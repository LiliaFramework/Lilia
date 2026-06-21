--[[
    Folder: Developer - Libraries
    File: lia.bar.md
]]
--[[
    Bar

    HUD bar helpers for registering, retrieving, removing, drawing, and displaying temporary action progress bars.
]]
--[[
    Overview:
        The bar library centralizes clientside HUD bar behavior under `lia.bar`. It manages registered status bars, smooths value changes over time, controls visibility through options and hooks, draws bar panels, and provides a temporary action progress bar panel for timed clientside actions.
]]
--[[
    Hooks:
        ShouldHideBars()

    Purpose:
        Allows plugins or modules to hide all registered HUD bars before they are drawn.

    Parameters:
        None

    Returns:
        boolean|nil
            Return true to stop all HUD bars from drawing. Return nil or false to allow normal drawing checks to continue.

    Realm:
        Client
]]
--[[
    Hooks:
        ShouldBarDraw(table bar)

    Purpose:
        Allows plugins or modules to force a specific registered HUD bar to draw even when it would not otherwise be visible.

    Parameters:
        bar (table)
            The registered bar data currently being evaluated for drawing.

    Returns:
        boolean|nil
            Return true to draw the bar. Return nil or false to continue normal visibility behavior.

    Realm:
        Client
]]
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

--[[
    Purpose:
        Gets a registered HUD bar by its identifier.

    Parameters:
        identifier (string)
            The unique identifier assigned when the bar was registered.

    Returns:
        table
            The registered bar data, or nil if no matching bar exists.

    Example Usage:
        ```lua
        local bar = lia.bar.get("health")
        if bar then print(bar.priority) end
        ```

    Realm:
        Client
]]
function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

--[[
    Purpose:
        Registers a HUD bar and replaces an existing bar when the same identifier is provided.

    Parameters:
        getValue (function)
            Function that returns the bar's current normalized value.
        color (Color)
            The color used to draw the bar fill. If omitted, a random bright color is used.
        priority (number)
            The sort priority used when drawing bars. Lower values draw first. If omitted, the next list position is used.
        identifier (string)
            Optional unique identifier used to retrieve, replace, or remove the bar later.

    Returns:
        number
            The priority assigned to the registered bar.

    Example Usage:
        ```lua
        lia.bar.add(function()
            return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
        end, Color(200, 50, 40), 1, "health")
        ```

    Realm:
        Client
]]
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

--[[
    Purpose:
        Removes a registered HUD bar by its identifier.

    Parameters:
        identifier (string)
            The unique identifier of the bar to remove.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.bar.remove("stamina")
        ```

    Realm:
        Client
]]
function lia.bar.remove(identifier)
    local idx = findIndexByIdentifier(identifier)
    if idx then table.remove(lia.bar.list, idx) end
end

local function PaintPanel(x, y, w, h)
    lia.derma.rect(x, y, w, h):Rad(4):Color(Color(0, 0, 0, 150)):Draw()
end

--[[
    Purpose:
        Draws a single HUD bar panel and its filled portion.

    Parameters:
        x (number)
            The horizontal screen position.
        y (number)
            The vertical screen position.
        w (number)
            The bar width.
        h (number)
            The bar height.
        pos (number)
            The current bar value.
        max (number)
            The maximum bar value.
        color (Color)
            The color used to draw the filled portion.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.bar.drawBar(4, 4, ScrW() * 0.35, 18, 0.75, 1, Color(200, 50, 40))
        ```

    Realm:
        Client
]]
function lia.bar.drawBar(x, y, w, h, pos, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 6, 0)
    local fill = usable * pos / max
    PaintPanel(x, y, w + 6, h)
    if fill > 0 then lia.derma.rect(x + 3, y + 3, fill, h - 6):Rad(3):Color(color):Draw() end
end

--[[
    Purpose:
        Displays a temporary action progress bar with text and a countdown duration.

    Parameters:
        text (string)
            The text displayed on the action progress bar.
        duration (number)
            The duration, in seconds, before the action progress bar is removed.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.bar.drawAction("Searching...", 5)
        ```

    Realm:
        Client
]]
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

--[[
    Purpose:
        Draws every registered HUD bar that should currently be visible.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
        ```

    Realm:
        Client
]]
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