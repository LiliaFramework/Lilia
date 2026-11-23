local MODULE = MODULE
local GM = GM or GAMEMODE
MODULE.profileMetrics = MODULE.profileMetrics or {}
MODULE.profileCounts = MODULE.profileCounts or {}
MODULE.profiledHooks = MODULE.profiledHooks or {}
MODULE.profiledEntityMethods = MODULE.profiledEntityMethods or setmetatable({}, {__mode = "k"})
MODULE.originalProfileFunctions = MODULE.originalProfileFunctions or {}
MODULE.profilingStarted = MODULE.profilingStarted or false
if MODULE.profilingCollecting == nil then MODULE.profilingCollecting = MODULE.profilingStarted end
MODULE.profileRefreshRate = MODULE.profileRefreshRate or 2
MODULE.profilingFrozen = MODULE.profilingFrozen or false

local function pack(...)
    return {n = select("#", ...), ...}
end

local function normalizeSource(source)
    return tostring(source or "unknown"):gsub("\\", "/")
end

function MODULE:IsOwnSource(source)
    return normalizeSource(source):lower():find("/modules/performance/", 1, true) ~= nil
end

function MODULE:GetSource(func)
    if not isfunction(func) then return "unknown" end
    local info = debug.getinfo(func, "S")
    return info and normalizeSource(info.short_src) or "unknown"
end

function MODULE:CanViewMetrics(client)
    return IsValid(client) and isfunction(client.hasPrivilege) and client:hasPrivilege("viewPerformanceMetrics") or false
end

function MODULE:TakeMeasurement(elapsed, name, source)
    if not self.profilingCollecting or not isnumber(elapsed) or elapsed < 0 then return end
    source = normalizeSource(source)
    if self:IsOwnSource(source) then return end
    local sourceMetrics = self.profileMetrics[source]
    if not sourceMetrics then
        sourceMetrics = {}
        self.profileMetrics[source] = sourceMetrics
    end

    sourceMetrics[name] = (sourceMetrics[name] or 0) + elapsed
    local counts = self.profileCounts[source]
    if not counts then
        counts = {}
        self.profileCounts[source] = counts
    end
    counts[name] = (counts[name] or 0) + 1
end

