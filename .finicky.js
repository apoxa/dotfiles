// @ts-check

/**
 * @typedef {import('/Applications/Finicky.app/Contents/Resources/finicky.d.ts').FinickyConfig} FinickyConfig
 */

/**
 * @type {FinickyConfig}
 */

const browsers = {
  firefox: "org.mozilla.firefox", // or Firefox
  firefox_work:
    "/Users/stierbn/Library/Application Support/Firefox/Profiles/sd8mkzkp.default-release-1701947069561",
  firefox_personal:
    "/Users/stierbn/Library/Application Support/Firefox/Profiles/wr7kuZwn.Profile 1",
};

const apps = {
  spotify: "com.spotify.client",
  teams: "com.microsoft.teams2",
  zoom: "us.zoom.xos",
};

export default {
  defaultBrowser: browsers.firefox,
  options: {
    logRequests: false,
  },

  rewrite: [
    {
      // Preview.app encodes '#' als '%23' – rückgängig machen
      match: (url, { opener }) =>
        opener.bundleId === "com.apple.Preview" && url.href.includes("%23"),
      url: (url) => url.href.replace(/%23/g, "#"),
    },
    {
      // Strip tracking parameters (https://straus.it/blog/finicky-url-routing/)
      match: (m) => true,
      url: (url) => {
        const lower = (s) => String(s || "").toLowerCase();
        const removeExact = new Set([
          "fbclid",
          "gclid",
          "dclid",
          "gbraid",
          "wbraid",
          "msclkid",
          "ttclid",
          "twclid",
          "li_fat_id",
          "mkt_tok",
          "mc_cid",
          "mc_eid",
          "igsh",
          "si",
          "feature",
          "ref",
          "ref_src",
          "spm",
        ]);
        const removePrefixes = ["utm_", "uta_", "ga_", "pk_", "vero_"];
        const removeByValue = new Set([
          "share",
          "social",
          "social_media",
          "social_network",
        ]);

        const keys = [...url.searchParams.keys()];

        for (const key of keys) {
          const k = lower(key),
            v = lower(url.searchParams.get(key));
          const isExact = removeExact.has(k);
          const isPrefix = removePrefixes.some((p) => k.startsWith(p));
          const isValueNoise =
            (k === "source" || k === "src" || k === "medium") &&
            removeByValue.has(v);

          if (isExact || isPrefix || isValueNoise) {
            url.searchParams.delete(key);
          }
        }

        return url.href;
      },
    },
    {
      // Decode Microsoft SafeLinks
      match:
        /statics\.teams\.cdn\.office\.net\/evergreen-assets\/safelinks\/.*url=(https%3A%2F%2F(?:[a-zA-Z]+\.)zoom\.us.*)&locale=.*/,
      url: (url) => {
        const match = url.search.match(/url=([^&]*)/);
        if (match && match[1]) {
          const decodedUrl = decodeURIComponent(match[1]);
          // Parse and return clean URL components
          // ...
        }
        return { ...url };
      },
    },
    {
      // Open Zoom in Zoom.app
      match: (url) =>
        url.host.includes("zoom.us") && url.pathname.includes("/j/"),
      url: (url) => {
        try {
          const match = url.search.match(/pwd=(\w*)/);
          var pass = match ? "&pwd=" + match[1] : "";
        } catch {
          var pass = "";
        }
        const pathMatch = url.pathname.match(/\/j\/(\d+)/);
        var conf = "confno=" + (pathMatch ? pathMatch[1] : "");
        url.search = conf + pass;
        url.pathname = "/join";
        url.protocol = "zoommtg";
        return url;
      },
    },
    {
      // Bypass Medium Paywalls
      match: /medium.com/,
      url: ({ url }) => {
        return {
          pathname: "/" + url.host + "/" + url.pathname,
          host: "freedium.cfd",
        };
      },
    },
  ],

  handlers: [
    {
      // Teams links open in Teams
      match: finicky.matchHostnames(["teams.microsoft.com"]),
      browser: apps.teams,
      url: ({ url }) => ({ ...url, protocol: "msteams" }),
    },
    {
      // Zoom links open in Zoom app
      match: /zoom\.us\/join/,
      browser: apps.zoom,
    },
    {
      // Links FROM Outlook always open in work browser
      match: (_url, { opener }) =>
        ["com.microsoft.Outlook"].includes(opener?.bundleId ?? ""),
      browser: (url) => ({
        // Firefox needs a workaround for profile loading because it's not included in Finicky
        name: "/Applications/Firefox.app",
        appType: "path",
        args: ["-n", "--args", "--profile", browsers.firefox_work, url.href],
      }),
    },
    {
      match: finicky.matchHostnames("open.spotify.com"),
      browser: apps.spotify,
    },
  ],
};
