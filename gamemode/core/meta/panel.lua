--[[
    Panel Meta

    Panel management system for the Lilia framework.
]]
--[[
    Overview:
        The panel meta table provides comprehensive functionality for managing VGUI panels, UI interactions, and panel operations in the Lilia framework. It handles panel event listening, inventory synchronization, UI updates, and panel-specific operations. The meta table operates primarily on the client side, with the server providing data that panels can listen to and display. It includes integration with the inventory system for inventory change notifications, character system for character data display, network system for data synchronization, and UI system for panel management. The meta table ensures proper panel event handling, inventory synchronization, UI updates, and comprehensive panel lifecycle management from creation to destruction.
]]
local panelMeta = FindMetaTable("Panel")
local originalSetSize = panelMeta.SetSize
local originalSetPos = panelMeta.SetPos
--[[
    Purpose:
        Sets up event listeners for inventory changes on a panel

    When Called:
        When a UI panel needs to respond to inventory modifications, typically during panel initialization

    Parameters:
        inventory (Inventory)
            The inventory object to listen for changes on

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set up inventory listening for a basic panel
        panel:liaListenForInventoryChanges(playerInventory)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set up inventory listening with conditional setup
        if playerInventory then
            characterPanel:liaListenForInventoryChanges(playerInventory)
        end
        ```

    High Complexity:
        ```lua
        -- High: Set up inventory listening for multiple panels with error handling
        local panels = {inventoryPanel, characterPanel, equipmentPanel}
        for _, pnl in ipairs(panels) do
            if IsValid(pnl) and playerInventory then
                pnl:liaListenForInventoryChanges(playerInventory)
            end
        end
        ```
]]
function panelMeta:liaListenForInventoryChanges(inventory)
    assert(inventory, L("noInventorySet"))
    local id = inventory:getID()
    self:liaDeleteInventoryHooks(id)
    _LIA_INV_PANEL_ID = (_LIA_INV_PANEL_ID or 0) + 1
    local hookID = "liaInventoryListener" .. _LIA_INV_PANEL_ID
    self.liaHookID = self.liaHookID or {}
    self.liaHookID[id] = hookID
    self.liaToRemoveHooks = self.liaToRemoveHooks or {}
    self.liaToRemoveHooks[id] = {}
    local function listenForInventoryChange(eventName, panelHookName)
        panelHookName = panelHookName or eventName
        hook.Add(eventName, hookID, function(inv, ...)
            if not IsValid(self) then return end
            if not isfunction(self[panelHookName]) then return end
            local args = {...}
            args[#args + 1] = inv
            self[panelHookName](self, unpack(args))
            if eventName == "InventoryDeleted" then self:liaDeleteInventoryHooks(id) end
        end)

        table.insert(self.liaToRemoveHooks[id], eventName)
    end

    listenForInventoryChange("InventoryInitialized")
    listenForInventoryChange("InventoryDeleted")
    listenForInventoryChange("InventoryDataChanged")
    listenForInventoryChange("InventoryItemAdded")
    listenForInventoryChange("InventoryItemRemoved")
    hook.Add("ItemDataChanged", hookID, function(item, key, oldValue, newValue)
        if not IsValid(self) or not inventory.items[item:getID()] then return end
        if not isfunction(self.InventoryItemDataChanged) then return end
        self:InventoryItemDataChanged(item, key, oldValue, newValue, inventory)
    end)

    table.insert(self.liaToRemoveHooks[id], "ItemDataChanged")
end

--[[
    Purpose:
        Removes inventory change event listeners from a panel

    When Called:
        When a panel no longer needs to listen to inventory changes, during cleanup, or when switching inventories

    Parameters:
        id (number)
            The specific inventory ID to remove hooks for, or nil to remove all hooks

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Remove hooks for a specific inventory
        panel:liaDeleteInventoryHooks(inventoryID)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up hooks when closing a panel
        if IsValid(panel) then
            panel:liaDeleteInventoryHooks()
        end
        ```

    High Complexity:
        ```lua
        -- High: Clean up multiple panels with different inventory IDs
        local panels = {inventoryPanel, equipmentPanel, storagePanel}
        local inventoryIDs = {playerInvID, equipmentInvID, storageInvID}

        for i, pnl in ipairs(panels) do
            if IsValid(pnl) then
                pnl:liaDeleteInventoryHooks(inventoryIDs[i])
            end
        end
        ```
]]
function panelMeta:liaDeleteInventoryHooks(id)
    if not self.liaHookID then return end
    if id == nil then
        for invID, hookIDs in pairs(self.liaToRemoveHooks) do
            for i = 1, #hookIDs do
                if IsValid(self.liaHookID) then hook.Remove(hookIDs[i], self.liaHookID) end
            end

            self.liaToRemoveHooks[invID] = nil
        end
        return
    end

    if not self.liaHookID[id] then return end
    for i = 1, #self.liaToRemoveHooks[id] do
        hook.Remove(self.liaToRemoveHooks[id][i], self.liaHookID[id])
    end

    self.liaToRemoveHooks[id] = nil
end

