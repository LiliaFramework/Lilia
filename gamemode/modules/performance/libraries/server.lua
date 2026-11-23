local MODULE = MODULE
local subscribers = setmetatable({}, {__mode = "k"})
local nextRefresh = 0

function MODULE:SendProfilerState(client)
    net.Start("liaPerformanceProfileState")
    net.WriteBool(self.profilingFrozen)
    net.WriteFloat(self.profileRefreshRate)
    net.WriteBool(self.profilingStarted)
    net.WriteBool(self.profilingCollecting)
    net.Send(client)
end

function MODULE:SyncProfilerState()
    for client in pairs(subscribers) do
        if self:CanViewMetrics(client) then
            self:SendProfilerState(client)
        else
            subscribers[client] = nil
        end
    end
end

function MODULE:SetProfilerSetting(name, value)
    if name == "freeze" then
        self.profilingFrozen = value == true
    elseif name == "refresh" then
        if not isnumber(value) or value ~= value or value == math.huge or value == -math.huge then return end
        self.profileRefreshRate = math.Clamp(value, 0.1, 5)
    else
        return
    end
    self:SyncProfilerState()
end

function MODULE:SendProfilerMetrics()
    local metrics = {}
    for source, data in pairs(self:GetReadableMetrics()) do
        metrics[#metrics + 1] = {source = source, data = data}
    end
    table.sort(metrics, function(a, b) return a.data.time > b.data.time end)
    for client in pairs(subscribers) do
        if not self:CanViewMetrics(client) then
            subscribers[client] = nil
        else
            for i = 1, math.min(#metrics, 128) do
                local entry = metrics[i]
                local data = entry.data
                local callbacks = {}
                for name, elapsed in pairs(data.funcs) do
                    callbacks[#callbacks + 1] = {name = name, elapsed = elapsed, calls = (data.counts or {})[name] or 0}
                end
                table.sort(callbacks, function(a, b) return a.elapsed > b.elapsed end)
                net.Start("liaPerformanceProfileMetric")
                net.WriteString(entry.source)
                net.WriteFloat(data.time)
                net.WriteUInt(math.min(data.calls or 0, 4294967295), 32)
                net.WriteUInt(math.min(#callbacks, 10), 4)
                for j = 1, math.min(#callbacks, 10) do
                    local callback = callbacks[j]
                    net.WriteString(callback.name)
                    net.WriteFloat(callback.elapsed)
                    net.WriteUInt(math.min(callback.calls, 4294967295), 32)
                end
                net.Send(client)
            end
        end
    end
end

function MODULE:Think()
    if not self.profilingCollecting or self.profilingFrozen then return end
    if nextRefresh > CurTime() then return end
    self:SendProfilerMetrics()
    table.Empty(self.profileMetrics)
    table.Empty(self.profileCounts)
    nextRefresh = CurTime() + math.Clamp(self.profileRefreshRate, 0.1, 5)
end

function MODULE:HandleProfilingStart(client)
    if not self:CanViewMetrics(client) then return end
    if net.ReadBool() then
        self:StartProfiling()
    else
        self:PauseProfiling()
    end
    self:SyncProfilerState()
end

function MODULE:HandleProfilerClear(client)
    if not self:CanViewMetrics(client) then return end
    self:ClearProfileMetrics()
    for subscriber in pairs(subscribers) do
        if self:CanViewMetrics(subscriber) then
            net.Start("liaPerformanceProfileClear")
            net.Send(subscriber)
        else
            subscribers[subscriber] = nil
        end
    end
    if not subscribers[client] then
        net.Start("liaPerformanceProfileClear")
        net.Send(client)
    end
end

function MODULE:HandleProfilerSettings(client)
    if not self:CanViewMetrics(client) then return end
    local setting = net.ReadString()
    if setting == "freeze" then
        self:SetProfilerSetting(setting, net.ReadBool())
    elseif setting == "refresh" then
        self:SetProfilerSetting(setting, net.ReadFloat())
    end
end

function MODULE:HandleProfilerSubscription(client)
    if not self:CanViewMetrics(client) then return end
    if net.ReadBool() then
        subscribers[client] = true
        self:SendProfilerState(client)
    else
        subscribers[client] = nil
    end
end

net.Receive("liaPerformanceProfileStart", function(_, client) MODULE:HandleProfilingStart(client) end)
net.Receive("liaPerformanceProfileClear", function(_, client) MODULE:HandleProfilerClear(client) end)
net.Receive("liaPerformanceProfileSettings", function(_, client) MODULE:HandleProfilerSettings(client) end)
net.Receive("liaPerformanceProfileSubscription", function(_, client) MODULE:HandleProfilerSubscription(client) end)
