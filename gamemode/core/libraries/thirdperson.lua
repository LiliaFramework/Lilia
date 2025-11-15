local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng
local clmp = math.Clamp
crouchFactor = 0
local diff, fm, sm
local maxValues = {
    height = 30,
    horizontal = 30,
    distance = 100
}

hook.Add("CalcView", "liaThirdPersonCalcView", function(client)
    ft = FrameTime()
    owner = owner or LocalPlayer()
    if client:canOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
        if client:OnGround() and client:KeyDown(IN_DUCK) or client:Crouching() then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        curAng = owner.camAng or Angle(0, 0, 0)
        view = {}
        traceData = {}
        traceData.start = client:GetPos() + client:GetViewOffset() + curAng:Up() * clmp(lia.option.get("thirdPersonHeight"), 0, maxValues.height) + curAng:Right() * clmp(lia.option.get("thirdPersonHorizontal"), -maxValues.horizontal, maxValues.horizontal) - client:GetViewOffsetDucked() * .5 * crouchFactor
        traceData.endpos = traceData.start - curAng:Forward() * clmp(lia.option.get("thirdPersonDistance"), 0, maxValues.distance)
        traceData.filter = client
        local isNoclip = client:GetMoveType() == MOVETYPE_NOCLIP
        if isNoclip then
            view.origin = traceData.endpos
        else
            view.origin = util.TraceLine(traceData).HitPos
        end

        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        if isNoclip then
            client:SetEyeAngles(curAng)
        else
            traceData2 = {}
            traceData2.start = aimOrigin
            traceData2.endpos = aimOrigin + curAng:Forward() * 65535
            traceData2.filter = client
            if lia.option.get("thirdPersonClassicMode", false) or owner.isWepRaised and owner:isWepRaised() or owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and owner:GetVelocity():Length() >= 10 then client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle()) end
        end
        return view
    end
end)

hook.Add("CreateMove", "liaThirdPersonCreateMove", function(cmd)
    owner = LocalPlayer()
    if owner:canOverrideView() and owner:GetMoveType() ~= MOVETYPE_NOCLIP and LocalPlayer():GetViewEntity() == LocalPlayer() then
        fm = cmd:GetForwardMove()
        sm = cmd:GetSideMove()
        diff = (owner:EyeAngles() - (owner.camAng or Angle(0, 0, 0)))[2] or 0
        diff = diff / 90
        cmd:SetForwardMove(fm + sm * diff)
        cmd:SetSideMove(sm + fm * diff)
        return false
    end
end)

hook.Add("InputMouseApply", "liaThirdPersonInputMouseApply", function(_, x, y)
    owner = LocalPlayer()
    if not owner.camAng then owner.camAng = Angle(0, 0, 0) end
    if owner:canOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
        owner.camAng.p = clmp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
        owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)
        return true
    end
end)

hook.Add("ShouldDrawLocalPlayer", "liaThirdPersonShouldDrawLocalPlayer", function() if LocalPlayer():GetViewEntity() == LocalPlayer() and not IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():canOverrideView() then return true end end)
hook.Add("EntityEmitSound", "liaThirdPersonEntityEmitSound", function(data)
    local steps = {".stepleft", ".stepright"}
    local thirdPersonIsEnabled = lia.option.get("thirdPersonEnabled", false)
    if thirdPersonIsEnabled then
        if not IsValid(data.Entity) and not data.Entity:IsPlayer() then return end
        local sName = data.OriginalSoundName
        if sName:find(steps[1]) or sName:find(steps[2]) then return false end
    end
end)

hook.Add("PlayerButtonDown", "liaThirdPersonPlayerButtonDown", function(_, button)
    if button == KEY_F4 and IsFirstTimePredicted() then
        local currentState = lia.option.get("thirdPersonEnabled", false)
        lia.option.set("thirdPersonEnabled", not currentState)
        hook.Run("ThirdPersonToggled", not currentState)
    end
end)