# GameVerse website

The approved **01 Tactile Arcade** landing page: responsive cream/navy/orange
composition, a sculpted game-piece hero, seven game-detail dialogs and a public
privacy policy. No framework dependencies, analytics, cookies or database.

## Run locally

Requires Node.js 24. From this directory:

```powershell
npm run dev
```

Open http://localhost:4173. Ctrl+C stops the server. Restart the command after
source changes; this small static preview does not provide hot reload.

```powershell
npm run build
npm test
npm run preview
```

`build.mjs` generates `dist/`, including `/privacy/` from the app's shared
`../docs/PRIVACY_POLICY.md`. Edit that source, not generated HTML.

## Production

The root `../Dockerfile` builds the site and serves it with multi-architecture
NGINX on container port 8080. Build context is the repository root. The
`.dockerignore` excludes the Flutter app, local keys, build artifacts and test
sources. `/health` reports readiness; unknown routes return a real HTTP 404.
Security headers include CSP, frame denial and restricted browser permissions.

Deployment target: the owner's existing Coolify/Oracle ARM64 VPS at
https://gameverse.nexdark.com. See `../docs/WEBSITE_PLAN.md` for deployment state
and operating instructions. Do not change other applications or host ports.

The Google Play CTA is deliberately **Coming soon** and opens an availability
dialog. Replace it with a real listing only after the owner publishes the app.
Game cards describe the app; they do not launch browser versions of the games.

## Verification and assets

`test/build.test.mjs` verifies the seven dialogs, shared privacy source, asset
links and honest availability. `test/browser.cjs` uses an installed Playwright
package to verify six viewports (320, 360, 390, 430, 768, 1440), keyboard focus,
dialogs, navigation, policy and 404. Set `SITE_URL` to test a deployed site.
Screenshots go to the ignored `.dart_tool/website-qa/` directory.

See `ASSETS.md` for provenance, fonts and reproduction. Preview servers belong
to the user: agents should not leave one running without asking.
