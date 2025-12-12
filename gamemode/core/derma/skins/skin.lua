local surface = surface
local Color = Color
local ColorAlpha = ColorAlpha
local function getTheme()
    local theme = lia.color.theme or {}
    return {
        text = theme.text or Color(220, 220, 220),
        header = theme.header or theme.theme or Color(52, 73, 94),
        headerText = theme.header_text or theme.text or Color(255, 255, 255),
        background = theme.background_alpha or theme.background or Color(34, 34, 34, 230),
        panel = theme.panel and theme.panel[1] or theme.background_alpha or theme.background or Color(30, 30, 30, 210),
        hover = theme.hover or Color(255, 255, 255, 20),
        accent = theme.accent or theme.theme or Color(116, 185, 255),
        shadow = theme.window_shadow or Color(0, 0, 0, 170),
        focus = theme.focus_panel or Color(255, 255, 255, 24),
        scrollbar = theme.scrollbar or theme.theme or Color(255, 255, 255)
    }
end

local function drawAltBg(panel, w, h)
    local colors = getTheme()
    if panel:GetName() and (panel:GetName():find("ContentContainer") or panel:GetName():find("Tree")) then lia.util.drawBlur(panel, 5) end
    lia.derma.rect(0, 0, w, h):Rad(6):Color(colors.shadow):Shadow(6, 14):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(colors.panel):Shape(lia.derma.SHAPE_IOS):Draw()
end

local SKIN = {}
local BASE = derma.GetDefaultSkin() or {}
SKIN.Base = "Default"
SKIN.PrintName = "Lilia"
SKIN.Author = "Lilia Framework"
SKIN.DermaVersion = BASE.DermaVersion or 1
SKIN.fontFrame = "BudgetLabel"
SKIN.fontTab = "LiliaFont.17"
SKIN.fontButton = "LiliaFont.17"
SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Window.TitleActive = Color(255, 255, 255)
SKIN.Colours.Window.TitleInactive = Color(255, 255, 255)
SKIN.Colours.Label.Dark = lia.color.theme and lia.color.theme.text or Color(200, 200, 200)
SKIN.Colours.Button.Normal = lia.color.theme and lia.color.theme.text or Color(200, 200, 200)
SKIN.Colours.Button.Hover = Color(255, 255, 255)
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)
SKIN.Colours.Tree = table.Copy(derma.SkinList.Default.Colours.Tree)
SKIN.Colours.Tree.Text = Color(255, 255, 255)
SKIN.Colours.Tree.SelectedText = Color(255, 255, 255)
function SKIN:PaintFrame(panel)
    if not panel.LaidOut then
        for _, btn in ipairs({panel.btnMinimize, panel.btnMaximize, panel.btnClose}) do
            if btn and btn:IsValid() then
                btn:SetText("")
                btn:SetPaintBackground(true)
            end
        end

        panel.LaidOut = true
    end

    local colors = getTheme()
    local w, h = panel:GetWide(), panel:GetTall()
    local radius = 6
    local headerH = math.min(24, h)
    lia.util.drawBlur(panel, 8)
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(colors.shadow):Shadow(8, 16):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, headerH):Radii(radius, radius, 0, 0):Color(colors.header):Draw()
    lia.derma.rect(0, headerH, w, math.max(h - headerH, 0)):Radii(0, 0, radius, radius):Color(colors.background):Draw()
end

function SKIN:DrawGenericBackground(x, y, w, h)
    local colors = getTheme()
    lia.derma.rect(x, y, w, h):Rad(6):Color(colors.shadow):Shadow(5, 12):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(x, y, w, h):Rad(6):Color(colors.panel):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintPanel(panel)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local w, h = panel:GetWide(), panel:GetTall()
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(colors.panel):Shape(lia.derma.SHAPE_IOS):Draw()
    if panel.Hovered then lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.focus, 90)):Shape(lia.derma.SHAPE_IOS):Draw() end
end

local function paintButtonBase(panel, w, h)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local colors = getTheme()
    local base = ColorAlpha(colors.panel, 200)
    if panel:GetDisabled() then
        base = ColorAlpha(colors.panel, 80)
    elseif panel.Depressed then
        base = ColorAlpha(colors.accent, 220)
    elseif panel.Hovered then
        base = ColorAlpha(colors.accent, 180)
    end

    lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
    if not panel:GetDisabled() and panel.Hovered and not panel.Depressed then lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.focus, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    local colors = getTheme()
    surface.SetDrawColor(colors.headerText)
    local t = 1
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - t) * 0.5
    surface.DrawRect(x, y, iconW, t)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    local colors = getTheme()
    surface.SetDrawColor(colors.headerText)
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - iconW) * 0.5
    surface.DrawOutlinedRect(x, y, iconW, iconW)
end

