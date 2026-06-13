--[[
    Folder: Developer - Meta Tables
    File: panel.md
]]
--[[
    Panel

    Panel metatable helpers for inventory-aware UI behavior, layout, transitions, and drawing.
]]
--[[
    Overview:
        The panel meta table extends Garry's Mod VGUI panels with convenience helpers for inventory hook forwarding, scaled positioning and sizing, composable paint and hover effects, avatar masking, click behaviors, layout shortcuts, and transition-driven UI animation.
]]
local panelMeta = FindMetaTable("Panel")
local originalSetSize = panelMeta.SetSize
local originalSetPos = panelMeta.SetPos
--[[
    Purpose:
        Starts listening for inventory-related hooks and forwards matching events to this panel.

    Parameters:
        inventory (table)
            The inventory object whose events should be observed.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:liaListenForInventoryChanges(inventory)
        ```

    Realm:
        Client
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
        Removes inventory hooks that were previously registered for this panel.

    Parameters:
        id (number|nil)
            A specific inventory ID to stop listening to, or `nil` to remove all tracked inventory hooks.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:liaDeleteInventoryHooks()
        panel:liaDeleteInventoryHooks(inventory:getID())
        ```

    Realm:
        Client
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
        Sets the panel position using screen-scaled X and Y values.

    Parameters:
        x (number)
            The horizontal position before `ScreenScale` is applied.
        y (number)
            The vertical position before `ScreenScaleH` is applied.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:setScaledPos(32, 24)
        ```

    Realm:
        Client
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
        Sets the panel size using screen-scaled width and height values.

    Parameters:
        w (number)
            The width before `ScreenScale` is applied.
        h (number)
            The height before `ScreenScaleH` is applied.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:setScaledSize(300, 160)
        ```

    Realm:
        Client
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
        Appends a callback onto an existing panel method instead of replacing the method entirely.

    Parameters:
        name (string)
            The panel method name to wrap.
        fn (function)
            The callback to run after the original method.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:On("Paint", function(_, w, h)
            surface.DrawOutlinedRect(0, 0, w, h)
        end)
        ```

    Realm:
        Client
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
        Creates a transition value that smoothly lerps between `0` and `1` based on a predicate callback.

    Parameters:
        name (string)
            The field name that stores the transition value.
        speed (number)
            The interpolation speed multiplier.
        fn (function)
            A callback that returns whether the transition should move toward `1`.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:SetupTransition("HoverAmount", 8, function(s)
            return s:IsHovered()
        end)
        ```

    Realm:
        Client
]]
function panelMeta:SetupTransition(name, speed, fn)
    fn = self.TransitionFunc or fn
    self[name] = 0
    self:On("Think", function(s) s[name] = Lerp(FrameTime() * speed, s[name], fn(s) and 1 or 0) end)
end

