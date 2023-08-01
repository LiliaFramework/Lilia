local MODULE = MODULE
MODULE.name = "Storage Base"
MODULE.author = "Leonheart#7476/Cheesenot"
MODULE.desc = "Useful things for storage modules."
STORAGE_DEFINITIONS = STORAGE_DEFINITIONS or {}
MODULE.definitions = STORAGE_DEFINITIONS
lia.util.include("sv_storage.lua")
lia.util.include("sv_networking.lua")
lia.util.include("sv_access_rules.lua")
lia.util.include("cl_networking.lua")
lia.util.include("cl_password.lua")
liaStorageBase = MODULE

if CLIENT then
	function MODULE:transferItem(itemID)
		if not lia.item.instances[itemID] then return end
		net.Start("liaStorageTransfer")
		net.WriteUInt(itemID, 32)
		net.SendToServer()
	end
end

lia.command.add("storagelock", {
	adminOnly = true,
	syntax = "[string password]",
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local ent = trace.Entity

		if ent and ent:IsValid() then
			local password = table.concat(arguments, " ")

			if password ~= "" then
				ent:setNetVar("locked", true)
				ent.password = password
				client:notifyLocalized("storPass", password)
			else
				ent:setNetVar("locked", nil)
				ent.password = nil
				client:notifyLocalized("storPassRmv")
			end

			MODULE:saveStorage()
		else
			client:notifyLocalized("invalid", "Entity")
		end
	end
})