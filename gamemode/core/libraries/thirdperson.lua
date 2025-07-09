local view, traceData, traceData2, aimOrigin, ft, curAng
local crouchFactor = 0
local ImportantBones = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_R_Foot"}
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
    if IsValid(lia.gui.score) then return end
    ft = FrameTime()
    if client:CanOverrideView() and client:GetViewEntity() == client then
        if client:OnGround() and (client:KeyDown(IN_DUCK) or client:Crouching()) then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        local heightMax = lia.config.get("MaxThirdPersonHeight", 30)
        local horizontalMax = lia.config.get("MaxThirdPersonHorizontal", 30)
        local distanceMax = lia.config.get("MaxThirdPersonDistance", 100)
        curAng = client.camAng or angle_zero
        traceData = {
            start = client:GetPos() + client:GetViewOffset() + curAng:Up() * math.Clamp(lia.option.get("thirdPersonHeight", 10), 0, heightMax) + curAng:Right() * math.Clamp(lia.option.get("thirdPersonHorizontal", 10), -horizontalMax, horizontalMax) - client:GetViewOffsetDucked() * 0.5 * crouchFactor,
            endpos = client:GetPos() + client:GetViewOffset() + curAng:Up() * math.Clamp(lia.option.get("thirdPersonHeight", 10), 0, heightMax) + curAng:Right() * math.Clamp(lia.option.get("thirdPersonHorizontal", 10), -horizontalMax, horizontalMax) - client:GetViewOffsetDucked() * 0.5 * crouchFactor - curAng:Forward() * math.Clamp(lia.option.get("thirdPersonDistance", 100), 0, distanceMax),
            filter = client
        }

        view = {}
        view.origin = util.TraceLine(traceData).HitPos
        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        traceData2 = {
            start = aimOrigin,
            endpos = aimOrigin + curAng:Forward() * 65535,
            filter = client
        }

        local tr = util.TraceLine(traceData2)
        local shouldAutoFace = lia.option.get("thirdPersonClassicMode", false) or client.isWepRaised and client:isWepRaised() or client:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and client:GetVelocity():Length() >= 10
        if shouldAutoFace then
            local eyeAng
            if tr.Hit and tr.HitPos:Distance(client:GetShootPos()) > 32 and tr.Fraction > 0.02 then
                eyeAng = (tr.HitPos - client:GetShootPos()):Angle()
            else
                eyeAng = curAng + client:GetViewPunchAngles()
            end

            client:SetEyeAngles(eyeAng)
        end
        return view
    end
end)

hook.Add("CreateMove", "liaThirdPersonCreateMove", function(cmd)
    local client = LocalPlayer()
    if client:CanOverrideView() and not client:isNoClipping() and client:GetViewEntity() == client then
        local fm = cmd:GetForwardMove()
        local sm = cmd:GetSideMove()
        local diffAngle = client:EyeAngles().y - (client.camAng and client.camAng.y or 0)
        local theta = math.rad(-diffAngle)
        local newFm = fm * math.cos(theta) - sm * math.sin(theta)
        local newSm = fm * math.sin(theta) + sm * math.cos(theta)
        cmd:SetForwardMove(newFm)
        cmd:SetSideMove(newSm)
        return false
    end
end)

hook.Add("InputMouseApply", "liaThirdPersonInputMouseApply", function(_, x, y)
    local client = LocalPlayer()
    if not client.camAng then client.camAng = angle_zero end
    if client:CanOverrideView() and client:GetViewEntity() == client then
        client.camAng.p = math.Clamp(math.NormalizeAngle(client.camAng.p + y / 50), -85, 85)
        client.camAng.y = math.NormalizeAngle(client.camAng.y - x / 50)
        return true
    end
end)

hook.Add("PlayerButtonDown", "liaThirdPersonPlayerButtonDown", function(_, button)
    if button == KEY_F4 and IsFirstTimePredicted() then
        local currentState = lia.option.get("thirdPersonEnabled", false)
        lia.option.set("thirdPersonEnabled", not currentState)
        hook.Run("thirdPersonToggled", not currentState)
    end
end)

hook.Add("ShouldDrawLocalPlayer", "liaThirdPersonShouldDrawLocalPlayer", function()
    local client = LocalPlayer()
    if client:GetViewEntity() == client and client:CanOverrideView() then return true end
end)

hook.Add("EntityEmitSound", "liaThirdPersonEntityEmitSound", function(data)
    local steps = {".stepleft", ".stepright"}
    local thirdPersonIsEnabled = lia.option.get("thirdPersonEnabled", false)
    if thirdPersonIsEnabled then
        if not IsValid(data.Entity) and not data.Entity:IsPlayer() then return end
        local sName = data.OriginalSoundName
        if sName:find(steps[1]) or sName:find(steps[2]) then return false end
    end
end)

hook.Add("PrePlayerDraw", "liaThirdPersonPrePlayerDraw", function(drawnClient)
    local client = LocalPlayer()
    if drawnClient == client then return end
    if client:isStaffOnDuty() or not lia.config.get("WallPeek", false) or client:InVehicle() or client:hasValidVehicle() or client:isNoClipping() or not client:CanOverrideView() then
        drawnClient:DrawShadow(true)
        drawnClient.IsHidden = false
        return
    end

    local clientPos = client:GetShootPos()
    local targetPos = drawnClient:GetShootPos()
    if clientPos:Distance(targetPos) > lia.config.get("MaxViewDistance", 5000) then
        drawnClient:DrawShadow(false)
        drawnClient.IsHidden = true
        return true
    end

    local dirToTarget = (targetPos - clientPos):GetNormalized()
    if math.deg(math.acos(client:EyeAngles():Forward():Dot(dirToTarget))) > 90 then
        drawnClient:DrawShadow(false)
        drawnClient.IsHidden = true
        return true
    end

    local filter = player.GetAll()
    local visible = false
    for _, boneName in ipairs(ImportantBones) do
        local boneIndex = drawnClient:LookupBone(boneName)
        if boneIndex then
            local bonePos = drawnClient:GetBonePosition(boneIndex)
            local trace = util.TraceLine({
                start = clientPos,
                endpos = bonePos,
                filter = filter,
                mask = MASK_SHOT_HULL
            })

            local ent = trace.Entity
            if trace.HitPos == bonePos or NotSolidMatTypes[trace.MatType] or NotSolidTextures[trace.HitTexture] or IsValid(ent) and NotSolidModels[ent:GetModel()] then
                visible = true
                break
            end
        end
    end

    drawnClient:DrawShadow(visible)
    drawnClient.IsHidden = not visible
    return not visible
end)