local MODULE = MODULE
local mathApproach = math.Approach
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
    self.deltaValue = self.value
    self.max = 10
    self.bar = self:Add("DPanel")
    self.bar:Dock(FILL)
    self.bar:DockMargin(2, 2, 2, 2)
    self.bar.Paint = function(_, w, h)
        self.t = Lerp(FrameTime() * 10, self.t, 1)
        local value = (self.value / self.max) * self.t
        local boostedValue = self.boostValue or 0
        local barWidth = w * value
        if value > 0 then
            local color = lia.config.Color
            surface.SetDrawColor(color)
            surface.DrawRect(0, 0, barWidth, h)
        end

        if boostedValue ~= 0 then
            local boostW = math.Clamp(math.abs(boostedValue / self.max), 0, 1) * w * self.t + 1
            if boostedValue < 0 then
                surface.SetDrawColor(200, 80, 80, 200)
                surface.DrawRect(barWidth - boostW, 0, boostW, h)
            else
                surface.SetDrawColor(80, 200, 80, 200)
                surface.DrawRect(barWidth, 0, boostW, h)
            end
        end
    end

    self.label = self.bar:Add("DLabel")
    self.label:Dock(FILL)
    self.label:SetExpensiveShadow(1, Color(0, 0, 60))
    self.label:SetContentAlignment(5)
end

function PANEL:Think()
    if self.pressing and ((self.nextPress or 0) < CurTime()) then self:doChange() end
    self.deltaValue = mathApproach(self.deltaValue, self.value, FrameTime() * 15)
end

function PANEL:doChange()
    if (self.value == 0 and self.pressing == -1) or (self.value == self.max and self.pressing == 1) then return end
    self.nextPress = CurTime() + 0.2
    if self:onChanged(self.pressing) ~= false then self.value = math.Clamp(self.value + self.pressing, 0, self.max) end
end

function PANEL:onChanged()
end

function PANEL:getValue()
    return self.value
end

function PANEL:setValue(value)
    self.value = value
end

function PANEL:setBoost(value)
    self.boostValue = value
end

function PANEL:setMax(max)
    self.max = max
end

function PANEL:setText(text)
    self.label:SetText(text)
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
    local client = LocalPlayer()
    self.title = self:addLabel("attributes")
    self.leftLabel = self:addLabel("points left")
    self.leftLabel:SetFont("liaCharSubTitleFont")
    self.leftLabel:SetTextColor(color_white)
    self.title:SetTextColor(color_white)
    self.total = hook.Run("GetStartAttribPoints", client, self:getContext()) or lia.config.MaxAttributes
    self.attribs = {}
    for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
        if v.noStartBonus then continue end
        self.attribs[k] = self:addAttribute(k, v)
    end
end

function PANEL:updatePointsLeft()
    self.leftLabel:SetText(L("points left"):upper() .. ": " .. self.left)
end

function PANEL:onDisplay()
    local attribs = self:getContext("attribs", {})
    local sum = 0
    for _, quantity in pairs(attribs) do
        sum = sum + quantity
    end

    self.left = math.max(self.total - sum, 0)
    self:updatePointsLeft()
    for key, row in pairs(self.attribs) do
        row.points = attribs[key] or 0
        row:updateQuantity()
    end
end

function PANEL:addAttribute(key, attribute)
    local row = self:Add("liaCharacterAttribsRow")
    row:setAttribute(key, attribute)
    row.parent = self
    return row
end

function PANEL:onPointChange(key, delta)
    if not key then return 0 end
    local attribs = self:getContext("attribs", {})
    local startingMax = lia.attribs.list[key].startingMax or nil
    local quantity = attribs[key] or 0
    local newQuantity = quantity + delta
    local newPointsLeft = self.left - delta
    if newPointsLeft < 0 or newPointsLeft > self.total or newQuantity < 0 or newQuantity > self.total or (startingMax and startingMax < newQuantity) then return quantity end
    self.left = newPointsLeft
    self:updatePointsLeft()
    attribs[key] = newQuantity
    self:setContext("attribs", attribs)
    return newQuantity
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
    self.add = self:addButton("⯈", 1)
    self.add:Dock(RIGHT)
    self.sub = self:addButton("⯇", -1)
    self.sub:Dock(LEFT)
    self.quantity = self.buttons:Add("DLabel")
    self.quantity:SetFont("liaCharSubTitleFont")
    self.quantity:SetTextColor(color_white)
    self.quantity:Dock(FILL)
    self.quantity:SetText("0")
    self.quantity:SetContentAlignment(5)
    self.name = self:Add("DLabel")
    self.name:SetFont("liaCharSubTitleFont")
    self.name:SetContentAlignment(4)
    self.name:SetTextColor(color_white)
    self.name:Dock(FILL)
    self.name:DockMargin(8, 0, 0, 0)
end

function PANEL:setAttribute(key, attribute)
    self.key = key
    local startingMax = lia.attribs.list[key].startingMax or nil
    self.name:SetText(L(attribute.name))
    self:SetTooltip(L(attribute.desc or "noDesc") .. (startingMax and " Max: " .. startingMax or ""))
end

function PANEL:delta(delta)
    local client = LocalPlayer()
    if IsValid(self.parent) then
        local oldPoints = self.points
        self.points = self.parent:onPointChange(self.key, delta)
        self:updateQuantity()
        if oldPoints ~= self.points then client:EmitSound(unpack(MODULE.CharAttrib)) end
    end
end

function PANEL:addButton(symbol, delta)
    local button = self.buttons:Add("liaCharButton")
    button:SetFont("liaCharSubTitleFont")
    button:SetWide(32)
    button:SetText(symbol)
    button:SetContentAlignment(5)
    button.OnMousePressed = function()
        self.autoDelta = delta
        self.nextAuto = CurTime() + 0.4
        self:delta(delta)
    end

    button.OnMouseReleased = function() self.autoDelta = nil end
    button:SetPaintBackground(false)
    return button
end

function PANEL:Think()
    local curTime = CurTime()
    if self.autoDelta and (self.nextAuto or 0) < curTime then
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