--[[
    Purpose:
        Sets the position of a panel with automatic screen scaling

    When Called:
        When positioning UI elements that need to adapt to different screen resolutions

    Parameters:
        x (number)
            The horizontal position value to be scaled
        y (number)
            The vertical position value to be scaled

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Position a button at scaled coordinates
        button:setScaledPos(100, 50)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Position panel based on screen dimensions
        local x = ScrW() * 0.5 - 200
        local y = ScrH() * 0.3
        panel:setScaledPos(x, y)
        ```

    High Complexity:
        ```lua
        -- High: Position multiple panels with responsive layout
        local panels = {mainPanel, sidePanel, footerPanel}
        local positions = {
            {ScrW() * 0.1, ScrH() * 0.1},
            {ScrW() * 0.7, ScrH() * 0.1},
            {ScrW() * 0.1, ScrH() * 0.8}
        }

        for i, pnl in ipairs(panels) do
            if IsValid(pnl) then
                pnl:setScaledPos(positions[i][1], positions[i][2])
            end
        end
        ```
]]
function panelMeta:setScaledPos(x, y)
    if not IsValid(self) then return end
    if not originalSetPos then
        ErrorNoHalt("[Lilia] setScaledPos: Panel does not have SetPos method. Panel type: " .. tostring(self.ClassName or "Unknown") .. "\n")
        return
    end

    originalSetPos(self, ScreenScale(x), ScreenScaleH(y))
end

--[[
    Purpose:
        Sets the size of a panel with automatic screen scaling

    When Called:
        When sizing UI elements that need to adapt to different screen resolutions

    Parameters:
        w (number)
            The width value to be scaled
        h (number)
            The height value to be scaled

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set panel size with scaled dimensions
        panel:setScaledSize(400, 300)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set size based on screen proportions
        local w = ScrW() * 0.8
        local h = ScrH() * 0.6
        panel:setScaledSize(w, h)
        ```

    High Complexity:
        ```lua
        -- High: Set sizes for multiple panels with responsive layout
        local panels = {mainPanel, sidePanel, footerPanel}
        local sizes = {
            {ScrW() * 0.7, ScrH() * 0.6},
            {ScrW() * 0.25, ScrH() * 0.6},
            {ScrW() * 0.95, ScrH() * 0.1}
        }

        for i, pnl in ipairs(panels) do
            if IsValid(pnl) then
                pnl:setScaledSize(sizes[i][1], sizes[i][2])
            end
        end
        ```
]]
function panelMeta:setScaledSize(w, h)
    if not IsValid(self) then return end
    if not originalSetSize then
        lia.error("[Lilia] setScaledSize: Panel does not have SetSize method. Panel type: " .. tostring(self.ClassName or "Unknown") .. "\n")
        return
    end

    originalSetSize(self, ScreenScale(w), ScreenScaleH(h))
end

local blur = Material("pp/blurscreen")
local gradLeft = Material("vgui/gradient-l")
local gradUp = Material("vgui/gradient-u")
local gradRight = Material("vgui/gradient-r")
local gradDown = Material("vgui/gradient-d")
local function drawCircle(x, y, r)
    local circle = {}
    for i = 1, 360 do
        circle[i] = {}
        circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
        circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
    end

    surface.DrawPoly(circle)
end

function panelMeta:On(name, fn)
    name = self.AppendOverwrite or name
    local old = self[name]
    self[name] = function(s, ...)
        if old then old(s, ...) end
        fn(s, ...)
    end
end

function panelMeta:SetupTransition(name, speed, fn)
    fn = self.TransitionFunc or fn
    self[name] = 0
    self:On("Think", function(s) s[name] = Lerp(FrameTime() * speed, s[name], fn(s) and 1 or 0) end)
end

