local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng
local clmp = math.Clamp
crouchFactor = 0
local diff, fm, sm
local firstPersonCurrentAngles = angle_zero
local firstPersonCurrentPosition = vector_origin
local firstPersonTargetAngles = angle_zero
local firstPersonTargetPosition = vector_origin
local freelooking = false
local freelookX = 0
local freelookY = 0
local freelookInitialAngles = Angle()
local freelookCurrentAngles = Angle()
local freelookWasHolding = false
local zeroAngle = Angle()
local hiddenBoneScale = Vector(0.001, 0.001, 0.001)
local visibleBoneScale = Vector(1, 1, 1)
local canOverrideView
lia.camera = lia.camera or {}
hook.Remove("ShouldDisableThirdperson", "liaThirdPersonSuppressOnWeapons")
local maxValues = {
    height = 30,
    horizontal = 30,
    distance = 100
}

local rmbViewWeapons = {
    lia_adminstick = true,
    lia_mapconfigurer = true,
    gmod_tool = true,
    weapon_physgun = true,
    weapon_physcannon = true
}

local realisticViewWeaponWhitelist = {
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    lia_adminstick = true,
    lia_hands = true,
    lia_mapconfigurer = true,
    weapon_physgun = true,
    weapon_physcannon = true
}

local function isCharacterMenuOpen()
    return IsValid(lia.gui.loading) or IsValid(lia.gui.char) or IsValid(lia.gui.charCreate) or IsValid(lia.gui.character)
end

local function getActiveWeaponClass(client)
    if not IsValid(client) then return end
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end
    return weapon:GetClass()
end

local function isUsingThirdPersonCamera(client)
    return IsValid(client) and client:GetViewEntity() == client and canOverrideView and canOverrideView(client) or false
end

local function shouldForceRMBViewForWeapon(client)
    local class = getActiveWeaponClass(client)
    return class and rmbViewWeapons[class] == true or false
end

local function isUsingKeysWeapon(client)
    return getActiveWeaponClass(client) == "lia_keys"
end

local function isRealisticViewWhitelistedWeapon(client)
    local class = getActiveWeaponClass(client)
    return class and realisticViewWeaponWhitelist[class] == true or false
end

local function shouldSuppressRealisticView(client)
    if not IsValid(client) then return false end
    if isUsingKeysWeapon(client) then return shouldForceRMBViewForWeapon(client) end
    return client:KeyDown(IN_ATTACK2) or shouldForceRMBViewForWeapon(client)
end

function canOverrideView(client)
    if not IsValid(client) then return false end
    if isCharacterMenuOpen() then return false end
    if IsValid(client:GetVehicle()) then return false end
    if hook.Run("ShouldDisableThirdperson", client) == true then return false end
    local ragdoll = client:GetRagdollEntity()
    return lia.option.get("thirdPersonEnabled", false) and lia.config.get("ThirdPersonEnabled", true) and client:getChar() and not IsValid(ragdoll)
end

local function canApplyFirstPersonEffects(client)
    if not IsValid(client) or client ~= LocalPlayer() then return false end
    if isCharacterMenuOpen() then return false end
    if not client:getChar() then return false end
    if client:GetViewEntity() ~= client then return false end
    if isUsingThirdPersonCamera(client) then return false end
    return lia.option.get("firstPersonEffects", false)
end

local function canUseRealisticView(client)
    if not IsValid(client) or client ~= LocalPlayer() then return false end
    if client.IsInAdminEntityView then return false end
    if isCharacterMenuOpen() then return false end
    if not client:getChar() or client:InVehicle() then return false end
    if client:GetViewEntity() ~= client or isUsingThirdPersonCamera(client) then return false end
    if shouldSuppressRealisticView(client) then return false end
    if isRealisticViewWhitelistedWeapon(client) then return false end
    local class = getActiveWeaponClass(client)
    if not class then return false end
    if isUsingKeysWeapon(client) then return true end
    if lia.option.get("realisticViewEnabled", false) then return true end
    if lia.option.get("alwaysRealisticView", false) then return true end
    return false
end

local function canUseFreelook(client)
    if not IsValid(client) or client ~= LocalPlayer() then return false end
    if client.IsInAdminEntityView then return false end
    if isCharacterMenuOpen() then return false end
    if not client:getChar() then return false end
    if client:GetViewEntity() ~= client then return false end
    if isUsingThirdPersonCamera(client) then return false end
    return lia.option.get("freelookEnabled", false)
end

local function isInSights(client)
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return client:KeyDown(IN_ATTACK2) end
    local inArcCWSights = weapon.ArcCW and ArcCW and weapon.GetState and weapon:GetState() == ArcCW.STATE_SIGHTS
    return lia.option.get("freelookBlockADS", true) and (client:KeyDown(IN_ATTACK2) or weapon.GetInSights and weapon:GetInSights() or inArcCWSights or weapon.GetIronSights and weapon:GetIronSights())
