MODULE.name = "Teams"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Manages factions and character classes."
if SERVER then
    util.AddNetworkString("CharacterInfo")
    util.AddNetworkString("KickCharacter")
    net.Receive("KickCharacter", function(len, client)
        local char = client:getChar()
        if not char then return end
        local isLeader = client:IsSuperAdmin() or char:getData("factionOwner") or char:getData("factionAdmin") or char:hasFlags("V")
        if not isLeader then return end

        local citizen = lia.faction.teams["citizen"]
        local characterID = net.ReadUInt(32)
        local IsOnline = false
        for _, target in player.Iterator() do
            local targetChar = target:getChar()
            if targetChar and targetChar:getID() == characterID and targetChar:getFaction() == char:getFaction() then
                IsOnline = true
                target:notify("You were kicked from your faction!")
                targetChar.vars.faction = citizen.uniqueID
                targetChar:setFaction(citizen.index)
            end
        end

        if not IsOnline then lia.char.setCharData(characterID, "kickedFromFaction", true) end
    end)

    function MODULE:PlayerLoadedChar(client)
        local citizen = lia.faction.teams["citizen"]
        if client:getChar():getData("kickedFromFaction", false) then
            client:notify("You were kicked from a faction while offline!")
            client:getChar().vars.faction = citizen.uniqueID
            client:getChar():setFaction(citizen.index)
            client:getChar():setData("kickedFromFaction", false)
        end
    end
else
    net.Receive("CharacterInfo", function()
        local factionID = net.ReadString()
        local characterData = net.ReadTable()
        local character = LocalPlayer():getChar()
        local isLeader = LocalPlayer():IsSuperAdmin() or character:getData("factionOwner") or character:getData("factionAdmin") or character:hasFlags("V")
        if not isLeader then return end

        if IsValid(characterPanel) then characterPanel:Remove() end

        local rows = {}
        for _, data in ipairs(characterData) do
            if data.faction == factionID and data.id ~= character:getID() then
                table.insert(rows, data)
            end
        end

        local columns = {
            {name = "ID", field = "id"},
            {name = "Name", field = "name"},
            {name = "Last Online", field = "lastOnline"},
            {name = "Hours Played", field = "hoursPlayed"}
        }

        local frame, list = lia.util.CreateTableUI("Character Information", columns, rows, {
            {name = "Kick", net = "KickCharacter"}
        })

        if IsValid(list) then
            list.OnRowRightClick = function(_, _, line)
                if not IsValid(line) or not line.rowData then return end
                local rowData = line.rowData
                local menu = DermaMenu()
                menu:AddOption("Kick", function()
                    Derma_Query("Are you sure you want to kick this player?", "Confirm", "Yes", function()
                        net.Start("KickCharacter")
                        net.WriteInt(tonumber(rowData.id), 32)
                        net.SendToServer()
                        if IsValid(frame) then frame:Remove() end
                    end, "No")
                end)

                menu:AddOption("View Character List", function()
                    LocalPlayer():ConCommand("say /charlist " .. rowData.steamID)
                end)

                menu:AddOption(L("copyRow"), function()
                    local rowString = ""
                    for key, value in pairs(rowData) do
                        value = tostring(value or L("na"))
                        rowString = rowString .. key:gsub("^%l", string.upper) .. ": " .. value .. " | "
                    end
                    rowString = rowString:sub(1, -4)
                    SetClipboardText(rowString)
                end)

                menu:Open()
            end
        end
    end)
end
