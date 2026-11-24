lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.values = lia.bar.values or {}
lia.bar.list = {}
lia.bar.counter = lia.bar.counter or 0
local gradientUp = Material("vgui/gradient-u")
local gradientDown = Material("vgui/gradient-d")
local healthColor = Color(176, 48, 42)
local armorColor = Color(52, 92, 168)
local staminaColor = Color(196, 176, 72)
local fallbackColor = Color(200, 200, 200)
local textColor = Color(240, 240, 240)
local shadowColor = Color(20, 20, 20)
local function uiScale(px)
    return math.max(1, math.Round(px * math.Clamp(math.min(ScrW() / 1920, ScrH() / 1080), 0.75, 2)))
end

local function getSimfphysBase(client)
    if not IsValid(client) then return end
    local seat = client:GetVehicle()
    if not IsValid(seat) then return end
    if IsValid(seat.vehiclebase) then return seat.vehiclebase end
    local parent = seat:GetParent()
    if IsValid(parent) and (parent.IsSimfphyscar or parent:GetClass() == "gmod_sent_vehicle_fphysics_base") then return parent end
    if seat.IsSimfphyscar or seat:GetClass() == "gmod_sent_vehicle_fphysics_base" then return seat end
    if simfphys and isfunction(simfphys.IsCar) then
        if simfphys.IsCar(seat) then return seat end
        if IsValid(parent) and simfphys.IsCar(parent) then return parent end
    end
end

local function simfphysHudClearance(client)
    if not getSimfphysBase(client) or lia.config.get("DisableSimfphysHUD", false) then return 0 end
    local hud = GetConVar("cl_simfphys_hud")
    if hud and not hud:GetBool() then return 0 end
    local offset = GetConVar("cl_simfphys_hudoffset_y")
    return uiScale(190) + (offset and math.max(0, offset:GetInt()) or 0)
end

local function paintBar(x, y, w, h, fraction, color, material)
    fraction = math.Clamp(fraction or 0, 0, 1)
    color = color or fallbackColor
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(255, 255, 255, 12)
    surface.DrawOutlinedRect(x, y, w, h)
    local padding = math.min(2, math.floor((h - 1) * 0.5))
    local fillWidth = math.floor(math.max(0, w - padding * 2) * fraction)
    local fillHeight = math.max(0, h - padding * 2)
    if fillWidth <= 0 or fillHeight <= 0 then return end
    surface.SetDrawColor(color.r, color.g, color.b, 230)
    surface.DrawRect(x + padding, y + padding, fillWidth, fillHeight)
    surface.SetDrawColor(255, 255, 255, 18)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x + padding, y + padding, fillWidth, fillHeight)
end

local function getBarColor(bar)
    if bar.identifier == "health" then return healthColor end
    if bar.identifier == "armor" then return armorColor end
    if bar.identifier == "stamina" or bar.identifier == "stm" then return staminaColor end
    return bar.color or fallbackColor
end

local function isMenuOpen()
    return IsValid(lia.gui.menu) or IsValid(lia.gui.character) or IsValid(lia.gui.schemaCharacterCreator)
end

local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

function lia.bar.add(getValue, color, priority, identifier)
    if identifier then
        local existingIdx = findIndexByIdentifier(identifier)
        if existingIdx then table.remove(lia.bar.list, existingIdx) end
    end

    priority = priority or #lia.bar.list + 1
    lia.bar.counter = lia.bar.counter + 1
    table.insert(lia.bar.list, {
        getValue = getValue,
        color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
        priority = priority,
        lifeTime = 0,
        identifier = identifier,
        order = lia.bar.counter
    })
    return priority
end

function lia.bar.remove(identifier)
    local idx = findIndexByIdentifier(identifier)
    if idx then table.remove(lia.bar.list, idx) end
end

function lia.bar.drawBar(x, y, w, h, pos, maximum, color)
    maximum = tonumber(maximum) or 1
    paintBar(x, y, w, h, maximum > 0 and (tonumber(pos) or 0) / maximum or 0, color, gradientUp)
end