end

local function isHoldingFreelookBind(client)
    if not input.LookupBinding("freelook") then return client:KeyDown(IN_WALK) end
    return freelooking
end

local function resetFreelookState()
    freelookX = 0
    freelookY = 0
    freelookCurrentAngles = zeroAngle
end

local function beginFreelook(client)
    freelookInitialAngles = client:EyeAngles()
    freelookInitialAngles.r = 0
    freelookWasHolding = true
end

local function endFreelook()
    freelookWasHolding = false
    resetFreelookState()
end

local function shouldDrawBodyForFreelook(client)
    if not canUseFreelook(client) then return false end
    return isHoldingFreelookBind(client) or math.abs(freelookCurrentAngles.p) >= 0.05 or math.abs(freelookCurrentAngles.y) >= 0.05
end

local function getFirstPersonHeadBones(client)
    if client.liaFirstPersonHeadBones then return client.liaFirstPersonHeadBones end
    local bones = {}
    local addedBones = {}
    local function addBone(index)
        if index == nil or index < 0 or addedBones[index] then return end
        addedBones[index] = true
        bones[#bones + 1] = index
    end

    for bone = 0, (client:GetBoneCount() or 0) - 1 do
        local boneName = client:GetBoneName(bone)
        if boneName then
            local lowered = boneName:lower()
            if lowered:find("head", 1, true) or lowered:find("neck", 1, true) or lowered:find("collar", 1, true) or lowered:find("clavicle", 1, true) or lowered:find("upperchest", 1, true) then
                addBone(bone)
                local parent = client:GetBoneParent(bone)
                local depth = 0
                while parent and parent >= 0 and depth < 2 do
                    addBone(parent)
                    parent = client:GetBoneParent(parent)
                    depth = depth + 1
                end
            end
        end
    end

    client.liaFirstPersonHeadBones = bones
    return bones
end

local function setFirstPersonHeadHidden(client, hidden)
    if not IsValid(client) then return end
    if client.liaFirstPersonHeadHidden == hidden then return end
    client.liaFirstPersonHeadHidden = hidden
    local scale = hidden and hiddenBoneScale or visibleBoneScale
    for _, bone in ipairs(getFirstPersonHeadBones(client)) do
        client:ManipulateBoneScale(bone, scale)
    end

    client:InvalidateBoneCache()
end

local function applyFreelookToAngles(client, angles)
    if not canUseFreelook(client) then
        endFreelook()
        return angles
    end

    local smoothness = clmp(lia.option.get("freelookSmoothness", 1), 0.1, 2)
    freelookCurrentAngles = LerpAngle(0.15 * smoothness, freelookCurrentAngles, Angle(freelookY, -freelookX, 0))
    local shouldReset = not isHoldingFreelookBind(client) and math.abs(freelookCurrentAngles.p) < 0.05
    shouldReset = shouldReset or isInSights(client) and math.abs(freelookCurrentAngles.p) < 0.05
    shouldReset = shouldReset or not system.HasFocus() or isUsingThirdPersonCamera(client)
    if shouldReset then
        freelookInitialAngles = angles + freelookCurrentAngles
        endFreelook()
        return angles
    end
    return angles + freelookCurrentAngles
end

local function buildRealisticView(client, origin, angles, fov)
    local head = client:LookupAttachment("eyes")
    head = client:GetAttachment(head)
    if not head or not head.Pos or IsValid(lia.gui.menu) or client:GetMoveType() == MOVETYPE_NOCLIP then return end
    local viewAngles = applyFreelookToAngles(client, head.Ang)
    return {
        origin = head.Pos + head.Ang:Up(),
        angles = viewAngles,
        fov = fov or 90,
        drawviewer = true
    }
end

local function buildFreelookBodyView(client, pos, ang, fov)
    if not shouldDrawBodyForFreelook(client) then return end
    setFirstPersonHeadHidden(client, true)
    local bodyView = buildRealisticView(client, pos, ang, fov)
    if bodyView then return bodyView end
    return {
        origin = pos,
        angles = applyFreelookToAngles(client, ang),
        fov = fov
    }
end

function lia.camera.calcView(client, pos, ang, fov)
    ft = FrameTime()
    local owner = LocalPlayer()
    setFirstPersonHeadHidden(client, false)
    if isUsingThirdPersonCamera(client) then
        if client:OnGround() and client:KeyDown(IN_DUCK) or client:Crouching() then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        curAng = owner.camAng or Angle(0, 0, 0)
        view = {}
        local viewOffset = client:GetViewOffset()
        local heightOffset = curAng:Up() * clmp(lia.option.get("thirdPersonHeight"), 0, maxValues.height)
        local horizontalOffset = curAng:Right() * clmp(lia.option.get("thirdPersonHorizontal"), -maxValues.horizontal, maxValues.horizontal)
        local crouchOffset = client:GetViewOffsetDucked() * 0.5 * crouchFactor
        traceData = {}
        traceData.start = client:GetPos() + viewOffset + heightOffset + horizontalOffset - crouchOffset
        traceData.endpos = traceData.start - curAng:Forward() * clmp(lia.option.get("thirdPersonDistance"), 0, maxValues.distance)
        traceData.filter = {client}
        traceData.mask = MASK_SOLID_BRUSHONLY
        local isNoclip = client:GetMoveType() == MOVETYPE_NOCLIP
        local traceResult
        if isNoclip then
            view.origin = traceData.endpos
        else
            traceResult = util.TraceLine(traceData)
            local hitDistance = traceData.start:Distance(traceResult.HitPos)
            if traceResult.Hit then
                local minDistanceFromWall = 10
                local direction = (traceData.endpos - traceData.start):GetNormalized()
                local safeDistance = math.max(hitDistance - minDistanceFromWall, minDistanceFromWall)
                view.origin = traceData.start + direction * safeDistance
                local verifyTrace = util.TraceLine({
                    start = traceData.start,
                    endpos = view.origin,
                    filter = {client},
                    mask = MASK_SOLID_BRUSHONLY
                })

                if verifyTrace.Hit then view.origin = verifyTrace.HitPos + verifyTrace.HitNormal * minDistanceFromWall end
            else
                view.origin = traceResult.HitPos
            end
        end

        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        if isNoclip then
            client:SetEyeAngles(curAng)
        else
            traceData2 = {}
            traceData2.start = aimOrigin
            traceData2.endpos = aimOrigin + curAng:Forward() * 65535
            traceData2.filter = {client}
            traceData2.mask = MASK_SOLID_BRUSHONLY
            if lia.option.get("thirdPersonClassicMode", false) or owner.isWepRaised and owner:isWepRaised() or owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and owner:GetVelocity():Length() >= 10 then
                local aimTrace = util.TraceLine(traceData2)
                client:SetEyeAngles((aimTrace.HitPos - client:GetShootPos()):Angle())
            end
        end
        return view
    end

    if canUseRealisticView(client) then
        setFirstPersonHeadHidden(client, true)
        local realisticView = buildRealisticView(client, pos, ang, fov)
        if realisticView then return realisticView end
    end

    local freelookBodyView = buildFreelookBodyView(client, pos, ang, fov)
    if freelookBodyView then return freelookBodyView end
    ang = applyFreelookToAngles(client, ang)
    if not canApplyFirstPersonEffects(client) then
        return {
            origin = pos,
            angles = ang,
            fov = fov
        }
    end

    local realTime = RealTime()
    local velocity = math.floor(client:GetVelocity():Length2D())
    if client:OnGround() then
        local walkSpeed = lia.config.get("WalkSpeed")
        if velocity > walkSpeed + 40 and not client.isBreathing then
            local runSpeed = lia.config.get("RunSpeed")
            local percentage = clmp(velocity / runSpeed * 100, 0.5, 5)
            firstPersonTargetAngles = Angle(math.abs(math.cos(realTime * runSpeed / 33) * 0.4 * percentage), math.sin(realTime * runSpeed / 29) * 0.5 * percentage, 0)
            firstPersonTargetPosition = Vector(0, 0, math.sin(realTime * runSpeed / 30) * 0.4 * percentage)
        else
            local percentage = clmp((velocity / walkSpeed * 100) / 60, 0, 10)
            firstPersonTargetAngles = Angle(math.cos(realTime * walkSpeed / 8) * 0.2 * percentage, 0, 0)
            firstPersonTargetPosition = Vector(0, 0, math.sin(realTime * walkSpeed / 8) * 0.5 * percentage)
        end
    elseif client:WaterLevel() >= 2 then
        firstPersonTargetAngles = angle_zero
        firstPersonTargetPosition = vector_origin
    else
        velocity = math.abs(client:GetVelocity().z)
        local angleVariance = 0
        local percentage = clmp(velocity / 200, 0.1, 8)
        if percentage > 1 then angleVariance = percentage end
        firstPersonTargetAngles = Angle(math.cos(realTime * 15) * 2 * percentage + math.Rand(-angleVariance * 2, angleVariance * 2), math.sin(realTime * 15) * 2 * percentage + math.Rand(-angleVariance * 2, angleVariance * 2), math.Rand(-angleVariance * 5, angleVariance * 5))
        firstPersonTargetPosition = Vector(math.cos(realTime * 15) * 0.5 * percentage, math.sin(realTime * 15) * 0.5 * percentage, 0)
    end

    firstPersonCurrentAngles = LerpAngle(ft * 10, firstPersonCurrentAngles, firstPersonTargetAngles)
    firstPersonCurrentPosition = LerpVector(ft * 10, firstPersonCurrentPosition, firstPersonTargetPosition)
    local shouldDrawFreelookBody = shouldDrawBodyForFreelook(client)
    if shouldDrawFreelookBody then setFirstPersonHeadHidden(client, true) end
    return {
        origin = pos + firstPersonCurrentPosition,
        angles = ang + firstPersonCurrentAngles,
        fov = fov,
        drawviewer = shouldDrawFreelookBody
    }
end

hook.Add("CreateMove", "liaThirdPersonCreateMove", function(cmd)
    local owner = LocalPlayer()
    if isUsingThirdPersonCamera(owner) and owner:GetMoveType() ~= MOVETYPE_NOCLIP then
        fm = cmd:GetForwardMove()
        sm = cmd:GetSideMove()
        local eyeAngles = owner:EyeAngles()
        local camAng = owner.camAng or Angle(0, 0, 0)
        diff = (eyeAngles - camAng)[2] or 0
        diff = diff / 90
        cmd:SetForwardMove(fm + sm * diff)
        cmd:SetSideMove(sm + fm * diff)
        return false
    end
end)

hook.Add("InputMouseApply", "liaThirdPersonInputMouseApply", function(cmd, x, y)
    local owner = LocalPlayer()
    if not owner.camAng then owner.camAng = Angle(0, 0, 0) end
    if isUsingThirdPersonCamera(owner) then
        owner.camAng.p = clmp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
        owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)
        return true
    end

    if not canUseFreelook(owner) then return end
    if hook.Run("ShouldUseFreelook", owner) == false then return end
    local isHolding = isHoldingFreelookBind(owner)
    if not isHolding or isInSights(owner) or isUsingThirdPersonCamera(owner) then
        if freelookWasHolding then endFreelook() end
        return
    end

    if not freelookWasHolding then beginFreelook(owner) end
    freelookInitialAngles.z = 0
    cmd:SetViewAngles(freelookInitialAngles)
    freelookX = clmp(freelookX + x * 0.02, -lia.option.get("freelookLimitHorizontal", 90), lia.option.get("freelookLimitHorizontal", 90))
    freelookY = clmp(freelookY + y * 0.02, -lia.option.get("freelookLimitVertical", 65), lia.option.get("freelookLimitVertical", 65))
    return true
end)

