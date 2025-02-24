local MODULE = MODULE
function MODULE:LoadData()
    self.spawns = self:getData() or {}
end

function MODULE:SaveData()
    self:setData(self.spawns)
end

function MODULE:PostPlayerLoadout(client)
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character or not self.spawns or next(self.spawns) == nil then return end
    local factionInfo
    for _, v in ipairs(lia.faction.indices) do
        if v.index == client:Team() then
            factionInfo = v
            break
        end
    end

    if factionInfo then
        local spawns = self.spawns[factionInfo.uniqueID] or {}
        if #spawns > 0 then
            local spawnPosition = table.Random(spawns)
            client:SetPos(spawnPosition)
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
        if lia.config.get("LoseItemsonDeathHuman", false) then self:RemovedDropOnDeathItems(client) end
        if lia.config.get("DeathPopupEnabled", true) then
            net.Start("death_client")
            net.WriteString(tostring(attacker:getChar():getID()))
            net.WriteString(tostring(attacker:SteamID()))
            net.Send(client)
        end
    end

    client:setNetVar("IsDeadRestricted", true)
    client:setNetVar("lastDeathTime", os.time())
    timer.Simple(lia.config.get("SpawnTime"), function() if IsValid(client) then client:setNetVar("IsDeadRestricted", false) end end)
    client:SetDSP(30, false)
    character:setData("pos", nil)
    if (not attacker:IsPlayer() and lia.config.get("LoseItemsonDeathNPC", false)) or (lia.config.get("LoseItemsonDeathWorld", false) and attacker:IsWorld()) then self:RemovedDropOnDeathItems(client) end
    character:setData("deathPos", client:GetPos())
end

function MODULE:RemovedDropOnDeathItems(client)
    local character = client:getChar()
    if not character then return end
    local inventory = character:getInv()
    if not inventory then return end
    local items = inventory:getItems()
    client.carryWeapons = {}
    client.LostItems = {}
    for _, item in pairs(items) do
        if item.isWeapon and item.DropOnDeath and item:getData("equip", false) or not item.isWeapon and item.DropOnDeath then
            table.insert(client.LostItems, {
                name = item.name,
                id = item.id
            })

            item:remove()
        end
    end

    local lostCount = #client.LostItems
    if lostCount > 0 then client:notifyLocalized("itemsLostOnDeath", lostCount) end
end

function MODULE:PlayerSpawn(client)
    if client:getChar() and client:isStaffOnDuty() then
        if lia.config.get("StaffHasGodMode", true) then
            client:GodEnable()
        else
            client:GodDisable()
        end
    else
        client:GodDisable()
    end

    client:setNetVar("IsDeadRestricted", false)
    client:SetDSP(0, false)
end
