{{flutter_js}}
{{flutter_build_config}}

// Flutter's own service worker is deprecated (the generated one only
// unregisters itself), so load without it; sw.js provides offline support.
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    registerServiceWorker();
  },
});

// sw_manifest.js is only written by scripts/pwa_manifest.py, so a build that
// skips that step (e.g. `flutter run`) drops any worker left over from an
// earlier build instead of letting it serve stale files.
async function registerServiceWorker() {
  if (!('serviceWorker' in navigator)) return;

  let manifest;
  try {
    manifest = await fetch('sw_manifest.js', {method: 'HEAD', cache: 'no-store'});
  } catch (e) {
    return; // Offline: keep whatever worker is installed.
  }
  const contentType = manifest.headers.get('content-type') || '';
  if (!manifest.ok || !contentType.includes('javascript')) {
    const registration = await navigator.serviceWorker.getRegistration();
    if (registration && registration.scope === new URL('.', document.baseURI).href) {
      await registration.unregister();
    }
    return;
  }

  await navigator.serviceWorker.register('sw.js');

  // The worker never sees requests made before it took control (CanvasKit on
  // the first visit, or after an update), so tell it what this page loaded.
  const reportLoaded = async () => {
    const {active} = await navigator.serviceWorker.ready;
    const urls = performance.getEntriesByType('resource').map((e) => e.name);
    active.postMessage({type: 'cache-urls', urls});
  };
  navigator.serviceWorker.addEventListener('controllerchange', reportLoaded);
  reportLoaded();
}
