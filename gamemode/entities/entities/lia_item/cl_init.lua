local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:computeDescMarkup(description)
    if self.desc ~= description then
        self.desc = description
        self.markup = lia.markup.parse("<font=liaItemDescFont>" .. description .. "</font>", ScrW() * 0.5)
    end
    return self.markup
end

function ENT:onDrawEntityInfo(alpha)
    if IsValid(lia.gui.itemPanel) then return end
    local item = self:getItemTable()
    if not item then return end
    local oldE, oldD = item.entity, item.data
    item.entity, item.data = self, self:getNetVar("data") or oldD
    local name = L(item.getName and item:getName() or item.name)
    lia.util.drawEntText(self, name, 0, alpha)
    local desc = item:getDesc()
    if desc and desc ~= "" then
        local pos = toScreen(self:LocalToWorld(self:OBBCenter()))
        local x, y = pos.x, pos.y
        surface.SetFont("liaHugeText")
        local tw, th = surface.GetTextSize(name)
        self:computeDescMarkup("<font=liaMediumFont>" .. desc .. "</font>", tw)
        local markupHeight = 0
        if self.markup then markupHeight = self.markup:getHeight() end
        local spacing = math.max(80, markupHeight + 20)
        y = y + th + spacing
        if self.markup then self.markup:draw(x - tw / 2, y, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, alpha) end
        hook.Run("DrawItemDescription", self, x, y, ColorAlpha(color_white, alpha), alpha)
    end

    item.data, item.entity = oldD, oldE
end

function ENT:DrawTranslucent()
    local itemTable = self:getItemTable()
    if itemTable and itemTable.drawEntity then
        itemTable:drawEntity(self)
    else
        local paintMat = itemTable and hook.Run("PaintItem", itemTable)
        if isstring(paintMat) and paintMat ~= "" then self:SetMaterial(paintMat) end
        self:DrawModel()
    end
end
