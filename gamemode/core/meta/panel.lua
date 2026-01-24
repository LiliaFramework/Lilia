--[[
    Folder: Meta
    File:  panel.md
]]
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
        Registers the panel to mirror inventory events to its methods.

    When Called:
        Use when a panel needs to react to changes in a specific inventory.

    Parameters:
        inventory (Inventory)
            Inventory instance whose events should be listened to.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:liaListenForInventoryChanges(inv)
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
        Removes inventory event hooks previously registered on the panel.

    When Called:
        Call when tearing down a panel or when an inventory is no longer tracked.

    Parameters:
        id (number|nil)
            Optional inventory ID to target; nil clears all known hooks.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:liaDeleteInventoryHooks(invID)
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
        Sets the panel position using screen-scaled coordinates.

    When Called:
        Use when positioning should respect different resolutions.

    Parameters:
        x (number)
            Horizontal position before scaling.
        y (number)
            Vertical position before scaling.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:setScaledPos(32, 48)
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
        Sets the panel size using screen-scaled dimensions.

    When Called:
        Use when sizing should scale with screen resolution.

    Parameters:
        w (number)
            Width before scaling.
        h (number)
            Height before scaling.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:setScaledSize(120, 36)
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

--[[
    Purpose:
        Appends an additional handler to a panel function without removing the existing one.

    When Called:
        Use to extend an existing panel callback (e.g., Paint, Think) while preserving prior logic.

    Parameters:
        name (string)
            Panel function name to wrap.
        fn (function)
            Function to run after the original callback.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:On("Paint", function(s, w, h) draw.RoundedBox(0, 0, 0, w, h, col) end)
        ```
]]
function panelMeta:On(name, fn)
    name = self.AppendOverwrite or name
    local old = self[name]
    self[name] = function(s, ...)
        if old then old(s, ...) end
        fn(s, ...)
    end
end

--[[
    Purpose:
        Creates a smoothly lerped state property driven by a predicate function.

    When Called:
        Use when a panel needs an animated transition flag (e.g., hover fades).

    Parameters:
        name (string)
            Property name to animate on the panel.
        speed (number)
            Lerp speed multiplier.
        fn (function)
            Predicate returning true when the property should approach 1.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SetupTransition("HoverAlpha", 6, function(s) return s:IsHovered() end)
        ```
]]
function panelMeta:SetupTransition(name, speed, fn)
    fn = self.TransitionFunc or fn
    self[name] = 0
    self:On("Think", function(s) s[name] = Lerp(FrameTime() * speed, s[name], fn(s) and 1 or 0) end)
end

