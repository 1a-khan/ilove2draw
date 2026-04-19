const CACHE_NAME = "ilove2draw-v4";

const APP_SHELL = [
  "/",
  "/index.html",
  "/manifest.json"
];

// Install — cache the app shell
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

// Activate — clean up old caches
self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

// Fetch — cache first for app shell and images, network first for everything else
self.addEventListener("fetch", event => {
  const url = new URL(event.request.url);

  // Cache local images aggressively
  if (url.pathname.startsWith("/images/") || url.pathname.startsWith("/icons/")) {
    event.respondWith(
      caches.open(CACHE_NAME).then(cache =>
        cache.match(event.request).then(cached => {
          if (cached) return cached;
          return fetch(event.request).then(response => {
            cache.put(event.request, response.clone());
            return response;
          });
        })
      )
    );
    return;
  }

  // Pixabay CDN images — let browser handle them directly, no service worker interference
  if (url.hostname.includes("pixabay.com")) return;

  // App shell — cache first
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request))
  );
});
