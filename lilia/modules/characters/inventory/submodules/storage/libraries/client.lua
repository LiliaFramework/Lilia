---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
CanSpawnStorage = CreateClientConVar("can_spawn_storage", 1, true, true)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:exitStorage()
    net.Start("liaStorageExit")
    net.SendToServer()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:StorageUnlockPrompt(_)
    Derma_StringRequest(L("storPassWrite"), L("storPassWrite"), "", function(val)
        net.Start("liaStorageUnlock")
        net.WriteString(val)
        net.SendToServer()
    end)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:SetupQuickMenu(menu)
    if CAMI.PlayerHasAccess(client, "Staff Permissions - Can Spawn Storage", nil) then
        menu:addCheck("Spawn Storage Props as Storages", function(_, state)
            if state then
                RunConsoleCommand("can_spawn_storage", "1")
            else
                RunConsoleCommand("can_spawn_storage", "0")
            end
        end, CanSpawnStorage:GetBool())

        menu:addSpacer()
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:StorageOpen(storage, normal)
    if not IsValid(storage) then return end
    if not normal then
        local localInv = LocalPlayer():getChar() and LocalPlayer():getChar():getInv()
        local storageInv = lia.inventory.instances[storage:getNetVar("inv")]
        if not localInv or not storageInv then return self:exitStorage() end
        local localInvPanel = localInv:show()
        local storageInvPanel = storageInv:show()
        storageInvPanel:SetTitle("Car Trunk")
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
                if IsValid(otherPanel) then otherPanel:Remove() end
            end

            panel:oldOnRemove()
        end

        hook.Run("OnCreateStoragePanel", localInvPanel, storageInvPanel, storage)
        localInvPanel.OnRemove = exitStorageOnRemove
        storageInvPanel.OnRemove = exitStorageOnRemove
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:transferItem(itemID)
    if not lia.item.instances[itemID] then return end
    net.Start("liaStorageTransfer")
    net.WriteUInt(itemID, 32)
    net.SendToServer()
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
