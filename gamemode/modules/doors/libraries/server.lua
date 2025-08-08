function MODULE:PostLoadData()
    if self.DoorsAlwaysDisabled then
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                door:setNetVar("disabled", true)
                count = count + 1
            end
        end

        lia.information(L("doorDisableAll"))
    end
end

local function buildCondition(gamemode, map)
    return "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
end

function MODULE:LoadData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local mapName = game.GetMap()
    local condition = buildCondition(gamemode, mapName)
    local query = "SELECT * FROM lia_doors WHERE " .. condition
    lia.db.query(query):next(function(res)
        local rows = res.results or {}
        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            local ent = ents.GetMapCreatedEntity(id)
            if IsValid(ent) and ent:isDoor() then
                local factions = lia.data.deserialize(row.factions) or {}
                if istable(factions) and not table.IsEmpty(factions) then
                    ent.liaFactions = factions
                    ent:setNetVar("factions", util.TableToJSON(factions))
                end

                local classes = lia.data.deserialize(row.classes) or {}
                if istable(classes) and not table.IsEmpty(classes) then
                    ent.liaClasses = classes
                    ent:setNetVar("classes", util.TableToJSON(classes))
                end

                if row.name and row.name ~= "NULL" then ent:setNetVar("name", row.name) end
                local price = tonumber(row.price) or 0
                ent:setNetVar("price", price)
                local locked = tonumber(row.locked) == 1
                ent:setNetVar("locked", locked)
                local disabled = tonumber(row.disabled) == 1
                ent:setNetVar("disabled", disabled)
                local hidden = tonumber(row.hidden) == 1
                ent:setNetVar("hidden", hidden)
                local noSell = tonumber(row.ownable) == 0
                ent:setNetVar("noSell", noSell)
            end
        end
    end)
end

function MODULE:SaveData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(gamemode, map)
    local rows = {}
    for _, door in ents.Iterator() do
        if door:isDoor() then
            rows[#rows + 1] = {
                gamemode = gamemode,
                map = map,
                id = door:MapCreationID(),
                factions = lia.data.serialize(door.liaFactions or {}),
                classes = lia.data.serialize(door.liaClasses or {}),
                disabled = door:getNetVar("disabled") and 1 or 0,
                hidden = door:getNetVar("hidden") and 1 or 0,
                ownable = door:getNetVar("noSell") and 0 or 1,
                name = door:getNetVar("name"),
                price = door:getNetVar("price"),
                locked = door:getNetVar("locked") and 1 or 0
            }
        end
    end

    lia.db.delete("doors", condition):next(function() if #rows > 0 then return lia.db.bulkInsert("doors", rows) end end)
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
    if factions and factions ~= "[]" then
        local facs = util.JSONToTable(factions)
        if facs then
            local playerFaction = client:getChar():getFaction()
            local factionData = lia.faction.indices[playerFaction]
            local unique = factionData and factionData.uniqueID
            for _, id in ipairs(facs) do
                if id == unique or lia.faction.getIndex(id) == playerFaction then return true end
            end
        end
    end

    local classes = door:getNetVar("classes")
    local charClass = client:getChar():getClass()
    local charClassData = lia.class.list[charClass]
    if classes and classes ~= "[]" and charClassData then
        local classTable = util.JSONToTable(classes)
        if classTable then
            local unique = charClassData.uniqueID
            for _, id in ipairs(classTable) do
                local classIndex = lia.class.retrieveClass(id)
                local classData = lia.class.list[classIndex]
                if id == unique or classIndex == charClass then
                    return true
                elseif classData and classData.team and classData.team == charClassData.team then
                    return true
                end
            end
            return false
        end
    end
end

function MODULE:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function MODULE:ShowTeam(client)
    local entity = client:getTracedEntity()
    if IsValid(entity) and entity:isDoor() then
        local factions = entity:getNetVar("factions")
        local classes = entity:getNetVar("classes")
        if (not factions or factions == "[]") and (not classes or classes == "[]") then
            if entity:checkDoorAccess(client, DOOR_TENANT) then
                local door = entity
                net.Start("doorMenu")
                net.WriteEntity(door)
                local access = door.liaAccess or {}
                net.WriteUInt(table.Count(access), 8)
                for ply, perm in pairs(access) do
                    net.WriteEntity(ply)
                    net.WriteUInt(perm or 0, 2)
                end

                net.WriteEntity(entity)
                net.Send(client)
            elseif not IsValid(entity:GetDTEntity(0)) then
                lia.command.run(client, "doorbuy")
            else
                client:notifyLocalized("notNow")
            end
            return true
        end
    end
end

function MODULE:PlayerDisconnected(client)
    for _, v in ents.Iterator() do
        if v ~= client and v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then v:removeDoorAccessData() end
    end
end

function MODULE:KeyLock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if hook.Run("CanPlayerLock", client, door) == false then return end
    local distance = client:GetPos():Distance(door:GetPos())
    local isProperEntity = door:isDoor() or door:IsVehicle() or door:isSimfphysCar()
    if isProperEntity and not door:isLocked() and distance <= 256 and (door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty()) then
        client:setAction(L("locking"), time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, true) end, time, function() client:stopAction() end)
        lia.log.add(client, "lockDoor", door)
    end
end

function MODULE:KeyUnlock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if hook.Run("CanPlayerUnlock", client, door) == false then return end
    local distance = client:GetPos():Distance(door:GetPos())
    local isProperEntity = door:isDoor() or door:IsVehicle() or door:isSimfphysCar()
    if isProperEntity and door:isLocked() and distance <= 256 and (door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty()) then
        client:setAction(L("unlocking"), time, function() end)
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
    elseif (door:GetCreator() == client or client:hasPrivilege(L("manageDoors")) or client:isStaffOnDuty()) and (door:IsVehicle() or door:isSimfphysCar()) then
        if state then
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
        end

        door:setLocked(state)
    end

    hook.Run("DoorLockToggled", client, door, state)
    lia.log.add(client, "toggleLock", door, state and L("locked") or L("unlocked"))
end