function SKIN:PaintWindowCloseButton(panel, w, h)
    paintButtonBase(panel, w, h)
    local colors = getTheme()
    surface.SetDrawColor(colors.headerText)
    local iconW = w * 0.4
    local x1 = (w - iconW) * 0.5
    local y1 = (h - iconW) * 0.5
    local x2 = x1 + iconW
    local y2 = y1 + iconW
    surface.DrawLine(x1, y1, x2, y2)
    surface.DrawLine(x2, y1, x1, y2)
end

function SKIN:PaintButton(panel)
    paintButtonBase(panel, panel:GetWide(), panel:GetTall())
end

function SKIN:PaintComboBox(panel, w, h)
    if panel:GetFont() == "Default" or panel:GetFont() == "" then panel:SetFont("LiliaFont.18") end
    paintButtonBase(panel, w, h)
end

function SKIN:PaintTextEntry(panel, w, h)
    if panel.m_bBackground then
        local colors = getTheme()
        local base = ColorAlpha(colors.panel, panel:GetDisabled() and 90 or 200)
        if panel.Depressed then
            base = ColorAlpha(colors.accent, 220)
        elseif panel.Hovered then
            base = ColorAlpha(colors.accent, 160)
        end

        lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
        local outline = panel:HasFocus() and colors.accent or ColorAlpha(colors.focus, 120)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(outline):Outline(1):Draw()
    end

    if panel.GetPlaceholderText and panel.GetPlaceholderColor and panel:GetPlaceholderText() and panel:GetPlaceholderText():Trim() ~= "" and panel:GetPlaceholderColor() and (not panel:GetText() or panel:GetText() == "") then
        local old = panel:GetText()
        local str = panel:GetPlaceholderText()
        if str:StartWith("#") then str = str:sub(2) end
        str = language.GetPhrase(str)
        panel:SetText(str)
        panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor())
        panel:SetText(old)
        return
    end

    local colors = getTheme()
    panel:DrawTextEntryText(colors.text, panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintListView(_, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.panel, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintListViewLine(panel, w, h)
    local colors = getTheme()
    local col = (panel:IsHovered() or panel:IsLineSelected()) and ColorAlpha(colors.accent, 160) or Color(0, 0, 0, 0)
    lia.derma.rect(0, 0, w, h):Rad(4):Color(col):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintScrollBarGrip(_, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.accent, 210)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintButtonUp(_, w, h)
    if w <= 0 then return end
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.accent, 210)):Shape(lia.derma.SHAPE_IOS):Draw()
    surface.SetTextColor(colors.headerText)
    surface.SetFont("Marlett")
    surface.SetTextPos(1, 1)
    surface.DrawText("▲")
end

function SKIN:PaintButtonDown(_, w, h)
    if w <= 0 then return end
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.accent, 210)):Shape(lia.derma.SHAPE_IOS):Draw()
    surface.SetTextColor(colors.headerText)
    surface.SetFont("Marlett")
    surface.SetTextPos(1, 0)
    surface.DrawText("▼")
end

function SKIN:PaintVScrollBar(_, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.panel, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintMenu(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintMenuOption(panel, w, h)
    if not panel.LaidOut then
        panel.LaidOut = true
        panel:SetTextColor(getTheme().text)
    end

    if panel.m_bBackground and (panel.Hovered or panel.Highlight) then
        local colors = getTheme()
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.hover, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local skin = derma.GetDefaultSkin()
    skin.MenuOptionOdd = not skin.MenuOptionOdd
    if panel:GetChecked() then skin.tex.Menu_Check(5, h / 2 - 7, 15, 15) end
end

function SKIN:PaintTreeNodeButton(panel, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(colors.panel):Shape(lia.derma.SHAPE_IOS):Draw()
    if panel.m_bSelected then
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.accent, 140)):Shape(lia.derma.SHAPE_IOS):Draw()
    elseif panel.Hovered then
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.hover, 180)):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    panel:SetTextColor(colors.text)
end

