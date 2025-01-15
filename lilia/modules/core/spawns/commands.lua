local MODULE = MODULE
lia.command.add("spawnadd", {
    privilege = "Manage Spawns",
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments)
        local factionName = arguments[1]
        if not factionName then return L("invalidArg", 1) end
        local factionInfo = lia.faction.indices[factionName:lower()]
        if not factionInfo then
            for _, v in ipairs(lia.faction.indices) do
                if lia.util.stringMatches(v.uniqueID, factionName) or lia.util.stringMatches(L(v.name), factionName) then
                    factionInfo = v
                    break
                end
            end
        end

        if factionInfo then
            MODULE.spawns[factionInfo.uniqueID] = MODULE.spawns[factionInfo.uniqueID] or {}
            table.insert(MODULE.spawns[factionInfo.uniqueID], client:GetPos())
            MODULE:SaveData()
            local factionDisplay = L(factionInfo.name)
            return L("spawnAdded", factionDisplay)
        else
            return L("invalidFaction")
        end
    end
})

lia.command.add("spawnremoveinradius", {
    privilege = "Manage Spawns",
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments)
        local position = client:GetPos()
        local radius = tonumber(arguments[1]) or 120
        local removedCount = 0
        for faction, spawns in pairs(MODULE.spawns) do
            for index = #spawns, 1, -1 do
                if spawns[index]:Distance(position) <= radius then
                    table.remove(MODULE.spawns[faction], index)
                    removedCount = removedCount + 1
                end
            end
        end

        if removedCount > 0 then MODULE:SaveData() end
        return L("spawnDeleted", removedCount)
    end
})

lia.command.add("spawnremovebyname", {
    privilege = "Manage Spawns",
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(_, arguments)
        local factionName = arguments[1]
        if not factionName then return L("invalidArg", 1) end
        local factionInfo = lia.faction.indices[factionName:lower()]
        if not factionInfo then
            for _, v in ipairs(lia.faction.indices) do
                if lia.util.stringMatches(v.uniqueID, factionName) or lia.util.stringMatches(L(v.name), factionName) then
                    factionInfo = v
                    break
                end
            end
        end

        if factionInfo then
            if MODULE.spawns[factionInfo.uniqueID] then
                local removedCount = #MODULE.spawns[factionInfo.uniqueID]
                MODULE.spawns[factionInfo.uniqueID] = nil
                MODULE:SaveData()
                return L("spawnDeletedByName", L(factionInfo.name), removedCount)
            else
                return L("noSpawnsForFaction")
            end
        else
            return L("invalidFaction")
        end
    end
})

lia.command.add("returnitems", {
    superAdminOnly = true,
    privilege = "Return Items",
    syntax = "[string name]",
    AdminStick = {
        Name = "Return Items",
        Category = "Character Management",
        SubCategory = "Items",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client, arguments)
        local targetPlayer = lia.command.findPlayer(client, arguments[1])
        if not targetPlayer or not IsValid(targetPlayer) then
            client:notify("Target player not found.")
            return
        end

        if MODULE.LoseDropItemsonDeathHuman or MODULE.LoseDropItemsonDeathNPC then
            if IsValid(targetPlayer) then
                if not targetPlayer.LostItems then
                    client:notify("The target hasn't died recently or they have already had their items returned!")
                    return
                end

                if table.IsEmpty(targetPlayer.LostItems) then
                    client:notify("Cannot return any items; the player hasn't lost any!")
                    return
                end

                local character = targetPlayer:getChar()
                if not character then return end
                local inv = character:getInv()
                if not inv then return end
                local returnedItems = {}
                for _, item in pairs(targetPlayer.LostItems) do
                    inv:add(item)
                    table.insert(returnedItems, item.uniqueID)
                end

                targetPlayer.LostItems = nil
                targetPlayer:notify("Your items have been returned.")
                client:notify("Returned the items.")
            end
        else
            client:notify("Weapon on Death not Enabled!")
        end
    end
})