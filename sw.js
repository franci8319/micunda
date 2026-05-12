const CACHE = 'micunda-v1';

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.add('/')));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);

  // Supabase siempre en red — necesita datos en tiempo real
  if (url.hostname.includes('supabase.co')) return;

  e.respondWith(
    caches.match(e.request).then(cached => {
      const network = fetch(e.request)
        .then(res => {
          if (res.ok && url.origin === self.location.origin) {
            caches.open(CACHE).then(c => c.put(e.request, res.clone()));
          }
          return res;
        })
        .catch(() => cached);
      return cached || network;
    })
  );
});
