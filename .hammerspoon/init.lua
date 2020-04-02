hs.loadSpoon('SpoonInstall')
Install=spoon.SpoonInstall

local hyper = {'ctrl', 'alt', 'cmd'}
local shift_hyper = {'shift', 'ctrl', 'alt', 'cmd'}
hs.window.animationDuration = 0.1

Install:andUse('ReloadConfiguration');

Install:andUse('MiroWindowsManager',{
    {},
    fn = function(m)
        m:bindHotkeys({
        up         = {hyper, 'k'},
        right      = {hyper, 'l'},
        down       = {hyper, 'j'},
        left       = {hyper, 'h'},
        fullscreen = {hyper, 'f'}
        })
    end
})

hs.hotkey.bind({'ctrl','cmd'}, 'q', function() hs.caffeinate.startScreensaver() end )

hs.hotkey.bind({'ctrl','cmd'},'t', function()
    term=hs.application.find('iTerm2') or hs.application.open('iTerm')
    term:selectMenuItem('New Window')
end)
