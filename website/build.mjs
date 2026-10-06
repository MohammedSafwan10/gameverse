import { mkdirSync, readFileSync, writeFileSync, cpSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const out = resolve(root, 'dist');
mkdirSync(resolve(out, 'privacy'), { recursive: true });
const esc = (text) => text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
export const games = [
  { id: 'chess', name: 'Chess', copy: 'Timeless strategy. Anytime.', detail: 'Choose an AI opponent or share the board with a friend. Enjoy different board styles, saved matches and move history.', modes: 'AI opponents · Local two-player', color: '#f2e7d7' },
  { id: 'memory-match', name: 'Memory Match', copy: 'A little focus. A satisfying match.', detail: 'Turn over beautifully crafted cards and find every pair. Play at your own pace, race the clock or take on a growing challenge.', modes: 'Classic · Time Trial · Challenge', color: '#e8f5ff' },
  { id: 'flappy-bird', name: 'Flappy Bird', copy: 'Simple taps. Big fun.', detail: 'Find your rhythm and fly between the pipes. Switch between sunny Classic skies and the neon Cyber world, with the same gameplay rules.', modes: 'Classic sky · Cyber sky', color: '#c9f0ff' },
  { id: 'block-merge', name: 'Block Merge', copy: 'Swipe, merge and reach higher.', detail: 'Slide matching number tiles together and work toward 2048. Keep going in Classic, beat the timer or unwind with Zen.', modes: 'Classic · Time Challenge · Zen', color: '#e6f4ee' },
  { id: 'tic-tac-toe', name: 'Tic-Tac-Toe', copy: 'Classic fun for everyone.', detail: 'Make your next move count. Play a quick round against the AI or pass the phone to a friend for a local two-player match.', modes: 'AI opponents · Local two-player', color: '#e6f0ff' },
  { id: 'connect-four', name: 'Connect Four', copy: 'Drop, connect and outsmart.', detail: 'Drop your discs and connect four before your opponent. Challenge the AI or play face-to-face on the same device.', modes: 'AI opponents · Local two-player', color: '#fff0d4' },
  { id: 'quiz-master', name: 'Quiz Master', copy: 'Test what you know across five topics.', detail: 'Explore Science, History, Geography, Mathematics and Technology. Choose a quiz length, answer timed questions and review the explanations afterward.', modes: 'Five offline topics · Answer review', color: '#eef3ff' },
];

const icon = (name, cls = '') => {
  const shapes = {
    arrow: '<path d="m9 5 7 7-7 7"/>',
    offline: '<path d="m3 3 18 18M5 9a12 12 0 0 1 3-2m5-2a15 15 0 0 1 8 4M8 13a7 7 0 0 1 3-1m4 1 1 1M11 17l1 1"/>',
    people: '<circle cx="8" cy="7" r="3"/><circle cx="17" cy="8" r="2.5"/><path d="M2 21v-4a6 6 0 0 1 12 0v4m3 0h5v-4a5 5 0 0 0-6-5"/>',
    phone: '<rect x="6" y="2" width="12" height="20" rx="2"/><path d="M10 18h4"/>',
    menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',
    close: '<path d="m6 6 12 12M18 6 6 18"/>',
  };
  return `<svg class="icon ${cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${shapes[name]}</svg>`;
};
const brand = '<a class="brand" href="/" aria-label="GameVerse home"><img src="/assets/icon.webp" width="42" height="42" alt=""><span>GameVerse</span></a>';
const header = `<header class="header wrap">${brand}<nav class="desktop-nav" aria-label="Main navigation"><a href="/#games">Games</a><a href="/#about">About</a><a href="/privacy/">Privacy</a></nav><a class="status" href="/#release">Coming soon</a><details class="mobile-nav"><summary aria-label="Navigation menu">${icon('menu')}</summary><nav aria-label="Mobile navigation"><a href="/#games">Games</a><a href="/#about">About</a><a href="/privacy/">Privacy policy</a><a href="/#release">Coming soon</a></nav></details></header>`;
const footer = `<footer class="footer wrap"><span>NexDark Labs</span><div><a href="/privacy/">Privacy policy</a><a href="mailto:nexdarksolutions@gmail.com">nexdarksolutions@gmail.com</a></div></footer>`;
const play = '<svg class="play-icon" viewBox="0 0 24 26" aria-hidden="true"><path fill="#28c7ff" d="M1 1v24l12-12z"/><path fill="#39db82" d="m1 1 16 9-4 3z"/><path fill="#ffcf38" d="m17 10 6 3-6 3-4-3z"/><path fill="#ff5669" d="m1 25 16-9-4-3z"/></svg>';
const comingButton = `<a class="cta" href="#release" data-release>${play}<span>Coming soon on Google Play</span></a>`;

function shell(title, description, content, path = '/') {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="theme-color" content="#fffaf1"><title>${title}</title><meta name="description" content="${description}"><link rel="canonical" href="https://gameverse.nexdark.com${path}"><meta property="og:title" content="${title}"><meta property="og:description" content="${description}"><meta property="og:type" content="website"><meta property="og:url" content="https://gameverse.nexdark.com${path}"><meta property="og:image" content="https://gameverse.nexdark.com/assets/hero.webp"><link rel="icon" type="image/webp" href="/assets/icon.webp"><link rel="preload" href="/assets/Outfit-900.ttf" as="font" type="font/ttf" crossorigin><link rel="stylesheet" href="/styles.css"><script src="/app.js" defer></script></head><body><a class="skip-link" href="#main">Skip to content</a>${header}${content}${footer}</body></html>`;
}

const cards = games.map((game, i) => `<article class="game-card ${i >= 4 ? 'compact-card' : ''}" style="--card-color:${game.color}"><button class="game-button" type="button" data-game="${game.id}" aria-label="About ${game.name}"><div class="game-art"><img src="/assets/${game.id}.webp" alt="" width="640" height="420" loading="lazy"></div><div class="game-caption"><div><h3>${game.name}</h3><p>${game.copy}</p></div><span class="round-arrow">${icon('arrow')}</span></div></button></article>`).join('');
const dialogs = games.map((game) => `<dialog id="${game.id}" class="game-dialog" aria-labelledby="${game.id}-title"><button class="close-button" type="button" data-close aria-label="Close ${game.name} details">${icon('close')}</button><img class="dialog-art" src="/assets/${game.id}.webp" alt="" width="640" height="420" loading="lazy"><div class="dialog-copy"><p class="eyebrow">MEET YOUR NEXT FAVORITE</p><h2 id="${game.id}-title">${game.name}</h2><p>${game.detail}</p><p class="mode-label">${game.modes}</p><p class="availability">Available in the Android app. Coming soon on Google Play.</p><button class="secondary-button" type="button" data-close>Back to the collection</button></div></dialog>`).join('');

writeFileSync(resolve(out, 'index.html'), shell('GameVerse — Seven offline games. One Android app.', 'Chess, Memory Match, Flappy Bird, Block Merge and more. Seven offline games with local play and on-device progress. Coming soon on Google Play.', `<main id="main"><section class="hero wrap" aria-labelledby="hero-title"><div class="hero-copy"><h1 id="hero-title">Your next<br>favorite game.<br>All in one place.</h1><p>Seven offline games. No account needed.</p>${comingButton}</div><div class="hero-visual"><img class="hero-art" src="/assets/hero.webp" width="1536" height="1024" alt="A tactile collection of chess pieces, memory cards, number tiles and arcade game pieces" fetchpriority="high"><div class="app-phone"><img src="/assets/app-home.webp" width="390" height="844" alt="The real GameVerse home screen with featured games and the game collection"></div></div></section><section id="games" class="collection wrap" aria-labelledby="games-title"><h2 id="games-title">Seven games.<br class="mobile-break"> Endless good moments.</h2><div class="game-grid">${cards}</div></section><section id="about" class="benefits wrap" aria-label="Why GameVerse"><div>${icon('offline')}<div><h2>Play offline</h2><p>All seven games work without internet.</p></div></div><div>${icon('people')}<div><h2>Local two-player</h2><p>Share Chess, Tic-Tac-Toe and Connect Four.</p></div></div><div>${icon('phone')}<div><h2>Progress stays on device</h2><p>Your game records are saved locally.</p></div></div></section><section class="release wrap" id="release"><span class="release-dot" aria-hidden="true"></span><p>Made for your next little break. <strong>Coming soon on Google Play.</strong></p></section></main>${dialogs}<dialog id="release-dialog" class="release-dialog" aria-labelledby="release-title"><button class="close-button" type="button" data-close aria-label="Close availability information">${icon('close')}</button><img src="/assets/icon.webp" alt="" width="76" height="76"><p class="eyebrow">THE NEXT LITTLE BREAK</p><h2 id="release-title">See you on Google Play.</h2><p>GameVerse is coming soon. There isn't a Play Store download link yet.</p><p>Questions? <a href="mailto:nexdarksolutions@gmail.com">Contact NexDark Labs</a>.</p><button class="secondary-button" type="button" data-close>Keep exploring</button></dialog>`));

const policy = readFileSync(resolve(root, '../docs/PRIVACY_POLICY.md'), 'utf8');
const policyHTML = policy.trim().split(/\r?\n\s*\r?\n/).map((part) => {
  if (part.startsWith('# ')) return `<h1>${esc(part.slice(2))}</h1>`;
  if (part.startsWith('## ')) return `<h2>${esc(part.slice(3))}</h2>`;
  return `<p>${esc(part).replaceAll('nexdarksolutions@gmail.com', '<a href="mailto:nexdarksolutions@gmail.com">nexdarksolutions@gmail.com</a>')}</p>`;
}).join('\n');
writeFileSync(resolve(out, 'privacy/index.html'), shell('GameVerse Privacy Policy — NexDark Labs', 'How GameVerse handles offline game records, device preferences and your privacy choices.', `<main id="main" class="policy wrap"><a class="back-link" href="/">← Back to GameVerse</a><article>${policyHTML}</article></main>`, '/privacy/'));
writeFileSync(resolve(out, '404.html'), shell('Page not found — GameVerse', 'Return to the GameVerse collection.', '<main id="main" class="not-found wrap"><h1>A little off the board.</h1><p>This page does not exist.</p><a class="cta" href="/">Back to GameVerse</a></main>'));
writeFileSync(resolve(out, 'robots.txt'), 'User-agent: *\nAllow: /\nSitemap: https://gameverse.nexdark.com/sitemap.xml\n');
writeFileSync(resolve(out, 'sitemap.xml'), '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://gameverse.nexdark.com/</loc></url><url><loc>https://gameverse.nexdark.com/privacy/</loc></url></urlset>');
for (const file of ['styles.css', 'app.js']) cpSync(resolve(root, file), resolve(out, file));
cpSync(resolve(root, 'assets'), resolve(out, 'assets'), { recursive: true });
console.log('Built landing page, policy, 404, sitemap and self-hosted assets.');
