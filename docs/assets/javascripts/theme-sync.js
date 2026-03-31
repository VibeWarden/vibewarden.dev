// Sync dark mode between landing page and docs.
// The landing page stores theme in localStorage key "theme" (dark/light).
// MkDocs Material stores palette in "/docs/.__palette".
// This script reads the landing page key and applies it to MkDocs on load.
(function() {
  try {
    var landingTheme = localStorage.getItem('theme');
    if (!landingTheme) return;

    var docsKey = '/docs/.__palette';
    var existing = localStorage.getItem(docsKey);

    // Only sync if no docs palette set yet, or if landing page was toggled more recently
    var scheme = landingTheme === 'dark' ? 'slate' : 'default';
    var palette = {
      index: landingTheme === 'dark' ? 1 : 0,
      color: {
        scheme: scheme,
        primary: 'deep-purple',
        accent: 'cyan',
        media: ''
      }
    };
    localStorage.setItem(docsKey, JSON.stringify(palette));

    // Apply immediately to body
    document.body.setAttribute('data-md-color-scheme', scheme);
    document.body.setAttribute('data-md-color-primary', 'deep-purple');
    document.body.setAttribute('data-md-color-accent', 'cyan');

    // Also check the correct radio button
    var radio = document.getElementById(landingTheme === 'dark' ? '__palette_1' : '__palette_0');
    if (radio) radio.checked = true;
  } catch(e) {}

  // When docs palette changes, write back to landing page key
  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(m) {
      if (m.attributeName === 'data-md-color-scheme') {
        var s = document.body.getAttribute('data-md-color-scheme');
        try { localStorage.setItem('theme', s === 'slate' ? 'dark' : 'light'); } catch(e) {}
      }
    });
  });
  observer.observe(document.body, { attributes: true, attributeFilter: ['data-md-color-scheme'] });
})();