function lia.bar.drawAction(text, duration)
    if IsValid(lia.gui.actionPanel) then lia.gui.actionPanel:Remove() end
    duration = tonumber(duration) or 0
    if duration <= 0 then return end
    local startTime = CurTime()
    local endTime = startTime + duration
    lia.gui.actionPanel = vgui.Create("liaProgressBar")
    lia.gui.actionPanel:SetSize(math.floor(ScrW() * 0.28), uiScale(50))
    lia.gui.actionPanel:SetPos(math.floor((ScrW() - lia.gui.actionPanel:GetWide()) * 0.5), math.floor(ScrH() * 0.72 - lia.gui.actionPanel:GetTall() * 0.5))
    lia.gui.actionPanel:SetAsActionBar(true)
    lia.gui.actionPanel:SetText(tostring(text or ""))
    lia.gui.actionPanel:SetBarColor(lia.config.get("Color") or fallbackColor)
    lia.gui.actionPanel:SetProgress(startTime, endTime)
    lia.gui.actionPanel:SetFraction(1)
    lia.gui.actionPanel.Paint = function(self, w, h)
        local barHeight = uiScale(22)
        paintBar(0, h - barHeight, w, barHeight, self:GetFraction(), self.BarColor, gradientDown)
        if self.Text ~= "" then
            draw.SimpleText(self.Text, "LiliaFont.17", 1, h - barHeight - uiScale(16), shadowColor)
            draw.SimpleText(self.Text, "LiliaFont.17", 0, h - barHeight - uiScale(17), textColor)
        end
    end

    lia.gui.actionPanel.Think = function(self)
        if CurTime() >= endTime then
            if lia.gui.actionPanel == self then lia.gui.actionPanel = nil end
            self:Remove()
            return
        end

        self:SetFraction(1 - math.TimeFraction(startTime, endTime, CurTime()))
    end

    lia.gui.actionPanel:MakePopup()
    lia.gui.actionPanel:SetKeyboardInputEnabled(false)
    lia.gui.actionPanel:SetMouseInputEnabled(false)
end

function lia.bar.drawAll()
    if isMenuOpen() or hook.Run("ShouldHideBars") then return end
    local client = LocalPlayer()
    if not IsValid(client) or not client:getChar() then return end
    table.sort(lia.bar.list, function(a, b)
        if a.priority == b.priority then return (a.order or 0) < (b.order or 0) end
        return (a.priority or 0) < (b.priority or 0)
    end)

    local active = {}
    local now = CurTime()
    for _, bar in ipairs(lia.bar.list) do
        local key = bar.identifier or bar
        local target = math.Clamp(tonumber(bar.getValue()) or 0, 0, 1)
        local value = math.Approach(lia.bar.delta[key] or 0, target, FrameTime() * 1.4)
        lia.bar.delta[key] = value
        if lia.bar.values[key] ~= target or value ~= target then bar.lifeTime = now + 4 end
        lia.bar.values[key] = target
        local show = (lia.option.get("BarsAlwaysVisible") and target > 0) or (bar.lifeTime or 0) >= now or bar.visible or hook.Run("ShouldBarDraw", bar) == true
        if bar.identifier == "health" or bar.identifier == "stamina" or bar.identifier == "stm" then show = true end
        if bar.identifier == "armor" and client:Armor() <= 0 then show = false end
        if show then
            active[#active + 1] = {
                fraction = value,
                color = getBarColor(bar)
            }
        end
    end

    if #active == 0 then return end
    local height = uiScale(8)
    local width = uiScale(240)
    local gap = uiScale(5)
    local padding = uiScale(8)
    local margin = uiScale(20)
    local x = margin
    local y = math.max(margin, ScrH() - margin - padding * 2 - #active * height - (#active - 1) * gap - simfphysHudClearance(client))
    surface.SetDrawColor(0, 0, 0, 140)
    surface.DrawRect(x, y, width + padding * 2, padding * 2 + #active * height + (#active - 1) * gap)
    surface.SetDrawColor(255, 255, 255, 10)
    surface.DrawOutlinedRect(x, y, width + padding * 2, padding * 2 + #active * height + (#active - 1) * gap)
    for _, entry in ipairs(active) do
        paintBar(x + padding, y + padding, width, height, entry.fraction, entry.color, gradientUp)
        y = y + height + gap
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
end, Color(200, 50, 40), 1, "health")

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Armor() / client:GetMaxArmor()
end, Color(30, 70, 180), 3, "armor")

hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
