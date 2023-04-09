net.Receive("liaStorageUnlock", function()
	local entity = net.ReadEntity()
	hook.Run("StorageUnlockPrompt", entity)
end)

net.Receive("liaStorageOpen", function()
	local entity = net.ReadEntity()
	hook.Run("StorageOpen", entity)
end)

function PLUGIN:exitStorage()
	net.Start("liaStorageExit")
	net.SendToServer()
end
