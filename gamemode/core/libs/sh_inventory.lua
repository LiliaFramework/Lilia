lia.inventory = lia.inventory or {}
lia.inventory.types = {}
lia.inventory.instances = lia.inventory.instances or {}

lia.util.include("lilia/gamemode/core/meta/sh_base_inventory.lua")

local function serverOnly(value)
	return SERVER and value or nil
end

local InvTypeStructType = {
	__index = "table",
	add = serverOnly("function"),
	remove = serverOnly("function"),
	sync = serverOnly("function"),
	typeID = "string",
	className = "string"
}

local function checkType(typeID, struct, expected, prefix)
	prefix = prefix or ""
	for key, expectedType in pairs(expected) do
		local actualValue = struct[key]
		local expectedTypeString = isstring(expectedType)
			and expectedType or type(expectedType)
		assert(
			type(actualValue) == expectedTypeString,
			"expected type of "..prefix..key.." to be "..expectedTypeString..
			" for inventory type "..typeID..", got "..type(actualValue)
		)
		if (istable(expectedType)) then
			checkType(typeID, actualValue, expectedType, prefix..key..".")
		end
	end
end

-- Performs type checking for new inventory types then stores them into
-- lia.inventory.types if there are no errors.
function lia.inventory.newType(typeID, invTypeStruct)
	assert(not lia.inventory.types[typeID], "duplicate inventory type "..typeID)

	-- Type check the inventory type struct.
	assert(istable(invTypeStruct), "expected table for argument #2")
	checkType(typeID, invTypeStruct, InvTypeStructType)

	debug.getregistry()[invTypeStruct.className] = invTypeStruct
	lia.inventory.types[typeID] = invTypeStruct
end

-- Creates an instance of an inventory class whose type is the given type ID.
function lia.inventory.new(typeID)
	local class = lia.inventory.types[typeID]
	assert(class ~= nil, "bad inventory type "..typeID)

	return setmetatable({
		items = {},
		config = table.Copy(class.config)
	}, class)
end

if (CLIENT) then
	function lia.inventory.show(inventory, parent)
		local globalName = "inv"..inventory.id
		if (IsValid(lia.gui[globalName])) then
			lia.gui[globalName]:Remove()
		end
		local panel = hook.Run("CreateInventoryPanel", inventory, parent)
		lia.gui[globalName] = panel
		return panel
	end
end
