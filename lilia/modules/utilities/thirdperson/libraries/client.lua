local MODULE = MODULE
local MAT_GLASS2 = 45
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng, diff, fm, sm
local playerMeta = FindMetaTable("Player")
crouchFactor = 0
local NotSolidTextures = {
    ["TOOLS/TOOLSNODRAW"] = true,
    ["METAL/METALBAR001C"] = true,
    ["METAL/METALGATE001A"] = true,
    ["METAL/METALGATE004A"] = true,
    ["METAL/METALGRATE011A"] = true,
    ["METAL/METALGRATE016A"] = true,
    ["METAL/METALCOMBINEGRATE001A"] = true,
}

local NotSolidModels = {
    ["models/props_wasteland/exterior_fence002c.mdl"] = true,
    ["models/props_wasteland/exterior_fence002b.mdl"] = true,
    ["models/props_wasteland/exterior_fence003a.mdl"] = true,
    ["models/props_wasteland/exterior_fence001b.mdl"] = true
}

local NotSolidMatTypes = {
    [MAT_GLASS] = true,
    [MAT_GLASS2] = true
}

function MODULE:CalcView(client)
    ft = FrameTime()
    if client:CanOverrideView() and client:GetViewEntity() == client then
        if (client:OnGround() and client:KeyDown(IN_DUCK)) or client:Crouching() then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        local heightMax = lia.config.get("MaxThirdPersonHeight", 30)
        local horizontalMax = lia.config.get("MaxThirdPersonHorizontal", 30)
        local distanceMax = lia.config.get("MaxThirdPersonDistance", 100)
        curAng = client.camAng or Angle(0, 0, 0)
        view = {}
        traceData = {}
        traceData.start = client:GetPos() + client:GetViewOffset() + curAng:Up() * math.Clamp(lia.option.get("thirdPersonHeight", 10.0), 0, heightMax) + curAng:Right() * math.Clamp(lia.option.get("thirdPersonHorizontal", 10.0), -horizontalMax, horizontalMax) - client:GetViewOffsetDucked() * 0.5 * crouchFactor
        traceData.endpos = traceData.start - curAng:Forward() * math.Clamp(lia.option.get("thirdPersonDistance", 100.0), 0, distanceMax)
        traceData.filter = client
        view.origin = util.TraceLine(traceData).HitPos
        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        traceData2 = {}
        traceData2.start = aimOrigin
        traceData2.endpos = aimOrigin + curAng:Forward() * 65535
        traceData2.filter = client
        if lia.option.get("thirdPersonClassicMode", false) or (client.isWepRaised and client:isWepRaised()) or (client:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and client:GetVelocity():Length() >= 10) then client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle()) end
        return view
    end
end

function MODULE:CreateMove(cmd)
    local client = LocalPlayer()
    if client:CanOverrideView() and client:GetMoveType() ~= MOVETYPE_NOCLIP and client:GetViewEntity() == client then
        fm = cmd:GetForwardMove()
        sm = cmd:GetSideMove()
        diff = (client:EyeAngles() - (client.camAng or Angle(0, 0, 0)))[2] or 0
        diff = diff / 90
        cmd:SetForwardMove(fm + sm * diff)
        cmd:SetSideMove(sm + fm * diff)
        return false
    end
end

function MODULE:InputMouseApply(_, x, y)
    local client = LocalPlayer()
    if not client.camAng then client.camAng = Angle(0, 0, 0) end
    if client:CanOverrideView() and client:GetViewEntity() == client then
        client.camAng.p = math.Clamp(math.NormalizeAngle(client.camAng.p + y / 50), -85, 85)
        client.camAng.y = math.NormalizeAngle(client.camAng.y - x / 50)
        return true
    end
end

function MODULE:PlayerButtonDown(_, button)
    if button == KEY_F4 and IsFirstTimePredicted() then
        local currentState = lia.option.get("thirdPersonEnabled", false)
        lia.option.set("thirdPersonEnabled", not currentState)
        print(L("thirdpersonToggle") .. " - " .. tostring(not currentState))
        hook.Run("thirdPersonToggled", not currentState)
    end
end

function MODULE:ShouldDrawLocalPlayer()
    local client = LocalPlayer()
    if client:GetViewEntity() == client and client:CanOverrideView() then return true end
end