--[[
    Purpose:
        Paints a fading hover overlay over the panel.

    Parameters:
        col (Color|nil)
            The hover overlay color.
        speed (number|nil)
            The hover fade speed.
        rad (number|nil)
            An optional rounded corner radius.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:FadeHover(Color(255, 255, 255, 20), 6, 8)
        ```

    Realm:
        Client
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
        Draws an animated bar along the bottom edge while the panel is hovered.

    Parameters:
        col (Color|nil)
            The bar color.
        height (number|nil)
            The bar thickness.
        speed (number|nil)
            The transition speed.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:BarHover(Color(0, 120, 255), 3, 8)
        ```

    Realm:
        Client
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
        Fills the panel from a chosen direction while it is hovered.

    Parameters:
        col (Color|nil)
            The fill color.
        dir (number|nil)
            The fill direction constant such as `LEFT` or `TOP`.
        speed (number|nil)
            The transition speed.
        mat (IMaterial|nil)
            An optional material to draw instead of a solid rectangle.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:FillHover(Color(255, 255, 255, 25), LEFT, 8)
        ```

    Realm:
        Client
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
        Draws a flat or rounded background in the panel paint hook.

    Parameters:
        col (Color)
            The background color.
        rad (number|nil)
            The rounded corner radius.
        rtl (boolean|nil)
            Whether the top-left corner is rounded when using `draw.RoundedBoxEx`.
        rtr (boolean|nil)
            Whether the top-right corner is rounded.
        rbl (boolean|nil)
            Whether the bottom-left corner is rounded.
        rbr (boolean|nil)
            Whether the bottom-right corner is rounded.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Background(Color(20, 20, 20, 220), 8)
        ```

    Realm:
        Client
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
        Paints a material stretched across the panel.

    Parameters:
        mat (IMaterial)
            The material to draw.
        col (Color|nil)
            A tint color applied to the material.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Material(Material("vgui/white"), Color(255, 255, 255))
        ```

    Realm:
        Client
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
        Paints a tiled material across the panel using UV scaling.

    Parameters:
        mat (IMaterial)
            The material to tile.
        tw (number)
            The horizontal tile size.
        th (number)
            The vertical tile size.
        col (Color|nil)
            A tint color applied to the tiled material.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:TiledMaterial(Material("vgui/white"), 32, 32)
        ```

    Realm:
        Client
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
        Draws an outline around the panel with configurable thickness.

    Parameters:
        col (Color|nil)
            The outline color.
        width (number|nil)
            The outline thickness in pixels.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Outline(Color(255, 255, 255), 2)
        ```

    Realm:
        Client
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
        Draws simple line corners around the panel frame.

    Parameters:
        col (Color|nil)
            The corner line color.
        cornerLen (number|nil)
            The length of each corner segment.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:LinedCorners(Color(255, 255, 255), 12)
        ```

    Realm:
        Client
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
        Draws a solid accent block on one side of the panel.

    Parameters:
        col (Color|nil)
            The block color.
        size (number|nil)
            The thickness of the block.
        side (number|nil)
            The side constant such as `LEFT` or `BOTTOM`.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:SideBlock(Color(0, 127, 255), 4, LEFT)
        ```

    Realm:
        Client
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
        Sets built-in control text or paints centered text manually.

    Parameters:
        text (string)
            The text to display.
        font (string|nil)
            The font name to use.
        col (Color|nil)
            The text color.
        alignment (number|nil)
            The horizontal text alignment constant.
        ox (number|nil)
            Horizontal paint offset.
        oy (number|nil)
            Vertical paint offset.
        paint (boolean|nil)
            Whether to force manual painting even when native text setters exist.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Text("Confirm", "Trebuchet24", color_white)
        ```

    Realm:
        Client
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
        Paints two stacked text lines with independent fonts and colors.

    Parameters:
        toptext (string)
            The upper text line.
        topfont (string|nil)
            The upper line font.
        topcol (Color|nil)
            The upper line color.
        bottomtext (string)
            The lower text line.
        bottomfont (string|nil)
            The lower line font.
        bottomcol (Color|nil)
            The lower line color.
        alignment (number|nil)
            The horizontal text alignment.
        centerSpacing (number|nil)
            Extra spacing adjustment around the center.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:DualText("Lilia", "Trebuchet24", color_white, "Inventory", "Trebuchet18", Color(180, 180, 180))
        ```

    Realm:
        Client
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
        Draws a blurred fullscreen backdrop behind the panel bounds.

    Parameters:
        amount (number|nil)
            The maximum blur strength.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Blur(8)
        ```

    Realm:
        Client
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
        Plays an expanding circular ripple from the click position.

    Parameters:
        col (Color|nil)
            The ripple color.
        speed (number|nil)
            The expansion and fade speed.
        trad (number|nil)
            The target radius for the ripple.

    Returns:
        nil

    Example Usage:
        ```lua
        button:CircleClick(Color(255, 255, 255, 40), 5)
        ```

    Realm:
        Client
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
        Draws a circular hover effect that follows the cursor.

    Parameters:
        col (Color|nil)
            The hover effect color.
        speed (number|nil)
            The transition speed.
        trad (number|nil)
            The target hover radius.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:CircleHover(Color(255, 255, 255, 20), 6)
        ```

    Realm:
        Client
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
        Paints an animated square checkbox fill based on checked state.

    Parameters:
        inner (Color|nil)
            The fill color used when checked.
        outer (Color|nil)
            The outer frame color.
        speed (number|nil)
            The transition speed.

    Returns:
        nil

    Example Usage:
        ```lua
        checkbox:SquareCheckbox(Color(0, 200, 0), color_white, 14)
        ```

    Realm:
        Client
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
        Paints an animated circular checkbox fill based on checked state.

    Parameters:
        inner (Color|nil)
            The fill color used when checked.
        outer (Color|nil)
            The outer frame color.
        speed (number|nil)
            The transition speed.

    Returns:
        nil

    Example Usage:
        ```lua
        checkbox:CircleCheckbox(Color(0, 200, 0), color_white, 14)
        ```

    Realm:
        Client
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
        Masks an embedded `AvatarImage` using a custom stencil shape callback.

    Parameters:
        mask (function)
            A drawing callback that defines the stencil mask shape.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:AvatarMask(function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, color_white)
        end)
        ```

    Realm:
        Client
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
        Applies a circular stencil mask to the panel avatar.

    Returns:
        nil

    Example Usage:
        ```lua
        avatarPanel:CircleAvatar()
        ```

    Realm:
        Client
]]
function panelMeta:CircleAvatar()
    self:AvatarMask(function(_, w, h) drawCircle(w / 2, h / 2, w / 2) end)
