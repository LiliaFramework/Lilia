--------------------------------------------------------------------------------------------------------
ACCESS_LABELS = {}
--------------------------------------------------------------------------------------------------------
ACCESS_LABELS[DOOR_OWNER] = "owner"
ACCESS_LABELS[DOOR_TENANT] = "tenant"
ACCESS_LABELS[DOOR_GUEST] = "guest"
ACCESS_LABELS[DOOR_NONE] = "none"
--------------------------------------------------------------------------------------------------------
function MODULE:ShouldDrawEntityInfo(entity)
	if (entity.isDoor(entity) and !entity.getNetVar(entity, "disabled")) then
		return true
	end
end
--------------------------------------------------------------------------------------------------------
function MODULE:DrawEntityInfo(entity, alpha)
	if (entity.isDoor(entity) and !entity:getNetVar("hidden")) then
		local position = FindMetaTable("Vector").ToScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
		local x, y = position.x, position.y
		local owner = entity.GetDTEntity(entity, 0)
		local name = entity.getNetVar(entity, "title", entity.getNetVar(entity, "name", IsValid(owner) and L"dTitleOwned" or L"dTitle"))
		local factions = entity.getNetVar(entity, "factions")
		local class = entity.getNetVar(entity, "class")
		local color = lia.config.Color

		lia.util.drawText(name, x, y, ColorAlpha(color_white, alpha), 1, 1)

		if (IsValid(owner)) then
			lia.util.drawText(L("dOwnedBy", owner.Name(owner)), x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
		elseif (factions ~= "[]" and factions ~= nil) then
			local facs = util.JSONToTable(factions)
			local count = 1
			for id,_ in pairs(facs) do
				local info = lia.faction.indices[id]
				lia.util.drawText(info.name, x, y + (16 * count), info.color, 1, 1)
				count = count + 1
			end
		else
			lia.util.drawText(entity.getNetVar(entity, "noSell") and L"dIsNotOwnable" or L"dIsOwnable", x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
		end
	end
end
--------------------------------------------------------------------------------------------------------