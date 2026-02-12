local surface = surface
local Color = Color
local ColorAlpha = ColorAlpha
local function getThemeBackground()
    return Color(25, 28, 35, 250)
end

local function getThemeBackgroundSolid()
    return Color(25, 28, 35, 250)
end

local function drawAltBg(panel, w, h)
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
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
SKIN.Colours.Button.Disabled = Color(120, 120, 120)
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

    local w, h = panel:GetWide(), panel:GetTall()
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:DrawGenericBackground(x, y, w, h)
    local bgColor = getThemeBackground()
    lia.derma.rect(x, y, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintPanel(panel)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local w, h = panel:GetWide(), panel:GetTall()
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

local function paintButtonBase(panel, w, h)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local bgColor = getThemeBackgroundSolid()
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local base = ColorAlpha(bgColor, panel:GetDisabled() and 80 or 200)
    lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
    if not panel:GetDisabled() then
        if panel.Depressed then
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 60)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(accentColor):Outline(1):Draw()
        elseif panel.Hovered then
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 35)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 180)):Outline(1):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(Color(255, 255, 255), 24)):Shape(lia.derma.SHAPE_IOS):Draw()
        end
    end
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(Color(255, 255, 255))
    local t = 1
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - t) * 0.5
    surface.DrawRect(x, y, iconW, t)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(Color(255, 255, 255))
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - iconW) * 0.5
    surface.DrawOutlinedRect(x, y, iconW, iconW)
end

function SKIN:PaintWindowCloseButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(Color(255, 255, 255))
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
        local bgColor = getThemeBackgroundSolid()
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        local base = ColorAlpha(bgColor, panel:GetDisabled() and 90 or 200)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
        if not panel:GetDisabled() then
            if panel.Depressed or panel:HasFocus() then
                lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 55)):Shape(lia.derma.SHAPE_IOS):Draw()
            elseif panel.Hovered then
                lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 28)):Shape(lia.derma.SHAPE_IOS):Draw()
            end
        end

        local outline = panel:HasFocus() and accentColor or ColorAlpha(Color(255, 255, 255), 30)
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

    panel:DrawTextEntryText(Color(220, 220, 220), panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintListView(_, w, h)
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintListViewLine(panel, w, h)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    if panel:IsLineSelected() then
        local bgColor = getThemeBackgroundSolid()
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(bgColor, 185)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 50)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 160)):Outline(1):Draw()
    end
end

function SKIN:PaintScrollBarGrip(_, w, h)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 160)):Outline(1):Draw()
end

function SKIN:PaintButtonUp(_, w, h)
    if w <= 0 then return end
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(bgColor, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 140)):Outline(1):Draw()
    surface.SetTextColor(Color(255, 255, 255))
    surface.SetFont("Marlett")
    surface.SetTextPos(1, 1)
    surface.DrawText("▲")
end

function SKIN:PaintButtonDown(_, w, h)
    if w <= 0 then return end
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(bgColor, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 140)):Outline(1):Draw()
    surface.SetTextColor(Color(255, 255, 255))
    surface.SetFont("Marlett")
    surface.SetTextPos(1, 0)
    surface.DrawText("▼")
end

