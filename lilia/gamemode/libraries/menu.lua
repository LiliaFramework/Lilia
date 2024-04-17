--[[--
Entity menu manipulation.

The `menu` library allows you to open up a context menu of arbitrary options whose callbacks will be ran when they are selected
from the panel that shows up for the player.
]]
-- @module lia.menu
lia.menu = lia.menu or {}
lia.menu.list = lia.menu.list or {}

--- Adds a menu with the provided options.
-- @param options Table containing the menu options
-- @param position Position of the menu (either a vector or an entity)
-- @param onRemove Callback function to execute when the menu is removed (optional)
-- @return The index of the added menu in the `lia.menu.list` table
-- @realm client
function lia.menu.add(options, position, onRemove)
    local width = 0
    local entity
    surface.SetFont("liaMediumFont")
    for k, _ in pairs(options) do
        width = math.max(width, surface.GetTextSize(tostring(k)))
    end

    if isentity(position) then
        entity = position
        position = entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
    end
    return table.insert(lia.menu.list, {
        position = position or LocalPlayer():GetEyeTrace().HitPos,
        options = options,
        width = width + 8,
        height = table.Count(options) * 28,
        entity = entity,
        onRemove = onRemove
    })
end

--- Draws all menus currently active on the screen.
-- @realm client
function lia.menu.drawAll()
    local frameTime = FrameTime() * 30
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = LocalPlayer():GetPos()
    for k, v in ipairs(lia.menu.list) do
        local position
        local entity = v.entity
        if entity then
            if IsValid(entity) then
                local realPos = entity:LocalToWorld(v.position)
                v.entPos = LerpVector(frameTime * 0.5, v.entPos or realPos, realPos)
                position = v.entPos:ToScreen()
            else
                table.remove(lia.menu.list, k)
                if v.onRemove then v:onRemove() end
                continue
            end
        else
            position = v.position:ToScreen()
        end

        local width, height = v.width, v.height
        local startX, startY = position.x - (width * 0.5), position.y
        local alpha = v.alpha or 0
        local inRange = position2:DistToSqr(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 9216
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange
        if not v.displayed or inside then
            v.alpha = math.Approach(alpha or 0, 255, frameTime * 25)
            if v.alpha == 255 then v.displayed = true end
        else
            v.alpha = math.Approach(alpha or 0, 0, inRange and frameTime or (frameTime * 45))
            if v.alpha == 0 then
                table.remove(lia.menu.list, k)
                if v.onRemove then v:onRemove() end
                continue
            end
        end

        local i = 0
        local x2, y2, w2, h2 = startX - 4, startY - 4, width + 8, height + 8
        alpha = v.alpha * 0.9
        surface.SetDrawColor(40, 40, 40, alpha)
        surface.DrawRect(x2, y2, w2, h2)
        surface.SetDrawColor(250, 250, 250, alpha * 0.025)
        surface.SetMaterial(Material("vgui/gradient-u"))
        surface.DrawTexturedRect(x2, y2, w2, h2)
        surface.SetDrawColor(0, 0, 0, alpha * 0.25)
        surface.DrawOutlinedRect(x2, y2, w2, h2)
        for k2, _ in SortedPairs(v.options) do
            local y = startY + (i * 28)
            if inside and mY >= y and mY <= (y + 28) then
                surface.SetDrawColor(ColorAlpha(lia.config.Color, v.alpha + math.cos(RealTime() * 8) * 40))
                surface.DrawRect(startX, y, width, 28)
            end

            lia.util.drawText(k2, startX + 4, y, ColorAlpha(color_white, v.alpha), nil, nil, "liaMediumFont")
            i = i + 1
        end
    end
end

-- Retrieves the index and the choice of the active menu, if any.
-- @return Index of the active menu in the `lia.menu.list` table, and the chosen option
-- @realm client
function lia.menu.getActiveMenu()
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = LocalPlayer():GetPos()
    for k, v in ipairs(lia.menu.list) do
        local position
        local entity = v.entity
        local width, height = v.width, v.height
        if entity then
            if IsValid(entity) then
                position = (v.entPos or entity:LocalToWorld(v.position)):ToScreen()
            else
                table.remove(lia.menu.list, k)
                continue
            end
        else
            position = v.position:ToScreen()
        end

        local startX, startY = position.x - (width * 0.5), position.y
        local inRange = position2:Distance(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 96
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange
        if inRange and inside then
            local choice
            local i = 0
            for _, v2 in SortedPairs(v.options) do
                local y = startY + (i * 28)
                if inside and mY >= y and mY <= (y + 28) then
                    choice = v2
                    break
                end

                i = i + 1
            end
            return k, choice
        end
    end
end
--- Executes a callback function when a menu button is pressed and removes the menu.
-- @param menu Index of the menu to remove
-- @param callback Callback function to execute
-- @return True if a callback was provided and executed, false otherwise
-- @realm client
function lia.menu.onButtonPressed(menu, callback)
    table.remove(lia.menu.list, menu)
    if callback then
        callback()
        return true
    end
    return false
end
