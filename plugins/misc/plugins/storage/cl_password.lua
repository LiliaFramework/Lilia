function PLUGIN:StorageUnlockPrompt(entity)
	Derma_StringRequest(
		L("storPassWrite"),
		L("storPassWrite"),
		"",
		function(val)
			net.Start("liaStorageUnlock")
				net.WriteString(val)
			net.SendToServer()
		end
	)
end
