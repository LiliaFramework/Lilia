net.Receive("liaMainCharacterSet", function()
    local charID = net.ReadUInt(32)
    charID = tonumber(charID)
    local client = LocalPlayer()
    if IsValid(client) then
        lia.localData = lia.localData or {}
        lia.localData["mainCharacter"] = charID
        client:notify(string.format("Character set as main character."))
        if IsValid(lia.gui.character) and lia.gui.character.isLoadMode then lia.gui.character:updateSelectedCharacter() end
    end
end)

net.Receive("liaStaffDiscordPrompt", function()
    lia.derma.requestString("Staff Character Setup", "Please enter your Discord username for your staff character description:", function(discord)
        if discord and discord:Trim() ~= "" then
            net.Start("liaStaffDiscordResponse")
            net.WriteString(discord:Trim())
            net.SendToServer()
        elseif discord == false then
            net.Start("liaStaffDiscordResponse")
            net.WriteString("Not provided")
            net.SendToServer()
        else
            LocalPlayer():notifyError(string.format("Discord username cannot be empty!"))
        end
    end, "", nil)
end)