--[[
    Purpose:
        Draws a faded overlay that brightens when the panel is hovered.

    When Called:
        Apply to panels that need a simple hover highlight.

    Parameters:
        col (Color)
            Overlay color and base alpha.
        speed (number)
            Transition speed toward hover state.
        rad (number|nil)
            Optional corner radius for rounded boxes.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:FadeHover(Color(255,255,255,40), 8, 4)
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
        Animates a horizontal bar under the panel while hovered.

    When Called:
        Use for button underlines or similar hover indicators.

    Parameters:
        col (Color)
            Bar color.
        height (number)
            Bar thickness in pixels.
        speed (number)
            Transition speed toward hover state.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:BarHover(Color(0,150,255), 2, 10)
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
        Fills the panel from one side while hovered, optionally using a material.

    When Called:
        Use when a directional hover fill effect is desired.

    Parameters:
        col (Color)
            Fill color.
        dir (number)
            Direction constant (LEFT, RIGHT, TOP, BOTTOM).
        speed (number)
            Transition speed toward hover state.
        mat (IMaterial|nil)
            Optional material to draw instead of a solid color.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:FillHover(Color(255,255,255,20), LEFT, 6)
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
        Paints a solid background for the panel with optional rounded corners.

    When Called:
        Use when a panel needs a consistent background fill.

    Parameters:
        col (Color)
            Fill color.
        rad (number|nil)
            Corner radius; nil or 0 draws a square rect.
        rtl/rtr/rbl/rbr (boolean|nil)
            Optional flags for which corners are rounded when using RoundedBoxEx.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Background(Color(20,20,20,230), 6)
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
        Draws a textured material across the panel.

    When Called:
        Use when a static material should cover the panel area.

    Parameters:
        mat (IMaterial)
            Material to render.
        col (Color)
            Color tint applied to the material.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Material(Material("vgui/gradient-l"), Color(255,255,255))
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
        Tiles a material over the panel at a fixed texture size.

    When Called:
        Use when repeating patterns should fill the panel.

    Parameters:
        mat (IMaterial)
            Material to tile.
        tw (number)
            Tile width in texture units.
        th (number)
            Tile height in texture units.
        col (Color)
            Color tint for the material.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:TiledMaterial(myMat, 64, 64, Color(255,255,255))
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
        Draws an outlined rectangle around the panel.

    When Called:
        Use to give a panel a simple border.

    Parameters:
        col (Color)
            Outline color.
        width (number)
            Border thickness in pixels.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Outline(Color(255,255,255), 2)
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
        Draws minimal corner lines on opposite corners of the panel.

    When Called:
        Use for a lightweight corner accent instead of a full border.

    Parameters:
        col (Color)
            Corner line color.
        cornerLen (number)
            Length of each corner arm in pixels.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:LinedCorners(Color(255,255,255), 12)
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
        Adds a solid strip to one side of the panel.

    When Called:
        Use for side indicators or separators on panels.

    Parameters:
        col (Color)
            Strip color.
        size (number)
            Strip thickness in pixels.
        side (number)
            Side constant (LEFT, RIGHT, TOP, BOTTOM).

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SideBlock(Color(0,140,255), 4, LEFT)
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
        Renders a single line of text within the panel or sets label properties directly.

    When Called:
        Use to quickly add centered or aligned text to a panel.

    Parameters:
        text (string)
            Text to display.
        font (string)
            Font name to use.
        col (Color)
            Text color.
        alignment (number)
            TEXT_ALIGN_* constant controlling horizontal alignment.
        ox/oy (number)
            Optional offsets applied to the draw position.
        paint (boolean)
            Force paint-based rendering even if label setters exist.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Text("Hello", "Trebuchet24", color_white, TEXT_ALIGN_CENTER)
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
        Draws two stacked text lines with independent styling.

    When Called:
        Use when a panel needs a title and subtitle aligned together.

    Parameters:
        toptext/bottomtext (string)
            Text to render on each line.
        topfont/bottomfont (string)
            Fonts for the respective lines.
        topcol/bottomcol (Color)
            Colors for the respective lines.
        alignment (number)
            TEXT_ALIGN_* horizontal alignment.
        centerSpacing (number)
            Offset to spread the two lines from the center point.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:DualText("Title", "Trebuchet24", lia.colors.primary, "Detail", "Trebuchet18", color_white)
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
        Draws a post-process blur behind the panel bounds.

    When Called:
        Use to blur the world/UI behind a panel while it is painted.

    Parameters:
        amount (number)
            Blur intensity multiplier.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Blur(8)
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
        Creates a ripple effect centered on the click position.

    When Called:
        Use for buttons that need animated click feedback.

    Parameters:
        col (Color)
            Ripple color and opacity.
        speed (number)
            Lerp speed for expansion and fade.
        trad (number|nil)
            Target radius override; defaults to panel width.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:CircleClick(Color(255,255,255,40), 5)
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
        Draws a circular highlight that follows the cursor while hovering.

    When Called:
        Use for hover feedback centered on the cursor position.

    Parameters:
        col (Color)
            Highlight color and base opacity.
        speed (number)
            Transition speed for appearing/disappearing.
        trad (number|nil)
            Target radius; defaults to panel width.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:CircleHover(Color(255,255,255,30), 6)
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
        Renders an animated square checkbox fill tied to the panel's checked state.

    When Called:
        Use on checkbox panels to visualize toggled state.

    Parameters:
        inner (Color)
            Color of the filled square.
        outer (Color)
            Color of the outline/background.
        speed (number)
            Transition speed for filling.

    Realm:
        Client

    Example Usage:
        ```lua
            checkbox:SquareCheckbox()
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
        Renders an animated circular checkbox tied to the panel's checked state.

    When Called:
        Use on checkbox panels that should appear circular.

    Parameters:
        inner (Color)
            Color of the inner filled circle.
        outer (Color)
            Outline color.
        speed (number)
            Transition speed for filling.

    Realm:
        Client

    Example Usage:
        ```lua
            checkbox:CircleCheckbox()
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
        Applies a stencil mask to an AvatarImage child using a custom shape.

    When Called:
        Use when an avatar needs to be clipped to a non-rectangular mask.

    Parameters:
        mask (function)
            Draw callback that defines the stencil shape.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:AvatarMask(function(_, w, h) drawCircle(w/2, h/2, w/2) end)
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
        Masks the panel's avatar as a circle.

    When Called:
        Use when a circular avatar presentation is desired.

    Parameters:
        None
            Uses a built-in circular mask.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:CircleAvatar()
        ```
]]
function panelMeta:CircleAvatar()
    self:AvatarMask(function(_, w, h) drawCircle(w / 2, h / 2, w / 2) end)
end

--[[
    Purpose:
        Paints a filled circle that fits the panel bounds.

    When Called:
        Use for circular panels or backgrounds.

    Parameters:
        col (Color)
            Circle color.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Circle(Color(255,255,255))
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
        Shows a fading circular overlay at the center while hovered.

    When Called:
        Use for subtle hover feedback on circular elements.

    Parameters:
        col (Color)
            Overlay color and base alpha.
        speed (number)
            Transition speed toward hover state.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:CircleFadeHover(Color(255,255,255,30), 6)
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
        Draws an expanding circle from the panel center while hovered.

    When Called:
        Use when a growing highlight is needed on hover.

    Parameters:
        col (Color)
            Circle color and alpha.
        speed (number)
            Transition speed toward hover state.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:CircleExpandHover(Color(255,255,255,30), 6)
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
        Draws a directional gradient over the panel.

    When Called:
        Use to overlay a gradient tint from a chosen side.

    Parameters:
        col (Color)
            Gradient color.
        dir (number)
            Direction constant (LEFT, RIGHT, TOP, BOTTOM).
        frac (number)
            Fraction of the panel to cover with the gradient.
        op (boolean)
            When true, flips the gradient material for the given direction.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Gradient(Color(0,0,0,180), BOTTOM, 0.4)
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
        Opens a URL when the panel is clicked.

    When Called:
        Attach to clickable panels that should launch an external link.

    Parameters:
        url (string)
            URL to open.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SetOpenURL("https://example.com")
        ```
]]
function panelMeta:SetOpenURL(url)
    self:On("DoClick", function() gui.OpenURL(url) end)
