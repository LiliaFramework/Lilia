--------------------------------------------------------------------------------------------------------
renderedIcons = renderedIcons or {}
--------------------------------------------------------------------------------------------------------
function renderNewIcon(panel, itemTable)
    if (itemTable.iconCam and not renderedIcons[string.lower(itemTable.model)]) or itemTable.forceRender then
        local iconCam = itemTable.iconCam

        iconCam = {
            cam_pos = iconCam.pos,
            cam_ang = iconCam.ang,
            cam_fov = iconCam.fov,
        }

        renderedIcons[string.lower(itemTable.model)] = true
        panel.Icon:RebuildSpawnIconEx(iconCam)
    end
end
--------------------------------------------------------------------------------------------------------
local function drawIcon(mat, self, x, y)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, x, y)
end
--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:setItemType(itemTypeOrID)
    local item = lia.item.list[itemTypeOrID]

    if isnumber(itemTypeOrID) then
        item = lia.item.instances[itemTypeOrID]
        self.itemID = itemTypeOrID
    else
        self.itemType = itemTypeOrID
    end

    assert(item, "invalid item type or ID " .. tostring(item))
    self.liaToolTip = true
    self.itemTable = item
    self:SetModel(item:getModel(), item:getSkin())
    self:updateTooltip()

    if item.exRender then
        self.Icon:SetVisible(false)

        self.ExtraPaint = function(self, x, y)
            local paintFunc = item.paintIcon

            if paintFunc and type(paintFunc) == "function" then
                paintFunc(item, self)
            else
                local exIcon = ikon:getIcon(item.uniqueID)

                if exIcon then
                    surface.SetMaterial(exIcon)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(0, 0, x, y)
                else
                    ikon:renderIcon(item.uniqueID, item.width, item.height, item.model, item.iconCam)
                end
            end
        end
    elseif item.icon then
        self.Icon:SetVisible(false)

        self.ExtraPaint = function(self, w, h)
            drawIcon(item.icon, self, w, h)
        end
    else
        renderNewIcon(self, item)
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:updateTooltip()
    self:SetTooltip("<font=liaItemBoldFont>" .. self.itemTable:getName() .. "</font>\n" .. "<font=liaItemDescFont>" .. self.itemTable:getDesc())
end
--------------------------------------------------------------------------------------------------------
function PANEL:getItem()
    return self.itemTable
end
--------------------------------------------------------------------------------------------------------
function PANEL:ItemDataChanged(key, oldValue, newValue)
    self:updateTooltip()
end
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:Droppable("inv")
    self:SetSize(64, 64)
end
--------------------------------------------------------------------------------------------------------
function PANEL:PaintOver(w, h)
    local itemTable = lia.item.instances[self.itemID]

    if itemTable and itemTable.paintOver then
        local w, h = self:GetSize()
        itemTable.paintOver(self, itemTable, w, h)
    end

    hook.Run("ItemPaintOver", self, itemTable, w, h)
end
--------------------------------------------------------------------------------------------------------
function PANEL:PaintBehind(w, h)
    surface.SetDrawColor(0, 0, 0, 85)
    surface.DrawRect(2, 2, w - 4, h - 4)
end
--------------------------------------------------------------------------------------------------------
function PANEL:ExtraPaint(w, h)
end
--------------------------------------------------------------------------------------------------------
function PANEL:Paint(w, h)
    self:PaintBehind(w, h)
    self:ExtraPaint(w, h)
end
--------------------------------------------------------------------------------------------------------
local buildActionFunc = function(action, actionIndex, itemTable, invID, sub)
    return function()
        itemTable.player = LocalPlayer()
        local send = true

        if action.onClick then
            send = action.onClick(itemTable, sub and sub.data)
        end

        local snd = action.sound or SOUND_INVENTORY_INTERACT

        if snd then
            if istable(snd) then
                LocalPlayer():EmitSound(unpack(snd))
            elseif isstring(snd) then
                surface.PlaySound(snd)
            end
        end

        if send ~= false then
            netstream.Start("invAct", actionIndex, itemTable.id, invID, sub and sub.data)
        end

        itemTable.player = nil
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:openActionMenu()
    local itemTable = self.itemTable
    assert(itemTable, "attempt to open action menu for invalid item")
    itemTable.player = LocalPlayer()
    local menu = DermaMenu()
    local override = hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable)

    if override then
        if IsValid(menu) then
            menu:Remove()
        end

        return
    end

    for k, v in SortedPairs(itemTable.functions) do
        if hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun) and not v.onCanRun(itemTable) then continue end

        if v.isMulti then
            local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), buildActionFunc(v, k, itemTable, self.invID))
            subMenuOption:SetImage(v.icon or "icon16/brick.png")
            if not v.multiOptions then return end
            local options = isfunction(v.multiOptions) and v.multiOptions(itemTable, LocalPlayer()) or v.multiOptions

            for _, sub in pairs(options) do
                subMenu:AddOption(L(sub.name or "subOption"), buildActionFunc(v, k, itemTable, self.invID, sub)):SetImage(sub.icon or "icon16/brick.png")
            end
        else
            menu:AddOption(L(v.name or k), buildActionFunc(v, k, itemTable, self.invID)):SetImage(v.icon or "icon16/brick.png")
        end
    end

    menu:Open()
    itemTable.player = nil
end
--------------------------------------------------------------------------------------------------------
vgui.Register("liaItemIcon", PANEL, "SpawnIcon")
--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:MakePopup()
    self:Center()
    self:ShowCloseButton(false)
    self:SetDraggable(true)
    self:SetTitle(L"inv")
end
--------------------------------------------------------------------------------------------------------
function PANEL:setInventory(inventory)
    self.inventory = inventory
    self:liaListenForInventoryChanges(inventory)
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryInitialized()
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryDataChanged(key, oldValue, newValue)
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryDeleted(inventory)
    if self.inventory == inventory then
        self:Remove()
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryItemAdded(item)
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryItemRemoved(item)
end
--------------------------------------------------------------------------------------------------------
function PANEL:InventoryItemDataChanged(item, key, oldValue, newValue)
end
--------------------------------------------------------------------------------------------------------
function PANEL:OnRemove()
    self:liaDeleteInventoryHooks()
end
--------------------------------------------------------------------------------------------------------
vgui.Register("liaInventory", PANEL, "DFrame")