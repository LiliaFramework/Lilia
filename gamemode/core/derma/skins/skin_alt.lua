local surface = surface
local Color = Color
local SKIN = {}
SKIN.fontFrame = "BudgetLabel"
SKIN.fontTab = "liaSmallFont"
SKIN.fontButton = "liaSmallFont"
SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Window.TitleActive = Color(255, 255, 255)
SKIN.Colours.Window.TitleInactive = Color(255, 255, 255)
SKIN.Colours.Label.Dark = Color(200, 200, 200)
SKIN.Colours.Button.Normal = Color(200, 200, 200)
SKIN.Colours.Button.Hover = Color(255, 255, 255)
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)
SKIN.Colours.Tree = table.Copy(derma.SkinList.Default.Colours.Tree)
SKIN.Colours.Tree.Text = Color(255, 255, 255)
SKIN.Colours.Tree.SelectedText = Color(255, 255, 255)
function SKIN:PaintFrame(panel, w, h)
    if not panel.LaidOut then
        if panel.btnClose and panel.btnClose:IsValid() then
            panel.btnClose:SetPos(panel:GetWide() - 16, 4)
            panel.btnClose:SetScaledSize(24, 24)
            panel.btnClose:SetFont("marlett")
            panel.btnClose:SetText("r")
            panel.btnClose:SetTextColor(Color(255, 255, 255))
            panel.btnClose:PerformLayout()
        end

        panel.LaidOut = true
    end

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

function SKIN:PaintTooltip(_, w, h)
    surface.SetDrawColor(45, 45, 45, 240)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawOutlinedRect(0, 0, w, h)
    surface.SetDrawColor(100, 100, 100, 25)
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function SKIN:DrawGenericBackground(x, y, w, h)
    surface.SetDrawColor(45, 45, 45, 240)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawOutlinedRect(x, y, w, h)
    surface.SetDrawColor(100, 100, 100, 25)
    surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
end

function SKIN:PaintPanel(panel)
    if not panel.m_bBackground or panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local w, h = panel:GetWide(), panel:GetTall()
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

local function DrawButton(panel, w, h)
    if not panel.m_bBackground or panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local alpha = 50
    if panel:GetDisabled() then
        alpha = 10
    elseif panel.Depressed then
        alpha = 180
    elseif panel.Hovered then
        alpha = 75
    end

    surface.SetDrawColor(20, 20, 20, alpha)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(100, 100, 100, alpha)
    surface.DrawRect(2, 2, w - 4, h - 4)
end

function SKIN:PaintButton(panel)
    local w, h = panel:GetWide(), panel:GetTall()
    DrawButton(panel, w, h)
end

function SKIN:PaintWindowCloseButton(panel, w, h)
    local base = derma.GetDefaultSkin()
    base.PaintWindowCloseButton(base, panel, w, h)
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
    local base = derma.GetDefaultSkin()
    base.PaintWindowMinimizeButton(base, panel, w, h)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
    local base = derma.GetDefaultSkin()
    base.PaintWindowMaximizeButton(base, panel, w, h)
end

function SKIN:PaintWindowCloseButton()
end

function SKIN:PaintWindowMinimizeButton()
end

function SKIN:PaintWindowMaximizeButton()
end

function SKIN:PaintComboBox(panel, w, h)
    DrawButton(panel, w, h)
end

