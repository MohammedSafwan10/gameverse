# GameVerse website

## Selected direction and implementation

The owner selected **01 Tactile Arcade** and authorized implementation and
Coolify deployment. The website is implemented in `website/`: semantic static
HTML/CSS, native dialogs, mobile navigation and policy generated from the app's
source. Concepts are composition references, not live screenshots. Production
uses the existing icon/artwork and a real Flutter widget render in the phone.

- 01 Tactile Arcade: cream, cobalt and orange; sculpted game-piece hero;
  approachable premium identity, closest to the actual app. Recommended.
- 02 Midnight Collection: cinematic dark tabletop and curated game gallery.
- 03 Playroom Editorial: light asymmetric bento composition and bold typography.

## Content and routes

- `/`: promotional landing page, seven-game gallery, truthful offline/local-play
  benefits, coming-soon Google Play status, contact and policy links.
- `/privacy/`: public accessible HTML rendering of `docs/PRIVACY_POLICY.md`.
- Optional `/games/<slug>/` sections only if the selected flow benefits from them;
  not required to launch the marketing site.

Developer: NexDark Labs. Contact: nexdarksolutions@gmail.com.
No fake ratings, download counters, reviews, waitlist collection or analytics.
No fabricated Play Store URL. The CTA says Coming soon until the owner supplies
a published listing. Local two-player applies to supported board games, not all
seven games. No claim of online multiplayer.

## Hosting plan and verified access

Use the existing Oracle Always Free ARM64 VPS and Coolify. Read
`D:/Dev/oracle/OCI_COOLIFY_RUNBOOK.md` before infrastructure changes. Do not
create paid resources, resize the VM, change firewall rules or expose host ports.

Read-only checks on 6 October 2026 confirmed:

- Coolify context `nexdark` authenticates; server responds with version 4.3.23.
- Existing application BugHunter must remain untouched.
- There is no existing `gameverse.nexdark.com` DNS record.

Authorized new domain: `https://gameverse.nexdark.com`, with privacy at
`https://gameverse.nexdark.com/privacy/`. Create a new GameVerse project and
website application only. A small static build served by a multi-architecture
NGINX container is sufficient; no application database or secrets needed.
GitHub Pages is no longer the hosting plan: the owner requested Coolify.

## Implementation gates after selection

1. Build semantic responsive HTML/CSS with native text and isolated artwork.
2. Use real app screenshots; optimize static images without cropping subjects.
3. Verify 320, 360, 390, 430, 768 and 1440px widths; keyboard navigation,
   readable contrast, reduced motion and usable touch targets.
4. Keep the privacy source in sync between the app and public website.
5. Push the selected site source, verify ARM64 build and health endpoint, then
   create only the new GameVerse Coolify resource with modest resource limits.
6. Add only the GameVerse DNS record, verify origin HTTPS/certificate, routes,
   headers and deployment health. Preserve all unrelated domains/apps.

Do not claim deployment until a public HTTPS check succeeds.

## Verification / handoff

- Website build and three Node tests passed.
- Playwright passed 320×568, 360×800, 390×844, 430×932, 768×1024 and
  1440×1000: no horizontal overflow, decoded assets, seven dialogs, Escape and
  returned focus, coming-soon dialog, mobile navigation and policy; real 404.
- Desktop/mobile screenshots inspected against the chosen reference. Reused
  app card art differs from concept props intentionally; native content remains
  responsive and truthful. Hero edges softened and phone frame refined.
- `flutter analyze`: clean. Full serial suite: 406 passed. Android debug build:
  passed. The focused marketing golden also passed without baseline updates.
- `website/README.md` and `website/ASSETS.md` document local preview, asset
  provenance and production build. No local preview server is left running.
- Live deployment verified on 6 October 2026: HTTPS homepage, `/privacy/` and
  `/health` return 200; unknown routes return 404. CSP/frame denial present,
  no response cookies. Playwright passed all six viewports against the public
  site, and the deployed desktop/mobile screenshots were inspected.

## Live Coolify resource and repeat deployments

- URL: https://gameverse.nexdark.com
- Policy: https://gameverse.nexdark.com/privacy/
- Existing ARM64 server: `8z2ogeah73dlohmjvqjb41ag`.
- New project GameVerse: `3gr7lgjbv2d4r9blxl3vzia9`.
- New app GameVerse Website: `lfptedxauxnlqhoc9wrnkxm1`.
- Successful deployment: `bfz9rdrkfjdtrhb8c8srtfgu`.
- Deployed source commit: `f292de70547cff9c0d951fd73e7e4cb45411d6b9` on
  `MohammedSafwan10/gameverse`, branch `main`.
- Root Dockerfile, base directory `/`, port 8080, `/health`, CPU 0.25 and memory
  128M. Registry manifests confirmed Linux ARM64 for Node 24 Alpine and NGINX
  1.30.5 Alpine. Coolify's ARM64 build finished and the container is healthy.
- Only DNS record added: DNS-only A `gameverse.nexdark.com` → `129.151.44.211`.
  Origin HTTPS verifies normally, with no TLS bypass. No other DNS, server,
  firewall or application was changed.

This first deployment is deliberately pinned to the verified commit above.
Before a future release, set the application's source commit to the desired
pushed SHA (or `HEAD` in Coolify's Git Source settings if latest-main deployments
are intended), then deploy this exact application UUID. CLI v1.8 does not expose
a source-commit update flag. Never deploy a dirty local tree or claim that a
push updates this site automatically. Automatic push deployment requires a
GitHub App/webhook as well as Coolify's auto-deploy setting; that integration
was not added as part of this manual deployment.

```powershell
& 'C:/Users/Thumbeja/AppData/Local/Coolify/coolify.exe' context verify
& 'C:/Users/Thumbeja/AppData/Local/Coolify/coolify.exe' deploy uuid 'lfptedxauxnlqhoc9wrnkxm1'
```

Read the Oracle runbook before modifying deployment settings. Monitor returned
deployment UUIDs with `deploy get`, printing only status/commit/timestamps, not
raw configuration or secrets. Do not modify unrelated apps, domains, firewall
or OCI capacity.

Next: provide a published Play Store listing to replace the truthful coming-soon
CTA. Physical-device release smoke testing/store approval remain separate app
release gates; a healthy marketing site does not certify the Android app.
