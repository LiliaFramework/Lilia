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
local function drawAltBg(panel, w, h)
    lia.util.drawBlur(panel, 10)
    surface.SetDrawColor(45, 45, 45, 200)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintFrame(panel)
    if not panel.LaidOut then
        if panel.btnClose and panel.btnClose:IsValid() then
            panel.btnClose:SetPos(panel:GetWide() - 16, 4)
            panel.btnClose:SetSize(24, 24)
            panel.btnClose:SetFont("marlett")
            panel.btnClose:SetText("r")
            panel.btnClose:SetTextColor(Color(255, 255, 255))
            panel.btnClose:PerformLayout()
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

function SKIN:PaintButton(panel)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
    local w, h = panel:GetWide(), panel:GetTall()
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

function SKIN:PaintComboBox(panel, w, h)
    if not panel.m_bBackground then return end
    if panel.GetPaintBackground and not panel:GetPaintBackground() then return end
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

    -- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
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

    panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintWindowCloseButton(panel, w, h)
end

-- I don't think we gonna need minimize button and maximize button.
function SKIN:PaintWindowMinimizeButton(panel, w, h)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
end

function SKIN:PaintListView(panel, w, h)
    surface.SetDrawColor(20, 20, 20, 100)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintListViewLine(panel, w, h)
    surface.SetDrawColor((panel:IsHovered() or panel:IsLineSelected()) and lia.config.get("Color", Color(255, 255, 255)) or Color(0, 0, 0, 0))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintButtonUp(panel, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("marlett")
    surface.SetTextPos(1, 1)
    surface.DrawText("5")
end

function SKIN:PaintButtonDown(panel, w, h)
    surface.SetDrawColor(lia.config.get("Color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("marlett")
    surface.SetTextPos(1, 0)
    surface.DrawText("6")
end

function SKIN:PaintVScrollBar(panel, w, h)
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenu(panel, w, h)
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

function SKIN:PaintTreeNode(panel, _, h)
    local w = panel:GetWide()
    drawAltBg(panel, w, h)
end

function SKIN:PaintTreeNodeButton(panel, w, h)
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

derma.DefineSkin("lilia", "The alt skin for the Lilia framework.", SKIN)
SKIN = {}
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

derma.DefineSkin("lilia_alt", "The base skin for the Lilia framework.", SKIN)
derma.RefreshSkins()
local g_DermaPreviewFrame
concommand.Add("open_derma_preview", function()
    -- Remove existing preview if already open
    if IsValid(g_DermaPreviewFrame) then g_DermaPreviewFrame:Remove() end
    -- Main preview frame covering 80% of screen
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Derma Controls Preview")
    frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    frame:Center()
    frame:MakePopup()
    g_DermaPreviewFrame = frame
    -- Scrollable panel inside frame
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    -- Helper to add a labeled preview entry
    local function addPreview(name, createFunc)
        -- Label for the panel name
        local label = scroll:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(10, 10, 10, 2)
        label:SetText(name)
        label:SizeToContents()
        -- Create the panel using provided function
        local panel = createFunc()
        if IsValid(panel) then
            panel:Dock(TOP)
            panel:DockMargin(10, 2, 10, 0)
        end
    end

    -- Add previews for each Derma control
    -- DFrame (as a child example)
    addPreview("DFrame", function()
        local container = scroll:Add("DPanel")
        container:SetTall(70)
        container:SetPaintBackground(false)
        -- Create a small DFrame inside the container
        local miniFrame = vgui.Create("DFrame", container)
        miniFrame:SetTitle("DFrame")
        miniFrame:SetSize(150, 60)
        miniFrame:SetDraggable(false)
        miniFrame:ShowCloseButton(true)
        miniFrame:SetPos(0, 5) -- position within container
        return container
    end)

    -- DPanel
    addPreview("DPanel", function()
        local panel = scroll:Add("DPanel")
        panel:SetTall(50)
        -- (Default DPanel background will be shown)
        return panel
    end)

    -- DButton
    addPreview("DButton", function()
        local btn = scroll:Add("DButton")
        btn:SetText("DButton")
        return btn
    end)

    -- DLabel
    addPreview("DLabel", function()
        local lbl = scroll:Add("DLabel")
        lbl:SetText("DLabel")
        lbl:SizeToContents()
        return lbl
    end)

    -- DTextEntry
    addPreview("DTextEntry", function()
        local txt = scroll:Add("DTextEntry")
        txt:SetText("DTextEntry")
        -- Alternatively, to show placeholder: txt:SetText("") txt:SetPlaceholderText("Type here...")
        return txt
    end)

    -- DCheckBox
    addPreview("DCheckBox", function()
        local cb = scroll:Add("DCheckBox")
        cb:SetValue(false) -- unchecked state
        cb:SetChecked(true) -- example checked state (checked box)
        -- (Box will appear, no label by default)
        return cb
    end)

    -- DComboBox
    addPreview("DComboBox", function()
        local combo = scroll:Add("DComboBox")
        combo:AddChoice("Option 1")
        combo:AddChoice("Option 2")
        combo:ChooseOption("Option 1", 1)
        return combo
    end)

    -- DListView
    addPreview("DListView", function()
        local listview = scroll:Add("DListView")
        listview:SetTall(120)
        listview:AddColumn("Column 1")
        listview:AddColumn("Column 2")
        listview:AddLine("Row1Col1", "Row1Col2")
        listview:AddLine("Row2Col1", "Row2Col2")
        return listview
    end)

    -- DImage
    addPreview("DImage", function()
        local container = scroll:Add("DPanel")
        container:SetTall(40)
        container:SetPaintBackground(false)
        local img = vgui.Create("DImage", container)
        img:SetImage("icon16/star.png")
        img:SetSize(32, 32)
        img:SetPos(0, 4)
        return container
    end)

    -- DPanelList
    addPreview("DPanelList", function()
        local pnlList = scroll:Add("DPanelList")
        pnlList:SetTall(80)
        pnlList:EnableVerticalScrollbar()
        pnlList:SetPadding(5)
        for i = 1, 10 do
            local item = vgui.Create("DLabel")
            item:SetText("Item " .. i)
            item:SizeToContents()
            pnlList:AddItem(item)
        end
        return pnlList
    end)

    -- DProgress (Progress Bar)
    addPreview("DProgressBar", function()
        local progress = scroll:Add("DProgress")
        progress:SetTall(20)
        progress:SetFraction(0.5) -- 50%
        return progress
    end)

    -- DNumSlider
    addPreview("DNumSlider", function()
        local slider = scroll:Add("DNumSlider")
        slider:SetText("DNumSlider")
        slider:SetMin(0)
        slider:SetMax(100)
        slider:SetValue(50)
        slider:SetDecimals(0)
        slider:SetTall(35)
        return slider
    end)

    -- DScrollPanel
    addPreview("DScrollPanel", function()
        local subScroll = scroll:Add("DScrollPanel")
        subScroll:SetTall(100)
        for i = 1, 20 do
            local line = subScroll:Add("DLabel")
            line:SetText("Line " .. i)
            line:Dock(TOP)
            line:DockMargin(0, 0, 0, 5)
        end
        return subScroll
    end)

    -- DTree
    addPreview("DTree", function()
        local tree = scroll:Add("DTree")
        tree:SetTall(100)
        local node1 = tree:AddNode("Node 1")
        node1:AddNode("Child 1")
        node1:AddNode("Child 2")
        tree:AddNode("Node 2")
        return tree
    end)

    -- DColorMixer
    addPreview("DColorMixer", function()
        local mixer = scroll:Add("DColorMixer")
        mixer:SetTall(150)
        mixer:SetPalette(true)
        mixer:SetAlphaBar(true)
        mixer:SetWangs(true)
        -- (Default color mixer settings)
        return mixer
    end)

    -- DPropertySheet
    addPreview("DPropertySheet", function()
        local sheet = scroll:Add("DPropertySheet")
        sheet:SetTall(120)
        local tab1 = vgui.Create("DPanel")
        tab1:Dock(FILL)
        local lbl1 = vgui.Create("DLabel", tab1)
        lbl1:Dock(TOP)
        lbl1:DockMargin(0, 0, 0, 4)
        lbl1:SetText(L("settings"))
        lbl1:SizeToContents()
        local btn1 = vgui.Create("DButton", tab1)
        btn1:Dock(TOP)
        btn1:SetText(L("apply"))
        local tab2 = vgui.Create("DPanel")
        tab2:Dock(FILL)
        local entry = vgui.Create("DTextEntry", tab2)
        entry:Dock(TOP)
        entry:SetPlaceholderText(L("enterValue"))
        local chk = vgui.Create("DCheckBoxLabel", tab2)
        chk:Dock(TOP)
        chk:DockMargin(0, 4, 0, 0)
        chk:SetText("Enable feature")
        sheet:AddSheet("Tab 1", tab1, "icon16/wrench.png")
        sheet:AddSheet("Tab 2", tab2, "icon16/cog.png")
        return sheet
    end)

    -- DCategoryList
    addPreview("DCategoryList", function()
        local catList = scroll:Add("DCategoryList")
        catList:SetTall(100)
        local category = catList:Add("Category 1")
        category:Add("Item 1")
        category:Add("Item 2")
        -- Expand the category for preview
        category:SetExpanded(true)
        return catList
    end)

    -- DCollapsibleCategory
    addPreview("DCollapsibleCategory", function()
        local cat = scroll:Add("DCollapsibleCategory")
        local content = vgui.Create("DPanel")
        content:SetTall(40)
        cat:SetLabel("DCollapsibleCategory")
        cat:SetContents(content)
        cat:SetExpanded(true)
        -- Adjust height to show content
        if cat.GetHeaderHeight then
            cat:SetTall(cat:GetHeaderHeight() + content:GetTall())
        else
            cat:SetTall(60)
        end
        return cat
    end)

    -- DModelPanel
    addPreview("DModelPanel", function()
        local container = scroll:Add("DPanel")
        container:SetTall(300)
        container:SetPaintBackground(false)
        local modelPanel = vgui.Create("DModelPanel", container)
        modelPanel:SetModel("models/props_c17/oildrum001.mdl")
        modelPanel:SetSize(300, 300)
        modelPanel:SetPos(0, 0)
        return container
    end)
end)