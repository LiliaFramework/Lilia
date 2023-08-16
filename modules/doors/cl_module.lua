ACCESS_LABELS = {}
ACCESS_LABELS[DOOR_OWNER] = "owner"
ACCESS_LABELS[DOOR_TENANT] = "tenant"
ACCESS_LABELS[DOOR_GUEST] = "guest"
ACCESS_LABELS[DOOR_NONE] = "none"

function MODULE:ShouldDrawEntityInfo(entity)
	if (entity.isDoor(entity) and !entity.getNetVar(entity, "disabled")) then
		return true
	end
end

local toScreen = FindMetaTable("Vector").ToScreen
local colorAlpha = ColorAlpha
local drawText = lia.util.drawText
local teamGetColor = team.GetColor

function MODULE:DrawEntityInfo(entity, alpha)
	if (entity.isDoor(entity) and !entity:getNetVar("hidden")) then
		local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
		local x, y = position.x, position.y
		local owner = entity.GetDTEntity(entity, 0)
		local name = entity.getNetVar(entity, "title", entity.getNetVar(entity, "name", IsValid(owner) and L"dTitleOwned" or L"dTitle"))
		local factions = entity.getNetVar(entity, "factions")
		local class = entity.getNetVar(entity, "class")
		local color = lia.config.Color

		drawText(name, x, y, colorAlpha(color_white, alpha), 1, 1)

		if (IsValid(owner)) then
			drawText(L("dOwnedBy", owner.Name(owner)), x, y + 16, colorAlpha(color_white, alpha), 1, 1)
		elseif (factions ~= "[]" and factions ~= nil) then
			local facs = util.JSONToTable(factions)
			local count = 1
			for id,_ in pairs(facs) do
				local info = lia.faction.indices[id]
				drawText(info.name, x, y + (16 * count), info.color, 1, 1)
				count = count + 1
			end
		else
			drawText(entity.getNetVar(entity, "noSell") and L"dIsNotOwnable" or L"dIsOwnable", x, y + 16, colorAlpha(color_white, alpha), 1, 1)
		end
	end
end

netstream.Hook("doorMenu", function(entity, access, door2)
	if (IsValid(lia.gui.door)) then
		return lia.gui.door:Remove()
	end

	if (IsValid(entity)) then
		lia.gui.door = vgui.Create("liaDoorMenu")
		lia.gui.door:setDoor(entity, access, door2)
	end
end)

netstream.Hook("doorPerm", function(door, client, access)
	local panel = door.liaPanel

	if (IsValid(panel) and IsValid(client)) then
		panel.access[client] = access

		for k, v in ipairs(panel.access:GetLines()) do
			if (v.player == client) then
				v:SetColumnText(2, L(ACCESS_LABELS[access or 0]))

				return
			end
		end
	end
end)