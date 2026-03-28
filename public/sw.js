const CACHE_NAME = 'crater-cache-v1';
const urlsToCache = [
  '/',
  '/favicons/favicon.ico',
  '/favicons/android-chrome-192x192.png',
  '/favicons/android-chrome-256x256.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
