local PANEL = {}
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

local function buildActionFunc(action, actionIndex, itemTable, invID, sub)
    return function()
        itemTable.player = LocalPlayer()
        local send = true
        if action.onClick then send = action.onClick(itemTable, sub and sub.data) end
        local snd = action.sound or SOUND_INVENTORY_INTERACT
        if snd then
            if istable(snd) then
                LocalPlayer():EmitSound(unpack(snd))
            elseif isstring(snd) then
                surface.PlaySound(snd)
            end
        end

        if send ~= false then netstream.Start("invAct", actionIndex, itemTable.id, invID, sub and sub.data) end
        itemTable.player = nil
    end
end

function PANEL:openActionMenu()
    local itemTable = self.itemTable
    assert(itemTable, "attempt to open action menu for invalid item")
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

vgui.Register("liaItemIcon", PANEL, "SpawnIcon")