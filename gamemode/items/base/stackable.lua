ITEM.name = "stackableName"
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.isStackable = true
ITEM.maxQuantity = 10
ITEM.canSplit = true
function ITEM:getDesc()
    return L("stackableDesc", self:getQuantity())
end

function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "liaChatFont")
end

function ITEM:onCombine(other)
    if other.uniqueID ~= self.uniqueID then return end
    local combined = self:getQuantity() + other:getQuantity()
    if combined <= self.maxQuantity then
        self:setQuantity(combined)
        other:remove()
    else
        self:setQuantity(self.maxQuantity)
        other:setQuantity(combined - self.maxQuantity)
    end
    return true
end
