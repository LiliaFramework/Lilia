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
    surface_SetFont("liaMediumFont")
    for k, v in pairs(opts) do
        list[#list + 1] = {k, v}
        w = math_max(w, surface_GetTextSize(tostring(k)))
    end

    table_sort(list, function(a, b) return tostring(a[1]) < tostring(b[1]) end)
    return list, w
end

--[[
    Purpose:
        Creates and adds a new context menu to the menu system

    When Called:
        When you need to display a context menu with options for player interaction

    Parameters:
        - opts (table): Table of menu options where keys are display text and values are callback functions
        - pos (Vector|Entity, optional): World position or entity to attach menu to. If entity, menu attaches to entity's local position
        - onRemove (function, optional): Callback function called when menu is removed

    Returns:
        (number) Index of the created menu in the menu list

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create a basic context menu
        lia.menu.add({
        ["Use"] = function() print("Used item") end,
        ["Drop"] = function() print("Dropped item") end
        })
        ```

        Medium Complexity:
        ```lua
        -- Medium: Create menu attached to an entity
        local ent = Entity(1)
        lia.menu.add({
        ["Open"] = function() ent:Use() end,
        ["Examine"] = function() print("Examining entity") end,
        ["Destroy"] = function() ent:Remove() end
        }, ent)
        ```

        High Complexity:
        ```lua
        -- High: Create menu with custom position and cleanup
        local menuData = {
        ["Option 1"] = function()
        RunConsoleCommand("say", "Selected option 1")
        end,
        ["Option 2"] = function()
        RunConsoleCommand("say", "Selected option 2")
        end,
        ["Cancel"] = function()
        print("Menu cancelled")
        end
        }

        local cleanupFunc = function()
        print("Menu was removed")
        end

        local menuIndex = lia.menu.add(menuData, Vector(100, 200, 50), cleanupFunc)
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
        Renders all active context menus with animations and interaction detection

    When Called:
        Called every frame from the HUD rendering system to draw all menus

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Called automatically by the framework
        -- This function is typically called from hooks like HUDPaint
        hook.Add("HUDPaint", "MenuDraw", lia.menu.drawAll)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Custom rendering with additional checks
        hook.Add("HUDPaint", "CustomMenuDraw", function()
        if not LocalPlayer():Alive() then return end
            lia.menu.drawAll()
        end)
        ```

        High Complexity:
        ```lua
        -- High: Conditional rendering with performance optimization
        local lastDrawTime = 0
        hook.Add("HUDPaint", "OptimizedMenuDraw", function()
        local currentTime = RealTime()
        if currentTime - lastDrawTime < 0.016 then return end -- Limit to ~60fps

            if #lia.menu.list > 0 then
                lia.menu.drawAll()
                lastDrawTime = currentTime
            end
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

            lia_drawText(lbl, x + pad, oy + 2, ColorAlpha(color_white, d.alpha), nil, nil, "liaMediumFont")
        end
    end
end

--[[
    Purpose:
        Gets the currently active menu item that the player is hovering over

    When Called:
        When checking for menu interaction, typically from input handling systems

    Parameters:
        None

    Returns:
        (number, function|nil) Menu index and callback function if menu item is hovered, nil otherwise

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if player is hovering over a menu
        local menuIndex, callback = lia.menu.getActiveMenu()
        if callback then
            print("Player is hovering over menu item")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Handle menu interaction with validation
        hook.Add("PlayerButtonDown", "MenuInteraction", function(ply, button)
        if button == MOUSE_LEFT then
            local menuIndex, callback = lia.menu.getActiveMenu()
            if callback then
                callback()
                print("Menu item activated")
            end
        end
        end)
        ```

        High Complexity:
        ```lua
        -- High: Advanced menu interaction with cooldown and logging
        local lastMenuTime = 0
        hook.Add("PlayerButtonDown", "AdvancedMenuInteraction", function(ply, button)
        if button == MOUSE_LEFT then
            local currentTime = RealTime()
            if currentTime - lastMenuTime < 0.1 then return end -- Prevent spam

                local menuIndex, callback = lia.menu.getActiveMenu()
                if callback then
                    lastMenuTime = currentTime
                    callback()

                    -- Log the interaction
                    print(string.format("Menu interaction at time %f, menu index %d", currentTime, menuIndex))
                end
            end
        end)
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
        Handles button press events for menu items and removes the menu

    When Called:
        When a menu item is clicked or activated by player input

    Parameters:
        - id (number): Index of the menu to remove from the menu list
        - cb (function, optional): Callback function to execute when button is pressed

    Returns:
        (boolean) True if callback was executed, false otherwise

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Remove menu and execute callback
        local menuIndex = 1
        local success = lia.menu.onButtonPressed(menuIndex, function()
        print("Menu button pressed!")
        end)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Handle menu interaction with validation
        hook.Add("PlayerButtonDown", "MenuButtonPress", function(ply, button)
        if button == MOUSE_LEFT then
            local menuIndex, callback = lia.menu.getActiveMenu()
            if menuIndex and callback then
                local success = lia.menu.onButtonPressed(menuIndex, callback)
                if success then
                    print("Menu interaction successful")
                end
            end
        end
        end)
        ```

        High Complexity:
        ```lua
        -- High: Advanced menu handling with error checking and logging
        local function handleMenuPress(menuIndex, callback)
            if not menuIndex or menuIndex <= 0 then
                print("Invalid menu index")
                return false
            end

            if not callback or type(callback) ~= "function" then
                print("Invalid callback function")
                return false
            end

            local success = lia.menu.onButtonPressed(menuIndex, function()
            local success, err = pcall(callback)
            if not success then
                print("Menu callback error: " .. tostring(err))
            end
        end)

        return success
        end

        -- Usage
        local menuIndex, callback = lia.menu.getActiveMenu()
        if menuIndex then
            handleMenuPress(menuIndex, callback)
        end
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
