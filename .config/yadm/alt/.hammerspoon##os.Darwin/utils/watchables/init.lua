local status = hs.watchable.new('status')
local log    = hs.logger.new('watchables', 'debug')

local cache  = { status = status }
local module = { cache = cache }

local updateBattery = function()
  local burnRate = hs.battery.designCapacity() / math.abs(hs.battery.amperage())

  status.battery = {
    isCharged     = hs.battery.isCharged(),
    percentage    = hs.battery.percentage(),
    powerSource   = hs.battery.powerSource(),
    amperage      = hs.battery.amperage(),
    burnRate      = burnRate,
  }
end

local updateScreen = function()
  status.connectedScreens        = #hs.screen.allScreens()
  status.connectedScreenIds      = hs.fnutils.map(hs.screen.allScreens(), function(screen) return screen:id() end)
  status.isThunderboltConnected  = hs.screen.findByName('Thunderbolt Display') ~= nil
  status.isLaptopScreenConnected = hs.screen.findByName('Color LCD') ~= nil

  log.d('updated screens:', hs.inspect(status.connectedScreenIds))
end

local updateWiFi = function()
  status.currentNetwork = hs.wifi.currentNetwork()

  log.d('updated wifi:', status.currentNetwork)
end

local updateSleep = function(event)
  status.sleepEvent = event

  log.d('updated sleep:', status.sleepEvent)
end

module.start = function()
  -- start watchers
  cache.watchers = {
    battery = hs.battery.watcher.new(updateBattery):start(),
    screen  = hs.screen.watcher.new(updateScreen):start(),
    sleep   = hs.caffeinate.watcher.new(updateSleep):start(),
    wifi    = hs.wifi.watcher.new(updateWiFi):start(),
  }

  -- setup on start
  updateBattery()
  updateScreen()
  updateSleep()
  updateWiFi()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher)
    watcher:stop()
  end)

  cache.configuration:stop()
end

return module
