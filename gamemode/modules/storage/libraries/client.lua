function MODULE:ExitStorage()
    net.Start("liaStorageExit")
    net.SendToServer()
end

function MODULE:StorageUnlockPrompt()
    LocalPlayer():requestString(L("storPassWrite"), L("storPassWrite"), function(val)
        net.Start("liaStorageUnlock")
        net.WriteString(val)
        net.SendToServer()
    end, "")
end

function MODULE:StorageOpen(storage, isCar)
    local client = LocalPlayer()
    local localInv = client:getChar() and client:getChar():getInv()
    if not localInv then return self:ExitStorage() end
    local storageInv
    if isCar then
        storageInv = storage
    else
        if not IsValid(storage) then return end
        storageInv = storage:getInv()
    end

    if not storageInv then return self:ExitStorage() end
    local panels = lia.inventory.showDual(localInv, storageInv)
    if not panels then return self:ExitStorage() end
    local localInvPanel, storageInvPanel = panels[1], panels[2]
    if isCar then
        storageInvPanel:SetTitle(L("carTrunk"))
    else
        local storageInfo = storage:getStorageInfo()
        if storageInfo and storageInfo.name then
            storageInvPanel:SetTitle(L(storageInfo.name))
        else
            storageInvPanel:SetTitle(L("storageContainer"))
        end
    end

    local originalOnRemove1 = localInvPanel.OnRemove
    local originalOnRemove2 = storageInvPanel.OnRemove
    local function exitStorageOnRemove(panel)
        self:ExitStorage()
        if panel == localInvPanel and originalOnRemove1 then
            originalOnRemove1(panel)
        elseif panel == storageInvPanel and originalOnRemove2 then
            originalOnRemove2(panel)
        end
    end

    localInvPanel.OnRemove = exitStorageOnRemove
    storageInvPanel.OnRemove = exitStorageOnRemove
    hook.Run("OnCreateStoragePanel", localInvPanel, storageInvPanel, storage)
end

function MODULE:TransferItem(itemID)
    if not lia.item.instances[itemID] then return end
    net.Start("liaStorageTransfer")
    net.WriteUInt(itemID, 32)
    net.SendToServer()
end
