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
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, x, y)
end

function PANEL:getItem()
    return self.itemTable
end

function PANEL:Init()
    self:Droppable("inv")
    self:SetSize(64, 64)
end

function PANEL:PaintBehind(w, h)
    surface.SetDrawColor(0, 0, 0, 85)
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

local function buildActionFunc(action, actionIndex, itemTable, _, sub)
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
            net.Start("invAct")
            net.WriteString(actionIndex)
            net.WriteType(itemTable.id)
            net.WriteType(sub and sub.data)
            net.SendToServer()
        end

        itemTable.player = nil
    end
end

function PANEL:openActionMenu()
    local itemTable = self.itemTable
    assert(itemTable, L("invalidActionMenuItem"))
    itemTable.player = LocalPlayer()
    local menu = DermaMenu()
    if hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable) then
        if IsValid(menu) then menu:Remove() end
        return
    end

    for k, v in SortedPairs(itemTable.functions) do
        if hook.Run("CanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun) and not v.onCanRun(itemTable) then continue end
        if v.isMulti then
            local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), buildActionFunc(v, k, itemTable, self.invID))
            subMenuOption:SetImage(v.icon or "icon16/brick.png")
            local options = isfunction(v.multiOptions) and v.multiOptions(itemTable, LocalPlayer()) or v.multiOptions
            if not options then return end
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
    self:SetModel(item:getModel(), item:getSkin())
    self:updateTooltip()
    if item.icon then
        self.Icon:SetVisible(false)
        self.ExtraPaint = function(pnl, w, h) drawIcon(item.icon, pnl, w, h) end
    else
        renderNewIcon(self, item)
    end
end

function PANEL:updateTooltip()
    self:SetTooltip("<font=liaItemBoldFont>" .. self.itemTable:getName() .. "</font>\n" .. "<font=liaItemDescFont>" .. self.itemTable:getDesc())
end

function PANEL:ItemDataChanged()
    self:updateTooltip()
end

vgui.Register("liaItemIcon", PANEL, "SpawnIcon")