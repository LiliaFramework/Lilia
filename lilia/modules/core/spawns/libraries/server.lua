---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.spawns = MODULE.spawns or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:LoadData()
    self.spawns = self:getData() or {}
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:SaveData()
    self:setData(self.spawns)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CharacterPreSave(character)
    local client = character:getPlayer()
    local vehicle = client:GetVehicle()
    if IsValid(client) and not IsValid(vehicle) or not vehicle:IsVehicle() then character:setData("pos", {client:GetPos(), client:EyeAngles(), game.GetMap()}) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerLoadedChar(client, character, _)
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerDeath(client, _, attacker)
    local char = client:getChar()
    if not char then return end
    if attacker:IsPlayer() then
        if self.LoseWeapononDeathHuman then self:RemoveAllEquippedWeapons(client) end
        if self.DeathPopupEnabled then
            net.Start("death_client")
            net.WriteString(attacker:Nick())
            net.WriteFloat(attacker:getChar():getID())
            net.Send(client)
        end
    end

    if (not attacker:IsPlayer() and self.LoseWeapononDeathNPC) or (self.LoseWeapononDeathWorld and attacker:IsWorld()) then self:RemoveAllEquippedWeapons(client) end
    timer.Simple(lia.config.SpawnTime + 1, function()
        net.Start("RespawnButtonDeath")
        net.Send(client)
    end)

    char:setData("deathPos", client:GetPos())
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:RemoveAllEquippedWeapons(client)
    local char = client:getChar()
    local inventory = char:getInv()
    local items = inventory:getItems()
    client.carryWeapons = {}
    client.LostItems = {}
    for _, v in pairs(items) do
        if (v.isWeapon or v.isCW) and v:getData("equip") then
            table.insert(client.LostItems, v.uniqueID)
            v:remove()
        end
    end

    if #client.LostItems > 0 then
        local amount = #client.LostItems > 1 and #client.LostItems .. " items" or "an item"
        client:notify("Because you died, you have lost " .. amount .. ".")
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