--[[
    Purpose:
        Adds a fade hover effect to a panel that transitions opacity based on hover state

    When Called:
        When initializing a panel that should have a visual hover effect with opacity transition

    Parameters:
        col (Color, optional)
            The color to use for the hover effect. Defaults to Color(255, 255, 255, 30)
        speed (number, optional)
            The transition speed for the fade effect. Defaults to 6
        rad (number, optional)
            The border radius for rounded corners. If provided, uses rounded box drawing

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic fade hover effect
        button:FadeHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add fade hover with custom color and speed
        panel:FadeHover(Color(100, 150, 255, 50), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add fade hover with rounded corners and custom styling
        panel:FadeHover(Color(255, 200, 0, 40), 10, 8)
        ```
]]
function panelMeta:FadeHover(col, speed, rad)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    self:SetupTransition("FadeHover", speed, function(s) return s:IsHovered() end)
    self:On("Paint", function(s, w, h)
        local colAlpha = ColorAlpha(col, col.a * s.FadeHover)
        if rad and rad > 0 then
            draw.RoundedBox(rad, 0, 0, w, h, colAlpha)
        else
            surface.SetDrawColor(colAlpha)
            surface.DrawRect(0, 0, w, h)
        end
    end)
end

--[[
    Purpose:
        Adds a horizontal bar hover effect that expands from the center when hovered

    When Called:
        When initializing a panel that should display a bottom bar indicator on hover

    Parameters:
        col (Color, optional)
            The color of the hover bar. Defaults to Color(255, 255, 255, 255)
        height (number, optional)
            The height of the hover bar in pixels. Defaults to 2
        speed (number, optional)
            The transition speed for the bar expansion. Defaults to 6

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic bar hover effect
        button:BarHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add bar hover with custom color and height
        panel:BarHover(Color(0, 150, 255), 3, 8)
        ```

    High Complexity:
        ```lua
        -- High: Add bar hover with custom styling
        panel:BarHover(Color(255, 100, 0), 4, 10)
        ```
]]
function panelMeta:BarHover(col, height, speed)
    col = col or Color(255, 255, 255, 255)
    height = height or 2
    speed = speed or 6
    self:SetupTransition("BarHover", speed, function(s) return s:IsHovered() end)
    self:On("PaintOver", function(s, w, h)
        local bar = math.Round(w * s.BarHover)
        surface.SetDrawColor(col)
        surface.DrawRect(w / 2 - bar / 2, h - height, bar, height)
    end)
end

--[[
    Purpose:
        Adds a fill hover effect that expands from a specified direction when hovered

    When Called:
        When initializing a panel that should have a directional fill effect on hover

    Parameters:
        col (Color, optional)
            The color of the fill effect. Defaults to Color(255, 255, 255, 30)
        dir (number, optional)
            The direction for the fill effect (LEFT, TOP, RIGHT, BOTTOM). Defaults to LEFT
        speed (number, optional)
            The transition speed for the fill expansion. Defaults to 8
        mat (Material, optional)
            Optional material to use for the fill instead of solid color

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic fill hover from left
        button:FillHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add fill hover from bottom with custom color
        panel:FillHover(Color(100, 200, 255), BOTTOM, 10)
        ```

    High Complexity:
        ```lua
        -- High: Add fill hover with material texture
        panel:FillHover(Color(255, 255, 255), RIGHT, 8, gradientMaterial)
        ```
]]
function panelMeta:FillHover(col, dir, speed, mat)
    col = col or Color(255, 255, 255, 30)
    dir = dir or LEFT
    speed = speed or 8
    self:SetupTransition("FillHover", speed, function(s) return s:IsHovered() end)
    self:On("PaintOver", function(s, w, h)
        surface.SetDrawColor(col)
        local x, y, fw, fh
        if dir == LEFT then
            x, y, fw, fh = 0, 0, math.Round(w * s.FillHover), h
        elseif dir == TOP then
            x, y, fw, fh = 0, 0, w, math.Round(h * s.FillHover)
        elseif dir == RIGHT then
            local prog = math.Round(w * s.FillHover)
            x, y, fw, fh = w - prog, 0, prog, h
        elseif dir == BOTTOM then
            local prog = math.Round(h * s.FillHover)
            x, y, fw, fh = 0, h - prog, w, prog
        end

        if mat then
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(x, y, fw, fh)
        else
            surface.DrawRect(x, y, fw, fh)
        end
    end)
end

--[[
    Purpose:
        Sets a background color for a panel with optional rounded corners

    When Called:
        When initializing a panel that needs a colored background

    Parameters:
        col (Color)
            The background color to use
        rad (number, optional)
            The border radius for rounded corners. If 0 or nil, uses square corners
        rtl (boolean, optional)
            Top-left corner rounding. If nil, all corners use rad
        rtr (boolean, optional)
            Top-right corner rounding
        rbl (boolean, optional)
            Bottom-left corner rounding
        rbr (boolean, optional)
            Bottom-right corner rounding

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add solid background color
        panel:Background(Color(40, 40, 40))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add rounded background
        panel:Background(Color(50, 50, 60), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add background with custom corner rounding
        panel:Background(Color(30, 30, 40), 10, true, true, false, false)
        ```
]]
function panelMeta:Background(col, rad, rtl, rtr, rbl, rbr)
    self:On("Paint", function(_, w, h)
        if rad and rad > 0 then
            if rtl ~= nil then
                draw.RoundedBoxEx(rad, 0, 0, w, h, col, rtl, rtr, rbl, rbr)
            else
                draw.RoundedBox(rad, 0, 0, w, h, col)
            end
        else
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
        end
    end)
end

--[[
    Purpose:
        Sets a material texture as the panel background

    When Called:
        When initializing a panel that should display a material texture

    Parameters:
        mat (Material)
            The material to display
        col (Color, optional)
            The color tint to apply to the material. Defaults to Color(255, 255, 255)

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add material background
        panel:Material(Material("icon16/user.png"))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add material with color tint
        panel:Material(Material("icon16/star.png"), Color(255, 200, 0))
        ```

    High Complexity:
        ```lua
        -- High: Add material with custom color and effects
        panel:Material(customMaterial, Color(100, 150, 255, 200))
        ```
]]
function panelMeta:Material(mat, col)
    col = col or Color(255, 255, 255)
    self:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end)
end

--[[
    Purpose:
        Sets a tiled material texture that repeats across the panel background

    When Called:
        When initializing a panel that should display a repeating tiled texture

    Parameters:
        mat (Material)
            The material to tile
        tw (number)
            The tile width in pixels
        th (number)
            The tile height in pixels
        col (Color, optional)
            The color tint to apply. Defaults to Color(255, 255, 255, 255)

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add tiled material
        panel:TiledMaterial(Material("tile.png"), 64, 64)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add tiled material with color tint
        panel:TiledMaterial(Material("pattern.png"), 32, 32, Color(200, 200, 200))
        ```

    High Complexity:
        ```lua
        -- High: Add tiled material with custom styling
        panel:TiledMaterial(customPattern, 16, 16, Color(150, 150, 255, 180))
        ```
]]
function panelMeta:TiledMaterial(mat, tw, th, col)
    col = col or Color(255, 255, 255, 255)
    self:On("Paint", function(_, w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(col)
        surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w / tw, h / th)
    end)
end

--[[
    Purpose:
        Adds an outline border around the panel

    When Called:
        When initializing a panel that needs a visible border outline

    Parameters:
        col (Color, optional)
            The color of the outline. Defaults to Color(255, 255, 255, 255)
        width (number, optional)
            The width of the outline in pixels. Defaults to 1

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic outline
        panel:Outline()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add outline with custom color and width
        panel:Outline(Color(100, 150, 255), 2)
        ```

    High Complexity:
        ```lua
        -- High: Add thick outline with custom color
        panel:Outline(Color(255, 200, 0), 3)
        ```
]]
function panelMeta:Outline(col, width)
    col = col or Color(255, 255, 255, 255)
    width = width or 1
    self:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        for i = 0, width - 1 do
            surface.DrawOutlinedRect(0 + i, 0 + i, w - i * 2, h - i * 2)
        end
    end)
end

--[[
    Purpose:
        Adds corner line decorations to the panel (L-shaped corners)

    When Called:
        When initializing a panel that needs decorative corner lines

    Parameters:
        col (Color, optional)
            The color of the corner lines. Defaults to Color(255, 255, 255, 255)
        cornerLen (number, optional)
            The length of each corner line segment. Defaults to 15

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add corner lines
        panel:LinedCorners()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add corner lines with custom color
        panel:LinedCorners(Color(0, 150, 255), 20)
        ```

    High Complexity:
        ```lua
        -- High: Add corner lines with custom styling
        panel:LinedCorners(Color(255, 200, 0), 25)
        ```
]]
function panelMeta:LinedCorners(col, cornerLen)
    col = col or Color(255, 255, 255, 255)
    cornerLen = cornerLen or 15
    self:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, cornerLen, 1)
        surface.DrawRect(0, 1, 1, cornerLen - 1)
        surface.DrawRect(w - cornerLen, h - 1, cornerLen, 1)
        surface.DrawRect(w - 1, h - cornerLen, 1, cornerLen - 1)
    end)
