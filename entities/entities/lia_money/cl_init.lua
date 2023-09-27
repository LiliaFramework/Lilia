
include("shared.lua")

local toScreen = FindMetaTable("Vector").ToScreen
local colorAlpha = ColorAlpha
local drawText = lia.util.drawText
function ENT:onDrawEntityInfo(alpha)
    local position = toScreen(self:LocalToWorld(self:OBBCenter()))
    local x, y = position.x, position.y
    drawText(lia.currency.get(self:getAmount()), x, y, colorAlpha(lia.config.Color), 1, 1, nil, alpha * 0.65)
end
