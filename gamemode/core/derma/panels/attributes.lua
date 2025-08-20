local PANEL = {}
function PANEL:Init()
    self:SetTall(20)
    self.add = self:Add("DImageButton")
    self.add:SetSize(16, 16)
    self.add:Dock(RIGHT)
    self.add:DockMargin(2, 2, 2, 2)
    self.add:SetImage("icon16/add.png")
    self.add.OnMousePressed = function()
        self.pressing = 1
        self:doChange()
        self.add:SetAlpha(150)
    end

    self.add.OnMouseReleased = function()
        if self.pressing then
            self.pressing = nil
            self.add:SetAlpha(255)
        end
    end

    self.add.OnCursorExited = self.add.OnMouseReleased
    self.sub = self:Add("DImageButton")
    self.sub:SetSize(16, 16)
    self.sub:Dock(LEFT)
    self.sub:DockMargin(2, 2, 2, 2)
    self.sub:SetImage("icon16/delete.png")
    self.sub.OnMousePressed = function()
        self.pressing = -1
        self:doChange()
        self.sub:SetAlpha(150)
    end

    self.sub.OnMouseReleased = function()
        if self.pressing then
            self.pressing = nil
            self.sub:SetAlpha(255)
        end
    end

    self.sub.OnCursorExited = self.sub.OnMouseReleased
    self.t = 0
    self.value = 0
    self.deltaValue = 0
    self.max = 10
    self.bar = self:Add("DPanel")
    self.bar:Dock(FILL)
    self.bar:DockMargin(2, 2, 2, 2)
    self.bar.Paint = function(_, w, h)
        self.t = Lerp(FrameTime() * 10, self.t, 1)
        local v = self.value / self.max * self.t
        if v > 0 then
            local c = lia.config.get("Color")
            surface.SetDrawColor(c)
            surface.DrawRect(0, 0, w * v, h)
        end

        local b = self.boostValue or 0
        if b ~= 0 then
            local bw = math.Clamp(math.abs(b / self.max), 0, 1) * w * self.t + 1
            if b < 0 then
                surface.SetDrawColor(200, 80, 80, 200)
                surface.DrawRect(w * v - bw, 0, bw, h)
            else
                surface.SetDrawColor(80, 200, 80, 200)
                surface.DrawRect(w * v, 0, bw, h)
            end
        end
    end

    self.label = self.bar:Add("DLabel")
    self.label:Dock(FILL)
    self.label:SetExpensiveShadow(1, Color(0, 0, 60))
    self.label:SetContentAlignment(5)
end

function PANEL:Think()
    if self.pressing and (self.nextPress or 0) < CurTime() then self:doChange() end
    self.deltaValue = math.Approach(self.deltaValue, self.value, FrameTime() * 15)
end

function PANEL:doChange()
    if self.value == 0 and self.pressing == -1 or self.value == self.max and self.pressing == 1 then return end
    self.nextPress = CurTime() + 0.2
    if self:onChanged() ~= false then self.value = math.Clamp(self.value + self.pressing, 0, self.max) end
end

function PANEL:onChanged()
end

function PANEL:getValue()
    return self.value
end

function PANEL:setValue(v)
    self.value = v
end

function PANEL:setBoost(v)
    self.boostValue = v
end

function PANEL:setMax(m)
    self.max = m
end

function PANEL:SetText(t)
    self.label:SetText(t)
    self.label:SetTextColor(color_white)
end

