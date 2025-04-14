require("hs.ipc")

--# constants
-- ⌘ ⌃ ⌥ ⇧
local super = "⌃⌘"
local shift_super = "⇧⌃⌘"
local hyper = "⌃⌥⌘"
local shift_hyper = "⇧⌃⌥⌘"
--# bindings

hs.loadSpoon("SpoonInstall")
Install = spoon.SpoonInstall

hs.window.animationDuration = 0.0
hs.application.enableSpotlightForNameSearches(false)

hs.hotkey.bind(super, "q", function()
	hs.caffeinate.startScreensaver()
end)

hs.hotkey.bind(super, "t", function()
	term = hs.application.find("iTerm2") or hs.application.open("iTerm")
	term:selectMenuItem("New Window")
end)

hs.hotkey.bind(super, "return", function()
	term = hs.application.find(DefaultBrowser) or hs.application.open(DefaultBrowser)
	term:selectMenuItem("New Window")
end)

hs.hotkey.bind(super, "o", function()
	local officeApps = { "Mattermost", "Microsoft Teams", "Microsoft Outlook", "chat.rocket" }
	for _, name in ipairs(officeApps) do
		_ = hs.application.find(name) or hs.application.open(name)
	end
end)

function appID(app)
	infoBundle = hs.application.infoForBundlePath(app)
	if infoBundle ~= nil then
		return infoBundle["CFBundleIdentifier"]
	end
end

chromeBrowser = appID("/Applications/Google Chrome.app")
edgeBrowser = appID("/Applications/Microsoft Edge.app")
firefoxBrowser = appID("/Applications/Firefox.app")
teamsApp = appID("/Applications/Microsoft Teams.app")

DefaultBrowser = firefoxBrowser

Install:andUse("URLDispatcher", {
	config = {
		url_patterns = {
			{ "msteams:", teamsApp },
		},
		url_redir_decoders = {
			-- Send MS Teams URLs directly to the app
			{ "MS Teams URLs", "(https://teams.microsoft.com.*)", "msteams:%1", true },
			-- Preview incorrectly encodes the anchor
			-- character in URLs as %23, we fix it
			{ "Fix broken Preview anchor URLs", "%%23", "#", false, "Preview" },
		},
		default_handler = DefaultBrowser,
	},
	start = true,
	-- Enable debug logging if you get unexpected behavior
	-- loglevel = 'debug'
})