function SKIN:PaintVScrollBar(_, w, h)
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintMenu(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintMenuOption(panel, w, h)
    if not panel.LaidOut then
        panel.LaidOut = true
        panel:SetTextColor(Color(220, 220, 220))
    end

    if panel.m_bBackground and (panel.Hovered or panel.Highlight) then lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(Color(255, 255, 255), 50)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local skin = derma.GetDefaultSkin()
    skin.MenuOptionOdd = not skin.MenuOptionOdd
    if panel:GetChecked() then skin.tex.Menu_Check(5, h / 2 - 7, 15, 15) end
end

function SKIN:PaintTreeNodeButton(panel, w, h)
    local bgColor = getThemeBackground()
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    lia.derma.rect(0, 0, w, h):Rad(4):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    if panel.m_bSelected then
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 50)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 180)):Outline(1):Draw()
    elseif panel.Hovered then
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(Color(255, 255, 255), 36)):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    panel:SetTextColor(Color(220, 220, 220))
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
    surface.SetDrawColor(Color(220, 220, 220))
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
    local cx, cy = w * 0.5, h * 0.5
    surface.SetDrawColor(Color(220, 220, 220))
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
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 200)):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintCheckBox(panel, w, h)
    local bgColor = getThemeBackgroundSolid()
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local base = ColorAlpha(bgColor, panel:GetDisabled() and 60 or 180)
    lia.derma.rect(0, 0, w, h):Rad(4):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
    if not panel:GetDisabled() then
        if panel.Depressed then
            lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 65)):Shape(lia.derma.SHAPE_IOS):Draw()
        elseif panel.Hovered then
            lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 40)):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        if panel.Hovered or panel.Depressed then lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 160)):Outline(1):Draw() end
    end

    if panel:GetChecked() then
        lia.derma.rect(3, 3, w - 6, h - 6):Rad(3):Color(accentColor):Shape(lia.derma.SHAPE_IOS):Draw()
        surface.SetDrawColor(Color(255, 255, 255))
        surface.DrawLine(4, h * 0.55, w * 0.4, h - 4)
        surface.DrawLine(w * 0.4, h - 4, w - 4, 4)
    end
end

function SKIN:PaintRadioButton(panel, w, h)
    local bgColor = getThemeBackgroundSolid()
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local r = math.min(w, h)
    local base = ColorAlpha(bgColor, panel:GetDisabled() and 60 or 180)
    lia.derma.circle(w / 2, h / 2, r):Color(base):Draw()
    if not panel:GetDisabled() then
        if panel.Depressed then
            lia.derma.circle(w / 2, h / 2, r):Color(ColorAlpha(accentColor, 65)):Draw()
        elseif panel.Hovered then
            lia.derma.circle(w / 2, h / 2, r):Color(ColorAlpha(accentColor, 40)):Draw()
        end
    end

    if panel:GetChecked() then lia.derma.circle(w / 2, h / 2, r * 0.5):Color(accentColor):Draw() end
end

function SKIN:PaintExpandButton(panel, w, h)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(bgColor, 160)):Shape(lia.derma.SHAPE_IOS):Draw()
    surface.SetDrawColor(Color(220, 220, 220))
    surface.DrawRect(4, h * 0.5 - 1, w - 8, 2)
    if not panel:GetExpanded() then surface.DrawRect(w * 0.5 - 1, 4, 2, h - 8) end
end

function SKIN:PaintComboDownArrow(_, w, h)
    surface.SetDrawColor(Color(255, 255, 255))
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
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    local base = ColorAlpha(bgColor, 200)
    lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
    local overlay = panel.Depressed and 70 or panel.Hovered and 45 or 0
    if overlay > 0 then lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, overlay)):Shape(lia.derma.SHAPE_IOS):Draw() end
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, panel.Depressed and 220 or panel.Hovered and 190 or 140)):Outline(1):Draw()
end

function SKIN:PaintNumSlider(panel, w, h)
    surface.SetDrawColor(ColorAlpha(Color(220, 220, 220), 180))
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
    local bgColor = getThemeBackgroundSolid()
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 180)):Shape(lia.derma.SHAPE_IOS):Draw()
    local frac = math.Clamp(panel:GetFraction() or 0, 0, 1)
    if frac > 0 then
        lia.derma.rect(0, 0, w * frac, h):Rad(6):Color(ColorAlpha(bgColor, 220)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w * frac, h):Rad(6):Color(ColorAlpha(accentColor, 60)):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    if not (panel and panel.GetDisabled and panel:GetDisabled()) then lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 140)):Outline(1):Draw() end
end

function SKIN:PaintHScrollBarGrip(panel, w, h)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(bgColor, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
    if panel.Depressed then
        lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 70)):Shape(lia.derma.SHAPE_IOS):Draw()
    elseif panel.Hovered then
        lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 45)):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, panel.Depressed and 220 or panel.Hovered and 190 or 140)):Outline(1):Draw()
