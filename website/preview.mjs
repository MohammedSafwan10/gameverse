import { createServer } from 'node:http';
import { readFileSync, statSync } from 'node:fs';
import { resolve, extname } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('./dist/', import.meta.url));
const types = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.webp': 'image/webp', '.ttf': 'font/ttf', '.txt': 'text/plain', '.xml': 'application/xml' };
createServer((request, response) => {
  try {
    const path = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    if (path === '/health') { response.end('ok'); return; }
    let file = resolve(root, '.' + path);
    if (file !== resolve(root) && !file.startsWith(root)) throw new Error('Outside static root');
    if (statSync(file).isDirectory()) file = resolve(file, 'index.html');
    response.setHeader('Content-Type', types[extname(file)] || 'application/octet-stream');
    response.end(readFileSync(file));
  } catch {
    response.writeHead(404, { 'Content-Type': 'text/html' });
    response.end(readFileSync(resolve(root, '404.html')));
  }
}).listen(4173, '127.0.0.1', () => console.log('Preview: http://127.0.0.1:4173'));
