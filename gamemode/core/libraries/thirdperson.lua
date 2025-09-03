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
    if client:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
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
        view.origin = util.TraceLine(traceData).HitPos
        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        traceData2 = {}
        traceData2.start = aimOrigin
        traceData2.endpos = aimOrigin + curAng:Forward() * 65535
        traceData2.filter = client
        if lia.option.get("thirdPersonClassicMode", false) or owner.isWepRaised and owner:isWepRaised() or owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and owner:GetVelocity():Length() >= 10 then client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle()) end
        return view
    end
end)

hook.Add("CreateMove", "liaThirdPersonCreateMove", function(cmd)
    owner = LocalPlayer()
    if owner:CanOverrideView() and owner:GetMoveType() ~= MOVETYPE_NOCLIP and LocalPlayer():GetViewEntity() == LocalPlayer() then
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
    if owner:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
        owner.camAng.p = clmp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
        owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)
        return true
    end
end)

hook.Add("ShouldDrawLocalPlayer", "liaThirdPersonShouldDrawLocalPlayer", function() if LocalPlayer():GetViewEntity() == LocalPlayer() and not IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():CanOverrideView() then return true end end)
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
        hook.Run("thirdPersonToggled", not currentState)
    end
end)

local function SetWeaponHidden(ply, state)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then wep:SetNoDraw(state) end
end

local function SetRagdollHidden(ply, state)
    local rag = ply:getRagdoll() or ply:GetRagdollEntity()
    if IsValid(rag) then
        rag:SetNoDraw(state)
        rag:DrawShadow(not state)
    end
end

local function PlayerIsVisible(client, ply, filter)
    local tr = util.TraceHull({
        start = client:EyePos(),
        endpos = ply:EyePos(),
        mins = ply:OBBMins(),
        maxs = ply:OBBMaxs(),
        filter = filter,
        mask = MASK_SHOT_HULL
    })
    return tr.Fraction == 1 or tr.Entity == ply
end

hook.Add("PrePlayerDraw", "liaThirdPersonPrePlayerDraw", function(ply)
    local client = LocalPlayer()
    if ply == client then return end
    if client:isStaffOnDuty() or not lia.config.get("WallPeek", false) or client:InVehicle() or client:hasValidVehicle() or client:isNoClipping() or not client:CanOverrideView() then
        if ply.IsHidden then
            ply.IsHidden = false
            if not ply:GetNoDraw() then ply:DrawShadow(true) end
        end

        SetWeaponHidden(ply, false)
        SetRagdollHidden(ply, false)
        return
    end

    local maxDist = lia.config.get("MaxViewDistance", 5000)
    if client:EyePos():DistToSqr(ply:EyePos()) > maxDist * maxDist then
        if not ply.IsHidden then
            ply.IsHidden = true
            ply:DrawShadow(false)
        end

        SetWeaponHidden(ply, true)
        SetRagdollHidden(ply, true)
        return true
    end

    if client:EyeAngles():Forward():Dot(ply:EyePos() - client:EyePos()) < 0 then
        if not ply.IsHidden then
            ply.IsHidden = true
            ply:DrawShadow(false)
        end

        SetRagdollHidden(ply, true)
        SetWeaponHidden(ply, true)
        return true
    end

    local filter = player.GetAll()
    table.RemoveByValue(filter, client)
    table.RemoveByValue(filter, ply)
    local visible = PlayerIsVisible(client, ply, filter)
    if visible then
        if ply.IsHidden then
            ply.IsHidden = false
            if not ply:GetNoDraw() then ply:DrawShadow(true) end
        end

        SetRagdollHidden(ply, false)
        SetWeaponHidden(ply, false)
    else
        if not ply.IsHidden then
            ply.IsHidden = true
            ply:DrawShadow(false)
            SetRagdollHidden(ply, true)
        end

        SetWeaponHidden(ply, true)
    end
    return not visible
end)