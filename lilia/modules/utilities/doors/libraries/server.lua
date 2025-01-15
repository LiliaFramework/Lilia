local Variables = {
    ["disabled"] = true,
    ["name"] = true,
    ["price"] = true,
    ["noSell"] = true,
    ["faction"] = true,
    ["factions"] = true,
    ["class"] = true,
    ["hidden"] = true,
    ["locked"] = true,
}

local DarkRPVariables = {
    ["DarkRPNonOwnable"] = function(entity) entity:setNetVar("noSell", true) end,
    ["DarkRPTitle"] = function(entity, val) entity:setNetVar("name", val) end,
    ["DarkRPCanLockpick"] = function(entity, val) entity.noPick = tobool(val) end
}

function MODULE:EntityKeyValue(entity, key, value)
    if entity:isDoor() and DarkRPVariables[key] then DarkRPVariables[key](entity, value) end
end

function MODULE:copyParentDoor(child)
    local parent = child.liaParent
    if IsValid(parent) then
        for var in pairs(Variables) do
            local parentValue = parent:getNetVar(var)
            if child:getNetVar(var) ~= parentValue then child:setNetVar(var, parentValue) end
        end
    end
end

function MODULE:PostLoadData()
    if self.DoorsAlwaysDisabled then
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                door:setNetVar("disabled", true)
                self:callOnDoorChildren(door, function(child) child:setNetVar("disabled", true) end)
                count = count + 1
            end
        end

        LiliaInformation(count .. " doors have been disabled as per DoorsAlwaysDisabled setting.")
    end
end

function MODULE:LoadData()
    local data = self:getData()
    if not data then return end
    for k, v in pairs(data) do
        local entity = ents.GetMapCreatedEntity(k)
        if IsValid(entity) and entity:isDoor() then
            for k2, v2 in pairs(v) do
                if k2 == "children" then
                    entity.liaChildren = v2
                    for index, _ in pairs(v2) do
                        local door = ents.GetMapCreatedEntity(index)
                        if IsValid(door) then door.liaParent = entity end
                    end
                else
                    entity:setNetVar(k2, v2)
                end
            end
        end
    end
end

function MODULE:SaveData()
    local data = {}
    local doors = {}
    for _, ent in ents.Iterator() do
        if ent:isDoor() then doors[ent:MapCreationID()] = ent end
    end

    for id, door in pairs(doors) do
        local doorData = {}
        for var in pairs(Variables) do
            local value = door:getNetVar(var)
            if value then doorData[var] = value end
        end

        if door.liaChildren then doorData.children = door.liaChildren end
        if door.liaClassID then doorData.class = door.liaClassID end
        if door.liaFactionID then doorData.faction = door.liaFactionID end
        if next(doorData) then data[id] = doorData end
    end

    self:setData(data)
    LiliaInformation("Amount of doors saved: " .. table.Count(data))
end

function MODULE:callOnDoorChildren(entity, callback)
    local parent
    if entity.liaChildren then
        parent = entity
    elseif entity.liaParent then
        parent = entity.liaParent
    end

    if IsValid(parent) then
        callback(parent)
        for k, _ in pairs(parent.liaChildren) do
            local child = ents.GetMapCreatedEntity(k)
            if IsValid(child) then callback(child) end
        end
    end
end

function MODULE:InitPostEntity()
    local doors = ents.FindByClass("prop_door_rotating")
    for _, v in ipairs(doors) do
        local parent = v:GetOwner()
        if IsValid(parent) then
            v.liaPartner = parent
            parent.liaPartner = v
        else
            for _, v2 in ipairs(doors) do
                if v2:GetOwner() == v then
                    v2.liaPartner = v
                    v.liaPartner = v2
                    break
                end
            end
        end
    end
end

function MODULE:PlayerUse(client, door)
    if door:IsVehicle() and door:isLocked() then return false end
    if door:isDoor() then
        local result = hook.Run("CanPlayerUseDoor", client, door)
        if result == false then
            return false
        else
            result = hook.Run("PlayerUseDoor", client, door)
            if result ~= nil then return result end
        end
    end
end

function MODULE:CanPlayerUseDoor(_, door)
    if door:getNetVar("disabled", false) then return false end
end

function MODULE:CanPlayerAccessDoor(client, door)
    local factions = door:getNetVar("factions")
    if factions ~= nil then
        local facs = util.JSONToTable(factions)
        if facs ~= nil and facs ~= "[]" and facs[client:Team()] then return true end
    end

    local class = door:getNetVar("class")
    local classData = lia.class.list[class]
    local charClass = client:getChar():getClass()
    local classData2 = lia.class.list[charClass]
    if class and classData and classData2 then
        if classData.team then
            if classData.team ~= classData2.team then return false end
        else
            if charClass ~= class then return false end
        end
        return true
    end
end

