hs.window.animationDuration = 0.1
local hyper = {'ctrl', 'alt', 'cmd'}

hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()

hs.loadSpoon('MiroWindowsManager')
spoon.MiroWindowsManager:bindHotkeys({
  up         = {hyper, 'k'},
  right      = {hyper, 'l'},
  down       = {hyper, 'j'},
  left       = {hyper, 'h'},
  fullscreen = {hyper, 'f'}
})

hs.hotkey.bind({'ctrl','cmd'}, 'q', function() hs.caffeinate.startScreensaver() end )

hs.hotkey.bind({'ctrl','cmd'},'t', function()
    if hs.application.title(hs.application.frontmostApplication()) ~= 'iTerm2' then
        hs.application.launchOrFocus('iTerm')
    end
    hs.eventtap.keyStroke('cmd','n')
end)


ht = hs.loadSpoon("HammerText")
ht.keywords = {
    ["..shrug"] = "¯\\_(ツ)_/¯",
    ["..tf"] = "(╯°□°）╯︵ ┻━┻",
    ["..paste"] = function() return hs.pasteboard.getContents() end,
}
ht:start()
