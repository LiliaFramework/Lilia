
function MODULE:StorageOpen(storage)
	if not IsValid(storage) or storage:getStorageInfo().invType ~= "grid" then return end
	local localInv = LocalPlayer():getChar() and LocalPlayer():getChar():getInv()
	local storageInv = storage:getInv()
	if not localInv or not storageInv then return LiliaStorage:exitStorage() end
	local localInvPanel = localInv:show()
	local storageInvPanel = storageInv:show()
	storageInvPanel:SetTitle(L(storage:getStorageInfo().name))
	localInvPanel:ShowCloseButton(true)
	storageInvPanel:ShowCloseButton(true)
	local extraWidth = (storageInvPanel:GetWide() + 4) / 2
	localInvPanel:Center()
	storageInvPanel:Center()
	localInvPanel.x = localInvPanel.x + extraWidth
	storageInvPanel:MoveLeftOf(localInvPanel, 4)
	local firstToRemove = true
	localInvPanel.oldOnRemove = localInvPanel.OnRemove
	storageInvPanel.oldOnRemove = storageInvPanel.OnRemove
	local function exitStorageOnRemove(panel)
		if firstToRemove then
			firstToRemove = false
			LiliaStorage:exitStorage()
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
