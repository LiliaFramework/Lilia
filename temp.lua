if SERVER then
	timer.Create("liaSaveData", lia.config.DataSaveInterval, 0, function()
		hook.Run("SaveData")
		hook.Run("PersistenceSave")
	end)

	timer.Simple(0, function()
		hook.Run("SetupDatabase")

		lia.db.connect(function()
			lia.db.loadTables()
			MsgC(Color(0, 255, 0), "Lilia has connected to the database.\n")
			MsgC(Color(0, 255, 0), "Database Type: " .. lia.db.module .. ".\n")
			hook.Run("DatabaseConnected")
		end)
	end)

	cvars.AddChangeCallback("sbox_persist", function(name, old, new)
		timer.Create("sbox_persist_change_timer", 1, 1, function()
			hook.Run("PersistenceSave", old)
			game.CleanUpMap()
			if new == "" then return end
			hook.Run("PersistenceLoad", new)
		end)
	end, "sbox_persist_load")
else
	local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()

	cvars.AddChangeCallback("lia_cheapblur", function(name, old, new)
		useCheapBlur = (tonumber(new) or 0) > 0
	end)

	CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

	nut = lia or {
		util = {},
		meta = {}
	}
end