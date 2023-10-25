--------------------------------------------------------------------------------------------------------------------------
local Variables = {"disabled", "name", "price", "noSell", "faction", "factions", "class", "hidden"}
--------------------------------------------------------------------------------------------------------------------------
function MODULE:callOnDoorChildren(entity, callback)
    local parent
    if entity.liaChildren then
        parent = entity
    elseif entity.liaParent then
        parent = entity.liaParent
    end

    if IsValid(parent) then
        callback(parent)
        for k, v in pairs(parent.liaChildren) do
            local child = ents.GetMapCreatedEntity(k)
            if IsValid(child) then
                callback(child)
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
local DarkRPVariables = {
    ["DarkRPNonOwnable"] = function(ent, val)
        ent:setNetVar("noSell", true)
    end,
    ["DarkRPTitle"] = function(ent, val)
        ent:setNetVar("name", val)
    end,
    ["DarkRPCanLockpick"] = function(ent, val)
        ent.noPick = tobool(val)
    end
}

--------------------------------------------------------------------------------------------------------------------------
function MODULE:EntityKeyValue(ent, key, value)
    if not ent:isDoor() then return end
    if DarkRPVariables[key] then
        DarkRPVariables[key](ent, value)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:copyParentDoor(child)
    local parent = child.liaParent
    if IsValid(parent) then
        for k, v in ipairs(Variables) do
            local value = parent:getNetVar(v)
            if child:getNetVar(v) ~= value then
                child:setNetVar(v, value)
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
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
                        if IsValid(door) then
                            door.liaParent = entity
                        end
                    end
                else
                    entity:setNetVar(k2, v2)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:SaveDoorData()
    local data = {}
    local doors = {}
    for k, v in ipairs(ents.GetAll()) do
        if v:isDoor() then
            doors[v:MapCreationID()] = v
        end
    end

    local doorData
    for k, v in pairs(doors) do
        doorData = {}
        for k2, v2 in ipairs(Variables) do
            local value = v:getNetVar(v2)
            if value then
                doorData[v2] = v:getNetVar(v2)
            end
        end

        if v.liaChildren then
            doorData.children = v.liaChildren
        end

        if v.liaClassID then
            doorData.class = v.liaClassID
        end

        if v.liaFactionID then
            doorData.faction = v.liaFactionID
        end

        if table.Count(doorData) > 0 then
            data[k] = doorData
        end
    end

    self:setData(data)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerUseDoor(client, entity)
    if entity:getNetVar("disabled") then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerAccessDoor(client, door, access)
    local factions = door:getNetVar("factions")
    if factions ~= nil then
        local facs = util.JSONToTable(factions)
        if facs ~= nil and facs ~= "[]" then
            if facs[client:Team()] then return true end
        end
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

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShowTeam(client)
    local entity = client:GetTracedEntity()
    if IsValid(entity) and entity:isDoor() and not entity:getNetVar("faction") and not entity:getNetVar("class") then
        if entity:checkDoorAccess(client, DOOR_TENANT) then
            local door = entity
            if IsValid(door.liaParent) then
                door = door.liaParent
            end

            netstream.Start(client, "doorMenu", door, door.liaAccess, entity)
        elseif not IsValid(entity:GetDTEntity(0)) then
            lia.command.run(client, "doorbuy")
        else
            client:notifyLocalized("notAllowed")
        end

        return true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerDisconnected(client)
    for k, v in ipairs(ents.GetAll()) do
        if v == client then return end
        if v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then
            v:removeDoorAccessData()
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------