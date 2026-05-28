export default {
  defaultBrowser: "Firefox",

  rewrite: [
    {
      // Preview.app encodes '#' als '%23' – rückgängig machen
      match: (url, { opener }) =>
        opener.bundleId === "com.apple.Preview" && url.href.includes("%23"),
      url: (url) => url.href.replace(/%23/g, "#"),
    },
    {
      // Teams-Web-URLs als msteams:-Deeplink öffnen (wie URLDispatcher: "msteams:%1")
      match: /^https:\/\/teams\.microsoft\.com/,
      url: (url) => `msteams:${url.href}`,
    },
  ],

  handlers: [
    {
      match: /^msteams:/,
      browser: "Microsoft Teams",
    },
  ],
};