end

--[[
    Purpose:
        Adds a colored block on a specific side of the panel

    When Called:
        When initializing a panel that needs a side indicator or accent block

    Parameters:
        col (Color, optional)
            The color of the side block. Defaults to Color(255, 255, 255, 255)
        size (number, optional)
            The size/thickness of the block. Defaults to 3
        side (number, optional)
            The side to place the block (LEFT, TOP, RIGHT, BOTTOM). Defaults to LEFT

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add side block on left
        panel:SideBlock()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add side block on bottom with custom color
        panel:SideBlock(Color(0, 255, 0), 5, BOTTOM)
        ```

    High Complexity:
        ```lua
        -- High: Add side block with custom styling
        panel:SideBlock(Color(255, 100, 0), 4, RIGHT)
        ```
]]
function panelMeta:SideBlock(col, size, side)
    col = col or Color(255, 255, 255, 255)
    size = size or 3
    side = side or LEFT
    self:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        if side == LEFT then
            surface.DrawRect(0, 0, size, h)
        elseif side == TOP then
            surface.DrawRect(0, 0, w, size)
        elseif side == RIGHT then
            surface.DrawRect(w - size, 0, size, h)
        elseif side == BOTTOM then
            surface.DrawRect(0, h - size, w, size)
        end
    end)
end

--[[
    Purpose:
        Adds text rendering to a panel with optional styling

    When Called:
        When initializing a panel that should display text

    Parameters:
        text (string)
            The text to display
        font (string, optional)
            The font to use. Defaults to "Trebuchet24"
        col (Color, optional)
            The text color. Defaults to Color(255, 255, 255, 255)
        alignment (number, optional)
            Text alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT). Defaults to TEXT_ALIGN_CENTER
        ox (number, optional)
            Horizontal offset. Defaults to 0
        oy (number, optional)
            Vertical offset. Defaults to 0
        paint (boolean, optional)
            If true, forces Paint hook instead of using SetText methods

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add text
        panel:Text("Hello World")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add text with custom font and color
        panel:Text("Title", "DermaDefault", Color(255, 200, 0))
        ```

    High Complexity:
        ```lua
        -- High: Add text with full customization
        panel:Text("Label", "CustomFont", Color(100, 150, 255), TEXT_ALIGN_LEFT, 10, -5)
        ```
]]
function panelMeta:Text(text, font, col, alignment, ox, oy, paint)
    font = font or "Trebuchet24"
    col = col or Color(255, 255, 255, 255)
    alignment = alignment or TEXT_ALIGN_CENTER
    ox = ox or 0
    oy = oy or 0
    if not paint and self.SetText and self.SetFont and self.SetTextColor then
        self:SetText(text)
        self:SetFont(font)
        self:SetTextColor(col)
    else
        self:On("Paint", function(_, w, h)
            local x = 0
            if alignment == TEXT_ALIGN_CENTER then
                x = w / 2
            elseif alignment == TEXT_ALIGN_RIGHT then
                x = w
            end

            draw.SimpleText(text, font, x + ox, h / 2 + oy, col, alignment, TEXT_ALIGN_CENTER)
        end)
    end
end

--[[
    Purpose:
        Adds two lines of text to a panel, one on top and one on bottom

    When Called:
        When initializing a panel that should display two text lines vertically

    Parameters:
        toptext (string)
            The top text to display
        topfont (string, optional)
            The font for the top text. Defaults to "Trebuchet24"
        topcol (Color, optional)
            The color for the top text. Defaults to Color(0, 127, 255, 255)
        bottomtext (string)
            The bottom text to display
        bottomfont (string, optional)
            The font for the bottom text. Defaults to "Trebuchet18"
        bottomcol (Color, optional)
            The color for the bottom text. Defaults to Color(255, 255, 255, 255)
        alignment (number, optional)
            Text alignment. Defaults to TEXT_ALIGN_CENTER
        centerSpacing (number, optional)
            Spacing between the two text lines. Defaults to 0

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add dual text
        panel:DualText("Title", nil, nil, "Subtitle", nil, nil)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add dual text with custom colors
        panel:DualText("Name", nil, Color(255, 200, 0), "Description", nil, Color(200, 200, 200))
        ```

    High Complexity:
        ```lua
        -- High: Add dual text with full customization
        panel:DualText("Top", "CustomFont1", Color(100, 150, 255), "Bottom", "CustomFont2", Color(255, 255, 255), TEXT_ALIGN_LEFT, 5)
        ```
]]
function panelMeta:DualText(toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing)
    topfont = topfont or "Trebuchet24"
    topcol = topcol or Color(0, 127, 255, 255)
    bottomfont = bottomfont or "Trebuchet18"
    bottomcol = bottomcol or Color(255, 255, 255, 255)
    alignment = alignment or TEXT_ALIGN_CENTER
    centerSpacing = centerSpacing or 0
    self:On("Paint", function(_, w, h)
        surface.SetFont(topfont)
        local _, th = surface.GetTextSize(toptext)
        surface.SetFont(bottomfont)
        local _, bh = surface.GetTextSize(bottomtext)
        local y1, y2 = h / 2 - bh / 2, h / 2 + th / 2
        local x
        if alignment == TEXT_ALIGN_LEFT then
            x = 0
        elseif alignment == TEXT_ALIGN_CENTER then
            x = w / 2
        elseif alignment == TEXT_ALIGN_RIGHT then
            x = w
        end

        draw.SimpleText(toptext, topfont, x, y1 + centerSpacing, topcol, alignment, TEXT_ALIGN_CENTER)
        draw.SimpleText(bottomtext, bottomfont, x, y2 - centerSpacing, bottomcol, alignment, TEXT_ALIGN_CENTER)
    end)
end

--[[
    Purpose:
        Adds a blur effect to the panel background

    When Called:
        When initializing a panel that should have a blurred background effect

    Parameters:
        amount (number, optional)
            The blur intensity. Defaults to 8

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add blur effect
        panel:Blur()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add blur with custom intensity
        panel:Blur(12)
        ```

    High Complexity:
        ```lua
        -- High: Add strong blur effect
        panel:Blur(15)
        ```
]]
function panelMeta:Blur(amount)
    self:On("Paint", function(s)
        local x, y = s:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * (amount or 8))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end)
