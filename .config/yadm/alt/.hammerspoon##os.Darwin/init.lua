require("hs.ipc")
local yabai = require("yabai")

--# constants
-- ⌘ ⌃ ⌥ ⇧
super = "⌃⌘"
shift_super = "⇧⌃⌘"
empty_table = {}
windowCornerRadius = 10

--# images
local images = require("images")
local windowAction = require("windowAction")
windowAction.new(super, hs.keycodes.map["s"], "swap",  images.swap) --["y"]
windowAction.new(super, hs.keycodes.map["w"], "warp",  images.warp) --["n"]
windowAction.new(super, hs.keycodes.map["x"], "stack", images.stack) --["h"]

--# canvas elements
local canvases = {
    winFocusRect = hs.canvas.new({ x = 0, y = 0, w = 100, h = 100 }),
}

local focus_ = {
    --hideTimer = nil
}

function delayed(fn, delay)
    return hs.timer.delayed.new(delay, fn):start()
end

toasts = {
    main = nil
}
function killToast(params)
    params = params or empty_table
    local name = params.name or "main"
    if toasts[name] ~= nil then
        hs.alert.closeSpecific(toasts[name], params.fadeOutDuration or 0.1)
        toasts[name] = nil
    end
end
function toast(str, time, params)
    killToast(params)
    params = params or empty_table
    local name = params.name or "main"
    toasts[name] = hs.alert(str, {
        fillColor = { white = 0, alpha = 0.4 },
        strokeColor = { white = 0, alpha = 0 },
        strokeWidth = 0,
        textColor = { white = 1, alpha = 1 },
        radius = 0,
        padding = 6,
        atScreenEdge = 0,
        fadeInDuration = 0.1,
        fadeOutDuration = params.fadeOutDuration or 0.1
    }, time or 0.6)
end

function reloadYabai()
    hs.execute('/bin/launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"')
end

--# Stackline
stackline = require "stackline"
stackline:init()

--# Main chooser
local mainChooser = hs.chooser.new(function(option)
    if option ~= nil then
        if option.action == "reload" then
            hs.reload()
        elseif option.action == "reload_yabai" then
            reloadYabai()
        elseif option.action == "toggle_gap" then
            yabai({"-m", "space", "--toggle", "padding"}, function() yabai({"-m", "space", "--toggle", "gap"}) end)
        end
    end
end):choices({
{
    text = "Toggle Gap",
    subText = "Toggles padding and gaps around the current space",
    action = "toggle_gap",
},
{
    text = "Reload Yabai",
    subText = "Reload Yabai daemon",
    action = "reload_yabai",
},
{
    text = "Reload",
    subText = "Reload Hammerspoon configuration",
    action = "reload",
},
})

--# bindings

--# reload config
hs.hotkey.bind(super, hs.keycodes.map["return"], nil, function() hs.reload() end)
--# open main chooser
hs.hotkey.bind(shift_super, hs.keycodes.map["space"], nil, function() mainChooser:show() end)


--# set layout under mouse
hs.hotkey.bind(super, hs.keycodes.map["7"], nil, function() yabai({"-m", "space", "mouse", "--layout", "bsp"}, function() toast("🖖") end) end) --["1"]
hs.hotkey.bind(super, hs.keycodes.map["8"], nil, function() yabai({"-m", "space", "mouse", "--layout", "stack"}, function() toast("📚") end) end) --["2"]
hs.hotkey.bind(super, hs.keycodes.map["9"], nil, function() yabai({"-m", "space", "mouse", "--layout", "float"}, function() toast("☁️") end) end) --["3"]

--# rotate space
hs.hotkey.bind(super, hs.keycodes.map["."], nil, function() yabai({"-m", "space", "--rotate", "270"}, function() toast("🔲🔁") end) end) --["."]

--# focus fullscreen
hs.hotkey.bind(super, hs.keycodes.map["m"], nil, function() yabai({"-m", "window", "--toggle", "zoom-fullscreen"}) end) --["m"]

--# toggle float layout for window
hs.hotkey.bind(super, hs.keycodes.map["f"], nil, function() yabai({"-m", "window", "--toggle", "float"}, function() toast("🎚 ☁️") end) end) --["/"]