function SKIN:PaintTooltip(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintPopupMenu(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintCategoryList(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintCategoryButton(panel, w, h)
    paintButtonBase(panel, w, h)
end

function SKIN:PaintContentPanel(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintContentIcon(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintSpawnIcon(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintTree(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintTreeNode(_, _, h)
    local colors = getTheme()
    surface.SetDrawColor(colors.text)
    surface.DrawRect(9, 0, 1, h)
    surface.DrawRect(9, 7, 9, 1)
end

function SKIN:PaintShadow(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintMenuSpacer(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintPropertySheet(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintTab(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintActiveTab(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintButtonLeft(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintButtonRight(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintListBox(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintNumberUp(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintNumberDown(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintSelection(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintMenuBar(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintMenuRightArrow(_, w, h)
    local colors = getTheme()
    local cx, cy = w * 0.5, h * 0.5
    surface.SetDrawColor(colors.text)
    surface.DrawPoly({
        {
            x = cx - 3,
            y = cy - 5
        },
        {
            x = cx + 3,
            y = cy
        },
        {
            x = cx - 3,
            y = cy + 5
        }
    })
end

function SKIN:PaintHScrollBar(_, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.panel, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintCheckBox(panel, w, h)
    local colors = getTheme()
    local base = ColorAlpha(colors.panel, panel:GetDisabled() and 60 or 180)
    if panel.Depressed then
        base = ColorAlpha(colors.accent, 220)
    elseif panel.Hovered then
        base = ColorAlpha(colors.accent, 160)
    end

    lia.derma.rect(0, 0, w, h):Rad(4):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
    if panel:GetChecked() then
        lia.derma.rect(3, 3, w - 6, h - 6):Rad(3):Color(colors.accent):Shape(lia.derma.SHAPE_IOS):Draw()
        surface.SetDrawColor(colors.headerText)
        surface.DrawLine(4, h * 0.55, w * 0.4, h - 4)
        surface.DrawLine(w * 0.4, h - 4, w - 4, 4)
    end
end

function SKIN:PaintRadioButton(panel, w, h)
    local colors = getTheme()
    local r = math.min(w, h)
    local base = ColorAlpha(colors.panel, panel:GetDisabled() and 60 or 180)
    if panel.Depressed then
        base = ColorAlpha(colors.accent, 220)
    elseif panel.Hovered then
        base = ColorAlpha(colors.accent, 160)
    end

    lia.derma.circle(w / 2, h / 2, r):Color(base):Draw()
    if panel:GetChecked() then lia.derma.circle(w / 2, h / 2, r * 0.5):Color(colors.accent):Draw() end
end

function SKIN:PaintExpandButton(panel, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.panel, 160)):Shape(lia.derma.SHAPE_IOS):Draw()
    surface.SetDrawColor(colors.text)
    surface.DrawRect(4, h * 0.5 - 1, w - 8, 2)
    if not panel:GetExpanded() then surface.DrawRect(w * 0.5 - 1, 4, 2, h - 8) end
end

function SKIN:PaintComboDownArrow(_, w, h)
    local colors = getTheme()
    surface.SetDrawColor(colors.headerText)
    surface.DrawPoly({
        {
            x = w * 0.25,
            y = h * 0.4
        },
        {
            x = w * 0.5,
            y = h * 0.65
        },
        {
            x = w * 0.75,
            y = h * 0.4
        }
    })
end

function SKIN:PaintSliderKnob(panel, w, h)
    local colors = getTheme()
    local base = ColorAlpha(colors.accent, panel.Depressed and 240 or panel.Hovered and 200 or 160)
    lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintNumSlider(panel, w, h)
    local colors = getTheme()
    surface.SetDrawColor(ColorAlpha(colors.text, 180))
    surface.DrawRect(8, h / 2, w - 16, 1)
    local notches = panel.GetNotches and panel:GetNotches() or 0
    if notches > 0 then
        local space = (w - 16) / notches
        for i = 0, notches do
            surface.DrawRect(8 + i * space, h / 2 - 3, 1, 6)
        end
    end
end

function SKIN:PaintProgress(panel, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(colors.panel, 180)):Shape(lia.derma.SHAPE_IOS):Draw()
    local frac = math.Clamp(panel:GetFraction() or 0, 0, 1)
    if frac > 0 then lia.derma.rect(0, 0, w * frac, h):Rad(6):Color(ColorAlpha(colors.accent, 220)):Shape(lia.derma.SHAPE_IOS):Draw() end
end

function SKIN:PaintHScrollBarGrip(panel, w, h)
    local colors = getTheme()
    local base = ColorAlpha(colors.accent, panel.Depressed and 240 or panel.Hovered and 210 or 180)
    lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintComboBox(panel, w, h)
    if panel:GetFont() == "Default" or panel:GetFont() == "" then panel:SetFont("LiliaFont.18") end
    paintButtonBase(panel, w, h)
end

function SKIN:PaintListBox(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintSelection(_, w, h)
    local colors = getTheme()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(colors.accent, 160)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintMenuSpacer(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintTooltip(panel, w, h)
    drawAltBg(panel, w, h)
end

derma.DefineSkin(L("liliaSkin"), L("liliaSkinDesc"), SKIN)
local skinTestFrame
local function addRow(list, title, height, builder)
    local row = list:Add("DPanel")
    row:SetTall(height or 96)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 8)
    row:DockPadding(10, 8, 10, 8)
    row:SetPaintBackground(false)
    local label = row:Add("DLabel")
    label:SetFont("LiliaFont.18")
    label:SetText(title)
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, 6)
    label:SizeToContents()
    local holder = row:Add("DPanel")
    holder:Dock(FILL)
    holder:SetPaintBackground(false)
    builder(holder)
end

local function buildSkinPreview()
    if IsValid(skinTestFrame) then skinTestFrame:Remove() end
    skinTestFrame = vgui.Create("DFrame")
    skinTestFrame:SetSize(960, 720)
    skinTestFrame:Center()
    skinTestFrame:SetTitle("Lilia Skin Preview")
    skinTestFrame:MakePopup()
    local scroll = skinTestFrame:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockPadding(10, 10, 10, 10)
    local list = scroll:Add("DListLayout")
    list:Dock(TOP)
    list:SetSize(scroll:GetWide(), 0)
    addRow(list, "Checkboxes & Radio Buttons", 90, function(parent)
        local cb = parent:Add("DCheckBoxLabel")
        cb:Dock(LEFT)
        cb:SetText("Checkbox")
        cb:SetValue(true)
        cb:SizeToContents()
        local radioWrap = parent:Add("DPanel")
        radioWrap:Dock(LEFT)
        radioWrap:DockMargin(16, 0, 0, 0)
        radioWrap:SetWide(140)
        radioWrap:SetPaintBackground(false)
        local rb = radioWrap:Add("DRadioButton")
        rb:Dock(LEFT)
        rb:SetValue(true)
        local rbLabel = radioWrap:Add("DLabel")
        rbLabel:Dock(LEFT)
        rbLabel:DockMargin(6, 0, 0, 0)
        rbLabel:SetText("Radio")
        rbLabel:SizeToContents()
    end)

    addRow(list, "Collapsible (Expand Button)", 140, function(parent)
        local cat = parent:Add("DCollapsibleCategory")
        cat:Dock(FILL)
        cat:SetLabel("Click to expand")
        cat:SetExpanded(false)
        local inner = vgui.Create("DPanel")
        inner:SetTall(60)
        inner:DockPadding(8, 8, 8, 8)
        inner.Paint = function(_, w, h)
            surface.SetDrawColor(0, 0, 0, 40)
            surface.DrawRect(0, 0, w, h)
        end

        cat:SetContents(inner)
    end)

    addRow(list, "Combo Box & Down Arrow", 90, function(parent)
        local combo = parent:Add("DComboBox")
        combo:Dock(LEFT)
        combo:SetWide(220)
        combo:SetValue("Choose an option")
        combo:AddChoice("Option A")
        combo:AddChoice("Option B")
        combo:AddChoice("Option C")
    end)

    addRow(list, "Horizontal Scrollbar & Grip", 120, function(parent)
        local scrollBar = parent:Add("liaHorizontalScroll")
        scrollBar:Dock(FILL)
        for i = 1, 12 do
            local btn = vgui.Create("DButton")
            btn:SetWide(120)
            btn:SetText("Item " .. i)
            scrollBar:AddItem(btn)
        end
    end)

    addRow(list, "Num Slider & Knob", 110, function(parent)
        local slider = parent:Add("DNumSlider")
        slider:Dock(TOP)
        slider:SetText("Volume")
        slider:SetMin(0)
        slider:SetMax(100)
        slider:SetDecimals(0)
        slider:SetValue(60)
    end)

    addRow(list, "Progress Bar", 90, function(parent)
        local bar = parent:Add("DProgress")
        bar:Dock(TOP)
        bar:SetTall(24)
        bar.Think = function(self)
            local frac = (math.sin(CurTime() * 1.2) + 1) * 0.5
            self:SetFraction(frac)
        end
    end)

    addRow(list, "List View Selection", 160, function(parent)
        local listView = parent:Add("DListView")
        listView:Dock(FILL)
        listView:AddColumn("Name")
        listView:AddColumn("Role")
        listView:AddLine("Alex", "Builder")
        listView:AddLine("Sam", "Pilot")
        listView:AddLine("Jamie", "Engineer")
        listView:SelectItem(listView:GetLine(2))
    end)

    addRow(list, "List Box", 140, function(parent)
        local listBox = parent:Add("DListBox")
        listBox:Dock(FILL)
        listBox:AddItem("First choice")
        listBox:AddItem("Second choice")
        listBox:AddItem("Third choice")
    end)

    addRow(list, "Menu, Right Arrow, Spacer, Tooltip", 110, function(parent)
        local btn = parent:Add("DButton")
        btn:Dock(LEFT)
        btn:SetWide(200)
        btn:SetText("Open test menu")
        btn:SetTooltip("Hover here to see tooltip styling")
        btn.DoClick = function()
            local menu = DermaMenu()
            menu:AddOption("Primary option")
            menu:AddSpacer()
            local submenu = menu:AddSubMenu("Sub menu")
            submenu:AddOption("Child A")
            submenu:AddOption("Child B")
            menu:Open()
        end
    end)
end

concommand.Add("lia_skin_test", buildSkinPreview)
