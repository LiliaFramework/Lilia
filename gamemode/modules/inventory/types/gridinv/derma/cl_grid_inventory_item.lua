local PANEL = {}
local renderedIcons = {}
local function getThemeColors()
    local theme = lia.color and lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    return accent, theme.text or Color(232, 240, 240)
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

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
    self.selected = false
    self.Hovered = false
    if IsValid(self.Icon) then self.Icon:SetMouseInputEnabled(false) end
end

function PANEL:setIconSize(size)
    self.size = size
    if self.itemTable and IsValid(self.Icon) then
        self.Icon:SetSize(self.size * self.itemTable:getWidth(), self.size * self.itemTable:getHeight())
        self.Icon:InvalidateLayout(true)
        self:centerIcon()
    end
end

function PANEL:setSelected(selected)
    self.selected = selected == true
end

function PANEL:setItem(item)
    self.itemTable = item
    if IsValid(self.Icon) then self.Icon:SetMouseInputEnabled(false) end
    self.Icon:SetSize(self.size * item:getWidth(), self.size * item:getHeight())
    self.Icon:InvalidateLayout(true)
    self:setItemType(item:getID())
    self:centerIcon()
end

local function drawIcon(mat, _, w, h)
    local material = isstring(mat) and Material(mat) or mat
    if not material or material:IsError() then return end
    local padding = math.max(math.floor(math.min(w, h) * 0.08), 2)
    local availableW = math.max(w - padding * 2, 1)
    local availableH = math.max(h - padding * 2, 1)
    local materialW = math.max(material:Width(), 1)
    local materialH = math.max(material:Height(), 1)
    local scale = math.min(availableW / materialW, availableH / materialH)
    local drawW = math.max(math.floor(materialW * scale), 1)
    local drawH = math.max(math.floor(materialH * scale), 1)
    local drawX = math.floor((w - drawW) * 0.5)
    local drawY = math.floor((h - drawH) * 0.5)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
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

        if skin or bodygroups and next(bodygroups) then item.forceRender = true end
    end

    self:updateTooltip()
    local itemIcon = item.icon
    if itemIcon then
        self.Icon:SetVisible(false)
        self.ExtraPaint = function(_, w, h) drawIcon(itemIcon, self, w, h) end
    else
        renderNewIcon(self, item)
        if self.Icon and self.Icon.UpdateVisuals then
            self.Icon.ItemTable = item
            self.Icon:UpdateVisuals()
        end
    end

    if IsValid(self.Icon) then self.Icon:SetMouseInputEnabled(false) end
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

function PANEL:centerIcon(w, h)
    if not IsValid(self.Icon) then return end
    w = w or self:GetWide()
    h = h or self:GetTall()
    local iconW, iconH = self.Icon:GetSize()
    self.Icon:SetPos(math.floor((w - iconW) * 0.5), math.floor((h - iconH) * 0.5))
end

function PANEL:PerformLayout(w, h)
    self:centerIcon(w, h)
end

function PANEL:PaintBehind(w, h)
    local accent = select(1, getThemeColors())
    if self.isDragPreview then
        drawPanel(0, 0, w, h, 5, Color(255, 255, 255, 7), Color(accent.r, accent.g, accent.b, 100))
        return
    end

    local hovered = self.Hovered
    local background = self.selected and Color(accent.r, accent.g, accent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(2, 14, 18, 45)
    local outline = self.selected and Color(accent.r, accent.g, accent.b, 145) or hovered and Color(accent.r, accent.g, accent.b, 100) or nil
    drawPanel(0, 0, w, h, 5, background, outline)
end

function PANEL:PaintOver(w, h)
    if self.BaseClass and self.BaseClass.PaintOver then self.BaseClass.PaintOver(self, w, h) end
    if self.isDragPreview or not self.itemTable then return end
    local quantity = self.itemTable.getQuantity and self.itemTable:getQuantity() or self.itemTable.quantity
    if isnumber(quantity) and quantity > 1 then draw.SimpleText(tostring(quantity), "LiliaFont.14b", w - 8, h - 8, Color(232, 240, 240), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM) end
end

vgui.Register("liaGridInvItem", PANEL, "liaItemIcon")
