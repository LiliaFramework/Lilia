lia.command.add("plykick", {
    adminOnly = true,
    syntax = "<string name> [string reason]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Kick(L("kickMessage", target, arguments[2] or L("genericReason")))
                client:notifyLocalized("plyKicked")
            end
        end
    end
})

lia.command.add("plyban", {
    adminOnly = true,
    syntax = "<string name> [number duration] [string reason]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:banPlayer(arguments[3] or L("genericReason"), arguments[2])
                client:notifyLocalized("plyBanned")
            end
        end
    end
})

lia.command.add("plykill", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Kill()
                client:notifyLocalized("plyKilled")
            end
        end
    end
})

lia.command.add("plysetgroup", {
    adminOnly = true,
    syntax = "<string name> <string group>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and lia.admin.groups[arguments[2]] then
                lia.admin.setPlayerGroup(target, arguments[2])
                client:notifyLocalized("plyGroupSet")
            elseif IsValid(target) and not lia.admin.groups[arguments[2]] then
                client:notifyLocalized("groupNotExists")
            end
        end
    end
})

lia.command.add("plyunban", {
    adminOnly = true,
    syntax = "<string steamid>",
    onRun = function(client, arguments)
        if SERVER then
            local steamid = arguments[1]
            if steamid and steamid ~= "" then
                lia.admin.removeBan(steamid)
                client:notify("Player unbanned")
            end
        end
    end
})

lia.command.add("plyfreeze", {
    adminOnly = true,
    syntax = "<string name> [number duration]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Freeze(true)
                local dur = tonumber(arguments[2]) or 0
                if dur > 0 then timer.Simple(dur, function() if IsValid(target) then target:Freeze(false) end end) end
            end
        end
    end
})

lia.command.add("plyunfreeze", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:Freeze(false) end
        end
    end
})

lia.command.add("plyslay", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:Kill() end
        end
    end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:Spawn() end
        end
    end
})

lia.command.add("plyblind", {
    adminOnly = true,
    syntax = "<string name> [number time]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                net.Start("blindTarget")
                net.WriteBool(true)
                net.Send(target)

                local dur = tonumber(arguments[2])
                if dur and dur > 0 then
                    timer.Create("liaBlind" .. target:SteamID(), dur, 1, function()
                        if IsValid(target) then
                            net.Start("blindTarget")
                            net.WriteBool(false)
                            net.Send(target)
                        end
                    end)
                end
            end
        end
    end
})

lia.command.add("plyunblind", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                net.Start("blindTarget")
                net.WriteBool(false)
                net.Send(target)
            end
        end
    end
})

lia.command.add("plyblindfade", {
    adminOnly = true,
    syntax = "<string name> <number time> [string color] [number fadein] [number fadeout]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local duration = tonumber(arguments[2]) or 0
                local colorName = (arguments[3] or "black"):lower()
                local fadeIn = tonumber(arguments[4])
                local fadeOut = tonumber(arguments[5])

                fadeIn = fadeIn or duration * 0.05
                fadeOut = fadeOut or duration * 0.05

                net.Start("blindFade")
                net.WriteBool(colorName == "white")
                net.WriteFloat(duration)
                net.WriteFloat(fadeIn)
                net.WriteFloat(fadeOut)
                net.Send(target)
            end
        end
    end
})

lia.command.add("blindfadeall", {
    adminOnly = true,
    syntax = "<number time> [string color] [number fadein] [number fadeout]",
    onRun = function(client, arguments)
        if SERVER then
            local duration = tonumber(arguments[1]) or 0
            local colorName = (arguments[2] or "black"):lower()
            local fadeIn = tonumber(arguments[3]) or (duration * 0.05)
            local fadeOut = tonumber(arguments[4]) or (duration * 0.05)
            local isWhite = colorName == "white"

            for _, ply in player.Iterator() do
                if not ply:isStaffOnDuty() then
                    net.Start("blindFade")
                    net.WriteBool(isWhite)
                    net.WriteFloat(duration)
                    net.WriteFloat(fadeIn)
                    net.WriteFloat(fadeOut)
                    net.Send(ply)
                end
            end
        end
    end
})

lia.command.add("plygag", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:setNetVar("liaGagged", true) end
        end
    end
})

lia.command.add("plyungag", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:setNetVar("liaGagged", false) end
        end
    end
})

lia.command.add("plymute", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then target:getChar():setData("VoiceBan", true) end
        end
    end
})

lia.command.add("plyunmute", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then target:getChar():setData("VoiceBan", false) end
        end
    end
})

local returnPositions = {}
lia.command.add("plybring", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                returnPositions[target] = target:GetPos()
                target:SetPos(client:GetPos() + client:GetForward() * 50)
            end
        end
    end
})

lia.command.add("plygoto", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                returnPositions[client] = client:GetPos()
                client:SetPos(target:GetPos() + target:GetForward() * 50)
            end
        end
    end
})

lia.command.add("plyreturn", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            target = IsValid(target) and target or client
            local pos = returnPositions[target]
            if pos then
                target:SetPos(pos)
                returnPositions[target] = nil
            end
        end
    end
})

lia.command.add("plyjail", {
    adminOnly = true,
    syntax = "<string name> [number duration]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Lock()
                target:Freeze(true)
            end
        end
    end
})

lia.command.add("plyunjail", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:UnLock()
                target:Freeze(false)
            end
        end
    end
})

lia.command.add("plycloak", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:SetNoDraw(true) end
        end
    end
})

lia.command.add("plyuncloak", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:SetNoDraw(false) end
        end
    end
})

lia.command.add("plygod", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:GodEnable() end
        end
    end
})

lia.command.add("plyungod", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:GodDisable() end
        end
    end
})

lia.command.add("plyignite", {
    adminOnly = true,
    syntax = "<string name> [number duration]",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:Ignite(tonumber(arguments[2]) or 5) end
        end
    end
})

lia.command.add("plyextinguish", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:Extinguish() end
        end
    end
})

lia.command.add("plystrip", {
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        if SERVER then
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then target:StripWeapons() end
        end
    end
})

lia.command.add("adminmode", {
    desc = "adminModeDesc",
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
                lia.log.add(client, "adminMode", oldCharID, L("adminModeLogBack"))
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
                        lia.log.add(client, "adminMode", id, L("adminModeLogStaff"))
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
    desc = "manageSitroomsDesc",
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
    desc = "setSitroomDesc",
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
    desc = "sendToSitRoomDesc",
    syntax = "[player Player Name]",
    AdminStick = {
        Name = "sendToSitRoom",
        Category = "moderationTools",
        SubCategory = "misc",
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
    desc = "returnFromSitroomDesc",
    syntax = "[player Player Name]",
    AdminStick = {
        Name = "returnFromSitroom",
        Category = "moderationTools",
        SubCategory = "misc",
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