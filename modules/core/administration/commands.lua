lia.command.add("adminmode", {
    desc = L("adminModeDesc"),
    onRun = function(client)
        if not IsValid(client) then return end
        local steamID = client:SteamID64()
        if client:isStaffOnDuty() then
            local oldCharID = client:getNetVar("OldCharID", 0)
            if oldCharID > 0 then
                net.Start("AdminModeSwapCharacter")
                net.WriteInt(oldCharID, 32)
                net.Send(client)
                client:setNetVar("OldCharID", nil)
                lia.log.add(client, "adminMode", oldCharID, "Switched back to their IC character")
            else
                client:ChatPrint(L("noPrevChar"))
            end
        else
            lia.db.query(string.format("SELECT * FROM lia_characters WHERE _steamID = \"%s\"", lia.db.escape(steamID)), function(data)
                for _, row in ipairs(data) do
                    local id = tonumber(row._id)
                    if row._faction == "staff" then
                        client:setNetVar("OldCharID", client:getChar():getID())
                        net.Start("AdminModeSwapCharacter")
                        net.WriteInt(id, 32)
                        net.Send(client)
                        lia.log.add(client, "adminMode", id, "Switched to their staff character")
                        return
                    end
                end

                client:ChatPrint(L("noStaffChar"))
            end)
        end
    end
})

lia.command.add("setsitroom", {
    superAdminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("setSitroomDesc"),
    onRun = function(client)
        local pos = client:GetPos()
        local mapName = game.GetMap()
        local sitrooms = lia.data.get("sitrooms", {}, true, true)
        sitrooms[mapName] = pos
        lia.data.set("sitrooms", sitrooms, true, true)
        client:notifyLocalized("sitroomSet")
        lia.log.add(client, "sitRoomSet", string.format("Map: %s | Position: %s", mapName, tostring(pos)), "Set the sitroom location for the current map")
    end
})

lia.command.add("sendtositroom", {
    adminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("sendToSitRoomDesc"),
    syntax = "[string charname]",
    AdminStick = {
        Name = L("sendToSitRoom"),
        Category = L("Moderation Tools"),
        SubCategory = L("misc"),
        Icon = "icon16/arrow_down.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local mapName = game.GetMap()
        local sitrooms = lia.data.get("sitrooms", {}, true, true)
        local pos = sitrooms[mapName]
        if pos then
            target:SetPos(pos)
            client:notifyLocalized("sitroomTeleport", target:Nick())
            target:notifyLocalized("sitroomArrive")
            lia.log.add(client, "sendToSitRoom", string.format("Map: %s | Target: %s | Position: %s", mapName, target:Nick(), tostring(pos)), "Teleported player to the sitroom for the current map")
        else
            client:notifyLocalized("sitroomNotSet")
        end
    end
})