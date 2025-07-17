lia.command.add("plytransfer", {
    adminOnly = true,
    privilege = "Manage Transfers",
    desc = "plyTransferDesc",
    syntax = "[player Name] [faction Faction]",
    alias = {"charsetfaction"},
    onRun = function(client, arguments)
        local targetPlayer = lia.util.findPlayer(client, arguments[1])
        if not targetPlayer or not IsValid(targetPlayer) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local factionName = table.concat(arguments, " ", 2)
        local faction = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if not faction then
            client:notifyLocalized("invalidFaction")
            return
        end

        local targetChar = targetPlayer:getChar()
        if hook.Run("CanCharBeTransfered", targetChar, faction, targetPlayer:Team()) == false then return end
        local oldFaction = targetChar:getFaction()
        local oldFactionName = lia.faction.indices[oldFaction] and lia.faction.indices[oldFaction].name or oldFaction
        targetChar.vars.faction = faction.uniqueID
        targetChar:setFaction(faction.index)
        targetChar:kickClass()
        local defaultClass = lia.faction.getDefaultClass(faction.index)
        if defaultClass then targetChar:joinClass(defaultClass.index) end
        hook.Run("OnTransferred", targetPlayer)
        if faction.OnTransferred then faction:OnTransferred(targetPlayer, oldFaction) end
        hook.Run("PlayerLoadout", targetPlayer)
        client:notifyLocalized("transferSuccess", targetPlayer:Name(), L(faction.name, client))
        if client ~= targetPlayer then targetPlayer:notifyLocalized("transferNotification", L(faction.name, targetPlayer), client:Name()) end
        lia.log.add(client, "plyTransfer", targetPlayer:Name(), oldFactionName, faction.name)
    end
})

local function formatDHM(seconds)
    seconds = math.max(seconds or 0, 0)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    return string.format("%dd %dh %dm", days, hours, minutes)
end

lia.command.add("roster", {
    desc = "rosterDesc",
    onRun = function(client)
        local character = client:getChar()
        if not character then
            client:notify("Character data not found for client:", client)
            return
        end

        local isLeader = client:IsSuperAdmin() or character:getData("factionOwner") or character:getData("factionAdmin") or character:hasFlags("V")
        if not isLeader then return end
        local fields = "lia_characters._name, lia_characters._faction, lia_characters._id, lia_characters._steamID, lia_characters._lastJoinTime, lia_players._totalOnlineTime, lia_players._lastOnline"
        if not character then
            client:notify("Character data not found for client:", client)
            return
        end

        local factionIndex = character:getFaction()
        if not factionIndex then
            client:notify("Faction data not found for character:", character)
            return
        end

        local faction = lia.faction.indices[factionIndex]
        if not faction then
            client:notify("Faction data not found for index:", factionIndex)
            return
        end

        local condition = "lia_characters._schema = '" .. lia.db.escape(SCHEMA.folder) .. "' AND lia_characters._faction = " .. lia.db.convertDataType(faction.uniqueID)
        local query = "SELECT " .. fields .. " FROM lia_characters LEFT JOIN lia_players ON lia_characters._steamID = lia_players._steamID WHERE " .. condition
        lia.db.query(query, function(data)
            local characters = {}
            if data then
                for _, v in ipairs(data) do
                    local last = tonumber(v._lastOnline)
                    if not isnumber(last) then last = os.time(lia.time.toNumber(v._lastJoinTime)) end
                    local lastDiff = os.time() - last
                    local timeSince = lia.time.TimeSince(last)
                    local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                    local lastOnlineText = string.format("%s (%s) ago", timeStripped, formatDHM(lastDiff))
                    table.insert(characters, {
                        id = v._id,
                        name = v._name,
                        faction = v._faction,
                        steamID = v._steamID,
                        lastOnline = lastOnlineText,
                        hoursPlayed = formatDHM(tonumber(v._totalOnlineTime) or 0)
                    })
                end
            else
                client:notify("No data found for the specified condition.")
            end

            net.Start("CharacterInfo")
            net.WriteString(faction.uniqueID)
            net.WriteTable(characters)
            net.Send(client)
        end)
    end
})

