local log       = hs.logger.new('autonl', 'debug')

local cache     = {}
local module    = { cache = cache }

local wifiWatcher = function(_,_,_,_, currentNetwork)
    if config.networks[currentNetwork] ~= nil then
        hs.execute('/usr/sbin/scselect ' .. config.networks[currentNetwork])
    else
        hs.execute('/usr/sbin/scselect Automatic')
    end
end

-- module
module.start = function()
    cache.watcherWifi = hs.watchable.watch('status.currentNetwork', wifiWatcher)
end

module.stop = function()
    cache.watcherWifi:release()
end

return module
