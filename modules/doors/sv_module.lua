-- Variables for door data.
local variables = {"disabled", "name", "price", "noSell", "faction", "factions", "class", "hidden"}

-- Whether or not the door will be disabled.
-- The name of the door.
-- Price of the door.
-- If the door is unownable.
-- The faction that owns a door.
-- The class that owns a door.
-- Whether or not the door will be hidden.
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

local kekDarkRP = {
    ["DarkRPNonOwnable"] = function(ent, val)
        ent:setNetVar("noSell", true)
    end,
    ["DarkRPTitle"] = function(ent, val)
        ent:setNetVar("name", val)
    end,
    --["DarkRPDoorGroup"]  = function(ent, val) if RPExtraTeamDoors[val] then ent:setDoorGroup(val) end end,
    ["DarkRPCanLockpick"] = function(ent, val)
        ent.noPick = tobool(val)
    end
}

function MODULE:EntityKeyValue(ent, key, value)
    if not ent:isDoor() then return end

    if kekDarkRP[key] then
        kekDarkRP[key](ent, value)
    end
end

function MODULE:copyParentDoor(child)
    local parent = child.liaParent

    if IsValid(parent) then
        for k, v in ipairs(variables) do
            local value = parent:getNetVar(v)

            if child:getNetVar(v) ~= value then
                child:setNetVar(v, value)
            end
        end
    end
end

-- Called after the entities have loaded.
function MODULE:LoadData()
    -- Restore the saved door information.
    local data = self:getData()
    if not data then return end

    -- Loop through all of the saved doors.
    for k, v in pairs(data) do
        -- Get the door entity from the saved ID.
        local entity = ents.GetMapCreatedEntity(k)

        -- Check it is a valid door in-case something went wrong.
        if IsValid(entity) and entity:isDoor() then
            -- Loop through all of our door variables.
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

-- Called before the gamemode shuts down.
function MODULE:SaveDoorData()
    -- Create an empty table to save information in.
    local data = {}
    local doors = {}

    for k, v in ipairs(ents.GetAll()) do
        if v:isDoor() then
            doors[v:MapCreationID()] = v
        end
    end

    local doorData

    -- Loop through doors with information.
    for k, v in pairs(doors) do
        -- Another empty table for actual information regarding the door.
        doorData = {}

        -- Save all of the needed variables to the doorData table.
        for k2, v2 in ipairs(variables) do
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

        -- Add the door to the door information.
        if table.Count(doorData) > 0 then
            data[k] = doorData
        end
    end

    -- Save all of the door information.
    self:setData(data)
end

function MODULE:CanPlayerUseDoor(client, entity)
    if entity:getNetVar("disabled") then return false end
end

-- Whether or not a player a player has any abilities over the door, such as locking.
function MODULE:CanPlayerAccessDoor(client, door, access)
    local factions = door:getNetVar("factions")

    if factions ~= nil then
        local facs = util.JSONToTable(factions)

        if facs ~= nil and facs ~= "[]" then
            if facs[client:Team()] then return true end
        end
    end

    local class = door:getNetVar("class")
    -- If the door has a faction set which the client is a member of, allow access.
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
    local data = {}
    data.start = client:GetShootPos()
    data.endpos = data.start + client:GetAimVector() * 96
    data.filter = client
    local trace = util.TraceLine(data)
    local entity = trace.Entity

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

function MODULE:PlayerDisconnected(client)
    for k, v in ipairs(ents.GetAll()) do
        if v == client then return end

        if v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then
            v:removeDoorAccessData()
        end
    end
end

netstream.Hook("doorPerm", function(client, door, target, access)
    if IsValid(target) and target:getChar() and door.liaAccess and door:GetDTEntity(0) == client and target ~= client then
        access = math.Clamp(access or 0, DOOR_NONE, DOOR_TENANT)
        if access == door.liaAccess[target] then return end
        door.liaAccess[target] = access
        local recipient = {}

        for k, v in pairs(door.liaAccess) do
            if v > DOOR_GUEST then
                recipient[#recipient + 1] = k
            end
        end

        if #recipient > 0 then
            netstream.Start(recipient, "doorPerm", door, target, access)
        end
    end
end)