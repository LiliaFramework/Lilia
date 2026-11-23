local function isSitAnywhereCallback(callback)
    if not isfunction(callback) or not debug or not debug.getinfo then return false end
    local info = debug.getinfo(callback, "S")
    if not info or not isstring(info.source) then return false end
    local source = string.lower(info.source:gsub("\\", "/"))
    return source:find("sitanywhere/client/", 1, true) ~= nil or source:find("sitanywhere/server/", 1, true) ~= nil or source:find("sitanywhere/ground_sit.lua", 1, true) ~= nil or source:find("sitanywhere/helpers.lua", 1, true) ~= nil
end

local function removeSitAnywhereHooks()
    for event, callbacks in pairs(hook.GetTable()) do
        for identifier, callback in pairs(callbacks) do
            if isSitAnywhereCallback(callback) then hook.Remove(event, identifier) end
        end
    end
end

local function removeSitAnywhereCommands()
    for name, callback in pairs(concommand.GetTable()) do
        if isSitAnywhereCallback(callback) then concommand.Remove(name) end
    end
end

local function removeSitAnywhereMethod(meta, name)
    if not meta then return end
    local callback = meta[name]
    if isSitAnywhereCallback(callback) then meta[name] = nil end
end

local function cleanupSitAnywhereState()
    if not SERVER then return end
    timer.Remove("SitAny_RemoveSeats")
    if net and net.Receivers then
        local receiver = net.Receivers.sitanywhere
        if isSitAnywhereCallback(receiver) then net.Receivers.sitanywhere = nil end
    end

    for _, client in player.Iterator() do
        client:SetNWBool("SitAnyG_", false)
    end

    for _, entity in ipairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
        if entity.playerdynseat or entity:GetNWBool("playerdynseat", false) then
            local driver = entity:GetDriver()
            if IsValid(driver) then driver:ExitVehicle() end
            local parent = entity:GetParent()
            if IsValid(parent) and parent:GetClass() == "sit_holder" then SafeRemoveEntity(parent) end
            SafeRemoveEntity(entity)
        end
    end
end

local function disableSitAnywhere()
    removeSitAnywhereHooks()
    removeSitAnywhereCommands()
    removeSitAnywhereMethod(FindMetaTable("Player"), "Sit")
    removeSitAnywhereMethod(FindMetaTable("Player"), "GetSitting")
    removeSitAnywhereMethod(FindMetaTable("Player"), "ExitSit")
    removeSitAnywhereMethod(FindMetaTable("Entity"), "IsSitAnywhereSeat")
    SitAnywhere.GroundSit = false
    cleanupSitAnywhereState()
end

disableSitAnywhere()
timer.Simple(0, disableSitAnywhere)
hook.Add("InitPostEntity", "liaDisableSitAnywhere", disableSitAnywhere)
hook.Add("InitializedModules", "liaDisableSitAnywhere", disableSitAnywhere)
hook.Add("OnReloaded", "liaDisableSitAnywhere", function() timer.Simple(0, disableSitAnywhere) end)