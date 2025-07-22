local ImportantBones = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_R_Foot"}
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng
local clmp = math.Clamp
crouchFactor = 0
local diff, fm, sm
local maxValues = {
    height = 30,
    horizontal = 30,
    distance = 100
}

local NotSolidTextures = {
    ["TOOLS/TOOLSNODRAW"] = true,
    ["METAL/METALBAR001C"] = true,
    ["METAL/METALGATE001A"] = true,
    ["METAL/METALGATE004A"] = true,
    ["METAL/METALGRATE011A"] = true,
    ["METAL/METALGRATE016A"] = true,
    ["METAL/METALCOMBINEGRATE001A"] = true
}

local NotSolidModels = {
    ["models/props_wasteland/exterior_fence002c.mdl"] = true,
    ["models/props_wasteland/exterior_fence002b.mdl"] = true,
    ["models/props_wasteland/exterior_fence003a.mdl"] = true,
    ["models/props_wasteland/exterior_fence001b.mdl"] = true
}

local NotSolidMatTypes = {
    [MAT_GLASS] = true
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

hook.Add("PrePlayerDraw", "liaThirdPersonPrePlayerDraw", function(ply)
    local maxDist = lia.config.get("MaxViewDistance", 5000)
    local maxDistSqr = maxDist * maxDist
    local debounceTime = 0.15
    local client = LocalPlayer()
    if ply == client then return end
    if client:isStaffOnDuty() or not lia.config.get("WallPeek", false) or client:InVehicle() or client:hasValidVehicle() or client:isNoClipping() or not client:CanOverrideView() then
        if ply.IsHidden then
            ply.IsHidden = false
            if not ply:GetNoDraw() then ply:DrawShadow(true) end
        end

        SetWeaponHidden(ply, false)
        return
    end

    local clientPos = client:EyePos()
    local targetPos = ply:EyePos()
    if clientPos:DistToSqr(targetPos) > maxDistSqr then
        if not ply.IsHidden then
            ply.IsHidden = true
            ply:DrawShadow(false)
        end

        SetWeaponHidden(ply, true)
        return true
    end

    local forward = client:EyeAngles():Forward()
    local dir = targetPos - clientPos
    if forward:Dot(dir) < 0 then
        if not ply.IsHidden then
            ply.IsHidden = true
            ply:DrawShadow(false)
        end

        SetWeaponHidden(ply, true)
        return true
    end

    local filter = {}
    for _, v in ipairs(player.GetAll()) do
        if v ~= ply and v ~= client then filter[#filter + 1] = v end
    end

    local visible = false
    for _, boneName in ipairs(ImportantBones) do
        local idx = ply:LookupBone(boneName)
        if idx then
            local bonePos = ply:GetBonePosition(idx)
            if bonePos then
                local tr = util.TraceLine({
                    start = clientPos,
                    endpos = bonePos,
                    filter = filter,
                    mask = MASK_SHOT_HULL
                })

                local ent = tr.Entity
                if tr.Fraction == 1 or ent == ply or NotSolidMatTypes[tr.MatType] or NotSolidTextures[tr.HitTexture] or IsValid(ent) and NotSolidModels[ent:GetModel()] then
                    visible = true
                    break
                end
            end
        end
    end

    local now = CurTime()
    if ply._visState ~= visible then
        if not ply._visChangeTime then
            ply._visChangeTime = now
        elseif now - ply._visChangeTime >= debounceTime then
            ply._visState = visible
            ply._visChangeTime = nil
            if visible then
                if ply.IsHidden then
                    ply.IsHidden = false
                    if not ply:GetNoDraw() then ply:DrawShadow(true) end
                end

                SetWeaponHidden(ply, false)
            else
                if not ply.IsHidden then
                    ply.IsHidden = true
                    ply:DrawShadow(false)
                end

                SetWeaponHidden(ply, true)
            end
        end
    else
        ply._visChangeTime = nil
    end
    return not (ply._visState == true)
end)
