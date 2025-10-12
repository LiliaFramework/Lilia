local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:onDrawEntityInfo(alpha)
    local locked = self:getNetVar("locked", false)
    local position = toScreen(self:LocalToWorld(self:OBBCenter(self)))
    local x, y = position.x, position.y
    y = y - 20
    local mat = locked and "locked.png" or "unlocked.png"
    lia.util.drawTexture(mat, ColorAlpha(color_white, alpha), x - 16, y - 16, 32, 32)
    local def = self:getStorageInfo()
    if def and def.desc then
        local descText = L(def.desc)
        lia.util.drawEntText(self, descText, 50, alpha)
    end
end