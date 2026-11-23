local SKIN = {}
local renderer = lia.derma
local defaultColors = derma.SkinList.Default.Colours
local COLOR_PANEL = Color(25, 25, 25, 230)
local COLOR_CONTROL = Color(30, 30, 30, 220)
local COLOR_BORDER = Color(0, 0, 0, 150)
local COLOR_TEXT = Color(220, 220, 220)
local COLOR_TEXT_MUTED = Color(160, 160, 160)
local COLOR_WHITE = Color(255, 255, 255)
local SHAPE = renderer.SHAPE_FIGMA
local function getAccent(alpha)
    local theme = lia.color and lia.color.theme or {}
    local accent = theme.maincolor or theme.accent or theme.theme or (lia.config and lia.config.get and lia.config.get("Color"))
    if not IsColor(accent) then accent = Color(76, 164, 224) end
    return Color(accent.r, accent.g, accent.b, alpha or accent.a or 255)
end

local function rect(radius, x, y, w, h, color, shape)
    if w <= 0 or h <= 0 then return end
    renderer.draw(radius, x, y, w, h, color, shape or SHAPE)
end

local function outline(radius, x, y, w, h, color, shape)
    if w <= 0 or h <= 0 then return end
    renderer.drawOutlined(radius, x, y, w, h, color, 1, shape or SHAPE)
end

local function shadow(radius, x, y, w, h, spread, intensity)
    if w <= 0 or h <= 0 then return end
    renderer.drawShadows(radius, x, y, w, h, Color(0, 0, 0, 160), spread, intensity, SHAPE)
end

local function accentBar(w, h)
    if w <= 4 or h <= 2 then return end
    surface.SetDrawColor(getAccent())
    surface.DrawRect(2, h - 2, w - 4, 2)
end

local function controlBackground(w, h, alpha)
    rect(6, 0, 0, w, h, Color(30, 30, 30, alpha or 220))
    outline(6, 0, 0, w, h, COLOR_BORDER)
end

local function paintArrow(w, h, symbol)
    rect(3, 0, 0, w, h, COLOR_CONTROL)
    surface.SetFont("Marlett")
    surface.SetTextColor(COLOR_TEXT)
    local tw, th = surface.GetTextSize(symbol)
    surface.SetTextPos((w - tw) * 0.5, (h - th) * 0.5)
    surface.DrawText(symbol)
end

