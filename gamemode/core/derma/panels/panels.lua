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
    self:SetSkin(lia.config.get("DermaSkin", L("liliaSkin")))
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
    self.expand:SetText("")
    self.expand:SetFont("DermaDefaultBold")
    self.expand:SetPaintBackground(false)
    self.expand:SetTextColor(color_white)
    self.expand:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.expand:SetSize(36, 36)
    self.expand:SetPos(0, 0)
    self.expand.icon = self.expand:Add("DImage")
    self.expand.icon:SetImage("settings.png")
    self.expand.icon:SetSize(24, 24)
    self.expand.icon:Dock(FILL)
    self.expand.icon:DockMargin(6, 6, 6, 6)
    self.expand.DoClick = function()
        if self.expanded then
            self:SizeTo(self:GetWide(), 36, 0.15, nil, nil, function() self:MoveTo(ScrW() - 36, 30, 0.15) end)
            self.expanded = false
        else
            self:MoveTo(ScrW() - 400, 30, 0.15, nil, nil, function()
                local h = 0
                for _, v in pairs(self.items) do
                    if IsValid(v) then h = h + v:GetTall() + 1 end
                end

                h = math.min(h, ScrH() * 0.5)
                local target = 36 + math.max(h, 0)
                self:SizeTo(self:GetWide(), target, 0.15)
            end)

            self.expanded = true
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.items = {}
    hook.Run("SetupQuickMenu", self)
    self:populateOptions()
    self:MoveTo(self.x, 30, 0.05)
end

function QuickPanel:PerformLayout(w, h)
    self.scroll:SetPos(0, 36)
    self.scroll:SetSize(w, math.max(h - 36, 0))
end

local function paintButton(button, w, h)
    local r, g, b = lia.config.get("Color"):Unpack()
    local a = button.Depressed or button.m_bSelected and 255 or button.Hovered and 200 or 100
    surface.SetDrawColor(r, g, b, a)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-r"))
    surface.DrawTexturedRect(0, 0, w / 2, h)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
    surface.DrawTexturedRect(w / 2, 0, w / 2, h)
end

local categoryDoClick = function(this)
    this.expanded = not this.expanded
    local items = lia.gui.quick.items
    local i0 = table.KeyFromValue(items, this)
    for i = i0 + 1, #items do
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

function QuickPanel:addButton(text, cb)
    local btn = self.scroll:Add("DButton")
    btn:SetText(text)
    btn:SetTall(36)
    btn:Dock(TOP)
    btn:DockMargin(0, 1, 0, 0)
    btn:SetFont("liaMediumLightFont")
    btn:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    btn:SetContentAlignment(4)
    btn:SetTextInset(8, 0)
    btn:SetTextColor(color_white)
    btn.Paint = paintButton
    if cb then btn.DoClick = cb end
    self.items[#self.items + 1] = btn
    return btn
end

function QuickPanel:addSpacer()
    local pnl = self.scroll:Add("DPanel")
    pnl:SetTall(1)
    pnl:Dock(TOP)
    pnl:DockMargin(0, 1, 0, 0)
    pnl.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end

    self.items[#self.items + 1] = pnl
    return pnl
end

function QuickPanel:addSlider(text, cb, val, min, max, dec)
    local s = self.scroll:Add("DNumSlider")
    s:SetText(text)
    s:SetTall(36)
    s:Dock(TOP)
    s:DockMargin(0, 1, 0, 0)
    s:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    s:SetMin(min or 0)
    s:SetMax(max or 100)
    s:SetDecimals(dec or 0)
    s:SetValue(val or 0)
    s.Label:SetFont("liaMediumLightFont")
    s.Label:SetTextColor(color_white)
    s.Label:DockMargin(8, 0, 0, 0)
    local te = s:GetTextArea()
    te:SetFont("liaMediumLightFont")
    te:SetTextColor(color_white)
    if cb then
        s.OnValueChanged = function(this, newVal)
            local r = math.Round(newVal, dec or 0)
            cb(this, r)
        end
    end

    self.items[#self.items + 1] = s
    s.Paint = paintButton
    return s
end

function QuickPanel:addCheck(text, cb, checked)
    local btn = self:addButton(text)
    local chk = btn:Add("liaCheckBox")
    chk:SetChecked(checked)
    chk:SetSize(22, 22)
    chk.OnChange = function(_, v) if cb then cb(btn, v) end end
    btn.DoClick = function() chk:SetChecked(not chk:GetChecked()) end
    btn.PerformLayout = function(_, w, h) chk:SetPos(w - chk:GetWide() - 8, math.floor((h - chk:GetTall()) * 0.5)) end
    return btn
end

function QuickPanel:setIcon(ch)
    self.icon = ch
end

function QuickPanel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(lia.config.get("Color"))
    surface.DrawRect(0, 0, w, 36)
end

function QuickPanel:populateOptions()
    local cats = {}
    for k, v in pairs(lia.option.stored) do
        if v and (v.isQuick or v.data and v.data.isQuick) then
            local cat = v.data and v.data.category or L("categoryGeneral")
            cats[cat] = cats[cat] or {}
            cats[cat][#cats[cat] + 1] = {
                key = k,
                opt = v
            }
        end
    end

    if table.IsEmpty(cats) then
        self:Remove()
        return
    end

    local names = {}
    for n in pairs(cats) do
        names[#names + 1] = n
    end

    table.sort(names, function(a, b)
        if a == L("categoryGeneral") and b ~= L("categoryGeneral") then return true end
        if b == L("categoryGeneral") and a ~= L("categoryGeneral") then return false end
        return a < b
    end)

    for i, cat in ipairs(names) do
        self:addCategory(cat)
        local list = cats[cat]
        table.sort(list, function(a, b) return (a.opt.name or a.key) < (b.opt.name or b.key) end)
        for _, info in ipairs(list) do
            local key = info.key
            local opt = info.opt
            local data = opt.data or {}
            local val = lia.option.get(key, opt.default)
            if opt.type == "Boolean" then
                self:addCheck(opt.name or key, function(_, state) lia.option.set(key, state) end, val)
            elseif opt.type == "Int" or opt.type == "Float" then
                self:addSlider(opt.name or key, function(_, v) lia.option.set(key, v) end, val, data.min or 0, data.max or 100, opt.type == "Float" and (data.decimals or 2) or 0)
            end
        end

        if i < #names then self:addSpacer() end
    end
end

vgui.Register("liaQuick", QuickPanel, "EditablePanel")