function SKIN:PaintTextEntry(panel, w, h)
    if panel.m_bBackground then
        local alpha = 50
        if panel:GetDisabled() then
            alpha = 10
        elseif panel.Depressed then
            alpha = 180
        elseif panel.Hovered then
            alpha = 75
        end

        surface.SetDrawColor(20, 20, 20, alpha)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(100, 100, 100, alpha)
        surface.DrawRect(2, 2, w - 4, h - 4)
    end

    if panel.GetPlaceholderText and panel.GetPlaceholderColor and panel:GetPlaceholderText() and panel:GetPlaceholderText():Trim() ~= "" and panel:GetPlaceholderColor() and (not panel:GetText() or panel:GetText() == "") then
        local oldText = panel:GetText()
        local str = panel:GetPlaceholderText()
        if str:StartWith("#") then str = str:sub(2) end
        str = language.GetPhrase(str)
        panel:SetText(str)
        panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor())
        panel:SetText(oldText)
        return
    end

    panel:DrawTextEntryText(Color(255, 255, 255), panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintListView(_, w, h)
    surface.SetDrawColor(20, 20, 20, 100)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintListViewLine(panel, w, h)
    surface.SetDrawColor((panel:IsHovered() or panel:IsLineSelected()) and lia.config.get("Color", Color(255, 255, 255)) or Color(0, 0, 0, 0))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintScrollBarGrip(_, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintVScrollBar(_, w, h)
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenu(_, w, h)
    local odd = true
    for i = 0, h, 22 do
        if odd then
            surface.SetDrawColor(40, 40, 40, 255)
            surface.DrawRect(0, i, w, 22)
        else
            surface.SetDrawColor(50, 50, 50, 255)
            surface.DrawRect(0, i, w, 22)
        end

        odd = not odd
    end
end

function SKIN:PaintPopupMenu(panel, w, h)
    local bg = panel:IsHovered() and Color(70, 70, 70, 240) or Color(45, 45, 45, 240)
    surface.SetDrawColor(bg)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:PaintMenuOption(panel, w, h)
    if not panel.LaidOut then
        panel.LaidOut = true
        panel:SetTextColor(Color(200, 200, 200, 255))
    end

    if panel.m_bBackground and (panel.Hovered or panel.Highlight) then
        surface.SetDrawColor(70, 70, 70, 255)
        surface.DrawRect(0, 0, w, h)
    end

    local skin = derma.GetDefaultSkin()
    skin.MenuOptionOdd = not skin.MenuOptionOdd
    if panel:GetChecked() then skin.tex.Menu_Check(5, h / 2 - 7, 15, 15) end
end

local function DrawSpawnBG(w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

function SKIN:PaintCollapsibleCategory(p, w, h)
    DrawSpawnBG(w, h)
    if not p.HeaderPainted then
        p.Header.Paint = function(_, hw, hh)
            surface.SetDrawColor(20, 20, 20, p:GetExpanded() and 180 or 120)
            surface.DrawRect(0, 0, hw, hh)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, hw, hh, 2)
        end

        p.HeaderPainted = true
    end
end

function SKIN:PaintCategoryList(_, w, h)
    DrawSpawnBG(w, h)
end

function SKIN:PaintCategoryButton(p, w, h)
    local a = p:GetDisabled() and 10 or p.Depressed and 180 or p.Hovered and 75 or 50
    surface.SetDrawColor(20, 20, 20, a)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(100, 100, 100, a)
    surface.DrawRect(2, 2, w - 4, h - 4)
end

function SKIN:PaintContentPanel(_, w, h)
    DrawSpawnBG(w, h)
end

function SKIN:PaintContentIcon(p, w, h)
    if p:IsHovered() then
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(0, 0, w, h)
    end

    DrawSpawnBG(w, h)
end

function SKIN:PaintSpawnIcon(p, w, h)
    if p:IsHovered() then
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(0, 0, w, h)
    end

    DrawSpawnBG(w, h)
end

local function DrawTreeBG(w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

function SKIN:PaintTree(_, w, h)
    DrawTreeBG(w, h)
end

function SKIN:PaintTreeNode(p, _, h)
    if not p.m_bDrawLines then return end
    surface.SetDrawColor(self.Colours.Tree and self.Colours.Tree.Lines or Color(100, 100, 100))
    if p.m_bLastChild then
        surface.DrawRect(9, 0, 1, 7)
        surface.DrawRect(9, 7, 9, 1)
    else
        surface.DrawRect(9, 0, 1, h)
        surface.DrawRect(9, 7, 9, 1)
    end
end

function SKIN:PaintTreeNodeButton(p, w, h)
    w = w + 6
    if p.m_bSelected then
        surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
        surface.DrawRect(38, 0, w + 6, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawOutlinedRect(38, 0, w + 6, h)
    elseif p.Hovered then
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(38, 0, w + 6, h)
    end

    p:SetTextColor(self.Colours.Tree.Text)
end

local function basePaint(w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

function SKIN:PaintShadow(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintMenuSpacer(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintPropertySheet(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintTab(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintActiveTab(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintButtonLeft(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintButtonRight(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintListBox(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintNumberUp(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintNumberDown(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintSelection(_, w, h)
    basePaint(w, h)
end

function SKIN:PaintMenuBar(_, w, h)
    basePaint(w, h)
end

derma.DefineSkin("Lilia Alt Skin", L("liliaAltSkinDesc"), SKIN)
derma.RefreshSkins()