end

--[[
    Purpose:
        Adds a circular ripple effect that appears when the panel is clicked

    When Called:
        When initializing a panel that should show a click ripple animation

    Parameters:
        col (Color, optional)
            The color of the ripple effect. Defaults to Color(255, 255, 255, 50)
        speed (number, optional)
            The animation speed of the ripple. Defaults to 5
        trad (number, optional)
            The target radius for the ripple. Defaults to panel width

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add click ripple
        button:CircleClick()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add click ripple with custom color
        panel:CircleClick(Color(100, 150, 255, 80), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add click ripple with full customization
        panel:CircleClick(Color(255, 200, 0, 100), 10, 200)
        ```
]]
function panelMeta:CircleClick(col, speed, trad)
    col = col or Color(255, 255, 255, 50)
    speed = speed or 5
    self.Rad, self.Alpha, self.ClickX, self.ClickY = 0, 0, 0, 0
    self:On("Paint", function(s, w)
        if s.Alpha >= 1 then
            surface.SetDrawColor(ColorAlpha(col, s.Alpha))
            draw.NoTexture()
            drawCircle(s.ClickX, s.ClickY, s.Rad)
            s.Rad = Lerp(FrameTime() * speed, s.Rad, trad or w)
            s.Alpha = Lerp(FrameTime() * speed, s.Alpha, 0)
        end
    end)

    self:On("DoClick", function(s)
        s.ClickX, s.ClickY = s:CursorPos()
        s.Rad = 0
        s.Alpha = col.a
    end)
end

--[[
    Purpose:
        Adds a circular hover effect that follows the cursor position

    When Called:
        When initializing a panel that should show a circular hover effect

    Parameters:
        col (Color, optional)
            The color of the hover circle. Defaults to Color(255, 255, 255, 30)
        speed (number, optional)
            The transition speed. Defaults to 6
        trad (number, optional)
            The target radius for the circle. Defaults to panel width

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circle hover
        button:CircleHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circle hover with custom color
        panel:CircleHover(Color(100, 150, 255, 50), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add circle hover with full customization
        panel:CircleHover(Color(255, 200, 0, 40), 10, 150)
        ```
]]
function panelMeta:CircleHover(col, speed, trad)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    self.LastX, self.LastY = 0, 0
    self:SetupTransition("CircleHover", speed, function(s) return s:IsHovered() end)
    self:On("Think", function(s) if s:IsHovered() then s.LastX, s.LastY = s:CursorPos() end end)
    self:On("PaintOver", function(s, w)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleHover))
        drawCircle(s.LastX, s.LastY, s.CircleHover * (trad or w))
    end)
end

--[[
    Purpose:
        Styles a checkbox panel with a square design and animated checkmark

    When Called:
        When initializing a checkbox panel that should have a square style

    Parameters:
        inner (Color, optional)
            The color of the inner checkmark. Defaults to Color(0, 255, 0, 255)
        outer (Color, optional)
            The color of the outer border. Defaults to Color(255, 255, 255, 255)
        speed (number, optional)
            The animation speed for the checkmark. Defaults to 14

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add square checkbox style
        checkbox:SquareCheckbox()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add square checkbox with custom colors
        checkbox:SquareCheckbox(Color(0, 200, 255), Color(200, 200, 200), 10)
        ```

    High Complexity:
        ```lua
        -- High: Add square checkbox with full customization
        checkbox:SquareCheckbox(Color(100, 255, 100), Color(255, 255, 255), 16)
        ```
]]
function panelMeta:SquareCheckbox(inner, outer, speed)
    inner = inner or Color(0, 255, 0, 255)
    outer = outer or Color(255, 255, 255, 255)
    speed = speed or 14
    self:SetupTransition("SquareCheckbox", speed, function(s) return s:GetChecked() end)
    self:On("Paint", function(s, w, h)
        surface.SetDrawColor(outer)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(inner)
        surface.DrawOutlinedRect(0, 0, w, h)
        local bw, bh = (w - 4) * s.SquareCheckbox, (h - 4) * s.SquareCheckbox
        bw, bh = math.Round(bw), math.Round(bh)
        surface.DrawRect(w / 2 - bw / 2, h / 2 - bh / 2, bw, bh)
    end)
end

--[[
    Purpose:
        Styles a checkbox panel with a circular design and animated checkmark

    When Called:
        When initializing a checkbox panel that should have a circular style

    Parameters:
        inner (Color, optional)
            The color of the inner checkmark. Defaults to Color(0, 255, 0, 255)
        outer (Color, optional)
            The color of the outer border. Defaults to Color(255, 255, 255, 255)
        speed (number, optional)
            The animation speed for the checkmark. Defaults to 14

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circle checkbox style
        checkbox:CircleCheckbox()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circle checkbox with custom colors
        checkbox:CircleCheckbox(Color(0, 200, 255), Color(200, 200, 200), 10)
        ```

    High Complexity:
        ```lua
        -- High: Add circle checkbox with full customization
        checkbox:CircleCheckbox(Color(100, 255, 100), Color(255, 255, 255), 16)
        ```
]]
function panelMeta:CircleCheckbox(inner, outer, speed)
    inner = inner or Color(0, 255, 0, 255)
    outer = outer or Color(255, 255, 255, 255)
    speed = speed or 14
    self:SetupTransition("CircleCheckbox", speed, function(s) return s:GetChecked() end)
    self:On("Paint", function(s, w, h)
        draw.NoTexture()
        surface.SetDrawColor(outer)
        drawCircle(w / 2, h / 2, w / 2 - 1)
        surface.SetDrawColor(inner)
        drawCircle(w / 2, h / 2, w * s.CircleCheckbox / 2)
    end)