--# change window stack focus
local stack_overflow = {
    next = "first",
    prev = "last",
}
function navigate_stack(direction)
    yabai({"-m", "window", "--focus", "stack."..direction}, function(out,err)
        if err ~= nil and err ~= '' then
            yabai({"-m", "window", "--focus", "stack."..stack_overflow[direction]})
        end
    end)
end
hs.hotkey.bind(shift_super, hs.keycodes.map["t"], function() navigate_stack("prev") end)  --["t"]
hs.hotkey.bind(shift_super, hs.keycodes.map["g"], function() navigate_stack("next") end)  --["g"]

--# change spaces
function gotoSpace(number)
    hs.spaces.gotoSpace(hs.spaces.spacesForScreen(hs.screen.mainScreen())[number])
end
hs.hotkey.bind(super, hs.keycodes.map["1"], function() gotoSpace(1) end)
hs.hotkey.bind(super, hs.keycodes.map["2"], function() gotoSpace(2) end)
hs.hotkey.bind(super, hs.keycodes.map["3"], function() gotoSpace(3) end)
hs.hotkey.bind(super, hs.keycodes.map["4"], function() gotoSpace(4) end)

--# change window focus to direction
function focus(direction)
    yabai({"-m", "window", "--focus", direction}, function(out,err)
        -- print("stdout:>"..out.."<stderr:>"..err.."<")
        if err ~= nil and err ~= '' then
            yabai({"-m", "display", "--focus", direction})
        end
    end)
end
hs.hotkey.bind(super, hs.keycodes.map["l"], function() focus("east") end)  --[";"]
hs.hotkey.bind(super, hs.keycodes.map["h"], function() focus("west") end)  --[";"]
hs.hotkey.bind(super, hs.keycodes.map["k"], function() focus("north") end)  --[";"]
hs.hotkey.bind(super, hs.keycodes.map["j"], function() focus("south") end)  --[";"]

--# move window to direction
function warp(direction)
    yabai({"-m", "window", "--warp", direction}, function(out,err)
        -- print("stdout:>"..out.."<stderr:>"..err.."<")
        if err ~= nil and err ~= '' then
            yabai({"-m", "window", "--display", direction})
            yabai({"-m", "display", "--focus", direction})
        end
    end)
end
hs.hotkey.bind(shift_super, hs.keycodes.map["l"], function() warp("east") end)  --[";"]
hs.hotkey.bind(shift_super, hs.keycodes.map["h"], function() warp("west") end)  --["j"]
hs.hotkey.bind(shift_super, hs.keycodes.map["k"], function() warp("north") end)  --["l"]
hs.hotkey.bind(shift_super, hs.keycodes.map["j"], function() warp("south") end)  --["k"]

--# move window to space
function moveToSpace(number)
    yabai({"-m", "query", "--displays", "--display"},
    function(out)
        local display = hs.json.decode(out)
        print(hs.inspect(display))
        -- yabai({"-m", "window", "--space", number+4*(display.index -1)})
        yabai({"-m", "window", "--space", tostring(number+4*(display.index-1))})
    end
    )
end
hs.hotkey.bind(shift_super, hs.keycodes.map["1"], function() moveToSpace(1) end)
hs.hotkey.bind(shift_super, hs.keycodes.map["2"], function() moveToSpace(2) end)
hs.hotkey.bind(shift_super, hs.keycodes.map["3"], function() moveToSpace(3) end)
hs.hotkey.bind(shift_super, hs.keycodes.map["4"], function() moveToSpace(4) end)

--# bsp ratio
hs.hotkey.bind(super, hs.keycodes.map["z"], function() yabai({"-m", "window", "--ratio", "abs:0.38"}) toast("🔲⅓") end)  --["7"]
hs.hotkey.bind(super, hs.keycodes.map["u"], function() yabai({"-m", "window", "--ratio", "abs:0.5"}) toast("🔲½") end)  --["8"]
hs.hotkey.bind(super, hs.keycodes.map["i"], function() yabai({"-m", "window", "--ratio", "abs:0.62"}) toast("🔲⅔") end)  --["9"]
hs.hotkey.bind(super, hs.keycodes.map["0"], function() yabai({"-m", "space", "--balance"}) toast("🔲⚖️") end)  --["-"]


