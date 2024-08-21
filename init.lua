--- === MenuMetrics ===
---
--- A Hammerspoon Spoon to display system metrics in the menu bar
---
--- Download: [https://github.com/username/MenuMetrics.spoon/raw/master/MenuMetrics.spoon.zip](https://github.com/username/MenuMetrics.spoon/raw/master/MenuMetrics.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MenuMetrics"
obj.version = "1.0"
obj.author = "James Turnbull <james@lovedthanlost.net>"
obj.homepage = "https://github.com/username/MenuMetrics.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Icons for the metrics
obj.icons = {
    memory = "🧠",  -- Memory icon
    disk = "📀",    -- Disk icon
    cpu = "⚙️"     -- CPU icon
}

-- Metrics update interval (in seconds)
obj.updateInterval = 5
obj.currentMetric = 1

-- Function to get total memory using a shell command
function obj:getTotalMemoryMB()
    local handle = io.popen("sysctl -n hw.memsize")
    local result = handle:read("*a")
    handle:close()
    
    local totalMemoryBytes = tonumber(result)
    
    if totalMemoryBytes then
        return totalMemoryBytes / (1024 * 1024) -- Convert bytes to MB
    else
        return 8192 -- Fallback to 8GB if detection fails
    end
end

-- Function to get memory usage as a percentage
function obj:getMemoryUsage()
    local memoryInfo = hs.host.vmStat()
    local freeMemoryMB = memoryInfo.pagesFree * 4096 / (1024 * 1024) -- Free memory in MB
    local totalMemoryMB = self:getTotalMemoryMB() -- Get total memory in MB

    -- Ensure memory values are valid
    if freeMemoryMB and totalMemoryMB and totalMemoryMB > 0 then
        local usedMemoryPercent = ((totalMemoryMB - freeMemoryMB) / totalMemoryMB) * 100
        return usedMemoryPercent
    else
        hs.logger.new('MemoryUsage', 'error'):e('Invalid memory values')
        return 0 -- Return 0% if unable to calculate
    end
end

-- Function to get disk usage as a percentage
function obj:getDiskUsage()
    local handle = io.popen("df /System/Volumes/Data | tail -1 | awk '{print $5}'")
    if not handle then
        hs.logger.new('DiskUsage', 'error'):e('Failed to execute disk usage command')
        return 0
    end

    local result = handle:read("*a")
    handle:close()

    local usedDiskPercent = tonumber(result:match("(%d+)"))
    if usedDiskPercent then
        return usedDiskPercent
    else
        hs.logger.new('DiskUsage', 'error'):e('Invalid disk usage value')
        return 0 -- Return 0% if unable to fetch disk info
    end
end

-- Function to get CPU usage as a percentage
function obj:getCpuUsage()
    local cpuInfo = hs.host.cpuUsage()
    if cpuInfo and cpuInfo.overall and cpuInfo.overall.active then
        return cpuInfo.overall.active
    else
        hs.logger.new('CpuUsage', 'error'):e('Invalid CPU usage values')
        return 0 -- Return 0 if unable to fetch CPU usage
    end
end

-- Array of metric functions
obj.metricFunctions = {
    { name = "Memory", icon = obj.icons.memory, getMetric = obj.getMemoryUsage },
    { name = "Disk", icon = obj.icons.disk, getMetric = obj.getDiskUsage },
    { name = "CPU", icon = obj.icons.cpu, getMetric = obj.getCpuUsage }
}

-- Function to update the menu bar
function obj:updateMenu()
    local metric = self.metricFunctions[self.currentMetric]
    
    -- Debugging output
    print("Switching to metric:", metric.name)
    
    local percentage = metric.getMetric(self)
    
    -- Debugging output for percentage
    print(string.format("Current %s usage: %.1f%%", metric.name, percentage))
    
    self.menuMetrics:setTitle(string.format("%s %.1f%%", metric.icon, percentage))

    -- Cycle to the next metric
    self.currentMetric = self.currentMetric + 1
    if self.currentMetric > #self.metricFunctions then
        self.currentMetric = 1
    end
end

-- Start the rotation
function obj:start()
    self.menuMetrics = hs.menubar.new()
    
    if self.menuMetrics then
        -- Set an initial value for the menubar
        self:updateMenu()

        -- Create a timer for rotating the metrics
        self.rotationTimer = hs.timer.doEvery(self.updateInterval, function()
            print("Timer triggered - Updating metric")
            self:updateMenu()
        end)

        -- Ensure the timer is active
        if self.rotationTimer:running() then
            print("Timer is running")
        else
            print("Timer failed to start")
        end
    end
end

function obj:stop()
    if self.rotationTimer then
        self.rotationTimer:stop()
    end
    if self.menuMetrics then
        self.menuMetrics:delete()
    end
end

return obj