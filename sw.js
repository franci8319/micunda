// Service worker mínimo — solo necesario para habilitar la instalación PWA.
// No cachea nada para evitar el aviso de datos de Chrome en Android.
self.addEventListener('install',  () => self.skipWaiting());
self.addEventListener('activate', () => self.clients.claim());
self.addEventListener('fetch',    () => {});