--# modals
local focus_display_mod = hs.hotkey.modal.new(super, hs.keycodes.map["f"])  --["v"]
local insert_window_modal = hs.hotkey.modal.new(super, hs.keycodes.map["tab"])
local move_display_modal = hs.hotkey.modal.new(super, hs.keycodes.map["v"])  --["b"]
local resize_window_modal = hs.hotkey.modal.new()

--# focus display
function focus_display_mod:entered()
    toast("🖥🧭", true, { name = "modal" })
end
function focus_display_mod:exited()
    killToast({ name = "modal" })
end
focus_display_mod:bind("", hs.keycodes.map["escape"], function() focus_display_mod:exit() end)
focus_display_mod:bind(super, hs.keycodes.map["n"], function() yabai({"-m", "display", "--focus", "next"}, function() delayed(function() toast("🖥➡️") end, 0.1) end) focus_display_mod:exit() end)  --[";"]
focus_display_mod:bind(super, hs.keycodes.map["t"], function() yabai({"-m", "display", "--focus", "prev"}, function() delayed(function() toast("🖥⬅️") end, 0.1) end) focus_display_mod:exit() end)  --["j"]


--# insert window rule
--# insert window rule functions
function insert_window_modal:entered()
    toast("🔲🌱 ", true, { name = "modal" })
end
function insert_window_modal:exited()
    killToast({ name = "modal" })
end
insert_window_modal:bind("", hs.keycodes.map["escape"], function() insert_window_modal:exit() end)
insert_window_modal:bind(super, hs.keycodes.map["l"], function() yabai({"-m", "window", "--insert", "east"}) end)  --[";"]
insert_window_modal:bind(super, hs.keycodes.map["h"], function() yabai({"-m", "window", "--insert", "west"}) end)  --["j"]
insert_window_modal:bind(super, hs.keycodes.map["k"], function() yabai({"-m", "window", "--insert", "north"}) end)  --["l"]
insert_window_modal:bind(super, hs.keycodes.map["j"], function() yabai({"-m", "window", "--insert", "south"}) end)  --["k"]
insert_window_modal:bind(super, hs.keycodes.map["s"], function() yabai({"-m", "window", "--insert", "stack"}) end)  --["h"]
insert_window_modal:bind(super, hs.keycodes.map["tab"], function() insert_window_modal:exit() resize_window_modal:enter() end)


--# send window to display
local move_display_ = {
    selected = nil
}
function move_display_modal:entered()
    yabai({"-m", "query", "--windows", "--window"},
    function(out)
        local window = hs.json.decode(out)
        if (window ~= nil) then
            --print(hs.inspect(hs.json.decode(out)))
            move_display_.selected = window
            toast("🔲🖥", true, { name = "move_display" })
        end
    end
    )
end
function move_display_modal:exited()
    move_display_.selected = nil
    killToast({ name = "move_display" })
end
move_display_modal:bind(super, hs.keycodes.map["n"],  --[";"]
function()
    if (move_display_.selected ~= nil) then
        yabai({"-m", "window", "--display", "next"},
        function()
            move_display_modal:exit()
        end
        )
    end
end
)
move_display_modal:bind(super, hs.keycodes.map["t"],  --["j"]
function()
    if (move_display_.selected ~= nil) then
        yabai({"-m", "window", "--display", "prev"},
        function()
            move_display_modal:exit()
        end
        )
    end
end
)
move_display_modal:bind("", hs.keycodes.map["escape"], function() move_display_modal:exit() end)


--# resize window
local resize_window = {
    size = 40,
    horizontalEdge = nil, -- 1 is for right, -1 is for left
    verticalEdge = nil -- 1 is for bottom, -1 is for top
}
function resize_window_modal:entered()
    toast("🔲↔️", true, { name = "resize_window" })
end
function resize_window_modal:exited()
    resize_window.horizontalEdge = nil
    resize_window.verticalEdge = nil
    killToast({ name = "resize_window" })
