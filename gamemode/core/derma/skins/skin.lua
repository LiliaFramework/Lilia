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
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    lia.derma.rect(0, 0, w, h):Rad(14):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(10, 16):Draw()
    lia.derma.rect(0, 0, w, h):Rad(14):Color(lia.color.theme.background_panelpopup):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(14):Color(ColorAlpha(Color(255, 255, 255), 18)):Outline(1):Draw()
    lia.derma.rect(0, 0, w, h):Rad(14):Color(ColorAlpha(accentColor, 65)):Outline(1):Draw()
    lia.derma.rect(10, 8, w - 20, 2):Rad(2):Color(ColorAlpha(accentColor, 120)):Draw()
end

function SKIN:PaintMenuOption(panel, w, h)
    if not panel.LaidOut then
        panel.LaidOut = true
        panel:SetTextColor(Color(220, 220, 220))
    end

    if panel.m_bBackground then
        local bgColor = getThemeBackgroundSolid()
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        local isSelected = panel:GetChecked()
        local hovered = panel.Hovered or panel.Highlight
        local base = ColorAlpha(bgColor, 185)
        if isSelected then
            base = ColorAlpha(bgColor, 220)
        elseif hovered then
            base = ColorAlpha(bgColor, 205)
        end

        lia.derma.rect(0, 0, w, h):Rad(6):Color(base):Shape(lia.derma.SHAPE_IOS):Draw()
        if isSelected then
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 55)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 220)):Outline(1):Draw()
        elseif hovered then
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 28)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(accentColor, 170)):Outline(1):Draw()
        else
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(Color(255, 255, 255), 18)):Outline(1):Draw()
        end

        if isSelected or hovered then lia.derma.rect(2, 4, 3, h - 8):Rad(2):Color(ColorAlpha(accentColor, isSelected and 220 or 160)):Draw() end
    end

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