lia.command.add("factionmanagement", {
    superAdminOnly = true,
    privilege = "Manage Faction Members",
    desc = "factionManagementDesc",
    syntax = "[faction Faction]",
    onRun = function(client, arguments)
        local fields = "lia_characters._name, lia_characters._faction, lia_characters._id, lia_characters._steamID, lia_characters._lastJoinTime, lia_players._totalOnlineTime, lia_players._lastOnline"
        local faction
        local arg = table.concat(arguments, " ")
        if arg ~= "" then
            faction = lia.util.findFaction(client, arg)
            if not faction then return end
        else
            local character = client:getChar()
            if not character then
                client:notify("Character data not found for client:", client)
                return
            end

            local factionIndex = character:getFaction()
            if not factionIndex then
                client:notify("Faction data not found for character:", character)
                return
            end

            faction = lia.faction.indices[factionIndex]
            if not faction then
                client:notify("Faction data not found for index:", factionIndex)
                return
            end
        end

        local condition = "lia_characters._schema = '" .. lia.db.escape(SCHEMA.folder) .. "' AND lia_characters._faction = " .. lia.db.convertDataType(faction.uniqueID)
        local query = "SELECT " .. fields .. " FROM lia_characters LEFT JOIN lia_players ON lia_characters._steamID = lia_players._steamID WHERE " .. condition
        lia.db.query(query, function(data)
            local characters = {}
            if data then
                for _, v in ipairs(data) do
                    local last = tonumber(v._lastOnline)
                    if not isnumber(last) then last = os.time(lia.time.toNumber(v._lastJoinTime)) end
                    local lastDiff = os.time() - last
                    local timeSince = lia.time.TimeSince(last)
                    local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                    local lastOnlineText = string.format("%s (%s) ago", timeStripped, formatDHM(lastDiff))
                    table.insert(characters, {
                        id = v._id,
                        name = v._name,
                        faction = v._faction,
                        steamID = v._steamID,
                        lastOnline = lastOnlineText,
                        hoursPlayed = formatDHM(tonumber(v._totalOnlineTime) or 0)
                    })
                end
            else
                client:notify("No data found for the specified condition.")
            end

            net.Start("CharacterInfo")
            net.WriteString(faction.uniqueID)
            net.WriteTable(characters)
            net.Send(client)
        end)
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "plyWhitelistDesc",
    syntax = "[player Name] [faction Faction]",
    alias = {"factionwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, true) then
            for _, v in player.Iterator() do
                v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
            end

            lia.log.add(client, "plyWhitelist", target:Name(), faction.name)
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "plyUnwhitelistDesc",
    syntax = "[player Name] [faction Faction]",
    alias = {"factionunwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, false) then
            for _, v in player.Iterator() do
                v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
            end

            lia.log.add(client, "plyUnwhitelist", target:Name(), faction.name)
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    desc = "beClassDesc",
    syntax = "[class Class]",
    onRun = function(client, arguments)
        local className = table.concat(arguments, " ")
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyLocalized("illegalAccess")
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if classData and lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                client:notifyLocalized("becomeClass", L(classData.name))
                lia.log.add(client, "beClass", classData.name)
            else
                client:notifyLocalized("becomeClassFail", L(classData.name))
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = "setClassDesc",
    syntax = "[player Player Name] [class Class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local className = table.concat(arguments, " ", 2)
        local classID = lia.class.retrieveClass(className)
        local classData = lia.class.list[classID]
        if classData then
            if target:Team() == classData.faction then
                target:getChar():joinClass(classID, true)
                lia.log.add(client, "setClass", target:Name(), classData.name)
                target:notifyLocalized("classSet", L(classData.name), client:GetName())
                if client ~= target then client:notifyLocalized("classSetOther", target:GetName(), L(classData.name)) end
                hook.Run("PlayerLoadout", target)
            else
                client:notifyLocalized("classFactionMismatch")
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "classWhitelistDesc",
    syntax = "[player Name] [class Class]",
    AdminStick = {
        Name = "adminStickClassWhitelistName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_add.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif target:hasClassWhitelist(classID) then
            client:notifyLocalized("alreadyWhitelisted")
        else
            target:classWhitelist(classID)
            client:notifyLocalized("whitelistedSuccess")
            target:notifyLocalized("classAssigned", L(classData.name))
            lia.log.add(client, "classWhitelist", target:Name(), classData.name)
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = "classUnwhitelistDesc",
    syntax = "[player Name] [class Class]",
    AdminStick = {
        Name = "adminStickClassUnwhitelistName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif not target:hasClassWhitelist(classID) then
            client:notifyLocalized("notWhitelisted")
        else
            target:classUnWhitelist(classID)
            client:notifyLocalized("unwhitelistedSuccess")
            target:notifyLocalized("classUnassigned", L(classData.name))
            lia.log.add(client, "classUnwhitelist", target:Name(), classData.name)
        end
    end
})
