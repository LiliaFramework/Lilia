lia.net.readBigTable("liaDialogSync", function(data) if istable(data) then lia.dialog.stored = data end end)
net.Receive("liaOpenNpcDialog", function()
    local npc = net.ReadEntity()
    local canCustomize = net.ReadBool()
    local npcData = net.ReadTable()
    local npcName = "Dialog"
    if IsValid(npc) then
        npcName = npc:getNetVar("NPCName", npc.NPCName or "Dialog")
    elseif npcData and npcData.PrintName then
        npcName = npcData.PrintName
    end

    lia.dialog.vgui = vgui.Create("liaDialogMenu")
    lia.dialog.vgui:SetDialogTitle(npcName)
    if npcData then
        local enhancedConversation = table.Copy(npcData.Conversation or {})
        local additionalOptions = hook.Run("GetNPCDialogOptions", LocalPlayer(), npc, canCustomize) or {}
        for optionName, optionData in pairs(additionalOptions) do
            enhancedConversation[optionName] = optionData
        end

        local enhancedData = table.Copy(npcData)
        enhancedData.Conversation = enhancedConversation
        lia.dialog.vgui:LoadNPCDialog(enhancedData, npc)
    end
end)

net.Receive("liaNpcDialogDeliverResponse", function()
    local npc = net.ReadEntity()
    local responses = net.ReadTable()
    if not IsValid(lia.dialog.vgui) or not responses then return end
    if IsValid(lia.dialog.vgui) then lia.dialog.vgui:DisplayServerResponse(responses, npc) end
end)

net.Receive("liaNpcDialogNodeResult", function()
    local result = net.ReadTable()
    if not IsValid(lia.dialog.vgui) or not result then return end
    if IsValid(lia.dialog.vgui) then lia.dialog.vgui:HandleGeneratedDialogResult(result) end
end)

net.Receive("liaRequestNPCSelection", function()
    local npcEntity = net.ReadEntity()
    local npcOptions = net.ReadTable()
    if not IsValid(npcEntity) or not npcOptions then return end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Select NPC Type")
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(20, 20, 20, 20)
    for _, option in ipairs(npcOptions) do
        local displayName = option[1]
        local uniqueID = option[2]
        local button = vgui.Create("liaButton", scroll)
        button:Dock(TOP)
        button:SetTall(50)
        button:DockMargin(0, 0, 0, 10)
        button:SetText(displayName)
        button.DoClick = function()
            net.Start("liaRequestNPCSelection")
            net.WriteEntity(npcEntity)
            net.WriteString(uniqueID)
            net.SendToServer()
            frame:Close()
        end
    end

    local closeBtn = vgui.Create("liaButton", frame)
    closeBtn:Dock(BOTTOM)
    closeBtn:SetTall(60)
    closeBtn:DockMargin(20, 10, 20, 20)
    closeBtn:SetText("Cancel")
    closeBtn.DoClick = function() frame:Close() end
end)

function MODULE:GetAdminESPTarget(ent)
    if not lia.option.get("espEntities", false) or not lia.dialog.isDialogNPCEntity(ent) then return end
    local uniqueID = ent:getNetVar("uniqueID", "")
    if uniqueID == "" then return {} end
    return {
        kind = "npcs",
        label = ent:getNetVar("NPCName", "Unconfigured NPC"),
        baseColor = lia.option.get("espEntitiesColor")
    }
end