end

--[[
    Purpose:
        Draws a filled circle that fits inside the panel.

    Parameters:
        col (Color|nil)
            The circle color.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Circle(Color(255, 255, 255))
        ```

    Realm:
        Client
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
        Draws a circular hover overlay that fades in and out.

    Parameters:
        col (Color|nil)
            The overlay color.
        speed (number|nil)
            The transition speed.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:CircleFadeHover(Color(255, 255, 255, 20), 6)
        ```

    Realm:
        Client
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
        Draws a circular hover overlay that expands with hover progress.

    Parameters:
        col (Color|nil)
            The overlay color.
        speed (number|nil)
            The transition speed.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:CircleExpandHover(Color(255, 255, 255, 20), 6)
        ```

    Realm:
        Client
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
        Draws a directional gradient overlay with optional inversion.

    Parameters:
        col (Color)
            The gradient tint color.
        dir (number|nil)
            The gradient direction constant.
        frac (number|nil)
            The fraction of the panel covered by the gradient.
        op (boolean|nil)
            Whether to invert the gradient material direction.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Gradient(Color(0, 0, 0, 180), BOTTOM, 1)
        ```

    Realm:
        Client
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
        Opens the provided URL when the panel is clicked.

    Parameters:
        url (string)
            The URL to open in the user's browser.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:SetOpenURL("https://example.com")
        ```

    Realm:
        Client
]]
function panelMeta:SetOpenURL(url)
    self:On("DoClick", function() gui.OpenURL(url) end)
end

--[[
    Purpose:
        Sends a client-to-server net message when the panel is clicked.

    Parameters:
        name (string)
            The net message name.
        data (function|nil)
            A callback that writes additional payload data into the net message.

    Returns:
        nil

    Example Usage:
        ```lua
        button:NetMessage("liaRequestAction", function()
            net.WriteUInt(1, 8)
        end)
        ```

    Realm:
        Client
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
        Docks the panel with optional uniform margin and parent invalidation.

    Parameters:
        dock (number|nil)
            The docking mode such as `FILL` or `TOP`.
        margin (number|nil)
            A uniform dock margin.
        dontInvalidate (boolean|nil)
            Whether to skip invalidating the parent layout.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:Stick(TOP, 4)
        ```

    Realm:
        Client
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
        Sets the panel height to a fraction of a target panel's height.

    Parameters:
        frac (number|nil)
            The divisor used for the target height.
        target (Panel|nil)
            The panel whose height is used as the source measurement.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:DivTall(3, parent)
        ```

    Realm:
        Client
]]
function panelMeta:DivTall(frac, target)
    frac = frac or 2
    target = target or self:GetParent()
    self:SetTall(target:GetTall() / frac)
end

--[[
    Purpose:
        Sets the panel width to a fraction of a target panel's width.

    Parameters:
        frac (number|nil)
            The divisor used for the target width.
        target (Panel|nil)
            The panel whose width is used as the source measurement.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:DivWide(2, parent)
        ```

    Realm:
        Client
]]
function panelMeta:DivWide(frac, target)
    target = target or self:GetParent()
    frac = frac or 2
    self:SetWide(target:GetWide() / frac)