SKIN.fontFrame = "LiliaFont.18"
SKIN.fontTab = "LiliaFont.17"
SKIN.fontButton = "LiliaFont.17"
SKIN.fontLabel = "LiliaFont.17"
SKIN.fontTextEntry = "LiliaFont.17"
SKIN.fontComboBox = "LiliaFont.17"
SKIN.fontListView = "LiliaFont.17"
SKIN.fontMenu = "LiliaFont.17"
SKIN.fontMenuOption = "LiliaFont.17"
SKIN.fontTooltip = "LiliaFont.17"
SKIN.Colours = table.Copy(defaultColors)
SKIN.Colours.Window.TitleActive = COLOR_WHITE
SKIN.Colours.Window.TitleInactive = COLOR_TEXT_MUTED
SKIN.Colours.Label.Dark = COLOR_TEXT
SKIN.Colours.Label.Default = COLOR_TEXT
SKIN.Colours.Label.Bright = COLOR_WHITE
SKIN.Colours.Label.Highlight = COLOR_WHITE
SKIN.Colours.Button.Normal = COLOR_TEXT
SKIN.Colours.Button.Hover = COLOR_WHITE
SKIN.Colours.Button.Down = COLOR_TEXT
SKIN.Colours.Button.Disabled = Color(100, 100, 100, 100)
SKIN.Colours.Tree = SKIN.Colours.Tree or {}
SKIN.Colours.Tree.Lines = Color(90, 90, 90)
SKIN.Colours.Tree.Normal = COLOR_TEXT
SKIN.Colours.Tree.Hover = COLOR_WHITE
SKIN.Colours.Tree.Selected = COLOR_WHITE
SKIN.Colours.Tree.Text = COLOR_TEXT
SKIN.Colours.Tree.SelectedText = COLOR_WHITE
SKIN.Colours.Properties = SKIN.Colours.Properties or {}
SKIN.Colours.Properties.Line_Normal = Color(48, 48, 48)
SKIN.Colours.Properties.Line_Selected = Color(62, 62, 62)
SKIN.Colours.Properties.Line_Hover = Color(58, 58, 58)
SKIN.Colours.Properties.Title = COLOR_TEXT
SKIN.Colours.Properties.Column_Normal = Color(48, 48, 48)
SKIN.Colours.Properties.Column_Selected = Color(62, 62, 62)
SKIN.Colours.Properties.Column_Hover = Color(58, 58, 58)
SKIN.Colours.Properties.Column_Disabled = Color(40, 40, 40)
SKIN.Colours.Properties.Border = COLOR_BORDER
SKIN.Colours.Properties.Label_Normal = COLOR_TEXT
SKIN.Colours.Properties.Label_Selected = COLOR_WHITE
SKIN.Colours.Properties.Label_Hover = COLOR_WHITE
SKIN.Colours.Properties.Label_Disabled = COLOR_TEXT_MUTED
SKIN.Colours.Category = SKIN.Colours.Category or {}
SKIN.Colours.Category.Header = COLOR_TEXT
SKIN.Colours.Category.Header_Closed = COLOR_TEXT_MUTED
SKIN.Colours.Category.Line = SKIN.Colours.Category.Line or {}
SKIN.Colours.Category.Line.Text = COLOR_TEXT
SKIN.Colours.Category.Line.Text_Hover = COLOR_WHITE
SKIN.Colours.Category.Line.Text_Selected = COLOR_WHITE
SKIN.Colours.Category.Line.Text_Disabled = COLOR_TEXT_MUTED
SKIN.Colours.Category.Line.Button = Color(48, 48, 48)
SKIN.Colours.Category.Line.Button_Hover = Color(62, 62, 62)
SKIN.Colours.Category.Line.Button_Selected = Color(72, 72, 72)
SKIN.Colours.Category.Line.Button_Disabled = Color(38, 38, 38)
SKIN.Colours.Category.LineAlt = SKIN.Colours.Category.LineAlt or {}
SKIN.Colours.Category.LineAlt.Text = COLOR_TEXT
SKIN.Colours.Category.LineAlt.Text_Hover = COLOR_WHITE
SKIN.Colours.Category.LineAlt.Text_Selected = COLOR_WHITE
SKIN.Colours.Category.LineAlt.Text_Disabled = COLOR_TEXT_MUTED
SKIN.Colours.Category.LineAlt.Button = Color(42, 42, 42)
SKIN.Colours.Category.LineAlt.Button_Hover = Color(58, 58, 58)
SKIN.Colours.Category.LineAlt.Button_Selected = Color(68, 68, 68)
SKIN.Colours.Category.LineAlt.Button_Disabled = Color(36, 36, 36)
SKIN.colTextEntryBG = COLOR_CONTROL
SKIN.colTextEntryText = COLOR_WHITE
SKIN.colTextEntryTextCursor = COLOR_WHITE
SKIN.colTextEntryTextPlaceholder = COLOR_TEXT_MUTED
SKIN.colNumSliderNotch = Color(190, 190, 190, 120)
function SKIN:PaintFrame(_, w, h)
    shadow(8, 0, 0, w, h, 22, 30)
    rect(8, 0, 0, w, h, Color(20, 20, 20, 250))
    outline(8, 0, 0, w, h, Color(95, 95, 95, 50))
    surface.SetDrawColor(getAccent())
    surface.DrawRect(0, 0, w, 2)
end

function SKIN:DrawGenericBackground(x, y, w, h)
    rect(4, x, y, w, h, Color(45, 45, 45, 240))
    outline(4, x, y, w, h, COLOR_BORDER)
end

function SKIN:PaintPanel(panel, w, h)
    if not panel.m_bBackground or panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    rect(6, 0, 0, w, h, Color(25, 25, 25, 180))
end

function SKIN:PaintButton(panel, w, h)
    if not panel.m_bBackground or panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local disabled = panel:GetDisabled()
    local alpha = disabled and 65 or panel.Depressed and 210 or panel.Hovered and 175 or 125
    rect(6, 0, 0, w, h, Color(30, 30, 30, alpha))
    outline(6, 0, 0, w, h, Color(0, 0, 0, disabled and 70 or 140))
    if panel.Hovered and not disabled then rect(6, 0, 0, w, h, getAccent(25)) end
    if not disabled then accentBar(w, h) end
end