end

--[[
    Purpose:
        Sends a network message when the panel is clicked.

    When Called:
        Use for UI buttons that trigger server-side actions.

    Parameters:
        name (string)
            Net message name.
        data (function)
            Optional writer that populates the net message payload.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:NetMessage("liaAction", function(p) net.WriteEntity(p.Entity) end)
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
        Docks the panel with optional margin and parent invalidation.

    When Called:
        Use to pin a panel to a dock position with minimal boilerplate.

    Parameters:
        dock (number)
            DOCK constant to apply; defaults to FILL.
        margin (number)
            Optional uniform margin after docking.
        dontInvalidate (boolean)
            Skip invalidating the parent when true.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:Stick(LEFT, 8)
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
        Sets the panel height to a fraction of another panel's height.

    When Called:
        Use for proportional layout against a parent or target panel.

    Parameters:
        frac (number)
            Divisor applied to the target height.
        target (Panel)
            Panel to reference; defaults to the parent.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:DivTall(3, parentPanel)
        ```
]]
function panelMeta:DivTall(frac, target)
    frac = frac or 2
    target = target or self:GetParent()
    self:SetTall(target:GetTall() / frac)
end

--[[
    Purpose:
        Sets the panel width to a fraction of another panel's width.

    When Called:
        Use for proportional layout against a parent or target panel.

    Parameters:
        frac (number)
            Divisor applied to the target width.
        target (Panel)
            Panel to reference; defaults to the parent.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:DivWide(2, parentPanel)
        ```
]]
function panelMeta:DivWide(frac, target)
    target = target or self:GetParent()
    frac = frac or 2
    self:SetWide(target:GetWide() / frac)
end

