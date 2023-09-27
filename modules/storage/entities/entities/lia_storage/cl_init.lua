--------------------------------------------------------------------------------------------------------
include("shared.lua")
--------------------------------------------------------------------------------------------------------
function ENT:onDrawEntityInfo(alpha)
	local locked = self.getNetVar(self, "locked", false)
	local position = FindMetaTable("Vector").ToScreen(self.LocalToWorld(self, self.OBBCenter(self)))
	local x, y = position.x, position.y
	-- TODO: refactor this
	y = y - 20
	local tx, ty = lia.util.drawText(locked and "P" or "Q", x, y, ColorAlpha(locked and Color(242, 38, 19) or Color(135, 211, 124), alpha), 1, 1, "liaIconsMedium", alpha * 0.65)
	y = y + ty * .9
	local def = self:getStorageInfo()
	if def then
		local tx, ty = lia.util.drawText(L(def.name or "Storage"), x, y, ColorAlpha(lia.config.Color), 1, 1, nil, alpha * 0.65)
		y = y + ty + 1
		if def.desc then
			lia.util.drawText(L(def.desc), x, y, ColorAlpha(color_white, alpha), 1, 1, nil, alpha * 0.65)
		end
	end
end
--------------------------------------------------------------------------------------------------------