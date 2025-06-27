local MODULE = MODULE
lia.command.add("spawnadd", {
    privilege = "Manage Spawns",
    adminOnly = true,
    desc = L("spawnAddDesc"),
    syntax = "[string Faction]",
    onRun = function(client, arguments)
        local factionName = arguments[1]
        if not factionName then return L("invalidArg") end
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
            lia.log.add(client, "spawnAdd", factionInfo.name)
            return L("spawnAdded", L(factionInfo.name))
        else
            return L("invalidFaction")
        end
    end
})

lia.command.add("spawnremoveinradius", {
    privilege = "Manage Spawns",
    adminOnly = true,
    desc = L("spawnRemoveInRadiusDesc"),
    syntax = "[number Radius]",
    onRun = function(client, arguments)
        local position = client:GetPos()
        local radius = tonumber(arguments[1]) or 120
        local removedCount = 0
        for faction, spawns in pairs(MODULE.spawns) do
            for i = #spawns, 1, -1 do
                if spawns[i]:Distance(position) <= radius then
                    table.remove(MODULE.spawns[faction], i)
                    removedCount = removedCount + 1
                end
            end
        end

        if removedCount > 0 then MODULE:SaveData() end
        lia.log.add(client, "spawnRemoveRadius", radius, removedCount)
        return L("spawnDeleted", removedCount)
    end
})

lia.command.add("spawnremovebyname", {
    privilege = "Manage Spawns",
    adminOnly = true,
    desc = L("spawnRemoveByNameDesc"),
    syntax = "[string Faction]",
    onRun = function(_, arguments)
        local factionName = arguments[1]
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
                lia.log.add(client, "spawnRemoveByName", factionInfo.name, removedCount)
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
    desc = L("returnItemsDesc"),
    syntax = "[string Name]",
    AdminStick = {
        Name = L("returnItemsName"),
        Category = "characterManagement",
        SubCategory = L("items"),
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if lia.config.get("LoseItemsonDeathHuman", false) or lia.config.get("LoseItemsonDeathNPC", false) then
            if not target.LostItems or table.IsEmpty(target.LostItems) then
                client:notifyLocalized("returnItemsTargetNoItems")
                return
            end

            local character = target:getChar()
            if not character then return end
            local inv = character:getInv()
            if not inv then return end
            for _, item in pairs(target.LostItems) do
                inv:add(item)
            end

            target.LostItems = nil
            target:notifyLocalized("returnItemsReturnedToPlayer")
            client:notifyLocalized("returnItemsAdminConfirmed")
            lia.log.add(client, "returnItems", target:Name())
        else
            client:notifyLocalized("returnItemsNotEnabled")
        end
    end
})
