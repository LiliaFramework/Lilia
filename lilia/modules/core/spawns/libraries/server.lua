local MODULE = MODULE
MODULE.spawns = MODULE.spawns or {}
function MODULE:LoadData()
    self.spawns = self:getData() or {}
end

function MODULE:SaveData()
    self:setData(self.spawns)
end

function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if IsValid(client) or character and self.spawns and table.Count(self.spawns) > 0 then
        local class = character:getClass()
        local points
        local className = ""
        for k, v in ipairs(lia.faction.indices) do
            if k == client:Team() then
                points = self.spawns[v.uniqueID] or {}
                break
            end
        end

        if points then
            for _, v in ipairs(lia.class.list) do
                if class == v.index then
                    className = v.uniqueID
                    break
                end
            end

            points = points[className] or points[""]
            if points and table.Count(points) > 0 then
                local position = table.Random(points)
                client:SetPos(position)
            end
        end
    end
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    local InVehicle = client:hasValidVehicle()
    if IsValid(client) and not InVehicle and client:Alive() then character:setData("pos", {client:GetPos(), client:EyeAngles(), game.GetMap()}) end
end

function MODULE:PlayerLoadedChar(client, character)
    timer.Simple(0, function()
        if IsValid(client) then
            local position = character:getData("pos")
            if position then
                if position[3] and position[3]:lower() == game.GetMap():lower() then
                    client:SetPos(position[1].x and position[1] or client:GetPos())
                    client:SetEyeAngles(position[2].p and position[2] or Angle(0, 0, 0))
                end

                character:setData("pos", nil)
            end
        end
    end)
end

function MODULE:PlayerDeath(client, _, attacker)
    local character = client:getChar()
    if not character then return end
    if attacker:IsPlayer() then
        if self.LoseWeapononDeathHuman then self:RemovedDropOnDeathItems(client) end
        if self.DeathPopupEnabled then
            net.Start("death_client")
            net.WriteFloat(attacker:getChar():getID())
            net.Send(client)
        end
    end

    client:SetDeathTimer()
    character:setData("pos", nil)
    if (not attacker:IsPlayer() and self.LoseWeapononDeathNPC) or (self.LoseWeapononDeathWorld and attacker:IsWorld()) then self:RemovedDropOnDeathItems(client) end
    character:setData("deathPos", client:GetPos())
end

function MODULE:RemovedDropOnDeathItems(client)
    local character = client:getChar()
    if not character then return end
    local inventory = character:getInv()
    if not inventory then return end
    local items = inventory:getItems()
    if not items or #items == 0 then return end
    client.carryWeapons = {}
    client.LostItems = {}
    for _, item in ipairs(items) do
        if (item.isWeapon and item.DropOnDeath and item:getData("equip", false)) or (not item.isWeapon and item.DropOnDeath) then
            table.insert(client.LostItems, {
                name = item.name,
                id = item.id
            })

            item:remove()
        end
    end

    local lostCount = #client.LostItems
    if lostCount > 0 then
        local itemLabel = lostCount > 1 and "items" or "an item"
        client:notify("Because you died, you have lost " .. lostCount .. " " .. itemLabel .. ".")
    end
end

function MODULE:PlayerSpawn(client)
    if client:getChar() and client:isStaffOnDuty() then
        if self.StaffHasGodMode then
            client:GodEnable()
        else
            client:GodDisable()
        end
    else
        client:GodDisable()
    end
end