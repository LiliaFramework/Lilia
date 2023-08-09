--------------------------------------------------------------------------------------------------------
lia.inventory = lia.inventory or {}
lia.inventory.instances = lia.inventory.instances or {}
lia.inventory.types = lia.inventory.types or {}
--------------------------------------------------------------------------------------------------------
local function serverOnly(value)
	return SERVER and value or nil
end
--------------------------------------------------------------------------------------------------------
local InvTypeStructType = {
	__index = "table",
	add = serverOnly("function"),
	remove = serverOnly("function"),
	sync = serverOnly("function"),
	typeID = "string",
	className = "string"
}
--------------------------------------------------------------------------------------------------------
local function checkType(typeID, struct, expected, prefix)
	prefix = prefix or ""

	for key, expectedType in pairs(expected) do
		local actualValue = struct[key]
		local expectedTypeString = isstring(expectedType) and expectedType or type(expectedType)
		assert(type(actualValue) == expectedTypeString, "expected type of " .. prefix .. key .. " to be " .. expectedTypeString .. " for inventory type " .. typeID .. ", got " .. type(actualValue))

		if istable(expectedType) then
			checkType(typeID, actualValue, expectedType, prefix .. key .. ".")
		end
	end
end
--------------------------------------------------------------------------------------------------------
function lia.inventory.newType(typeID, invTypeStruct)
	assert(not lia.inventory.types[typeID], "duplicate inventory type " .. typeID)
	assert(istable(invTypeStruct), "expected table for argument #2")
	checkType(typeID, invTypeStruct, InvTypeStructType)
	debug.getregistry()[invTypeStruct.className] = invTypeStruct
	lia.inventory.types[typeID] = invTypeStruct
end
--------------------------------------------------------------------------------------------------------
function lia.inventory.new(typeID)
	local class = lia.inventory.types[typeID]
	assert(class ~= nil, "bad inventory type " .. typeID)

	return setmetatable({
		items = {},
		config = table.Copy(class.config)
	}, class)
end
--------------------------------------------------------------------------------------------------------