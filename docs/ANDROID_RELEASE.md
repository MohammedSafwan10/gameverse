# Android release and local builds

## Toolchain

This project uses Flutter 3.47.5 / Dart 3.13.4, AGP 9.4.0, Gradle 9.6.0,
Kotlin 2.4.20 and Java 17-compatible bytecode. Gradle's download is checksum
pinned in the wrapper. Use the SDK configured in `android/local.properties`.

AGP's built-in Kotlin defaults to 2.2.10. Flutter requires at least 2.2.20.
Declare the override in **both** `android/settings.gradle` (plugin resolution,
apply false) and root `android/build.gradle` (compiler dependency); do not apply
`kotlin-android` in the app module when built-in Kotlin is enabled. A root-only
override did not replace the compiler loaded by plugin resolution.

`android.newDsl=false` is still needed by this Flutter Gradle integration.
Do not bypass validation with `--android-skip-build-dependency-validation`.

Primary references:

- https://developer.android.com/build/releases/agp-9-0-0-release-notes#runtime-dependency-on-kotlin-gradle-plugin
- https://developer.android.com/build/releases/agp-9-4-0-release-notes
- https://kotlinlang.org/docs/whatsnew2420.html

## Commands

```powershell
flutter pub get
flutter analyze
flutter test --concurrency=1
flutter build apk --debug
flutter build appbundle --release
python tool/verify_android_bundle.py build/app/outputs/bundle/release/app-release.aab
```

Serial tests currently avoid a Windows file-lock collision between tests that
share GetStorage's test directory. A concurrent-suite failure of that kind is
not proof of a gameplay failure; test-isolation cleanup remains separate work.

Release signing requires the owner's ignored `android/key.properties` and
keystore. Missing credentials must fail, never silently fall back to debug
signing. Keep credentials and keystore out of Git and logs. Preserve independent
backups; do not generate a replacement key for an existing app.

Output: `build/app/outputs/bundle/release/app-release.aab`. An AAB is an upload
artifact, not directly installable. Validate it using Google's bundletool and
verify its signature. Native 64-bit ELF LOAD alignment must support 16KB pages;
the provided script checks this plus bundled fonts, policy and permissions.

## Owner's version choice

Keep `1.0.0+1` for the first Play Store listing, explicitly chosen by the owner.
The earlier GitHub APK is version 1.0.1+2; version code 1 cannot upgrade that
installation. Fresh install or a future higher build code is required. Never
silently uninstall a user's app to work around this.

## Store gates (not a production certificate)

- Publish the policy at the selected Coolify website's `/privacy/` route.
- Owner reviews policy, Data safety, target audience/content rating and listing.
- Complete any Play Console testing/verification requirements for this account.
- Smoke-test a fresh **release** install offline, saved games after process death,
  upgrades, mute/haptics, long sessions and all seven games on real devices.
- Inspect Android 16KB-compatible device/emulator behavior, not only ELF headers.
- Verify Play Console accepts the uploaded artifact; do not infer store approval
  from a successful local build.

Contact/developer identity: NexDark Labs, nexdarksolutions@gmail.com.

## Play Console registration — 6 October 2026

The owner approved `com.nexdarklabs.gameverse` because `com.gameverse.app` was
already used in Play Console. Android applicationId, namespace and MainActivity
now match the registered identity. Preserve the existing release keystore.
Old-package installs remain separate; do not uninstall or claim data migration.
Title: GameVerse: Play Your Way. See `PLAY_STORE_LISTING.md` for the exact
Console state, audience choice, draft copy and production-access blocker.