--[[
    Purpose:
        Makes the panel width equal its current height.

    When Called:
        Use when the panel should become a square based on height.

    Parameters:
        None
            Uses the panel's current height.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SquareFromHeight()
        ```
]]
function panelMeta:SquareFromHeight()
    self:SetWide(self:GetTall())
end

--[[
    Purpose:
        Makes the panel height equal its current width.

    When Called:
        Use when the panel should become a square based on width.

    Parameters:
        None
            Uses the panel's current width.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SquareFromWidth()
        ```
]]
function panelMeta:SquareFromWidth()
    self:SetTall(self:GetWide())
end

--[[
    Purpose:
        Removes a target panel when this panel is clicked.

    When Called:
        Use for close buttons or dismiss actions.

    Parameters:
        target (Panel|nil)
            Panel to remove; defaults to the panel itself.

    Realm:
        Client

    Example Usage:
        ```lua
            closeButton:SetRemove(parentPanel)
        ```
]]
function panelMeta:SetRemove(target)
    target = target or self
    self:On("DoClick", function() if IsValid(target) then target:Remove() end end)
end

--[[
    Purpose:
        Fades the panel in from transparent to a target alpha.

    When Called:
        Use when showing a panel with a quick fade animation.

    Parameters:
        time (number)
            Duration of the fade in seconds.
        alpha (number)
            Target opacity after fading.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:FadeIn(0.2, 255)
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
        Hides and collapses the vertical scrollbar of a DScrollPanel.

    When Called:
        Use when the scrollbar should be invisible but scrolling remains enabled.

    Parameters:
        None
            Operates on the panel's VBar.

    Realm:
        Client

    Example Usage:
        ```lua
            scrollPanel:HideVBar()
        ```
]]
function panelMeta:HideVBar()
    local vbar = self:GetVBar()
    vbar:SetWide(0)
    vbar:Hide()
end

--[[
    Purpose:
        Sets a shared predicate used by transition helpers to determine state.

    When Called:
        Use before invoking helpers like SetupTransition to change their condition.

    Parameters:
        fn (function)
            Predicate returning true when the transition should be active.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SetTransitionFunc(function(s) return s:IsVisible() end)
        ```
]]
function panelMeta:SetTransitionFunc(fn)
    self.TransitionFunc = fn
end

--[[
    Purpose:
        Clears any predicate set for transition helpers.

    When Called:
        Use to revert transition helpers back to their default behavior.

    Parameters:
        None
            Resets the stored predicate.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:ClearTransitionFunc()
        ```
]]
function panelMeta:ClearTransitionFunc()
    self.TransitionFunc = nil
end

--[[
    Purpose:
        Overrides the target function name used by the On helper.

    When Called:
        Use when On should wrap a different function name than the provided one.

    Parameters:
        fn (string)
            Function name to force On to wrap.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:SetAppendOverwrite("PaintOver")
        ```
]]
function panelMeta:SetAppendOverwrite(fn)
    self.AppendOverwrite = fn
end

--[[
    Purpose:
        Removes any function name override set for the On helper.

    When Called:
        Use to return On to its default behavior.

    Parameters:
        None
            Clears the override.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:ClearAppendOverwrite()
        ```
]]
function panelMeta:ClearAppendOverwrite()
    self.AppendOverwrite = nil
end

--[[
    Purpose:
        Removes any custom Paint function on the panel.

    When Called:
        Use to revert a panel to its default painting behavior.

    Parameters:
        None
            Simply clears the Paint reference.

    Realm:
        Client

    Example Usage:
        ```lua
            panel:ClearPaint()
        ```
]]
function panelMeta:ClearPaint()
    self.Paint = nil
end

--[[
    Purpose:
        Prepares a text entry for Lilia styling by hiding its background and adding focus feedback.

    When Called:
        Use after creating a TextEntry to match framework visuals.

    Parameters:
        None
            Applies standard styling hooks.

    Realm:
        Client

    Example Usage:
        ```lua
            textEntry:ReadyTextbox()
        ```
]]
function panelMeta:ReadyTextbox()
    self:SetPaintBackground(false)
    self:SetAppendOverwrite("PaintOver"):SetTransitionFunc(function(s) return s:IsEditing() end)
end