end

--[[
    Purpose:
        Makes the panel square by matching its width to its current height.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:SquareFromHeight()
        ```

    Realm:
        Client
]]
function panelMeta:SquareFromHeight()
    self:SetWide(self:GetTall())
end

--[[
    Purpose:
        Makes the panel square by matching its height to its current width.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:SquareFromWidth()
        ```

    Realm:
        Client
]]
function panelMeta:SquareFromWidth()
    self:SetTall(self:GetWide())
end

--[[
    Purpose:
        Removes a target panel when this panel is clicked.

    Parameters:
        target (Panel|nil)
            The panel to remove, or this panel when omitted.

    Returns:
        nil

    Example Usage:
        ```lua
        closeButton:SetRemove(frame)
        ```

    Realm:
        Client
]]
function panelMeta:SetRemove(target)
    target = target or self
    self:On("DoClick", function() if IsValid(target) then target:Remove() end end)
end

--[[
    Purpose:
        Fades the panel in from alpha `0` to a target opacity.

    Parameters:
        time (number|nil)
            The fade duration in seconds.
        alpha (number|nil)
            The target alpha value.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:FadeIn(0.25, 255)
        ```

    Realm:
        Client
]]
function panelMeta:FadeIn(time, alpha)
    time = time or 0.2
    alpha = alpha or 255
    self:SetAlpha(0)
    self:AlphaTo(alpha, time)
end

--[[
    Purpose:
        Hides and collapses a scroll panel's vertical scrollbar.

    Returns:
        nil

    Example Usage:
        ```lua
        scrollPanel:HideVBar()
        ```

    Realm:
        Client
]]
function panelMeta:HideVBar()
    local vbar = self:GetVBar()
    vbar:SetWide(0)
    vbar:Hide()
end

--[[
    Purpose:
        Sets the default predicate used by transition helpers.

    Parameters:
        fn (function)
            The predicate callback used by `SetupTransition`.

    Returns:
        Panel
            The current panel for chaining.

    Example Usage:
        ```lua
        panel:SetTransitionFunc(function(s) return s:IsHovered() end)
        ```

    Realm:
        Client
]]
function panelMeta:SetTransitionFunc(fn)
    self.TransitionFunc = fn
    return self
end

--[[
    Purpose:
        Clears the default predicate override used by transition helpers.

    Returns:
        Panel
            The current panel for chaining.

    Example Usage:
        ```lua
        panel:ClearTransitionFunc()
        ```

    Realm:
        Client
]]
function panelMeta:ClearTransitionFunc()
    self.TransitionFunc = nil
    return self
end

--[[
    Purpose:
        Overrides which panel method `On` appends to.

    Parameters:
        fn (string)
            The method name that `On` should use until cleared.

    Returns:
        Panel
            The current panel for chaining.

    Example Usage:
        ```lua
        panel:SetAppendOverwrite("PaintOver")
        ```

    Realm:
        Client
]]
function panelMeta:SetAppendOverwrite(fn)
    self.AppendOverwrite = fn
    return self
end

--[[
    Purpose:
        Clears the temporary method override used by `On`.

    Returns:
        Panel
            The current panel for chaining.

    Example Usage:
        ```lua
        panel:ClearAppendOverwrite()
        ```

    Realm:
        Client
]]
function panelMeta:ClearAppendOverwrite()
    self.AppendOverwrite = nil
    return self
end

--[[
    Purpose:
        Removes the panel `Paint` function.

    Returns:
        nil

    Example Usage:
        ```lua
        panel:ClearPaint()
        ```

    Realm:
        Client
]]
function panelMeta:ClearPaint()
    self.Paint = nil
end

--[[
    Purpose:
        Prepares a textbox for paint-over transitions while editing.

    Returns:
        nil

    Example Usage:
        ```lua
        textEntry:ReadyTextbox()
        ```

    Realm:
        Client
]]
function panelMeta:ReadyTextbox()
    self:SetPaintBackground(false)
    self:SetAppendOverwrite("PaintOver"):SetTransitionFunc(function(s) return s:IsEditing() end)
end
