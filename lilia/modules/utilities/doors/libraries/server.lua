local Variables = {"disabled", "name", "price", "noSell", "faction", "factions", "class", "hidden"}
local DarkRPVariables = {
    ["DarkRPNonOwnable"] = function(entity, _) entity:setNetVar("noSell", true) end,
    ["DarkRPTitle"] = function(entity, val) entity:setNetVar("name", val) end,
    ["DarkRPCanLockpick"] = function(entity, val) entity.noPick = tobool(val) end
}

function MODULE:EntityKeyValue(entity, key, value)
    if entity:isDoor() and DarkRPVariables[key] then DarkRPVariables[key](entity, value) end
end

function MODULE:copyParentDoor(child)
    local parent = child.liaParent
    if IsValid(parent) then
        for _, v in ipairs(Variables) do
            local value = parent:getNetVar(v)
            if child:getNetVar(v) ~= value then child:setNetVar(v, value) end
        end
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
    for _, v in ipairs(ents.GetAll()) do
        if v:isDoor() then doors[v:MapCreationID()] = v end
    end

    local doorData
    for k, v in pairs(doors) do
        doorData = {}
        for _, v2 in ipairs(Variables) do
            local value = v:getNetVar(v2)
            if value then doorData[v2] = v:getNetVar(v2) end
        end

        if v.liaChildren then doorData.children = v.liaChildren end
        if v.liaClassID then doorData.class = v.liaClassID end
        if v.liaFactionID then doorData.faction = v.liaFactionID end
        if table.Count(doorData) > 0 then data[k] = doorData end
    end

    self:setData(data)
    print("Amount of doors saved:", table.Count(data))
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
    if door:getNetVar("disabled") then return false end
end

function MODULE:CanPlayerAccessDoor(client, door, _)
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
    local entity = client:GetTracedEntity()
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
    for _, v in ipairs(ents.GetAll()) do
        if v ~= client and v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then v:removeDoorAccessData() end
    end
end

function MODULE:KeyLock(client, door, time)
    if not door:IsLocked() and IsValid(door) and client:GetPos():Distance(door:GetPos()) <= 256 and (door:isDoor() or (door:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty() and door:IsVehicle())) then
        client:setAction("@locking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, true) end, time, function() client:stopAction() end)
    end
end

function MODULE:KeyUnlock(client, door, time)
    if door:IsLocked() and IsValid(door) and client:GetPos():Distance(door:GetPos()) <= 256 and (door:isDoor() or (door:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty() and door:IsVehicle())) then
        client:setAction("@unlocking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, false) end, time, function() client:stopAction() end)
    end
end

function MODULE:ToggleLock(client, door, state)
    if door:isDoor() then
        local partner = door:getDoorPartner()
        if state then
            if IsValid(partner) then partner:Fire("lock") end
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
            lia.chat.send(client, "actions", "locks the door.", false)
        else
            if IsValid(partner) then partner:Fire("unlock") end
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
            lia.chat.send(client, "actions", "unlocks the door.", false)
        end

        door:SetLocked(state)
    elseif (door:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty()) and door:IsVehicle() then
        if state then
            door:Fire("lock")
            if door:isSimfphysCar() then door:Lock() end
            client:EmitSound("doors/door_latch3.wav")
            lia.chat.send(client, "actions", "locks the vehicle.", false)
        else
            door:Fire("unlock")
            if door:isSimfphysCar() then door:UnLock() end
            client:EmitSound("doors/door_latch1.wav")
            lia.chat.send(client, "actions", "unlocks the vehicle.", false)
        end

        door:SetLocked(state)
    end
end