end

--[[
    Purpose:
        Creates an avatar image with a custom mask shape

    When Called:
        When initializing a panel that should display a masked avatar image

    Parameters:
        mask (function)
            A function that draws the mask shape: function(panel, width, height)

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add avatar mask with circle
        panel:AvatarMask(function(_, w, h) drawCircle(w/2, h/2, w/2) end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add avatar mask with custom shape
        panel:AvatarMask(function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, color_white) end)
        ```

    High Complexity:
        ```lua
        -- High: Add avatar mask with complex shape
        panel:AvatarMask(function(_, w, h)
            -- Custom mask drawing code
        end)
        ```
]]
function panelMeta:AvatarMask(mask)
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)
    self.Paint = function(s, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilPassOperation(STENCILOPERATION_ZERO)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
        render.SetStencilReferenceValue(1)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
        mask(s, w, h)
        render.SetStencilFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilReferenceValue(1)
        s.Avatar:SetPaintedManually(false)
        s.Avatar:PaintManual()
        s.Avatar:SetPaintedManually(true)
        render.SetStencilEnable(false)
        render.ClearStencil()
    end

    self.PerformLayout = function(s) s.Avatar:SetSize(s:GetWide(), s:GetTall()) end
    self.SetPlayer = function(s, ply, size) s.Avatar:SetPlayer(ply, size) end
    self.SetSteamID = function(s, id, size) s.Avatar:SetSteamID(id, size) end
end

--[[
    Purpose:
        Creates a circular avatar image panel

    When Called:
        When initializing a panel that should display a circular avatar

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circular avatar
        panel:CircleAvatar()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circular avatar and set player
        panel:CircleAvatar()
        panel:SetPlayer(LocalPlayer(), 64)
        ```

    High Complexity:
        ```lua
        -- High: Add circular avatar with full setup
        panel:CircleAvatar()
        panel:SetPlayer(targetPlayer, 128)
        ```
]]
function panelMeta:CircleAvatar()
    self:AvatarMask(function(_, w, h) drawCircle(w / 2, h / 2, w / 2) end)
end

--[[
    Purpose:
        Draws a filled circle on the panel

    When Called:
        When initializing a panel that should display a circle shape

    Parameters:
        col (Color, optional)
            The color of the circle. Defaults to Color(255, 255, 255, 255)

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circle
        panel:Circle()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circle with custom color
        panel:Circle(Color(100, 150, 255))
        ```

    High Complexity:
        ```lua
        -- High: Add circle with custom styling
        panel:Circle(Color(255, 200, 0, 200))
        ```
]]
function panelMeta:Circle(col)
    col = col or Color(255, 255, 255, 255)
    self:On("Paint", function(_, w, h)
        draw.NoTexture()
        surface.SetDrawColor(col)
        drawCircle(w / 2, h / 2, math.min(w, h) / 2)
    end)
end

--[[
    Purpose:
        Adds a circular fade hover effect that transitions opacity on hover

    When Called:
        When initializing a panel that should have a circular fade hover effect

    Parameters:
        col (Color, optional)
            The color of the hover circle. Defaults to Color(255, 255, 255, 30)
        speed (number, optional)
            The transition speed. Defaults to 6

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circle fade hover
        button:CircleFadeHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circle fade hover with custom color
        panel:CircleFadeHover(Color(100, 150, 255, 50), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add circle fade hover with full customization
        panel:CircleFadeHover(Color(255, 200, 0, 40), 10)
        ```
]]
function panelMeta:CircleFadeHover(col, speed)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    self:SetupTransition("CircleFadeHover", speed, function(s) return s:IsHovered() end)
    self:On("Paint", function(s, w, h)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleFadeHover))
        drawCircle(w / 2, h / 2, w / 2)
    end)
end

--[[
    Purpose:
        Adds a circular hover effect that expands from the center on hover

    When Called:
        When initializing a panel that should have an expanding circle hover effect

    Parameters:
        col (Color, optional)
            The color of the hover circle. Defaults to Color(255, 255, 255, 30)
        speed (number, optional)
            The transition speed. Defaults to 6

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add circle expand hover
        button:CircleExpandHover()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add circle expand hover with custom color
        panel:CircleExpandHover(Color(100, 150, 255, 50), 8)
        ```

    High Complexity:
        ```lua
        -- High: Add circle expand hover with full customization
        panel:CircleExpandHover(Color(255, 200, 0, 40), 10)
        ```
]]
function panelMeta:CircleExpandHover(col, speed)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    self:SetupTransition("CircleExpandHover", speed, function(s) return s:IsHovered() end)
    self:On("Paint", function(s, w, h)
        local rad = math.Round(w / 2 * s.CircleExpandHover)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleExpandHover))
        drawCircle(w / 2, h / 2, rad)
    end)
end

--[[
    Purpose:
        Adds a gradient effect to the panel background

    When Called:
        When initializing a panel that should have a gradient background

    Parameters:
        col (Color)
            The gradient color
        dir (number, optional)
            The gradient direction (LEFT, TOP, RIGHT, BOTTOM). Defaults to BOTTOM
        frac (number, optional)
            The gradient fraction (0-1). Defaults to 1
        op (boolean, optional)
            If true, reverses the gradient direction

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add gradient
        panel:Gradient(Color(0, 0, 0, 200))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add gradient with direction
        panel:Gradient(Color(0, 0, 0, 150), TOP, 0.5)
        ```

    High Complexity:
        ```lua
        -- High: Add gradient with full customization
        panel:Gradient(Color(100, 150, 255, 180), RIGHT, 0.8, true)
        ```
]]
function panelMeta:Gradient(col, dir, frac, op)
    dir = dir or BOTTOM
    frac = frac or 1
    self:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        local x, y, gw, gh
        if dir == LEFT then
            local prog = math.Round(w * frac)
            x, y, gw, gh = 0, 0, prog, h
            surface.SetMaterial(op and gradRight or gradLeft)
        elseif dir == TOP then
            local prog = math.Round(h * frac)
            x, y, gw, gh = 0, 0, w, prog
            surface.SetMaterial(op and gradDown or gradUp)
        elseif dir == RIGHT then
            local prog = math.Round(w * frac)
            x, y, gw, gh = w - prog, 0, prog, h
            surface.SetMaterial(op and gradLeft or gradRight)
        elseif dir == BOTTOM then
            local prog = math.Round(h * frac)
            x, y, gw, gh = 0, h - prog, w, prog
            surface.SetMaterial(op and gradUp or gradDown)
        end

        surface.DrawTexturedRect(x, y, gw, gh)
    end)