end

function SKIN:PaintComboBox(panel, w, h)
    if panel:GetFont() == "Default" or panel:GetFont() == "" then panel:SetFont("LiliaFont.18") end
    paintButtonBase(panel, w, h)
end

function SKIN:PaintListBox(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintSelection(_, w, h)
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    local bgColor = getThemeBackgroundSolid()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(bgColor, 190)):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 55)):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(accentColor, 190)):Outline(1):Draw()
end

function SKIN:PaintMenuSpacer(panel, w, h)
    drawAltBg(panel, w, h)
end

function SKIN:PaintTooltip(panel, w, h)
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

function SKIN:PaintPropertySheet(panel, w, h)
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local bgColor = getThemeBackground()
    lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

derma.DefineSkin(L("liliaSkin"), L("liliaSkinDesc"), SKIN)
local skinTestFrame
local function addRow(list, title, height, builder)
    local row = list:Add("DPanel")
    row:SetTall(height or 60)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, 4)
    row:DockPadding(8, 4, 8, 4)
    row:SetPaintBackground(false)
    local label = row:Add("DLabel")
    label:SetFont("LiliaFont.16")
    label:SetText(title)
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, 4)
    label:SizeToContents()
    local holder = row:Add("DPanel")
    holder:Dock(FILL)
    holder:SetPaintBackground(false)
    builder(holder)
end

