function MODULE:StorageOpen(storage)
	local PADDING = 4
	if not IsValid(storage) or storage:getStorageInfo().invType ~= "grid" then return end
	local localInv = LocalPlayer():getChar() and LocalPlayer():getChar():getInv()
	local storageInv = storage:getInv()
	if not localInv or not storageInv then return liaStorageBase:exitStorage() end
	local localInvPanel = localInv:show()
	local storageInvPanel = storageInv:show()
	storageInvPanel:SetTitle(L(storage:getStorageInfo().name))
	localInvPanel:ShowCloseButton(true)
	storageInvPanel:ShowCloseButton(true)
	local extraWidth = (storageInvPanel:GetWide() + PADDING) / 2
	localInvPanel:Center()
	storageInvPanel:Center()
	localInvPanel.x = localInvPanel.x + extraWidth
	storageInvPanel:MoveLeftOf(localInvPanel, PADDING)
	local firstToRemove = true
	localInvPanel.oldOnRemove = localInvPanel.OnRemove
	storageInvPanel.oldOnRemove = storageInvPanel.OnRemove

	local function exitStorageOnRemove(panel)
		if firstToRemove then
			firstToRemove = false
			liaStorageBase:exitStorage()
			local otherPanel = panel == localInvPanel and storageInvPanel or localInvPanel

			if IsValid(otherPanel) then
				otherPanel:Remove()
			end
		end

		panel:oldOnRemove()
	end

	hook.Run("OnCreateStoragePanel", localInvPanel, storageInvPanel, storage)
	localInvPanel.OnRemove = exitStorageOnRemove
	storageInvPanel.OnRemove = exitStorageOnRemove
end

function MODULE:transferItem(itemID)
	if not lia.item.instances[itemID] then return end
	net.Start("liaStorageTransfer")
	net.WriteUInt(itemID, 32)
	net.SendToServer()
end