function MODULE:PlayerDeath(client)
    net.Start("removeF1")
    net.Send(client)
end

net.Receive("liaTeleportToEntity", function(_, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if not ply:hasPrivilege("teleportToEntityTab") then return end
    local pos = ent:GetPos() + Vector(0, 0, 50)
    ply:SetPos(pos)
    ply:notifyLocalized("teleportedToEntity", ent:GetClass())
    lia.log.add(ply, "teleportToEntity", ent:GetClass())
end)

function MODULE:ShowHelp()
    return false
end