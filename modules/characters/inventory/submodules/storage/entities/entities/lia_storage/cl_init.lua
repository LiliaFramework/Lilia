local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:onDrawEntityInfo(alpha)
    local locked = self.getNetVar(self, "locked", false)
    local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
    local x, y = position.x, position.y
    y = y - 20
    local _, ty = lia.util.drawText(locked and getIcon("0xf512", true) or getIcon("0xf510", true), x, y, ColorAlpha(locked and Color(242, 38, 19) or Color(135, 211, 124), alpha), 1, 1, "liaIconsMedium", alpha * 0.65)
    y = y + ty * .9
    local def = self:getStorageInfo()
    if def then
        y = y + ty + 1
        if def.desc then lia.util.drawText(L(def.desc), x, y, ColorAlpha(color_white, alpha), 1, 1, nil, alpha * 0.65) end
    end
end
