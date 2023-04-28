PLUGIN.name = "Simple Inv"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Adds a simple inventory type."

lia.util.include("sh_simple_inv.lua")

local INVENTORY_TYPE_ID = "simple"
PLUGIN.INVENTORY_TYPE_ID = INVENTORY_TYPE_ID

function PLUGIN:GetDefaultInventoryType(character)
	return INVENTORY_TYPE_ID
end
