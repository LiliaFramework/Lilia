function PLUGIN:HUDPaint()
    local w, h = ScrW(), ScrH()
    local client = LocalPlayer()

    if client:GetNWBool("IsInCombat", false) then
        if client:GetNWBool("WarmUpBegin", false) then
            draw.SimpleText("Starting in: " .. math.Round(client:GetNWFloat("Timeramount", 0) - CurTime(), 1) .. " Seconds", "TBCWarmUpFont", w / 2, h / 5, Color(255, 165, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Combat Warm Up", "TBCWarmUpFont", w / 2, h / 7, Color(255, 165, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if client:GetNWBool("MyTurn", false) then
            draw.SimpleText("Your Turn", "TBCWarmUpFont", w / 2, h / 7, Color(255, 165, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Actions Points: " .. client:GetNWInt("AP", 3), "TBCSmallFont", w / 2, h / 1.25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Time Left: " .. math.Round(client:GetNWFloat("TurnTimer", 0) - CurTime(), 1) .. " Seconds", "TBCWarmUpFont", w / 2, h / 5, Color(255, 165, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local walkBind = input.LookupBinding("+walk") or "ALT"
        draw.SimpleText("INSTRUCTIONS | Skip Turn: " .. walkBind .. " | IF ALL PLAYERS SKIP THEIR TURN COMBAT WILL END", "TBCTinyFont", w / 2, h / 1.02, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Current Number of NPCs: " .. client:GetNWInt("CombatNPCCount", 0) .. " | Current Number of Players: " .. client:GetNWInt("CombatPlayerCount", 0) .. " |", "TBCSmallFont", w / 2, h / 1.05, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PLUGIN:PostDrawOpaqueRenderables()
    local ply = LocalPlayer()

    if ply:GetNWBool("IsInCombat", false) then
        if ply:GetNWBool("MyTurn", false) then
            local trace = util.TraceLine({
                start = ply:GetPos() + Vector(0, 0, 30),
                endpos = ply:GetPos() - Vector(0, 0, 1000),
                filter = ply
            })

            cam.Start3D2D(ply:GetNWVector("StartPos", ply:GetPos()) + trace.HitNormal, trace.HitNormal:Angle() + Angle(90, 0, 0), 1)
            surface.SetDrawColor(0, 0, 0, 200)
            draw.NoTexture()
            draw.Circle(0, 0, ix.config.Get("movementradius", 10) * self:factorial(ply:GetNWInt("AP", ix.config.Get("playeractionpoints", 3), 50)), 25)
            cam.End3D2D()
            cam.Start3D2D(ply:GetNWVector("StartPos", ply:GetPos()) + trace.HitNormal, trace.HitNormal:Angle() + Angle(90, 0, 0), 1)
            surface.SetDrawColor(94, 180, 255, 255)
            draw.NoTexture()
            draw.Circle(0, 0, ix.config.Get("movementradius", 10) * ply:GetNWInt("AP", ix.config.Get("playeractionpoints", 3)), 25)
            cam.End3D2D()
        end
    else
        for k, v in pairs(ents.GetAll()) do
            if v:IsNPC() or v:GetClass() == "player" then
                if v:GetNWBool("IsInCombat", false) then
                    render.SetColorMaterial()
                    render.DrawSphere(v:GetNWVector("StartPos", v:EyePos()), ix.config.Get("radius", 500), 50, 50, Color(0, 0, 0, 100))
                end
            end
        end
    end
end