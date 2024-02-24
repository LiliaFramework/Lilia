---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("spawnadd", {
    privilege = "Change Spawns",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function(client, arguments)
        local faction
        local name = arguments[1]
        local class = table.concat(arguments, " ", 2)
        local info
        local info2
        if name then
            info = lia.faction.indices[name:lower()]
            if not info then
                for _, v in ipairs(lia.faction.indices) do
                    if lia.util.stringMatches(v.uniqueID, name) or lia.util.stringMatches(L(v.name, client), name) then
                        faction = v.uniqueID
                        info = v
                        break
                    end
                end
            end

            if info then
                if class and class ~= "" then
                    local found = false
                    for _, v in ipairs(lia.class.list) do
                        if v.faction == info.index and (v.uniqueID:lower() == class:lower() or lia.util.stringMatches(L(v.name, client), class)) then
                            class = v.uniqueID
                            info2 = v
                            found = true
                            break
                        end
                    end

                    if not found then return L("invalidClass", client) end
                else
                    class = ""
                end

                MODULE.spawns[faction] = MODULE.spawns[faction] or {}
                MODULE.spawns[faction][class] = MODULE.spawns[faction][class] or {}
                table.insert(MODULE.spawns[faction][class], client:GetPos())
                MODULE:SaveData()
                local name = L(info.name, client)
                if info2 then name = name .. " (" .. L(info2.name, client) .. ")" end
                return L("spawnAdded", client, name)
            else
                return L("invalidFaction", client)
            end
        else
            return L("invalidArg", client, 1)
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("respawn", {
    privilege = "Forcelly Respawn",
    adminOnly = true,
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            MODULE:PostPlayerLoadout(target)
            client:notify("You teleported " .. target:Nick() .. " back to their faction spawn point.")
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("spawnremove", {
    privilege = "Change Spawns",
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments)
        local position = client:GetPos()
        local radius = tonumber(arguments[1]) or 120
        local i = 0
        for _, v in pairs(MODULE.spawns) do
            for _, v2 in pairs(v) do
                for _, v3 in pairs(v2) do
                    if v3:Distance(position) <= radius then
                        v2[k3] = nil
                        i = i + 1
                    end
                end
            end
        end

        if i > 0 then MODULE:SaveData() end
        return L("spawnDeleted", client, i)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("returnitems", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Return Items",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if MODULE.LoseWeapononDeathHuman or MODULE.LoseWeapononDeathNPC then
            if IsValid(target) then
                if not target.LostItems then
                    client:notify("The target hasn't died recently or they had their items returned already!")
                    return
                end

                if table.IsEmpty(target.LostItems) then
                    client:notify("Cannot return any items; the player hasn't lost any!")
                    return
                end

                local character = target:getChar()
                if not character then return end
                local inv = character:getInv()
                if not inv then return end
                for _, v in pairs(target.LostItems) do
                    inv:add(v)
                end

                target.LostItems = nil
                target:notify("Your items have been returned.")
                client:notify("Returned the items.")
            end
        else
            client:notify("Weapon on Death not Enabled!")
        end
    end
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------