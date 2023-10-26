--------------------------------------------------------------------------------------------------------------------------
paintedEntitiesCache = {}
--------------------------------------------------------------------------------------------------------------------------
local hasVignetteMaterial = lia.util.getMaterial("lilia/gui/vignette.png") ~= "___error"
--------------------------------------------------------------------------------------------------------------------------
local charInfo = {}
--------------------------------------------------------------------------------------------------------------------------
local nextUpdate = 0
--------------------------------------------------------------------------------------------------------------------------
local lastTrace = {}
--------------------------------------------------------------------------------------------------------------------------
local lastEntity
--------------------------------------------------------------------------------------------------------------------------
local toScreen = FindMetaTable("Vector").ToScreen
--------------------------------------------------------------------------------------------------------------------------
local DescWidth = CreateClientConVar("lia_hud_descwidth", 0.5, true, false)
--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDShouldDraw(element)
    if lia.config.HiddenHUDElements[element] then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanDrawAmmoHUD()
    return lia.config.AmmoDrawEnabled
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShouldHideBars()
    return lia.config.BarsDisabled
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDDrawTargetID()
    return false
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDDrawPickupHistory()
    return false
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDAmmoPickedUp()
    return false
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawDeathNotice()
    return false
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShouldDrawCrosshair()
    local wep = LocalPlayer():GetActiveWeapon()
    if wep and wep:IsValid() then
        local className = wep:GetClass()
        if className == "gmod_tool" or string.find(className, "lia_") or string.find(className, "detector_") then return true end

        return lia.config.CrosshairEnabled
    end

    return lia.config.CrosshairEnabled
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDPaintBackground()
    local localPlayer = LocalPlayer()
    if not localPlayer.getChar(localPlayer) then return end
    local frameTime = FrameTime()
    if hasVignetteMaterial and lia.config.Vignette then
        self:HUDPaintBackgroundVignette()
    end

    if nextUpdate < RealTime() then
        nextUpdate = RealTime() + 0.5
        lastTrace.start = localPlayer.GetShootPos(localPlayer)
        lastTrace.endpos = lastTrace.start + localPlayer:GetAimVector() * 160
        lastTrace.filter = localPlayer
        lastTrace.mins = Vector(-4, -4, -4)
        lastTrace.maxs = Vector(4, 4, 4)
        lastTrace.mask = MASK_SHOT_HULL
        lastEntity = util.TraceHull(lastTrace).Entity
        if IsValid(lastEntity) and hook.Run("ShouldDrawEntityInfo", lastEntity) then
            paintedEntitiesCache[lastEntity] = true
        end
    end

    for entity, drawing in pairs(paintedEntitiesCache) do
        if IsValid(entity) then
            local goal = drawing and 255 or 0
            local alpha = math.Approach(entity.liaAlpha or 0, goal, frameTime * 1000)
            if lastEntity ~= entity then
                paintedEntitiesCache[entity] = false
            end

            if alpha > 0 then
                local client = entity.getNetVar(entity, "player")
                if IsValid(client) then
                    local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
                    hook.Run("DrawEntityInfo", client, alpha, position)
                elseif entity.onDrawEntityInfo then
                    entity.onDrawEntityInfo(entity, alpha)
                else
                    hook.Run("DrawEntityInfo", entity, alpha)
                end
            end

            entity.liaAlpha = alpha
            if alpha == 0 and goal == 0 then
                paintedEntitiesCache[entity] = nil
            end
        else
            paintedEntitiesCache[entity] = nil
        end
    end

    local weapon = localPlayer:GetActiveWeapon()
    if hook.Run("CanDrawAmmoHUD", weapon) ~= false then
        hook.Run("DrawAmmoHUD", weapon)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanDrawAmmoHUD(weapon)
    if IsValid(weapon) and weapon.DrawAmmo ~= false and LocalPlayer():Alive() then return true end

    return false
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawAmmoHUD(weapon)
    if not IsValid(weapon) then return end
    local localPlayer = LocalPlayer()
    local clip = weapon:Clip1()
    local count = localPlayer:GetAmmoCount(weapon:GetPrimaryAmmoType())
    local secondary = localPlayer:GetAmmoCount(weapon:GetSecondaryAmmoType())
    local x, y = ScrW() - 80, ScrH() - 80
    if secondary > 0 then
        lia.util.drawBlurAt(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 64, 64)
        lia.util.drawText(secondary, x + 32, y + 32, nil, 1, 1, "liaBigFont")
    end

    if weapon.GetClass(weapon) ~= "weapon_slam" and clip > 0 or count > 0 then
        x = x - (secondary > 0 and 144 or 64)
        lia.util.drawBlurAt(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 128, 64)
        lia.util.drawText(clip == -1 and count or clip .. "/" .. count, x + 64, y + 32, nil, 1, 1, "liaBigFont")
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawCharInfo(client, character, info)
    local injText, injColor = hook.Run("GetInjuredText", client)
    if injText then
        info[#info + 1] = {L(injText), injColor}
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawEntityInfo(entity, alpha, position)
    if not entity.IsPlayer(entity) then return end
    if hook.Run("ShouldDrawPlayerInfo", entity) == false then return end
    local character = entity.getChar(entity)
    if not character then return end
    position = position or toScreen(entity.GetPos(entity) + (entity.Crouching(entity) and Vector(0, 0, 48) or Vector(0, 0, 80)))
    local x, y = position.x, position.y
    local ty = 0
    charInfo = {}
    if entity.widthCache ~= DescWidth:GetFloat() then
        entity.widthCache = DescWidth:GetFloat()
        entity.liaNameCache = nil
        entity.liaDescCache = nil
    end

    entity.liaNameCache = nil
    entity.liaDescCache = nil
    local name = hook.Run("GetDisplayedName", entity, nil) or character.getName(character)
    if name ~= entity.liaNameCache then
        entity.liaNameCache = name
        if name:len() > 250 then
            name = name:sub(1, 250) .. "..."
        end

        entity.liaNameLines = lia.util.wrapText(name, ScrW() * entity.widthCache, "liaSmallFont")
    end

    for i = 1, #entity.liaNameLines do
        charInfo[#charInfo + 1] = {entity.liaNameLines[i], team.GetColor(entity.Team(entity))}
    end

    local description = hook.Run("GetDisplayedDescription", entity, "hud") or character.getDesc(character)
    if description ~= entity.liaDescCache then
        entity.liaDescCache = description
        if description:len() > 250 then
            description = description:sub(1, 250) .. "..."
        end

        entity.liaDescLines = lia.util.wrapText(description, ScrW() * entity.widthCache, "liaSmallFont")
    end

    for i = 1, #entity.liaDescLines do
        charInfo[#charInfo + 1] = {entity.liaDescLines[i]}
    end

    hook.Run("DrawCharInfo", entity, character, charInfo)
    for i = 1, #charInfo do
        local info = charInfo[i]
        _, ty = lia.util.drawText(info[1]:gsub("#", "\226\128\139#"), x, y, ColorAlpha(info[2] or color_white, alpha), 1, 1, "liaSmallFont")
        y = y + ty
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShouldDrawEntityInfo(entity)
    if entity:IsPlayer() and entity:IsNoClipping() then return false end
    if entity:IsPlayer() and entity:IsBot() then return true end
    if entity:IsPlayer() and entity:getChar() and entity:GetNoDraw() ~= true then return true end
    if entity:IsPlayer() or IsValid(entity:getNetVar("player")) then return entity == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end
    if entity.DrawEntityInfo then return true end
    if entity.onShouldDrawEntityInfo then return entity:onShouldDrawEntityInfo() end
end
--------------------------------------------------------------------------------------------------------------------------