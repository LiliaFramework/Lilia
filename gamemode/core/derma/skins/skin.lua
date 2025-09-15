local surface = surface
local Color = Color
local function drawAltBg(panel, w, h)
    lia.util.drawBlur(panel, 10)
    surface.SetDrawColor(45, 45, 45, 200)
    surface.DrawRect(0, 0, w, h)
end
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
    lia.util.drawBlur(panel, 10)
    surface.SetDrawColor(45, 45, 45, 200)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
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
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local w, h = panel:GetWide(), panel:GetTall()
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
    surface.DrawOutlinedRect(0, 0, w, h)
end
local function paintButtonBase(panel, w, h)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local a = 50
    if panel:GetDisabled() then
        a = 10
    elseif panel.Depressed then
        a = 180
    elseif panel.Hovered then
        a = 75
    end
    surface.SetDrawColor(20, 20, 20, a)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(100, 100, 100, a)
    surface.DrawRect(2, 2, w - 4, h - 4)
end
function SKIN:PaintWindowMinimizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(255, 255, 255, 255)
    local t = 1
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - t) * 0.5
    surface.DrawRect(x, y, iconW, t)
end
function SKIN:PaintWindowMaximizeButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(255, 255, 255, 255)
    local iconW = w * 0.4
    local x = (w - iconW) * 0.5
    local y = (h - iconW) * 0.5
    surface.DrawOutlinedRect(x, y, iconW, iconW)
end
function SKIN:PaintWindowCloseButton(panel, w, h)
    paintButtonBase(panel, w, h)
    surface.SetDrawColor(255, 255, 255, 255)
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
    paintButtonBase(panel, w, h)
end
function SKIN:PaintTextEntry(panel, w, h)
    if panel.m_bBackground then
        local a = 50
        if panel:GetDisabled() then
            a = 10
        elseif panel.Depressed then
            a = 180
        elseif panel.Hovered then
            a = 75
        end
        surface.SetDrawColor(20, 20, 20, a)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(100, 100, 100, a)
        surface.DrawRect(2, 2, w - 4, h - 4)
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
function SKIN:PaintButtonUp(_, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("marlett")
    surface.SetTextPos(1, 1)
    surface.DrawText("5")
end
function SKIN:PaintButtonDown(_, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("marlett")
    surface.SetTextPos(1, 0)
    surface.DrawText("6")
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
function SKIN:PaintTreeNodeButton(panel, w, h)
    drawAltBg(panel, w, h)
    panel:SetTextColor(self.Colours.Tree.Text)
end
function SKIN:PaintTooltip(panel, w, h)
    drawAltBg(panel, w, h)
end
function SKIN:PaintPopupMenu(panel, w, h)
    drawAltBg(panel, w, h)
end
function SKIN:PaintCollapsibleCategory(panel, w, h)
    drawAltBg(panel, w, h)
end
function SKIN:PaintCategoryList(panel, w, h)
    drawAltBg(panel, w, h)
end
function SKIN:PaintCategoryButton(panel, w, h)
    drawAltBg(panel, w, h)
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
derma.DefineSkin("Lilia Skin", L("liliaSkinDesc"), SKIN)
derma.RefreshSkins()
