local function ExitStorage()
    local client = LocalPlayer()
    if client.liaLockPanel and IsValid(client.liaLockPanel) then
        client.liaLockPanel:Remove()
        client.liaLockPanel = nil
    end

    net.Start("liaStorageExit")
    net.SendToServer()
end

function MODULE:StorageUnlockPrompt()
    LocalPlayer():requestString(L("storPassWrite"), L("storPassWrite"), function(val)
        if val ~= false then
            net.Start("liaStorageUnlock")
            net.WriteString(val)
            net.SendToServer()
        end
    end, "")
end

function MODULE:StorageOpen(storage, isCar)
    local client = LocalPlayer()
    if client.liaLockPanel and IsValid(client.liaLockPanel) then
        client.liaLockPanel:Remove()
        client.liaLockPanel = nil
    end

    local localInv = client:getChar() and client:getChar():getInv()
    if not localInv then return ExitStorage() end
    local storageInv
    if isCar then
        storageInv = storage
    else
        if not IsValid(storage) then return end
        storageInv = storage:getInv()
    end

    if not storageInv then return ExitStorage() end
    local panels = lia.inventory.showDual(localInv, storageInv)
    if not panels then return ExitStorage() end
    local localInvPanel, storageInvPanel = panels[1], panels[2]
    if not IsValid(localInvPanel) or not IsValid(storageInvPanel) then return ExitStorage() end
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
        ExitStorage()
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

local function SetStoragePassword(action, oldPassword, newPassword)
    net.Start("liaStorageSetPassword")
    net.WriteString(action)
    if action == "set" then
        net.WriteString(newPassword or "")
    elseif action == "change" then
        net.WriteString(oldPassword or "")
        net.WriteString(newPassword or "")
    end

    net.SendToServer()
end

function MODULE:OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
    if not IsValid(storageInvPanel) or not IsValid(localInvPanel) or not IsValid(storage) then return end
    local parentPanel = localInvPanel:GetParent()
    local screenWidth = ScrW()
    local panelWidth = math.floor(screenWidth * 0.25)
    lockPanelRef = vgui.Create("DPanel", parentPanel)
    lockPanelRef:SetSize(panelWidth, 70)
    lockPanelRef:SetPos((parentPanel:GetWide() - panelWidth) / 2, localInvPanel:GetY() - 80)
    local panelColor = lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1] or Color(35, 35, 35)
    local textColor = lia.color.theme and lia.color.theme.text or color_white
    lockPanelRef.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(panelColor):Shape(lia.derma.SHAPE_IOS):Draw()
        draw.SimpleText(L("storageLockManagement"), "liaSmallFont", w / 2, 8, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local client = LocalPlayer()
    client.liaLockPanel = lockPanelRef
    local buttonWidth = (panelWidth - 40) / 3
    local buttonY = 40
    local lockBtn = vgui.Create("liaButton", lockPanelRef)
    lockBtn:SetTxt(L("lockStorage"))
    lockBtn:SetSize(buttonWidth, 22)
    lockBtn:SetPos(10, buttonY)
    lockBtn:PaintButton(lia.color.theme and lia.color.theme.button or Color(50, 80, 50), lia.color.theme and lia.color.theme.button_hovered or Color(60, 100, 60))
    lockBtn.DoClick = function() LocalPlayer():requestString(L("enterNewPassword"), L("enterNewPassword"), function(password) if password and password ~= "" then SetStoragePassword("set", nil, password) end end, "") end
    local changeBtn = vgui.Create("liaButton", lockPanelRef)
    changeBtn:SetTxt(L("changePassword"))
    changeBtn:SetSize(buttonWidth, 22)
    changeBtn:SetPos(15 + buttonWidth, buttonY)
    changeBtn:PaintButton(lia.color.theme and lia.color.theme.button or Color(50, 50, 80), lia.color.theme and lia.color.theme.button_hovered or Color(60, 60, 100))
    changeBtn.DoClick = function() LocalPlayer():requestString(L("enterCurrentPassword"), L("enterCurrentPassword"), function(currentPass) if currentPass and currentPass ~= "" then LocalPlayer():requestString(L("enterNewPassword"), L("enterNewPassword"), function(newPass) if newPass and newPass ~= "" then SetStoragePassword("change", currentPass, newPass) end end, "") end end, "") end
    local removeBtn = vgui.Create("liaButton", lockPanelRef)
    removeBtn:SetTxt(L("removePassword"))
    removeBtn:SetSize(buttonWidth, 22)
    removeBtn:SetPos(20 + buttonWidth * 2, buttonY)
    removeBtn:PaintButton(lia.color.theme and lia.color.theme.button or Color(80, 50, 50), lia.color.theme and lia.color.theme.button_hovered or Color(100, 60, 60))
    removeBtn.DoClick = function() LocalPlayer():requestString(L("removePassword"), L("confirmRemovePassword"), function(value) if value and value:lower() == "yes" then SetStoragePassword("remove") end end) end
    local updateButtons = function()
        local isLocked = storage:getNetVar("locked", false)
        lockBtn:SetEnabled(not isLocked)
        changeBtn:SetEnabled(isLocked)
        removeBtn:SetEnabled(isLocked)
    end

    updateButtons()
    storageInvPanel:Receiver("liaStorageEntity", function() timer.Simple(0.1, updateButtons) end)
end
