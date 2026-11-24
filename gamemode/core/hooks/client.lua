local GM = GM or GAMEMODE
local RealTime, FrameTime = RealTime, FrameTime
local mathApproach = math.Approach
local IsValid = IsValid
local toScreen = FindMetaTable("Vector").ToScreen
local paintedEntitiesCache = {}
local lastTrace = {
    mins = Vector(-4, -4, -4),
    maxs = Vector(4, 4, 4),
    mask = MASK_SHOT_HULL,
    filter = nil,
    start = nil,
    endpos = nil
}

local VOICE_WHISPERING = "whispering"
local VOICE_TALKING = "talking"
local VOICE_YELLING = "yelling"
local hidden = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudHistoryResource"] = true,
    ["CHudCrosshair"] = true,
    ["CHudChat"] = true
}

local VoiceRanges = {
    [VOICE_WHISPERING] = 120,
    [VOICE_TALKING] = 300,
    [VOICE_YELLING] = 600,
}

local getEntityInfoMaxDistance
local falloverBlackoutAlpha = 0
local lastEntity
local nextUpdate = 0
local NoDrawCrosshairWeapon = {
    weapon_crowbar = true,
    weapon_stunstick = true,
    weapon_bugbait = true
}

local ForceDrawCrosshairWeapon = {
    gmod_tool = true,
    lia_adminstick = true,
    lia_keys = true,
    weapon_physgun = true,
    weapon_physcannon = true
}

local function getHUDFont(size, suffix)
    return "HUDFont." .. tostring(size) .. (suffix or "")
end

local function isToolgunHUDHidden(client)
    local weapon = IsValid(client) and client:GetActiveWeapon() or nil
    return IsValid(weapon) and weapon:GetClass() == "gmod_tool"
end

local function easeOutQuint(fraction)
    fraction = math.Clamp(fraction or 0, 0, 1)
    return 1 - (1 - fraction) ^ 5
end

local function appendPlayerInfoRow(rows, entry)
    if entry == nil then return end
    if istable(entry) then
        if entry.divider then
            rows[#rows + 1] = {
                divider = true
            }
            return
        end

        if entry.section or entry.category then
            rows[#rows + 1] = {
                section = entry.section or entry.category
            }
            return
        end

        local label = entry.label or entry.name or entry.key
        local value = entry.value or entry[2]
        local text = entry.text or entry[1]
        if label and value ~= nil then
            rows[#rows + 1] = {
                label = tostring(label),
                value = tostring(value)
            }
        elseif text ~= nil and tostring(text) ~= "" then
            rows[#rows + 1] = {
                text = tostring(text)
            }
        end
        return
    end

    local text = tostring(entry)
    if text ~= "" then
        rows[#rows + 1] = {
            text = text
        }
    end
end

local function getPlayerInfoMeasureText(entry)
    if not istable(entry) then return tostring(entry or "") end
    if entry.divider then return "" end
    if entry.section or entry.category then return tostring(entry.section or entry.category or "") end
    if entry.label and entry.value ~= nil then return tostring(entry.label) .. " " .. tostring(entry.value) end
    if entry.text ~= nil then return tostring(entry.text) end
    if entry[1] ~= nil and entry[2] ~= nil then return tostring(entry[1]) .. " " .. tostring(entry[2]) end
    return tostring(entry[1] or "")
end

