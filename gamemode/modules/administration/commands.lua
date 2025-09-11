lia.command.add("playtime", {
    adminOnly = false,
    desc = "playtimeDesc",
    onRun = function(client)
        local secs = client:getPlayTime()
        if not secs then
            client:notifyLocalized("playtimeError")
            return
        end

        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:notifyLocalized("playtimeYour", h, m, s)
    end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetPlayTimeName",
        Category = "moderation",
        SubCategory = "misc",
        Icon = "icon16/time.png"
    },
    desc = "plygetplaytimeDesc",
    onRun = function(client, args)
        if not args[1] then
            client:notifyLocalized("specifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local secs = target:getPlayTime()
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:ChatPrint(L("playtimeFor", target:Nick(), h, m, s))
    end
})

lia.command.add("managesitrooms", {
    superAdminOnly = true,
    desc = "manageSitroomsDesc",
    onRun = function(client)
        if not client:hasPrivilege("manageSitRooms") then return end
        local rooms = lia.data.get("sitrooms", {})
        net.Start("managesitrooms")
        net.WriteTable(rooms)
        net.Send(client)
    end
})

lia.command.add("addsitroom", {
    superAdminOnly = true,
    desc = "setSitroomDesc",
    onRun = function(client)
        client:requestString(L("enterNamePrompt"), L("enterSitroomPrompt") .. ":", function(name)
            if name == "" then
                client:notifyLocalized("invalidName")
                return
            end

            local rooms = lia.data.get("sitrooms", {})
            rooms[name] = client:GetPos()
            lia.data.set("sitrooms", rooms)
            client:notifyLocalized("sitroomSet")
            lia.log.add(client, "sitRoomSet", L("sitroomSetDetail", name, tostring(client:GetPos())), L("logSetSitroom"))
        end)
    end
})

