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
    background = Color(4, 16, 19, 246),
    panel = Color(6, 25, 29, 230),
    panelHover = Color(9, 34, 39, 242),
    panelStrong = Color(5, 20, 24, 248),
    field = Color(2, 18, 22, 238),
    line = Color(57, 82, 86, 115),
    lineSoft = Color(54, 76, 78, 70),
    text = Color(230, 238, 238, 255),
    textMuted = Color(152, 170, 170, 255),
    accent = Color(188, 127, 67, 255),
    accentSoft = Color(188, 127, 67, 46),
    toggleOff = Color(63, 77, 80, 255),
    toggleKnob = Color(238, 244, 241, 255)
}

local quickPalette = table.Copy(quickPaletteDefaults)
local function setQuickPaletteColor(name, value)
    local fallback = quickPaletteDefaults[name] or color_white
    quickPalette[name] = IsColor(value) and Color(value.r, value.g, value.b, value.a or 255) or Color(fallback.r, fallback.g, fallback.b, fallback.a or 255)
end

local function refreshQuickPalette()
    local theme = lia.color and lia.color.theme or {}
    local background = theme.background_alpha or theme.background or quickPaletteDefaults.background
    local panel = theme.button or theme.category or quickPaletteDefaults.panel
    local field = theme.focus_panel or theme.category or quickPaletteDefaults.field
    local line = theme.gray or quickPaletteDefaults.line
    local text = theme.text or theme.text_entry or quickPaletteDefaults.text
    local accent = theme.accent or theme.theme or theme.maincolor or quickPaletteDefaults.accent
    local toggleOff = theme.toggle or quickPaletteDefaults.toggleOff
    setQuickPaletteColor("background", background)
    setQuickPaletteColor("panel", panel)
    setQuickPaletteColor("panelHover", lia.color and lia.color.adjust(panel, 10, 10, 10, 12) or quickPaletteDefaults.panelHover)
    setQuickPaletteColor("panelStrong", lia.color and lia.color.darken(panel, 0.18) or quickPaletteDefaults.panelStrong)
    setQuickPaletteColor("field", field)
    setQuickPaletteColor("line", Color(line.r, line.g, line.b, 115))
    setQuickPaletteColor("lineSoft", Color(line.r, line.g, line.b, 70))
    setQuickPaletteColor("text", text)
    setQuickPaletteColor("textMuted", theme.gray or theme.header_text or quickPaletteDefaults.textMuted)
    setQuickPaletteColor("accent", accent)
    setQuickPaletteColor("accentSoft", Color(accent.r, accent.g, accent.b, 46))
    setQuickPaletteColor("toggleOff", toggleOff)
    setQuickPaletteColor("toggleKnob", theme.text_entry or theme.text or quickPaletteDefaults.toggleKnob)
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

local function quickThemeColor(name)
    local theme = lia.color and lia.color.theme or nil
    if name == "accent" and theme and theme.theme then return theme.theme end
    if name == "text" and theme and theme.text then return theme.text end
    if name == "muted" and theme and theme.desc then return theme.desc end
    return quickPalette[name] or color_white
end

local function drawQuickOutlinedBox(x, y, w, h, radius, fillColor, borderColor)
    if w <= 0 or h <= 0 then return end
    draw.RoundedBox(radius, x, y, w, h, borderColor)
    draw.RoundedBox(math.max(radius - 1, 0), x + 1, y + 1, math.max(w - 2, 0), math.max(h - 2, 0), fillColor)
end