function MODULE:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function MODULE:ShowTeam(client)
    local entity = client:getTracedEntity()
    if IsValid(entity) and entity:isDoor() and not entity:getNetVar("faction") and not entity:getNetVar("class") then
        if entity:checkDoorAccess(client, DOOR_TENANT) then
            local door = entity
            if IsValid(door.liaParent) then door = door.liaParent end
            netstream.Start(client, "doorMenu", door, door.liaAccess, entity)
        elseif not IsValid(entity:GetDTEntity(0)) then
            lia.command.run(client, "doorbuy")
        else
            client:notifyLocalized("notAllowed")
        end
        return true
    end
end

function MODULE:PlayerDisconnected(client)
    for _, v in ents.Iterator() do
        if v ~= client and v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then v:removeDoorAccessData() end
    end
end

function MODULE:KeyLock(client, door, time)
    local distance = client:GetPos():Distance(door:GetPos())
    if not door:isLocked() and IsValid(door) and distance <= 256 and (door:isDoor() and door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty() and (door:IsVehicle() or door:isSimfphysCar())) then
        client:setAction("@locking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, true) end, time, function() client:stopAction() end)
        lia.log.add(client, "lockDoor", door)
    end
end

function MODULE:KeyUnlock(client, door, time)
    local distance = client:GetPos():Distance(door:GetPos())
    if door:isLocked() and IsValid(door) and distance <= 256 and (door:isDoor() and door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty() and (door:IsVehicle() or door:isSimfphysCar())) then
        client:setAction("@unlocking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, false) end, time, function() client:stopAction() end)
        lia.log.add(client, "unlockDoor", door)
    end
end

function MODULE:ToggleLock(client, door, state)
    if not IsValid(door) then return end
    if door:isDoor() then
        local partner = door:getDoorPartner()
        if state then
            if IsValid(partner) then partner:Fire("lock") end
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
        else
            if IsValid(partner) then partner:Fire("unlock") end
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
        end

        door:setLocked(state)
    elseif (door:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty()) and (door:IsVehicle() or door:isSimfphysCar()) then
        if state then
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
        end

        door:setLocked(state)
    end

    lia.log.add(client, "toggleLock", door, state and "locked" or "unlocked")
end

lia.log.addType("doorSetClass", function(client, door, className) return string.format("[%s] %s set class '%s' to %s.", client:SteamID(), client:Name(), className, door:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorRemoveClass", function(client, door) return string.format("[%s] %s removed class from %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorSaveData", function(client) return string.format("[%s] %s saved all door data.", client:SteamID(), client:Name()) end, "Doors", Color(0, 255, 0))
lia.log.addType("doorToggleOwnable", function(client, door, state) return string.format("[%s] %s toggled the ownable state of %s to %s.", client:SteamID(), client:Name(), door:GetClass(), state and "unownable" or "ownable") end, "Doors", Color(52, 152, 219))
lia.log.addType("doorSetFaction", function(client, door, factionName) return string.format("[%s] %s assigned faction '%s' to %s.", client:SteamID(), client:Name(), factionName, door:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorRemoveFaction", function(client, door, factionName) return string.format("[%s] %s removed faction '%s' from %s.", client:SteamID(), client:Name(), factionName, door:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorSetHidden", function(client, door, state) return string.format("[%s] %s set %s to %s.", client:SteamID(), client:Name(), door:GetClass(), state and "hidden" or "visible") end, "Doors", Color(52, 152, 219))
lia.log.addType("doorSetTitle", function(client, door, title) return string.format("[%s] %s set title '%s' to %s.", client:SteamID(), client:Name(), title, door:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorResetData", function(client, door) return string.format("[%s] %s reset all data on %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorSetParent", function(client, door) return string.format("[%s] %s set %s as the parent door.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorAddChild", function(client, parentDoor, childDoor) return string.format("[%s] %s added %s as a child to %s.", client:SteamID(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorRemoveChild", function(client, parentDoor, childDoor) return string.format("[%s] %s removed %s as a child from %s.", client:SteamID(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end, "Doors", Color(52, 152, 219))
lia.log.addType("doorForceLock", function(client, door) return string.format("[%s] %s forcibly locked %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorForceUnlock", function(client, door) return string.format("[%s] %s forcibly unlocked %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorDisable", function(client, door) return string.format("[%s] %s disabled %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorEnable", function(client, door) return string.format("[%s] %s enabled %s.", client:SteamID(), client:Name(), door:GetClass()) end, "Doors", Color(0, 255, 0))
lia.log.addType("doorDisableAll", function(client, count) return string.format("[%s] %s disabled all doors (%d total).", client:SteamID(), client:Name(), count) end, "Doors", Color(255, 0, 0))
lia.log.addType("doorEnableAll", function(client, count) return string.format("[%s] %s enabled all doors (%d total).", client:SteamID(), client:Name(), count) end, "Doors", Color(0, 255, 0))