end
resize_window_modal:bind(super, hs.keycodes.map["n"], function()  --[";"]
    if resize_window.horizontalEdge == nil then
        resize_window.horizontalEdge = 1
    end
    if resize_window.horizontalEdge == 1 then
        -- grow from right
        print("grow from right")
        yabai({"-m", "window", "--resize", "right:"..resize_window.size..":0"}, function(out, err) print(out, err) end)
    else
        -- shrink from left
        print("shrink from left")
        yabai({"-m", "window", "--resize", "left:"..resize_window.size..":0"}, function(out, err) print(out, err) end)
    end
end)
resize_window_modal:bind(super, hs.keycodes.map["t"], function()  --["j"]
    if resize_window.horizontalEdge == nil then
        resize_window.horizontalEdge = -1
    end
    if resize_window.horizontalEdge == 1 then
        -- shrink from right
        print("shrink from right")
        yabai({"-m", "window", "--resize", "right:-"..resize_window.size..":0"}, function(out, err) print(out, err) end)
    else
        -- grow from left
        print("grow from left")
        yabai({"-m", "window", "--resize", "left:-"..resize_window.size..":0"}, function(out, err) print(out, err) end)
    end
end)
resize_window_modal:bind(super, hs.keycodes.map["s"], function()  --["k"]
    if resize_window.verticalEdge == nil then
        resize_window.verticalEdge = 1
    end
    if resize_window.verticalEdge == 1 then
        -- grow from bottom
        print("grow from bottom")
        yabai({"-m", "window", "--resize", "bottom:0:"..resize_window.size}, function(out, err) print(out, err) end)
    else
        -- shrink from top
        print("shrink from top")
        yabai({"-m", "window", "--resize", "top:0:"..resize_window.size}, function(out, err) print(out, err) end)
    end
end)
resize_window_modal:bind(super, hs.keycodes.map["r"], function()  --["l"]
    if resize_window.verticalEdge == nil then
        resize_window.verticalEdge = -1
    end
    if resize_window.verticalEdge == 1 then
        -- shrink from bottom
        print("shrink from bottom")
        yabai({"-m", "window", "--resize", "bottom:0:-"..resize_window.size}, function(out, err) print(out, err) end)
    else
        -- grow from top
        print("grow from top")
        yabai({"-m", "window", "--resize", "top:0:-"..resize_window.size}, function(out, err) print(out, err) end)
    end
end)
resize_window_modal:bind("", hs.keycodes.map["escape"], function() resize_window_modal:exit() end)


--# window focus listener
currentFocus = nil
function onWindowFocusChanged(window_id)
    getFocusedWindow(function(win)
        if win ~= nil then
            if currentFocus == nil or currentFocus.id ~= win.id then
                currentFocus = win
                --deleteBorder()
                --createBorder(win)
            end
        else
            currentFocus = nil
            deleteBorder()
        end
    end)
end

function onWindowResized(window_id)
    if currentFocus ~= nil and currentFocus.id == window_id then
        getWindow(currentFocus.id,
        function(win)
            --deleteBorder()
            --createBorder(win)
        end
        )
    end
end

function onWindowMoved(window_id)
    if currentFocus ~= nil and currentFocus.id == window_id then
        getWindow(currentFocus.id,
        function(win)
            --deleteBorder()
            --createBorder(win)
        end
        )
    end
end

function onWindowDestroyed(window_id)
    if currentFocus ~= nil and currentFocus.id == window_id then
        deleteBorder()
    end
end

function createBorder(win)
    if win == nil or canvases.winFocusRect == nil then
        return
    end
    canvases.winFocusRect:topLeft({ x = win.frame.x - 2, y = win.frame.y - 2 })
    canvases.winFocusRect:size({ w = win.frame.w + 4, h = win.frame.h + 4 })
    local borderColor = { red = 0.8, green = 0.8, blue = 0.2 , alpha = 0.6 }
    local zoomed = win["zoom-fullscreen"] == 1
    if zoomed then
        borderColor = { red = 0.8, green = 0.2, blue = 0.2 , alpha = 0.6 }
    end
    canvases.winFocusRect:replaceElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = borderColor,
        strokeWidth = 4,
        --strokeDashPattern = { 60, 40 },
        roundedRectRadii = { xRadius = windowCornerRadius, yRadius = windowCornerRadius },
        padding = 2
    })
    canvases.winFocusRect:show()
