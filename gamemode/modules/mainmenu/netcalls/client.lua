local MODULE = MODULE

net.Receive("liaMainCharacterSet", function()
        local charID = net.ReadUInt(32)
        charID = tonumber(charID)
        local client = LocalPlayer()
        if IsValid(client) then
            lia.localData = lia.localData or {}
            lia.localData["mainCharacter"] = charID
            client:notifyLocalized("mainCharacterSet")
            if IsValid(lia.gui.character) and lia.gui.character.isLoadMode then lia.gui.character:updateSelectedCharacter() end
        end
    end)

net.Receive("liaStaffDiscordPrompt", function()
        lia.derma.requestString(L("staffCharacterSetup"), L("discordUsernamePrompt"), function(discord)
            if discord and discord:Trim() ~= "" then
                net.Start("liaStaffDiscordResponse")
                net.WriteString(discord:Trim())
                net.SendToServer()
            elseif discord == false then
                net.Start("liaStaffDiscordResponse")
                net.WriteString("not provided")
                net.SendToServer()
            else
                LocalPlayer():notifyErrorLocalized("discordUsernameEmpty")
            end
        end, "", nil)
    end)