hook.Add("ShouldDrawLocalPlayer", "liaThirdPersonShouldDrawLocalPlayer", function()
    local client = LocalPlayer()
    if isUsingThirdPersonCamera(client) and not IsValid(client:GetVehicle()) then return true end
end)

hook.Add("CalcViewModelView", "liaFreelookCalcViewModelView", function(weapon, _, _, _, _, angles)
    local client = LocalPlayer()
    if not canUseFreelook(client) then return end
    local mwBased = weapon.m_AimModeDeltaVelocity and -1.5 or 1
    angles.p = angles.p + freelookCurrentAngles.p / 2.5 * mwBased
    angles.y = angles.y + freelookCurrentAngles.y / 2.5 * mwBased
end)

hook.Add("StartCommand", "liaFreelookStartCommand", function(client, cmd)
    if not client:IsPlayer() or not client:Alive() then return end
    if not canUseFreelook(client) or not lia.option.get("freelookBlockADS", true) then return end
    if not isHoldingFreelookBind(client) or isInSights(client) or isUsingThirdPersonCamera(client) then return end
    cmd:RemoveKey(IN_ATTACK)
end)

hook.Add("EntityEmitSound", "liaThirdPersonEntityEmitSound", function(data)
    local steps = {".stepleft", ".stepright"}
    if lia.option.get("thirdPersonEnabled", false) then
        if not IsValid(data.Entity) or not data.Entity:IsPlayer() then return end
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

hook.Add("SetupQuickMenu", "liaFreelookSetupQuickMenu", function(menu)
    menu:addCheck("Enable freelook", function(_, state)
        lia.option.set("freelookEnabled", state)
        if state then
            LocalPlayer():ChatPrint("Freelook enabled.")
        else
            LocalPlayer():ChatPrint("Freelook disabled.")
        end
    end, lia.option.get("freelookEnabled", false))
end)

concommand.Add("+freelook", function()
    if hook.Run("PreFreelookToggle", true) == false then return end
    freelooking = true
    hook.Run("FreelookToggled", true)
end)

concommand.Add("-freelook", function()
    if hook.Run("PreFreelookToggle", false) == false then return end
    freelooking = false
    hook.Run("FreelookToggled", false)
end)