end

function deleteBorder(fadeTime)
    canvases.winFocusRect:hide()
end

--# query
function getFocusedWindow(callback)
    yabai({"-m", "query", "--windows"},
    function(out, err)
        if out == nil or type(out) ~= "string" or string.len(out) == 0 then
            callback(nil)
        else
            out = string.gsub(out, ":inf,", ":0.0,")
            local json = "{\"windows\":"..out.."}"
            --print(json)
            local json_obj = hs.json.decode(json)
            if json_obj ~= nil then
                local windows = json_obj.windows
                for i, win in ipairs(windows) do
                    if win.focused == 1 then
                        callback(win)
                        return
                    end
                end
                callback(nil)
            else
                getFocusedWindow(callback)
            end
        end
    end
    )
end

function getWindow(window_id, callback)
    yabai({"-m", "query", "--windows", "--window", tostring(window_id)},
    function(out, err)
        if out == nil or string.len(out) == 0 then
            callback(nil)
        else
            --print("json|"..out.."|len"..string.len(out))
            local win = hs.json.decode(out)
            callback(win)
        end
    end
    )
end

--# install cli
hs.ipc.cliInstall()

-- calls made by yabai frow cli, see .yabairc
yabaidirectcall = {
    window_focused = function(window_id) -- called when another window from the current app is focused
        onWindowFocusChanged(window_id)
    end,
    application_activated = function(process_id) -- called when a window from a different app is focused. Doesn’t exclude a window_focused call.
        onWindowFocusChanged(window_id)
    end,
    window_resized = function(window_id) -- called when a window changes dimensions
        onWindowResized(window_id)
    end,
    window_moved = function(window_id) -- called when a window is moved
        onWindowMoved(window_id)
    end,
    window_destroyed = function(window_id) -- called when a window is destroyed
        onWindowDestroyed(window_id)
    end
}

onWindowFocusChanged(nil) -- show borders of focused window at startup

hs.loadSpoon('SpoonInstall')
Install=spoon.SpoonInstall

local hyper = {'ctrl', 'alt', 'cmd'}
local shift_hyper = {'shift', 'ctrl', 'alt', 'cmd'}
hs.window.animationDuration = 0.0
hs.application.enableSpotlightForNameSearches(false)

hs.hotkey.bind({'ctrl','cmd'}, 'q', function() hs.caffeinate.startScreensaver() end )

hs.hotkey.bind({'ctrl','cmd'},'t', function()
    term=hs.application.find('iTerm2') or hs.application.open('iTerm')
    term:selectMenuItem('New Window')
end)

hs.hotkey.bind(shift_hyper, 'n', function() hs.eventtap.keyStroke({}, 71) end)

-- Register my custom repository
Install.repos["apoSpoons"] = {
  desc   = "apoxa's repository",
  url    = "https://github.com/apoxa/apoSpoons",
  branch = 'main'
}

Install:andUse('MacroPad',
    {
        repo = "apoSpoons",
        hotkeys = {
            raiseHand = {hyper, "F11"},
            toggleMute = {hyper, "F12"},
        },
        start = true,
    }
)

function appID(app)
    infoBundle = hs.application.infoForBundlePath(app)
    if infoBundle ~= nil then
        return infoBundle['CFBundleIdentifier']
    end
end

chromeBrowser = appID('/Applications/Google Chrome.app')
edgeBrowser = appID('/Applications/Microsoft Edge.app')
teamsApp = appID('/Applications/Microsoft Teams.app')

DefaultBrowser = chromeBrowser

Install:andUse("URLDispatcher",
    {
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
    }
)

-- global config
config = {
    networks = {
        ['wlan@somewhere'] = 'levigo',
        ['DWMC3'] = 'DWMC3'
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

-- axbrowse
-- b = hs.axuielement.systemElementAtPosition(hs.mouse.absolutePosition())
-- hs.inspect(b:attributeNames())
-- hs.inspect(b:actionNames())
-- hs.inspect(b:parameterizedAttributeNames())
-- b:attributeValue("AXRoleDescription")
