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

if not lia.admin.isDisabled() then
    lia.command.add("plykick", {
        adminOnly = true,
        privilege = "Kick Player",
        desc = "plyKickDesc",
        syntax = "<string name> [string reason]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Kick(L("kickMessage", target, arguments[2] or L("genericReason")))
                client:notifyLocalized("plyKicked")
                lia.log.add(client, "plyKick", target:Name())
            end
        end
    })

    lia.command.add("plyban", {
        adminOnly = true,
        privilege = "Ban Player",
        desc = "plyBanDesc",
        syntax = "<string name> [number duration] [string reason]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:banPlayer(arguments[3] or L("genericReason"), arguments[2])
                client:notifyLocalized("plyBanned")
                lia.log.add(client, "plyBan", target:Name())
            end
        end
    })

    lia.command.add("plykill", {
        adminOnly = true,
        privilege = "Kill Player",
        desc = "plyKillDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Kill()
                client:notifyLocalized("plyKilled")
                lia.log.add(client, "plyKill", target:Name())
            end
        end
    })

    lia.command.add("plysetgroup", {
        adminOnly = true,
        privilege = "Set Player Group",
        desc = "plySetGroupDesc",
        syntax = "<string name> <string group>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and lia.admin.groups[arguments[2]] then
                lia.admin.setPlayerGroup(target, arguments[2])
                client:notifyLocalized("plyGroupSet")
                lia.log.add(client, "plySetGroup", target:Name(), arguments[2])
            elseif IsValid(target) and not lia.admin.groups[arguments[2]] then
                client:notifyLocalized("groupNotExists")
            end
        end
    })

    lia.command.add("plyunban", {
        adminOnly = true,
        privilege = "Unban Player",
        desc = "plyUnbanDesc",
        syntax = "<string steamid>",
        onRun = function(client, arguments)
            local steamid = arguments[1]
            if steamid and steamid ~= "" then
                lia.admin.removeBan(steamid)
                client:notify("Player unbanned")
                lia.log.add(client, "plyUnban", steamid)
            end
        end
    })

    lia.command.add("plyfreeze", {
        adminOnly = true,
        privilege = "Freeze Player",
        desc = "plyFreezeDesc",
        syntax = "<string name> [number duration]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Freeze(true)
                local dur = tonumber(arguments[2]) or 0
                if dur > 0 then timer.Simple(dur, function() if IsValid(target) then target:Freeze(false) end end) end
                lia.log.add(client, "plyFreeze", target:Name(), dur)
            end
        end
    })

    lia.command.add("plyunfreeze", {
        adminOnly = true,
        privilege = "Unfreeze Player",
        desc = "plyUnfreezeDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Freeze(false)
                lia.log.add(client, "plyUnfreeze", target:Name())
            end
        end
    })

    lia.command.add("plyslay", {
        adminOnly = true,
        privilege = "Slay Player",
        desc = "plySlayDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Kill()
                lia.log.add(client, "plySlay", target:Name())
            end
        end
    })

    lia.command.add("plyrespawn", {
        adminOnly = true,
        privilege = "Respawn Player",
        desc = "plyRespawnDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Spawn()
                lia.log.add(client, "plyRespawn", target:Name())
            end
        end
    })

    lia.command.add("plyblind", {
        adminOnly = true,
        privilege = "Blind Player",
        desc = "plyBlindDesc",
        syntax = "<string name> [number time]",
        onRun = function(client, arguments)
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

                lia.log.add(client, "plyBlind", target:Name(), dur or 0)
            end
        end
    })

    lia.command.add("plyunblind", {
        adminOnly = true,
        privilege = "Unblind Player",
        desc = "plyUnblindDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                net.Start("blindTarget")
                net.WriteBool(false)
                net.Send(target)
                lia.log.add(client, "plyUnblind", target:Name())
            end
        end
    })

    lia.command.add("plyblindfade", {
        adminOnly = true,
        privilege = "Blind Fade Player",
        desc = "plyBlindFadeDesc",
        syntax = "<string name> <number time> [string color] [number fadein] [number fadeout]",
        onRun = function(client, arguments)
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
                lia.log.add(client, "plyBlindFade", target:Name(), duration, colorName)
            end
        end
    })

    lia.command.add("blindfadeall", {
        adminOnly = true,
        privilege = "Blind Fade All",
        desc = "blindFadeAllDesc",
        syntax = "<number time> [string color] [number fadein] [number fadeout]",
        onRun = function(_, arguments)
            local duration = tonumber(arguments[1]) or 0
            local colorName = (arguments[2] or "black"):lower()
            local fadeIn = tonumber(arguments[3]) or duration * 0.05
            local fadeOut = tonumber(arguments[4]) or duration * 0.05
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
    })

    lia.command.add("plygag", {
        adminOnly = true,
        privilege = "Gag Player",
        desc = "plyGagDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:setNetVar("liaGagged", true)
                lia.log.add(client, "plyGag", target:Name())
                hook.Run("PlayerGagged", target, client)
            end
        end
    })

    lia.command.add("plyungag", {
        adminOnly = true,
        privilege = "Ungag Player",
        desc = "plyUngagDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:setNetVar("liaGagged", false)
                lia.log.add(client, "plyUngag", target:Name())
                hook.Run("PlayerUngagged", target, client)
            end
        end
    })

    lia.command.add("plymute", {
        adminOnly = true,
        privilege = "Mute Player",
        desc = "plyMuteDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                target:getChar():setData("VoiceBan", true)
                lia.log.add(client, "plyMute", target:Name())
                hook.Run("PlayerMuted", target, client)
            end
        end
    })

    lia.command.add("plyunmute", {
        adminOnly = true,
        privilege = "Unmute Player",
        desc = "plyUnmuteDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                target:getChar():setData("VoiceBan", false)
                lia.log.add(client, "plyUnmute", target:Name())
                hook.Run("PlayerUnmuted", target, client)
            end
        end
    })

    local returnPositions = {}
    lia.command.add("plybring", {
        adminOnly = true,
        privilege = "Bring Player",
        desc = "plyBringDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                returnPositions[target] = target:GetPos()
                target:SetPos(client:GetPos() + client:GetForward() * 50)
                lia.log.add(client, "plyBring", target:Name())
            end
        end
    })

    lia.command.add("plygoto", {
        adminOnly = true,
        privilege = "Goto Player",
        desc = "plyGotoDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                returnPositions[client] = client:GetPos()
                client:SetPos(target:GetPos() + target:GetForward() * 50)
                lia.log.add(client, "plyGoto", target:Name())
            end
        end
    })

    lia.command.add("plyreturn", {
        adminOnly = true,
        privilege = "Return Player",
        desc = "plyReturnDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            target = IsValid(target) and target or client
            local pos = returnPositions[target]
            if pos then
                target:SetPos(pos)
                returnPositions[target] = nil
                lia.log.add(client, "plyReturn", target:Name())
            end
        end
    })

    lia.command.add("plyjail", {
        adminOnly = true,
        privilege = "Jail Player",
        desc = "plyJailDesc",
        syntax = "<string name> [number duration]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Lock()
                target:Freeze(true)
                lia.log.add(client, "plyJail", target:Name())
            end
        end
    })

    lia.command.add("plyunjail", {
        adminOnly = true,
        privilege = "Unjail Player",
        desc = "plyUnjailDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:UnLock()
                target:Freeze(false)
                lia.log.add(client, "plyUnjail", target:Name())
            end
        end
    })

    lia.command.add("plycloak", {
        adminOnly = true,
        privilege = "Cloak Player",
        desc = "plyCloakDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:SetNoDraw(true)
                lia.log.add(client, "plyCloak", target:Name())
            end
        end
    })

    lia.command.add("plyuncloak", {
        adminOnly = true,
        privilege = "Uncloak Player",
        desc = "plyUncloakDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:SetNoDraw(false)
                lia.log.add(client, "plyUncloak", target:Name())
            end
        end
    })

    lia.command.add("plygod", {
        adminOnly = true,
        privilege = "God Player",
        desc = "plyGodDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:GodEnable()
                lia.log.add(client, "plyGod", target:Name())
            end
        end
    })

    lia.command.add("plyungod", {
        adminOnly = true,
        privilege = "Ungod Player",
        desc = "plyUngodDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:GodDisable()
                lia.log.add(client, "plyUngod", target:Name())
            end
        end
    })

    lia.command.add("plyignite", {
        adminOnly = true,
        privilege = "Ignite Player",
        desc = "plyIgniteDesc",
        syntax = "<string name> [number duration]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local dur = tonumber(arguments[2]) or 5
                target:Ignite(dur)
                lia.log.add(client, "plyIgnite", target:Name(), dur)
            end
        end
    })

    lia.command.add("plyextinguish", {
        adminOnly = true,
        privilege = "Extinguish Player",
        desc = "plyExtinguishDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:Extinguish()
                lia.log.add(client, "plyExtinguish", target:Name())
            end
        end
    })

    lia.command.add("plystrip", {
        adminOnly = true,
        privilege = "Strip Player",
        desc = "plyStripDesc",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                target:StripWeapons()
                lia.log.add(client, "plyStrip", target:Name())
            end
        end
    })
end