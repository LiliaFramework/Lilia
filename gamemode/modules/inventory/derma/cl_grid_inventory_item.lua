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

function PANEL:Init()
    self.size = 64
end

function PANEL:setIconSize(size)
    self.size = size
end

function PANEL:setItem(item)
    self.Icon:SetSize(self.size * item:getWidth(), self.size * item:getHeight())
    self.Icon:InvalidateLayout(true)
    self:setItemType(item:getID())
    self:centerIcon()
end

local function drawIcon(mat, _, w, h)
    local m = isstring(mat) and Material(mat) or mat
    surface.SetDrawColor(color_white)
    surface.SetMaterial(m)
    surface.DrawTexturedRect(0, 0, w, h)
end

function PANEL:setItemType(itemTypeOrID)
    local item = lia.item.list[itemTypeOrID]
    if isnumber(itemTypeOrID) then
        item = lia.item.instances[itemTypeOrID]
        self.itemID = itemTypeOrID
    else
        self.itemType = itemTypeOrID
    end

    assert(item, L("invalidItemTypeOrID", tostring(item)))
    self.liaToolTip = true
    self.itemTable = item
    self:SetModel(item:getModel(), item:getSkin())
    self:updateTooltip()
    if item.icon then
        self.Icon:SetVisible(false)
        self.ExtraPaint = function(_, w, h) drawIcon(item.icon, self, w, h) end
    else
        renderNewIcon(self, item)
    end
end

function PANEL:updateTooltip()
    self:SetTooltip("<font=liaItemBoldFont>" .. self.itemTable:getName() .. "</font>\n<font=liaItemDescFont>" .. self.itemTable:getDesc())
end

function PANEL:ItemDataChanged()
    self:updateTooltip()
end

function PANEL:centerIcon(w, h)
    w = w or self:GetWide()
    h = h or self:GetTall()
    local iconW, iconH = self.Icon:GetSize()
    self.Icon:SetPos((w - iconW) * 0.5, (h - iconH) * 0.5)
end

function PANEL:PerformLayout(w, h)
    self:centerIcon(w, h)
end

function PANEL:PaintBehind()
end

function PANEL:PaintOver(w, h)
    surface.SetDrawColor(0, 0, 0)
    surface.DrawOutlinedRect(0, 0, w, h)
    if self.BaseClass and self.BaseClass.PaintOver then self.BaseClass.PaintOver(self, w, h) end
end

vgui.Register("liaGridInvItem", PANEL, "liaItemIcon")