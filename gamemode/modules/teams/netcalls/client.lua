local characterPanel
net.Receive("liaClassUpdate", function()
    local joinedClient = net.ReadEntity()
    if lia.gui.classes and lia.gui.classes:IsVisible() then
        if joinedClient == LocalPlayer() then
            lia.gui.classes:loadClasses()
        else
            for _, v in ipairs(lia.gui.classes.classPanels) do
                local data = v.data
                v:setNumber(#lia.class.getPlayers(data.index))
            end
        end
    end
end)

net.Receive("liaCharacterInfo", function()
    local characterData = net.ReadTable()
    local character = LocalPlayer():getChar()
    if not character or LocalPlayer():Team() == FACTION_STAFF or not (character:hasFlags("V") or character:hasFlags("W")) then return end
    local canKick = false
    if lia.gui.currentRosterType == "faction" then
        local factionData = lia.faction.indices[character:getFaction()]
        canKick = character:hasFlags("K")
        if factionData and factionData.isDefault then canKick = false end
    end

    if IsValid(lia.gui.roster) then
        lia.gui.roster:Populate(characterData, canKick)
        return
    end

    if IsValid(characterPanel) then characterPanel:Remove() end
    local rows = {}
    for _, data in ipairs(characterData) do
        table.insert(rows, data)
    end

    local columns = {
        {
            name = "name",
            field = "name"
        },
        {
            name = "steamID",
            field = "steamID"
        },
        {
            name = "class",
            field = "class"
        },
        {
            name = "playtime",
            field = "playTime"
        },
        {
            name = "lastOnline",
            field = "lastOnline"
        }
    }

    local actions = {}
    if canKick then
        actions[#actions + 1] = {
            name = "kick",
            net = "KickCharacter"
        }
    end

    local frame, list = lia.util.CreateTableUI(L("character") .. " " .. L("information"), columns, rows, actions)
    characterPanel = frame
    if IsValid(list) then
        list.OnRowRightClick = function(_, _, line)
            if not IsValid(line) or not line.rowData then return end
            local rowData = line.rowData
            local menu = DermaMenu()
            if canKick and rowData.steamID ~= LocalPlayer():SteamID() then
                menu:AddOption(L("kick"), function()
                    Derma_Query(L("kickConfirm"), L("confirm"), L("yes"), function()
                        net.Start("liaKickCharacter")
                        net.WriteInt(tonumber(rowData.id), 32)
                        net.SendToServer()
                        if IsValid(frame) then frame:Remove() end
                    end, L("no"))
                end)
            end

            menu:AddOption(L("view") .. " " .. L("characterList"), function() LocalPlayer():ConCommand("say /charlist " .. rowData.steamID) end)
            menu:AddOption(L("copySteamID"), function() SetClipboardText(rowData.steamID or "") end)
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for key, value in pairs(rowData) do
                    value = tostring(value or L("na"))
                    local columnName
                    for _, col in ipairs(columns) do
                        if col.field == key then
                            columnName = col.name
                            break
                        end
                    end

                    columnName = columnName or key:gsub("^%l", string.upper)
                    rowString = rowString .. columnName .. ": " .. value .. " | "
                end

                rowString = rowString:sub(1, -4)
                SetClipboardText(rowString)
            end)

            menu:Open()
        end
    end
end)
