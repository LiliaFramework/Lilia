﻿lia.menu = lia.menu or {}
lia.menu.list = lia.menu.list or {}
--[[
   Function: lia.menu.add

   Description:
      Adds a new menu to the client's menu list.
      Calculates the menu width based on the provided options, determines the on-screen position (or converts an entity's position to a local position),
      and inserts the menu data into lia.menu.list.

   Parameters:
      options (table) - A table of menu options.
      position (vector or entity) - The position where the menu should appear, or an entity from which to derive the position.
      onRemove (function) - An optional callback to be executed when the menu is removed.

   Returns:
      nil

   Realm:
      Client
]]
function lia.menu.add(options, position, onRemove)
    local client = LocalPlayer()
    local width = 0
    local entity
    surface.SetFont("liaMediumFont")
    for k, _ in pairs(options) do
        width = math.max(width, surface.GetTextSize(tostring(k)))
    end

    if isentity(position) then
        entity = position
        position = entity:WorldToLocal(client:GetEyeTrace().HitPos)
    end
    return table.insert(lia.menu.list, {
        position = position or client:GetEyeTrace().HitPos,
        options = options,
        width = width + 8,
        height = table.Count(options) * 28,
        entity = entity,
        onRemove = onRemove
    })
end

local mathApproach = math.Approach
--[[
   Function: lia.menu.drawAll

   Description:
      Draws all active menus in lia.menu.list on the client's screen.
      It handles fading in/out effects, updates positions (especially for menus attached to entities),
      and renders both the background and the options with highlights for the option under the mouse cursor.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Client
]]
function lia.menu.drawAll()
    local client = LocalPlayer()
    local frameTime = FrameTime() * 30
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = client:GetPos()
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
        local startX, startY = position.x - width * 0.5, position.y
        local alpha = v.alpha or 0
        local inRange = position2:DistToSqr(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 9216
        local inside = mX >= startX and mX <= startX + width and mY >= startY and mY <= startY + height and inRange
        if not v.displayed or inside then
            v.alpha = mathApproach(alpha or 0, 255, frameTime * 25)
            if v.alpha == 255 then v.displayed = true end
        else
            v.alpha = mathApproach(alpha or 0, 0, inRange and frameTime or frameTime * 45)
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
            local y = startY + i * 28
            if inside and mY >= y and mY <= y + 28 then
                surface.SetDrawColor(ColorAlpha(lia.config.get("Color"), v.alpha + math.cos(RealTime() * 8) * 40))
                surface.DrawRect(startX, y, width, 28)
            end

            lia.util.drawText(k2, startX + 4, y, ColorAlpha(color_white, v.alpha), nil, nil, "liaMediumFont")
            i = i + 1
        end
    end
end

--[[
   Function: lia.menu.getActiveMenu

   Description:
      Determines the active menu based on the client's mouse position.
      Iterates through the menus in lia.menu.list and returns the index and the selected option of the menu
      if the mouse is hovering over it.

   Parameters:
      None

   Returns:
      number, any - The index of the active menu and the corresponding menu option; returns nil if no menu is active.

   Realm:
      Client
]]
function lia.menu.getActiveMenu()
    local client = LocalPlayer()
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = client:GetPos()
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

        local startX, startY = position.x - width * 0.5, position.y
        local inRange = position2:Distance(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 96
        local inside = mX >= startX and mX <= startX + width and mY >= startY and mY <= startY + height and inRange
        if inRange and inside then
            local choice
            local i = 0
            for _, v2 in SortedPairs(v.options) do
                local y = startY + i * 28
                if inside and mY >= y and mY <= y + 28 then
                    choice = v2
                    break
                end

                i = i + 1
            end
            return k, choice
        end
    end
end

--[[
   Function: lia.menu.onButtonPressed

   Description:
      Handles the action when a menu button is pressed.
      Removes the specified menu from lia.menu.list and executes an optional callback function.

   Parameters:
      menu (number) - The index of the menu to be removed.
      callback (function) - An optional function to execute after removal.

   Returns:
      boolean - Returns true if the callback was executed, false otherwise.

   Realm:
      Client
]]
function lia.menu.onButtonPressed(menu, callback)
    table.remove(lia.menu.list, menu)
    if callback then
        callback()
        return true
    end
    return false
end