function SKIN:PaintWindowCloseButton(panel, w, h)
    rect(4, 0, 0, w, h, panel.Hovered and Color(170, 55, 55, 215) or Color(40, 40, 40, 165))
    surface.SetDrawColor(COLOR_WHITE)
    local cx, cy = w * 0.5, h * 0.5
    surface.DrawLine(cx - 4, cy - 4, cx + 4, cy + 4)
    surface.DrawLine(cx + 4, cy - 4, cx - 4, cy + 4)
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
    rect(4, 0, 0, w, h, panel.Hovered and Color(70, 70, 70, 230) or Color(40, 40, 40, 165))
    surface.SetDrawColor(COLOR_WHITE)
    surface.DrawRect(w * 0.5 - 4, h * 0.5 + 3, 8, 1)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
    rect(4, 0, 0, w, h, panel.Hovered and Color(70, 70, 70, 230) or Color(40, 40, 40, 165))
    surface.SetDrawColor(COLOR_WHITE)
    surface.DrawOutlinedRect(w * 0.5 - 4, h * 0.5 - 4, 8, 8)
end

function SKIN:PaintListView(_, w, h)
    rect(3, 0, 0, w, h, Color(20, 20, 20, 160))
end

function SKIN:PaintListViewLine(panel, w, h)
    local alpha = panel.IsLineSelected and panel:IsLineSelected() and 80 or panel:IsHovered() and 35 or 0
    if alpha > 0 then rect(2, 0, 0, w, h, getAccent(alpha)) end
end

function SKIN:PaintScrollBarGrip(_, w, h)
    rect(2, 0, 0, w, h, getAccent(210))
end

function SKIN:PaintVScrollBar(_, w, h)
    rect(2, 0, 0, w, h, Color(30, 30, 30, 185))
end

function SKIN:PaintButtonUp(_, w, h)
    paintArrow(w, h, "5")
end

function SKIN:PaintButtonDown(_, w, h)
    paintArrow(w, h, "6")
end

function SKIN:PaintButtonLeft(_, w, h)
    paintArrow(w, h, "3")
end

function SKIN:PaintButtonRight(_, w, h)
    paintArrow(w, h, "4")
end

