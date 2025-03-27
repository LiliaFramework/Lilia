lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

--[[
    Function: lia.attribs.setup

    Description:
        Initializes all attributes for a player's character.
        If an attribute has an OnSetup function, it will be called.

    Parameters:
        client (Player) - The player whose character's attributes are being set up.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.attribs.setup(client)
]]
function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

--[[
    Function: lia.attribs.setup

    Description:
        Initializes all attributes for a player's character.
        If an attribute has an OnSetup function, it will be called.

    Parameters:
        client (Player) - The player whose character's attributes are being set up.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.attribs.setup(client)
]]
function lia.bar.add(getValue, color, priority, identifier)
    if identifier then
        local existingIdx = findIndexByIdentifier(identifier)
        if existingIdx then table.remove(lia.bar.list, existingIdx) end
    end

    priority = priority or #lia.bar.list + 1
    table.insert(lia.bar.list, {
        getValue = getValue,
        color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
        priority = priority,
        lifeTime = 0,
        identifier = identifier
    })
    return priority
end

--[[
    Function: lia.attribs.setup

    Description:
        Initializes all attributes for a player's character.
        If an attribute has an OnSetup function, it will be called.

    Parameters:
        client (Player) - The player whose character's attributes are being set up.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.attribs.setup(client)
]]
function lia.bar.remove(identifier)
    local idx = findIndexByIdentifier(identifier)
    if idx then table.remove(lia.bar.list, idx) end
end

--[[
    Function: lia.attribs.setup

    Description:
        Initializes all attributes for a player's character.
        If an attribute has an OnSetup function, it will be called.

    Parameters:
        client (Player) - The player whose character's attributes are being set up.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.attribs.setup(client)
]]
function lia.bar.drawBar(x, y, w, h, pos, neg, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 2, 0)
    local fill = usable * pos / max
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(x, y, w + 6, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawOutlinedRect(x, y, w + 6, h)
    surface.SetDrawColor(color.r, color.g, color.b)
    surface.DrawRect(x + 3, y + 3, fill, h - 6)
end

--[[ 
    Function: lia.bar.drawAction

    Description:
        Draws the action bar on the HUD if an action is currently in progress.
        The bar displays a progress fill and text based on the remaining time.
        Uses blur and styled drawing to render a clean visual effect.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Internal:
        true
]]
function lia.bar.drawAction(text, time)
    local now = CurTime()
    local endTime = now + time
    hook.Remove("HUDPaint", "liaDrawAction")
    hook.Add("HUDPaint", "liaDrawAction", function()
        local cur = CurTime()
        if endTime <= cur then
            hook.Remove("HUDPaint", "liaDrawAction")
            return
        end

        local frac = 1 - math.TimeFraction(now, endTime, cur)
        local w, h = ScrW() * 0.35, 28
        local x, y = ScrW() * 0.5 - w / 2, ScrH() * 0.725 - h / 2
        lia.util.drawBlurAt(x, y, w, h)
        surface.SetDrawColor(35, 35, 35, 100)
        surface.DrawRect(x, y, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawOutlinedRect(x, y, w, h)
        surface.SetDrawColor(lia.config.get("Color"))
        surface.DrawRect(x + 4, y + 4, w * frac - 8, h - 8)
        surface.SetDrawColor(200, 200, 200, 20)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
        surface.DrawTexturedRect(x + 4, y + 4, w * frac - 8, h - 8)
        draw.SimpleText(text, "liaMediumFont", x + 2, y - 22, Color(20, 20, 20))
        draw.SimpleText(text, "liaMediumFont", x, y - 24, Color(240, 240, 240))
    end)
end

--[[ 
    Function: lia.bar.drawAll

    Description:
        Called from the HUDPaintBackground hook to draw all active bars on the player's HUD.
        This includes action bars and status bars. Bars are sorted by priority and
        smoothly animated toward their target values. Positions are configurable.
        Rendering is skipped if the "ShouldHideBars" hook returns true.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Internal:
        true
]]
function lia.bar.drawAll()
    if hook.Run("ShouldHideBars") then return end
    table.sort(lia.bar.list, function(a, b) return a.priority < b.priority end)
    local w, h = ScrW() * 0.35, 14
    local x = 4
    local y = ScrH() - h
    local deltas = lia.bar.delta
    local update = FrameTime() * 0.6
    local now = CurTime()
    for i, bar in ipairs(lia.bar.list) do
        local target = bar.getValue()
        deltas[i] = deltas[i] or target
        deltas[i] = math.Approach(deltas[i], target, update)
        local value = deltas[i]
        if value ~= target then bar.lifeTime = now + 5 end
        if bar.lifeTime >= now or bar.visible or hook.Run("ShouldBarDraw", bar) then
            lia.bar.drawBar(x, y, w, h, value, 0, 1, bar.color)
            y = y - (h + 2)
        end
    end
end

lia.option.add("BarPositions", "Bar Positions", "Determines the position of the Lilia bars.", "Bottom Left", nil, {
    category = "General",
    type = "Table",
    options = {"Top Right", "Top Left", "Bottom Right", "Bottom Left"}
})

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), 2, "stamina")

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
end, Color(200, 50, 40), 1, "health")

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Armor() / client:GetMaxArmor()
end, Color(30, 70, 180), 3, "armor")

hook.Add("HUDPaintBackground", "liaDrawBars", lia.bar.drawAll)