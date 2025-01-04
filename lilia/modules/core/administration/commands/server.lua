lia.command.add("adminmode", {
    syntax = "<string charName>",
    onRun = function(client)
        if not IsValid(client) then return end
        local steamID = client:SteamID64()
        if client:Team() == FACTION_STAFF then
            local oldCharID = client:GetNW2Int("OldCharID", 0)
            if oldCharID > 0 then
                net.Start("AdminModeSwapCharacter")
                net.WriteInt(oldCharID, 32)
                net.Send(client)
                client:SetNW2Int("OldCharID", nil)
            else
                client:ChatPrint("No previous character to swap to.")
            end
        else
            lia.db.query(string.format("SELECT * FROM lia_characters WHERE _steamID = \"%s\"", lia.db.escape(steamID)), function(data)
                for _, row in ipairs(data) do
                    local id = tonumber(row._id)
                    local faction = row._faction
                    if faction == "staff" then
                        client:SetNW2Int("OldCharID", client:getChar():getID())
                        net.Start("AdminModeSwapCharacter")
                        net.WriteInt(id, 32)
                        net.Send(client)
                        return
                    end
                end

                client:ChatPrint("No staff character found.")
            end)
        end
    end
})