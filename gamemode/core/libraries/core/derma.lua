lia.derma = lia.derma or {}
local color_disconnect = Color(210, 65, 65)
local color_bot = Color(70, 150, 220)
local color_online = Color(120, 180, 70)
local color_close = Color(210, 65, 65)
local color_accept = Color(44, 124, 62)
local color_target = Color(255, 255, 255, 200)
function lia.derma.dermaMenu()
    if IsValid(lia.gui.menuDermaMenu) then lia.gui.menuDermaMenu:CloseMenu() end
    local mouseX, mouseY = input.GetCursorPos()
    local m = vgui.Create("liaDermaMenu")
    m:SetPos(mouseX, mouseY)
    lia.util.clampMenuPosition(m)
    lia.gui.menuDermaMenu = m
    return m
end

function lia.derma.requestColorPicker(func, colorStandard)
    if IsValid(lia.gui.menuColorPicker) then lia.gui.menuColorPicker:Remove() end
    local selected_color = colorStandard or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    if colorStandard then
        local r, g, b = colorStandard.r / 255, colorStandard.g / 255, colorStandard.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        hue = h
        saturation = s
        value = v
    end

    lia.gui.menuColorPicker = vgui.Create("liaFrame")
    lia.gui.menuColorPicker:SetSize(300, 378)
    lia.gui.menuColorPicker:Center()
    lia.gui.menuColorPicker:MakePopup()
    lia.gui.menuColorPicker:SetTitle("")
    lia.gui.menuColorPicker:SetCenterTitle("Color Picker")
    local container = vgui.Create("Panel", lia.gui.menuColorPicker)
    container:Dock(FILL)
    container:DockMargin(10, 10, 10, 10)
    container.Paint = nil
    local preview = vgui.Create("Panel", container)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h)
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(selected_color):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local colorField = vgui.Create("Panel", container)
    colorField:Dock(TOP)
    colorField:SetTall(200)
    colorField:DockMargin(0, 0, 0, 10)
    local colorCursor = {
        x = 0,
        y = 0
    }

    local isDraggingColor = false
    colorField.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = true
            self:OnCursorMoved(self:CursorPos())
            lia.webcontent.playButtonSound()
        end
    end

    colorField.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingColor = false end end
    colorField.OnCursorMoved = function(self, x, y)
        if isDraggingColor then
            local w, h = self:GetSize()
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)
            colorCursor.x = x
            colorCursor.y = y
            saturation = x / w
            value = 1 - (y / h)
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    colorField.Paint = function(_, w, h)
        local segments = 80
        local segmentSize = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        for x = 0, segments do
            for y = 0, segments do
                local s = x / segments
                local v = 1 - (y / segments)
                local segX = x * segmentSize
                local segY = y * segmentSize
                surface.SetDrawColor(HSVToColor(hue, s, v))
                surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
            end
        end

        lia.derma.circle(colorCursor.x, colorCursor.y, 12):Outline(2):Color(color_target):Draw()
    end

    local hueSlider = vgui.Create("Panel", container)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(20)
    hueSlider:DockMargin(0, 0, 0, 10)
    local huePos = 0
    local isDraggingHue = false
    hueSlider.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = true
            self:OnCursorMoved(self:CursorPos())
            lia.webcontent.playButtonSound()
        end
    end

    hueSlider.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingHue = false end end
    hueSlider.OnCursorMoved = function(self, x)
        if isDraggingHue then
            local w = self:GetWide()
            x = math.Clamp(x, 0, w)
            huePos = x
            hue = (x / w) * 360
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    hueSlider.Paint = function(_, w, h)
        local segments = 100
        local segmentWidth = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth
            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        lia.derma.rect(huePos - 2, 0, 4, h):Color(color_target):Draw()
    end

    local rgbContainer = vgui.Create("Panel", container)
    rgbContainer:Dock(TOP)
    rgbContainer:SetTall(60)
    rgbContainer:DockMargin(0, 0, 0, 10)
    rgbContainer.Paint = nil
    local btnContainer = vgui.Create("Panel", container)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)
    btnContainer.Paint = nil
    local btnClose = vgui.Create("liaButton", btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(90)
    btnClose:SetTxt("Cancel")
    btnClose:SetColorHover(color_close)
    btnClose.DoClick = function()
        btnClose.BaseClass.DoClick(btnClose)
        if func then func(false) end
        lia.gui.menuColorPicker:Remove()
    end

    local btnSelect = vgui.Create("liaButton", btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetTxt("Select")
    btnSelect:SetColorHover(color_accept)
    btnSelect.DoClick = function()
        btnSelect.BaseClass.DoClick(btnSelect)
        func(selected_color)
        lia.gui.menuColorPicker:Remove()
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)

    timer.Simple(0.1, function() lia.gui.menuColorPicker:SetAlpha(255) end)
end

function lia.derma.requestPlayerSelector(doClick)
    if IsValid(lia.gui.menuPlayerSelector) then lia.gui.menuPlayerSelector:Remove() end
    lia.gui.menuPlayerSelector = vgui.Create("liaFrame")
    lia.gui.menuPlayerSelector:SetSize(340, 398)
    lia.gui.menuPlayerSelector:Center()
    lia.gui.menuPlayerSelector:MakePopup()
    lia.gui.menuPlayerSelector:SetTitle("")
    lia.gui.menuPlayerSelector:SetCenterTitle("Player Selector")
    lia.gui.menuPlayerSelector:ShowAnimation()
    local contentPanel = vgui.Create("Panel", lia.gui.menuPlayerSelector)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    lia.gui.menuPlayerSelector.sp = vgui.Create("liaScrollPanel", contentPanel)
    lia.gui.menuPlayerSelector.sp:Dock(FILL)
    local CARD_HEIGHT = 44
    local AVATAR_SIZE = 32
    local AVATAR_X = 14
    local function CreatePlayerCard(pl)
        local card = vgui.Create("DButton", lia.gui.menuPlayerSelector.sp)
        card:Dock(TOP)
        card:DockMargin(0, 5, 0, 0)
        card:SetTall(CARD_HEIGHT)
        card:SetText("")
        card.hover_status = 0
        card.OnCursorEntered = function(self) self:SetCursor("hand") end
        card.OnCursorExited = function(self) self:SetCursor("arrow") end
        card.Think = function(self)
            if self:IsHovered() then
                self.hover_status = math.Clamp(self.hover_status + 4 * FrameTime(), 0, 1)
            else
                self.hover_status = math.Clamp(self.hover_status - 8 * FrameTime(), 0, 1)
            end
        end

        card.DoClick = function()
            if IsValid(pl) then
                card.BaseClass.DoClick(card)
                doClick(pl)
            end

            lia.gui.menuPlayerSelector:Remove()
        end

        card.Paint = function(self, w, h)
            lia.derma.rect(0, 0, w, h):Rad(10):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
            if self.hover_status > 0 then lia.derma.rect(0, 0, w, h):Rad(10):Color(Color(0, 0, 0, 40 * self.hover_status)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local infoX = AVATAR_X + AVATAR_SIZE + 10
            if not IsValid(pl) then
                draw.SimpleText("Disconnected", "LiliaFont.18", infoX, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(pl:Name(), "LiliaFont.18", infoX, 6, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = pl:GetUserGroup() or "user"
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, "LiliaFont.14", infoX, h - 6, lia.color.theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(pl:Ping() .. " " .. "Ping", "LiliaFont.16", w - 20, h - 6, lia.color.theme.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            if pl:IsBot() then
                statusColor = color_bot
            else
                statusColor = color_online
            end

            lia.derma.circle(w - 24, 14, 24):Color(statusColor):Draw()
        end

        local avatarImg = vgui.Create("AvatarImage", card)
        avatarImg:SetSize(AVATAR_SIZE, AVATAR_SIZE)
        avatarImg:SetPos(AVATAR_X, (CARD_HEIGHT - AVATAR_SIZE) * 0.5)
        avatarImg:SetPlayer(pl, 64)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetKeyboardInputEnabled(false)
        avatarImg.PaintOver = function() end
        avatarImg:SetPos(AVATAR_X, (card:GetTall() - AVATAR_SIZE) * 0.5)
        return card
    end

    for _, pl in player.Iterator() do
        CreatePlayerCard(pl)
    end

    lia.gui.menuPlayerSelector.btn_close = vgui.Create("liaButton", lia.gui.menuPlayerSelector)
    lia.gui.menuPlayerSelector.btn_close:Dock(BOTTOM)
    lia.gui.menuPlayerSelector.btn_close:DockMargin(16, 8, 16, 12)
    lia.gui.menuPlayerSelector.btn_close:SetTall(36)
    lia.gui.menuPlayerSelector.btn_close:SetTxt("Close")
    lia.gui.menuPlayerSelector.btn_close:SetColorHover(color_disconnect)
    lia.gui.menuPlayerSelector.btn_close.DoClick = function() lia.gui.menuPlayerSelector:Remove() end
end

local RNDX = lia.rndx
assert(RNDX, "RNDX failed to load")
lia.derma.draw = RNDX.draw
lia.derma.drawOutlined = RNDX.drawOutlined
lia.derma.drawTexture = RNDX.drawTexture
lia.derma.drawMaterial = RNDX.drawMaterial
lia.derma.drawCircle = RNDX.drawCircle
lia.derma.drawCircleOutlined = RNDX.drawCircleOutlined
lia.derma.drawCircleTexture = RNDX.drawCircleTexture
lia.derma.drawCircleMaterial = RNDX.drawCircleMaterial
lia.derma.drawShadowsEx = RNDX.drawShadowsEx
lia.derma.drawShadows = RNDX.drawShadows
lia.derma.drawShadowsOutlined = RNDX.drawShadowsOutlined
lia.derma.rect = RNDX.rect
lia.derma.circle = RNDX.circle
lia.derma.setFlag = RNDX.setFlag
lia.derma.setDefaultShape = RNDX.setDefaultShape
lia.derma.NO_TL = RNDX.NO_TL
lia.derma.NO_TR = RNDX.NO_TR
lia.derma.NO_BL = RNDX.NO_BL
lia.derma.NO_BR = RNDX.NO_BR
lia.derma.SHAPE_CIRCLE = RNDX.SHAPE_CIRCLE
lia.derma.SHAPE_FIGMA = RNDX.SHAPE_FIGMA
lia.derma.SHAPE_IOS = RNDX.SHAPE_IOS
lia.derma.BLUR = RNDX.BLUR
lia.derma.MANUAL_COLOR = RNDX.MANUAL_COLOR
function lia.derma.shadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    surface.SetFont(font)
    local _, h = surface.GetTextSize(text)
    if yalign == TEXT_ALIGN_CENTER then
        y = y - h / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then
        y = y - h
    end

    draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
    draw.DrawText(text, font, x, y, colortext, xalign)
end

function lia.derma.drawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
    local steps = (outlinewidth * 2) / 3
    if steps < 1 then steps = 1 end
    for ox = -outlinewidth, outlinewidth, steps do
        for oy = -outlinewidth, outlinewidth, steps do
            draw.DrawText(text, font, x + ox, y + oy, outlinecolour, xalign)
        end
    end
    return draw.DrawText(text, font, x, y, colour, xalign)
end

function lia.derma.drawTip(x, y, w, h, text, font, textCol, outlineCol)
    draw.NoTexture()
    local rectH = 0.85
    local triW = 0.1
    local verts = {
        {
            x = x,
            y = y
        },
        {
            x = x + w,
            y = y
        },
        {
            x = x + w,
            y = y + h * rectH
        },
        {
            x = x + w / 2 + w * triW,
            y = y + h * rectH
        },
        {
            x = x + w / 2,
            y = y + h
        },
        {
            x = x + w / 2 - w * triW,
            y = y + h * rectH
        },
        {
            x = x,
            y = y + h * rectH
        }
    }

    surface.SetDrawColor(outlineCol)
    surface.DrawPoly(verts)
    draw.SimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function lia.derma.drawText(text, x, y, color, alignX, alignY, font, alpha)
    color = color or Color(255, 255, 255)
    return draw.TextShadow({
        text = text,
        font = font or "LiliaFont.16",
        pos = {x, y},
        color = color,
        xalign = alignX or 0,
        yalign = alignY or 0
    }, 1, alpha or color.a * 0.575)
end

local drawBoxOverlaps = {}
local drawBoxFrame = 0
local function splitBoxTextLines(text)
    local sourceLines = istable(text) and text or {text}
    local textLines = {}
    for _, value in ipairs(sourceLines) do
        local normalized = tostring(value or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
        local startIndex = 1
        while true do
            local breakStart, breakEnd = normalized:find("\n", startIndex, true)
            if not breakStart then
                textLines[#textLines + 1] = normalized:sub(startIndex)
                break
            end

            textLines[#textLines + 1] = normalized:sub(startIndex, breakStart - 1)
            startIndex = breakEnd + 1
            if startIndex > #normalized then
                textLines[#textLines + 1] = ""
                break
            end
        end
    end

    if #textLines == 0 then textLines[1] = "" end
    return textLines
end

function lia.derma.drawBoxWithText(text, x, y, options)
    options = options or {}
    local function trim(value)
        return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function fitTextToWidth(value, maxRowWidth, font, suffix)
        local resolved = trim(value)
        suffix = suffix or "..."
        surface.SetFont(font)
        if surface.GetTextSize(resolved) <= maxRowWidth then return resolved end
        local candidate = resolved .. suffix
        while resolved ~= "" and surface.GetTextSize(candidate) > maxRowWidth do
            resolved = trim(resolved:sub(1, -2))
            candidate = resolved .. suffix
        end
        return candidate ~= "" and candidate or suffix
    end

    local function resolveText(value)
        if value == nil then return "" end
        if isstring(value) and L then
            local ok, localized = pcall(lia.lang.resolve, value)
            if ok and localized and localized ~= "" then return tostring(localized) end
        end
        return tostring(value)
    end

    local function resolveAccent()
        local theme = lia.color and lia.color.theme or {}
        return options.accentColor or theme.accent or theme.theme or lia.config.get("Color") or Color(164, 106, 54)
    end

    local function drawBlurAt(px, py, pw, ph, blurData)
        if not blurData or blurData.enabled == false then return end
        local amount = blurData.amount or 3
        local passes = blurData.passes or 3
        local alpha = blurData.alpha or 0.9
        lia.util.drawBlurAt(px, py, pw, ph, amount, passes, alpha)
    end

    local function parseDebugText(raw)
        if not isstring(raw) then return end
        if not raw:find("SteamID", 1, true) and not raw:find("FrameTime", 1, true) then return end
        local values = {}
        local loose = {}
        local normalized = raw:gsub("\r\n", "\n"):gsub("\r", "\n")
        for line in normalized:gmatch("[^\n]+") do
            for part in line:gmatch("[^|]+") do
                local item = trim(part)
                if item ~= "" then
                    local key, value = item:match("^([^:]+):%s*(.+)$")
                    if key and value then
                        values[key:lower():gsub("[^%w]", "")] = trim(value)
                    else
                        loose[#loose + 1] = item
                    end
                end
            end
        end

        local dateText, timeText
        for _, item in ipairs(loose) do
            if not dateText and item:match("^%d%d/%d%d/%d%d%d%d$") then dateText = item end
            if not timeText and item:match("^%d%d:%d%d:%d%d$") then timeText = item end
        end

        local function getValue(...)
            for _, key in ipairs({...}) do
                local value = values[key]
                if value and value ~= "" then return value end
            end
        end

        local sections = {}
        local sessionRows = {}
        local steamID64 = getValue("steamid64")
        local steamID = getValue("steamid")
        if steamID64 then
            sessionRows[#sessionRows + 1] = {
                label = "SteamID64",
                value = steamID64
            }
        end

        if steamID then
            sessionRows[#sessionRows + 1] = {
                label = "SteamID",
                value = steamID
            }
        end

        if dateText or timeText then
            sessionRows[#sessionRows + 1] = {
                label = "Date / Time",
                value = trim((dateText or "") .. " " .. (timeText or ""))
            }
        end

        if #sessionRows > 0 then
            sections[#sections + 1] = {
                rows = sessionRows
            }
        end

        local positionRows = {}
        local pos = getValue("pos")
        local ang = getValue("ang")
        local tracePos = getValue("tracepos")
        local traceDist = getValue("tracedist")
        if pos then
            positionRows[#positionRows + 1] = {
                label = "Pos",
                value = pos
            }
        end

        if ang then
            positionRows[#positionRows + 1] = {
                label = "Ang",
                value = ang
            }
        end

        if tracePos then
            positionRows[#positionRows + 1] = {
                label = "Trace Pos",
                value = tracePos
            }
        end

        if traceDist then
            positionRows[#positionRows + 1] = {
                label = "Trace Dist",
                value = traceDist
            }
        end

        if #positionRows > 0 then
            sections[#sections + 1] = {
                title = "Position",
                rows = positionRows
            }
        end

        local performanceRows = {}
        local health = getValue("health")
        local ping = getValue("ping")
        local fps = getValue("fps")
        local frameTime = getValue("frametime")
        if health then
            performanceRows[#performanceRows + 1] = {
                label = "Health",
                value = health
            }
        end

        if ping then
            performanceRows[#performanceRows + 1] = {
                label = "Ping",
                value = ping
            }
        end

        if fps then
            performanceRows[#performanceRows + 1] = {
                label = "FPS",
                value = fps
            }
        end

        if frameTime then
            performanceRows[#performanceRows + 1] = {
                label = "Frame Time",
                value = frameTime
            }
        end

        if #performanceRows > 0 then
            sections[#sections + 1] = {
                title = "Performance",
                rows = performanceRows
            }
        end

        if #sections == 0 then return end
        return {
            title = "Debug Session",
            sections = sections
        }
    end

    local debugLayout
    local structured = istable(options.sections) or istable(options.rows) or options.title ~= nil
    if not structured and options.autoFormatDebug ~= false then
        debugLayout = parseDebugText(text)
        structured = debugLayout ~= nil
    end

    if not structured then
        local font = options.font or "LiliaFont.16"
        local textColor = options.textColor or Color(255, 255, 255)
        local backgroundColor = options.backgroundColor or Color(25, 28, 35, 250)
        local borderColor = options.borderColor or lia.color.theme.theme
        local borderRadius = options.borderRadius or 12
        local borderThickness = options.borderThickness or 0
        local padding = options.padding or 20
        local blur = options.blur or {
            enabled = true,
            amount = 3,
            passes = 3,
            alpha = 0.9
        }

        local textAlignX = options.textAlignX or TEXT_ALIGN_CENTER
        local textAlignY = options.textAlignY or TEXT_ALIGN_CENTER
        local autoSize = options.autoSize ~= false
        local lineSpacing = options.lineSpacing or 4
        local overlapMargin = options.overlapMargin or 8
        local textLines = splitBoxTextLines(text)
        surface.SetFont(font)
        local _, defaultLineHeight = surface.GetTextSize("W")
        local maxWidth, totalHeight = 0, 0
        local lineHeights = {}
        for i, line in ipairs(textLines) do
            local measureText = line ~= "" and line or " "
            local textWidth, textHeight = surface.GetTextSize(measureText)
            if line == "" then textWidth = 0 end
            lineHeights[i] = math.max(textHeight, defaultLineHeight)
            maxWidth = math.max(maxWidth, textWidth)
            if i == 1 then
                totalHeight = lineHeights[i]
            else
                totalHeight = totalHeight + lineHeights[i] + lineSpacing
            end
        end

        local boxWidth, boxHeight
        if autoSize then
            boxWidth = maxWidth + padding
            boxHeight = totalHeight + padding
        else
            boxWidth = options.width or maxWidth + padding
            boxHeight = options.height or totalHeight + padding
        end

        local boxX = x
        if textAlignX == TEXT_ALIGN_RIGHT then
            boxX = x - boxWidth
        elseif textAlignX == TEXT_ALIGN_CENTER then
            boxX = x - boxWidth / 2
        end

        local boxY = y
        if textAlignY == TEXT_ALIGN_BOTTOM then
            boxY = y - boxHeight
        elseif textAlignY == TEXT_ALIGN_CENTER then
            boxY = y - boxHeight / 2
        end

        if drawBoxFrame ~= FrameNumber() then
            drawBoxOverlaps = {}
            drawBoxFrame = FrameNumber()
        end

        local screenW, screenH = ScrW(), ScrH()
        local function intersects(cx, cy)
            for _, rect in ipairs(drawBoxOverlaps) do
                if cx < rect.x + rect.w + overlapMargin and cx + boxWidth + overlapMargin > rect.x and cy < rect.y + rect.h + overlapMargin and cy + boxHeight + overlapMargin > rect.y then return rect end
            end
        end

        boxX = math.Clamp(boxX, 0, screenW - boxWidth)
        boxY = math.Clamp(boxY, 0, screenH - boxHeight)
        local overlap = intersects(boxX, boxY)
        local attempts = 0
        while overlap and attempts < 8 do
            local down = overlap.y + overlap.h + overlapMargin
            local up = overlap.y - boxHeight - overlapMargin
            local nextY = down + boxHeight <= screenH and down or math.max(0, up)
            boxY = math.Clamp(nextY, 0, screenH - boxHeight)
            overlap = intersects(boxX, boxY)
            attempts = attempts + 1
        end

        local shadow = options.shadow or {
            enabled = true,
            color = Color(0, 0, 0, 180),
            offsetX = 15,
            offsetY = 20
        }

        boxWidth = math.max(boxWidth, 1)
        boxHeight = math.max(boxHeight, 1)
        if shadow.enabled then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Rad(borderRadius):Color(shadow.color or Color(0, 0, 0, 180)):Shadow(shadow.offsetX or 15, shadow.offsetY or 20):Shape(lia.derma.SHAPE_IOS):Draw() end
        drawBlurAt(boxX, boxY, boxWidth, boxHeight, blur)
        lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(backgroundColor):Rad(borderRadius):Shape(lia.derma.SHAPE_IOS):Draw()
        if borderThickness > 0 then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(borderColor):Rad(borderRadius):Shape(lia.derma.SHAPE_IOS):Outline(borderThickness):Draw() end
        local accentBorder = options.accentBorder or {
            enabled = false
        }

        if accentBorder.enabled then
            local accent = accentBorder.color or lia.color.theme.theme or color_white
            surface.SetDrawColor(accent.r, accent.g, accent.b, accent.a or 255)
            surface.DrawRect(boxX, boxY, boxWidth, accentBorder.height or 2)
        end

        local startY = boxY + padding / 2
        if textAlignY == TEXT_ALIGN_CENTER then
            startY = boxY + (boxHeight - totalHeight) / 2
        elseif textAlignY == TEXT_ALIGN_BOTTOM then
            startY = boxY + boxHeight - padding / 2 - totalHeight
        end

        local currentY = startY
        for i, line in ipairs(textLines) do
            local textX
            if textAlignX == TEXT_ALIGN_CENTER then
                textX = boxX + boxWidth / 2
            elseif textAlignX == TEXT_ALIGN_LEFT then
                textX = boxX + padding / 2
            else
                textX = boxX + boxWidth - padding / 2
            end

            if line ~= "" then lia.derma.drawText(line, textX, currentY, textColor, textAlignX, TEXT_ALIGN_TOP, font) end
            if i < #textLines then currentY = currentY + lineHeights[i] + lineSpacing end
        end

        drawBoxOverlaps[#drawBoxOverlaps + 1] = {
            x = boxX,
            y = boxY,
            w = boxWidth,
            h = boxHeight
        }
        return boxWidth, boxHeight
    end

    local accent = resolveAccent()
    local theme = lia.color and lia.color.theme or {}
    local textColor = options.textColor or theme.text or Color(235, 240, 242)
    local mutedTextColor = options.mutedTextColor or theme.gray or Color(160, 178, 180)
    local titleFont = options.titleFont or "LiliaFont.17"
    local sectionFont = options.sectionFont or "LiliaFont.15"
    local rowFont = options.font or "LiliaFont.15"
    local valueFont = options.valueFont or rowFont
    local backgroundColor = options.backgroundColor or Color(3, 18, 22, 232)
    local borderColor = options.borderColor or Color(accent.r, accent.g, accent.b, 110)
    local borderRadius = options.borderRadius or 8
    local borderThickness = options.borderThickness or 1
    local padding = options.padding or 16
    local rowHeight = options.rowHeight or 24
    local sectionGap = options.sectionGap or 12
    local columnGap = options.columnGap or 28
    local minWidth = options.minWidth or 280
    local maxWidth = options.maxWidth or 520
    local overlapMargin = options.overlapMargin or 8
    local textAlignX = options.textAlignX or TEXT_ALIGN_LEFT
    local textAlignY = options.textAlignY or TEXT_ALIGN_TOP
    local truncateTextRows = options.truncateTextRows == true
    local textRowSuffix = options.textRowSuffix or "..."
    local textRowRightPadding = options.textRowRightPadding or 6
    local titleInset = options.titleInset or 14
    local maxTextRowWidth = math.max(1, (options.width or maxWidth) - padding - textRowRightPadding)
    local titleText = resolveText(options.title or debugLayout and debugLayout.title)
    local sourceSections = {}
    if debugLayout then
        sourceSections = debugLayout.sections
    elseif istable(options.sections) then
        for _, section in ipairs(options.sections) do
            if istable(section) then
                sourceSections[#sourceSections + 1] = {
                    title = section.title or section.name,
                    rows = section.rows or section.items or {}
                }
            end
        end
    elseif istable(options.rows) then
        local current = {
            title = options.sectionTitle,
            rows = {}
        }

        for _, row in ipairs(options.rows) do
            if istable(row) and (row.section or row.category) then
                if current.title or #current.rows > 0 then sourceSections[#sourceSections + 1] = current end
                current = {
                    title = row.section or row.category,
                    rows = {}
                }
            else
                current.rows[#current.rows + 1] = row
            end
        end

        if current.title or #current.rows > 0 then sourceSections[#sourceSections + 1] = current end
    else
        sourceSections[#sourceSections + 1] = {
            rows = splitBoxTextLines(text)
        }
    end

    surface.SetFont(titleFont)
    local titleWidth, titleHeight = 0, 0
    if titleText ~= "" then titleWidth, titleHeight = surface.GetTextSize(string.upper(titleText)) end
    local measuredWidth = titleWidth + padding * 2 + 24
    local totalHeight = padding
    if titleText ~= "" then totalHeight = totalHeight + math.max(titleHeight, 18) + 14 end
    local preparedSections = {}
    for _, section in ipairs(sourceSections) do
        local preparedRows = {}
        local sectionTitle = resolveText(section.title)
        local sectionHeight = 0
        if sectionTitle ~= "" then
            surface.SetFont(sectionFont)
            local sectionWidth, sectionTextHeight = surface.GetTextSize(string.upper(sectionTitle))
            measuredWidth = math.max(measuredWidth, sectionWidth + padding * 2 + 120)
            sectionHeight = sectionHeight + math.max(sectionTextHeight, 16) + 10
        end

        for _, row in ipairs(section.rows or {}) do
            local prepared = {}
            if istable(row) then
                if row.divider then
                    prepared.type = "divider"
                    sectionHeight = sectionHeight + 10
                    preparedRows[#preparedRows + 1] = prepared
                else
                    prepared.label = resolveText(row.label or row.name or row.key or row[1])
                    prepared.value = resolveText(row.value or row[2])
                    prepared.text = resolveText(row.text)
                    if prepared.text == "" and prepared.label ~= "" and prepared.value == "" and not row.value and not row[2] then
                        prepared.text = prepared.label
                        prepared.label = ""
                    end

                    if truncateTextRows and prepared.text ~= "" and prepared.label == "" and prepared.value == "" then prepared.text = fitTextToWidth(prepared.text, maxTextRowWidth, rowFont, textRowSuffix) end
                    surface.SetFont(rowFont)
                    local labelWidth = prepared.label ~= "" and surface.GetTextSize(prepared.label) or 0
                    local textWidth = prepared.text ~= "" and surface.GetTextSize(prepared.text) or 0
                    surface.SetFont(valueFont)
                    local valueWidth = prepared.value ~= "" and surface.GetTextSize(prepared.value) or 0
                    measuredWidth = math.max(measuredWidth, labelWidth + valueWidth + padding * 2 + columnGap, textWidth + padding * 2)
                    sectionHeight = sectionHeight + rowHeight
                    preparedRows[#preparedRows + 1] = prepared
                end
            else
                prepared.text = resolveText(row)
                if truncateTextRows and prepared.text ~= "" then prepared.text = fitTextToWidth(prepared.text, maxTextRowWidth, rowFont, textRowSuffix) end
                surface.SetFont(rowFont)
                local textWidth = surface.GetTextSize(prepared.text)
                measuredWidth = math.max(measuredWidth, textWidth + padding * 2)
                sectionHeight = sectionHeight + rowHeight
                preparedRows[#preparedRows + 1] = prepared
            end
        end

        preparedSections[#preparedSections + 1] = {
            title = sectionTitle,
            rows = preparedRows,
            height = sectionHeight
        }

        totalHeight = totalHeight + sectionHeight + sectionGap
    end

    if #preparedSections > 0 then totalHeight = totalHeight - sectionGap end
    totalHeight = totalHeight + padding
    local defaultWidth = debugLayout and 430 or 360
    local boxWidth = options.width or math.Clamp(math.max(defaultWidth, measuredWidth), minWidth, maxWidth)
    if options.autoSize == false and options.width then boxWidth = options.width end
    local boxHeight = options.height or totalHeight
    local boxX = x or 0
    if textAlignX == TEXT_ALIGN_RIGHT then
        boxX = boxX - boxWidth
    elseif textAlignX == TEXT_ALIGN_CENTER then
        boxX = boxX - boxWidth * 0.5
    end

    local boxY = y or 0
    if textAlignY == TEXT_ALIGN_BOTTOM then
        boxY = boxY - boxHeight
    elseif textAlignY == TEXT_ALIGN_CENTER then
        boxY = boxY - boxHeight * 0.5
    end

    if drawBoxFrame ~= FrameNumber() then
        drawBoxOverlaps = {}
        drawBoxFrame = FrameNumber()
    end

    local screenW, screenH = ScrW(), ScrH()
    local function intersects(cx, cy)
        for _, rect in ipairs(drawBoxOverlaps) do
            if cx < rect.x + rect.w + overlapMargin and cx + boxWidth + overlapMargin > rect.x and cy < rect.y + rect.h + overlapMargin and cy + boxHeight + overlapMargin > rect.y then return rect end
        end
    end

    boxX = math.Clamp(boxX, 0, math.max(0, screenW - boxWidth))
    boxY = math.Clamp(boxY, 0, math.max(0, screenH - boxHeight))
    local overlap = intersects(boxX, boxY)
    local attempts = 0
    while overlap and attempts < 8 do
        local down = overlap.y + overlap.h + overlapMargin
        local up = overlap.y - boxHeight - overlapMargin
        local nextY = down + boxHeight <= screenH and down or math.max(0, up)
        boxY = math.Clamp(nextY, 0, math.max(0, screenH - boxHeight))
        overlap = intersects(boxX, boxY)
        attempts = attempts + 1
    end

    local shadow = options.shadow or {
        enabled = true,
        color = Color(0, 0, 0, 125),
        offsetX = 8,
        offsetY = 14
    }

    local blur = options.blur or {
        enabled = true,
        amount = 2,
        passes = 2,
        alpha = 0.65
    }

    if shadow.enabled then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Rad(borderRadius):Color(shadow.color or Color(0, 0, 0, 125)):Shadow(shadow.offsetX or 8, shadow.offsetY or 14):Shape(lia.derma.SHAPE_IOS):Draw() end
    drawBlurAt(boxX, boxY, boxWidth, boxHeight, blur)
    lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Rad(borderRadius):Color(backgroundColor):Shape(lia.derma.SHAPE_IOS):Draw()
    if borderThickness > 0 then lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Rad(borderRadius):Color(borderColor):Shape(lia.derma.SHAPE_IOS):Outline(borderThickness):Draw() end
    surface.SetDrawColor(accent.r, accent.g, accent.b, options.accentAlpha or 210)
    surface.DrawRect(boxX, boxY + 1, 3, math.min(22, boxHeight - 2))
    local currentY = boxY + padding
    if titleText ~= "" then
        draw.SimpleText(string.upper(titleText), titleFont, boxX + padding + titleInset, currentY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(255, 255, 255, 18)
        surface.SetFont(titleFont)
        local headerWidth = surface.GetTextSize(string.upper(titleText))
        surface.DrawRect(boxX + padding + titleInset + headerWidth + 4, currentY + 9, math.max(0, boxWidth - padding * 2 - titleInset - headerWidth - 4), 1)
        currentY = currentY + math.max(titleHeight, 18) + 14
    end

    for sectionIndex, section in ipairs(preparedSections) do
        if section.title ~= "" then
            draw.SimpleText(string.upper(section.title), sectionFont, boxX + padding, currentY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetFont(sectionFont)
            local sectionWidth = surface.GetTextSize(string.upper(section.title))
            surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
            surface.DrawRect(boxX + padding + sectionWidth + 14, currentY + 8, math.max(0, boxWidth - padding * 2 - sectionWidth - 14), 1)
            currentY = currentY + 26
        end

        for _, row in ipairs(section.rows) do
            if row.type == "divider" then
                surface.SetDrawColor(255, 255, 255, 14)
                surface.DrawRect(boxX + padding, currentY + 5, boxWidth - padding * 2, 1)
                currentY = currentY + 10
            elseif row.text ~= "" then
                draw.SimpleText(row.text, rowFont, boxX + padding, currentY + math.floor(rowHeight * 0.5), textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                currentY = currentY + rowHeight
            else
                draw.SimpleText(row.label, rowFont, boxX + padding, currentY + math.floor(rowHeight * 0.5), mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(row.value, valueFont, boxX + boxWidth - padding, currentY + math.floor(rowHeight * 0.5), textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                currentY = currentY + rowHeight
            end
        end

        if sectionIndex < #preparedSections then currentY = currentY + sectionGap end
    end

    drawBoxOverlaps[#drawBoxOverlaps + 1] = {
        x = boxX,
        y = boxY,
        w = boxWidth,
        h = boxHeight
    }
    return boxWidth, boxHeight
end

function lia.derma.drawSurfaceTexture(material, color, x, y, w, h)
    surface.SetDrawColor(color or Color(255, 255, 255))
    if isstring(material) then
        surface.SetMaterial(lia.util.getMaterial(material))
    else
        surface.SetMaterial(material)
    end

    surface.DrawTexturedRect(x, y, w, h)
end

function lia.derma.skinFunc(name, panel, a, b, c, d, e, f, g)
    local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
    if not skin then return end
    local func = skin[name]
    if not func then return end
    return func(skin, panel, a, b, c, d, e, f, g)
end

function lia.derma.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

function lia.derma.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

function lia.derma.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

function lia.derma.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)
    scaleFactor = scaleFactor or 0.8
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alphaDuration = (alphaDuration and alphaDuration > 0) and alphaDuration or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or durationtion or duration
    local targetX, targetY = panel:GetPos()
    local initialW = targetWidth * (scaleFactor and scaleFactor or scaleFactor)
    local initialH = targetHeight * (scaleFactor and scaleFactor or scaleFactor)
    local initialX = targetX + (targetWidth - initialW) / 2
    local initialY = targetY + (targetHeight - initialH) / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2
    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)
    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0
    local eps = 0.5
    local alpha_eps = 1
    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alphaDuration)
    panel.Think = function()
        if not IsValid(panel) then return end
        local dt = FrameTime()
        curW = lia.derma.approachExp(curW, targetWidth, speedSize, dt)
        curH = lia.derma.approachExp(curH, targetHeight, speedSize, dt)
        curX = lia.derma.approachExp(curX, targetX, speedSize, dt)
        curY = lia.derma.approachExp(curY, targetY, speedSize, dt)
        curA = lia.derma.approachExp(curA, 255, speedAlpha, dt)
        panel:SetSize(curW, curH)
        panel:SetPos(curX, curY)
        panel:SetAlpha(math.floor(curA + 0.5))
        local doneSize = math.abs(curW - targetWidth) <= eps and math.abs(curH - targetHeight) <= eps <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps
        if doneSize and donePos and doneAlpha then
            panel:SetSize(targetWidth, targetHeight)
            panel:SetPos(targetX, targetY)
            panel:SetAlpha(255)
            panel.Think = nil
            if callback then callback(panel) end
        end
    end
end

function lia.derma.clampMenuPosition(panel)
    if not IsValid(panel) then return end
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = ScrW(), ScrH()
    if x < 5 then
        x = 5
    elseif x + w > sw - 5 then
        x = sw - 5 - w
    end

    if y < 5 then
        y = 5
    elseif y + h > sh - 5 then
        y = sh - 5 - h
    end

    panel:SetPos(x, y)
end

function lia.derma.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)
    local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
    radius = radius and radius or 0
    lia.derma.drawMaterial(radius, x, y, w, h, colorShadow, listGradients[direction], flags)
end

function lia.derma.wrapText(text, width, font)
    font = font or "LiliaFont.16"
    surface.SetFont(font)
    local exploded = string.Explode("%s", text, true)
    local line = ""
    local lines = {}
    local w = surface.GetTextSize(text)
    local maxW = 0
    if w <= width then
        text, _ = text:gsub("%s", " ")
        return {text}, w
    end

    for i = 1, #exploded do
        local word = exploded[i]
        line = line .. " " .. word
        w = surface.GetTextSize(line)
        if w > width then
            lines[#lines + 1] = line
            line = ""
            if w > maxW then maxW = w end
        end
    end

    if line ~= "" then lines[#lines + 1] = line end
    return lines, maxW
end

function lia.derma.drawBlur(panel, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x, y = panel:LocalToScreen(0, 0)
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end

function lia.derma.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
    if not IsValid(panel) then return end
    amount = amount or 6
    passes = math.max(1, passes or 5)
    alpha = alpha or 255
    darkAlpha = darkAlpha or 220
    local mat = lia.util.getMaterial("pp/blurscreen")
    local x, y = panel:LocalToScreen(0, 0)
    x = math.floor(x)
    y = math.floor(y)
    local sw, sh = ScrW(), ScrH()
    local expand = 4
    render.UpdateScreenEffectTexture()
    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, alpha)
    for i = 1, passes do
        mat:SetFloat("$blur", i / passes * amount)
        mat:Recompute()
        surface.DrawTexturedRectUV(-x - expand, -y - expand, sw + expand * 2, sh + expand * 2, 0, 0, 1, 1)
    end

    surface.SetDrawColor(0, 0, 0, darkAlpha)
    surface.DrawRect(x, y, panel:GetWide(), panel:GetTall())
end

function lia.derma.drawBlurAt(x, y, w, h, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x2, y2 = x / ScrW(), y / ScrH()
    local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
    end
end

function lia.derma.requestArguments(title, argTypes, onSubmit, defaults)
    defaults = defaults or {}
    local count = table.Count(argTypes)
    local frameW, frameH = 600, math.min(450 + count * 135, ScrH() * 0.5)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:SetCenterTitle(title or "Enter arguments...")
    frame:SetZPos(1000)
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 40, 10, 10)
    surface.SetFont("LiliaFont.17")
    local controls, watchers = {}, {}
    local validate
    local ordered = {}
    local grouped = {
        strings = {},
        dropdowns = {},
        bools = {},
        rest = {}
    }

    local isOrdered = istable(argTypes) and #argTypes > 0 and istable(argTypes[1])
    if isOrdered then
        for _, argInfo in ipairs(argTypes) do
            local name, typeInfo = argInfo[1], argInfo[2]
            local fieldType, dataTbl, defaultVal = typeInfo, nil, nil
            if istable(typeInfo) then
                fieldType, dataTbl = typeInfo[1], typeInfo[2]
                if typeInfo[3] ~= nil then defaultVal = typeInfo[3] end
            end

            fieldType = string.lower(tostring(fieldType))
            if defaultVal == nil and defaults[name] ~= nil then defaultVal = defaults[name] end
            local info = {
                name = name,
                fieldType = fieldType,
                dataTbl = dataTbl,
                defaultVal = defaultVal
            }

            table.insert(ordered, info)
        end
    else
        for name, typeInfo in pairs(argTypes) do
            local fieldType, dataTbl, defaultVal = typeInfo, nil, nil
            if istable(typeInfo) then
                fieldType, dataTbl = typeInfo[1], typeInfo[2]
                if typeInfo[3] ~= nil then defaultVal = typeInfo[3] end
            end

            fieldType = string.lower(tostring(fieldType))
            if defaultVal == nil and defaults[name] ~= nil then defaultVal = defaults[name] end
            local info = {
                name = name,
                fieldType = fieldType,
                dataTbl = dataTbl,
                defaultVal = defaultVal
            }

            if fieldType == "string" then
                table.insert(grouped.strings, info)
            elseif fieldType == "table" then
                table.insert(grouped.dropdowns, info)
            elseif fieldType == "boolean" then
                table.insert(grouped.bools, info)
            else
                table.insert(grouped.rest, info)
            end
        end

        for _, group in ipairs({grouped.strings, grouped.dropdowns, grouped.bools, grouped.rest}) do
            for _, v in ipairs(group) do
                table.insert(ordered, v)
            end
        end
    end

    for _, info in ipairs(ordered) do
        local name, fieldType, dataTbl, defaultVal = info.name, info.fieldType, info.dataTbl, info.defaultVal
        if not name or name == "" then continue end
        local panel = vgui.Create("DPanel", scroll)
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 15)
        panel:SetTall(120)
        panel.Paint = nil
        local label = vgui.Create("DLabel", panel)
        label:SetFont("LiliaFont.20")
        label:SetText(name)
        label:SizeToContents()
        local textW = select(1, surface.GetTextSize(name))
        local ctrl
        local isBool = fieldType == "boolean"
        if isBool then
            ctrl = vgui.Create("liaCheckbox", panel)
            if defaultVal ~= nil then ctrl:SetChecked(tobool(defaultVal)) end
        elseif fieldType == "table" then
            ctrl = vgui.Create("liaComboBox", panel)
            local defaultChoiceIndex
            if istable(dataTbl) then
                for idx, v in ipairs(dataTbl) do
                    if istable(v) then
                        ctrl:AddChoice(v[1], v[2])
                        if defaultVal ~= nil and (v[2] == defaultVal or v[1] == defaultVal) then defaultChoiceIndex = idx end
                    else
                        ctrl:AddChoice(tostring(v))
                        if defaultVal ~= nil and v == defaultVal then defaultChoiceIndex = idx end
                    end
                end
            end

            if defaultChoiceIndex then ctrl:ChooseOptionID(defaultChoiceIndex) end
            ctrl:FinishAddingOptions()
            ctrl:PostInit()
        elseif fieldType == "int" or fieldType == "number" then
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetTitle("")
            if ctrl.SetNumeric then ctrl:SetNumeric(true) end
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        elseif fieldType == "player" then
            ctrl = vgui.Create("liaComboBox", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetPlaceholder("Select")
            ctrl:AddChoice("Select", "")
            for _, pl in player.Iterator() do
                if IsValid(pl) then ctrl:AddChoice(pl:Name(), pl:SteamID()) end
            end

            ctrl:FinishAddingOptions()
            ctrl:PostInit()
            if defaultVal ~= nil then
                for i = 1, ctrl:GetOptionCount() do
                    local choiceText, choiceData = ctrl:GetOptionText(i), ctrl:GetOptionData(i)
                    if choiceData == defaultVal or choiceText == defaultVal then
                        ctrl:ChooseOptionID(i)
                        break
                    end
                end
            end
        else
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("LiliaFont.17")
            ctrl:SetTitle("")
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        end

        panel.PerformLayout = function(_, w, h)
            local ctrlH, ctrlW
            if isBool then
                ctrlH, ctrlW = 22, 60
            else
                ctrlH, ctrlW = 60, w * 0.85
            end

            local ctrlX = (w - ctrlW) / 2
            ctrl:SetPos(ctrlX, (h - ctrlH) / 2 + 6)
            ctrl:SetSize(ctrlW, ctrlH)
            label:SetPos((w - textW) / 2, (h - ctrlH) / 2 - 25)
        end

        controls[name] = {
            ctrl = ctrl,
            type = fieldType
        }

        watchers[#watchers + 1] = function()
            local function trigger()
                validate()
            end

            ctrl.OnValueChange, ctrl.OnTextChanged, ctrl.OnChange, ctrl.OnSelect = trigger, trigger, trigger, trigger
        end
    end

    local btnPanel = vgui.Create("DPanel", frame)
    btnPanel:Dock(BOTTOM)
    btnPanel:SetTall(90)
    btnPanel:DockPadding(15, 15, 15, 15)
    btnPanel.Paint = nil
    local submit = vgui.Create("liaButton", btnPanel)
    submit:Dock(LEFT)
    submit:DockMargin(0, 0, 15, 0)
    submit:SetWide(270)
    submit:SetTxt("Submit")
    submit:SetEnabled(false)
    local cancel = vgui.Create("liaButton", btnPanel)
    cancel:Dock(RIGHT)
    cancel:SetWide(270)
    cancel:SetTxt("Cancel")
    cancel.DoClick = function()
        if isfunction(onSubmit) then onSubmit(false) end
        frame:Remove()
    end

    validate = function()
        for _, data in pairs(controls) do
            local ctl, ftype, ok = data.ctrl, data.type, true
            if ftype == "boolean" then
                ok = true
            elseif ctl.GetSelected then
                local txt = select(1, ctl:GetSelected())
                ok = txt and txt ~= "" and txt ~= "Select" and txt ~= "Choose"
            elseif ctl.GetValue then
                local val = ctl:GetValue()
                if ftype == "int" or ftype == "number" then
                    ok = val ~= nil and val ~= "" and tonumber(val) ~= nil
                else
                    ok = val ~= nil and val ~= "" and val ~= "nil"
                end
            end

            if not ok then
                submit:SetEnabled(false)
                return
            end
        end

        submit:SetEnabled(true)
    end

    for _, fn in ipairs(watchers) do
        fn()
    end

    validate()
    submit.DoClick = function()
        local result = {}
        for k, data in pairs(controls) do
            local ctl, ftype = data.ctrl, data.type
            if ftype == "boolean" then
                result[k] = ctl:GetChecked()
            elseif ctl.GetSelected then
                local txt, val = ctl:GetSelected()
                result[k] = val or txt
            else
                local val = ctl:GetValue()
                result[k] = (ftype == "int" or ftype == "number") and tonumber(val) or val
            end
        end

        if isfunction(onSubmit) then onSubmit(true, result) end
        frame:Remove()
    end

    frame.OnClose = function() if isfunction(onSubmit) then onSubmit(false) end end
end

function lia.derma.createTableUI(title, columns, data, options, charID)
    if IsValid(lia.gui.menuTableUI) then lia.gui.menuTableUI:Remove() end
    local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
    local frame = vgui.Create("liaDListView")
    lia.gui.menuTableUI = frame
    frame:SetWindowTitle(title and tostring(title) or "Table List")
    frame:SetSize(frameWidth, frameHeight)
    frame:Center()
    frame:MakePopup()
    if IsValid(frame.topBar) then frame.topBar:Remove() end
    if IsValid(frame.statusBar) then frame.statusBar:Remove() end
    local listView = frame.listView
    listView:Dock(FILL)
    listView:Clear()
    if listView.ClearColumns then listView:ClearColumns() end
    for _, colInfo in ipairs(columns or {}) do
        local localizedName = colInfo.name and tostring(colInfo.name) or "N/A"
        local col = listView:AddColumn(localizedName)
        surface.SetFont(col.Header:GetFont())
        local textW = surface.GetTextSize(localizedName)
        local minWidth = textW + 16
        col:SetMinWidth(minWidth)
        col:SetWidth(colInfo.width or minWidth)
    end

    for _, row in ipairs(data) do
        local lineData = {}
        for _, colInfo in ipairs(columns) do
            table.insert(lineData, row[colInfo.field] or "N/A")
        end

        local line = listView:AddLine(unpack(lineData))
        line.rowData = row
    end

    listView.OnRowRightClick = function(_, _, line)
        if not IsValid(line) or not line.rowData then return end
        local rowData = line.rowData
        local menu = lia.derma.dermaMenu()
        menu:AddOption("Copy Row", function()
            local rowString = ""
            for key, value in pairs(rowData) do
                value = tostring(value or "N/A")
                rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
        end)

        for _, option in ipairs(istable(options) and options or {}) do
            menu:AddOption(option.name and tostring(option.name) or option.name, function()
                if not option.net then return end
                if option.ExtraFields then
                    local inputPanel = vgui.Create("liaFrame")
                    inputPanel:SetTitle(string.format("%s Options", option.name))
                    inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                    inputPanel:Center()
                    inputPanel:MakePopup()
                    local form = vgui.Create("DForm", inputPanel)
                    form:Dock(FILL)
                    form:SetLabel("")
                    form.Paint = function() end
                    local inputs = {}
                    for fName, fType in pairs(option.ExtraFields) do
                        local label = vgui.Create("DLabel", form)
                        label:SetText(fName)
                        label:Dock(TOP)
                        label:DockMargin(5, 10, 5, 0)
                        form:AddItem(label)
                        if isstring(fType) and fType == "text" then
                            local entry = vgui.Create("DTextEntry", form)
                            entry:Dock(TOP)
                            entry:DockMargin(5, 5, 5, 0)
                            entry:SetPlaceholderText(string.format("Type %s", fName))
                            form:AddItem(entry)
                            inputs[fName] = {
                                panel = entry,
                                ftype = "text"
                            }
                        elseif isstring(fType) and fType == "combo" then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(string.format("Select %s", fName))
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        elseif istable(fType) then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(string.format("Select %s", fName))
                            for _, choice in ipairs(fType) do
                                combo:AddChoice(choice)
                            end

                            combo:FinishAddingOptions()
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        end
                    end

                    local submitButton = vgui.Create("DButton", form)
                    submitButton:SetText("Submit")
                    submitButton:Dock(TOP)
                    submitButton:DockMargin(5, 10, 5, 0)
                    form:AddItem(submitButton)
                    submitButton.DoClick = function()
                        local values = {}
                        for fName, info in pairs(inputs) do
                            if not IsValid(info.panel) then continue end
                            if info.ftype == "text" then
                                values[fName] = info.panel:GetValue() or ""
                            elseif info.ftype == "combo" then
                                values[fName] = info.panel:GetSelected() or ""
                            end
                        end

                        net.Start(option.net)
                        net.WriteInt(charID, 32)
                        net.WriteTable(rowData)
                        for _, fVal in pairs(values) do
                            if isnumber(fVal) then
                                net.WriteInt(fVal, 32)
                            else
                                net.WriteString(fVal)
                            end
                        end

                        net.SendToServer()
                        inputPanel:Close()
                        frame:Remove()
                    end
                else
                    net.Start(option.net)
                    net.WriteInt(charID, 32)
                    net.WriteTable(rowData)
                    net.SendToServer()
                    frame:Remove()
                end
            end)
        end

        menu:Open()
    end

    frame.OnRemove = function() if lia.gui.menuTableUI == frame then lia.gui.menuTableUI = nil end end
    return frame, listView
end

function lia.derma.openOptionsMenu(title, options)
    if not istable(options) then return end
    lia.gui = lia.gui or {}
    if IsValid(lia.gui.menuOpenOptions) then lia.gui.menuOpenOptions:Remove() end
    local config = istable(options._config) and options._config or {}
    local function resolveText(value)
        if value == nil then return "" end
        if isstring(value) and L then
            local ok, localized = pcall(lia.lang.resolve, value)
            if ok and localized and localized ~= "" then return tostring(localized) end
        end
        return tostring(value)
    end

    local function shouldShowOption(option)
        if not istable(option) or not option.shouldShow then return true end
        local ok, result = pcall(option.shouldShow, LocalPlayer())
        return ok and result ~= false
    end

    local entries = {}
    local sequential = options[1] ~= nil
    if sequential then
        for _, opt in ipairs(options) do
            if istable(opt) then
                local callback = opt.callback or opt.onRun
                if isfunction(callback) and shouldShowOption(opt) then
                    entries[#entries + 1] = {
                        name = opt.name or opt.label or opt.title or opt.id,
                        category = opt.category or opt.group or opt.section or config.defaultCategory or "actions",
                        icon = opt.icon,
                        callback = callback,
                        tooltip = opt.tooltip or opt.description or opt.desc,
                        textColor = opt.textColor,
                        accentColor = opt.accentColor,
                        closeOnSelect = opt.closeOnSelect,
                        passContext = opt.passContext
                    }
                end
            end
        end
    else
        for name, value in pairs(options) do
            if name ~= "_config" then
                if isfunction(value) then
                    entries[#entries + 1] = {
                        name = name,
                        category = config.defaultCategory or "actions",
                        callback = value
                    }
                elseif istable(value) then
                    local callback = value.callback or value.onRun
                    if isfunction(callback) and shouldShowOption(value) then
                        entries[#entries + 1] = {
                            name = value.name or value.label or value.title or name,
                            category = value.category or value.group or value.section or config.defaultCategory or "actions",
                            icon = value.icon,
                            callback = callback,
                            tooltip = value.tooltip or value.description or value.desc,
                            textColor = value.textColor,
                            accentColor = value.accentColor,
                            closeOnSelect = value.closeOnSelect,
                            passContext = value.passContext
                        }
                    end
                end
            end
        end

        table.sort(entries, function(a, b) return resolveText(a.name):lower() < resolveText(b.name):lower() end)
    end

    if #entries == 0 then return end
    local theme = lia.color and lia.color.theme or {}
    local accent = config.accentColor or theme.accent or theme.theme or lia.config.get("Color") or Color(164, 106, 54)
    local backgroundColor = config.backgroundColor or Color(3, 18, 22, 242)
    local borderColor = config.borderColor or Color(accent.r, accent.g, accent.b, 115)
    local textColor = config.textColor or theme.text or Color(235, 240, 242)
    local mutedTextColor = config.mutedTextColor or theme.gray or Color(150, 170, 172)
    local frameW = config.width or config.frameW or 420
    local padding = config.padding or 16
    local headerH = config.headerHeight or 54
    local rowH = config.rowHeight or config.entryH or 38
    local rowGap = config.rowGap or 4
    local categoryH = config.categoryHeight or 28
    local sectionGap = config.sectionGap or 10
    local categoryOrder = {}
    local categorized = {}
    for _, entry in ipairs(entries) do
        local category = resolveText(entry.category)
        if category == "" then category = resolveText(config.defaultCategory or "actions") end
        if not categorized[category] then
            categorized[category] = {}
            categoryOrder[#categoryOrder + 1] = category
        end

        categorized[category][#categorized[category] + 1] = entry
    end

    local contentH = 0
    for _, category in ipairs(categoryOrder) do
        contentH = contentH + categoryH + 4
        contentH = contentH + #categorized[category] * (rowH + rowGap)
        contentH = contentH + sectionGap
    end

    if #categoryOrder > 0 then contentH = contentH - sectionGap end
    local maxHeight = config.maxHeight or ScrH() * 0.72
    local frameH = math.Clamp(headerH + padding + contentH + padding, config.minHeight or 160, maxHeight)
    local frameX = config.x or ScrW() - frameW - (config.screenPadding or 28)
    local frameY = config.y or math.max(80, (ScrH() - frameH) * 0.5)
    frameX = math.Clamp(frameX, 8, math.max(8, ScrW() - frameW - 8))
    frameY = math.Clamp(frameY, 8, math.max(8, ScrH() - frameH - 8))
    local frame = vgui.Create("DPanel")
    lia.gui.menuOpenOptions = frame
    frame:SetSize(frameW, frameH)
    frame:SetPos(frameX + 10, frameY)
    frame:SetDrawOnTop(true)
    frame:SetZPos(config.zPos or 10000)
    frame:SetAlpha(0)
    frame:MakePopup()
    frame:AlphaTo(255, config.fadeSpeed or 0.1)
    frame:MoveTo(frameX, frameY, config.slideSpeed or 0.12, 0, -1)
    frame.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(0, 0, 0, 150)):Shadow(8, 18):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(8):Color(backgroundColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(8):Color(borderColor):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
        surface.SetDrawColor(accent.r, accent.g, accent.b, 190)
        surface.DrawRect(0, 0, w, 2)
        surface.DrawRect(padding, 18, 3, 20)
        draw.SimpleText(string.upper(resolveText(title or "Options")), config.titleFont or "LiliaFont.20", padding + 16, headerH * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
        surface.DrawRect(padding, headerH - 1, w - padding * 2, 1)
    end

    local closeButton = frame:Add("DButton")
    closeButton:SetSize(34, 34)
    closeButton:SetPos(frameW - padding - 34, 10)
    closeButton:SetText("")
    closeButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        if hovered then lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(255, 255, 255, 12)):Shape(lia.derma.SHAPE_IOS):Draw() end
        draw.SimpleText("×", "LiliaFont.25", w * 0.5, h * 0.5 - 1, hovered and color_white or mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    closeButton.DoClick = function()
        lia.webcontent.playButtonSound()
        frame:AlphaTo(0, config.fadeSpeed or 0.1, 0, function() if IsValid(frame) then frame:Remove() end end)
    end

    local scroll = frame:Add("liaScrollPanel")
    scroll:SetPos(0, headerH + padding)
    scroll:SetSize(frameW, frameH - headerH - padding * 2)
    scroll.Paint = function() end
    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    local function resolveMaterial(icon)
        if type(icon) == "IMaterial" then return icon end
        if isstring(icon) and icon ~= "" then return Material(icon, "smooth") end
        if config.showFallbackIcons == false then return end
        return Material(config.fallbackIcon or "icon16/bullet_white.png", "smooth")
    end

    local function drawOptionIcon(icon, xPos, yPos, size, color)
        local material = resolveMaterial(icon)
        if not material or material:IsError() then return end
        surface.SetMaterial(material)
        surface.SetDrawColor(color.r, color.g, color.b, color.a or 255)
        surface.DrawTexturedRect(xPos, yPos, size, size)
    end

    for categoryIndex, category in ipairs(categoryOrder) do
        local categoryPanel = vgui.Create("DPanel", layout)
        categoryPanel:SetTall(categoryH)
        categoryPanel:Dock(TOP)
        categoryPanel:DockMargin(padding, categoryIndex == 1 and 0 or sectionGap, padding, 4)
        categoryPanel.Paint = function(_, w, h)
            local categoryText = string.upper(category)
            draw.SimpleText(categoryText, config.categoryFont or "LiliaFont.16", 0, h * 0.5, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetFont(config.categoryFont or "LiliaFont.16")
            local categoryWidth = surface.GetTextSize(categoryText)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
            surface.DrawRect(categoryWidth + 14, h * 0.5, math.max(0, w - categoryWidth - 14), 1)
        end

        layout:Add(categoryPanel)
        for _, entry in ipairs(categorized[category]) do
            local button = vgui.Create("DButton", layout)
            button:SetTall(rowH)
            button:Dock(TOP)
            button:DockMargin(padding, 0, padding, rowGap)
            button:SetText("")
            button:SetCursor("hand")
            button.Paint = function(self, w, h)
                local hovered = self:IsHovered()
                local entryAccent = entry.accentColor or accent
                local rowColor = hovered and Color(255, 255, 255, 22) or Color(255, 255, 255, 7)
                lia.derma.rect(0, 0, w, h):Rad(4):Color(rowColor):Shape(lia.derma.SHAPE_IOS):Draw()
                if hovered then
                    surface.SetDrawColor(entryAccent.r, entryAccent.g, entryAccent.b, 210)
                    surface.DrawRect(0, 0, 3, h)
                    lia.derma.rect(0, 0, w, h):Rad(4):Color(Color(entryAccent.r, entryAccent.g, entryAccent.b, 18)):Shape(lia.derma.SHAPE_IOS):Draw()
                end

                surface.SetDrawColor(255, 255, 255, hovered and 18 or 10)
                surface.DrawRect(10, h - 1, w - 20, 1)
                local drawColor = hovered and color_white or entry.textColor or textColor
                local iconColor = hovered and drawColor or mutedTextColor
                drawOptionIcon(entry.icon, 12, math.floor((h - 18) * 0.5), 18, iconColor)
                draw.SimpleText(resolveText(entry.name), config.buttonFont or "LiliaFont.17", 42, h * 0.5, drawColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            if entry.tooltip and entry.tooltip ~= "" then button:SetTooltip(resolveText(entry.tooltip)) end
            button.DoClick = function()
                lia.webcontent.playButtonSound()
                if entry.closeOnSelect ~= false then frame:AlphaTo(0, config.fadeSpeed or 0.1, 0, function() if IsValid(frame) then frame:Remove() end end) end
                local ok, err
                if entry.passContext == true then
                    ok, err = pcall(entry.callback, LocalPlayer(), frame, entry)
                elseif istable(entry.passContext) then
                    ok, err = pcall(entry.callback, unpack(entry.passContext))
                else
                    ok, err = pcall(entry.callback)
                end

                if not ok and ErrorNoHalt then ErrorNoHalt("[lia.derma.openOptionsMenu] " .. tostring(err) .. "\n") end
            end

            layout:Add(button)
        end
    end

    frame.OnRemove = function() if lia.gui.menuOpenOptions == frame then lia.gui.menuOpenOptions = nil end end
    return frame
end

local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta and vectorMeta.ToScreen or function()
    return {
        x = 0,
        y = 0,
        visible = false
    }
end

local defaultTheme = {
    background_alpha = Color(34, 34, 34, 210),
    header = Color(34, 34, 34, 210),
    accent = Color(255, 255, 255, 180),
    text = Color(255, 255, 255)
}

local function scaleColorAlpha(col, scale)
    col = col or defaultTheme.background_alpha
    local a = col.a or 255
    return Color(col.r, col.g, col.b, math.Clamp(a * scale, 0, 255))
end

local function EntText(text, x, y, fade)
    surface.SetFont("LiliaFont.40")
    local tw, th = surface.GetTextSize(text)
    local bx, by = math.Round(x - tw * 0.5 - 18), math.Round(y - 12)
    local bw, bh = tw + 36, th + 24
    local theme = lia.color.theme or defaultTheme
    local fadeAlpha = math.Clamp(fade, 0, 1)
    local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
    local accentColor = scaleColorAlpha(theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
    local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
    lia.derma.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
    lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
    draw.SimpleText(text, "LiliaFont.40", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    return bh
end

lia.derma.entsScales = lia.derma.entsScales or {}
function lia.derma.drawEntText(ent, text, posY, alphaOverride)
    timer.Simple(0, function() if derma.RefreshSkins then derma.RefreshSkins() end end)
    if not (IsValid(ent) and text and text ~= "") then return end
    posY = posY or 0
    local distSqr = EyePos():DistToSqr(ent:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end
    local dist = math.sqrt(distSqr)
    local minDist = 20
    local idx = ent:EntIndex()
    local prev = lia.derma.entsScales[idx] or 0
    local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
    local appearThreshold = 0.8
    local disappearThreshold = 0.01
    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed
    local cur = lia.derma.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    if cur == 0 and target == 0 then
        lia.derma.entsScales[idx] = nil
        return
    end

    lia.derma.entsScales[idx] = cur
    local eased = lia.derma.easeInOutCubic(cur)
    if eased <= 0 then return end
    local fade = eased
    if alphaOverride then
        if alphaOverride > 1 then
            fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
        else
            fade = fade * math.Clamp(alphaOverride, 0, 1)
        end
    end

    if fade <= 0 then return end
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local _, rotatedMax = ent:GetRotatedAABB(mins, maxs)
    local bob = math.sin(CurTime() + idx) / 3 + 0.5
    local center = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, math.abs(rotatedMax.z / 2) + 12 + bob)
    local screenPos = toScreen(center)
    if screenPos.visible == false then return end
    EntText(text, screenPos.x, screenPos.y + posY, fade)
end

local function resolveRequestText(text, fallback)
    if text == nil then return fallback end
    if istable(text) then
        local token = text[1]
        if isstring(token) and token:sub(1, 1) == "@" then
            return lia.lang.resolve(token, unpack(text, 2))
        elseif token ~= nil then
            return token
        end
        return fallback
    end

    if isstring(text) and text:sub(1, 1) == "@" then return lia.lang.resolve(text) end
    return text
end

local function resolveRequestOptionText(option)
    if istable(option) then
        local localized = table.Copy(option)
        if localized.text ~= nil then localized.text = resolveRequestText(localized.text, localized.text) end
        if localized[1] ~= nil then localized[1] = resolveRequestText(localized[1], localized[1]) end
        return localized
    end
    return resolveRequestText(option, option)
end

function lia.derma.requestDropdown(title, options, callback, defaultValue)
    if IsValid(lia.gui.menuRequestDropdown) then lia.gui.menuRequestDropdown:Remove() end
    local frameHeight = 200
    local frame = vgui.Create("liaFrame")
    frame:SetSize(340, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(resolveRequestText(title, "Select Option"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local dropdown = vgui.Create("liaComboBox", frame)
    dropdown:Dock(TOP)
    dropdown:DockMargin(24, 28, 24, 16)
    dropdown:SetTall(36)
    dropdown:SetMouseInputEnabled(true)
    dropdown:SetKeyboardInputEnabled(true)
    if istable(options) then
        for _, option in ipairs(options) do
            local displayOption = resolveRequestOptionText(option)
            if istable(displayOption) then
                dropdown:AddChoice(displayOption[1], displayOption[2])
            else
                dropdown:AddChoice(tostring(displayOption))
            end
        end
    end

    if defaultValue then
        if istable(defaultValue) then
            dropdown:ChooseOptionData(defaultValue[2])
        else
            dropdown:ChooseOption(tostring(defaultValue))
        end
    end

    dropdown:PostInit()
    if #options > 0 then
        local firstOption = resolveRequestOptionText(options[1])
        if istable(firstOption) then
            dropdown:ChooseOption(firstOption[1])
            dropdown.selectedText = firstOption[1]
            dropdown.selectedData = firstOption[2]
        else
            dropdown:ChooseOption(tostring(firstOption))
            dropdown.selectedText = tostring(firstOption)
        end
    end

    dropdown.OnSelect = function(_, _, value, data)
        dropdown.selectedText = value
        dropdown.selectedData = data
        dropdown.selected = value
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(24, 16, 24, 24)
    buttonPanel:SetTall(44)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(100)
    submitBtn:SetTxt("Select")
    submitBtn.DoClick = function()
        local selectedText = dropdown.selectedText or dropdown:GetValue()
        local selectedData = dropdown.selectedData or dropdown:GetSelectedData()
        if not selectedText and #options > 0 then
            local firstOption = resolveRequestOptionText(options[1])
            if istable(firstOption) then
                selectedText = firstOption[1]
                selectedData = firstOption[2]
            else
                selectedText = tostring(firstOption)
            end
        end

        if callback then
            if selectedData ~= nil then
                callback(selectedText, selectedData)
            else
                callback(selectedText)
            end
        end

        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(100)
    cancelBtn:SetTxt("Cancel")
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestDropdown = frame
    return frame
end

function lia.derma.requestString(title, description, callback, defaultValue, maxLength)
    if IsValid(lia.gui.menuRequestString) then lia.gui.menuRequestString:Remove() end
    local vendorPanel = lia.gui.vendor
    local vendorEditor = lia.gui.vendorEditor
    if IsValid(vendorPanel) then vendorPanel:SetVisible(false) end
    if IsValid(vendorEditor) then vendorEditor:SetVisible(false) end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(600, 300)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(resolveRequestText(title, "Enter Text"))
    frame:ShowAnimation()
    frame.OnRemove = function()
        if IsValid(vendorPanel) then vendorPanel:SetVisible(true) end
        if IsValid(vendorEditor) then vendorEditor:SetVisible(true) end
    end

    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 10)
    descriptionLabel:SetText(resolveRequestText(description, "Enter value..."))
    descriptionLabel:SetFont("LiliaFont.17")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local textEntry = vgui.Create("liaEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(20, 0, 20, 20)
    textEntry:SetTall(30)
    textEntry:SetTitle("")
    if defaultValue then textEntry:SetValue(tostring(defaultValue)) end
    if maxLength then textEntry:SetMaxLength(maxLength) end
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(120)
    submitBtn:SetTxt("Submit")
    submitBtn.DoClick = function()
        local value = textEntry:GetValue()
        if callback then callback(value) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(120)
    cancelBtn:SetTxt("Cancel")
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestString = frame
    return frame
end

function lia.derma.requestOptions(title, subTitle, options, callback, onCancel)
    if IsValid(lia.gui.menuRequestOptions) then lia.gui.menuRequestOptions:Remove() end
    local count = #options
    local frameW, frameH = 600, math.min(350 + count * 100, ScrH() * 0.5)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(resolveRequestText(title, string.format("Select %s", "Options")))
    if subTitle then
        local subTitleLabel = vgui.Create("DLabel", frame)
        subTitleLabel:SetText(resolveRequestText(subTitle, subTitle))
        subTitleLabel:SetFont("LiliaFont.18")
        subTitleLabel:SizeToContents()
        subTitleLabel:SetPos(10, 35)
        subTitleLabel:SetColor(Color(200, 200, 200))
    end

    frame:ShowAnimation()
    frame:SetZPos(1000)
    local scrollPanel = vgui.Create("liaScrollPanel", frame)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(10, 40, 10, 10)
    local controls = {}
    if istable(options) then
        for _, option in ipairs(options) do
            local optionName, optionData
            if istable(option) then
                optionName = option[1] or tostring(option[2])
                optionData = option[2]
            else
                optionName = tostring(option)
                optionData = option
            end

            optionName = resolveRequestText(optionName, optionName)
            local panel = vgui.Create("DPanel", scrollPanel)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 10)
            panel:SetTall(90)
            panel.Paint = nil
            local label = vgui.Create("DLabel", panel)
            label:SetFont("LiliaFont.20")
            label:SetText(optionName)
            label:SizeToContents()
            local textW = select(1, surface.GetTextSize(optionName))
            local ctrl
            if istable(optionData) then
                ctrl = vgui.Create("liaComboBox", panel)
                local defaultChoiceIndex
                for idx, v in ipairs(optionData) do
                    if istable(v) then
                        local displayValue = resolveRequestOptionText(v)
                        ctrl:AddChoice(displayValue[1], displayValue[2])
                        if defaults[optionName] ~= nil and (displayValue[2] == defaults[optionName] or displayValue[1] == defaults[optionName]) then defaultChoiceIndex = idx end
                    else
                        local displayValue = resolveRequestText(v, v)
                        ctrl:AddChoice(tostring(displayValue))
                        if defaults[optionName] ~= nil and displayValue == defaults[optionName] then defaultChoiceIndex = idx end
                    end
                end

                if defaultChoiceIndex then ctrl:ChooseOptionID(defaultChoiceIndex) end
                ctrl:FinishAddingOptions()
                ctrl:PostInit()
            else
                ctrl = vgui.Create("liaCheckbox", panel)
                ctrl:SetChecked(defaults and table.HasValue(defaults, optionData))
            end

            panel.PerformLayout = function(_, w, h)
                local ctrlH, ctrlW
                if ctrl:GetName() == "liaCheckbox" then
                    ctrlH, ctrlW = 22, 60
                else
                    ctrlH, ctrlW = 60, w * 0.85
                end

                local ctrlX = (w - ctrlW) / 2
                ctrl:SetPos(ctrlX, (h - ctrlH) / 2 + 6)
                ctrl:SetSize(ctrlW, ctrlH)
                label:SetPos((w - textW) / 2, (h - ctrlH) / 2 - 18)
            end

            controls[optionName] = {
                ctrl = ctrl,
                data = optionData
            }
        end
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(15, 15, 15, 15)
    buttonPanel:SetTall(90)
    buttonPanel.Paint = nil
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(LEFT)
    submitBtn:DockMargin(0, 0, 15, 0)
    submitBtn:SetWide(270)
    submitBtn:SetTxt("Submit")
    submitBtn.DoClick = function()
        local selectedOptions = {}
        for optionName, controlInfo in pairs(controls) do
            local ctrl = controlInfo.ctrl
            if ctrl:GetName() == "liaCheckbox" then
                if ctrl:GetChecked() then table.insert(selectedOptions, controlInfo.data) end
            elseif ctrl:GetName() == "liaComboBox" then
                local selectedText, selectedData = ctrl:GetSelected()
                if selectedData then
                    selectedOptions[optionName] = selectedData
                else
                    selectedOptions[optionName] = selectedText
                end
            end
        end

        if callback then callback(selectedOptions) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(RIGHT)
    cancelBtn:SetWide(270)
    cancelBtn:SetTxt("Cancel")
    cancelBtn.DoClick = function()
        if onCancel then onCancel() end
        frame:Remove()
    end

    lia.gui.menuRequestOptions = frame
    return frame
end

function lia.derma.requestBinaryQuestion(title, question, callback, yesText, noText)
    if IsValid(lia.gui.menuRequestBinary) then lia.gui.menuRequestBinary:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(450, 220)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(resolveRequestText(title, "Question"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local questionLabel = vgui.Create("DLabel", frame)
    questionLabel:Dock(TOP)
    questionLabel:DockMargin(20, 40, 20, 20)
    questionLabel:SetText(resolveRequestText(question, "Are you sure?"))
    questionLabel:SetFont("LiliaFont.18")
    questionLabel:SetTextColor(lia.color.theme.text or color_white)
    questionLabel:SetContentAlignment(5)
    questionLabel:SetWrap(true)
    questionLabel:SetAutoStretchVertical(true)
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local yesBtn = vgui.Create("liaButton", buttonPanel)
    yesBtn:Dock(RIGHT)
    yesBtn:DockMargin(10, 0, 0, 0)
    yesBtn:SetWide(140)
    yesBtn:SetTxt(resolveRequestText(yesText, "Yes"))
    yesBtn.DoClick = function()
        if callback then callback(true) end
        frame:Remove()
    end

    local noBtn = vgui.Create("liaButton", buttonPanel)
    noBtn:Dock(LEFT)
    noBtn:DockMargin(0, 0, 10, 0)
    noBtn:SetWide(140)
    noBtn:SetTxt(resolveRequestText(noText, "No"))
    noBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestBinary = frame
    return frame
end

function lia.derma.requestButtons(title, buttons, callback, description)
    if IsValid(lia.gui.menuRequestButtons) then lia.gui.menuRequestButtons:Remove() end
    local buttonCount = #buttons
    local frameHeight = 260 + (buttonCount * 45)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(350, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(resolveRequestText(title, "Select Option"))
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 20)
    descriptionLabel:SetText(resolveRequestText(description, ""))
    descriptionLabel:SetFont("LiliaFont.17")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local buttonContainer = vgui.Create("Panel", frame)
    buttonContainer:Dock(FILL)
    buttonContainer:DockMargin(20, 0, 20, 60)
    local buttonPanels = {}
    for i, buttonInfo in ipairs(buttons) do
        local buttonText = ""
        local buttonCallback = nil
        local buttonIcon = nil
        if istable(buttonInfo) then
            buttonText = buttonInfo.text or buttonInfo[1] or tostring(buttonInfo)
            buttonCallback = buttonInfo.callback or buttonInfo[2]
            buttonIcon = buttonInfo.icon or buttonInfo[3]
        else
            buttonText = tostring(buttonInfo)
        end

        buttonText = resolveRequestText(buttonText, buttonText)
        local buttonPanel = vgui.Create("Panel", buttonContainer)
        buttonPanel:Dock(TOP)
        buttonPanel:DockMargin(0, 5, 0, 5)
        buttonPanel:SetTall(40)
        local button = vgui.Create("liaButton", buttonPanel)
        button:Dock(FILL)
        button:DockMargin(0, 0, 0, 0)
        button:SetTxt(buttonText)
        if buttonIcon then button:SetIcon(buttonIcon) end
        button.DoClick = function()
            if buttonCallback then
                local result = buttonCallback()
                if result ~= false then frame:Remove() end
            else
                if callback then
                    local result = callback(i, buttonText)
                    if result ~= false then frame:Remove() end
                else
                    frame:Remove()
                end
            end
        end

        buttonPanels[i] = button
    end

    local closeBtn = vgui.Create("liaButton", frame)
    closeBtn:Dock(BOTTOM)
    closeBtn:DockMargin(20, 10, 20, 20)
    closeBtn:SetTall(40)
    closeBtn:SetTxt("Close")
    closeBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.gui.menuRequestButtons = frame
    return frame, buttonPanels
end

function lia.derma.requestPopupQuestion(question, buttons)
    if IsValid(lia.gui.menuRequestPopup) then lia.gui.menuRequestPopup:Remove() end
    local buttonCount = #buttons
    local frameHeight = 180 + (buttonCount * 45)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(400, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle("Question")
    frame:ShowAnimation()
    frame:SetZPos(1000)
    local questionLabel = vgui.Create("DLabel", frame)
    questionLabel:Dock(TOP)
    questionLabel:DockMargin(20, 40, 20, 20)
    questionLabel:SetText(resolveRequestText(question, "Are you sure?"))
    questionLabel:SetFont("LiliaFont.14")
    questionLabel:SetTextColor(lia.color.theme.text or color_white)
    questionLabel:SetContentAlignment(5)
    questionLabel:SizeToContents()
    local buttonContainer = vgui.Create("Panel", frame)
    buttonContainer:Dock(FILL)
    buttonContainer:DockMargin(20, 0, 20, 20)
    for _, buttonInfo in ipairs(buttons) do
        local buttonText
        local buttonCallback = nil
        if istable(buttonInfo) then
            buttonText = buttonInfo[1] or tostring(buttonInfo)
            buttonCallback = buttonInfo[2]
        else
            buttonText = tostring(buttonInfo)
        end

        buttonText = resolveRequestText(buttonText, buttonText)
        local buttonPanel = vgui.Create("Panel", buttonContainer)
        buttonPanel:Dock(TOP)
        buttonPanel:DockMargin(0, 5, 0, 5)
        buttonPanel:SetTall(40)
        local button = vgui.Create("liaButton", buttonPanel)
        button:Dock(FILL)
        button:SetTxt(buttonText)
        button.DoClick = function()
            if buttonCallback and isfunction(buttonCallback) then buttonCallback() end
            frame:Remove()
        end
    end

    lia.gui.menuRequestPopup = frame
    return frame
end