local function trimPlayerInfoText(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function hasVisiblePlayerInfoRows(rows)
    if not istable(rows) then return false end
    for i = 1, #rows do
        local row = rows[i]
        if istable(row) then
            if row.divider then return true end
            if trimPlayerInfoText(row.text) ~= "" or trimPlayerInfoText(row.label) ~= "" or trimPlayerInfoText(row.value) ~= "" then return true end
        elseif trimPlayerInfoText(row) ~= "" then
            return true
        end
    end
    return false
end

local function estimatePlayerInfoTooltipHeight(title, sections, titleFont, sectionFont, rowHeight, padding, sectionGap)
    surface.SetFont(titleFont)
    local _, titleHeight = 0, 0
    local titleText = trimPlayerInfoText(title)
    if titleText ~= "" then _, titleHeight = surface.GetTextSize(string.upper(titleText)) end
    local totalHeight = padding
    if titleText ~= "" then totalHeight = totalHeight + math.max(titleHeight, 18) + 14 end
    for i = 1, #sections do
        local section = sections[i]
        local sectionHeight = 0
        local sectionTitle = trimPlayerInfoText(section.title)
        if sectionTitle ~= "" then
            surface.SetFont(sectionFont)
            local _, sectionTextHeight = surface.GetTextSize(string.upper(sectionTitle))
            sectionHeight = sectionHeight + math.max(sectionTextHeight, 16) + 10
        end

        for j = 1, #(section.rows or {}) do
            local row = section.rows[j]
            if istable(row) and row.divider then
                sectionHeight = sectionHeight + 10
            else
                sectionHeight = sectionHeight + rowHeight
            end
        end

        totalHeight = totalHeight + sectionHeight
        if i < #sections then totalHeight = totalHeight + sectionGap end
    end
    return totalHeight + padding
end

local function buildPlayerInfoSections(descriptionRows, infoRows, defaultInfoTitle)
    local sections = {}
    if hasVisiblePlayerInfoRows(descriptionRows) then
        sections[#sections + 1] = {
            title = "Description",
            rows = descriptionRows
        }
    end

    local currentInfoSection
    local function pushCurrentInfoSection()
        if currentInfoSection and hasVisiblePlayerInfoRows(currentInfoSection.rows) then sections[#sections + 1] = currentInfoSection end
    end

    if istable(infoRows) then
        for i = 1, #infoRows do
            local row = infoRows[i]
            if istable(row) and (row.section or row.category) then
                pushCurrentInfoSection()
                currentInfoSection = {
                    title = trimPlayerInfoText(row.section or row.category),
                    rows = {}
                }
            else
                if not currentInfoSection then
                    currentInfoSection = {
                        title = defaultInfoTitle or "Information",
                        rows = {}
                    }
                end

                currentInfoSection.rows[#currentInfoSection.rows + 1] = row
            end
        end
    end

    pushCurrentInfoSection()
    return sections
end

local function fitDescriptionLine(text, maxWidth, font, suffix)
    surface.SetFont(font)
    local trimmed = string.Trim(text or "")
    local candidate = trimmed .. (suffix or "")
    while trimmed ~= "" and surface.GetTextSize(candidate) > maxWidth do
        trimmed = string.Trim(trimmed:sub(1, -2))
        candidate = trimmed .. (suffix or "")
    end
    return candidate ~= "" and candidate or (suffix or "")
end

local function wrapPlayerDescription(text, maxWidth, font, maxLines)
    local source = string.Trim(tostring(text or ""):gsub("%s+", " "))
    if source == "" then return {""} end
    surface.SetFont(font)
    local lines = {}
    local remaining = source
    local truncated = false
    while remaining ~= "" and #lines < maxLines do
        if surface.GetTextSize(remaining) <= maxWidth then
            lines[#lines + 1] = remaining
            remaining = ""
            break
        end

        local lastFitIndex, lastSpaceIndex
        for i = 1, #remaining do
            local chunk = remaining:sub(1, i)
            if surface.GetTextSize(chunk) <= maxWidth then
                lastFitIndex = i
                if chunk:sub(-1):match("%s") then lastSpaceIndex = i end
            else
                break
            end
        end

        if not lastFitIndex then
            lines[#lines + 1] = fitDescriptionLine(remaining:sub(1, 1), maxWidth, font)
            remaining = remaining:sub(2):gsub("^%s+", "")
        else
            local splitIndex = lastSpaceIndex or lastFitIndex
            lines[#lines + 1] = string.Trim(remaining:sub(1, splitIndex))
            remaining = remaining:sub(splitIndex + 1):gsub("^%s+", "")
        end
    end

    if remaining ~= "" then truncated = true end
    if truncated and #lines > 0 then lines[#lines] = fitDescriptionLine(lines[#lines], maxWidth, font, "(...)") end
    return lines
end

local function canDrawAmmo(wpn)
    if not IsValid(wpn) or wpn.DrawAmmo == false then return false end
    local hookResult = hook.Run("ShouldDrawAmmo", wpn)
    if hookResult ~= nil then return hookResult end
    return lia.config.get("AmmoDrawEnabled", false)
end

local function drawAmmo(wpn)
    local client = LocalPlayer()
    if not IsValid(wpn) then return end
    local clip = wpn:Clip1()
    local count = client:GetAmmoCount(wpn:GetPrimaryAmmoType())
    local sec = client:GetAmmoCount(wpn:GetSecondaryAmmoType())
    local x, y = ScrW() - 80, ScrH() - 80
    if sec > 0 then
        local shadowIntensity = 8
        local shadowBlur = 12
        lia.derma.rect(x, y, 64, 64):Rad(6):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(x, y, 64, 64):Radii(6, 6, 6, 6):Color(Color(25, 28, 35, 250)):Draw()
        lia.util.drawText(sec, x + 32, y + 32, lia.color.theme.text, 1, 1, getHUDFont(36))
    end

    if wpn:GetClass() ~= "weapon_slam" and (clip > 0 or count > 0) then
        x = x - (sec > 0 and 144 or 64)
        local ammoText = clip == -1 and count or clip .. "/" .. count
        local shadowIntensity = 8
        local shadowBlur = 12
        lia.derma.rect(x, y, 128, 64):Rad(6):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(x, y, 128, 64):Radii(6, 6, 6, 6):Color(Color(25, 28, 35, 250)):Draw()
        lia.util.drawText(ammoText, x + 64, y + 32, lia.color.theme.text, 1, 1, getHUDFont(36))
    end
end

local function canDrawCrosshair()
    local client = LocalPlayer()
    local rag = client:GetRagdollEntity()
    local wpn = client:GetActiveWeapon()
    if not client:getChar() or not IsValid(wpn) then return false end
    local hookResult = hook.Run("ShouldDrawCrosshair", client, wpn)
    if hookResult ~= nil then return hookResult end
    if ForceDrawCrosshairWeapon[wpn:GetClass()] then return true end
    if not lia.config.get("CrosshairEnabled", true) then return false end
    local cl = wpn:GetClass()
    if cl == "gmod_tool" or string.find(cl, "lia_") or string.find(cl, "detector_") then return true end
    if NoDrawCrosshairWeapon[cl] then return false end
    if not client:Alive() then return false end
    if IsValid(rag) then return false end
    if g_ContextMenu:IsVisible() then return false end
    if IsValid(lia.gui.character) and lia.gui.character:IsVisible() then return false end
    return true
end

local function drawCrosshair()
    local client = LocalPlayer()
    local trace = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    if trace.HitPos then
        local p = trace.HitPos:ToScreen()
        if p then
            local s = 3
            draw.RoundedBox(0, math.Round(p.x - s / 2), math.Round(p.y - s / 2), s, s, color_white)
            s = s - 2
            draw.RoundedBox(0, math.Round(p.x - s / 2), math.Round(p.y - s / 2), s, s, color_white)
        end
    end
end

local function RenderEntities()
    local client = LocalPlayer()
    if client:getChar() then
        local ft = FrameTime()
        local rt = RealTime()
        if nextUpdate < rt then
            nextUpdate = rt + 0.01
            local hoverTrace = client:GetEyeTraceNoCursor()
            local hoveredEntity = IsValid(hoverTrace.Entity) and hoverTrace.Entity or nil
            local hoverDistance = hoveredEntity and client:GetShootPos():Distance(hoverTrace.HitPos) or math.huge
            if IsValid(hoveredEntity) and hoverDistance > getEntityInfoMaxDistance(hoveredEntity) then hoveredEntity = nil end
            if not hoveredEntity or hoverDistance > 380 then
                lastTrace.start = client:GetShootPos()
                lastTrace.endpos = lastTrace.start + client:GetAimVector() * 380
                lastTrace.filter = client
                lastTrace.mins = Vector(-4, -4, -4)
                lastTrace.maxs = Vector(4, 4, 4)
                lastTrace.mask = MASK_SHOT_HULL
                hoveredEntity = util.TraceHull(lastTrace).Entity
                if IsValid(hoveredEntity) then
                    local hitPosition = hoveredEntity:NearestPoint(client:GetShootPos())
                    if client:GetShootPos():Distance(hitPosition) > getEntityInfoMaxDistance(hoveredEntity) then hoveredEntity = nil end
                end
            end

            lastEntity = hoveredEntity
            if IsValid(lastEntity) then
                local shouldDraw = hook.Run("ShouldDrawEntityInfo", lastEntity)
                if shouldDraw then paintedEntitiesCache[lastEntity] = true end
            end
        end

        for ent, drawing in pairs(paintedEntitiesCache) do
            if IsValid(ent) then
                local goal = drawing and 255 or 0
                local fadeSpeed = drawing and 255 or 1200
                local a = mathApproach(ent.liaAlpha or 0, goal, ft * fadeSpeed)
                if lastEntity ~= ent then paintedEntitiesCache[ent] = false end
                if a > 0 then
                    local netPlayer
                    if ent:GetClass() == "prop_ragdoll" then
                        for _, ply in player.Iterator() do
                            if ply:GetRagdollEntity() == ent then
                                netPlayer = ply
                                break
                            end
                        end
                    end

                    if IsValid(netPlayer) then
                        local p = toScreen(ent:LocalToWorld(ent:OBBCenter()))
                        hook.Run("DrawEntityInfo", netPlayer, a, p)
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

local function getEntityInfoCategory(entity)
    if not IsValid(entity) then return nil end
    if entity:IsPlayer() then return "players" end
    if entity:GetClass() == "prop_ragdoll" then
        for _, ply in player.Iterator() do
            if ply:GetRagdollEntity() == entity then return "players" end
        end
    end

    if entity.isItem and entity:isItem() or entity.isMoney and entity:isMoney() then return "items" end
    return "entities"
end

local entityInfoOptionByCategory = {
    players = "Player Hover Info",
    items = "Item Hover Info",
    entities = "Entity Hover Info"
}

local entityInfoMaxDistanceByCategory = {
    players = 128,
    items = 380,
    entities = 380
}

getEntityInfoMaxDistance = function(entity)
    local category = getEntityInfoCategory(entity)
    return entityInfoMaxDistanceByCategory[category] or 380
end

function GM:PostDrawOpaqueRenderables()
    if not lia.option.get("voiceRange", false) then return end
    local client = LocalPlayer()
    if not (IsValid(client) and client:IsSpeaking() and client:getChar()) then return end
    local vt = client:getLocalVar("VoiceType", VOICE_TALKING)
    local radius = VoiceRanges[vt] or VoiceRanges[VOICE_TALKING]
    local segments = 36
    local pos = client:GetPos() + Vector(0, 0, 2)
    local color = Color(0, 150, 255)
    render.SetColorMaterial()
    for i = 0, segments - 1 do
        local startAng = math.rad(i / segments * 360)
        local endAng = math.rad((i + 1) / segments * 360)
        local startPos = pos + Vector(math.cos(startAng), math.sin(startAng), 0) * radius
        local endPos = pos + Vector(math.cos(endAng), math.sin(endAng), 0) * radius
        render.DrawLine(startPos, endPos, color, false)
    end
end

function GM:ShouldDrawEntityInfo(e)
    if not IsValid(e) then return false end
    local category = getEntityInfoCategory(e)
    local optionKey = category and entityInfoOptionByCategory[category]
    if optionKey and not lia.option.get(optionKey, true) then return false end
    local hookResult = hook.Run("CanDrawEntityHoverInfo", e, category)
    if hookResult ~= nil then return hookResult end
    if e:IsPlayer() and e:getChar() then
        if e:GetMoveType() == MOVETYPE_NOCLIP or e:GetNoDraw() then return false end
        return true
    end

    local ply
    if e:GetClass() == "prop_ragdoll" then
        for _, p in player.Iterator() do
            if p:GetRagdollEntity() == e then
                ply = p
                break
            end
        end
    end

    if IsValid(ply) then return e == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end
    if e.DrawEntityInfo then return true end
    if e.onShouldDrawEntityInfo and e:onShouldDrawEntityInfo() then return true end
    return true
end

function GM:DrawEntityInfo(e, a, pos)
    if not e:IsPlayer() or hook.Run("ShouldDrawPlayerInfo", e) == false or IsValid(lia.gui.character) or IsValid(lia.gui.info) then return end
    local ch = e:getChar()
    if not ch then return end
    pos = pos or toScreen(e:GetPos() + (e:Crouching() and Vector(0, 0, 44) or Vector(0, 0, 72)))
    local width = lia.config.get("descriptionWidth", 0.5)
    if e.widthCache ~= width then
        e.widthCache = width
        e.liaNameCache = nil
        e.liaDescCache = nil
    end

    local name = hook.Run("GetDisplayedName", e) or ch and ch.getName(ch) or e:Name()
    if name ~= e.liaNameCache then
        e.liaNameCache = name
        if #name > 250 then name = name:sub(1, 250) .. "..." end
        e.liaNameLines = lia.util.wrapText(name, ScrW() * width, getHUDFont(17))
    end

    local desc = hook.Run("GetDisplayedDescription", e, true) or ch and ch.getDesc(ch) or "No character found!"
    if desc ~= e.liaDescCache then
        e.liaDescCache = desc
        e.liaDescLines = nil
        e.liaDescWrapWidth = nil
    end

    local extraInfo = {}
    if ch then hook.Run("DrawCharInfo", e, ch, extraInfo) end
    local minTooltipWidth = math.min(280, ScrW() * width)
    local maxTooltipWidth = math.min(420, ScrW() * 0.34)
    local descriptionWrapWidth = math.max(1, maxTooltipWidth - 24)
    if e.liaDescLines == nil or e.liaDescWrapWidth ~= descriptionWrapWidth then
        local wrappedDesc = e.liaDescCache or desc
        if #wrappedDesc > 250 then wrappedDesc = wrappedDesc:sub(1, 250) .. "..." end
        e.liaDescLines = wrapPlayerDescription(wrappedDesc, descriptionWrapWidth, getHUDFont(17), 3)
        e.liaDescWrapWidth = descriptionWrapWidth
    end

    local charInfo = {}
    for i = 1, #e.liaNameLines do
        charInfo[#charInfo + 1] = {e.liaNameLines[i], color_white}
    end

    for i = 1, #e.liaDescLines do
        charInfo[#charInfo + 1] = {e.liaDescLines[i]}
    end

    for i = 1, #extraInfo do
        charInfo[#charInfo + 1] = extraInfo[i]
    end

    if #charInfo > 0 then
        local fadeFraction = easeOutQuint(math.Clamp(tonumber(a) or 255, 0, 255) / 255)
        local fadeAlpha = math.floor(255 * fadeFraction)
        surface.SetFont(getHUDFont(17))
        local maxWidth = 0
        local totalHeight = 0
        for i = 1, #charInfo do
            local info = charInfo[i]
            local text = getPlayerInfoMeasureText(info):gsub("#", "\226\128\139#")
            local tw, th = surface.GetTextSize(text)
            maxWidth = math.max(maxWidth, tw)
            if i == 1 then
                totalHeight = th
            else
                totalHeight = totalHeight + th + 2
            end
        end

        local padding = 12
        local panelWidth = maxWidth + padding * 2
        local panelHeight = totalHeight + padding * 2
        local panelX = pos.x - panelWidth / 2
        local panelY = pos.y - panelHeight / 2
        if hook.Run("DrawPlayerInfoBackground", e, panelX, panelY, panelWidth, panelHeight, a) == false then return end
        local accent = lia.color.theme.accent or lia.color.theme.theme or color_white
        local boxWidth = math.Clamp(math.max(320, panelWidth + 32), minTooltipWidth, maxTooltipWidth)
        local boundMin, boundMax = e:GetRotatedAABB(e:OBBMins() * 0.5, e:OBBMaxs() * 0.5)
        local boundMinX = e:LocalToWorld(boundMin):ToScreen().x
        local boundMaxX = e:LocalToWorld(boundMax):ToScreen().x
        local tooltipAnchorX = math.max(boundMinX, boundMaxX) + 12
        local tooltipX = math.Clamp(tooltipAnchorX, ScrW() * 0.5 + 24, ScrW() - boxWidth)
        local descriptionRows = {}
        for i = 1, #e.liaDescLines do
            local line = trimPlayerInfoText(e.liaDescLines[i])
            if line ~= "" then
                descriptionRows[#descriptionRows + 1] = {
                    text = line:gsub("#", "\226\128\139#")
                }
            end
        end

        local informationRows = {}
        for i = 2, #e.liaNameLines do
            local line = trimPlayerInfoText(e.liaNameLines[i])
            if line ~= "" then
                informationRows[#informationRows + 1] = {
                    text = line:gsub("#", "\226\128\139#")
                }
            end
        end

        if #extraInfo > 0 then
            for i = 1, #extraInfo do
                local countBefore = #informationRows
                appendPlayerInfoRow(informationRows, extraInfo[i])
                local appended = informationRows[#informationRows]
                if appended and #informationRows > countBefore then
                    if appended.text then appended.text = appended.text:gsub("#", "\226\128\139#") end
                    if appended.label then appended.label = appended.label:gsub("#", "\226\128\139#") end
                    if appended.value then appended.value = appended.value:gsub("#", "\226\128\139#") end
                end
            end
        end

        local sections = buildPlayerInfoSections(descriptionRows, informationRows, "Information")
        local boxHeight = estimatePlayerInfoTooltipHeight(e.liaNameLines[1] or name, sections, "LiliaFont.17", "LiliaFont.15", 18, 12, 6)
        local tooltipY = math.Clamp(ScrH() * 0.5 - boxHeight * 0.5, 0, ScrH() - boxHeight)
        lia.derma.drawBoxWithText(nil, tooltipX, tooltipY, {
            title = e.liaNameLines[1] or name,
            sections = sections,
            textAlignX = TEXT_ALIGN_LEFT,
            textAlignY = TEXT_ALIGN_TOP,
            width = boxWidth,
            minWidth = minTooltipWidth,
            maxWidth = maxTooltipWidth,
            padding = 12,
            rowHeight = 18,
            sectionGap = 6,
            columnGap = 18,
            truncateTextRows = true,
            textRowSuffix = "(...)",
            textRowRightPadding = 0,
            titleInset = 0,
            backgroundColor = Color(3, 18, 22, math.floor(232 * (fadeAlpha / 255))),
            borderColor = Color(accent.r, accent.g, accent.b, math.floor(110 * (fadeAlpha / 255))),
            textColor = Color(235, 240, 242, fadeAlpha),
            mutedTextColor = Color(160, 178, 180, fadeAlpha),
            accentColor = Color(accent.r, accent.g, accent.b, fadeAlpha),
            accentAlpha = math.floor(210 * (fadeAlpha / 255)),
            shadow = {
                enabled = true,
                color = Color(0, 0, 0, math.floor(125 * (fadeAlpha / 255))),
                offsetX = 8,
                offsetY = 14
            },
            blur = {
                enabled = true,
                amount = 2,
                passes = 2,
                alpha = 0.65 * (fadeAlpha / 255)
            },
            overlapMargin = 4
        })
    end
end

function GM:HUDPaint()
    local client = LocalPlayer()
    if isToolgunHUDHidden(client) then return end
    if client:Alive() and client:getChar() then
        local wpn = client:GetActiveWeapon()
        if canDrawAmmo(wpn) then drawAmmo(wpn) end
        if canDrawCrosshair() then drawCrosshair() end
        local hudInfos = {}
        hook.Run("DisplayPlayerHUDInformation", client, hudInfos)
        if #hudInfos > 0 then
            for _, info in ipairs(hudInfos) do
                if (info.text or info.rows) and info.position then
                    local drawOptions = {
                        textColor = info.color or Color(180, 180, 180),
                        font = info.font or getHUDFont(16),
                        backgroundColor = Color(25, 28, 35, 250),
                        borderRadius = 12,
                        borderThickness = 0,
                        padding = 20,
                        blur = {
                            enabled = true,
                            amount = 1,
                            passes = 1,
                            alpha = 1.0
                        },
                        shadow = {
                            enabled = true,
                            offsetX = 15,
                            offsetY = 20,
                            color = Color(0, 0, 0, 180)
                        },
                        accentBorder = {
                            enabled = true,
                            height = 2,
                            color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
                        }
                    }

                    if info.backgroundColor then
                        drawOptions.backgroundColor = info.backgroundColor
                    else
                        drawOptions.backgroundColor = Color(25, 28, 35, 250)
                    end

                    if info.borderColor then drawOptions.borderColor = info.borderColor end
                    if info.borderRadius then drawOptions.borderRadius = info.borderRadius end
                    if info.borderThickness then drawOptions.borderThickness = info.borderThickness end
                    if info.padding then drawOptions.padding = info.padding end
                    if info.textAlignX then drawOptions.textAlignX = info.textAlignX end
                    if info.textAlignY then drawOptions.textAlignY = info.textAlignY end
                    if info.lineSpacing then drawOptions.lineSpacing = info.lineSpacing end
                    if info.autoSize ~= nil then drawOptions.autoSize = info.autoSize end
                    if info.width then drawOptions.width = info.width end
                    if info.height then drawOptions.height = info.height end
                    if info.title then drawOptions.title = info.title end
                    if info.rows then drawOptions.rows = info.rows end
                    if info.contentAlign then drawOptions.contentAlign = info.contentAlign end
                    if info.rowHeight then drawOptions.rowHeight = info.rowHeight end
                    if info.rowDividers ~= nil then drawOptions.rowDividers = info.rowDividers end
                    if info.richText ~= nil then
                        drawOptions.richText = info.richText
                    else
                        drawOptions.richText = info.rows ~= nil
                    end

                    if info.blur then drawOptions.blur = info.blur end
                    if info.shadow then drawOptions.shadow = info.shadow end
                    if info.accentBorder then drawOptions.accentBorder = info.accentBorder end
                    lia.derma.drawBoxWithText(info.rows and nil or info.text, info.position.x, info.position.y, drawOptions)
                end
            end
        end
    end
end

function GM:TooltipInitialize(var, panel)
    if panel.liaMainMenuTooltip then
        local text = panel.liaMainMenuTooltipText or ""
        surface.SetFont("LiliaFont.16")
        local textWidth = surface.GetTextSize(text)
        local tooltipWidth = math.min(math.ceil(textWidth) + 28, math.min(380, math.max(ScrW() - 24, 180)))
        var.tooltipPaddingX = 14
        var.tooltipPaddingY = 10
        var.markupObject = lia.markup.parse(var:GetText(), tooltipWidth - var.tooltipPaddingX * 2)
        var:SetText("")
        var:SetSize(tooltipWidth, math.max(44, var.markupObject:getHeight() + var.tooltipPaddingY * 2))
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isMainMenuTooltip = true
        return
    end

    if panel.liaToolTip or panel.itemID then
        local tooltipWidth = math.max(ScrW() * 0.15, 200)
        var.markupObject = lia.markup.parse(var:GetText(), tooltipWidth)
        var.tooltipPaddingX = 12
        var.tooltipPaddingY = 12
        var:SetText("")
        var:SetWide(tooltipWidth + var.tooltipPaddingX * 2)
        var:SetHeight(var.markupObject:getHeight() + var.tooltipPaddingY * 2)
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isItemTooltip = true
    end
end

function GM:TooltipPaint(var, w, h)
    if var.isMainMenuTooltip then
        local background = Color(27, 30, 42, 248)
        local outline = Color(61, 68, 90, 185)
        if lia.derma.SHAPE_IOS then
            lia.derma.rect(0, 0, w, h):Rad(3):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(3):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
        else
            draw.RoundedBox(3, 0, 0, w, h, background)
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        if var.markupObject then var.markupObject:draw(var.tooltipPaddingX or 14, math.floor((h - var.markupObject:getHeight()) * 0.5)) end
        return true
    end

    if var.isItemTooltip then
        local paddingX = var.tooltipPaddingX or 6
        local paddingY = var.tooltipPaddingY or 8
        local radius = 6
        local shadowIntensity = 8
        local shadowBlur = 12
        local accent = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
        local background = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.util.drawBlur(var, 4, 2)
        lia.derma.rect(0, 0, w, h):Rad(radius):Color(background):Draw()
        surface.SetDrawColor(accent)
        surface.DrawRect(0, 0, w, 2)
        if var.markupObject then var.markupObject:draw(paddingX, paddingY) end
        return true
    end
end

function GM:TooltipLayout(var)
    return var.isItemTooltip or var.isMainMenuTooltip
end

function GM:DrawLiliaModelView(client, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:CreateMove(cmd)
    local client = LocalPlayer()
    if IsValid(client) then
        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "lia_hands" and (weapon.cachedIsHoldingObject or false) and cmd:KeyDown(IN_ATTACK2) then
            cmd:ClearMovement()
            local angle = cmd:GetViewAngles()
            angle.z = 0
            cmd:SetViewAngles(angle)
        end
    end
end

function GM:CalcView(client, origin, angles, fov)
    if IsValid(client:GetVehicle()) then return self.BaseClass:CalcView(client, origin, angles, fov) end
    local view = lia.camera.calcView(client, origin, angles, fov) or self.BaseClass:CalcView(client, origin, angles, fov)
    local ragdoll = client:GetRagdollEntity()
    if not IsValid(client:GetVehicle()) and client:GetViewEntity() == client and not client:ShouldDrawLocalPlayer() and IsValid(ragdoll) then
        local idx = ragdoll:LookupAttachment("eyes")
        if idx then
            local data = ragdoll:GetAttachment(idx)
            if data then
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
                return view
            end
        end
    end
    return view
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and IsValid(client:GetRagdollEntity()) then lia.command.send("chargetup") end
    if bind:find("use") then
        local entity = client:getTracedEntity()
        local hasValidEntity = IsValid(entity) and (entity:isItem() or entity.hasMenu)
        if pressed and hasValidEntity then hook.Run("ItemShowEntityMenu", entity) end
    end

    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
    end
end

local liaItemDermaMenu = nil
function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local itemTable = entity:getItemTable()
    if not itemTable then return end
    if not useKeyHeld and input.IsShiftDown() then
        if IsValid(entity) then
            net.Start("liaInvAct")
            net.WriteString("take")
            net.WriteType(entity)
            net.WriteType(nil)
            net.SendToServer()
        end
        return
    end

    if IsValid(liaItemDermaMenu) then liaItemDermaMenu:Remove() end
    liaItemDermaMenu = vgui.Create("liaDermaMenu")
    local tempItem = table.Copy(itemTable)
    tempItem.player = LocalPlayer()
    tempItem.entity = entity
    for key, fn in SortedPairs(itemTable.functions) do
        if key == "combine" then continue end
        if hook.Run("CanRunItemAction", tempItem, key) == false then continue end
        if isfunction(fn.onCanRun) and not fn.onCanRun(tempItem) then continue end
        liaItemDermaMenu:AddOption(tostring(fn.name or key), function()
            if fn.sound then surface.PlaySound(fn.sound) end
            if not fn.onClick or fn.onClick(tempItem) ~= false then
                net.Start("liaInvAct")
                net.WriteString(key)
                net.WriteType(entity)
                net.WriteType(nil)
                net.SendToServer()
            end

            liaItemDermaMenu:Remove()
            liaItemMenuVisible = false
        end, fn.icon)
    end

    local pos = entity:GetPos()
    local screenPos = pos:ToScreen()
    local menuX = screenPos.x - liaItemDermaMenu:GetWide() / 2
    local menuY = screenPos.y - liaItemDermaMenu:GetTall() - 20
    menuX = math.Clamp(menuX, 0, ScrW() - liaItemDermaMenu:GetWide())
    menuY = math.Clamp(menuY, 0, ScrH() - liaItemDermaMenu:GetTall())
    liaItemDermaMenu:SetPos(menuX, menuY)
    liaItemDermaMenu:MakePopup()
    liaItemDermaMenu:SetVisible(true)
    liaItemDermaMenu:SetKeyboardInputEnabled(false)
    liaItemDermaMenu:SetMouseInputEnabled(true)
    liaItemDermaMenu.OnRemove = function() liaItemMenuVisible = false end
    liaItemMenuVisible = true
end

function GM:HUDPaintBackground()
    lia.menu.drawAll()
    RenderEntities()
    local client = LocalPlayer()
    if IsValid(client) then
        local shouldBlackout = client:Alive() and IsValid(client:GetRagdollEntity())
        local targetAlpha = shouldBlackout and 255 or 0
        local fadeSpeed = shouldBlackout and 900 or 600
        falloverBlackoutAlpha = mathApproach(falloverBlackoutAlpha, targetAlpha, FrameTime() * fadeSpeed)
        if falloverBlackoutAlpha > 0 then
            surface.SetDrawColor(0, 0, 0, falloverBlackoutAlpha)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end

    if not isToolgunHUDHidden(client) and BRANCH ~= "x86-64" then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch on your installation, consider swapping as soon as possible.", getHUDFont(17), ScrW() * 0.5, ScrH() * 0.97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    if hook.Run("ShouldShowQuickMenu") == false then return end
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
        lia.gui.quick = nil
    end

    lia.gui.quick = vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
        lia.gui.quick = nil
    end
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("PreLiliaLoaded")
        lia.option.load()
        hook.Run("LiliaLoaded")
    end)
end

function GM:ForceDermaSkin()
    return lia.config.get("DermaSkin", "Lilia Skin")
end

function GM:DermaSkinChanged()
    derma.RefreshSkins()
end

function GM:HUDShouldDraw(element)
    return not hidden[element]
end

function GM:SpawnMenuOpen()
    local client = LocalPlayer()
    if not IsValid(client) or not client:getChar() then return end
    local limitEnabled = lia.config.get("SpawnMenuLimit", false)
    local hasFlag = client:hasFlags("pet")
    local isStaff = client:isStaffOnDuty()
    local hasPrivilege = client:hasPrivilege("canSpawnProps")
    if limitEnabled and not (hasFlag or isStaff or hasPrivilege) then return end
    return true
end

function GM:InitPostEntity()
    lia.joinTime = RealTime() - 0.9716
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
    net.Start("liaStorageSyncRequest")
    net.SendToServer()
end

function GM:HUDDrawTargetID()
    return false
end

function GM:HUDDrawPickupHistory()
    return false
end

local lastRKeyState = false
function GM:Think()
    local itemIcon = IsValid(lia.item.held) and lia.item.held or nil
    local itemTable = itemIcon and itemIcon.itemTable or nil
    if not itemTable then return end
    local rKeyPressed = input.IsKeyDown(KEY_R)
    if rKeyPressed and not lastRKeyState then
        if IsValid(itemTable.entity) or itemTable.width == itemTable.height or itemTable:getData("equip", false) then return end
        local inv = lia.item.getInv(itemTable.invID)
        local x, y = itemTable:getData("x"), itemTable:getData("y")
        local newRot = not itemTable:getData("rotated", false)
        if inv and x and y then
            local w = newRot and (itemTable.height or 1) or itemTable.width or 1
            local h = newRot and (itemTable.width or 1) or itemTable.height or 1
            local invW, invH = inv:getSize()
            if x < 1 or y < 1 or x + w - 1 > invW or y + h - 1 > invH then return end
            for _, v in pairs(inv:getItems(true)) do
                if v ~= itemTable then
                    local ix, iy = v:getData("x"), v:getData("y")
                    if ix and iy then
                        local ix2 = ix + v:getWidth() - 1
                        local iy2 = iy + v:getHeight() - 1
                        local x2 = x + w - 1
                        local y2 = y + h - 1
                        if x <= ix2 and ix <= x2 and y <= iy2 and iy <= y2 then return end
                    end
                end
            end
        end

        local currentRotation = itemTable:getData("rotated", false)
        local newRotation = not currentRotation
        itemTable.data = itemTable.data or {}
        itemTable.data.rotated = newRotation
        itemTable.forceRender = true
        if IsValid(itemIcon) then itemIcon:setItem(itemTable) end
        net.Start("liaItemRotate")
        net.WriteUInt(itemTable:getID(), 32)
        net.WriteBool(newRotation)
        net.SendToServer()
    end

    lastRKeyState = rKeyPressed
end

function GM:HUDAmmoPickedUp()
    return false
end

function GM:DrawDeathNotice()
    return false
end

function GM:CharLoaded(character)
    if not character then return end
    timer.Simple(0.5, function()
        if lia.webcontent and lia.webcontent.stored then
            local missing = {}
            for _, entry in pairs(lia.webcontent.stored) do
                if not lia.webcontent.get(entry.name, entry.type, entry.flags) then missing[#missing + 1] = entry end
            end

            local function downloadNext(index)
                local entry = missing[index]
                if not entry then return end
                lia.webcontent.download(entry.name, entry.url, entry.type, function() timer.Simple(0.1, function() downloadNext(index + 1) end) end, entry.flags)
            end

            downloadNext(1)
        end
    end)
end

function GM:PrePlayerDraw(client)
    if lia.view.shouldHidePlayer(client) then
        client:DrawShadow(false)
        return true
    end

    if IsValid(client:GetRagdollEntity()) then
        client:DrawShadow(false)
        return true
    end
end