end

--[[
    Purpose:
        Sets the panel to open a URL when clicked

    When Called:
        When initializing a panel that should open a URL on click

    Parameters:
        url (string)
            The URL to open when the panel is clicked

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Open URL on click
        button:SetOpenURL("https://example.com")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Open URL with validation
        if url then
            panel:SetOpenURL(url)
        end
        ```

    High Complexity:
        ```lua
        -- High: Open URL with multiple conditions
        panel:SetOpenURL("https://example.com/page?id=" .. id)
        ```
]]
function panelMeta:SetOpenURL(url)
    self:On("DoClick", function() gui.OpenURL(url) end)
end

--[[
    Purpose:
        Sets the panel to send a network message when clicked

    When Called:
        When initializing a panel that should send network data on click

    Parameters:
        name (string)
            The network message name to send
        data (function, optional)
            A function that prepares the network message: function(panel)

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Send network message
        button:NetMessage("liaButtonClick")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send network message with data
        panel:NetMessage("liaAction", function(pnl)
            net.WriteString("action_name")
        end)
        ```

    High Complexity:
        ```lua
        -- High: Send network message with complex data
        panel:NetMessage("liaComplexAction", function(pnl)
            net.WriteString(pnl.actionType)
            net.WriteEntity(pnl.target)
            net.WriteTable(pnl.data)
        end)
        ```
]]
function panelMeta:NetMessage(name, data)
    data = data or function() end
    self:On("DoClick", function()
        net.Start(name)
        data(self)
        net.SendToServer()
    end)
end

--[[
    Purpose:
        Docks the panel to its parent with optional margin

    When Called:
        When initializing a panel that should be docked to its parent

    Parameters:
        dock (number, optional)
            The dock direction (FILL, LEFT, TOP, RIGHT, BOTTOM). Defaults to FILL
        margin (number, optional)
            The margin size in pixels. Defaults to 0
        dontInvalidate (boolean, optional)
            If true, doesn't invalidate the parent layout

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Dock panel to fill
        panel:Stick()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Dock with margin
        panel:Stick(FILL, 5)
        ```

    High Complexity:
        ```lua
        -- High: Dock with custom settings
        panel:Stick(TOP, 10, true)
        ```
]]
function panelMeta:Stick(dock, margin, dontInvalidate)
    dock = dock or FILL
    margin = margin or 0
    self:Dock(dock)
    if margin > 0 then self:DockMargin(margin, margin, margin, margin) end
    if not dontInvalidate then self:InvalidateParent(true) end
end

--[[
    Purpose:
        Sets the panel height to a fraction of the target panel's height

    When Called:
        When initializing a panel that should be a fraction of another panel's height

    Parameters:
        frac (number, optional)
            The fraction to divide by. Defaults to 2 (half height)
        target (Panel, optional)
            The target panel to measure from. Defaults to parent panel

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set to half height of parent
        panel:DivTall()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set to third height
        panel:DivTall(3)
        ```

    High Complexity:
        ```lua
        -- High: Set to fraction of specific panel
        panel:DivTall(4, targetPanel)
        ```
]]
function panelMeta:DivTall(frac, target)
    frac = frac or 2
    target = target or self:GetParent()
    self:SetTall(target:GetTall() / frac)
end

--[[
    Purpose:
        Sets the panel width to a fraction of the target panel's width

    When Called:
        When initializing a panel that should be a fraction of another panel's width

    Parameters:
        frac (number, optional)
            The fraction to divide by. Defaults to 2 (half width)
        target (Panel, optional)
            The target panel to measure from. Defaults to parent panel

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set to half width of parent
        panel:DivWide()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set to third width
        panel:DivWide(3)
        ```

    High Complexity:
        ```lua
        -- High: Set to fraction of specific panel
        panel:DivWide(4, targetPanel)
        ```
]]
function panelMeta:DivWide(frac, target)
    target = target or self:GetParent()
    frac = frac or 2
    self:SetWide(target:GetWide() / frac)
end

--[[
    Purpose:
        Sets the panel width to match its height, making it square

    When Called:
        When initializing a panel that should be square based on height

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Make panel square from height
        panel:SquareFromHeight()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set height then make square
        panel:SetTall(64)
        panel:SquareFromHeight()
        ```

    High Complexity:
        ```lua
        -- High: Make square with calculated height
        panel:SetTall(ScrH() * 0.1)
        panel:SquareFromHeight()
        ```
]]
function panelMeta:SquareFromHeight()
    self:SetWide(self:GetTall())
end

