-- Variables for door data.
local variables = {"disabled", "name", "price", "noSell", "faction", "class", "hidden"}

-- Whether or not the door will be disabled.
-- The name of the door.
-- Price of the door.
-- If the door is unownable.
-- The faction that owns a door.
-- The class that owns a door.
-- Whether or not the door will be hidden.
function PLUGIN:EntityTakeDamage(entity, dmgInfo)
    local SHOOT_DISTANCE = 180
    if not lia.config.get("ShootableDoors", false) then return end

    if entity:GetClass() == "prop_door_rotating" and (entity.liaNextBreach or 0) < CurTime() then
        local handle = entity:LookupBone("handle")

        if handle and dmgInfo:IsBulletDamage() then
            local client = dmgInfo:GetAttacker()
            local position = dmgInfo:GetDamagePosition()
            if client:GetEyeTrace().Entity ~= entity or client:GetPos():Distance(position) > SHOOT_DISTANCE then return end

            if IsValid(client) then
                if hook.Run("CanPlayerBustLock", client, entity) == false then return end
                local weapon = client:GetActiveWeapon()

                if IsValid(weapon) and weapon:GetClass() == "weapon_shotgun" then
                    entity:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", 150)
                    entity:blastDoor(client:GetAimVector() * 380)
                    local effect = EffectData()
                    effect:SetStart(position)
                    effect:SetOrigin(position)
                    effect:SetScale(10)
                    util.Effect("GlassImpact", effect, true, true)

                    return
                end
            end

            if IsValid(client) and position:Distance(entity:GetBonePosition(handle)) <= 12 then
                if hook.Run("CanPlayerBustLock", client, entity) == false then return end
                local effect = EffectData()
                effect:SetStart(position)
                effect:SetOrigin(position)
                effect:SetScale(2)
                util.Effect("GlassImpact", effect)
                local name = client:UniqueID() .. CurTime()
                client:SetName(name)
                entity.liaOldSpeed = entity.liaOldSpeed or entity:GetKeyValues().speed or 100
                entity:Fire("setspeed", entity.liaOldSpeed * 3.5)
                entity:Fire("unlock")
                entity:Fire("openawayfrom", name)
                entity:EmitSound("physics/wood/wood_plank_break" .. math.random(1, 4) .. ".wav", 100, 120)
                entity.liaNextBreach = CurTime() + 1

                timer.Simple(0.5, function()
                    if IsValid(entity) then
                        entity:Fire("setspeed", entity.liaOldSpeed)
                    end
                end)
            end
        end
    end
end

function PLUGIN:callOnDoorChildren(entity, callback)
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

function PLUGIN:copyParentDoor(child)
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
function PLUGIN:LoadData()
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
                elseif k2 == "faction" and not istable(v2) then
                    for k3, v3 in pairs(lia.faction.teams) do
                        if k3 == v2 then
                            entity.liaFactionID = k3
                            entity:setNetVar("faction", v3.index)
                            break
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
function PLUGIN:SaveDoorData()
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

        if v.liaFactionID and (not v:getNetVar("faction") or not istable(v:getNetVar("faction"))) then
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

function PLUGIN:CanPlayerUseDoor(client, entity)
    if entity:getNetVar("disabled") then return false end
end

-- Whether or not a player a player has any abilities over the door, such as locking.
function PLUGIN:CanPlayerAccessDoor(client, door, access)
    local faction = door:getNetVar("faction")

    -- If the door has a faction set which the client is a member of, allow access.
    if istable(faction) then
        for k, v in pairs(faction) do
            if client:Team() == v then return true end
        end
    elseif faction and client:Team() == faction then
        return true
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

function PLUGIN:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function PLUGIN:ShowTeam(client)
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

function PLUGIN:PlayerDisconnected(client)
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