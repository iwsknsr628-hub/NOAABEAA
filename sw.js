/* なんしよ？ PWA Service Worker — network-first（APIはキャッシュしない） */
const CACHE = "nanshiyo-pwa-v1";
const PRECACHE = [
  "/",
  "/index.html",
  "/manifest.webmanifest",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
  "/icons/icon.svg"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(PRECACHE)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

function shouldBypass(url) {
  const host = url.hostname;
  if (host.includes("supabase.co")) return true;
  if (host.includes("googleapis.com") || host.includes("gstatic.com")) return true;
  if (host.includes("google.com") || host.includes("maps.")) return true;
  if (host.includes("openstreetmap") || host.includes("nominatim") || host.includes("photon")) return true;
  if (host.includes("leaflet") || host.includes("unpkg.com") || host.includes("cdn.")) return true;
  if (host.includes("rakuten") || host.includes("amazon.")) return true;
  return false;
}

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;

  let url;
  try {
    url = new URL(req.url);
  } catch (e) {
    return;
  }

  if (shouldBypass(url)) return;

  // same-origin only for cache fallback
  const sameOrigin = url.origin === self.location.origin;

  event.respondWith(
    (async () => {
      try {
        const net = await fetch(req);
        if (sameOrigin && net && net.ok) {
          const copy = net.clone();
          caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {});
        }
        return net;
      } catch (err) {
        const cached = await caches.match(req);
        if (cached) return cached;
        if (req.mode === "navigate") {
          const home = await caches.match("/index.html") || await caches.match("/");
          if (home) return home;
        }
        throw err;
      }
    })()
  );
});