--[[
    Purpose:
        Sets the panel height to match its width, making it square

    When Called:
        When initializing a panel that should be square based on width

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Make panel square from width
        panel:SquareFromWidth()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set width then make square
        panel:SetWide(64)
        panel:SquareFromWidth()
        ```

    High Complexity:
        ```lua
        -- High: Make square with calculated width
        panel:SetWide(ScrW() * 0.1)
        panel:SquareFromWidth()
        ```
]]
function panelMeta:SquareFromWidth()
    self:SetTall(self:GetWide())
end

--[[
    Purpose:
        Sets the panel to remove a target panel when clicked

    When Called:
        When initializing a panel that should remove another panel on click

    Parameters:
        target (Panel, optional)
            The panel to remove. Defaults to self

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Remove self on click
        button:SetRemove()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove parent on click
        button:SetRemove(parentPanel)
        ```

    High Complexity:
        ```lua
        -- High: Remove specific panel with validation
        if IsValid(targetPanel) then
            button:SetRemove(targetPanel)
        end
        ```
]]
function panelMeta:SetRemove(target)
    target = target or self
    self:On("DoClick", function() if IsValid(target) then target:Remove() end end)
end

--[[
    Purpose:
        Animates the panel to fade in from transparent

    When Called:
        When initializing a panel that should fade in on creation

    Parameters:
        time (number, optional)
            The fade in duration in seconds. Defaults to 0.2
        alpha (number, optional)
            The target alpha value. Defaults to 255

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Fade in panel
        panel:FadeIn()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Fade in with custom time
        panel:FadeIn(0.5)
        ```

    High Complexity:
        ```lua
        -- High: Fade in with custom time and alpha
        panel:FadeIn(0.3, 200)
        ```
]]
function panelMeta:FadeIn(time, alpha)
    time = time or 0.2
    alpha = alpha or 255
    self:SetAlpha(0)
    self:AlphaTo(alpha, time)
end

--[[
    Purpose:
        Hides the vertical scrollbar of a scrollable panel

    When Called:
        When initializing a scrollable panel that should hide its scrollbar

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Hide scrollbar
        scrollPanel:HideVBar()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hide scrollbar after setup
        local scroll = vgui.Create("DScrollPanel")
        scroll:HideVBar()
        ```

    High Complexity:
        ```lua
        -- High: Hide scrollbar with custom panel
        customScrollPanel:HideVBar()
        ```
]]
function panelMeta:HideVBar()
    local vbar = self:GetVBar()
    vbar:SetWide(0)
    vbar:Hide()
end

--[[
    Purpose:
        Sets a custom transition function for SetupTransition

    When Called:
        When setting up a panel that needs a custom transition condition

    Parameters:
        fn (function)
            The transition function: function(panel) returns boolean

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set transition function
        panel:SetTransitionFunc(function(s) return s:IsHovered() end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set transition with custom condition
        panel:SetTransitionFunc(function(s) return s.value > 0 end)
        ```

    High Complexity:
        ```lua
        -- High: Set transition with complex condition
        panel:SetTransitionFunc(function(s)
            return s:IsHovered() and s.enabled
        end)
        ```
]]
function panelMeta:SetTransitionFunc(fn)
    self.TransitionFunc = fn
end

--[[
    Purpose:
        Clears the custom transition function

    When Called:
        When removing a custom transition function from a panel

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Clear transition function
        panel:ClearTransitionFunc()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clear after disabling feature
        if not useTransitions then
            panel:ClearTransitionFunc()
        end
        ```

    High Complexity:
        ```lua
        -- High: Clear with state management
        panel:ClearTransitionFunc()
        panel.transitionEnabled = false
        ```
]]
function panelMeta:ClearTransitionFunc()
    self.TransitionFunc = nil
end

--[[
    Purpose:
        Sets a custom append overwrite function for the On method

    When Called:
        When setting up a panel that needs custom hook name modification

    Parameters:
        fn (string or function)
            The hook name to use instead of the default

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set append overwrite
        panel:SetAppendOverwrite("PaintOver")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set with conditional
        panel:SetAppendOverwrite(usePaintOver and "PaintOver" or "Paint")
        ```

    High Complexity:
        ```lua
        -- High: Set with dynamic name
        panel:SetAppendOverwrite(customHookName)
        ```
]]
function panelMeta:SetAppendOverwrite(fn)
    self.AppendOverwrite = fn
end

--[[
    Purpose:
        Clears the custom append overwrite function

    When Called:
        When removing a custom append overwrite from a panel

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Clear append overwrite
        panel:ClearAppendOverwrite()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clear after disabling feature
        if not useCustomHook then
            panel:ClearAppendOverwrite()
        end
        ```

    High Complexity:
        ```lua
        -- High: Clear with state management
        panel:ClearAppendOverwrite()
        panel.customHookEnabled = false
        ```
]]
function panelMeta:ClearAppendOverwrite()
    self.AppendOverwrite = nil
end

--[[
    Purpose:
        Removes the Paint function from the panel

    When Called:
        When initializing a panel that should not have custom painting

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Clear paint function
        panel:ClearPaint()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clear paint conditionally
        if not useCustomPaint then
            panel:ClearPaint()
        end
        ```

    High Complexity:
        ```lua
        -- High: Clear paint with state management
        panel:ClearPaint()
        panel.hasCustomPaint = false
        ```
]]
function panelMeta:ClearPaint()
    self.Paint = nil
end

--[[
    Purpose:
        Prepares a textbox panel with custom styling and transition setup

    When Called:
        When initializing a textbox that should have custom styling

    Parameters:
        None

    Returns:
        Nothing

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Prepare textbox
        textbox:ReadyTextbox()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Prepare textbox with setup
        local textbox = vgui.Create("DTextEntry")
        textbox:ReadyTextbox()
        ```

    High Complexity:
        ```lua
        -- High: Prepare textbox with full setup
        local textbox = vgui.Create("DTextEntry")
        textbox:SetSize(200, 30)
        textbox:ReadyTextbox()
        ```
]]
function panelMeta:ReadyTextbox()
    self:SetPaintBackground(false)
    self:SetAppendOverwrite("PaintOver"):SetTransitionFunc(function(s) return s:IsEditing() end)
end
