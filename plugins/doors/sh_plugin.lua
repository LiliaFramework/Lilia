PLUGIN.name = "Doors"
PLUGIN.author = "Cheesenot & Leonheart#7476"
PLUGIN.desc = "A simple door system // Now has multifaction support!"

DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0

lia.util.include("sv_plugin.lua")
lia.util.include("cl_plugin.lua")
lia.util.include("sh_commands.lua")

do
	local entityMeta = FindMetaTable("Entity")

	function entityMeta:checkDoorAccess(client, access)
		if (!self:isDoor()) then
			return false
		end

		access = access or DOOR_GUEST

		local parent = self.liaParent

		if (IsValid(parent)) then
			return parent:checkDoorAccess(client, access)
		end

		if (hook.Run("CanPlayerAccessDoor", client, self, access)) then
			return true
		end

		if (self.liaAccess and (self.liaAccess[client] or 0) >= access) then
			return true
		end

		return false
	end

	if (SERVER) then
		function entityMeta:removeDoorAccessData()
			-- Don't ask why. This happened with 60 player servers.
			if (IsValid(self)) then
				for k, v in pairs(self.liaAccess or {}) do
					netstream.Start(k, "doorMenu")
				end
				
				self.liaAccess = {}
				self:SetDTEntity(0, nil)
			end
		end
	end
end

-- Configurations for door prices.
lia.config.add("doorCost", 10, "The price to purchase a door.", nil, {
	data = {min = 0, max = 500},
	category = "dConfigName"
})
lia.config.add("doorSellRatio", 0.5, "How much of the door price is returned when selling a door.", nil, {
	form = "Float",
	data = {min = 0, max = 1.0},
	category = "dConfigName"
})
lia.config.add("doorLockTime", 1, "How long it takes to (un)lock a door.", nil, {
	form = "Float",
	data = {min = 0, max = 10.0},
	category = "dConfigName"
})