// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options: https://github.com/johnste/finicky/wiki/Configuration

module.exports = {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      // Open google.com and *.google.com urls in Google Chrome
      match: [
        finicky.matchDomains(/(bbb|meeting)\.levigo.(de|cloud)/) // use helper function to match on domain only
      ],
      browser: "bbb"
    }
  ]
}
