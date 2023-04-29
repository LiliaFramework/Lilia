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

        if str:StartWith("#") then
            str = str:sub(2)
        end

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

function SKIN:PaintWindowMinimizeButton(panel, w, h)
end

function SKIN:PaintWindowMaximizeButton(panel, w, h)
end

function SKIN:PaintListView(panel, w, h)
    surface.SetDrawColor(20, 20, 20, 100)
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintListViewLine(panel, w, h)
    surface.SetDrawColor((panel:IsHovered() or panel:IsLineSelected()) and lia.config.get("color", Color(255, 255, 255)) or Color(0, 0, 0, 0))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    surface.SetDrawColor(lia.config.get("color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintButtonUp(panel, w, h)
    surface.SetDrawColor(lia.config.get("color", Color(255, 255, 255)))
    surface.DrawRect(0, 0, w, h)
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetFont("marlett")
    surface.SetTextPos(1, 1)
    surface.DrawText("5")
end

function SKIN:PaintButtonDown(panel, w, h)
    surface.SetDrawColor(lia.config.get("color", Color(255, 255, 255)))
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

    if panel:GetChecked() then
        skin.tex.Menu_Check(5, h / 2 - 7, 15, 15)
    end
end

derma.DefineSkin("lilia_darktheme", "The base skin for the Lilia framework.", SKIN)
derma.RefreshSkins()