function MODULE:EntityEmitSound(data)
    local steps = {".stepleft", ".stepright"}
    local ThirdPersonIsEnabled = lia.option.get("thirdPersonEnabled", false)
    if ThirdPersonIsEnabled then
        if not IsValid(data.Entity) and not data.Entity:IsPlayer() then return end
        local sName = data.OriginalSoundName
        if sName:find(steps[1]) or sName:find(steps[2]) then return false end
    end
end

function MODULE:PrePlayerDraw(drawnClient)
    local client = LocalPlayer()
    if drawnClient == client then return end
    local clientPos = client:GetShootPos()
    local onlinePlayers = player.GetAll()
    local MaxViewDistance = lia.config.get("MaxViewDistance", 5000)
    local drawnClientPos = drawnClient:GetShootPos()
    local distance = clientPos:Distance(drawnClientPos)
    local isStaff = client:Team() == FACTION_STAFF
    if isStaff then
        if drawnClient.IsHidden then
            drawnClient:DrawShadow(true)
            drawnClient.IsHidden = false
        end
        return
    end

    if distance > MaxViewDistance then
        if not drawnClient.IsHidden then
            drawnClient:DrawShadow(false)
            drawnClient.IsHidden = true
        end
        return true
    end

    local toDrawnClient = (drawnClientPos - clientPos):GetNormalized()
    local clientForward = client:EyeAngles():Forward()
    local angleDifference = math.deg(math.acos(clientForward:Dot(toDrawnClient)))
    if angleDifference > (180 / 2) then
        if not drawnClient.IsHidden then
            drawnClient:DrawShadow(false)
            drawnClient.IsHidden = true
        end
        return true
    end

    if not drawnClient:IsDormant() and client:GetMoveType() ~= MOVETYPE_NOCLIP and client:CanOverrideView() and not client:hasValidVehicle() then
        local bBoneHit = false
        for i = 0, drawnClient:GetBoneCount() - 1 do
            local bonePos = drawnClient:GetBonePosition(i)
            local traceLine = util.TraceLine({
                start = clientPos,
                endpos = bonePos,
                filter = onlinePlayers,
                mask = MASK_SHOT_HULL
            })

            local entity = traceLine.Entity
            if traceLine.HitPos == bonePos then
                bBoneHit = true
                break
            elseif NotSolidMatTypes[traceLine.MatType] or NotSolidTextures[traceLine.HitTexture] or (IsValid(entity) and (entity:GetClass() == "prop_dynamic" or entity:GetClass() == "prop_physics") and NotSolidModels[entity:GetModel()]) then
                local traceLine2 = util.TraceLine({
                    start = bonePos,
                    endpos = clientPos,
                    filter = onlinePlayers,
                    mask = MASK_SHOT_HULL
                })

                if traceLine.Entity == traceLine2.Entity then
                    bBoneHit = true
                    break
                end
            end
        end

        if not bBoneHit then
            if not drawnClient.IsHidden then
                drawnClient:DrawShadow(false)
                drawnClient.IsHidden = true
            end
            return true
        elseif drawnClient.IsHidden then
            drawnClient:DrawShadow(true)
            drawnClient.IsHidden = false
        end
    elseif drawnClient.IsHidden then
        drawnClient:DrawShadow(true)
        drawnClient.IsHidden = false
    end
end

function playerMeta:CanOverrideView()
    local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
    local isInVehicle = self:hasValidVehicle()
    if IsValid(lia.gui.char) then return false end
    if isInVehicle then return false end
    if hook.Run("ShouldDisableThirdperson", self) == true then return false end
    return lia.option.get("thirdPersonEnabled", false) and lia.config.get("ThirdPersonEnabled", true) and IsValid(self) and self:getChar() and not IsValid(ragdoll)
end

function playerMeta:IsInThirdPerson()
    local thirdPersonEnabled = lia.config.get("ThirdPersonEnabled", true)
    local tpEnabled = lia.option.get("thirdPersonEnabled", false)
    return tpEnabled and thirdPersonEnabled
end

concommand.Add("tp_toggle", function()
    local currentState = lia.option.get("thirdPersonEnabled", false)
    lia.option.set("thirdPersonEnabled", not currentState)
    print(L("thirdpersonToggle") .. " - " .. tostring(not currentState))
    hook.Run("thirdPersonToggled", not currentState)
end)