local function buildSkinPreview()
    if IsValid(skinTestFrame) then skinTestFrame:Remove() end
    skinTestFrame = vgui.Create("DFrame")
    skinTestFrame.Paint = function() end
    skinTestFrame:SetSize(1200, 800)
    skinTestFrame:Center()
    skinTestFrame:SetTitle("Lilia Skin Preview")
    skinTestFrame:MakePopup()
    skinTestFrame:SetSizable(true)
    local scroll = skinTestFrame:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockPadding(5, 5, 5, 5)
    local list = scroll:Add("DListLayout")
    list:Dock(TOP)
    list:SetSize(scroll:GetWide(), 0)
    addRow(list, "Checkboxes & Radio Buttons", 70, function(parent)
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
        local radio1 = radioWrap:Add("DCheckBox")
        radio1:Dock(TOP)
        radio1:SetText("Radio 1")
        radio1:SetValue(true)
        radio1:SizeToContents()
        local radio2 = radioWrap:Add("DCheckBox")
        radio2:Dock(TOP)
        radio2:SetText("Radio 2")
        radio2:SetValue(false)
        radio2:SizeToContents()
    end)

    addRow(list, "Collapsible (Expand Button)", 100, function(parent)
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

    addRow(list, "Combo Box & Down Arrow", 70, function(parent)
        local combo = parent:Add("DComboBox")
        combo:Dock(LEFT)
        combo:SetWide(220)
        combo:SetValue("Choose an option")
        combo:AddChoice("Option A")
        combo:AddChoice("Option B")
        combo:AddChoice("Option C")
    end)

    addRow(list, "Horizontal Scrollbar & Grip", 80, function(parent)
        local scrollBar = parent:Add("liaHorizontalScroll")
        scrollBar:Dock(FILL)
        for i = 1, 12 do
            local btn = vgui.Create("DButton")
            btn:SetWide(120)
            btn:SetText("Item " .. i)
            scrollBar:AddItem(btn)
        end
    end)

    addRow(list, "Num Slider & Knob", 80, function(parent)
        local slider = parent:Add("DNumSlider")
        slider:Dock(TOP)
        slider:SetText("Volume")
        slider:SetMin(0)
        slider:SetMax(100)
        slider:SetDecimals(0)
        slider:SetValue(60)
    end)

    addRow(list, "Progress Bar", 70, function(parent)
        local bar = parent:Add("DProgress")
        bar:Dock(TOP)
        bar:SetTall(24)
        bar.Think = function(self)
            local frac = (math.sin(CurTime() * 1.2) + 1) * 0.5
            self:SetFraction(frac)
        end
    end)

    addRow(list, "List View Selection", 120, function(parent)
        local listView = parent:Add("DListView")
        listView:Dock(FILL)
        listView:AddColumn("Name")
        listView:AddColumn("Role")
        listView:AddLine("Alex", "Builder")
        listView:AddLine("Sam", "Pilot")
        listView:AddLine("Jamie", "Engineer")
        listView:SelectItem(listView:GetLine(2))
    end)

    addRow(list, "List Box", 100, function(parent)
        local listBox = parent:Add("DListBox")
        listBox:Dock(FILL)
        listBox:AddItem("First choice")
        listBox:AddItem("Second choice")
        listBox:AddItem("Third choice")
    end)

    addRow(list, "Menu, Right Arrow, Spacer, Tooltip", 70, function(parent)
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

    addRow(list, "Text Entry", 60, function(parent)
        local textEntry = parent:Add("DTextEntry")
        textEntry:Dock(FILL)
        textEntry:SetPlaceholderText("Enter text here...")
        textEntry:SetText("Sample text")
    end)

    addRow(list, "Tree View", 120, function(parent)
        local tree = parent:Add("DTree")
        tree:Dock(FILL)
        local node1 = tree:AddNode("Root Node", "icon16/folder.png")
        node1:AddNode("Child Node 1", "icon16/page.png")
        node1:AddNode("Child Node 2", "icon16/page.png")
        local node4 = tree:AddNode("Another Root", "icon16/folder.png")
        node4:AddNode("Another Child", "icon16/page.png")
    end)

    addRow(list, "Property Sheet with Tabs", 120, function(parent)
        local sheet = parent:Add("DPropertySheet")
        sheet:Dock(FILL)
        local panel1 = vgui.Create("DPanel")
        panel1:SetPaintBackground(false)
        local label1 = panel1:Add("DLabel")
        label1:SetText("First tab content")
        label1:SetPos(20, 20)
        local panel2 = vgui.Create("DPanel")
        panel2:SetPaintBackground(false)
        local label2 = panel2:Add("DLabel")
        label2:SetText("Second tab content")
        label2:SetPos(20, 20)
        sheet:AddSheet("Tab 1", panel1, "icon16/page.png")
        sheet:AddSheet("Tab 2", panel2, "icon16/page_white.png")
    end)

    addRow(list, "Category List", 100, function(parent)
        local catList = parent:Add("DCategoryList")
        catList:Dock(FILL)
        local cat1 = catList:Add("Category 1")
        cat1:Add("Item 1.1")
        cat1:Add("Item 1.2")
        local cat2 = catList:Add("Category 2")
        cat2:Add("Item 2.1")
        cat2:Add("Item 2.2")
    end)

    addRow(list, "Vertical Scrollbar", 100, function(parent)
        local scrollPanel = parent:Add("DScrollPanel")
        scrollPanel:Dock(FILL)
        for i = 1, 8 do
            local btn = scrollPanel:Add("DButton")
            btn:SetTall(30)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 2)
            btn:SetText("Scroll Item " .. i)
        end
    end)

    addRow(list, "Buttons (Various States)", 70, function(parent)
        local normalBtn = parent:Add("DButton")
        normalBtn:Dock(LEFT)
        normalBtn:SetWide(100)
        normalBtn:SetText("Normal")
        local disabledBtn = parent:Add("DButton")
        disabledBtn:Dock(LEFT)
        disabledBtn:DockMargin(8, 0, 0, 0)
        disabledBtn:SetWide(100)
        disabledBtn:SetText("Disabled")
        disabledBtn:SetDisabled(true)
        local iconBtn = parent:Add("DButton")
        iconBtn:Dock(LEFT)
        iconBtn:DockMargin(8, 0, 0, 0)
        iconBtn:SetWide(100)
        iconBtn:SetText("Icon Button")
    end)

    addRow(list, "Spawn Icons", 80, function(parent)
        local spawnIcon1 = parent:Add("SpawnIcon")
        spawnIcon1:Dock(LEFT)
        spawnIcon1:SetSize(64, 64)
        spawnIcon1:SetModel("models/props_c17/oildrum001.mdl")
        local spawnIcon2 = parent:Add("SpawnIcon")
        spawnIcon2:Dock(LEFT)
        spawnIcon2:DockMargin(8, 0, 0, 0)
        spawnIcon2:SetSize(64, 64)
        spawnIcon2:SetModel("models/props_junk/wood_crate001a.mdl")
    end)

    addRow(list, "Frame with Window Controls", 140, function(parent)
        local frame = parent:Add("DFrame")
        frame:SetSize(300, 100)
        frame:Dock(LEFT)
        frame:SetTitle("Test Frame")
        frame.btnMinim:SetEnabled(true)
        frame.btnMaxim:SetEnabled(true)
    end)

    addRow(list, "Basic Panel", 80, function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        panel:SetBackgroundColor(Color(50, 50, 50, 100))
        local label = panel:Add("DLabel")
        label:SetText("Basic Panel")
        label:Center()
    end)

    addRow(list, "Number Spinner (Up/Down)", 80, function(parent)
        local numWang = parent:Add("DNumberWang")
        numWang:Dock(LEFT)
        numWang:SetWide(100)
        numWang:SetValue(42)
        numWang:SetMin(0)
        numWang:SetMax(100)
    end)

    addRow(list, "Menu Bar", 60, function(parent)
        local menuBar = parent:Add("DMenuBar")
        menuBar:Dock(FILL)
        local menu = menuBar:AddMenu("File")
        menu:AddOption("New")
        menu:AddOption("Open")
        menu:AddOption("Save")
        local editMenu = menuBar:AddMenu("Edit")
        editMenu:AddOption("Cut")
        editMenu:AddOption("Copy")
        editMenu:AddOption("Paste")
    end)

    addRow(list, "Tabs", 80, function(parent)
        local sheet = parent:Add("DPropertySheet")
        sheet:Dock(FILL)
        local panel1 = vgui.Create("DPanel")
        panel1:SetPaintBackground(false)
        local label1 = panel1:Add("DLabel")
        label1:SetText("Tab Content 1")
        label1:SetPos(10, 10)
        sheet:AddSheet("Tab 1", panel1)
    end)

    addRow(list, "Content Panel & Icon", 100, function(parent)
        local contentPanel = parent:Add("DPanel")
        contentPanel:Dock(LEFT)
        contentPanel:SetWide(150)
        contentPanel:SetBackgroundColor(Color(40, 40, 40, 80))
        local label = contentPanel:Add("DLabel")
        label:SetText("Content Panel")
        label:Center()
        local contentIcon = parent:Add("DPanel")
        contentIcon:Dock(LEFT)
        contentIcon:DockMargin(8, 0, 0, 0)
        contentIcon:SetWide(64)
        contentIcon:SetTall(64)
        contentIcon:SetBackgroundColor(Color(60, 60, 60, 100))
        local iconLabel = contentIcon:Add("DLabel")
        iconLabel:SetText("Icon")
        iconLabel:Center()
    end)

    addRow(list, "Selection Highlight", 60, function(parent)
        local panel = parent:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(116, 185, 255, 160)) end
        local label = panel:Add("DLabel")
        label:SetText("Selected Item")
        label:Center()
        label:SetTextColor(Color(255, 255, 255))
    end)

    addRow(list, "Shadow Panel", 80, function(parent)
        local shadow = parent:Add("DPanel")
        shadow:Dock(FILL)
        shadow:SetBackgroundColor(Color(20, 20, 20, 120))
        local label = shadow:Add("DLabel")
        label:SetText("Shadow Effect")
        label:Center()
        label:SetTextColor(Color(200, 200, 200))
    end)
end

concommand.Add("lia_skin_test", buildSkinPreview)
