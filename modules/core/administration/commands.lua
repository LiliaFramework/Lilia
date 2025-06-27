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

lia.command.add("managesitrooms", {
    superAdminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("manageSitroomsDesc"),
    onRun = function(client)
        if not client:hasPrivilege("Manage SitRooms") then return end
        local mapName = game.GetMap()
        local sitrooms = lia.data.get("sitrooms", {}, true, true)
        local rooms = sitrooms[mapName] or {}
        net.Start("managesitrooms")
        net.WriteTable(rooms)
        net.Send(client)
    end
})

lia.command.add("addsitroom", {
    superAdminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("setSitroomDesc"),
    onRun = function(client)
        client:requestString(L("enterNamePrompt"), L("enterSitroomPrompt"), function(name)
            if name == "" then
                client:notifyLocalized("invalidName")
                return
            end

            local mapName = game.GetMap()
            local sitrooms = lia.data.get("sitrooms", {}, true, true)
            sitrooms[mapName] = sitrooms[mapName] or {}
            sitrooms[mapName][name] = client:GetPos()
            lia.data.set("sitrooms", sitrooms, true, true)
            client:notifyLocalized("sitroomSet")
            lia.log.add(client, "sitRoomSet", string.format("Map: %s | Name: %s | Position: %s", mapName, name, tostring(client:GetPos())), "Set the sitroom location")
        end)
    end
})

lia.command.add("sendtositroom", {
    adminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("sendToSitRoomDesc"),
    syntax = "[player Player Name]",
    AdminStick = {
        Name = L("sendToSitRoom"),
        Category = "moderationTools",
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
        local rooms = sitrooms[mapName] or {}
        local names = {}
        for name in pairs(rooms) do
            names[#names + 1] = name
        end

        if #names == 0 then
            client:notifyLocalized("sitroomNotSet")
            return
        end

        client:requestDropdown(L("chooseSitroomTitle"), L("selectSitroomPrompt"), names, function(selection)
            local pos = rooms[selection]
            if not pos then
                client:notifyLocalized("sitroomNotSet")
                return
            end

            target:SetPos(pos)
            client:notifyLocalized("sitroomTeleport", target:Nick())
            target:notifyLocalized("sitroomArrive")
            lia.log.add(client, "sendToSitRoom", target:Nick(), selection)
        end)
    end
})

lia.command.add("returnsitroom", {
    adminOnly = true,
    privilege = "Manage SitRooms",
    desc = L("returnFromSitroomDesc"),
    syntax = "[player Player Name]",
    AdminStick = {
        Name = L("returnFromSitroom"),
        Category = "moderationTools",
        SubCategory = L("misc"),
        Icon = "icon16/arrow_up.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local prev = target:GetNWVector("previousSitroomPos")
        if not prev then
            client:notifyLocalized("noPreviousSitroomPos")
            return
        end

        target:SetPos(prev)
        client:notifyLocalized("sitroomReturnSuccess", target:Nick())
        if target ~= client then target:notifyLocalized("sitroomReturned") end
        lia.log.add(client, "sitRoomReturn", target:Nick())
    end
})
