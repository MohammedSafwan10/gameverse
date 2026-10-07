"""Verify bundled offline fonts, prohibited permissions, and native 16KB ELF alignment.

Usage: python tool/verify_android_bundle.py build/app/outputs/bundle/release/app-release.aab
This complements (does not replace) bundletool validation and device testing.
"""
import json
import struct
import sys
import zipfile


def verify(path):
    with zipfile.ZipFile(path) as bundle:
        names = set(bundle.namelist())
        prefix = "base/assets/flutter_assets/"
        manifest = json.loads(bundle.read(prefix + "FontManifest.json"))
        families = {entry["family"]: entry["fonts"] for entry in manifest}
        for family in ("Outfit", "Inter"):
            assert {font.get("weight") for font in families[family]} == {
                400, 500, 600, 700, 800, 900
            }, f"Missing font weights: {family}"
        for entry in manifest:
            for font in entry["fonts"]:
                assert prefix + font["asset"] in names, font["asset"]
        policy = bundle.read(prefix + "docs/PRIVACY_POLICY.md").decode("utf-8")
        assert "NexDark Labs" in policy
        assert "nexdarksolutions@gmail.com" in policy
        # Protobuf manifest embeds permission strings in UTF-8.
        android_manifest = bundle.read("base/manifest/AndroidManifest.xml")
        for permission in ("INTERNET", "ACCESS_FINE_LOCATION", "CAMERA", "RECORD_AUDIO"):
            assert ("android.permission." + permission).encode() not in android_manifest, permission
        assert b"com.nexdarklabs.gameverse" in android_manifest
        libraries = sorted(n for n in names if n.endswith(".so"))
        assert libraries, "No native libraries found"
        for name in libraries:
            data = bundle.read(name)
            assert data[:4] == b"\x7fELF", name
            order = "<" if data[5] == 1 else ">"
            is64 = data[4] == 2
            phoff = struct.unpack_from(order + ("Q" if is64 else "I"), data, 32 if is64 else 28)[0]
            entsize, count = struct.unpack_from(order + "HH", data, 54 if is64 else 42)
            aligns = []
            for i in range(count):
                offset = phoff + i * entsize
                kind = struct.unpack_from(order + "I", data, offset)[0]
                if kind == 1:
                    align = struct.unpack_from(order + ("Q" if is64 else "I"), data, offset + (48 if is64 else 28))[0]
                    aligns.append(align)
            # Android's 16KB page-size requirement concerns 64-bit ABIs.
            if is64:
                assert aligns and min(aligns) >= 16384, f"16KB alignment failure: {name}: {aligns}"
            print(f"{name}: LOAD alignment {aligns}")
        print("PASS: offline fonts, policy identity, release permissions and native 16KB alignment")


if __name__ == "__main__":
    verify(sys.argv[1])
