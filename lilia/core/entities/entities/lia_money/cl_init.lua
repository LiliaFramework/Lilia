--------------------------------------------------------------------------------------------------------------------------
local toScreen = FindMetaTable("Vector").ToScreen
--------------------------------------------------------------------------------------------------------------------------
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function ENT:onDrawEntityInfo(alpha)
    local position = toScreen(self:LocalToWorld(self:OBBCenter()))
    local x, y = position.x, position.y
    lia.util.drawText(lia.currency.get(self:getAmount()), x, y, ColorAlpha(lia.config.Color), 1, 1, nil, alpha * 0.65)
end
--------------------------------------------------------------------------------------------------------------------------
