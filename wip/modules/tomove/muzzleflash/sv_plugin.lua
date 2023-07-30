function MODULE:EntityFireBullets(ent, data)
    local dlight = DynamicLight(ent:EntIndex())

    if dlight then
        dlight.pos = ent:GetShootPos() + ent:GetAimVector() * 32
        dlight.dir = (ent:GetPos() - ent:GetPos()) * -1
        dlight.r = 255
        dlight.g = 255
        dlight.b = 150
        dlight.brightness = 7.5
        dlight.Decay = 8000
        dlight.Size = 400
        dlight.DieTime = CurTime() + 0.4
    end
end