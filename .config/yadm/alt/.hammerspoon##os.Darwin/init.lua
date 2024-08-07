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

hs.hotkey.bind(shift_hyper, "n", function()
	hs.eventtap.keyStroke({}, 71)
end)

-- Register my custom repository
Install.repos["apoSpoons"] = {
	desc = "apoxa's repository",
	url = "https://github.com/apoxa/apoSpoons",
	branch = "main",
}

hs.loadSpoon("GlobalMute")
spoon.GlobalMute:bindHotkeys({
	toggle = { hyper, "F12" },
})

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

-- global config
config = {
	networks = {
		["wlan@somewhere"] = "levigo",
		["DWMC3"] = "DWMC3",
	},
}

-- requires
watchables = require("utils.watchables")
controlplane = require("utils.controlplane")

-- controlplane
controlplane.enabled = { "autonl" }

-- start/stop modules
local modules = { controlplane, watchables }

hs.fnutils.each(modules, function(module)
	if module then
		module.start()
	end
end)

-- stop modules on shutdown
hs.shutdownCallback = function()
	hs.fnutils.each(modules, function(module)
		if module then
			module.stop()
		end
	end)
end

-- axbrowse
-- b = hs.axuielement.systemElementAtPosition(hs.mouse.absolutePosition())
-- hs.inspect(b:attributeNames())
-- hs.inspect(b:actionNames())
-- hs.inspect(b:parameterizedAttributeNames())
-- b:attributeValue("AXRoleDescription")