function SKIN:PaintTextEntry(panel, w, h)
    if panel.m_bBackground then
        controlBackground(w, h, panel:GetDisabled() and 75 or 220)
        if not panel:GetDisabled() then accentBar(w, h) end
    end

    local text = panel:GetText()
    local placeholder = panel.GetPlaceholderText and panel:GetPlaceholderText() or ""
    if text == "" and placeholder ~= "" and not panel:HasFocus() then
        local color = panel.GetPlaceholderColor and panel:GetPlaceholderColor() or COLOR_TEXT_MUTED
        local font = panel:GetFont()
        if not isstring(font) or font == "" then font = self.fontTextEntry end
        if placeholder:sub(1, 1) == "#" then placeholder = placeholder:sub(2) end
        draw.SimpleText(language.GetPhrase(placeholder), font, 5, h * 0.5, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end

    panel:DrawTextEntryText(self.colTextEntryText, panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintComboBox(panel, w, h)
    controlBackground(w, h, panel:GetDisabled() and 75 or 220)
    accentBar(w, h)
end

function SKIN:PaintMenu(_, w, h)
    shadow(4, 0, 0, w, h, 14, 20)
    rect(4, 0, 0, w, h, COLOR_PANEL)
    outline(4, 0, 0, w, h, Color(90, 90, 90, 100))
end

function SKIN:PaintPopupMenu(panel, w, h)
    rect(4, 0, 0, w, h, panel:IsHovered() and Color(45, 45, 45, 240) or COLOR_PANEL)
end

function SKIN:PaintMenuOption(panel, w, h)
    if panel.m_bBackground and (panel.Hovered or panel.Highlight) then rect(2, 0, 0, w, h, getAccent(45)) end
    if panel.GetChecked and panel:GetChecked() then
        local base = derma.GetDefaultSkin()
        if base.tex and base.tex.Menu_Check then base.tex.Menu_Check(5, h * 0.5 - 7, 15, 15) end
    end
end

function SKIN:PaintMenuSpacer(_, w, h)
    surface.SetDrawColor(Color(95, 95, 95, 130))
    surface.DrawRect(0, math.floor(h * 0.5), w, 1)
end

function SKIN:PaintPropertySheet(panel, w, h)
    local activeTab = panel:GetActiveTab()
    local offset = IsValid(activeTab) and activeTab:GetTall() - 8 or 0
    rect(4, 0, offset, w, h - offset, Color(20, 20, 20, 165))
end

function SKIN:PaintTab(panel, w, h)
    if panel:IsActive() then return self:PaintActiveTab(panel, w, h) end
    rect(4, 0, 0, w, h, panel.Hovered and Color(50, 50, 50, 255) or Color(35, 35, 35, 255))
end

function SKIN:PaintActiveTab(_, w, h)
    rect(4, 0, 0, w, h, Color(20, 20, 20, 255))
    accentBar(w, h)
end

function SKIN:PaintTree(panel, w, h)
    if not panel.m_bBackground then return end
    rect(3, 0, 0, w, h, Color(45, 45, 45, 220))
    outline(3, 0, 0, w, h, COLOR_BORDER)
end

function SKIN:PaintTreeNodeButton(panel, w, h)
    if panel.m_bSelected then
        rect(2, 0, 0, w, h, getAccent(75))
    elseif panel.Hovered then
        rect(2, 0, 0, w, h, Color(65, 65, 65, 140))
    end
end

function SKIN:PaintCategoryList(_, w, h)
    rect(3, 0, 0, w, h, Color(45, 45, 45, 225))
end

function SKIN:PaintCollapsibleCategory(panel, w, h)
    local headerHeight = panel:GetHeaderHeight()
    rect(3, 0, 0, w, h, Color(45, 45, 45, 235))
    rect(3, 0, 0, w, headerHeight, Color(55, 55, 55, 255))
    outline(3, 0, 0, w, h, COLOR_BORDER)
end

function SKIN:PaintCheckBox(panel, w, h)
    local diameter = math.min(w, h)
    local x, y = (w - diameter) * 0.5, (h - diameter) * 0.5
    rect(diameter * 0.5, x, y, diameter, diameter, COLOR_CONTROL, renderer.SHAPE_CIRCLE)
    outline(diameter * 0.5, x, y, diameter, diameter, COLOR_BORDER, renderer.SHAPE_CIRCLE)
    if panel.Hovered then rect(diameter * 0.5, x, y, diameter, diameter, getAccent(35), renderer.SHAPE_CIRCLE) end
    if panel.GetChecked and panel:GetChecked() then
        local inner = diameter - 5
        rect(inner * 0.5, x + 2.5, y + 2.5, inner, inner, getAccent(), renderer.SHAPE_CIRCLE)
    end
end

function SKIN:PaintExpandButton(panel, w, h)
    paintArrow(w, h, panel:GetExpanded() and "6" or "4")
end

function SKIN:PaintNumberUp(_, w, h)
    paintArrow(w, h, "5")
end

function SKIN:PaintNumberDown(_, w, h)
    paintArrow(w, h, "6")
end

function SKIN:PaintSlider(_, w, h)
    local trackHeight = math.min(h, 6)
    rect(3, 0, (h - trackHeight) * 0.5, w, trackHeight, COLOR_CONTROL)
end

function SKIN:PaintNumSlider(panel, w, h)
    self:PaintSlider(panel, w, h)
end

function SKIN:PaintSliderKnob(_, w, h)
    local diameter = math.min(w, h)
    rect(diameter * 0.5, (w - diameter) * 0.5, (h - diameter) * 0.5, diameter, diameter, getAccent(220), renderer.SHAPE_CIRCLE)
end

function SKIN:PaintNumSliderText(_, w, h)
    controlBackground(w, h, 225)
    accentBar(w, h)
end

function SKIN:PaintTooltip(_, w, h)
    shadow(6, 0, 0, w, h, 12, 18)
    rect(6, 0, 0, w, h, Color(25, 25, 25, 245))
    outline(6, 0, 0, w, h, Color(100, 100, 100, 110))
    accentBar(w, h)
end

function SKIN:PaintListBox(_, w, h)
    self:DrawGenericBackground(0, 0, w, h)
end

function SKIN:PaintContentPanel(_, w, h)
    self:DrawGenericBackground(0, 0, w, h)
end

function SKIN:PaintCategoryButton(panel, w, h)
    local alpha = panel:GetDisabled() and 65 or panel.Depressed and 210 or panel.Hovered and 175 or 125
    controlBackground(w, h, alpha)
    if not panel:GetDisabled() then accentBar(w, h) end
end

function SKIN:PaintSpawnIcon(panel, w, h)
    if panel:IsHovered() then rect(3, 0, 0, w, h, getAccent(22)) end
    outline(3, 0, 0, w, h, Color(0, 0, 0, 150))
end

function SKIN:PaintContentIcon(panel, w, h)
    self:PaintSpawnIcon(panel, w, h)
end

derma.DefineSkin("Lilia Skin Alt", "Dark rounded alternative skin for Lilia.", SKIN)
derma.RefreshSkins()