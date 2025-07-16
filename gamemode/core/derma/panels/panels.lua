local cacheKeys, cache, len = {}, {}, 0
local function PaintPanel(_, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

local function PaintFrame(pnl, w, h)
    if not pnl.LaidOut then
        local btn = pnl.btnClose
        if btn and btn:IsValid() then
            btn:SetPos(w - 16, 4)
            btn:SetSize(24, 24)
            btn:SetFont("marlett")
            btn:SetText("r")
            btn:SetTextColor(Color(255, 255, 255))
            btn:PerformLayout()
        end

        pnl.LaidOut = true
    end

    lia.util.drawBlur(pnl, 10)
    surface.SetDrawColor(45, 45, 45, 200)
    surface.DrawRect(0, 0, w, h)
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

vgui.Register("BlurredDFrame", BlurredDFrame, "DFrame")
local TransparentDFrame = {}
function TransparentDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
end

function TransparentDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function TransparentDFrame:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("SemiTransparentDFrame", TransparentDFrame, "DFrame")
local SimplePanel = {}
function SimplePanel:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("SemiTransparentDPanel", SimplePanel, "DPanel")
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

local QuickPanel = {}
function QuickPanel:Init()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
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
    self.title:SetTextColor(color_white)
    self.title:SetExpensiveShadow(1, Color(0, 0, 0, 175))
    self.title.Paint = function(_, w, h)
        surface.SetDrawColor(lia.config.get("Color"))
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
    self.expand.DoClick = function()
        if self.expanded then
            self:SizeTo(self:GetWide(), 36, 0.15, nil, nil, function() self:MoveTo(ScrW() - 36, 30, 0.15) end)
            self.expanded = false
        else
            self:MoveTo(ScrW() - 400, 30, 0.15, nil, nil, function()
                local height = 0
                for _, v in pairs(self.items) do
                    if IsValid(v) then height = height + v:GetTall() + 1 end
                end

                height = math.min(height, ScrH() * 0.5)
                self:SizeTo(self:GetWide(), height, 0.15)
            end)

            self.expanded = true
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(0, 36)
    self.scroll:SetSize(self:GetWide(), ScrH() * 0.5)
    self:MoveTo(self.x, 30, 0.05)
    self.items = {}
    hook.Run("SetupQuickMenu", self)
    self:populateOptions()
end

local function paintButton(button, w, h)
    local r, g, b = lia.config.get("Color"):Unpack()
    local alpha = 100
    if button.Depressed or button.m_bSelected then
        alpha = 255
    elseif button.Hovered then
        alpha = 200
    end

    surface.SetDrawColor(r, g, b, alpha)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-r"))
    surface.DrawTexturedRect(0, 0, w / 2, h)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
    surface.DrawTexturedRect(w / 2, 0, w / 2, h)
end

local categoryDoClick = function(this)
    this.expanded = not this.expanded
    local items = lia.gui.quick.items
    local index = table.KeyFromValue(items, this)
    for i = index + 1, #items do
        if items[i].categoryLabel then break end
        if not items[i].h then items[i].w, items[i].h = items[i]:GetSize() end
        items[i]:SizeTo(items[i].w, this.expanded and (items[i].h or 36) or 0, 0.15)
    end
end

function QuickPanel:addCategory(text)
    local label = self:addButton(text, categoryDoClick)
    label.categoryLabel = true
    label.expanded = true
    label:SetText(text)
    label:SetTall(36)
    label:Dock(TOP)
    label:DockMargin(0, 1, 0, 0)
    label:SetFont("liaMediumFont")
    label:SetTextColor(color_white)
    label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    label:SetContentAlignment(5)
    label.Paint = function() end
end

function QuickPanel:addButton(text, callback)
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
    if callback then button.DoClick = callback end
    self.items[#self.items + 1] = button
    return button
end

function QuickPanel:addSpacer()
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(1)
    panel:Dock(TOP)
    panel:DockMargin(0, 1, 0, 0)
    panel.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end

    self.items[#self.items + 1] = panel
    return panel
end

function QuickPanel:addSlider(text, callback, value, min, max, decimal)
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
        slider.OnValueChanged = function(this, newValue)
            local roundedValue = math.Round(newValue, decimal or 0)
            callback(this, roundedValue)
        end
    end

    self.items[#self.items + 1] = slider
    slider.Paint = paintButton
    return slider
end

local color_dark = Color(255, 255, 255, 5)
function QuickPanel:addCheck(text, callback, checked)
    local x, y
    local color
    local button = self:addButton(text, function(panel)
        panel.checked = not panel.checked
        if callback then callback(panel, panel.checked) end
    end)

    button.PaintOver = function(this, w, h)
        x, y = w - 8, h * 0.5
        if this.checked then
            color = lia.config.get("Color")
        else
            color = color_dark
        end

        draw.SimpleText(self.icon or "F", "liaIconsSmall", x, y, color, 2, 1)
    end

    button.checked = checked
    return button
end

function QuickPanel:setIcon(char)
    self.icon = char
end

function QuickPanel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(lia.config.get("Color"))
    surface.DrawRect(0, 0, w, 36)
end

function QuickPanel:populateOptions()
    local opts = {}
    for k, v in pairs(lia.option.stored) do
        if v.isQuick then
            opts[#opts + 1] = {key = k, opt = v}
        end
    end

    table.sort(opts, function(a, b)
        return (a.opt.name or a.key) < (b.opt.name or b.key)
    end)

    for _, info in ipairs(opts) do
        local key = info.key
        local opt = info.opt
        local data = opt.data or {}
        local value = lia.option.get(key, opt.default)
        if opt.type == "Boolean" then
            self:addCheck(opt.name, function(_, state)
                lia.option.set(key, state)
            end, value)
        elseif opt.type == "Int" or opt.type == "Float" then
            self:addSlider(
                opt.name,
                function(_, val)
                    lia.option.set(key, val)
                end,
                value,
                data.min or 0,
                data.max or 100,
                opt.type == "Float" and (data.decimals or 2) or 0
            )
        end
    end
end

vgui.Register("liaQuick", QuickPanel, "EditablePanel")