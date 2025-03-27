local MODULE = MODULE
local ScrW, ScrH = ScrW, ScrH
local RealTime, FrameTime = RealTime, FrameTime
local mathApproach = math.Approach
local IsValid = IsValid
local toScreen = FindMetaTable("Vector").ToScreen
local paintedEntitiesCache, lastTrace, charInfo, lastEntity = {}, {}, {}, nil
local NoDrawCrosshairWeapon = {"weapon_crowbar", "weapon_stunstick", "weapon_bugbait"}
local nextUpdate = 0
local healthPercent = {
    [0.2] = {"Critical Condition", Color(192, 57, 43)},
    [0.4] = {"Serious Injury", Color(231, 76, 60)},
    [0.6] = {"Moderate Injury", Color(255, 152, 0)},
    [0.8] = {"Minor Injury", Color(255, 193, 7)},
    [1.0] = {"Healthy", Color(46, 204, 113)}
}

local function canDrawAmmo(wpn)
    if IsValid(wpn) and wpn.DrawAmmo ~= false and lia.config.get("AmmoDrawEnabled", false) then return true end
end

local function drawAmmo(wpn)
    local client = LocalPlayer()
    if not IsValid(wpn) then return end
    local clip = wpn:Clip1()
    local count = client:GetAmmoCount(wpn:GetPrimaryAmmoType())
    local sec = client:GetAmmoCount(wpn:GetSecondaryAmmoType())
    local x, y = ScrW() - 80, ScrH() - 80
    if sec > 0 then
        lia.util.drawBlurAt(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 64, 64)
        lia.util.drawText(sec, x + 32, y + 32, nil, 1, 1, "liaBigFont")
    end

    if wpn:GetClass() ~= "weapon_slam" and (clip > 0 or count > 0) then
        x = x - (sec > 0 and 144 or 64)
        lia.util.drawBlurAt(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 128, 64)
        lia.util.drawText(clip == -1 and count or clip .. "/" .. count, x + 64, y + 32, nil, 1, 1, "liaBigFont")
    end
end

local function canDrawCrosshair()
    local client = LocalPlayer()
    local rag = Entity(client:getLocalVar("ragdoll", 0))
    local wpn = client:GetActiveWeapon()
    if not client:getChar() then return false end
    if IsValid(wpn) then
        local cl = wpn:GetClass()
        if cl == "gmod_tool" or string.find(cl, "lia_") or string.find(cl, "detector_") then return true end
        if not NoDrawCrosshairWeapon[cl] and lia.config.get("CrosshairEnabled", true) and client:Alive() and client:getChar() and not IsValid(rag) and wpn and not (g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible()) then return true end
    end
end

local function drawCrosshair()
    local client = LocalPlayer()
    local t = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    if t.HitPos then
        local p = t.HitPos:ToScreen()
        local s = 3
        if p then
            p[1] = math.Round(p[1] or 0)
            p[2] = math.Round(p[2] or 0)
            draw.RoundedBox(0, p[1] - s / 2, p[2] - s / 2, s, s, color_white)
            s = s - 2
            draw.RoundedBox(0, p[1] - s / 2, p[2] - s / 2, s, s, color_white)
        end
    end
end

local function RenderEntities()
    local client = LocalPlayer()
    if client.getChar and client:getChar() then
        local ft = FrameTime()
        local rt = RealTime()
        if nextUpdate < rt then
            nextUpdate = rt + 0.5
            lastTrace.start = client:GetShootPos()
            lastTrace.endpos = lastTrace.start + client:GetAimVector() * 160
            lastTrace.filter = client
            lastTrace.mins = Vector(-4, -4, -4)
            lastTrace.maxs = Vector(4, 4, 4)
            lastTrace.mask = MASK_SHOT_HULL
            lastEntity = util.TraceHull(lastTrace).Entity
            if IsValid(lastEntity) and hook.Run("ShouldDrawEntityInfo", lastEntity) then paintedEntitiesCache[lastEntity] = true end
        end

        for ent, drawing in pairs(paintedEntitiesCache) do
            if IsValid(ent) then
                local goal = drawing and 255 or 0
                local a = mathApproach(ent.liaAlpha or 0, goal, ft * 1000)
                if lastEntity ~= ent then paintedEntitiesCache[ent] = false end
                if a > 0 then
                    local pl = ent.getNetVar and ent:getNetVar("player")
                    if IsValid(pl) then
                        local p = toScreen(ent:LocalToWorld(ent:OBBCenter()))
                        hook.Run("DrawEntityInfo", pl, a, p)
                    elseif ent.onDrawEntityInfo then
                        ent.onDrawEntityInfo(ent, a)
                    else
                        hook.Run("DrawEntityInfo", ent, a)
                    end
                end

                ent.liaAlpha = a
                if a == 0 and goal == 0 then paintedEntitiesCache[ent] = nil end
            else
                paintedEntitiesCache[ent] = nil
            end
        end
    end
