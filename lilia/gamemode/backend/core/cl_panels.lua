--------------------------------------------------------------------------------------------------------------------------
lia.config.Font = lia.config.Font or "Arial"
lia.config.GenericFont = lia.config.GenericFont or "Segoe UI"
-----------------------------------------------------------------------------------------------------------------------------------------------
local DescWidth = CreateClientConVar("lia_hud_descwidth", 0.5, true, false)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local blurGoal = 0
local blurValue = 0
--------------------------------------------------------------------------------------------------------------------------
function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    vgui.Create("liaQuick")
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:SetupQuickMenu(menu)
    local current
    LIA_CVAR_LANG = CreateClientConVar("lia_language", "english", true, true)
    for k, v in SortedPairs(lia.lang.stored) do
        local name = lia.lang.names[k]
        local name2 = k:sub(1, 1):upper() .. k:sub(2)
        local enabled = LIA_CVAR_LANG:GetString():match(k)
        if name then
            name = name .. " (" .. name2 .. ")"
        else
            name = name2
        end

        local button = menu:addCheck(
            name,
            function(panel)
                panel.checked = true
                if IsValid(current) then
                    if current == panel then return end
                    current.checked = false
                end

                current = panel
                RunConsoleCommand("lia_language", k)
            end, enabled
        )

        if enabled and not IsValid(current) then
            current = button
        end
    end

    menu:addSlider(
        "HUD Desc Width Modifier",
        function(panel, value)
            DescWidth:SetFloat(value)
        end, DescWidth:GetFloat(), 0.1, 1, 2
    )

    menu:addSpacer()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ScreenResolutionChanged(oldW, oldH)
    RunConsoleCommand("fixchatplz")
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:HUDPaintBackground()
    local localPlayer = LocalPlayer()
    local frameTime = FrameTime()
    local scrW, scrH = ScrW(), ScrH()
    blurGoal = localPlayer:getLocalVar("blur", 0) + (hook.Run("AdjustBlurAmount", blurGoal) or 0)
    if blurValue ~= blurGoal then
        blurValue = math.Approach(blurValue, blurGoal, frameTime * 20)
    end

    if blurValue > 0 and not localPlayer:ShouldDrawLocalPlayer() then
        lia.util.drawBlurAt(0, 0, scrW, scrH, blurValue)
    end

    self.BaseClass.PaintWorldTips(self.BaseClass)
    lia.menu.drawAll()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then
            table.remove(lia.menu.list, k)
        end
    end

    local options = {}
    local itemTable = entity:getItemTable()
    if not itemTable then return end
    local function callback(index)
        if IsValid(entity) then
            netstream.Start("invAct", index, entity)
        end
    end

    itemTable.player = LocalPlayer()
    itemTable.entity = entity
    if input.IsShiftDown() then
        callback("take")
    end

    for k, v in SortedPairs(itemTable.functions) do
        if k == "combine" then continue end
        if (hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end
        options[L(v.name or k)] = function()
            local send = true
            if v.onClick then
                send = v.onClick(itemTable)
            end

            if v.sound then
                surface.PlaySound(v.sound)
            end

            if send ~= false then
                callback(k)
            end
        end
    end

    if table.Count(options) > 0 then
        entity.liaMenuIndex = lia.menu.add(options, entity)
    end

    itemTable.player = nil
    itemTable.entity = nil
end

--------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
    end

    lia.gui.quick = self
    self:SetSize(400, 36)
    self:SetPos(ScrW() - 36, -36)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetZPos(999)
    self:SetMouseInputEnabled(true)
    self.title = self:Add("DLabel")
    self.title:SetTall(36)
    self.title:Dock(TOP)
    self.title:SetFont("liaMediumFont")
    self.title:SetText(L"quickSettings")
    self.title:SetContentAlignment(4)
    self.title:SetTextInset(44, 0)
    self.title:SetTextColor(Color(250, 250, 250))
    self.title:SetExpensiveShadow(1, Color(0, 0, 0, 175))
    self.title.Paint = function(this, w, h)
        surface.SetDrawColor(lia.config.Color)
        surface.DrawRect(0, 0, w, h)
    end

    self.expand = self:Add("DButton")
    self.expand:SetContentAlignment(5)
    self.expand:SetText("`")
    self.expand:SetFont("liaIconsMedium")
    self.expand:SetPaintBackground(false)
    self.expand:SetTextColor(color_white)
    self.expand:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.expand:SetSize(36, 36)
    self.expand.DoClick = function(this)
        if self.expanded then
            self:SizeTo(
                self:GetWide(),
                36,
                0.15,
                nil,
                nil,
                function()
                    self:MoveTo(ScrW() - 36, 30, 0.15)
                end
            )

            self.expanded = false
        else
            self:MoveTo(
                ScrW() - 400,
                30,
                0.15,
                nil,
                nil,
                function()
                    local height = 0
                    for k, v in pairs(self.items) do
                        if IsValid(v) then
                            height = height + v:GetTall() + 1
                        end
                    end

                    height = math.min(height, ScrH() * 0.5)
                    self:SizeTo(self:GetWide(), height, 0.15)
                end
            )

            self.expanded = true
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(0, 36)
    self.scroll:SetSize(self:GetWide(), ScrH() * 0.5)
    self:MoveTo(self.x, 30, 0.05)
    self.items = {}
    hook.Run("SetupQuickMenu", self)
end

local function paintButton(button, w, h)
    local alpha = 0
    if button.Depressed or button.m_bSelected then
        alpha = 5
    elseif button.Hovered then
        alpha = 2
    end

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:addButton(text, callback)
    local button = self.scroll:Add("DButton")
    button:SetText(text)
    button:SetTall(36)
    button:Dock(TOP)
    button:DockMargin(0, 1, 0, 0)
    button:SetFont("liaMediumLightFont")
    button:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    button:SetContentAlignment(4)
    button:SetTextInset(8, 0)
    button:SetTextColor(color_white)
    button.Paint = paintButton
    if callback then
        button.DoClick = callback
    end

    self.items[#self.items + 1] = button

    return button
end

function PANEL:addSpacer()
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(1)
    panel:Dock(TOP)
    panel:DockMargin(0, 1, 0, 0)
    panel.Paint = function(this, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end

    self.items[#self.items + 1] = panel

    return panel
end

function PANEL:addSlider(text, callback, value, min, max, decimal)
    local slider = self.scroll:Add("DNumSlider")
    slider:SetText(text)
    slider:SetTall(36)
    slider:Dock(TOP)
    slider:DockMargin(0, 1, 0, 0)
    slider:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    slider:SetMin(min or 0)
    slider:SetMax(max or 100)
    slider:SetDecimals(decimal or 0)
    slider:SetValue(value or 0)
    slider.Label:SetFont("liaMediumLightFont")
    slider.Label:SetTextColor(color_white)
    local textEntry = slider:GetTextArea()
    textEntry:SetFont("liaMediumLightFont")
    textEntry:SetTextColor(color_white)
    if callback then
        slider.OnValueChanged = function(this, value)
            value = math.Round(value, decimal)
            callback(this, value)
        end
    end

    self.items[#self.items + 1] = slider

    return slider
end

local color_dark = Color(255, 255, 255, 5)
function PANEL:addCheck(text, callback, checked)
    local x, y
    local color
    local button = self:addButton(
        text,
        function(panel)
            panel.checked = not panel.checked
            if callback then
                callback(panel, panel.checked)
            end
        end
    )

    button.PaintOver = function(this, w, h)
        x, y = w - 8, h * 0.5
        if this.checked then
            color = lia.config.Color
        else
            color = color_dark
        end

        draw.SimpleText(self.icon or "F", "liaIconsSmall", x, y, color, 2, 1)
    end

    button.checked = checked

    return button
end

function PANEL:setIcon(char)
    self.icon = char
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(lia.config.Color)
    surface.DrawRect(0, 0, w, 36)
    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("liaQuick", PANEL, "EditablePanel")