local function drawQuickLine(x, y, w, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawRect(x, y, w, 1)
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
    local width = surface.GetTextSize(text)
    if width <= maxWidth then return text end
    local ellipsis = "..."
    local result = text
    while result ~= "" do
        result = string.sub(result, 1, #result - 1)
        width = surface.GetTextSize(result .. ellipsis)
        if width <= maxWidth then return result .. ellipsis end
    end
    return ellipsis
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
        local test = line == "" and word or line .. " " .. word
        local width = surface.GetTextSize(test)
        if width <= maxWidth then
            line = test
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
    if #lines > maxLines then lines[maxLines] = quickEllipsizeText(lines[maxLines], font, maxWidth) end
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
    self:BuildChrome()
    self:RebuildContent()
    self:UpdateTargetSize()
    self:MakePopup()
    self:SetZPos(999)
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
    self.search = self:Add("DTextEntry")
    self.search:SetText("")
    self.search:SetFont("LiliaFont.17")
    self.search:SetUpdateOnType(true)
    self.search:SetTextColor(quickPalette.text)
    self.search:SetCursorColor(quickPalette.accent)
    if self.search.SetPlaceholderText then self.search:SetPlaceholderText("Search settings...") end
    self.search.OnValueChange = function(entry, value)
        self.searchQuery = string.Trim(string.lower(value or ""))
        self:RebuildContent()
    end

    self.search.Paint = function(entry, w, h)
        drawQuickOutlinedBox(0, 0, w, h, 5, quickPalette.field, quickPalette.line)
        surface.SetFont("LiliaFont.17")
        surface.SetTextColor(quickPalette.textMuted)
        surface.SetTextPos(13, math.floor(h * 0.5 - 8))
        surface.DrawText("⌕")
        if entry:GetText() == "" then draw.SimpleText("Search settings...", "LiliaFont.17", 37, h * 0.5, Color(120, 138, 139, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        entry:DrawTextEntryText(quickPalette.text, quickPalette.accent, quickPalette.text)
    end

    self.scroll = self:Add("liaScrollPanel")
    self.scroll.Paint = function() end
    local bar = self.scroll.GetVBar and self.scroll:GetVBar() or nil
    if IsValid(bar) then
        bar:SetWide(6)
        bar.Paint = function(_, w, h) draw.RoundedBox(3, 2, 0, w - 2, h, Color(0, 0, 0, 60)) end
        if IsValid(bar.btnGrip) then bar.btnGrip.Paint = function(_, w, h) draw.RoundedBox(3, 1, 0, w - 1, h, Color(188, 127, 67, 150)) end end
        if IsValid(bar.btnUp) then bar.btnUp.Paint = function() end end
        if IsValid(bar.btnDown) then bar.btnDown.Paint = function() end end
    end

    self.footer = self:Add("DPanel")
    self.footer.Paint = function(_, w, h) drawQuickLine(0, 0, w, quickPalette.lineSoft) end
    self.resetButton = self.footer:Add("DButton")
    self.resetButton:SetText("")
    self.resetButton.DoClick = function() self:ResetQuickDefaults() end
    self.resetButton.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and Color(16, 39, 42, 232) or Color(8, 27, 31, 220)
        drawQuickOutlinedBox(0, 0, w, h, 4, fill, quickPalette.line)
        draw.SimpleText("↻  Reset Defaults", "LiliaFont.17", w * 0.5, h * 0.5, quickPalette.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.closeButton = self.footer:Add("DButton")
    self.closeButton:SetText("")
    self.closeButton.DoClick = function() self:OnClose() end
    self.closeButton.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and Color(16, 39, 42, 232) or Color(8, 27, 31, 220)
        drawQuickOutlinedBox(0, 0, w, h, 4, fill, quickPalette.line)
        draw.SimpleText("×  Close", "LiliaFont.17", w * 0.5, h * 0.5, quickPalette.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function QuickPanel:UpdateTargetSize()
    local width = math.Clamp(math.floor(ScrW() * 0.265), 390, 470)
    local height = math.Clamp(math.floor(ScrH() * 0.86), 420, ScrH() - 54)
    self:SetSize(width, height)
    self:SetPos(ScrW() - width - 24, 30)
    self:InvalidateLayout(true)
end

function QuickPanel:Paint(w, h)
    if lia.util and lia.util.drawBlur then lia.util.drawBlur(self, 6) end
    drawQuickOutlinedBox(0, 0, w, h, 8, quickPalette.background, Color(43, 72, 76, 170))
    draw.RoundedBox(8, 1, 1, w - 2, 66, Color(6, 22, 26, 210))
    surface.SetDrawColor(quickPalette.accent.r, quickPalette.accent.g, quickPalette.accent.b, 175)
    surface.DrawRect(0, 0, 2, h)
    draw.SimpleText(L("quickSettings") or "Quick Settings", "LiliaFont.24", 22, 26, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Adjust client-side preferences.", "LiliaFont.17", 22, 51, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    drawQuickOutlinedBox(w - 44, 18, 26, 26, 5, Color(7, 29, 33, 230), quickPalette.line)
    draw.SimpleText("⚙", "LiliaFont.18", w - 31, 31, quickPalette.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function QuickPanel:PerformLayout(w, h)
    local pad = 18
    if IsValid(self.search) then
        self.search:SetPos(pad, 82)
        self.search:SetSize(w - pad * 2, 34)
    end

    if IsValid(self.footer) then
        self.footer:SetPos(pad, h - 62)
        self.footer:SetSize(w - pad * 2, 46)
    end

    if IsValid(self.resetButton) then
        self.resetButton:SetPos(0, 11)
        self.resetButton:SetSize(math.floor((w - pad * 2 - 14) * 0.5), 34)
    end

    if IsValid(self.closeButton) and IsValid(self.resetButton) then
        self.closeButton:SetPos(self.resetButton:GetWide() + 14, 11)
        self.closeButton:SetSize(self.resetButton:GetWide(), 34)
    end

    if IsValid(self.scroll) then
        self.scroll:SetPos(0, 126)
        self.scroll:SetSize(w, math.max(h - 196, 40))
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
    local btn = self.scroll:Add("DButton")
    btn:SetText("")
    btn:SetTall(40)
    btn:Dock(TOP)
    btn:DockMargin(14, 8, 14, 0)
    btn:SetCursor("hand")
    if cb then btn.DoClick = cb end
    if description and description ~= "" then btn:SetTooltip(quickLocalized(description)) end
    btn.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        drawQuickOutlinedBox(0, 0, w, h, 5, fill, quickPalette.lineSoft)
        draw.SimpleText(text, "LiliaFont.17", 13, h * 0.5, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.items[#self.items + 1] = btn
    return btn
end

function QuickPanel:addSpacer()
    local pnl = self.scroll:Add("DPanel")
    pnl:SetTall(1)
    pnl:Dock(TOP)
    pnl:DockMargin(28, 0, 28, 0)
    pnl.Paint = function(_, w, h)
        surface.SetDrawColor(quickPalette.lineSoft.r, quickPalette.lineSoft.g, quickPalette.lineSoft.b, quickPalette.lineSoft.a)
        surface.DrawRect(0, 0, w, h)
    end

    self.items[#self.items + 1] = pnl
    return pnl
end

function QuickPanel:addCategoryHeader(categoryName, categoryColor)
    local header = self.scroll:Add("DPanel")
    header:SetTall(46)
    header:Dock(TOP)
    header:DockMargin(14, 12, 14, 0)
    header:SetPaintBackground(false)
    header.Paint = function(_, w, h)
        local accentColor = categoryColor or quickThemeColor("accent")
        local fill = Color(6, 25, 29, 225)
        drawQuickOutlinedBox(0, 0, w, h, 5, fill, quickPalette.lineSoft)
        draw.SimpleText(categoryName, "LiliaFont.17", 14, 18, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 100)
        surface.DrawRect(14, h - 11, w - 28, 1)
    end

    self.items[#self.items + 1] = header
    return header
end

function QuickPanel:addSlider(text, cb, val, min, max, dec, description)
    local container = self.scroll:Add("DPanel")
    container:SetTall(74)
    container:Dock(TOP)
    container:DockMargin(14, 0, 14, 0)
    container.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        drawQuickOutlinedBox(0, 0, w, h, 3, fill, quickPalette.lineSoft)
        draw.SimpleText(text, "LiliaFont.17", 14, 20, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if description and description ~= "" then container:SetTooltip(quickLocalized(description)) end
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
    slider.PerformLayout = function(_, w, h)
        if slider.Label then slider.Label:SetVisible(false) end
        if slider.TextArea then slider.TextArea:SetVisible(false) end
    end

    container.PerformLayout = function(_, w, h)
        valueLabel:SetPos(w - valueLabel:GetWide() - 15, 11)
        slider:SetPos(16, 42)
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
    local descText = quickLocalized(description or "")
    local hasDescription = descText and descText ~= ""
    row:SetTall(hasDescription and 62 or 42)
    row:Dock(TOP)
    row:DockMargin(14, 0, 14, 0)
    row.Checked = checked and true or false
    row:SetCursor("hand")
    if hasDescription then row:SetTooltip(descText) end
    row.Paint = function(panel, w, h)
        local fill = panel:IsHovered() and quickPalette.panelHover or quickPalette.panel
        local textMaxWidth = w - 92
        drawQuickOutlinedBox(0, 0, w, h, 3, fill, quickPalette.lineSoft)
        draw.SimpleText(quickEllipsizeText(text, "LiliaFont.17", textMaxWidth), "LiliaFont.17", 14, hasDescription and 15 or h * 0.5, quickPalette.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if hasDescription then
            local lines = quickWrapText(descText, "LiliaFont.17", textMaxWidth, 2)
            for index, line in ipairs(lines) do
                draw.SimpleText(line, "LiliaFont.17", 14, 31 + (index - 1) * 14, quickPalette.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    local toggle = vgui.Create("DButton", row)
    toggle:SetText("")
    toggle:SetCursor("hand")
    toggle.Paint = function(panel, w, h)
        local enabled = row.Checked and true or false
        local track = enabled and quickPalette.accent or quickPalette.toggleOff
        if panel:IsHovered() or row:IsHovered() then track = enabled and Color(210, 145, 79, 255) or Color(75, 91, 94, 255) end
        draw.RoundedBox(math.floor(h * 0.5), 0, 0, w, h, track)
        local knobSize = h - 6
        local knobX = enabled and w - knobSize - 3 or 3
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
        toggle:SetSize(42, 22)
        toggle:SetPos(w - 54, math.floor((h - 22) * 0.5))
    end

    self.items[#self.items + 1] = row
    return row
end

function QuickPanel:addEmptyState(text)
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(72)
    panel:Dock(TOP)
    panel:DockMargin(14, 12, 14, 0)
    panel.Paint = function(_, w, h)
        drawQuickOutlinedBox(0, 0, w, h, 5, quickPalette.panel, quickPalette.lineSoft)
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

function QuickPanel:OnRemove()
    hook.Remove("OnThemeChanged", self)
    hook.Remove("OptionAdded", self)
    if lia.gui.quick == self then lia.gui.quick = nil end
end

function QuickPanel:OnClose()
    self:SetVisible(false)
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
        local visible = not opt.visible or isfunction(opt.visible) and opt.visible()
        if visible then
            local categoryName = data.rawCategory or data.category or "general"
            local displayName = lia.option.getDisplayName and lia.option.getDisplayName(key) or opt.name or key
            local description = lia.option.getDisplayDesc and lia.option.getDisplayDesc(key) or opt.description or opt.desc or ""
            if self:MatchesSearch(key, displayName, description, categoryName) then
                local section = self:ResolveQuickSection(key, opt, displayName, categoryName)
                categories[section] = categories[section] or {
                    items = {},
                    color = data.categoryColor or quickPalette.accent,
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

    local function getTypeOrder(optType)
        if optType == "Boolean" then return 1 end
        if optType == "Int" or optType == "Float" then return 2 end
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
        for index, info in ipairs(categoryData.items) do
            local key = info.key
            local opt = info.opt
            local data = info.data or {}
            local val = lia.option.get(key, opt.default)
            local item
            if opt.type == "Boolean" then
                item = self:addCheck(info.displayName, function(_, state) lia.option.set(key, state) end, val, info.description)
            elseif opt.type == "Int" or opt.type == "Float" then
                item = self:addSlider(info.displayName, function(_, value) lia.option.set(key, value) end, val, data.min or 0, data.max or 100, opt.type == "Float" and (data.decimals or 2) or 0, info.description)
            end

            if item then self.optionsCache[#self.optionsCache + 1] = item end
            if index < #categoryData.items then self:addSpacer() end
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