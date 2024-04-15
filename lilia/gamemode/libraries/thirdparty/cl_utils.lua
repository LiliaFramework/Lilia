function surface.DrawBlurRect(x, y, w, h, amount, heavyness, alpha)
    local blur = Material("pp/blurscreen")
    local X, Y = 0, 0
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)
    for i = 1, heavyness do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(X * -1, Y * -1, scrW, scrH)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function ClientsidePhysicsModel(modelpath, pos)
    if not modelpath or not pos then return end
    local prop = ents.CreateClientProp(modelpath)
    if not IsValid(prop) then return end
    prop:SetModel(modelpath)
    prop:SetPos(pos)
    prop:Spawn()
    prop:PhysicsInit(SOLID_VPHYSICS)
    prop:SetSolid(SOLID_NONE)
    prop:SetMoveType(MOVETYPE_VPHYSICS)
    return prop
end
