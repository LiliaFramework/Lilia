﻿local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function ENT:onDrawEntityInfo(alpha)
    local position = toScreen(self:LocalToWorld(self:OBBCenter()))
    local x, y = position.x, position.y
    lia.util.drawText(lia.currency.get(self:getAmount()), x, y, ColorAlpha(lia.config.get("Color")), 1, 1, nil, alpha * 0.65)
end
