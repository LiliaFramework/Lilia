local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:onDrawEntityInfo(alpha)
    local locked = self.getNetVar(self, "locked", false)
    local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
    local x, y = position.x, position.y
    y = y - 20
    local mat = locked and "locked.png" or "unlocked.png"
    local ty = 32
    lia.util.drawTexture(mat, ColorAlpha(color_white, alpha), x - 16, y - 16, 32, 32)
    y = y + ty * .9
    local def = self:getStorageInfo()
    if def then
        y = y + ty + 1
        if def.desc then lia.util.drawText(L(def.desc), x, y, ColorAlpha(color_white, alpha), 1, 1, nil, alpha * 0.65) end
    end
end