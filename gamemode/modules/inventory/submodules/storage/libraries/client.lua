function MODULE:exitStorage()
    net.Start("liaStorageExit")
    net.SendToServer()
end

function MODULE:StorageUnlockPrompt()
    Derma_StringRequest(L("storPassWrite"), L("storPassWrite"), "", function(val)
        net.Start("liaStorageUnlock")
        net.WriteString(val)
        net.SendToServer()
    end)
end

function MODULE:StorageOpen(storage, isCar)
    local client = LocalPlayer()
    if isCar then
        local localInv = client:getChar() and client:getChar():getInv()
        if not localInv then return self:exitStorage() end
        local localInvPanel = localInv:show()
        local storageInvPanel = storage:show()
        storageInvPanel:SetTitle(L("carTrunk"))
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
                self:exitStorage()
                local otherPanel = panel == localInvPanel and storageInvPanel or localInvPanel
                if IsValid(otherPanel) then otherPanel:Remove() end
            end

            panel:oldOnRemove()
        end

        hook.Run("OnCreateStoragePanel", localInvPanel, storageInvPanel, storage)
        localInvPanel.OnRemove = exitStorageOnRemove
        storageInvPanel.OnRemove = exitStorageOnRemove
    else
        if not IsValid(storage) then return end
        local localInv = client:getChar() and client:getChar():getInv()
        local storageInv = storage:getInv()
        if not localInv or not storageInv then return self:exitStorage() end
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
                self:exitStorage()
                local otherPanel = panel == localInvPanel and storageInvPanel or localInvPanel
                if IsValid(otherPanel) then otherPanel:Remove() end
            end

            panel:oldOnRemove()
        end

        hook.Run("OnCreateStoragePanel", localInvPanel, storageInvPanel, storage)
        localInvPanel.OnRemove = exitStorageOnRemove
        storageInvPanel.OnRemove = exitStorageOnRemove
    end
end

function MODULE:transferItem(itemID)
    if not lia.item.instances[itemID] then return end
    net.Start("liaStorageTransfer")
    net.WriteUInt(itemID, 32)
    net.SendToServer()
end
