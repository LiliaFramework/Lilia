--[[
    Folder: Developer - Libraries
    File: lia.camera.md
]]
--[[
    Camera

    Camera helpers for Lilia third-person view, realistic first-person view, freelook input, and local-player visibility handling.
]]
--[[
    Overview:
        The camera library centralizes clientside camera behavior under `lia.camera`. It controls when third-person view may override the default view, builds collision-safe third-person camera positions, supports realistic first-person body rendering, applies freelook angle offsets, and hides local head/headwear geometry when needed for first-person body visibility.
]]
--[[
    Hooks:
        ShouldDisableThirdperson(Player client)

    Purpose:
        Allows plugins or modules to disable the Lilia third-person camera override for a client.

    Category:
        Camera

    Parameters:
        client (Player)
            The player whose third-person camera availability is being checked.

    Example Usage:
        ```lua
        hook.Add("ShouldDisableThirdperson", "liaExampleShouldDisableThirdperson", function(client)
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return true to block third-person view. Return nil or false to allow normal camera checks to continue.

    Realm:
        Client
]]
--[[
    Hooks:
        ShouldUseFreelook(Player client)

    Purpose:
        Allows plugins or modules to prevent freelook input processing for the local player.

    Category:
        Camera

    Parameters:
        client (Player)
            The local player whose freelook availability is being checked.

    Example Usage:
        ```lua
        hook.Add("ShouldUseFreelook", "liaExampleShouldUseFreelook", function(client)
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return false to block freelook input. Return nil or true to allow normal freelook checks to continue.

    Realm:
        Client
]]
--[[
    Hooks:
        PreFreelookToggle(boolean enabled)

    Purpose:
        Runs before the freelook console command changes freelook state.

    Category:
        Camera

    Parameters:
        enabled (boolean)
            True when freelook is about to be enabled, false when it is about to be disabled.

    Example Usage:
        ```lua
        hook.Add("PreFreelookToggle", "liaExamplePreFreelookToggle", function(enabled)
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return false to block the freelook state change. Return nil or true to allow it.

    Realm:
        Client
]]
--[[
    Hooks:
        FreelookToggled(boolean enabled)

    Purpose:
        Runs after the freelook console command changes freelook state.

    Category:
        Camera

    Parameters:
        enabled (boolean)
            True when freelook was enabled, false when it was disabled.

    Example Usage:
        ```lua
        hook.Add("FreelookToggled", "liaExampleFreelookToggled", function(enabled)
            print("[MyModule] handled FreelookToggled")
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        ThirdPersonToggled(boolean enabled)

    Purpose:
        Runs after the F4 third-person toggle changes the third-person option.

    Category:
        Camera

    Parameters:
        enabled (boolean)
            True when third-person view was enabled, false when it was disabled.

    Example Usage:
        ```lua
        hook.Add("ThirdPersonToggled", "liaExampleThirdPersonToggled", function(enabled)
            print("[MyModule] handled ThirdPersonToggled")
        end)
        ```

    Realm:
        Client
]]
lia.camera = lia.camera or {}
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng
local clmp = math.Clamp
crouchFactor = 0
local diff, fm, sm
local freelooking = false
local freelookX = 0
local freelookY = 0
local freelookInitialAngles = Angle()
local freelookCurrentAngles = Angle()
local freelookWasHolding = false
local zeroAngle = Angle()
local hiddenBoneScale = Vector(0.001, 0.001, 0.001)
local visibleBoneScale = Vector(1, 1, 1)
local hiddenBoneOffset = Vector(0, 0, 16384)
local visibleBoneOffset = Vector(0, 0, 0)
local maxValues = {
    height = 30,
    horizontal = 30,
    distance = 100
}

--[[
    Function: lia.camera.isCharacterMenuOpen

    Purpose:
        Checks whether any loading or character menu panel is currently open.

    Example Usage:
        ```lua
        local allowed = lia.camera.isCharacterMenuOpen()
        if allowed then
            print("lia.camera.isCharacterMenuOpen returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when a character-related UI panel is open.

    Realm:
        Client
]]
function lia.camera.isCharacterMenuOpen()
    return IsValid(lia.gui.loading) or IsValid(lia.gui.char) or IsValid(lia.gui.charCreate) or IsValid(lia.gui.character)
end

--[[
    Function: lia.camera.isUsingThirdPersonCamera

    Purpose:
        Checks whether the player is currently using the Lilia third-person camera override.

    Parameters:
        client (Player)
            The player whose view entity and camera eligibility should be checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.isUsingThirdPersonCamera()
        if allowed then
            print("lia.camera.isUsingThirdPersonCamera returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when the player's view entity is themselves and third-person override is available.

    Realm:
        Client
]]
function lia.camera.isUsingThirdPersonCamera(client)
    if not IsValid(client) then return false end
    return client:GetViewEntity() == client and lia.camera.canOverrideView(client)
end

--[[
    Function: lia.camera.shouldSuppressRealisticView

    Purpose:
        Determines whether realistic first-person view should be temporarily suppressed.

    Parameters:
        client (Player)
            The player whose input state should be checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.shouldSuppressRealisticView()
        if allowed then
            print("lia.camera.shouldSuppressRealisticView returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when realistic view should be blocked for the current frame.

    Realm:
        Client
]]
function lia.camera.shouldSuppressRealisticView(client)
    if not IsValid(client) then return false end
    return client:KeyDown(IN_ATTACK2)
end

--[[
    Function: lia.camera.canOverrideView

    Purpose:
        Determines whether the client may currently use the Lilia third-person camera override.

    Parameters:
        client (Player)
            The player whose camera state should be checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.canOverrideView()
        if allowed then
            print("lia.camera.canOverrideView returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when third-person view is enabled, configured, and not blocked by menus, vehicles, ragdolls, or hooks.

    Realm:
        Client
]]
function lia.camera.canOverrideView(client)
    if not IsValid(client) then return false end
    if lia.camera.isCharacterMenuOpen() then return false end
    if IsValid(client:GetVehicle()) then return false end
    if hook.Run("ShouldDisableThirdperson", client) == true then return false end
    local ragdoll = client:GetRagdollEntity()
    return lia.option.get("thirdPersonEnabled", false) and lia.config.get("ThirdPersonEnabled", true) and client:getChar() and not IsValid(ragdoll)
end

--[[
    Function: lia.camera.canUseRealisticView

    Purpose:
        Determines whether realistic first-person body view may be used for the local player.

    Parameters:
        client (Player)
            The local player being checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.canUseRealisticView()
        if allowed then
            print("lia.camera.canUseRealisticView returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when realistic view is enabled and no state blocks it.

    Realm:
        Client
]]
function lia.camera.canUseRealisticView(client)
    if not IsValid(client) or client ~= LocalPlayer() then return false end
    if client.IsInAdminEntityView then return false end
    if lia.camera.isCharacterMenuOpen() then return false end
    if not client:getChar() then return false end
    if client:InVehicle() then return false end
    if client:GetViewEntity() ~= client then return false end
    if lia.camera.isUsingThirdPersonCamera(client) then return false end
    if lia.camera.shouldSuppressRealisticView(client) then return false end
    return lia.option.get("realisticViewEnabled", false)
end

--[[
    Function: lia.camera.canUseFreelook

    Purpose:
        Determines whether freelook can be applied to the local player's current view.

    Parameters:
        client (Player)
            The local player being checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.canUseFreelook()
        if allowed then
            print("lia.camera.canUseFreelook returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when freelook is enabled and available.

    Realm:
        Client
]]
function lia.camera.canUseFreelook(client)
    if not IsValid(client) or client ~= LocalPlayer() then return false end
    if client.IsInAdminEntityView then return false end
    if lia.camera.isCharacterMenuOpen() then return false end
    if not client:getChar() then return false end
    if client:GetViewEntity() ~= client then return false end
    if lia.camera.isUsingThirdPersonCamera(client) then return false end
    return lia.option.get("freelookEnabled", false)
end

--[[
    Function: lia.camera.isInSights

    Purpose:
        Checks whether the player is aiming down sights with the active weapon.

    Parameters:
        client (Player)
            The player whose weapon and input state should be checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.isInSights()
        if allowed then
            print("lia.camera.isInSights returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when ADS blocking is enabled and the player is considered in sights.

    Realm:
        Client
]]
function lia.camera.isInSights(client)
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return client:KeyDown(IN_ATTACK2) end
    local inArcCWSights = weapon.ArcCW and ArcCW and weapon.GetState and weapon:GetState() == ArcCW.STATE_SIGHTS
    return lia.option.get("freelookBlockADS", true) and (client:KeyDown(IN_ATTACK2) or weapon.GetInSights and weapon:GetInSights() or inArcCWSights or weapon.GetIronSights and weapon:GetIronSights())
end

--[[
    Function: lia.camera.isHoldingFreelookBind

    Purpose:
        Checks whether the player is holding the freelook bind or the fallback walk key.

    Parameters:
        client (Player)
            The local player whose input state should be checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.isHoldingFreelookBind()
        if allowed then
            print("lia.camera.isHoldingFreelookBind returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when freelook input is currently being held.

    Realm:
        Client
]]
function lia.camera.isHoldingFreelookBind(client)
    if not input.LookupBinding("freelook") then return client:KeyDown(IN_WALK) end
    return freelooking
end

--[[
    Function: lia.camera.resetFreelookState

    Purpose:
        Resets freelook offsets and smoothed freelook angles back to neutral.

    Example Usage:
        ```lua
        lia.camera.resetFreelookState()
        ```

    Realm:
        Client
]]
function lia.camera.resetFreelookState()
    freelookX = 0
    freelookY = 0
    freelookCurrentAngles = zeroAngle
end

--[[
    Function: lia.camera.beginFreelook

    Purpose:
        Captures the player's current eye angles and marks freelook as actively held.

    Parameters:
        client (Player)
            The local player beginning freelook.

    Example Usage:
        ```lua
        lia.camera.beginFreelook()
        ```

    Realm:
        Client
]]
function lia.camera.beginFreelook(client)
    freelookInitialAngles = client:EyeAngles()
    freelookInitialAngles.r = 0
    freelookWasHolding = true
end

--[[
    Function: lia.camera.endFreelook

    Purpose:
        Ends active freelook and clears all freelook offsets.

    Example Usage:
        ```lua
        lia.camera.endFreelook()
        ```

    Realm:
        Client
]]
function lia.camera.endFreelook()
    freelookWasHolding = false
    lia.camera.resetFreelookState()
end

--[[
    Function: lia.camera.shouldDrawBodyForFreelook

    Purpose:
        Determines whether the local player's body should be drawn for freelook.

    Parameters:
        client (Player)
            The local player being checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.shouldDrawBodyForFreelook()
        if allowed then
            print("lia.camera.shouldDrawBodyForFreelook returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when freelook is active or still easing back toward center.

    Realm:
        Client
]]
function lia.camera.shouldDrawBodyForFreelook(client)
    if not lia.camera.canUseFreelook(client) then return false end
    return lia.camera.isHoldingFreelookBind(client) or math.abs(freelookCurrentAngles.p) >= 0.05 or math.abs(freelookCurrentAngles.y) >= 0.05
end

--[[
    Function: lia.camera.getFirstPersonHeadBones

    Purpose:
        Finds and caches head, neck, collar, clavicle, and upper chest bones for first-person hiding.

    Parameters:
        client (Player)
            The player model whose bones should be inspected.

    Example Usage:
        ```lua
        local result = lia.camera.getFirstPersonHeadBones()
        if istable(result) then
            PrintTable(result)
        end
        ```

    Returns:
        table
            A cached list of bone indexes that should be hidden in first-person body view.

    Realm:
        Client
]]
function lia.camera.getFirstPersonHeadBones(client)
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

--[[
    Function: lia.camera.getFirstPersonHeadBoneChildren

    Purpose:
        Collects child bones parented under a first-person head-related root bone.

    Parameters:
        client (Player)
            The player model whose skeleton should be inspected.

        rootBone (number)
            The root bone index used to find descendants.

    Example Usage:
        ```lua
        local result = lia.camera.getFirstPersonHeadBoneChildren()
        if istable(result) then
            PrintTable(result)
        end
        ```

    Returns:
        table
            A list of child bone indexes under the given root bone.

    Realm:
        Client
]]
function lia.camera.getFirstPersonHeadBoneChildren(client, rootBone)
    local children = {}
    local boneCount = (client:GetBoneCount() or 0) - 1
    for bone = 0, boneCount do
        local parent = client:GetBoneParent(bone)
        while parent and parent >= 0 do
            if parent == rootBone then
                children[#children + 1] = bone
                break
            end

            parent = client:GetBoneParent(parent)
        end
    end
    return children
end

--[[
    Function: lia.camera.getParentAttachmentNames

    Purpose:
        Builds and caches a lookup of parent attachment names for the player model.

    Parameters:
        client (Player)
            The player model whose attachment names should be cached.

    Example Usage:
        ```lua
        local result = lia.camera.getParentAttachmentNames()
        if istable(result) then
            PrintTable(result)
        end
        ```

    Returns:
        table
            A table keyed by attachment ID with lowercased attachment names.

    Realm:
        Client
]]
function lia.camera.getParentAttachmentNames(client)
    if client.liaFirstPersonAttachmentNames then return client.liaFirstPersonAttachmentNames end
    local attachmentNames = {}
    for _, attachment in ipairs(client:GetAttachments() or {}) do
        if attachment.id and attachment.name then attachmentNames[attachment.id] = attachment.name:lower() end
    end

    client.liaFirstPersonAttachmentNames = attachmentNames
    return attachmentNames
end

--[[
    Function: lia.camera.isHeadAttachmentName

    Purpose:
        Checks whether an attachment name appears to belong to head or face geometry.

    Parameters:
        name (string)
            The lowercased attachment name to inspect.

    Example Usage:
        ```lua
        local allowed = lia.camera.isHeadAttachmentName()
        if allowed then
            print("lia.camera.isHeadAttachmentName returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when the name matches a head, face, eye, mouth, or neck attachment.

    Realm:
        Client
]]
function lia.camera.isHeadAttachmentName(name)
    if not name or name == "" then return false end
    return name:find("head", 1, true) or name:find("eye", 1, true) or name:find("face", 1, true) or name:find("mouth", 1, true) or name:find("neck", 1, true)
end

--[[
    Function: lia.camera.isHeadwearModel

    Purpose:
        Checks whether a model path appears to represent headwear or face-worn geometry.

    Parameters:
        model (string)
            The model path to inspect.

    Example Usage:
        ```lua
        local allowed = lia.camera.isHeadwearModel()
        if allowed then
            print("lia.camera.isHeadwearModel returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when the model path matches known headwear terms.

    Realm:
        Client
]]
function lia.camera.isHeadwearModel(model)
    if not model or model == "" then return false end
    model = model:lower()
    return model:find("hat", 1, true) or model:find("mask", 1, true) or model:find("helmet", 1, true) or model:find("head", 1, true) or model:find("face", 1, true)
end

--[[
    Function: lia.camera.isHeadBodygroupName

    Purpose:
        Checks whether a bodygroup name appears to control headwear or face geometry.

    Parameters:
        name (string)
            The bodygroup name to inspect.

    Example Usage:
        ```lua
        local allowed = lia.camera.isHeadBodygroupName()
        if allowed then
            print("lia.camera.isHeadBodygroupName returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when the bodygroup should be hidden for first-person body view.

    Realm:
        Client
]]
function lia.camera.isHeadBodygroupName(name)
    if not name or name == "" then return false end
    name = name:lower()
    return name:find("head", 1, true) or name:find("face", 1, true) or name:find("mask", 1, true) or name:find("helmet", 1, true) or name:find("hat", 1, true) or name:find("gas", 1, true)
end

--[[
    Function: lia.camera.setFirstPersonHeadBodygroupsHidden

    Purpose:
        Hides or restores player bodygroups that contain headwear or face geometry.

    Parameters:
        client (Player)
            The player model whose bodygroups should be modified.

        hidden (boolean)
            Whether matching bodygroups should be hidden or restored.

    Example Usage:
        ```lua
        lia.camera.setFirstPersonHeadBodygroupsHidden()
        ```

    Realm:
        Client
]]
function lia.camera.setFirstPersonHeadBodygroupsHidden(client, hidden)
    if not IsValid(client) then return end
    client.liaFirstPersonHiddenBodygroups = client.liaFirstPersonHiddenBodygroups or {}
    if hidden then
        for _, bodygroup in ipairs(client:GetBodyGroups() or {}) do
            if bodygroup.id and lia.camera.isHeadBodygroupName(bodygroup.name) and client.liaFirstPersonHiddenBodygroups[bodygroup.id] == nil then
                client.liaFirstPersonHiddenBodygroups[bodygroup.id] = client:GetBodygroup(bodygroup.id)
                client:SetBodygroup(bodygroup.id, 0)
            end
        end
        return
    end

    for bodygroupID, originalValue in pairs(client.liaFirstPersonHiddenBodygroups) do
        client:SetBodygroup(bodygroupID, originalValue)
        client.liaFirstPersonHiddenBodygroups[bodygroupID] = nil
    end
end

--[[
    Function: lia.camera.shouldHideFirstPersonChildEntity

    Purpose:
        Determines whether a child entity attached to the player should be hidden in first-person body view.

    Parameters:
        client (Player)
            The player whose attached entities are being inspected.

        entity (Entity)
            The child entity being checked.

    Example Usage:
        ```lua
        local allowed = lia.camera.shouldHideFirstPersonChildEntity()
        if allowed then
            print("lia.camera.shouldHideFirstPersonChildEntity returned true for the current context.")
        end
        ```

    Returns:
        boolean
            True when the entity appears to be headwear, facewear, or nearby bonemerged head geometry.

    Realm:
        Client
]]
function lia.camera.shouldHideFirstPersonChildEntity(client, entity)
    if not IsValid(client) or not IsValid(entity) or entity == client then return false end
    if entity == client:GetActiveWeapon() or entity == client:GetViewModel() then return false end
    local parent = entity:GetParent()
    if not IsValid(parent) and entity.GetMoveParent then parent = entity:GetMoveParent() end
    if parent ~= client then return false end
    local attachmentID = entity.GetParentAttachment and entity:GetParentAttachment() or 0
    local attachmentName = lia.camera.getParentAttachmentNames(client)[attachmentID]
    if lia.camera.isHeadAttachmentName(attachmentName) then return true end
    if lia.camera.isHeadwearModel(entity:GetModel()) then return true end
    if entity:IsEffectActive(EF_BONEMERGE) and entity:GetPos():DistToSqr(client:EyePos()) <= 1600 then return true end
    return false
end

--[[
    Function: lia.camera.setFirstPersonHeadwearHidden

    Purpose:
        Hides or restores headwear entities parented to the player for first-person body view.

    Parameters:
        client (Player)
            The player whose child headwear entities should be modified.

        hidden (boolean)
            Whether matching child entities should be hidden or restored.

    Example Usage:
        ```lua
        lia.camera.setFirstPersonHeadwearHidden()
        ```

    Realm:
        Client
]]
function lia.camera.setFirstPersonHeadwearHidden(client, hidden)
    if not IsValid(client) then return end
    client.liaFirstPersonHiddenChildren = client.liaFirstPersonHiddenChildren or {}
    if hidden then
        for _, entity in ipairs(ents.GetAll()) do
            if lia.camera.shouldHideFirstPersonChildEntity(client, entity) and client.liaFirstPersonHiddenChildren[entity] == nil then
                client.liaFirstPersonHiddenChildren[entity] = entity:GetNoDraw()
                entity:SetNoDraw(true)
            end
        end
        return
    end

    for entity, wasNoDraw in pairs(client.liaFirstPersonHiddenChildren) do
        if IsValid(entity) then entity:SetNoDraw(wasNoDraw == true) end
        client.liaFirstPersonHiddenChildren[entity] = nil
    end
end

--[[
    Function: lia.camera.setFirstPersonHeadHidden

    Purpose:
        Hides or restores local first-person head, neck, head bodygroups, and headwear geometry.

    Parameters:
        client (Player)
            The player model to modify.

        hidden (boolean)
            Whether head-related geometry should be hidden.

    Example Usage:
        ```lua
        lia.camera.setFirstPersonHeadHidden()
        ```

    Realm:
        Client
]]
function lia.camera.setFirstPersonHeadHidden(client, hidden)
    if not IsValid(client) then return end
    if client.liaFirstPersonHeadHidden == hidden then return end
    client.liaFirstPersonHeadHidden = hidden
    local headBones = lia.camera.getFirstPersonHeadBones(client)
    local scale = hidden and hiddenBoneScale or visibleBoneScale
    local offset = hidden and hiddenBoneOffset or visibleBoneOffset
    for _, bone in ipairs(headBones) do
        client:ManipulateBoneScale(bone, scale)
        client:ManipulateBonePosition(bone, offset)
        for _, childBone in ipairs(lia.camera.getFirstPersonHeadBoneChildren(client, bone)) do
            client:ManipulateBoneScale(childBone, scale)
            client:ManipulateBonePosition(childBone, offset)
        end
    end

    lia.camera.setFirstPersonHeadBodygroupsHidden(client, hidden)
    lia.camera.setFirstPersonHeadwearHidden(client, hidden)
    client:InvalidateBoneCache()
end

--[[
    Function: lia.camera.applyFreelookToAngles

    Purpose:
        Applies the current freelook offset to a camera angle when freelook is available.

    Parameters:
        client (Player)
            The local player using freelook.

        angles (Angle)
            The base camera angles.

    Example Usage:
        ```lua
        local result = lia.camera.applyFreelookToAngles()
        if result then
            print(result)
        end
        ```

    Returns:
        Angle
            The adjusted camera angles.

    Realm:
        Client
]]
function lia.camera.applyFreelookToAngles(client, angles)
    if not lia.camera.canUseFreelook(client) then
        lia.camera.endFreelook()
        return angles
    end

    local smoothness = clmp(lia.option.get("freelookSmoothness", 1), 0.1, 2)
    freelookCurrentAngles = LerpAngle(0.15 * smoothness, freelookCurrentAngles, Angle(freelookY, -freelookX, 0))
    local shouldReset = not lia.camera.isHoldingFreelookBind(client) and math.abs(freelookCurrentAngles.p) < 0.05
    shouldReset = shouldReset or lia.camera.isInSights(client) and math.abs(freelookCurrentAngles.p) < 0.05
    shouldReset = shouldReset or not system.HasFocus() or lia.camera.isUsingThirdPersonCamera(client)
    if shouldReset then
        freelookInitialAngles = angles + freelookCurrentAngles
        lia.camera.endFreelook()
        return angles
    end
    return angles + freelookCurrentAngles
end

--[[
    Function: lia.camera.buildRealisticView

    Purpose:
        Builds a realistic first-person view from the player's eye attachment or eye position.

    Parameters:
        client (Player)
            The local player.

        origin (Vector)
            The original view origin.

        angles (Angle)
            The original view angles.

        fov (number)
            The current field of view.

    Example Usage:
        ```lua
        local result = lia.camera.buildRealisticView()
        if istable(result) then
            PrintTable(result)
        end
        ```

    Returns:
        table|nil
            A CalcView-compatible view table when realistic view can be built.

    Realm:
        Client
]]
function lia.camera.buildRealisticView(client, origin, angles, fov)
    if IsValid(lia.gui.menu) then return end
    if client:GetMoveType() == MOVETYPE_NOCLIP then return end
    local attachmentID = client:LookupAttachment("eyes")
    local attachment = attachmentID and client:GetAttachment(attachmentID)
    local viewOrigin
    local viewAngles = angles
    if attachment and attachment.Pos and attachment.Ang then
        viewOrigin = attachment.Pos + attachment.Ang:Forward() * 2 + attachment.Ang:Up() * 1.5
        viewAngles = attachment.Ang
    else
        viewOrigin = client:EyePos() + angles:Forward() * 2 + angles:Up() * 1.5
    end
    return {
        origin = viewOrigin,
        angles = lia.camera.applyFreelookToAngles(client, viewAngles),
        fov = fov or 90,
        drawviewer = true
    }
end

--[[
    Function: lia.camera.buildFreelookBodyView

    Purpose:
        Builds a first-person body view while freelook is active or easing back to center.

    Parameters:
        client (Player)
            The local player.

        pos (Vector)
            The original view position.

        ang (Angle)
            The original view angles.

        fov (number)
            The current field of view.

    Example Usage:
        ```lua
        local result = lia.camera.buildFreelookBodyView()
        if istable(result) then
            PrintTable(result)
        end
        ```

    Returns:
        table|nil
            A CalcView-compatible view table when body rendering should be forced.

    Realm:
        Client
]]
function lia.camera.buildFreelookBodyView(client, pos, ang, fov)
    if not lia.camera.shouldDrawBodyForFreelook(client) then return end
    local bodyView = lia.camera.buildRealisticView(client, pos, ang, fov)
    if bodyView then return bodyView end
    return {
        origin = pos,
        angles = lia.camera.applyFreelookToAngles(client, ang),
        fov = fov,
        drawviewer = true
    }
end

--[[
    Function: lia.camera.calcView

    Purpose:
        Builds the final Lilia camera view for third-person, realistic first-person, freelook body view, or the default first-person view.

    Parameters:
        client (Player)
            The player whose view is being calculated.

        pos (Vector)
            The original view position.

        ang (Angle)
            The original view angles.

        fov (number)
            The current field of view.

    Returns:
        table
            A CalcView-compatible table containing origin, angles, fov, and drawviewer when required.

    Example Usage:
        ```lua
        hook.Add("CalcView", "liaCameraCalcView", lia.camera.calcView)
        ```

    Realm:
        Client
]]
function lia.camera.calcView(client, pos, ang, fov)
    ft = FrameTime()
    local owner = LocalPlayer()
    if lia.camera.isUsingThirdPersonCamera(client) then
        lia.camera.setFirstPersonHeadHidden(client, false)
        if client:OnGround() and client:KeyDown(IN_DUCK) or client:Crouching() then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        curAng = owner.camAng or Angle(0, 0, 0)
        view = {}
        local viewOffset = client:GetViewOffset()
        local heightOffset = curAng:Up() * clmp(lia.option.get("thirdPersonHeight", 0), 0, maxValues.height)
        local horizontalOffset = curAng:Right() * clmp(lia.option.get("thirdPersonHorizontal", 0), -maxValues.horizontal, maxValues.horizontal)
        local crouchOffset = client:GetViewOffsetDucked() * 0.5 * crouchFactor
        traceData = {}
        traceData.start = client:GetPos() + viewOffset + heightOffset + horizontalOffset - crouchOffset
        traceData.endpos = traceData.start - curAng:Forward() * clmp(lia.option.get("thirdPersonDistance", 0), 0, maxValues.distance)
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

    if lia.camera.canUseRealisticView(client) then
        local realisticView = lia.camera.buildRealisticView(client, pos, ang, fov)
        if realisticView then
            lia.camera.setFirstPersonHeadHidden(client, true)
            return realisticView
        end
    end

    local freelookBodyView = lia.camera.buildFreelookBodyView(client, pos, ang, fov)
    if freelookBodyView then
        lia.camera.setFirstPersonHeadHidden(client, true)
        return freelookBodyView
    end

    ang = lia.camera.applyFreelookToAngles(client, ang)
    lia.camera.setFirstPersonHeadHidden(client, false)
    return {
        origin = pos,
        angles = ang,
        fov = fov
    }
end

hook.Add("CreateMove", "liaThirdPersonCreateMove", function(cmd)
    local owner = LocalPlayer()
    if lia.camera.isUsingThirdPersonCamera(owner) and owner:GetMoveType() ~= MOVETYPE_NOCLIP then
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
    if lia.camera.isUsingThirdPersonCamera(owner) then
        owner.camAng.p = clmp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
        owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)
        return true
    end

    if not lia.camera.canUseFreelook(owner) then return end
    if hook.Run("ShouldUseFreelook", owner) == false then return end
    local isHolding = lia.camera.isHoldingFreelookBind(owner)
    if not isHolding or lia.camera.isInSights(owner) or lia.camera.isUsingThirdPersonCamera(owner) then
        if freelookWasHolding then lia.camera.endFreelook() end
        return
    end

    if not freelookWasHolding then lia.camera.beginFreelook(owner) end
    freelookInitialAngles.z = 0
    cmd:SetViewAngles(freelookInitialAngles)
    freelookX = clmp(freelookX + x * 0.02, -lia.option.get("freelookLimitHorizontal", 90), lia.option.get("freelookLimitHorizontal", 90))
    freelookY = clmp(freelookY + y * 0.02, -lia.option.get("freelookLimitVertical", 65), lia.option.get("freelookLimitVertical", 65))
    return true
end)

hook.Add("ShouldDrawLocalPlayer", "liaThirdPersonShouldDrawLocalPlayer", function()
    local client = LocalPlayer()
    if not IsValid(client) or IsValid(client:GetVehicle()) then return end
    if lia.camera.isUsingThirdPersonCamera(client) then return true end
    if lia.camera.canUseRealisticView(client) then return true end
    if lia.camera.shouldDrawBodyForFreelook(client) then return true end
end)

hook.Add("CalcViewModelView", "liaFreelookCalcViewModelView", function(weapon, _, _, _, _, angles)
    local client = LocalPlayer()
    if not lia.camera.canUseFreelook(client) then return end
    local mwBased = weapon.m_AimModeDeltaVelocity and -1.5 or 1
    angles.p = angles.p + freelookCurrentAngles.p / 2.5 * mwBased
    angles.y = angles.y + freelookCurrentAngles.y / 2.5 * mwBased
end)

hook.Add("StartCommand", "liaFreelookStartCommand", function(client, cmd)
    if not client:IsPlayer() or not client:Alive() then return end
    if not lia.camera.canUseFreelook(client) or not lia.option.get("freelookBlockADS", true) then return end
    if not lia.camera.isHoldingFreelookBind(client) or lia.camera.isInSights(client) or lia.camera.isUsingThirdPersonCamera(client) then return end
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
