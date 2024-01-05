------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LiliaStorage:exitStorage()
    net.Start("liaStorageExit")
    net.SendToServer()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LiliaStorage:StorageUnlockPrompt(_)
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LiliaStorage:StorageOpen(storage)
    if not IsValid(storage) then return end
    local localInv = LocalPlayer():getChar() and LocalPlayer():getChar():getInv()
    local storageInv = lia.inventory.instances[storage:getNetVar("inv")]
    if not localInv or not storageInv then return self:exitStorage() end
    local localInvPanel = localInv:show()
    local storageInvPanel = storageInv:show()
    storageInvPanel:SetTitle("Trunk")
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LiliaStorage:transferItem(itemID)
    if not lia.item.instances[itemID] then return end
    net.Start("liaStorageTransfer")
    net.WriteUInt(itemID, 32)
    net.SendToServer()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LiliaStorage:PopulateContent(pnlContent, tree)
    local RootNode = tree:AddNode("Spawnable Props", "icon16/box.png")
    local ViewPanel = vgui.Create("ContentContainer", pnlContent)
    ViewPanel:SetVisible(false)
    RootNode.DoClick = function()
        ViewPanel:Clear(true)
        local label = vgui.Create("ContentHeader", container)
        label:SetText("Storage")
        ViewPanel:Add(label)
        for model, _ in pairs(LiliaStorage.StorageDefinitions) do
            local mdlicon = spawnmenu.GetContentType("model")
            if mdlicon then
                mdlicon(
                    ViewPanel,
                    {
                        model = model
                    }
                )
            end
        end
    end

    pnlContent:SwitchPanel(ViewPanel)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