lia.command.add("sendtositroom", {
    adminOnly = true,
    desc = "sendToSitRoomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "sendToSitRoom",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/arrow_down.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local rooms = lia.data.get("sitrooms", {})
        local names = {}
        for n in pairs(rooms) do
            names[#names + 1] = n
        end

        if #names == 0 then
            client:notifyLocalized("sitroomNotSet")
            return
        end

        client:requestDropdown(L("chooseSitroomTitle"), L("selectSitroomPrompt") .. ":", names, function(selection)
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
    desc = "returnFromSitroomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "returnFromSitroom",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/arrow_up.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local prev = target:getNetVar("previousSitroomPos")
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

lia.command.add("charkill", {
    superAdminOnly = true,
    desc = "charkillDesc",
    AdminStick = {
        Name = "adminStickCharKillName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client)
        local choices = {}
        for _, ply in player.Iterator() do
            if ply:getChar() then
                choices[#choices + 1] = {
                    ply:Nick(),
                    {
                        name = ply:Nick(),
                        steamID = ply:SteamID(),
                        charID = ply:getChar():getID()
                    }
                }
            end
        end

        local playerKey = L("player")
        local reasonKey = L("reason")
        local evidenceKey = L("evidence")
        client:requestArguments(L("pkActiveMenu"), {
            [playerKey] = {"table", choices},
            [reasonKey] = "string",
            [evidenceKey] = "string"
        }, function(data)
            local selection = data[playerKey]
            local reason = data[reasonKey]
            local evidence = data[evidenceKey]
            if not (isstring(evidence) and evidence:match("^https?://")) then
                client:notifyLocalized("evidenceInvalidURL")
                return
            end

            lia.db.insertTable({
                player = selection.name,
                reason = reason,
                steamID = selection.steamID,
                charID = selection.charID,
                submitterName = client:Name(),
                submitterSteamID = client:SteamID(),
                timestamp = os.time(),
                evidence = evidence
            }, nil, "permakills")

            for _, ply in player.Iterator() do
                if ply:SteamID() == selection.steamID and ply:getChar() then
                    ply:getChar():ban()
                    break
                end
            end
        end)
    end
})

local function sanitizeForNet(tbl)
    if istable(tbl) then return tbl end
    local result = {}
    for k, v in pairs(tbl) do
        if istable(c) then
            result[k] = sanitizeForNet(v)
        elseif not isfunction(v) then
            result[k] = v
        end
    end
    return result
end

lia.command.add("charlist", {
    adminOnly = true,
    desc = "charListDesc",
    arguments = {
        {
            name = "playerOrSteamId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickOpenCharListName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local identifier = arguments[1]
        local target
        local steamID
        if identifier then
            target = lia.util.findPlayer(client, identifier)
            if IsValid(target) then
                steamID = target:SteamID()
            elseif identifier:match("^STEAM_%d:%d:%d+$") then
                steamID = identifier
            else
                client:notifyLocalized("targetNotFound")
                return
            end
        else
            steamID = client:SteamID()
        end

        lia.db.selectWithCondition({"c.*", "d.value AS charBanInfo"}, "characters", "AS c LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.key = 'charBanInfo' WHERE c.steamID = " .. lia.db.convertDataType(steamID)):next(function(data)
            if not data or not data.results or #data.results == 0 then
                client:notifyLocalized("noCharactersForPlayer")
                return
            end

            local sendData = {}
            for _, row in ipairs(data.results) do
                local charID = tonumber(row.id) or row.id
                local stored = lia.char.getCharacter(charID)
                local info = stored and stored:getData() or {}
                local allVars = {}
                if stored then
                    for varName in pairs(lia.char.vars) do
                        local value
                        if varName == "data" then
                            value = stored:getData()
                        elseif varName == "var" then
                            value = stored:getVar()
                        else
                            local getter = stored["get" .. varName:sub(1, 1):upper() .. varName:sub(2)]
                            if isfunction(getter) then
                                value = getter(stored)
                            else
                                value = stored.vars and stored.vars[varName]
                            end
                        end

                        allVars[varName] = value
                    end
                end

                local banInfo = info.charBanInfo
                if not banInfo and row.charBanInfo and row.charBanInfo ~= "" then
                    local ok, decoded = pcall(pon.decode, row.charBanInfo)
                    if ok then
                        banInfo = decoded and decoded[1] or {}
                    else
                        banInfo = util.JSONToTable(row.charBanInfo) or {}
                    end
                end

                local bannedVal = stored and stored:getBanned() or tonumber(row.banned) or 0
                local isBanned = bannedVal ~= 0 and (bannedVal == -1 or bannedVal > os.time())
                local entry = {
                    ID = charID,
                    Name = stored and stored:getName() or row.name,
                    Desc = row.desc,
                    Faction = row.faction,
                    Banned = isBanned and L("yes") or L("no"),
                    BanningAdminName = banInfo and banInfo.name or "",
                    BanningAdminSteamID = banInfo and banInfo.steamID or "",
                    BanningAdminRank = banInfo and banInfo.rank or "",
                    Money = row.money,
                    LastUsed = stored and L("onlineNow") or row.lastJoinTime,
                    allVars = allVars
                }

                entry.extraDetails = {}
                hook.Run("CharListExtraDetails", client, entry, stored)
                entry = sanitizeForNet(entry)
                table.insert(sendData, entry)
            end

            sendData = sanitizeForNet(sendData)
            net.Start("DisplayCharList")
            net.WriteTable(sendData)
            net.WriteString(steamID)
            net.Send(client)
        end)
    end
})

lia.command.add("plyban", {
    adminOnly = true,
    desc = "plyBanDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
        {
            name = "reason",
            type = "string"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ban", arguments[1], arguments[2], arguments[3], client) end
})

lia.command.add("plykick", {
    adminOnly = true,
    desc = "plyKickDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "reason",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("kick", arguments[1], nil, arguments[2], client) end
})

lia.command.add("plykill", {
    adminOnly = true,
    desc = "plyKillDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("kill", arguments[1], nil, nil, client) end
})

lia.command.add("plyunban", {
    adminOnly = true,
    desc = "plyUnbanDesc",
    arguments = {
        {
            name = "steamid",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local steamid = arguments[1]
        if steamid and steamid ~= "" then
            lia.db.delete("bans", "playerSteamID = " .. steamid)
            client:notifyLocalized("playerUnbanned")
            lia.log.add(client, "plyUnban", steamid)
        end
    end
})

lia.command.add("plyfreeze", {
    adminOnly = true,
    desc = "plyFreezeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("freeze", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunfreeze", {
    adminOnly = true,
    desc = "plyUnfreezeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unfreeze", arguments[1], nil, nil, client) end
})

lia.command.add("plyslay", {
    adminOnly = true,
    desc = "plySlayDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("slay", arguments[1], nil, nil, client) end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    desc = "plyRespawnDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("respawn", arguments[1], nil, nil, client) end
})

lia.command.add("plyblind", {
    adminOnly = true,
    desc = "plyBlindDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("blind", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunblind", {
    adminOnly = true,
    desc = "plyUnblindDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unblind", arguments[1], nil, nil, client) end
})

lia.command.add("plyblindfade", {
    adminOnly = true,
    desc = "plyBlindFadeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "color",
            type = "string",
            optional = true
        },
        {
            name = "fadein",
            type = "string",
            optional = true
        },
        {
            name = "fadeout",
            type = "string",
            optional = true
        },
    },
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
    desc = "blindFadeAllDesc",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "color",
            type = "string",
            optional = true
        },
        {
            name = "fadein",
            type = "string",
            optional = true
        },
        {
            name = "fadeout",
            type = "string",
            optional = true
        },
    },
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
    desc = "plyGagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("gag", arguments[1], nil, nil, client) end
})

lia.command.add("plyungag", {
    adminOnly = true,
    desc = "plyUngagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ungag", arguments[1], nil, nil, client) end
})

lia.command.add("plymute", {
    adminOnly = true,
    desc = "plyMuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("mute", arguments[1], nil, nil, client) end
})

lia.command.add("plyunmute", {
    adminOnly = true,
    desc = "plyUnmuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unmute", arguments[1], nil, nil, client) end
})

lia.command.add("plybring", {
    adminOnly = true,
    desc = "plyBringDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("bring", arguments[1], nil, nil, client) end
})

lia.command.add("plygoto", {
    adminOnly = true,
    desc = "plyGotoDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("goto", arguments[1], nil, nil, client) end
})

lia.command.add("plyreturn", {
    adminOnly = true,
    desc = "plyReturnDesc",
    arguments = {
        {
            name = "name",
            type = "player",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("return", arguments[1] or client:Name(), nil, nil, client) end
})

lia.command.add("plyjail", {
    adminOnly = true,
    desc = "plyJailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("jail", arguments[1], nil, nil, client) end
})

lia.command.add("plyunjail", {
    adminOnly = true,
    desc = "plyUnjailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unjail", arguments[1], nil, nil, client) end
})

lia.command.add("plycloak", {
    adminOnly = true,
    desc = "plyCloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("cloak", arguments[1], nil, nil, client) end
})

lia.command.add("plyuncloak", {
    adminOnly = true,
    desc = "plyUncloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("uncloak", arguments[1], nil, nil, client) end
})

lia.command.add("plygod", {
    adminOnly = true,
    desc = "plyGodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("god", arguments[1], nil, nil, client) end
})

lia.command.add("plyungod", {
    adminOnly = true,
    desc = "plyUngodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ungod", arguments[1], nil, nil, client) end
})

lia.command.add("plyignite", {
    adminOnly = true,
    desc = "plyIgniteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ignite", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyextinguish", {
    adminOnly = true,
    desc = "plyExtinguishDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("extinguish", arguments[1], nil, nil, client) end
})

lia.command.add("plystrip", {
    adminOnly = true,
    desc = "plyStripDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("strip", arguments[1], nil, nil, client) end
})

lia.command.add("pktoggle", {
    adminOnly = true,
    desc = "togglePermakillDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickTogglePermakillName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if not character then
            client:notifyLocalized("invalid", L("character"))
            return
        end

        local currentState = character:getMarkedForDeath()
        local newState = not currentState
        character:setMarkedForDeath(newState)
        if newState then
            client:notifyLocalized("pktoggle_true")
        else
            client:notifyLocalized("pktoggle_false")
        end
    end
})

lia.command.add("charunbanoffline", {
    superAdminOnly = true,
    desc = "charUnbanOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyLocalized("invalidCharID") end
        local banned = lia.char.getCharBanned(charID)
        if banned == nil then return client:notifyLocalized("characterNotFound") end
        lia.char.setCharDatabase(charID, "banned", 0)
        lia.char.setCharDatabase(charID, "charBanInfo", nil)
        client:notifyLocalized("offlineCharUnbanned", charID)
        lia.log.add(client, "charUnbanOffline", charID)
    end
})

lia.command.add("charbanoffline", {
    superAdminOnly = true,
    desc = "charBanOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyLocalized("invalidCharID") end
        local banned = lia.char.getCharBanned(charID)
        if banned == nil then return client:notifyLocalized("characterNotFound") end
        lia.char.setCharDatabase(charID, "banned", -1)
        lia.char.setCharDatabase(charID, "charBanInfo", {
            name = client:Nick(),
            steamID = client:SteamID(),
            rank = client:GetUserGroup()
        })

        for _, ply in player.Iterator() do
            if ply:getChar() and ply:getChar():getID() == charID then
                ply:Kick(L("youHaveBeenBanned"))
                break
            end
        end

        client:notifyLocalized("offlineCharBanned", charID)
        lia.log.add(client, "charBanOffline", charID)
    end
})

lia.command.add("playglobalsound", {
    superAdminOnly = true,
    desc = "playGlobalSoundDesc",
    arguments = {
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local sound = arguments[1]
        if not sound or sound == "" then
            client:notifyLocalized("mustSpecifySound")
            return
        end

        for _, target in player.Iterator() do
            target:PlaySound(sound)
        end
    end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    desc = "playSoundDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local sound = arguments[2]
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not sound or sound == "" then
            client:notifyLocalized("noSound")
            return
        end

        target:PlaySound(sound)
    end
})

lia.command.add("returntodeathpos", {
    adminOnly = true,
    desc = "returnToDeathPosDesc",
    onRun = function(client)
        if IsValid(client) and client:Alive() then
            local character = client:getChar()
            local oldPos = character and character:getData("deathPos")
            if oldPos then
                client:SetPos(oldPos)
                character:setData("deathPos", nil)
            else
                client:notifyLocalized("noDeathPosition")
            end
        else
            client:notifyLocalized("waitRespawn")
        end
    end
})

lia.command.add("roll", {
    adminOnly = false,
    desc = "rollDesc",
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
    end
})

lia.command.add("forcefallover", {
    adminOnly = true,
    desc = "forceFalloverDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target:getNetVar("FallOverCooldown", false) then
            target:notifyLocalized("cmdCooldown")
            return
        elseif target:IsFrozen() then
            target:notifyLocalized("cmdFrozen")
            return
        elseif not target:Alive() then
            target:notifyLocalized("cmdDead")
            return
        elseif target:hasValidVehicle() then
            target:notifyLocalized("cmdVehicle")
            return
        elseif target:isNoClipping() then
            target:notifyLocalized("cmdNoclip")
            return
        end

        local time = tonumber(arguments[2])
        if not time or time < 1 then
            time = 5
        else
            time = math.Clamp(time, 1, 60)
        end

        target:setNetVar("FallOverCooldown", true)
        if not IsValid(target:getRagdoll()) then
            target:setRagdolled(true, time)
            timer.Simple(10, function() if IsValid(target) then target:setNetVar("FallOverCooldown", false) end end)
        end
    end
})

lia.command.add("forcegetup", {
    adminOnly = true,
    desc = "forceGetUpDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not IsValid(target:getRagdoll()) then
            target:notifyLocalized("noRagdoll")
            return
        end

        local entity = target:getRagdoll()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            target:setAction("gettingUp", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", target, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end
})

lia.command.add("chardesc", {
    adminOnly = false,
    desc = "changeCharDesc",
    arguments = {
        {
            name = "desc",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local desc = table.concat(arguments, " ")
        if not desc:find("%S") then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar() and client:getChar():getDesc() or "") end
        local character = client:getChar()
        if character then character:setDesc(desc) end
        return "@descChanged"
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    desc = "forceSelfGetUpDesc",
    onRun = function(client)
        if not IsValid(client:getRagdoll()) then
            client:notifyLocalized("noRagdoll")
            return
        end

        local entity = client:getRagdoll()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("gettingUp", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", client, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end,
    alias = {"getup"}
})

lia.command.add("fallover", {
    adminOnly = false,
    desc = "fallOverDesc",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        if client:getNetVar("FallOverCooldown", false) then
            client:notifyLocalized("cmdCooldown")
            return
        end

        if client:IsFrozen() then
            client:notifyLocalized("cmdFrozen")
            return
        end

        if not client:Alive() then
            client:notifyLocalized("cmdDead")
            return
        end

        if client:hasValidVehicle() then
            client:notifyLocalized("cmdVehicle")
            return
        end

        if client:isNoClipping() then
            client:notifyLocalized("cmdNoclip")
            return
        end

        local t = tonumber(arguments[1])
        if not t or t < 1 then
            t = 5
        else
            t = math.Clamp(t, 1, 60)
        end

        client:setNetVar("FallOverCooldown", true)
        if not IsValid(client:getRagdoll()) then
            client:setRagdolled(true, t)
            timer.Simple(10, function() if IsValid(client) then client:setNetVar("FallOverCooldown", false) end end)
        end
    end
})

lia.command.add("togglelockcharacters", {
    superAdminOnly = true,
    desc = "toggleCharLockDesc",
    onRun = function()
        local newVal = not GetGlobalBool("characterSwapLock", false)
        SetGlobalBool("characterSwapLock", newVal)
        if not newVal then
            return L("characterLockDisabled")
        else
            return L("characterLockEnabled")
        end
    end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    desc = "checkInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCheckInventoryName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyLocalized("invCheckSelf")
            return
        end

        local inventory = target:getChar():getInv()
        inventory:addAccessRule(function(_, action, _) return action == "transfer" end, 1)
        inventory:addAccessRule(function(_, action, _) return action == "repl" end, 1)
        inventory:sync(client)
        net.Start("OpenInvMenu")
        net.WriteEntity(target)
        net.WriteType(inventory:getID())
        net.Send(client)
    end
})

lia.command.add("flaggive", {
    adminOnly = true,
    desc = "flagGiveDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local available = ""
            for k in SortedPairs(lia.flag.list) do
                if not target:hasFlags(k) then available = available .. k .. " " end
            end

            available = available:Trim()
            if available == "" then
                client:notifyLocalized("noAvailableFlags")
                return
            end
            return client:requestString(L("give") .. " " .. L("flags"), L("flagGiveDesc"), function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
        end

        target:giveFlags(flags)
        client:notifyLocalized("flagGive", client:Name(), flags, target:Name())
        lia.log.add(client, "flagGive", target:Name(), flags)
    end,
    alias = {"giveflag", "chargiveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    desc = "giveAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not target:hasFlags(k) then target:giveFlags(k) end
        end

        client:notifyLocalized("gaveAllFlags")
        lia.log.add(client, "flagGiveAll", target:Name())
    end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    desc = "takeAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickTakeAllFlagsName",
        Category = "flagManagement",
        SubCategory = "characterFlags",
        Icon = "icon16/flag_green.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyLocalized("invalidTarget")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if target:hasFlags(k) then target:takeFlags(k) end
        end

        client:notifyLocalized("tookAllFlags")
        lia.log.add(client, "flagTakeAll", target:Name())
    end
})

lia.command.add("flagtake", {
    adminOnly = true,
    desc = "flagTakeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local currentFlags = target:getFlags()
            return client:requestString(L("take") .. " " .. L("flags"), L("flagTakeDesc"), function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, table.concat(currentFlags, ", "))
        end

        target:takeFlags(flags)
        client:notifyLocalized("flagTake", client:Name(), flags, target:Name())
        lia.log.add(client, "flagTake", target:Name(), flags)
    end,
    alias = {"takeflag"}
})

lia.command.add("pflaggive", {
    adminOnly = true,
    desc = "playerFlagGiveDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local available = ""
            for k in SortedPairs(lia.flag.list) do
                if not target:hasFlags(k, "player") then available = available .. k .. " " end
            end

            available = available:Trim()
            if available == "" then
                client:notifyLocalized("noAvailableFlags")
                return
            end
            return client:requestString(L("give") .. " " .. L("flags"), L("playerFlagGiveDesc"), function(text) lia.command.run(client, "pflaggive", {target:Name(), text}) end, available)
        end

        target:giveFlags(flags, "player")
        client:notifyLocalized("playerFlagGive", client:Name(), flags, target:Name())
        lia.log.add(client, "playerFlagGive", target:Name(), flags)
    end,
    alias = {"givepflag", "playerflaggive"}
})

lia.command.add("pflaggiveall", {
    adminOnly = true,
    desc = "giveAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not target:hasFlags(k, "player") then target:giveFlags(k, "player") end
        end

        client:notifyLocalized("gaveAllFlags")
        lia.log.add(client, "playerFlagGiveAll", target:Name())
    end
})

lia.command.add("pflagtakeall", {
    adminOnly = true,
    desc = "takeAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickTakeAllFlagsName",
        Category = "flagManagement",
        SubCategory = "playerFlags",
        Icon = "icon16/flag_green.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if target:hasFlags(k, "player") then target:takeFlags(k, "player") end
        end

        client:notifyLocalized("tookAllFlags")
        lia.log.add(client, "playerFlagTakeAll", target:Name())
    end
})

lia.command.add("pflagtake", {
    adminOnly = true,
    desc = "playerFlagTakeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local currentFlags = target:getFlags("player")
            return client:requestString(L("take") .. " " .. L("flags"), L("playerFlagTakeDesc"), function(text) lia.command.run(client, "pflagtake", {target:Name(), text}) end, currentFlags)
        end

        target:takeFlags(flags, "player")
        client:notifyLocalized("playerFlagTake", client:Name(), flags, target:Name())
        lia.log.add(client, "playerFlagTake", target:Name(), flags)
    end,
    alias = {"takepflag", "playerflagtake"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    desc = "bringLostItemsDesc",
    onRun = function(client)
        for _, v in ipairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("charvoicetoggle", {
    adminOnly = true,
    desc = "charVoiceToggleDesc",
    arguments = {
        {
            name = "name",
            type = "string"
        },
    },
    AdminStick = {
        Name = "toggleVoice",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyLocalized("cannotMuteSelf")
            return false
        end

        if target:getChar() then
            local isBanned = target:getLiliaData("VoiceBan", false)
            target:setLiliaData("VoiceBan", not isBanned)
            if isBanned then
                client:notifyLocalized("voiceUnmuted", target:Name())
                target:notifyLocalized("voiceUnmutedByAdmin")
            else
                client:notifyLocalized("voiceMuted", target:Name())
                target:notifyLocalized("voiceMutedByAdmin")
            end

            lia.log.add(client, "voiceToggle", target:Name(), isBanned and L("unmuted") or L("muted"))
        else
            client:notifyLocalized("noValidCharacter")
        end
    end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    desc = "cleanItemsDesc",
    onRun = function(client)
        local count = 0
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            count = count + 1
            SafeRemoveEntity(v)
        end

        client:notifyLocalized("cleaningFinished", L("items"), count)
    end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    desc = "cleanPropsDesc",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:isProp() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifyLocalized("cleaningFinished", L("props"), count)
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    desc = "cleanNPCsDesc",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:IsNPC() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifyLocalized("cleaningFinished", L("npcs"), count)
    end
})

lia.command.add("charunban", {
    superAdminOnly = true,
    desc = "charUnbanDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if (client.liaNextSearch or 0) >= CurTime() then return L("searchingChar") end
        local queryArg = table.concat(arguments, " ")
        local charFound
        local id = tonumber(queryArg)
        if id then
            for _, v in pairs(lia.char.getAll()) do
                if v:getID() == id then
                    charFound = v
                    break
                end
            end
        else
            for _, v in pairs(lia.char.getAll()) do
                if lia.util.stringMatches(v:getName(), queryArg) then
                    charFound = v
                    break
                end
            end
        end

        if charFound then
            if charFound:isBanned() then
                charFound:setBanned(0)
                charFound:setData("permakilled", nil)
                charFound:setData("charBanInfo", nil)
                charFound:save()
                client:notifyLocalized("charUnBan", client:Name(), charFound:getName())
                lia.log.add(client, "charUnban", charFound:getName(), charFound:getID())
            else
                return L("charNotBanned")
            end
        end

        client.liaNextSearch = CurTime() + 15
        local sqlCondition = id and ("id = " .. id) or ("name LIKE " .. lia.db.convertDataType("%" .. queryArg .. "%"))
        lia.db.selectOne({"id", "name"}, "characters", sqlCondition):next(function(data)
            if data then
                local charID = tonumber(data.id)
                local banned = lia.char.getCharBanned(charID)
                client.liaNextSearch = 0
                if not banned or banned == 0 then
                    client:notifyLocalized("charNotBanned")
                    return
                end

                lia.char.setCharDatabase(charID, "banned", 0)
                lia.char.setCharDatabase(charID, "charBanInfo", nil)
                client:notifyLocalized("charUnBan", client:Name(), data.name)
                lia.log.add(client, "charUnban", data.name, charID)
            end
        end)
    end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    desc = "clearInvDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickClearInventoryName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/bin.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():getInv():wipeItems()
        client:notifyLocalized("resetInv", target:getChar():getName())
    end
})

lia.command.add("charkick", {
    adminOnly = true,
    desc = "kickCharDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickKickCharacterName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            for _, targets in player.Iterator() do
                targets:notifyLocalized("charKick", client:Name(), target:Name())
            end

            character:kick()
            lia.log.add(client, "charKick", target:Name(), character:getID())
        else
            client:notifyLocalized("noChar")
        end
    end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    desc = "freezeAllPropsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local count = 0
        local tbl = cleanup.GetList(target)[target:UniqueID()] or {}
        for _, propTable in pairs(tbl) do
            for _, ent in pairs(propTable) do
                if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
                    ent:GetPhysicsObject():EnableMotion(false)
                    count = count + 1
                end
            end
        end

        client:notifyLocalized("freezeAllProps", target:Name())
        client:notifyLocalized("freezeAllPropsCount", count, target:Name())
    end
})

lia.command.add("charban", {
    superAdminOnly = true,
    desc = "banCharDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "banCharacter",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_red.png"
    },
    onRun = function(client, arguments)
        local queryArg = table.concat(arguments, " ")
        local target
        local id = tonumber(queryArg)
        if id then
            for _, ply in player.Iterator() do
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == id then
                    target = ply
                    break
                end
            end
        else
            target = lia.util.findPlayer(client, arguments[1])
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            character:setBanned(-1)
            character:setData("charBanInfo", {
                name = client.steamName and client:steamName() or client:Name(),
                steamID = client:SteamID(),
                rank = client:GetUserGroup()
            })

            character:save()
            character:kick()
            client:notifyLocalized("charBan", client:Name(), target:Name())
            lia.log.add(client, "charBan", target:Name(), character:getID())
        else
            client:notifyLocalized("noChar")
        end
    end
})

lia.command.add("charwipe", {
    superAdminOnly = true,
    desc = "charWipeDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "wipeCharacter",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local queryArg = table.concat(arguments, " ")
        local target
        local id = tonumber(queryArg)
        if id then
            for _, ply in player.Iterator() do
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == id then
                    target = ply
                    break
                end
            end
        else
            target = lia.util.findPlayer(client, arguments[1])
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            local charID = character:getID()
            local charName = character:getName()
            character:kick()
            lia.char.delete(charID, target)
            client:notifyLocalized("charWipe", client:Name(), charName)
            lia.log.add(client, "charWipe", charName, charID)
        else
            client:notifyLocalized("noChar")
        end
    end
})

lia.command.add("charwipeoffline", {
    superAdminOnly = true,
    desc = "charWipeOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyLocalized("invalidCharID") end
        lia.db.selectOne({"name"}, "characters", "id = " .. charID):next(function(data)
            if not data then
                client:notifyLocalized("characterNotFound")
                return
            end

            local charName = data.name
            for _, ply in player.Iterator() do
                if ply:getChar() and ply:getChar():getID() == charID then
                    ply:Kick(L("youHaveBeenWiped"))
                    break
                end
            end

            lia.char.delete(charID)
            client:notifyLocalized("offlineCharWiped", charID)
            lia.log.add(client, "charWipeOffline", charName, charID)
        end)
    end
})

lia.command.add("checkmoney", {
    adminOnly = true,
    desc = "checkMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCheckMoneyName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:notifyLocalized("playerMoney", target:GetName(), lia.currency.get(money))
    end
})

lia.command.add("listbodygroups", {
    adminOnly = true,
    desc = "listBodygroupsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local bodygroups = {}
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) > 1 then
                table.insert(bodygroups, {
                    group = i,
                    name = target:GetBodygroupName(i),
                    range = "0-" .. target:GetBodygroupCount(i) - 1
                })
            end
        end

        if #bodygroups > 0 then
            lia.util.SendTableUI(client, L("uiBodygroupsFor", target:Nick()), {
                {
                    name = "groupID",
                    field = "group"
                },
                {
                    name = "name",
                    field = "name"
                },
                {
                    name = "range",
                    field = "range"
                }
            }, bodygroups)
        else
            client:notifyLocalized("noBodygroups")
        end
    end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    desc = "setSpeedDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "speed",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharSpeedName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/lightning.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local speed = tonumber(arguments[2]) or lia.config.get("WalkSpeed")
        target:SetRunSpeed(speed)
    end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    desc = "setModelDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "model",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local oldModel = target:getChar():getModel()
        target:getChar():setModel(arguments[2] or oldModel)
        target:SetupHands()
        client:notifyLocalized("changeModel", client:Name(), target:Name(), arguments[2] or oldModel)
        lia.log.add(client, "charsetmodel", target:Name(), arguments[2], oldModel)
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    desc = "giveItemDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "itemName",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickGiveItemName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local itemName = arguments[2]
        if not itemName or itemName == "" then
            client:notifyLocalized("mustSpecifyItem")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local uniqueID
        for _, v in SortedPairs(lia.item.list) do
            if lia.util.stringMatches(v.name, itemName) or lia.util.stringMatches(v.uniqueID, itemName) then
                uniqueID = v.uniqueID
                break
            end
        end

        if not uniqueID then
            client:notifyLocalized("itemNoExist")
            return
        end

        local inv = target:getChar():getInv()
        local succ, err = inv:add(uniqueID)
        if succ then
            target:notifyLocalized("itemCreated")
            if target ~= client then client:notifyLocalized("itemCreated") end
            lia.log.add(client, "chargiveItem", lia.item.list[uniqueID] and lia.item.list[uniqueID].name or uniqueID, target, L("command"))
        else
            target:notifyLocalized(err or "unknownError")
        end
    end
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    desc = "setDescDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "description",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharDescName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_comment.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyLocalized("noChar")
            return
        end

        local desc = table.concat(arguments, " ", 2)
        if not desc:find("%S") then return client:requestString(L("chgDescTitle", target:Name()), L("enterNewDesc"), function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        target:getChar():setDesc(desc)
        return L("descChangedTarget", client:Name(), target:Name())
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    desc = "setNameDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "newName",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharNameName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_edit.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local newName = table.concat(arguments, " ", 2)
        if newName == "" then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        target:getChar():setName(newName:gsub("#", "#?"))
        client:notifyLocalized("changeName", client:Name(), target:Name(), newName)
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    desc = "setScaleDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "scale",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharScaleName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/arrow_out.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local scale = tonumber(arguments[2]) or 1
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:SetModelScale(scale, 0)
        client:notifyLocalized("changedScale", target:Name(), scale)
    end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    desc = "setJumpDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "power",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharJumpName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/arrow_up.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local power = tonumber(arguments[2]) or 200
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:SetJumpPower(power)
        client:notifyLocalized("changedJump", target:Name(), power)
    end
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    desc = "setBodygroupDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "bodygroupName",
            type = "string"
        },
        {
            name = "value",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local bodyGroup = arguments[2]
        local value = tonumber(arguments[3])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local index = target:FindBodygroupByName(bodyGroup)
        if index > -1 then
            if value and value < 1 then value = nil end
            local groups = target:getChar():getBodygroups()
            groups[index] = value
            target:getChar():setBodygroups(groups)
            target:SetBodygroup(index, value or 0)
            client:notifyLocalized("changeBodygroups", client:Name(), target:Name(), bodyGroup, value or 0)
        else
            client:notifyLocalized("invalidArg")
        end
    end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    desc = "setSkinDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "skin",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickSetCharSkinName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local skin = tonumber(arguments[2])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():setSkin(skin)
        target:SetSkin(skin or 0)
        client:notifyLocalized("changeSkin", client:Name(), target:Name(), skin or 0)
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    desc = "setMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount or amount < 0 then
            client:notifyLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():setMoney(math.floor(amount))
        client:notifyLocalized("setMoney", target:Name(), lia.currency.get(math.floor(amount)))
        lia.log.add(client, "charSetMoney", target:Name(), math.floor(amount))
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    desc = "addMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount then
            client:notifyLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        amount = math.Round(amount)
        local currentMoney = target:getChar():getMoney()
        target:getChar():setMoney(currentMoney + amount)
        client:notifyLocalized("addMoney", target:Name(), lia.currency.get(amount), lia.currency.get(currentMoney + amount))
        lia.log.add(client, "charAddMoney", target:Name(), amount, currentMoney + amount)
    end,
    alias = {"chargivemoney"}
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    desc = "globalBotSayDesc",
    arguments = {
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local message = table.concat(arguments, " ")
        if message == "" then
            client:notifyLocalized("noMessage")
            return
        end

        for _, bot in player.Iterator() do
            if bot:IsBot() then bot:Say(message) end
        end
    end
})

lia.command.add("botsay", {
    superAdminOnly = true,
    desc = "botSayDesc",
    arguments = {
        {
            name = "botName",
            type = "string"
        },
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if #arguments < 2 then
            client:notifyLocalized("needBotAndMessage")
            return
        end

        local botName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local targetBot
        for _, bot in player.Iterator() do
            if bot:IsBot() and string.find(string.lower(bot:Nick()), string.lower(botName)) then
                targetBot = bot
                break
            end
        end

        if not targetBot then
            client:notifyLocalized("botNotFound", botName)
            return
        end

        targetBot:Say(message)
    end
})

lia.command.add("forcesay", {
    superAdminOnly = true,
    desc = "forceSayDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "message",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickForceSayName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/comments.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local message = table.concat(arguments, " ", 2)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if message == "" then
            client:notifyLocalized("noMessage")
            return
        end

        target:Say(message)
        lia.log.add(client, "forceSay", target:Name(), message)
    end
})

lia.command.add("getmodel", {
    desc = "getModelDesc",
    onRun = function(client)
        local entity = client:getTracedEntity()
        if not IsValid(entity) then
            client:notifyLocalized("noEntityInFront")
            return
        end

        local model = entity:GetModel()
        client:ChatPrint(model and L("modelIs", model) or L("noModelFound"))
    end
})

lia.command.add("pm", {
    desc = "pmDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not lia.config.get("AllowPMs") then
            client:notifyLocalized("pmsDisabled")
            return
        end

        local targetName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not message:find("%S") then
            client:notifyLocalized("noMessage")
            return
        end

        lia.chat.send(client, "pm", message, false, {client, target})
    end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    desc = "getCharModelDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharModelName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charModelIs", target:GetModel()))
    end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    desc = "checkAllMoneyDesc",
    onRun = function(client)
        for _, target in player.Iterator() do
            local char = target:getChar()
            if char then client:ChatPrint(L("playerMoney", target:GetName(), lia.currency.get(char:getMoney()))) end
        end
    end
})

lia.command.add("checkflags", {
    adminOnly = true,
    desc = "checkFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharFlagsName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/flag_yellow.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = target:getFlags()
        if flags and #flags > 0 then
            client:ChatPrint(L("charFlags", target:Name(), table.concat(flags, ", ")))
        else
            client:notifyLocalized("noFlags", target:Name())
        end
    end
})

lia.command.add("pcheckflags", {
    adminOnly = true,
    desc = "checkFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetPlayerFlagsName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/flag_orange.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = target:getFlags("player")
        if flags and #flags > 0 then
            local flagTable = {}
            for i = 1, #flags do
                flagTable[#flagTable + 1] = flags:sub(i, i)
            end

            client:ChatPrint(L("playerFlags", target:Name(), table.concat(flagTable, ", ")))
        else
            client:notifyLocalized("noFlags", target:Name())
        end
    end,
})

lia.command.add("chargetname", {
    adminOnly = true,
    desc = "getCharNameDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharNameName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/user.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charNameIs", target:getChar():getName()))
    end
})

lia.command.add("chargethealth", {
    adminOnly = true,
    desc = "getHealthDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharHealthName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/heart.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charHealthIs", target:Health(), target:GetMaxHealth()))
    end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    desc = "getMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharMoneyName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:ChatPrint(L("charMoneyIs", lia.currency.get(money)))
    end
})

lia.command.add("chargetinventory", {
    adminOnly = true,
    desc = "getInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharInventoryName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local inventory = target:getChar():getInv()
        local items = inventory:getItems()
        if not items or table.Count(items) < 1 then
            client:notifyLocalized("charInvEmpty")
            return
        end

        local result = {}
        for _, item in pairs(items) do
            table.insert(result, item.name)
        end

        client:ChatPrint(L("charInventoryIs", table.concat(result, ", ")))
    end
})

lia.command.add("getallinfos", {
    adminOnly = true,
    desc = "getAllInfosDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetAllInfosName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/table.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyLocalized("noChar")
            return
        end

        local data = lia.char.getCharData(char:getID())
        if not data then
            client:notifyLocalized("noChar")
            return
        end

        lia.administrator(L("allInfoFor", char:getName()))
        for column, value in pairs(data) do
            if istable(value) then
                lia.administrator(column .. ":")
                PrintTable(value)
            else
                lia.administrator(column .. " = " .. tostring(value))
            end
        end

        client:notifyLocalized("infoPrintedConsole")
    end
})

lia.command.add("dropmoney", {
    adminOnly = true,
    desc = "dropMoneyDesc",
    arguments = {
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if not amount or amount <= 0 then
            client:notifyLocalized("invalidArg")
            return
        end

        local character = client:getChar()
        if not character or not character:hasMoney(amount) then
            client:notifyLocalized("notEnoughMoney")
            return
        end

        local maxEntities = lia.config.get("MaxMoneyEntities", 3)
        local existingMoneyEntities = 0
        for _, entity in pairs(ents.FindByClass("lia_money")) do
            if entity.client == client then existingMoneyEntities = existingMoneyEntities + 1 end
        end

        if existingMoneyEntities >= maxEntities then
            client:notifyLocalized("maxMoneyEntitiesReached", maxEntities)
            return
        end

        character:takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        if IsValid(money) then
            money.client = client
            money.charID = character:getID()
            client:notifyLocalized("moneyDropped", lia.currency.get(amount))
            lia.log.add(client, "moneyDropped", amount)
            client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
        end
    end
})

lia.command.add("exportprivileges", {
    adminOnly = true,
    desc = "exportprivilegesDesc",
    onRun = function(client)
        local filename = "lilia_registered_privileges.json"
        if not SERVER then return end
        local seen = {}
        local list = {}
        local function add(id, name)
            if isstring(id) or isnumber(id) then return end
            id = tostring(id)
            if id == "" then return end
            if seen[id] then return end
            seen[id] = true
            table.insert(list, {
                id = id,
                name = name and tostring(name) or ""
            })
        end

        local function walk(v)
            if istable(v) then return end
            for k, val in pairs(v) do
                if isstring(k) and (isboolean(val) or istable(val)) then if k ~= "" and k ~= "None" then add(k) end end
                if istable(val) then
                    local id = val.id or val.ID or val.Id or val.uniqueID or val.UniqueID
                    local name = val.name or val.Name or val.title or val.Title
                    if id then add(id, name) end
                    if val.privilege or val.Privilege then add(val.privilege or val.Privilege, name) end
                    if val.privileges or val.Privileges then
                        for _, p in pairs(val.privileges or val.Privileges) do
                            if istable(p) then
                                add(p.id or p.ID or p, p.name or p.Name)
                            elseif isstring(p) or isnumber(p) then
                                add(p)
                            end
                        end
                    end

                    walk(val)
                elseif isstring(val) or isnumber(val) then
                    if isstring(k) and k:lower() == "id" then add(val) end
                end
            end
        end

        local function collect(t)
            if istable(t) == "table" then walk(t) end
        end

        local srcs = {}
        if lia then
            if lia.administrator then
                table.insert(srcs, lia.administrator.privileges)
                if isfunction(lia.administrator.getPrivileges) == "function" then
                    local ok, r = pcall(lia.administrator.getPrivileges, lia.administrator)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.administrator then
                table.insert(srcs, lia.administrator.privileges)
                if isfunction(lia.administrator.getPrivileges) then
                    local ok, r = pcall(lia.administrator.getPrivileges, lia.administrator)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.permission then
                table.insert(srcs, lia.permission.list)
                if isfunction(lia.permission.getAll) then
                    local ok, r = pcall(lia.permission.getAll, lia.permission)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.permissions then table.insert(srcs, lia.permissions) end
            if lia.privileges then table.insert(srcs, lia.privileges) end
            if lia.command then table.insert(srcs, lia.command.stored or lia.command.list) end
            if lia.module.list then
                for _, p in pairs(lia.module.list) do
                    if istable(p) == "table" then
                        table.insert(srcs, p.Privileges or p.privileges)
                        collect(p)
                    end
                end
            end
        end

        for _, s in pairs(srcs) do
            collect(s)
        end

        table.sort(list, function(a, b) return a.id < b.id end)
        local payload = {
            privileges = list
        }

        local jsonData = util.TableToJSON(payload, true)
        local wrote = false
        do
            local f = file.Open("gamemodes/Lilia/data/" .. filename, "wb", "GAME")
            if f then
                f:Write(jsonData)
                f:Close()
                wrote = true
            end
        end

        if not wrote then
            if not file.Exists("data", "DATA") then file.CreateDir("data") end
            wrote = file.Write("data/" .. filename, jsonData) and true or false
        end

        if wrote then
            client:notifyLocalized("privilegesExportedSuccessfully", filename)
            lia.admin(L("privilegesExportedBy", client:Nick(), filename))
            lia.log.add(client, "privilegesExported", filename)
        else
            client:notifyLocalized("privilegesExportFailed")
            lia.error("Failed to export privileges to expected locations")
        end
    end
})

lia.command.add("serverpassword", {
    superAdminOnly = true,
    desc = "Get the current server password and copy it to your clipboard.",
    alias = {"svpassword", "getserverpassword"},
    onRun = function(client)
        if not IsValid(client) then
            local cvar = GetConVar("sv_password")
            local pw = cvar and cvar:GetString() or ""
            if pw == "" then
                print("[Lilia] Server password is not set.")
            else
                print("[Lilia] Server password: " .. pw)
            end
            return
        end

        local cvar = GetConVar("sv_password")
        local pw = cvar and cvar:GetString() or ""
        if not isstring(pw) or pw == "" then return "Server password is not set." end
        net.Start("liaProvideServerPassword")
        net.WriteString(pw)
        net.Send(client)
        return "Server password sent to you."
    end
})

lia.command.add("definefactiongroup", {
    superAdminOnly = true,
    desc = "definefactiongroupDesc",
    arguments = {
        {
            name = "groupName",
            type = "string"
        }
    },
    onRun = function(client, arguments)
        local groupName = arguments[1]
        if not groupName or groupName == "" then
            client:notifyLocalized("invalidArgument")
            return
        end

        if lia.faction.groups[groupName] then
            client:notifyLocalized("factionGroupExists", groupName)
            return
        end

        local factionOptions = {}
        for uniqueID, faction in pairs(lia.faction.teams) do
            table.insert(factionOptions, {
                text = faction.name .. " (" .. uniqueID .. ")",
                value = uniqueID,
                icon = "icon16/group.png"
            })
        end

        if #factionOptions == 0 then
            client:notifyLocalized("noFactionsAvailable")
            return
        end

        table.sort(factionOptions, function(a, b) return a.text < b.text end)
        client:requestOptions(L("selectFactionsForGroup", groupName), L("selectFactionsDesc"), factionOptions, 0, function(selections)
            if not selections or #selections == 0 then
                client:notifyLocalized("noFactionsSelected")
                return
            end

            lia.faction.registerGroup(groupName, selections)
            lia.log.add(client, "defineFactionGroup", groupName, #selections)
            client:notifyLocalized("factionGroupCreated", groupName, #selections)
            local factionNames = {}
            for _, uniqueID in ipairs(selections) do
                local faction = lia.faction.teams[uniqueID]
                if faction then table.insert(factionNames, faction.name) end
            end

            if #factionNames > 0 then client:notifyLocalized("factionGroupMembers", table.concat(factionNames, ", ")) end
        end)
    end
})

lia.command.add("listfactiongroups", {
    adminOnly = true,
    desc = "listfactiongroupsDesc",
    onRun = function(client)
        local groups = lia.faction.groups
        local groupCount = table.Count(groups)
        if groupCount == 0 then
            client:notifyLocalized("noFactionGroups")
            return
        end

        client:notifyLocalized("factionGroupsHeader", groupCount)
        local sortedGroups = {}
        for groupName in pairs(groups) do
            table.insert(sortedGroups, groupName)
        end

        table.sort(sortedGroups)
        for _, groupName in ipairs(sortedGroups) do
            local factionIDs = groups[groupName]
            local factionNames = {}
            for _, factionID in ipairs(factionIDs) do
                local faction = lia.faction.teams[factionID]
                if faction then
                    table.insert(factionNames, faction.name)
                else
                    table.insert(factionNames, factionID .. " (invalid)")
                end
            end

            client:notifyLocalized("factionGroupInfo", groupName, #factionIDs, table.concat(factionNames, ", "))
        end
    end
})

lia.command.add("removefactiongroup", {
    superAdminOnly = true,
    desc = "removefactiongroupDesc",
    arguments = {
        {
            name = "groupName",
            type = "string"
        }
    },
    onRun = function(client, arguments)
        local groupName = arguments[1]
        if not groupName or groupName == "" then
            client:notifyLocalized("invalidArgument")
            return
        end

        if not lia.faction.groups[groupName] then
            client:notifyLocalized("factionGroupNotFound", groupName)
            return
        end

        lia.faction.groups[groupName] = nil
        lia.log.add(client, "removeFactionGroup", groupName)
        client:notifyLocalized("factionGroupRemoved", groupName)
    end
})

lia.command.add("dbcheck", {
    adminOnly = true,
    desc = "Check database connection and table status",
    onRun = function(client)
        client:ChatPrint("[Database Check] Starting database diagnostics...")
        local testQuery = sql.Query("SELECT 1 as test")
        local testError = sql.LastError()
        if testQuery == false then
            client:ChatPrint("[Database Check] ❌ Connection test FAILED: " .. tostring(testError))
            return
        else
            client:ChatPrint("[Database Check] ✅ Connection test PASSED")
        end

        if lia.db.tablesLoaded == false then
            client:ChatPrint("[Database Check] ❌ Tables not loaded properly")
        else
            client:ChatPrint("[Database Check] ✅ Tables loaded")
        end

        local coreTables = {"lia_players", "lia_characters", "lia_inventories", "lia_items"}
        for _, tableName in ipairs(coreTables) do
            local existsQuery = sql.Query("SELECT name FROM sqlite_master WHERE type='table' AND name='" .. tableName .. "'")
            if existsQuery and #existsQuery > 0 then
                client:ChatPrint("[Database Check] ✅ Table '" .. tableName .. "' exists")
            else
                client:ChatPrint("[Database Check] ❌ Table '" .. tableName .. "' MISSING")
            end
        end

        local simpleQuery = sql.Query("SELECT COUNT(*) as count FROM sqlite_master WHERE type='table'")
        if simpleQuery and simpleQuery[1] then
            client:ChatPrint("[Database Check] ✅ Query test PASSED (" .. simpleQuery[1].count .. " tables found)")
        else
            client:ChatPrint("[Database Check] ❌ Query test FAILED")
        end

        client:ChatPrint("[Database Check] Diagnostics complete.")
    end
})