end

function MODULE:ShouldDrawEntityInfo(e)
    if IsValid(e) then
        if e:IsPlayer() and e:getChar() then
            if e:isNoClipping() then return false end
            if e:GetNoDraw() then return false end
            return true
        end

        if IsValid(e.getNetVar and e:getNetVar("player")) then return e == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end
        if e.DrawEntityInfo then return true end
        if e.onShouldDrawEntityInfo then return e:onShouldDrawEntityInfo() end
        return true
    end
    return false
end

function MODULE:GetInjuredText(c)
    local h = c:Health()
    local mh = c:GetMaxHealth() or 100
    local p = h / mh
    local r = nil
    for threshold, data in pairs(healthPercent) do
        if p <= threshold then
            r = data
            break
        end
    end

    if not r then r = healthPercent[1.0] end
    return r
end

function MODULE:DrawCharInfo(c, _, info)
    local injuredText = hook.Run("GetInjuredText", c)
    if injuredText then
        local text, col = injuredText[1], injuredText[2]
        if text and col then info[#info + 1] = {L(text), col} end
    end
end

function MODULE:DrawEntityInfo(e, a, pos)
    if not e.IsPlayer(e) then return end
    if hook.Run("ShouldDrawPlayerInfo", e) == false then return end
    local ch = e.getChar(e)
    if not ch then return end
    pos = pos or toScreen(e.GetPos(e) + (e.Crouching(e) and Vector(0, 0, 48) or Vector(0, 0, 80)))
    local x, y = pos.x, pos.y
    charInfo = {}
    if e.widthCache ~= lia.config.get("descriptionWidth", 0.5) then
        e.widthCache = lia.config.get("descriptionWidth", 0.5)
        e.liaNameCache, e.liaDescCache = nil, nil
    end

    e.liaNameCache = nil
    e.liaDescCache = nil
    local name = hook.Run("GetDisplayedName", e, nil) or ch.getName(ch)
    if name ~= e.liaNameCache then
        e.liaNameCache = name
        if #name > 250 then name = name:sub(1, 250) .. "..." end
        e.liaNameLines = lia.util.wrapText(name, ScrW() * e.widthCache, "liaSmallFont")
    end

    for i = 1, #e.liaNameLines do
        charInfo[#charInfo + 1] = {e.liaNameLines[i], color_white}
    end

    local desc = hook.Run("GetDisplayedDescription", e, true) or ch.getDesc(ch)
    if desc ~= e.liaDescCache then
        e.liaDescCache = desc
        if #desc > 250 then desc = desc:sub(1, 250) .. "..." end
        e.liaDescLines = lia.util.wrapText(desc, ScrW() * e.widthCache, "liaSmallFont")
    end

    for i = 1, #e.liaDescLines do
        charInfo[#charInfo + 1] = {e.liaDescLines[i]}
    end

    hook.Run("DrawCharInfo", e, ch, charInfo)
    for i = 1, #charInfo do
        local info = charInfo[i]
        local _, ty = lia.util.drawText(info[1]:gsub("#", "\226\128\139#"), x, y, ColorAlpha(info[2] or color_white, a), 1, 1, "liaSmallFont")
        y = y + ty
    end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() and client:getChar() then
        local wpn = client:GetActiveWeapon()
        if canDrawAmmo(wpn) then drawAmmo(wpn) end
        if canDrawCrosshair() then drawCrosshair() end
    end
end

function MODULE:HUDPaintBackground()
    if not is64Bits() then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * 0.5, ScrH() * 0.97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    RenderEntities()
end

function MODULE:TooltipInitialize(var, panel)
    if panel.liaToolTip or panel.itemID then
        var.markupObject = lia.markup.parse(var:GetText(), ScrW() * 0.15)
        var:SetText("")
        var:SetWide(math.max(ScrW() * 0.15, 200) + 12)
        var:SetHeight(var.markupObject:getHeight() + 12)
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isItemTooltip = true
    end
end

function MODULE:TooltipPaint(var, w, h)
    if var.isItemTooltip then
        lia.util.drawBlur(var, 2, 2)
        surface.SetDrawColor(0, 0, 0, 230)
        surface.DrawRect(0, 0, w, h)
        if var.markupObject then var.markupObject:draw(6, 8) end
        return true
    end
end

function MODULE:TooltipLayout(var)
    if var.isItemTooltip then return true end
end

timer.Create("liaVignetteChecker", 1, 0, function()
    local client = LocalPlayer()
    if IsValid(client) then
        local d = {}
        d.start = client:GetPos()
        d.endpos = d.start + Vector(0, 0, 768)
        d.filter = client
        local tr = util.TraceLine(d)
        if tr and tr.Hit then
            vignetteAlphaGoal = 80
        else
            vignetteAlphaGoal = 0
        end
    end
end)

lia.option.add("BarsAlwaysVisible", "Bars Always Visible", "Make all bars always visible", false, nil, {
    category = "General"
})
