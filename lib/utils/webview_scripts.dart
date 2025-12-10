class WebViewScripts {
  static const String hideHeaderScript = """
    (function() {
      if (window.location.href.includes('music.apple.com')) return;
      var style = document.createElement('style');
      style.innerHTML = `
        header, 
        .header, 
        #header, 
        .site-header,
        div[data-testid="header"],
        [role="banner"] { 
          display: none !important; 
        }
      `;
      document.head.appendChild(style);
    })();
  """;

  static const String hideOpenAppButtonScript = """
    (function() {
      var style = document.createElement('style');
      style.innerHTML = `
        /* Hide specific elements that look like "Open App" buttons */
        a[href*="play.google.com"],
        a[href*="itunes.apple.com"],
        button[aria-label="Open App"],
        button[aria-label="Get App"],
        div[role="button"]:has(div:contains("Open App")),
        [data-testid="action-bar-row"] button,
        .Button-sc-1dqy6lx-0.kOaQo, /* Specific class seen in some versions */
        [aria-label="Open in App"]
        {
           display: none !important;
        }
      `;
      document.head.appendChild(style);

      // MutationObserver to handle dynamic loading
      const observer = new MutationObserver((mutations) => {
        const buttons = document.querySelectorAll('button, a');
        buttons.forEach(btn => {
           if (btn.innerText.includes('Open App') || btn.innerText.includes('Get App') || btn.innerText.includes('Install App')) {
             btn.style.display = 'none';
           }
        });
      });
      
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    })();
  """;

  static const String hideFacebookAppBanner = """
    (function() {
      if (!window.location.href.includes('facebook.com')) return;
      if (window.location.href.includes('/login/')) return;
      
      var style = document.createElement('style');
      style.innerHTML = `
        /* Hide entire App Bar / Header on Facebook Mobile */
        #header,
        .header,
        div[id="header"],
        div[data-sigil="m-chrome-header"],
        div[role="banner"],
        div[class*="header"],
        div[id="msite-app-banner"],
        div[id="mobile_banner_root"],
        .ms-banner,
        ._55i1, 
        ._52z5,
        
        /* Common Facebook "Open App" banner selectors just in case */
        [aria-label="Open App"],
        [aria-label="Get Facebook App"],
        div[role="banner"]:has(a[href*="play.google.com"]),
        div[role="banner"]:has(a[href*="itunes.apple.com"]),
        .jewelButton,
        div:contains("Open in App"),
        span:contains("Open in App")
      {
          display: none !important;
      }
      `;
      document.head.appendChild(style);

      // Aggressive removal function
      function removeBanners() {
          // 1. Target known elements
          const banners = document.querySelectorAll('div, span, a, button, header');
          banners.forEach(el => {
              const text = el.innerText ? el.innerText.trim().toLowerCase() : '';
              if (text && (
                  text === 'open app' || 
                  text === 'get app' || 
                  text.includes('open in app') ||
                  text.includes('get the facebook app') ||
                  text.includes('get facebook for android')
              )) {
                  // Traverse up to find the container banner if possible, or just hide the element
                  let container = el.closest('[role="banner"]') || el.closest('div[style*="position: fixed"]') || el;
                  container.style.display = 'none';
              }
          });
          
          // 2. Target fixed headers at the top
          const possibleHeaders = document.querySelectorAll('div[style*="position: fixed"][style*="top: 0"]');
          possibleHeaders.forEach(header => {
             if(header.offsetHeight < 150) { // Increased threshold slightly
                 header.style.display = 'none';
             }
          });

          // 3. Target specific Facebook dynamic banner classes if found
          const specificBanners = document.querySelectorAll('.ms-banner, ._55i1, ._52z5, #msite-app-banner, #mobile_banner_root');
          specificBanners.forEach(b => b.style.display = 'none');
      }

      // Run immediately
      removeBanners();

      // Run on mutation
      const observer = new MutationObserver((mutations) => {
          removeBanners();
      });
      
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });

      // Fallback: Run every 1 second to catch stubborn banners
      setInterval(removeBanners, 1000);
    })();
  """;
}
