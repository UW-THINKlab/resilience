// Offline service worker for the installed web app.
//
// sw_manifest.js is generated after `flutter build web` by
// scripts/pwa_manifest.py. It lists the app-shell files and a content hash;
// a new hash makes the browser install a fresh copy of the shell. CanvasKit
// is cached per Flutter engine revision so app deploys don't re-download it.
// Supabase, map tiles, and other cross-origin requests are left alone.
importScripts('sw_manifest.js');

const {version, engineRevision, files} = self.PWA_MANIFEST;
const SCOPE = self.registration.scope;
const APP_CACHE = `app-${version}`;
const ENGINE_CACHE = `canvaskit-${engineRevision}`;
const FONT_CACHE = 'fonts';
const FONT_HOSTS = ['fonts.googleapis.com', 'fonts.gstatic.com'];
const CANVASKIT_PREFIX = new URL('canvaskit/', SCOPE).href;

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    // 'no-cache' revalidates against the server, so unchanged files come back
    // as 304s from the HTTP cache instead of being downloaded again.
    const requests = files.map((f) => new Request(new URL(f, SCOPE), {cache: 'no-cache'}));
    await (await caches.open(APP_CACHE)).addAll(requests);
    await refreshCanvasKit();
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const stale = (await caches.keys()).filter((name) =>
      (name.startsWith('app-') && name !== APP_CACHE) ||
      (name.startsWith('canvaskit-') && name !== ENGINE_CACHE));
    await Promise.all(stale.map((name) => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const {request} = event;
  if (request.method !== 'GET') return;

  if (FONT_HOSTS.includes(new URL(request.url).hostname)) {
    event.respondWith(cacheFirst(request, FONT_CACHE));
  } else if (!request.url.startsWith(SCOPE)) {
    return;
  } else if (request.mode === 'navigate') {
    // Single-page app: every navigation gets the cached shell.
    event.respondWith(caches.match(SCOPE).then((shell) => shell || fetch(request)));
  } else {
    event.respondWith(cacheFirst(request, cacheFor(request.url)));
  }
});

self.addEventListener('message', (event) => {
  if (event.data?.type === 'cache-urls') {
    event.waitUntil(cacheMissing(event.data.urls));
  }
});

function cacheFor(url) {
  return url.startsWith(CANVASKIT_PREFIX) ? ENGINE_CACHE : APP_CACHE;
}

async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) {
    await (await caches.open(cacheName)).put(request, response.clone());
  }
  return response;
}

async function cacheMissing(urls) {
  for (const url of urls) {
    if (!url.startsWith(SCOPE) || await caches.match(url)) continue;
    try {
      const response = await fetch(url);
      if (response.ok) await (await caches.open(cacheFor(url))).put(url, response);
    } catch (e) {
      // Offline or gone; the next page load will report it again.
    }
  }
}

// After a Flutter upgrade, re-fetch the CanvasKit files the previous engine
// cache held (whichever variant this browser uses) so the app still starts
// offline. Failing here fails the install, which keeps the old version.
async function refreshCanvasKit() {
  const engineCache = await caches.open(ENGINE_CACHE);
  if ((await engineCache.keys()).length > 0) return;
  const urls = new Set();
  const previous = (await caches.keys()).filter((n) => n.startsWith('canvaskit-') && n !== ENGINE_CACHE);
  for (const name of previous) {
    for (const request of await (await caches.open(name)).keys()) {
      urls.add(request.url);
    }
  }
  const requests = [...urls].map((url) => new Request(url, {cache: 'no-cache'}));
  await engineCache.addAll(requests);
}
