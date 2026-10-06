// Run with NODE_PATH pointing to the installed Playwright package.
const { chromium } = require('playwright');
const { mkdirSync } = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const base = process.env.SITE_URL || 'http://127.0.0.1:4173';
  const output = path.resolve(__dirname, '../../.dart_tool/website-qa');
  mkdirSync(output, { recursive: true });
  try {
    for (const [width, height] of [[320,568],[360,800],[390,844],[430,932],[768,1024],[1440,1000]]) {
      const page = await browser.newPage({ viewport: { width, height }, reducedMotion: 'reduce' });
      const errors = [];
      page.on('pageerror', e => errors.push(e.message));
      page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
      await page.goto(base, { waitUntil: 'networkidle' });
      await page.evaluate(() => document.fonts.ready);
      await page.locator('.footer').scrollIntoViewIfNeeded();
      await page.waitForFunction(() => [...document.querySelectorAll('.hero img, .game-card img')].every(i => i.complete && i.naturalWidth > 0));
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), `Overflow at ${width}`);
      await page.evaluate(() => scrollTo(0,0));
      if (width === 390 || width === 1440) await page.screenshot({ path: path.join(output, `${width}.png`), fullPage: true });
      const cards = page.locator('[data-game]');
      assert.equal(await cards.count(), 7);
      for (let i = 0; i < 7; i++) {
        const card = cards.nth(i);
        const id = await card.getAttribute('data-game');
        await card.click();
        await page.locator(`dialog#${id}`).waitFor({ state: 'visible' });
        await page.keyboard.press('Escape');
        assert.equal(await card.evaluate(b => b === document.activeElement), true);
      }
      await page.locator('[data-release]').click();
      await page.locator('#release-dialog').waitFor({ state: 'visible' });
      await page.locator('#release-dialog [data-close]').first().click();
      if (width <= 700) {
        await page.locator('.mobile-nav summary').click();
        await page.locator('.mobile-nav a[href="/privacy/"]').click();
      } else await page.locator('.desktop-nav a[href="/privacy/"]').click();
      await page.waitForURL('**/privacy/');
      assert.equal(await page.locator('h1').textContent(), 'GameVerse Privacy Policy');
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), `Policy overflow at ${width}`);
      if (width === 390) await page.screenshot({ path: path.join(output, 'privacy.png'), fullPage: true });
      assert.deepEqual(errors, [], `Browser errors at ${width}`);
      await page.close();
      console.log(`PASS ${width}x${height}: layout, assets, seven dialogs, focus, menu, release and policy`);
    }
    const page = await browser.newPage();
    const response = await page.goto(`${base}/not-a-page`);
    assert.equal(response.status(), 404);
    await page.close();
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exit(1); });
