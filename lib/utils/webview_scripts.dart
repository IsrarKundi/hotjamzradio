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
}
