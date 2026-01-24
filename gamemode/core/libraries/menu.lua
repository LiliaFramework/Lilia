--[[
    Folder: Libraries
    File: menu.md
]]
--[[
    Menu Library

    Interactive 3D context menu system for world and entity interactions in the Lilia framework.
]]
--[[
    Overview:
        The menu library provides a comprehensive context menu system for the Lilia framework. It enables the creation of interactive context menus that appear in 3D world space or attached to entities, allowing players to interact with objects and perform actions through a visual interface. The library handles menu positioning, animation, collision detection, and user interaction. Menus automatically fade in when the player looks at them and fade out when they look away, with smooth animations and proper range checking. The system supports both world-positioned menus and entity-attached menus with automatic screen space conversion and boundary clamping to ensure menus remain visible and accessible.
]]
lia.menu = lia.menu or {}
lia.menu.list = lia.menu.list or {}
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local lia_drawText = lia.util.drawText
local ColorAlpha = ColorAlpha
local math_max = math.max
local math_Clamp = math.Clamp
local math_cos = math.cos
local approach = math.Approach
local LerpVector = LerpVector
local FrameTime = FrameTime
local RealTime = RealTime
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local isEntity = isentity
local Material = Material
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove
local pad = 12
local rowH = 28
local gradient = Material("vgui/gradient-u")
local rangeSqr = 9216
local clickDist = 96
local function buildItems(opts)
    local list, w = {}, 0
    surface_SetFont("LiliaFont.25")
    for k, v in pairs(opts) do
        list[#list + 1] = {k, v}
        w = math_max(w, surface_GetTextSize(tostring(k)))
    end

    table_sort(list, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
    return list, w
end

--[[
    Purpose:
        Adds a new interactive context menu to the system that can be displayed in 3D world space or attached to entities.

    When Called:
        Called when creating context menus for world interactions, entity interactions, or any situation requiring a visual menu interface.

    Parameters:
        opts (table)
            A table containing menu options where keys are display text and values are callback functions.
        pos (Vector or Entity)
            The world position for the menu, or an entity to attach the menu to.
        onRemove (function)
            Optional callback function called when the menu is removed.

    Returns:
        number
            The index of the newly added menu in the menu list.

    Realm:
        Client

    Example Usage:
        ```lua
        -- Create a simple menu for an entity
        lia.menu.add({
            ["Open"] = function() print("Opening...") end,
            ["Close"] = function() print("Closing...") end
        }, entity)

        -- Create a world-positioned menu
        lia.menu.add({
            ["Pickup"] = function() print("Picked up!") end
        }, Vector(0, 0, 0))
        ```
]]
function lia.menu.add(opts, pos, onRemove)
    local client = LocalPlayer()
    local items, txtW = buildItems(opts)
    local ent
    if isEntity(pos) then
        ent = pos
        pos = ent:WorldToLocal(client:GetEyeTrace().HitPos)
    end
    return table_insert(lia.menu.list, {
        position = pos or client:GetEyeTrace().HitPos,
        entity = ent,
        items = items,
        width = txtW + pad * 2,
        height = #items * rowH,
        onRemove = onRemove
    })
end

local function getScreenPos(d, ft)
    if d.entity then
        if not IsValid(d.entity) then return end
        local world = d.entity:LocalToWorld(d.position)
        d.entPos = LerpVector(ft * 15, d.entPos or world, world)
        return d.entPos:ToScreen()
    end
    return d.position:ToScreen()
end

local function drawBackground(x, y, w, h, a)
    local a90 = a * 0.9
    surface_SetDrawColor(40, 40, 40, a90)
    surface_DrawRect(x - 4, y - 4, w + 8, h + 8)
    surface_SetDrawColor(250, 250, 250, a90 * 0.025)
    surface_SetMaterial(gradient)
    surface_DrawTexturedRect(x - 4, y - 4, w + 8, h + 8)
    surface_SetDrawColor(0, 0, 0, a90 * 0.25)
    surface_DrawOutlinedRect(x - 4, y - 4, w + 8, h + 8)
end

--[[
    Purpose:
        Renders all active context menus on the screen with smooth animations, range checking, and mouse interaction highlighting.

    When Called:
        Called every frame during the HUD/rendering phase to draw all active menus. Typically hooked into the drawing system.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
        -- Called automatically by the framework's rendering system
        -- Can be manually called if needed for custom rendering setups
        hook.Add("HUDPaint", "DrawMenus", function()
            lia.menu.drawAll()
        end)
        ```
]]
function lia.menu.drawAll()
    local client = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    local mx, my = sw * 0.5, sh * 0.5
    local pPos = client:GetPos()
    local ft = FrameTime() * 30
    for i = #lia.menu.list, 1, -1 do
        local d = lia.menu.list[i]
        local sp = getScreenPos(d, ft)
        if not sp then
            table_remove(lia.menu.list, i)
            if d.onRemove then d:onRemove() end
            continue
        end

        local w, h = d.width, d.height
        local x = math_Clamp(sp.x - w * 0.5, 8, sw - w - 8)
        local y = math_Clamp(sp.y, 8, sh - h - 8)
        local inRange = pPos:DistToSqr(IsValid(d.entity) and d.entity:GetPos() or d.position) <= rangeSqr
        local inside = mx >= x and mx <= x + w and my >= y and my <= y + h and inRange
        local a = d.alpha or 0
        if not d.displayed or inside then
            d.alpha = approach(a, 255, ft * 25)
            if d.alpha == 255 then d.displayed = true end
        else
            d.alpha = approach(a, 0, inRange and ft or ft * 45)
            if d.alpha == 0 then
                table_remove(lia.menu.list, i)
                if d.onRemove then d:onRemove() end
                continue
            end
        end

        drawBackground(x, y, w, h, d.alpha)
        local osc = math_cos(RealTime() * 8)
        for idx = 1, #d.items do
            local lbl, _ = d.items[idx][1], d.items[idx][2]
            local oy = y + (idx - 1) * rowH
            if inside and my >= oy and my <= oy + rowH then
                surface_SetDrawColor(ColorAlpha(lia.config.get("Color"), d.alpha + osc * 40))
                surface_DrawRect(x, oy, w, rowH)
            end

            lia_drawText(lbl, x + pad, oy + 2, ColorAlpha(color_white, d.alpha), nil, nil, "LiliaFont.25")
        end
    end
end

--[[
    Purpose:
        Determines which menu item is currently under the mouse cursor and within interaction range.

    When Called:
        Called when checking for menu interactions, mouse clicks, or determining which menu option the player is hovering over.

    Parameters:
        None

    Returns:
        number, function or nil
            Returns the menu index and the callback function of the active menu item, or nil if no active menu item is found.

    Realm:
        Client

    Example Usage:
        ```lua
        -- Check for menu interactions in a click handler
        local menuIndex, callback = lia.menu.getActiveMenu()
        if menuIndex and callback then
            lia.menu.onButtonPressed(menuIndex, callback)
        end

        -- Check if player is hovering over a menu
        local activeMenu = lia.menu.getActiveMenu()
        if activeMenu then
            -- Player is hovering over a menu item
        end
        ```
]]
function lia.menu.getActiveMenu()
    local client = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    local mx, my = sw * 0.5, sh * 0.5
    local pPos = client:GetPos()
    for i = #lia.menu.list, 1, -1 do
        local d = lia.menu.list[i]
        local sp = getScreenPos(d, 0)
        if not sp then
            table_remove(lia.menu.list, i)
            continue
        end

        local w, h = d.width, d.height
        local x = math_Clamp(sp.x - w * 0.5, 8, sw - w - 8)
        local y = math_Clamp(sp.y, 8, sh - h - 8)
        if mx < x or mx > x + w or my < y or my > y + h then continue end
        if pPos:Distance(IsValid(d.entity) and d.entity:GetPos() or d.position) > clickDist then continue end
        local idx = math.floor((my - y) / rowH) + 1
        local item = d.items[idx]
        if item then return i, item[2] end
    end
end

--[[
    Purpose:
        Handles menu button press events by removing the menu and executing the associated callback function.

    When Called:
        Called when a menu button is clicked to process the interaction and clean up the menu.

    Parameters:
        id (number)
            The index of the menu to remove from the menu list.
        cb (function)
            The callback function to execute when the button is pressed.

    Returns:
        boolean
            Returns true if a callback was executed, false otherwise.

    Realm:
        Client

    Example Usage:
        ```lua
        -- Handle a menu button press
        local menuIndex, callback = lia.menu.getActiveMenu()
        if menuIndex then
            local success = lia.menu.onButtonPressed(menuIndex, callback)
            if success then
                print("Menu action executed successfully")
            end
        end

        -- Remove a menu without executing callback
        lia.menu.onButtonPressed(specificMenuId)
        ```
]]
function lia.menu.onButtonPressed(id, cb)
    table_remove(lia.menu.list, id)
    if cb then
        cb()
        return true
    end
    return false
end
