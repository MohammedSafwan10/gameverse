import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const file = (path) => fileURLToPath(new URL('../dist/' + path, import.meta.url));
const home = readFileSync(file('index.html'), 'utf8');
test('all seven games have keyboard accessible cards and detail dialogs', () => {
  for (const id of ['chess','memory-match','flappy-bird','block-merge','tic-tac-toe','connect-four','quiz-master']) {
    assert.ok(home.includes(`data-game="${id}"`));
    assert.ok(home.includes(`id="${id}"`));
    assert.ok(existsSync(file(`assets/${id}.webp`)));
  }
  assert.equal((home.match(/data-game=/g) || []).length, 7);
});
test('public policy is generated from the app policy source', () => {
  const policy = readFileSync(file('privacy/index.html'), 'utf8');
  const source = readFileSync(new URL('../../docs/PRIVACY_POLICY.md', import.meta.url), 'utf8');
  for (const paragraph of source.trim().split(/\r?\n\s*\r?\n/)) {
    const plain = paragraph.replace(/^#{1,2} /, '');
    // Email addresses gain mailto links; all remaining policy wording is preserved.
    const flattened = policy.replace(/<[^>]*>/g, '').replaceAll('&amp;', '&');
    assert.ok(flattened.includes(plain));
  }
  assert.ok(policy.includes('NexDark Labs'));
});
test('every local linked asset exists and no fabricated store listing or remote tracker is present', () => {
  for (const match of home.matchAll(/(?:src|href)="(\/(?:assets\/[^"\s]+|styles\.css|app\.js))"/g)) {
    assert.ok(existsSync(file(match[1].slice(1))), match[1]);
  }
  assert.ok(!home.includes('play.google.com/store/apps/details'));
  assert.ok(!home.includes('google-analytics'));
  assert.ok(home.includes('Coming soon on Google Play'));
  assert.ok(existsSync(file('404.html')));
});
