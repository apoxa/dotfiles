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

-- global config
config = {
    networks = {
        ['wlan@somewhere'] = 'levigo',
        dwmc3 = 'DWMC3'
    }
}

-- requires
watchables   = require('utils.watchables')
controlplane = require('utils.controlplane')


-- controlplane
controlplane.enabled = { 'autonl' }

-- start/stop modules
local modules = { controlplane, watchables }

hs.fnutils.each(modules, function(module)
    if module then module.start() end
end)

-- stop modules on shutdown
hs.shutdownCallback = function()
    hs.fnutils.each(modules, function(module)
        if module then module.stop() end
    end)
end
