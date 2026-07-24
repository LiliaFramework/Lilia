--[[
    Hooks:
        SetupQuickMenu(Panel menu)

    Purpose:
        Allows modules to populate the quick settings menu before it is sized and shown.

    Category:
        UI

    Parameters:
        menu (Panel)
            The quick menu panel instance that exposes helper methods like `addButton`, `addCheck`, and `addSpacer`.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("SetupQuickMenu", "liaExampleSetupQuickMenu", function(menu)
            menu:addButton("Example Action", function()
                LocalPlayer():ChatPrint("Example clicked.")
            end, "Runs an example quick action.")
        end)
        ```

    Realm:
        Client
]]
local cacheKeys, cache, len = {}, {}, 0
local function PaintPanel(_, w, h)
    local radius = 6
    local shadowIntensity = 8
    local shadowBlur = 12
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(Color(25, 28, 35, 250)):Draw()
end

local function PaintFrame(pnl, w, h)
    if not pnl.LaidOut then
        local btn = pnl.btnClose
        if btn and btn:IsValid() then
            btn:SetPos(w - 26, 4)
            btn:SetSize(24, 24)
            btn:SetFont("Marlett")
            btn:SetText("âœ•")
            btn:SetTextColor(Color(255, 255, 255))
            btn:PerformLayout()
        end

        pnl.LaidOut = true
    end

    lia.util.drawBlur(pnl, 10)
    local radius = 6
    local shadowIntensity = 8
    local shadowBlur = 12
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(Color(25, 28, 35, 250)):Draw()
end

local BlurredDFrame = {}
function BlurredDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
end

function BlurredDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function BlurredDFrame:Paint(w, h)
    PaintFrame(self, w, h)
end

vgui.Register("liaBlurredDFrame", BlurredDFrame, "DFrame")
local TransparentDFrame = {}
function TransparentDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
    self.m_bBackground = false
end

function TransparentDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function TransparentDFrame:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("liaSemiTransparentDFrame", TransparentDFrame, "DFrame")
local SimplePanel = {}
function SimplePanel:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("liaSemiTransparentDPanel", SimplePanel, "DPanel")
timer.Create("derma_convar_fix", 0.5, 0, function()
    if len == 0 then return end
    local name
    for i = 1, len do
        name = cache[i]
        RunConsoleCommand(name, cacheKeys[name])
        cacheKeys[name] = nil
        cache[i] = nil
    end

    len = 0
end)

function Derma_SetCvar_Safe(name, value)
    if not cacheKeys[name] then
        cacheKeys[name] = tostring(value)
        len = len + 1
        cache[len] = name
    else
        timer.Adjust("derma_convar_fix", 0.5)
        cacheKeys[name] = tostring(value)
    end
end

function Derma_Install_Convar_Functions(panel)
    function panel:SetConVar(strConVar)
        self.m_strConVar = strConVar
    end

    function panel:ConVarChanged(strNewValue)
        local cvar = self.m_strConVar
        if not cvar or string.len(cvar) < 2 then return end
        Derma_SetCvar_Safe(cvar, strNewValue)
    end

    function panel:SetConVar(name, isNumber)
        self.m_conVar = GetConVar(name)
        if not self.m_conVar then return end
        self.m_isNumber = isNumber
        self.m_prevValue = isNumber and self.m_conVar:GetFloat() or self.m_conVar:GetString()
        self:SetValue(self.m_prevValue)
    end

    function panel:Think()
        local cvar = self.m_conVar
        if not cvar then return end
        local current = self.m_isNumber and cvar:GetFloat() or cvar:GetString()
        if current ~= self.m_prevValue then
            self.m_prevValue = current
            self:SetValue(current)
        end
    end
end

local quickPaletteDefaults = {
    background = Color(4, 13, 17, 250),
    header = Color(5, 18, 23, 248),
    panel = Color(9, 24, 29, 242),
    panelHover = Color(14, 32, 38, 248),
    field = Color(5, 18, 23, 244),
    content = Color(3, 16, 21, 222),
    line = Color(67, 89, 91, 112),
    lineSoft = Color(67, 89, 91, 62),
    text = Color(230, 239, 239, 255),
    textMuted = Color(155, 178, 179, 255),
    accent = Color(188, 127, 67, 255),
    toggleOn = Color(45, 190, 170, 255),
    toggleOff = Color(55, 76, 78, 255),
    toggleKnob = Color(235, 243, 241, 255)
}

local quickPalette = table.Copy(quickPaletteDefaults)
local quickMaterials = {
    search = Material("icon16/magnifier.png", "smooth"),
    settings = Material("icon16/cog.png", "smooth")
}

local function quickColor(value, fallback, alpha)
    local color = IsColor(value) and value or fallback
    return Color(color.r, color.g, color.b, alpha or color.a or 255)
end

local function quickBlend(first, second, fraction, alpha)
    fraction = math.Clamp(tonumber(fraction) or 0, 0, 1)
    return Color(math.Round(Lerp(fraction, first.r, second.r)), math.Round(Lerp(fraction, first.g, second.g)), math.Round(Lerp(fraction, first.b, second.b)), alpha or math.Round(Lerp(fraction, first.a or 255, second.a or 255)))
end

local function quickDarken(color, fraction, alpha)
    return quickBlend(color, color_black, fraction, alpha)
end

local function quickAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

local function refreshQuickPalette()
    local theme = lia.color and lia.color.theme or {}
    local accent = quickColor(theme.accent or theme.theme or theme.maincolor or lia.config.get("Color"), quickPaletteDefaults.accent)
    local text = quickColor(theme.text or theme.text_entry, quickPaletteDefaults.text)
    local textMuted = quickColor(theme.desc or theme.header_text or theme.gray, quickPaletteDefaults.textMuted)
    local background = quickColor(theme.background_alpha or theme.background or theme.window, quickPaletteDefaults.background)
    local panel = quickColor(theme.button or theme.category or theme.panel or theme.background, quickPaletteDefaults.panel)
    local field = quickColor(theme.focus_panel or theme.text_entry_background or theme.category or theme.button, quickPaletteDefaults.field)
    local toggleOff = quickColor(theme.toggle or theme.gray, quickPaletteDefaults.toggleOff)
    local toggleKnob = quickColor(theme.text_entry or theme.text, quickPaletteDefaults.toggleKnob)
    quickPalette.background = quickDarken(quickBlend(background, accent, 0.05), 0.7, 250)
    quickPalette.header = quickDarken(quickBlend(background, accent, 0.08), 0.64, 248)
    quickPalette.panel = quickDarken(quickBlend(panel, accent, 0.07), 0.62, 242)
    quickPalette.panelHover = quickDarken(quickBlend(panel, accent, 0.16), 0.52, 248)
    quickPalette.field = quickDarken(quickBlend(field, accent, 0.08), 0.66, 244)
    quickPalette.content = quickDarken(quickBlend(background, accent, 0.04), 0.74, 226)
    quickPalette.line = quickAlpha(accent, 105)
    quickPalette.lineSoft = quickAlpha(accent, 48)
    quickPalette.text = text
    quickPalette.textMuted = textMuted
    quickPalette.accent = accent
    quickPalette.toggleOn = accent
    quickPalette.toggleOff = quickDarken(quickBlend(toggleOff, accent, 0.05), 0.28, 255)
    quickPalette.toggleKnob = toggleKnob
end

local quickSectionTitles = {
    camera = "CAMERA",
    hud = "HUD",
    controls = "CONTROLS",
    voice = "VOICE",
    thirdperson = "THIRD PERSON",
    general = "GENERAL"
}

local quickSectionOrder = {
    camera = 1,
    hud = 2,
    controls = 3,
    voice = 4,
    thirdperson = 5,
    general = 99
}

local function drawQuickOutlinedBox(x, y, w, h, radius, fillColor, borderColor)
    if w <= 0 or h <= 0 then return end
    draw.RoundedBox(radius, x, y, w, h, borderColor)
    draw.RoundedBox(math.max(radius - 1, 0), x + 1, y + 1, math.max(w - 2, 0), math.max(h - 2, 0), fillColor)
end

local function drawQuickLine(x, y, w, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawRect(x, y, w, 1)
end

local function drawQuickMaterial(material, x, y, size, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color.r, color.g, color.b, color.a or 255)
    surface.DrawTexturedRect(x, y, size, size)
end

local function quickLocalized(value)
    if not value or value == "" then return value end
    local localized = L(value)
    if localized and localized ~= "" then return localized end
    return value
end

local function quickEllipsizeText(text, font, maxWidth)
    text = tostring(text or "")
    if maxWidth <= 0 then return "" end
    surface.SetFont(font)
    if surface.GetTextSize(text) <= maxWidth then return text end
    local result = text
    while result ~= "" do
        result = string.sub(result, 1, #result - 1)
        if surface.GetTextSize(result .. "...") <= maxWidth then return result .. "..." end
    end
    return "..."
end

local function quickWrapText(text, font, maxWidth, maxLines)
    text = string.Trim(tostring(text or ""):gsub("%s+", " "))
    maxLines = maxLines or 2
    if text == "" then return {} end
    if maxWidth <= 0 then return {""} end
    surface.SetFont(font)
    local lines = {}
    local line = ""
    for word in text:gmatch("%S+") do
        local candidate = line == "" and word or line .. " " .. word
        if surface.GetTextSize(candidate) <= maxWidth then
            line = candidate
        else
            if line == "" then
                lines[#lines + 1] = quickEllipsizeText(word, font, maxWidth)
            else
                lines[#lines + 1] = line
                line = word
            end

            if #lines >= maxLines then
                lines[#lines] = quickEllipsizeText(lines[#lines], font, maxWidth)
                return lines
            end
        end
    end

    if line ~= "" and #lines < maxLines then lines[#lines + 1] = line end
    return lines
end

local QuickPanel = {}
function QuickPanel:Init()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
    lia.gui.quick = self
    refreshQuickPalette()
    self:SetSkin(lia.config.get("DermaSkin", L("liliaSkin")))
    self:SetTitle("")
    self:SetAlphaBackground(false)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)
    if self.SetDeleteOnClose then self:SetDeleteOnClose(false) end
    self.items = {}
    self.optionsCache = {}
    self.searchQuery = ""
    self.forceRepopulate = true
    self.closing = false
    self:BuildChrome()
    self:RebuildContent()
    self:UpdateTargetSize(true)
    self:MakePopup()
    self:SetZPos(999)
    self:OpenAnimated()
    hook.Add("OnThemeChanged", self, function() if IsValid(self) then self:RefreshTheme() end end)
    hook.Add("OptionAdded", self, function(_, _, option)
        if not IsValid(self) then return end
        if option and (option.isQuick or option.data and option.data.isQuick) then
            self:InvalidateCache()
            self:RebuildContent()
        end
    end)
end

function QuickPanel:BuildChrome()
    self.headerIcon = self:Add("DPanel")
    self.headerIcon:SetMouseInputEnabled(false)
    self.headerIcon.Paint = function(_, w, h)
        drawQuickOutlinedBox(0, 0, w, h, 6, quickPalette.field, quickPalette.line)
        drawQuickMaterial(quickMaterials.settings, math.floor((w - 18) * 0.5), math.floor((h - 18) * 0.5), 18, quickPalette.textMuted)
    end

    self.search = self:Add("DTextEntry")
    self.search:SetText("")
    self.search:SetFont("LiliaFont.17")
    self.search:SetUpdateOnType(true)
    self.search:SetTextColor(quickPalette.text)
    self.search:SetCursorColor(quickPalette.accent)
    if self.search.SetTextInset then self.search:SetTextInset(42, 0) end
    if self.search.SetPlaceholderText then self.search:SetPlaceholderText("") end
    self.search.OnValueChange = function(_, value)
        self.searchQuery = string.Trim(string.lower(value or ""))
        self:RebuildContent()
    end

    self.search.Paint = function(entry, w, h)
        local border = entry:HasFocus() and quickAlpha(quickPalette.accent, 145) or quickPalette.line
        drawQuickOutlinedBox(0, 0, w, h, 6, quickPalette.field, border)
        drawQuickMaterial(quickMaterials.search, 15, math.floor((h - 16) * 0.5), 16, quickPalette.textMuted)
        if entry:GetText() == "" then draw.SimpleText("Search settings...", "LiliaFont.17", 42, h * 0.5, quickAlpha(quickPalette.textMuted, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        entry:DrawTextEntryText(quickPalette.text, quickPalette.accent, quickPalette.text)
    end

    self.scroll = self:Add("liaScrollPanel")
    self.scroll.Paint = function(_, w, h) drawQuickOutlinedBox(0, 0, w, h, 7, quickPalette.content, quickPalette.lineSoft) end
    local canvas = self.scroll.GetCanvas and self.scroll:GetCanvas() or nil
    if IsValid(canvas) then
        canvas:DockPadding(8, 8, 8, 12)
        canvas.Paint = function() end
    end

    local bar = self.scroll.GetVBar and self.scroll:GetVBar() or nil
    if IsValid(bar) then
        bar:SetWide(7)
        bar.Paint = function(_, w, h) draw.RoundedBox(3, 2, 0, math.max(w - 3, 1), h, Color(0, 0, 0, 70)) end
        if IsValid(bar.btnGrip) then bar.btnGrip.Paint = function(_, w, h) draw.RoundedBox(3, 1, 0, math.max(w - 2, 1), h, quickAlpha(quickPalette.accent, 165)) end end
        if IsValid(bar.btnUp) then bar.btnUp.Paint = function() end end
        if IsValid(bar.btnDown) then bar.btnDown.Paint = function() end end
    end

    self.footer = self:Add("DPanel")
    self.footer.Paint = function(_, w) drawQuickLine(0, 0, w, quickPalette.lineSoft) end
    self.resetButton = self.footer:Add("DButton")
    self.resetButton:SetText("")
    self.resetButton:SetCursor("hand")
    self.resetButton.DoClick = function() self:ResetQuickDefaults() end
    self.resetButton.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        local border = panel:IsHovered() and quickAlpha(quickPalette.accent, 145) or quickPalette.line
        drawQuickOutlinedBox(0, 0, w, h, 5, fill, border)
        draw.SimpleText("Reset Defaults", "LiliaFont.17", w * 0.5, h * 0.5, panel:IsHovered() and quickPalette.accent or quickPalette.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.closeButton = self.footer:Add("DButton")
    self.closeButton:SetText("")
    self.closeButton:SetCursor("hand")
    self.closeButton.DoClick = function() self:OnClose() end
    self.closeButton.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        local border = panel:IsHovered() and quickAlpha(quickPalette.accent, 145) or quickPalette.line
        drawQuickOutlinedBox(0, 0, w, h, 5, fill, border)
        draw.SimpleText("Close", "LiliaFont.17", w * 0.5, h * 0.5, panel:IsHovered() and quickPalette.text or quickPalette.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function QuickPanel:UpdateTargetSize(keepPosition)
    local width = math.Clamp(math.floor(ScrW() * 0.32), 470, 550)
    local height = math.Clamp(ScrH() - 40, 560, 920)
    self.targetX = ScrW() - width - 18
    self.targetY = 20
    self:SetSize(width, height)
    if not keepPosition then self:SetPos(self.targetX, self.targetY) end
    self:InvalidateLayout(true)
end

function QuickPanel:OpenAnimated()
    self.closing = false
    self:SetVisible(true)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    self:SetAlpha(0)
    self:SetPos(ScrW() + 16, self.targetY or 24)
    self:MoveTo(self.targetX or ScrW() - self:GetWide() - 22, self.targetY or 24, 0.24, 0, 0.2)
    self:AlphaTo(255, 0.18, 0)
end

function QuickPanel:Paint(w, h)
    if lia.util and lia.util.drawBlur then lia.util.drawBlur(self, 5) end
    drawQuickOutlinedBox(0, 0, w, h, 9, quickPalette.background, quickAlpha(quickPalette.accent, 115))
    draw.RoundedBox(8, 1, 1, w - 2, 74, quickPalette.header)
    drawQuickLine(18, 74, w - 36, quickPalette.lineSoft)
    draw.SimpleText("Quick Settings", "LiliaFont.25", 22, 29, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Adjust client-side preferences.", "LiliaFont.17", 22, 54, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function QuickPanel:PerformLayout(w, h)
    local pad = 18
    if IsValid(self.headerIcon) then
        self.headerIcon:SetPos(w - 60, 18)
        self.headerIcon:SetSize(38, 38)
    end

    if IsValid(self.search) then
        self.search:SetPos(pad, 92)
        self.search:SetSize(w - pad * 2, 44)
    end

    if IsValid(self.footer) then
        self.footer:SetPos(pad, h - 66)
        self.footer:SetSize(w - pad * 2, 52)
    end

    local footerWidth = w - pad * 2
    local buttonGap = 10
    local buttonWidth = math.floor((footerWidth - buttonGap) * 0.5)
    if IsValid(self.resetButton) then
        self.resetButton:SetPos(0, 12)
        self.resetButton:SetSize(buttonWidth, 40)
    end

    if IsValid(self.closeButton) then
        self.closeButton:SetPos(buttonWidth + buttonGap, 12)
        self.closeButton:SetSize(footerWidth - buttonWidth - buttonGap, 40)
    end

    if IsValid(self.scroll) then
        self.scroll:SetPos(pad, 150)
        self.scroll:SetSize(w - pad * 2, math.max(h - 230, 40))
    end
end

function QuickPanel:ResolveQuickSection(key, opt, displayName, categoryName)
    local rawCategory = string.lower(tostring(categoryName or ""))
    local token = string.lower(table.concat({tostring(key or ""), tostring(displayName or ""), rawCategory}, " "))
    if token:find("freelook", 1, true) or token:find("realistic", 1, true) or token:find("camera", 1, true) then return "camera" end
    if token:find("third", 1, true) or token:find("classic", 1, true) then return "thirdperson" end
    if token:find("voice", 1, true) then return "voice" end
    if token:find("weapon scroll", 1, true) or token:find("invert", 1, true) or token:find("scroll", 1, true) then return "controls" end
    if token:find("hover", 1, true) or token:find("bars", 1, true) or token:find("hud", 1, true) then return "hud" end
    if rawCategory == "core" then return "hud" end
    if rawCategory == "" or rawCategory == "unsorted" then return "general" end
    return rawCategory:gsub("%s+", "")
end

function QuickPanel:GetSectionTitle(sectionName)
    return quickSectionTitles[sectionName] or string.upper(tostring(sectionName or "general"))
end

function QuickPanel:MatchesSearch(key, displayName, description, categoryName)
    local query = self.searchQuery or ""
    if query == "" then return true end
    local token = string.lower(table.concat({tostring(key or ""), tostring(displayName or ""), tostring(description or ""), tostring(categoryName or "")}, " "))
    return token:find(query, 1, true) ~= nil
end

function QuickPanel:RebuildContent()
    if not IsValid(self.scroll) then return end
    for _, item in ipairs(self.items or {}) do
        if IsValid(item) then item:Remove() end
    end

    self.items = {}
    self.optionsCache = {}
    self.forceRepopulate = false
    self:populateOptions()
    hook.Run("SetupQuickMenu", self)
    self:InvalidateLayout(true)
end

function QuickPanel:addButton(text, cb, description)
    local descriptionText = quickLocalized(description or "")
    local hasDescription = descriptionText ~= ""
    local button = self.scroll:Add("DButton")
    button:SetText("")
    button:SetTall(hasDescription and 60 or 46)
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 7)
    button:SetCursor("hand")
    if cb then button.DoClick = cb end
    if hasDescription then button:SetTooltip(descriptionText) end
    button.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        local border = panel:IsHovered() and quickAlpha(quickPalette.accent, 105) or quickPalette.lineSoft
        drawQuickOutlinedBox(0, 0, w, h, 6, fill, border)
        draw.SimpleText(quickEllipsizeText(text, "LiliaFont.17", w - 28), "LiliaFont.17", 14, hasDescription and 17 or h * 0.5, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if hasDescription then draw.SimpleText(quickEllipsizeText(descriptionText, "LiliaFont.15", w - 28), "LiliaFont.15", 14, 40, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
    end

    self.items[#self.items + 1] = button
    return button
end

function QuickPanel:addSpacer()
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(2)
    panel:Dock(TOP)
    panel.Paint = function() end
    self.items[#self.items + 1] = panel
    return panel
end

function QuickPanel:addCategoryHeader(categoryName, categoryColor)
    local header = self.scroll:Add("DPanel")
    header:SetTall(44)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 8)
    header:SetPaintBackground(false)
    header.Paint = function(_, w, h)
        local accentColor = quickPalette.accent
        drawQuickOutlinedBox(0, 0, w, h, 5, quickPalette.header, quickPalette.lineSoft)
        draw.SimpleText(string.upper(tostring(categoryName or "GENERAL")), "LiliaFont.16", 13, 17, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        drawQuickLine(13, h - 10, w - 26, quickAlpha(accentColor, 105))
    end

    self.items[#self.items + 1] = header
    return header
end

function QuickPanel:addSlider(text, cb, val, min, max, dec, description)
    local descriptionText = quickLocalized(description or "")
    local hasDescription = descriptionText ~= ""
    local container = self.scroll:Add("DPanel")
    container:SetTall(hasDescription and 90 or 76)
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, 7)
    container.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        local border = panel:IsHovered() and quickAlpha(quickPalette.accent, 105) or quickPalette.lineSoft
        drawQuickOutlinedBox(0, 0, w, h, 6, fill, border)
        draw.SimpleText(quickEllipsizeText(text, "LiliaFont.17", w - 92), "LiliaFont.17", 14, 17, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if hasDescription then draw.SimpleText(quickEllipsizeText(descriptionText, "LiliaFont.15", w - 28), "LiliaFont.15", 14, 39, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
    end

    if hasDescription then container:SetTooltip(descriptionText) end
    local valueLabel = vgui.Create("DLabel", container)
    valueLabel:SetText("")
    valueLabel:SetFont("LiliaFont.17")
    valueLabel:SetTextColor(quickPalette.textMuted)
    local function updateLabelText(value)
        local displayValue = dec and dec > 0 and math.Round(value, dec) or math.Round(value)
        valueLabel:SetText(tostring(displayValue))
        valueLabel:SizeToContents()
    end

    updateLabelText(val or 0)
    local slider = container:Add("liaSlider")
    slider:SetRange(min or 0, max or 100, dec or 0)
    slider:SetValue(val or 0)
    slider.PerformLayout = function()
        if slider.Label then slider.Label:SetVisible(false) end
        if slider.TextArea then slider.TextArea:SetVisible(false) end
    end

    container.PerformLayout = function(_, w)
        valueLabel:SetPos(w - valueLabel:GetWide() - 15, 9)
        slider:SetPos(16, hasDescription and 60 or 44)
        slider:SetSize(w - 32, 22)
    end

    if cb then
        slider.OnValueChanged = function()
            local actualValue = slider:GetValue()
            if not isnumber(actualValue) then
                if isvector(actualValue) then
                    actualValue = actualValue.x or 0
                else
                    actualValue = tonumber(actualValue) or 0
                end
            end

            local rounded = math.Round(actualValue, dec or 0)
            updateLabelText(rounded)
            cb(slider, rounded)
        end
    end

    self.items[#self.items + 1] = container
    return container
end

function QuickPanel:addCheck(text, cb, checked, description)
    local row = self.scroll:Add("DPanel")
    local descriptionText = quickLocalized(description or "")
    local hasDescription = descriptionText ~= ""
    row:SetTall(hasDescription and 68 or 48)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 7)
    row.Checked = checked and true or false
    row.ToggleFraction = row.Checked and 1 or 0
    row:SetCursor("hand")
    if hasDescription then row:SetTooltip(descriptionText) end
    row.Paint = function(panel, w, h)
        local hovered = panel:IsHovered()
        local fill = hovered and quickPalette.panelHover or quickPalette.panel
        local border = hovered and quickAlpha(quickPalette.accent, 105) or quickPalette.lineSoft
        local textMaxWidth = w - 92
        drawQuickOutlinedBox(0, 0, w, h, 6, fill, border)
        draw.SimpleText(quickEllipsizeText(text, "LiliaFont.17", textMaxWidth), "LiliaFont.17", 14, hasDescription and 17 or h * 0.5, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if hasDescription then
            local lines = quickWrapText(descriptionText, "LiliaFont.15", textMaxWidth, 2)
            for index, line in ipairs(lines) do
                draw.SimpleText(line, "LiliaFont.15", 14, 36 + (index - 1) * 14, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    local toggle = vgui.Create("DButton", row)
    toggle:SetText("")
    toggle:SetCursor("hand")
    toggle.Paint = function(panel, w, h)
        local target = row.Checked and 1 or 0
        row.ToggleFraction = Lerp(math.Clamp(FrameTime() * 14, 0, 1), row.ToggleFraction or target, target)
        local hovered = panel:IsHovered() or row:IsHovered()
        local enabledColor = hovered and quickBlend(quickPalette.toggleOn, quickPalette.text, 0.12, 255) or quickPalette.toggleOn
        local disabledColor = hovered and quickBlend(quickPalette.toggleOff, quickPalette.textMuted, 0.16, 255) or quickPalette.toggleOff
        local track = Color(Lerp(row.ToggleFraction, disabledColor.r, enabledColor.r), Lerp(row.ToggleFraction, disabledColor.g, enabledColor.g), Lerp(row.ToggleFraction, disabledColor.b, enabledColor.b), 255)
        draw.RoundedBox(math.floor(h * 0.5), 0, 0, w, h, track)
        local knobSize = h - 6
        local knobX = 3 + (w - knobSize - 6) * row.ToggleFraction
        draw.RoundedBox(math.floor(knobSize * 0.5), knobX, 3, knobSize, knobSize, quickPalette.toggleKnob)
    end

    local function setState(state, runCallback)
        row.Checked = state and true or false
        if runCallback and cb then cb(row, row.Checked) end
    end

    row.SetToggleState = function(_, state) setState(state, false) end
    row.DoClick = function() setState(not row.Checked, true) end
    toggle.DoClick = function() setState(not row.Checked, true) end
    row.OnMousePressed = function(panel, code) if code == MOUSE_LEFT then panel:DoClick() end end
    row.PerformLayout = function(_, w, h)
        toggle:SetSize(44, 22)
        toggle:SetPos(w - 58, math.floor((h - 22) * 0.5))
    end

    self.items[#self.items + 1] = row
    return row
end

function QuickPanel:addEmptyState(text)
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(72)
    panel:Dock(TOP)
    panel:DockMargin(0, 4, 0, 0)
    panel.Paint = function(_, w, h)
        drawQuickOutlinedBox(0, 0, w, h, 6, quickPalette.panel, quickPalette.lineSoft)
        draw.SimpleText(text, "LiliaFont.17", w * 0.5, h * 0.5, quickPalette.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.items[#self.items + 1] = panel
    return panel
end

function QuickPanel:setIcon(ch)
    self.icon = ch
end

function QuickPanel:RefreshTheme()
    if not IsValid(self) then return end
    refreshQuickPalette()
    if IsValid(self.search) then
        self.search:SetTextColor(quickPalette.text)
        self.search:SetCursorColor(quickPalette.accent)
    end

    self:RebuildContent()
    self:InvalidateLayout(true)
end

function QuickPanel:InvalidateCache()
    self.forceRepopulate = true
end

function QuickPanel:OnScreenSizeChanged()
    if not IsValid(self) then return end
    self:UpdateTargetSize(false)
end

function QuickPanel:OnKeyCodePressed(key)
    if key == KEY_ESCAPE then self:OnClose() end
end

function QuickPanel:OnRemove()
    hook.Remove("OnThemeChanged", self)
    hook.Remove("OptionAdded", self)
    if lia.gui.quick == self then lia.gui.quick = nil end
end

function QuickPanel:OnClose()
    if self.closing then return false end
    self.closing = true
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    self:MoveTo(ScrW() + 16, self.targetY or 24, 0.22, 0, 0.2, function()
        if not IsValid(self) then return end
        self:SetVisible(false)
        self:SetPos(self.targetX or ScrW() - self:GetWide() - 22, self.targetY or 24)
        self:SetAlpha(255)
        self:SetMouseInputEnabled(true)
        self:SetKeyboardInputEnabled(true)
        self.closing = false
    end)

    self:AlphaTo(0, 0.16, 0)
    return false
end

function QuickPanel:ResetQuickDefaults()
    if not lia.option or not lia.option.stored or not lia.option.set then return end
    for key, option in pairs(lia.option.stored) do
        if option and (option.isQuick or option.data and option.data.isQuick) and option.default ~= nil then lia.option.set(key, option.default) end
    end

    self:RebuildContent()
end

function QuickPanel:populateOptions()
    if not lia.option or not lia.option.stored then
        self:addEmptyState("No quick settings available.")
        return false
    end

    local allOptions = {}
    for key, option in pairs(lia.option.stored) do
        if option and (option.isQuick or option.data and option.data.isQuick) then
            allOptions[#allOptions + 1] = {
                key = key,
                opt = option
            }
        end
    end

    if #allOptions == 0 then
        self:Remove()
        return false
    end

    local localize = lia.option.localizeValue or L
    local categories = {}
    local matchCount = 0
    for _, info in ipairs(allOptions) do
        local key = info.key
        local opt = info.opt
        local data = opt.data or {}
        local visible = opt.visible == nil or opt.visible == true or isfunction(opt.visible) and opt.visible()
        if visible then
            local categoryName = data.rawCategory or data.category or "general"
            local displayName = lia.option.getDisplayName and lia.option.getDisplayName(key) or opt.name or key
            local description = lia.option.getDisplayDesc and lia.option.getDisplayDesc(key) or opt.description or opt.desc or ""
            if self:MatchesSearch(key, displayName, description, categoryName) then
                local section = self:ResolveQuickSection(key, opt, displayName, categoryName)
                categories[section] = categories[section] or {
                    items = {},
                    color = quickPalette.accent,
                    title = quickSectionTitles[section] or string.upper(tostring(localize(categoryName) or categoryName or section))
                }

                categories[section].items[#categories[section].items + 1] = {
                    key = key,
                    opt = opt,
                    displayName = displayName,
                    description = description,
                    data = data
                }

                matchCount = matchCount + 1
            end
        end
    end

    if matchCount == 0 then
        self:addEmptyState(self.searchQuery ~= "" and "No settings match your search." or "No quick settings available.")
        return true
    end

    local sortedCategories = {}
    for sectionName, categoryData in pairs(categories) do
        if #categoryData.items > 0 then sortedCategories[#sortedCategories + 1] = sectionName end
    end

    table.sort(sortedCategories, function(a, b)
        local orderA = quickSectionOrder[a] or 50
        local orderB = quickSectionOrder[b] or 50
        if orderA ~= orderB then return orderA < orderB end
        return tostring(categories[a].title):lower() < tostring(categories[b].title):lower()
    end)

    local function getTypeOrder(optionType)
        if optionType == "Boolean" then return 1 end
        if optionType == "Int" or optionType == "Float" then return 2 end
        return 3
    end

    for _, sectionName in ipairs(sortedCategories) do
        local categoryData = categories[sectionName]
        table.sort(categoryData.items, function(a, b)
            local typeA = getTypeOrder(a.opt.type)
            local typeB = getTypeOrder(b.opt.type)
            if typeA ~= typeB then return typeA < typeB end
            return tostring(a.displayName):lower() < tostring(b.displayName):lower()
        end)

        self:addCategoryHeader(self:GetSectionTitle(sectionName), categoryData.color)
        for _, info in ipairs(categoryData.items) do
            local key = info.key
            local opt = info.opt
            local data = info.data or {}
            local value = lia.option.get(key, opt.default)
            local item
            if opt.type == "Boolean" then
                item = self:addCheck(info.displayName, function(_, state) lia.option.set(key, state) end, value, info.description)
            elseif opt.type == "Int" or opt.type == "Float" then
                item = self:addSlider(info.displayName, function(_, sliderValue) lia.option.set(key, sliderValue) end, value, data.min or 0, data.max or 100, opt.type == "Float" and (data.decimals or 2) or 0, info.description)
            end

            if item then self.optionsCache[#self.optionsCache + 1] = item end
        end
    end
    return true
end

vgui.Register("liaQuick", QuickPanel, "liaFrame")
local function drawcirclepoly(w, h)
    local poly = {}
    local x, y = w / 2, h / 2
    for angle = 1, 360 do
        local rad = math.rad(angle)
        local cos = math.cos(rad) * y
        local sin = math.sin(rad) * y
        poly[#poly + 1] = {
            x = x + cos,
            y = y + sin
        }
    end
    return poly
end

local PANEL = {}
function PANEL:Init()
    self.base = vgui.Create("AvatarImage", self)
    self.base:Dock(FILL)
    self.base:SetPaintedManually(true)
end

function PANEL:GetBase()
    return self.base
end

function PANEL:PushMask(mask)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
    mask()
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
end

function PANEL:PopMask()
    render.SetStencilEnable(false)
    render.ClearStencil()
end

function PANEL:OnSizeChanged(w, h)
    self.poly = drawcirclepoly(w, h)
end

function PANEL:Paint(w, h)
    self:PushMask(function()
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255)
        surface.DrawPoly(self.poly)
    end)

    self.base:PaintManual()
    self:PopMask()
end

function PANEL:SetPlayer(pl, size)
    self.base:SetPlayer(pl, size)
end

vgui.Register("CircularAvatar", PANEL)
