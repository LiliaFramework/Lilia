lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.values = lia.bar.values or {}
lia.bar.list = {}
lia.bar.counter = lia.bar.counter or 0
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

local function PaintPanel(x, y, w, h)
    lia.derma.rect(x, y, w, h):Rad(4):Color(Color(0, 0, 0, 150)):Draw()
end

function lia.bar.drawBar(x, y, w, h, pos, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 6, 0)
    local fill = usable * pos / max
    PaintPanel(x, y, w + 6, h)
    if fill > 0 then lia.derma.rect(x + 3, y + 3, fill, h - 6):Rad(3):Color(color):Draw() end
end

function lia.bar.drawAction(text, duration)
    if IsValid(lia.gui.actionPanel) then lia.gui.actionPanel:Remove() end
    local startTime, endTime = CurTime(), CurTime() + duration
    local w, h = ScrW() * 0.35, 80
    local x, y = ScrW() * 0.5 - w * 0.5, ScrH() * 0.725 - h * 0.5
    lia.gui.actionPanel = vgui.Create("liaProgressBar")
    lia.gui.actionPanel:SetPos(x, y)
    lia.gui.actionPanel:SetSize(w, h)
    lia.gui.actionPanel:SetAsActionBar(true)
    lia.gui.actionPanel:SetText(text)
    lia.gui.actionPanel:SetBarColor(lia.config.get("Color"))
    lia.gui.actionPanel:SetProgress(startTime, endTime)
    lia.gui.actionPanel:SetFraction(0)
    lia.gui.actionPanel.Think = function(self)
        local curTime = CurTime()
        if curTime >= endTime then
            self:Remove()
            lia.gui.actionPanel = nil
            return
        end

        local frac = 1 - math.TimeFraction(startTime, endTime, curTime)
        self:SetFraction(frac)
    end

    lia.gui.actionPanel:MakePopup()
    lia.gui.actionPanel:SetKeyboardInputEnabled(false)
    lia.gui.actionPanel:SetMouseInputEnabled(false)
end

function lia.bar.drawAll()
    if hook.Run("ShouldHideBars") then return end
    table.sort(lia.bar.list, function(a, b)
        if a.priority == b.priority then return (a.order or 0) < (b.order or 0) end
        return a.priority < b.priority
    end)

    local w, h = ScrW() * 0.35, 18
    local x, y = 4, 4
    local deltas = lia.bar.delta
    local update = FrameTime() * 0.6
    local now = CurTime()
    local always = lia.option.get("BarsAlwaysVisible")
    local values = lia.bar.values
    for i, bar in ipairs(lia.bar.list) do
        local id = bar.identifier or i
        local target = bar.getValue()
        local last = values[id]
        values[id] = target
        deltas[id] = deltas[id] or target
        deltas[id] = math.Approach(deltas[id], target, update)
        local value = deltas[id]
        if last ~= nil and last ~= target then
            bar.lifeTime = now + 5
        elseif value ~= target then
            bar.lifeTime = now + 5
        end

        if always and value > 0 or bar.lifeTime >= now or bar.visible or hook.Run("ShouldBarDraw", bar) then
            lia.bar.drawBar(x, y, w, h, value, 1, bar.color)
            y = y + h + 2
        end
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
