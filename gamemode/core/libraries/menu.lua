local menu = lia.menu or {}
lia.menu = menu
menu.list = menu.list or {}
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
    menu.add(opts, pos, onRemove)

    Description:
        Creates an on-screen interaction menu from a table of label/callback
        pairs. The menu can be anchored to a world position or entity and will
        call the optional onRemove callback when it disappears.

    Parameters:
        opts (table) – Key/value pairs where the key is the option text and the
        value is the function to execute when selected.
        pos (Vector or Entity) – World position of the menu or entity to attach
        it to.
        onRemove (function) – Called when the menu entry is removed (optional).

    Realm:
        Client

    Returns:
        number – The index of the newly inserted menu entry.
]]
function menu.add(opts, pos, onRemove)
    local client = LocalPlayer()
    local items, txtW = buildItems(opts)
    local ent
    if isEntity(pos) then
        ent = pos
        pos = ent:WorldToLocal(client:GetEyeTrace().HitPos)
    end
    return table_insert(menu.list, {
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
    menu.drawAll()

    Description:
        Draws all active menus and their options each frame. Menus fade in when
        looked at and fade out when the player looks away or moves out of range.

    Parameters:
        None

    Realm:
        Client

    Returns:
        nil
]]
function menu.drawAll()
    local client = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    local mx, my = sw * 0.5, sh * 0.5
    local pPos = client:GetPos()
    local ft = FrameTime() * 30
    for i = #menu.list, 1, -1 do
        local d = menu.list[i]
        local sp = getScreenPos(d, ft)
        if not sp then
            table_remove(menu.list, i)
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
                table_remove(menu.list, i)
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
    menu.getActiveMenu()

    Description:
        Checks if the player is hovering over a menu option within interaction
        range and returns the menu index and callback for that option.

    Parameters:
        None

    Realm:
        Client

    Returns:
        index (number) – The position of the active menu in the list.
        callback (function) – The function associated with the hovered option.
]]
function menu.getActiveMenu()
    local client = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    local mx, my = sw * 0.5, sh * 0.5
    local pPos = client:GetPos()
    for i = #menu.list, 1, -1 do
        local d = menu.list[i]
        local sp = getScreenPos(d, 0)
        if not sp then
            table_remove(menu.list, i)
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
    menu.onButtonPressed(id, cb)

    Description:
        Removes the menu at the given index and executes its callback if
        provided. Returns true when a callback was run.

    Parameters:
        id (number) – Index of the menu entry in the list.
        cb (function) – Callback to execute for the selected option.

    Realm:
        Client

    Returns:
        boolean – Whether a callback was invoked.
]]
function menu.onButtonPressed(id, cb)
    table_remove(menu.list, id)
    if cb then
        cb()
        return true
    end
    return false
end