function PANEL:setReadOnly()
    self.sub:Remove()
    self.add:Remove()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("liaAttribBar", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    self.title = self:addLabel(L("attributes"))
    self.title:SetTextColor(color_white)
    self.leftLabel = self:addLabel(L("pointsLeft"))
    self.leftLabel:SetFont("liaCharSubTitleFont")
    self.leftLabel:SetTextColor(color_white)
    self.total = hook.Run("GetMaxStartingAttributePoints", LocalPlayer(), self:getContext()) or lia.config.get("MaxAttributePoints")
    self.attribs = {}
    for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
        if not v.noStartBonus then self.attribs[k] = self:addAttribute(k, v) end
    end
end

function PANEL:updatePointsLeft()
    self.leftLabel:SetText(L("pointsLeft"):upper() .. ": " .. self.left)
end

function PANEL:onDisplay()
    local t = self:getContext("attribs", {})
    local sum = 0
    for _, q in pairs(t) do
        sum = sum + q
    end

    self.left = math.max(self.total - sum, 0)
    self:updatePointsLeft()
    for k, row in pairs(self.attribs) do
        row.points = t[k] or 0
        row:updateQuantity()
    end
end

function PANEL:addAttribute(k, v)
    local row = self:Add("liaCharacterAttribsRow")
    row:setAttribute(k, v)
    row.parent = self
    return row
end

function PANEL:onPointChange(k, d)
    if not k then return 0 end
    local client = LocalPlayer()
    local t = self:getContext("attribs", {})
    local qty = t[k] or 0
    local nm = hook.Run("GetAttributeStartingMax", client, k)
    local nq = qty + d
    local nl = self.left - d
    if nl < 0 or nl > self.total or nq < 0 or nq > self.total or nm and nq > nm then return qty end
    self.left = nl
    self:updatePointsLeft()
    t[k] = nq
    self:setContext("attribs", t)
    return nq
end

vgui.Register("liaCharacterAttribs", PANEL, "liaCharacterCreateStep")
PANEL = {}
function PANEL:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, 4)
    self:SetTall(36)
    self:SetPaintBackground(false)
    self.buttons = self:Add("DPanel")
    self.buttons:Dock(RIGHT)
    self.buttons:SetWide(128)
    self.buttons:SetPaintBackground(false)
    self.sub = self:addButton("⯇", -1):Dock(LEFT)
    self.add = self:addButton("⯈", 1):Dock(RIGHT)
    self.quantity = self.buttons:Add("DLabel")
    self.quantity:SetFont("liaCharSubTitleFont")
    self.quantity:SetTextColor(color_white)
    self.quantity:Dock(FILL)
    self.quantity:SetContentAlignment(5)
    self.name = self:Add("DLabel")
    self.name:SetFont("liaCharSubTitleFont")
    self.name:SetTextColor(color_white)
    self.name:SetContentAlignment(4)
    self.name:Dock(FILL)
    self.name:DockMargin(8, 0, 0, 0)
end

function PANEL:setAttribute(k, v)
    self.key = k
    local nm = hook.Run("GetAttributeStartingMax", LocalPlayer(), k)
    self.name:SetText(L(v.name))
    self:SetTooltip(L(v.desc or "noDesc") .. (nm and " " .. L("max", nm) or ""))
end

function PANEL:delta(d)
    if IsValid(self.parent) then
        local old = self.points
        self.points = self.parent:onPointChange(self.key, d)
        self:updateQuantity()
        if old ~= self.points then LocalPlayer():EmitSound("buttons/button16.wav", 30, 255) end
    end
end

function PANEL:addButton(sym, d)
    local b = self.buttons:Add("liaMediumButton")
    b:SetFont("liaCharSubTitleFont")
    b:SetWide(32)
    b:SetText(sym)
    b:SetContentAlignment(5)
    b:SetPaintBackground(false)
    b.OnMousePressed = function()
        self.autoDelta = d
        self.nextAuto = CurTime() + 0.4
        self:delta(d)
    end

    b.OnMouseReleased = function() self.autoDelta = nil end
    return b
end

function PANEL:Think()
    if self.autoDelta and (self.nextAuto or 0) < CurTime() then
        self.nextAuto = CurTime() + 0.4
        self:delta(self.autoDelta)
    end
end

function PANEL:updateQuantity()
    self.quantity:SetText(self.points)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("liaCharacterAttribsRow", PANEL, "DPanel")
