local PANEL = {}
local renderedIcons = {}
local function renderNewIcon(panel, itemTable)
    if itemTable.iconCam and (not renderedIcons[string.lower(itemTable.model)] or itemTable.forceRender) then
        local iconCam = itemTable.iconCam
        iconCam = {
            cam_pos = iconCam.pos,
            cam_ang = iconCam.ang,
            cam_fov = iconCam.fov
        }

        renderedIcons[string.lower(itemTable.model)] = true
        panel.Icon:RebuildSpawnIconEx(iconCam)
        itemTable.forceRender = nil
    end
end

local function drawIcon(mat, _, x, y)
    surface.SetDrawColor(color_white)
    if isstring(mat) then mat = Material(mat) end
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, x, y)
end

function PANEL:getItem()
    return self.itemTable
end

--[[
    Hooks:
        ItemPaintOver(Panel panel, Item|nil itemTable, number w, number h)

    Purpose:
        Runs after an item icon panel finishes its normal paint pass so modules can draw extra overlays.

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The item icon panel being painted.

        itemTable (Item|nil)
            The item instance assigned to the panel, when available.

        w (number)
            The width of the item panel.

        h (number)
            The height of the item panel.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("ItemPaintOver", "liaExampleItemPaintOver", function(panel, itemTable, w, h)
            if itemTable and itemTable:getData("favorite") then
                draw.SimpleText("*", "DermaDefaultBold", w - 8, 4, color_white, TEXT_ALIGN_RIGHT)
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        OnCreateItemInteractionMenu(Panel panel, Panel menu, Item itemTable)

    Purpose:
        Runs before the default item interaction options are added so modules can customize or replace the context menu.

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The item icon panel that opened the menu.

        menu (Panel)
            The newly created derma menu instance.

        itemTable (Item)
            The item whose interaction menu is being built.

    Returns:
        boolean|nil
            Return true to stop the default menu population. Returning nil allows the standard item actions to be added.

    Example Usage:
        ```lua
        hook.Add("OnCreateItemInteractionMenu", "liaExampleOnCreateItemInteractionMenu", function(panel, menu, itemTable)
            if itemTable.uniqueID == "badge" then
                menu:AddOption("Inspect Badge", function() print(itemTable:getName()) end)
                return true
            end
        end)
        ```

    Realm:
        Client
]]
function PANEL:Init()
    self:Droppable("inv")
    self:SetSize(64, 64)
end

function PANEL:PaintBehind(w, h)
    surface.SetDrawColor(lia.color.theme.window_shadow or Color(0, 0, 0, 85))
    surface.DrawRect(2, 2, w - 4, h - 4)
end

function PANEL:ExtraPaint()
end

function PANEL:Paint(w, h)
    self:PaintBehind(w, h)
    self:ExtraPaint(w, h)
end

function PANEL:PaintOver(w, h)
    local itemTable = lia.item.instances[self.itemID]
    if itemTable and itemTable.paintOver then
        w, h = self:GetSize()
        itemTable.paintOver(self, itemTable, w, h)
    end

    hook.Run("ItemPaintOver", self, itemTable, w, h)
end

local function buildActionFunc(action, actionIndex, itemTable, sub, optionKey)
    return function()
        itemTable.player = LocalPlayer()
        local send = true
        if action.onClick then send = action.onClick(itemTable, sub and sub.data) end
        local snd = action.sound
        if snd then
            if istable(snd) then
                LocalPlayer():EmitSound(unpack(snd))
            elseif isstring(snd) then
                surface.PlaySound(snd)
            end
        end

        if send ~= false then
            net.Start("liaInvAct")
            net.WriteString(actionIndex)
            net.WriteType(itemTable.id)
            net.WriteType(optionKey or sub and sub.data)
            net.SendToServer()
        end

        itemTable.player = nil
    end
end

function PANEL:openActionMenu()
    local itemTable = self.itemTable
    assert(itemTable, L("invalidActionMenuItem"))
    itemTable.player = LocalPlayer()
    local menu = lia.derma.dermaMenu()
    if hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable) then
        if IsValid(menu) then menu:Remove() end
        return
    end

    for k, v in SortedPairs(itemTable.functions) do
        if hook.Run("CanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun) and not v.onCanRun(itemTable) then continue end
        local isMulti = v.isMulti or (v.multiOptions and (istable(v.multiOptions) or isfunction(v.multiOptions)))
        if isMulti then
            local subMenu = menu:AddSubMenu(L(v.name or k), buildActionFunc(v, k, itemTable), v.icon or "icon16/brick.png")
            local options = v.multiOptions
            if isfunction(options) then options = options(itemTable, LocalPlayer()) end
            if not options then return end
            for optionKey, optionFunc in pairs(options) do
                if isfunction(optionFunc) then
                    local subOption = {
                        name = optionKey,
                        onRun = optionFunc
                    }

                    subMenu:AddOption(L(optionKey), buildActionFunc(v, k, itemTable, subOption, optionKey), "icon16/brick.png")
                elseif istable(optionFunc) then
                    if isfunction(optionFunc[2]) and not optionFunc[2](itemTable, LocalPlayer()) then continue end
                    local subOption = {
                        name = optionFunc.name or optionKey,
                        onRun = optionFunc[1] or optionFunc.onRun,
                        icon = optionFunc.icon
                    }

                    subMenu:AddOption(L(subOption.name), buildActionFunc(v, k, itemTable, subOption, optionKey), subOption.icon or "icon16/brick.png")
                else
                    subMenu:AddOption(L(optionFunc.name or "subOption"), buildActionFunc(v, k, itemTable, optionFunc), optionFunc.icon or "icon16/brick.png")
                end
            end
        else
            menu:AddOption(L(v.name or k), buildActionFunc(v, k, itemTable), v.icon or "icon16/brick.png")
        end
    end

    menu:Open()
    itemTable.player = nil
end

function PANEL:setItemType(itemTypeOrID)
    local item = lia.item.list[itemTypeOrID]
    if isnumber(itemTypeOrID) then
        item = lia.item.instances[itemTypeOrID]
        self.itemID = itemTypeOrID
    else
        self.itemType = itemTypeOrID
    end

    assert(item, L("invalidItemTypeOrID", item and item.name or itemTypeOrID))
    self.liaToolTip = true
    self.itemTable = item
    self:SetModel(item:getModel())
    local paintMat = hook.Run("PaintItem", item)
    local entity
    if self.Icon and self.Icon.GetEntity then
        entity = self.Icon:GetEntity()
    elseif self.GetEntity then
        entity = self:GetEntity()
    end

    if IsValid(entity) then
        local skin = item:getSkin()
        if skin and isnumber(skin) then entity:SetSkin(skin) end
        local bodygroups = item:getBodygroups()
        if bodygroups and istable(bodygroups) then lia.util.applyBodygroups(entity, bodygroups) end
        if isstring(paintMat) and paintMat ~= "" then
            entity:SetMaterial(paintMat)
        elseif isstring(item.material) and item.material ~= "" then
            entity:SetMaterial(item.material)
        else
            entity:SetMaterial("")
        end

        if skin or (bodygroups and next(bodygroups)) then item.forceRender = true end
    end

    self:updateTooltip()
    local itemIcon = item.icon
    if itemIcon then
        self.Icon:SetVisible(false)
        self.ExtraPaint = function(pnl, w, h) drawIcon(itemIcon, pnl, w, h) end
    else
        renderNewIcon(self, item)
        if self.Icon and self.Icon.UpdateVisuals then
            self.Icon.ItemTable = item
            self.Icon:UpdateVisuals()
        end
    end
end

function PANEL:updateTooltip()
    local lines = {}
    lines[#lines + 1] = "<font=LiliaFont.16b>" .. self.itemTable:getName() .. "</font>"
    local rarity = self.itemTable:getData("rarity") or self.itemTable.rarity
    if rarity and rarity ~= "" then
        local rarityText = rarity
        local rarityColors = lia.item and lia.item.rarities
        local rarityColor = rarityColors and rarityColors[rarity]
        if rarityColor then rarityText = Format("<color=%s, %s, %s>%s</color>", rarityColor.r, rarityColor.g, rarityColor.b, rarity) end
        lines[#lines + 1] = "<font=LiliaFont.16>" .. rarityText .. "</font>"
    end

    lines[#lines + 1] = "<font=LiliaFont.16>" .. self.itemTable:getDesc() .. "</font>"
    self:SetTooltip(table.concat(lines, "\n"))
end

function PANEL:ItemDataChanged()
    self:updateTooltip()
    if self.Icon and self.Icon.UpdateVisuals then self.Icon:UpdateVisuals() end
end

vgui.Register("liaItemIcon", PANEL, "SpawnIcon")
