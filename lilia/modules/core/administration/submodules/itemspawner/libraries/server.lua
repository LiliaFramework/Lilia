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
    if tr_down.Hit then ent:SetPos(entPos + (tr_down.HitPos - endposD)) end
    if tr_up.Hit then ent:SetPos(entPos + (tr_up.HitPos - endposU)) end
end

local function TryFixPropPosition(client, ent, hitpos)
    fixupProp(client, ent, hitpos, Vector(ent:OBBMins().x, 0, 0), Vector(ent:OBBMaxs().x, 0, 0))
    fixupProp(client, ent, hitpos, Vector(0, ent:OBBMins().y, 0), Vector(0, ent:OBBMaxs().y, 0))
    fixupProp(client, ent, hitpos, Vector(0, 0, ent:OBBMins().z), Vector(0, 0, ent:OBBMaxs().z))
end

local function SpawnItem(client, itemName, target)
    if not IsValid(client) or not itemName then return end
    CAMI.PlayerHasAccess(client, "Can Use Item Spawner", function(hasAccess)
        if not hasAccess then return end
        if target then
            client:ConCommand("say chargiveitem " .. target .. " " .. itemName)
            return
        end

        local vStart = client:EyePos()
        local vForward = client:GetAimVector()
        local tr = util.TraceLine({
            start = vStart,
            endpos = vStart + (vForward * 4096),
            filter = client
        })

        if not tr.Hit then return end
        lia.item.spawn(itemName, tr.HitPos, function(_, ent)
            if IsValid(ent) then
                TryFixPropPosition(client, ent, tr.HitPos)
                undo.Create("item")
                undo.SetPlayer(client)
                undo.AddEntity(ent)
                undo.Finish("Item (" .. itemName .. ")")
            end
        end, angle_zero, {})
    end)
end

net.Receive("lia_spawnItem", function(_, client)
    local itemID = net.ReadString()
    local target = net.ReadString()
    SpawnItem(client, itemID, target ~= "" and target or nil)
end)

util.AddNetworkString("lia_spawnItem")
