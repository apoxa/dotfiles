hs.loadSpoon('SpoonInstall')
Install=spoon.SpoonInstall

local hyper = {'ctrl', 'alt', 'cmd'}
local shift_hyper = {'shift', 'ctrl', 'alt', 'cmd'}
hs.window.animationDuration = 0.1

Install:andUse('ReloadConfiguration');

Install:andUse('BrewInfo',{
  config = {
    brew_info_style = {
      textFont = 'Hack Nerd Font Mono',
      textSize = 14,
      radius = 10 }
    },
    hotkeys = {
      -- brew info
      show_brew_info = {hyper, 'b'},
      open_brew_url = {shift_hyper, 'b'},
      -- brew cask info
      show_brew_cask_info = {hyper, 'c'},
      open_brew_cask_url = {shift_hyper, 'c'},
    }
  }
)

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


ht = hs.loadSpoon("HammerText")
ht.keywords = {
    ["..shrug"] = "¯\\_(ツ)_/¯",
    ["..eshrug"] = "¯\\\\_(ツ)_/¯",
    ["..tf"] = "(╯°□°）╯︵ ┻━┻",
    ["..paste"] = function() return hs.pasteboard.getContents() end,
}
ht:start()