function MODULE:MakeToolTipString(funcs, limit)
    local metrics = {}
    for name, elapsed in pairs(funcs or {}) do
        if elapsed > 0 then metrics[#metrics + 1] = {name = name, time = elapsed} end
    end

    table.sort(metrics, function(a, b) return a.time > b.time end)
    local lines = {}
    local maxLines = math.max(1, tonumber(limit) or #metrics)
    for i = 1, math.min(#metrics, maxLines) do
        local data = metrics[i]
        lines[#lines + 1] = string.format("%s ~ %.4fms", data.name, data.time * 1000)
    end
    return table.concat(lines, "\n")
end

function MODULE:GetReadableMetrics()
    local realm = SERVER and 1 or 0
    local readable = {}
    for source, funcs in pairs(self.profileMetrics) do
        local copiedFuncs = {}
        local total = 0
        local calls = 0
        local copiedCounts = {}
        local sourceCounts = self.profileCounts[source] or {}
        for name, elapsed in pairs(funcs) do
            copiedFuncs[name] = elapsed
            total = total + elapsed
            copiedCounts[name] = sourceCounts[name] or 0
            calls = calls + copiedCounts[name]
        end

        readable[source] = {funcs = copiedFuncs, counts = copiedCounts, calls = calls, realm = realm, time = total}
    end
    return readable
end

function MODULE:TimeThisHook(hookType, hookID)
    if hookID == nil then return end
    local hookTable = hook.GetTable()[hookType]
    if not hookTable then return end
    local hookFunc = hookTable[hookID]
    if not isfunction(hookFunc) then return end
    local source = self:GetSource(hookFunc)
    if self:IsOwnSource(source) then return end
    self.profiledHooks[hookType] = self.profiledHooks[hookType] or {}
    local previous = self.profiledHooks[hookType][hookID]
    if previous and hookFunc == previous.wrapper then return end
    local original = hookFunc
    local wrapper = function(...)
        local started = SysTime()
        local results = pack(original(...))
        self:TakeMeasurement(SysTime() - started, "HOOK: " .. tostring(hookType) .. " - " .. tostring(hookID), source)
        return unpack(results, 1, results.n)
    end

    self.profiledHooks[hookType][hookID] = {original = original, wrapper = wrapper}
    local add = self.originalProfileFunctions.hookAdd or hook.Add
    add(hookType, hookID, wrapper)
end

function MODULE:ListenForNewHooks()
    if self.hookProfilerInstalled then return end
    self.originalProfileFunctions.hookAdd = self.originalProfileFunctions.hookAdd or hook.Add
    local original = self.originalProfileFunctions.hookAdd
    hook.Add = function(hookType, hookID, func)
        local result = original(hookType, hookID, func)
        if self.profilingStarted and isfunction(func) then self:TimeThisHook(hookType, hookID) end
        return result
    end

    self.hookProfilerInstalled = true
end

function MODULE:TimeThisEntMethod(ent, methodName)
    if not IsValid(ent) or methodName == nil then return end
    local method = ent[methodName]
    if not isfunction(method) then return end
    local info = debug.getinfo(method, "S")
    if not info or info.what == "C" then return end
    local source = normalizeSource(info.short_src)
    if self:IsOwnSource(source) then return end
    local entityMethods = self.profiledEntityMethods[ent]
    if not entityMethods then
        entityMethods = {}
        self.profiledEntityMethods[ent] = entityMethods
    end

    local previous = entityMethods[methodName]
    if previous and method == previous.wrapper then return end
    local original = method
    local wrapper = function(...)
        local started = SysTime()
        local results = pack(original(...))
        self:TakeMeasurement(SysTime() - started, "METHOD: " .. tostring(methodName), source)
        return unpack(results, 1, results.n)
    end

    entityMethods[methodName] = {original = original, wrapper = wrapper}
    local entTable = ent:GetTable()
    if entTable then entTable[methodName] = wrapper end
end

function MODULE:TimeThisEntity(ent)
    if not IsValid(ent) then return end
    local entTable = ent:GetTable()
    if not entTable then return end
    for methodName, value in pairs(entTable) do
        if isfunction(value) then self:TimeThisEntMethod(ent, methodName) end
    end
end

function MODULE:ListenForNewEntityMethods()
    if self.entityProfilerInstalled then return end
    local entityMeta = FindMetaTable("Entity")
    if not entityMeta or not isfunction(entityMeta.__newindex) then return end
    self.originalProfileFunctions.entityNewIndex = self.originalProfileFunctions.entityNewIndex or entityMeta.__newindex
    local original = self.originalProfileFunctions.entityNewIndex
    entityMeta.__newindex = function(ent, key, value)
        local result = original(ent, key, value)
        if self.profilingStarted and isfunction(value) then
            timer.Simple(0, function() if IsValid(ent) then self:TimeThisEntMethod(ent, key) end end)
        end
        return result
    end

    self.entityProfilerInstalled = true
end

function MODULE:ListenForTimersToTime()
    if self.timerProfilerInstalled then return end
    self.originalProfileFunctions.timerCreate = self.originalProfileFunctions.timerCreate or timer.Create
    local original = self.originalProfileFunctions.timerCreate
    timer.Create = function(identifier, delay, repetitions, func)
        if not self.profilingStarted or not isfunction(func) then return original(identifier, delay, repetitions, func) end
        local source = self:GetSource(func)
        if self:IsOwnSource(source) then return original(identifier, delay, repetitions, func) end
        local wrapped = function(...)
            local started = SysTime()
            local results = pack(func(...))
            self:TakeMeasurement(SysTime() - started, "TIMER: " .. tostring(identifier), source)
            return unpack(results, 1, results.n)
        end
        return original(identifier, delay, repetitions, wrapped)
    end

    self.timerProfilerInstalled = true
end

function MODULE:ClearProfileMetrics()
    table.Empty(self.profileMetrics)
    table.Empty(self.profileCounts)
end

function MODULE:StartProfiling()
    if self.profilingStarted then
        self.profilingCollecting = true
        return true
    end
    self.profileMetrics = {}
    self.profileCounts = {}
    for hookName, entries in pairs(hook.GetTable()) do
        for hookID in pairs(entries) do
            self:TimeThisHook(hookName, hookID)
        end
    end

    self:ListenForNewHooks()
    for _, ent in ipairs(ents.GetAll()) do
        self:TimeThisEntity(ent)
    end

    self:ListenForNewEntityMethods()
    self:ListenForTimersToTime()
    self.profilingStarted = true
    self.profilingCollecting = true
    return true
end

function MODULE:PauseProfiling()
    if not self.profilingStarted then return false end
    self.profilingCollecting = false
    return true
end

function MODULE:OnEntityCreated(ent)
    if not self.profilingStarted then return end
    timer.Simple(0, function() if IsValid(ent) then self:TimeThisEntity(ent) end end)
end

function GM:MouthMoveAnimation(ply)
    if lia.config.get("MouthMoveAnimation", true) then
        local flexes = {ply:GetFlexIDByName("jaw_drop"), ply:GetFlexIDByName("left_part"), ply:GetFlexIDByName("right_part"), ply:GetFlexIDByName("left_mouth_drop"), ply:GetFlexIDByName("right_mouth_drop")}
        local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 2, 0, 2) or 0
        for k, v in ipairs(flexes) do
            ply:SetFlexWeight(v, weight)
        end
    end
    return nil
end

function GM:GrabEarAnimation(ply, plyTable)
    if lia.config.get("GrabEarAnimation", true) then
        if not plyTable then plyTable = ply:GetTable() end
        plyTable.ChatGestureWeight = plyTable.ChatGestureWeight or 0
        if ply:IsPlayingTaunt() then return end
        if ply:IsTyping() then
            plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 1, FrameTime() * 5.0)
        else
            plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 0, FrameTime() * 5.0)
        end

        if plyTable.ChatGestureWeight > 0 then
            ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
            ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, plyTable.ChatGestureWeight)
        end
    end
    return nil
end

function GM:PreGamemodeLoaded()
    widgets.PlayerTick = function() end
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PostDrawEffects", "RenderWidgets")
end

function GM:FindUseEntity(client, ent)
    return ent
end