local function fixupProp(client, ent, _, mins, maxs)
    local entPos = ent:GetPos()
    local endposD = ent:LocalToWorld(mins)
    local tr_down = util.TraceLine({
        start = entPos,
        endpos = endposD,
        filter = {ent, client}
    })

    local endposU = ent:LocalToWorld(maxs)
    local tr_up = util.TraceLine({
        start = entPos,
        endpos = endposU,
        filter = {ent, client}
    })

    if tr_up.Hit and tr_down.Hit then return end
    if tr_down.Hit then ent:SetPos(entPos + tr_down.HitPos - endposD) end
    if tr_up.Hit then ent:SetPos(entPos + tr_up.HitPos - endposU) end
end

local function TryFixPropPosition(client, ent, hitpos)
    fixupProp(client, ent, hitpos, Vector(ent:OBBMins().x, 0, 0), Vector(ent:OBBMaxs().x, 0, 0))
    fixupProp(client, ent, hitpos, Vector(0, ent:OBBMins().y, 0), Vector(0, ent:OBBMaxs().y, 0))
    fixupProp(client, ent, hitpos, Vector(0, 0, ent:OBBMins().z), Vector(0, 0, ent:OBBMaxs().z))
end

local function SpawnItem(client, itemName, target)
    if not IsValid(client) or not itemName then return end
    if client:hasPrivilege("Staff Permissions - Can Use Item Spawner") then
        if IsValid(target) then
            client:ConCommand("say /chargiveitem " .. target:SteamID() .. " " .. itemName)
            lia.log.add(client, "chargiveItem", itemName, target:Nick(), "Chargive item command executed")
            return
        end

        local vStart = client:EyePos()
        local vForward = client:GetAimVector()
        local tr = util.TraceLine({
            start = vStart,
            endpos = vStart + vForward * 4096,
            filter = client
        })

        if not tr.Hit then return end
        lia.item.spawn(itemName, tr.HitPos, function(_, ent)
            if IsValid(ent) then
                TryFixPropPosition(client, ent, tr.HitPos)
                undo.Create("item")
                undo.SetPlayer(client)
                undo.AddEntity(ent)
                local displayName = lia.item.list and lia.item.list[itemName] and lia.item.list[itemName].name or itemName
                undo.Finish("Item (" .. displayName .. ")")
                lia.log.add(client, "spawnItem", displayName, "Item spawned using item spawner")
            end
        end, angle_zero, {})
    end
end

net.Receive("lia_spawnItem", function(_, client)
    local itemID = net.ReadString()
    local targetID = net.ReadString()
    local target = lia.char.getByID(targetID)
    SpawnItem(client, itemID, target)
end)

util.AddNetworkString("lia_spawnItem")