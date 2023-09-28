--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
lia.command.add(
    "spawnadd",
    {
        privilege = "Management - Change Spawns",
        adminOnly = true,
        syntax = "<string faction> [string class]",
        onRun = function(client, arguments)
            local faction
            local factionName = arguments[1]
            local class = table.concat(arguments, " ", 2)
            local info
            local info2
            if factionName then
                info = lia.faction.indices[factionName:lower()]
                if not info then
                    for _, v in ipairs(lia.faction.indices) do
                        if lia.util.stringMatches(v.uniqueID, factionName) or lia.util.stringMatches(L(v.name, client), factionName) then
                            faction = v.uniqueID
                            info = v
                            break
                        end
                    end
                end

                if info then
                    if class and class ~= "" then
                        local found = false
                        for k, v in ipairs(lia.class.list) do
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
                    MODULE:SaveSpawns()
                    local factionDisplayName = L(info.name, client)
                    if info2 then
                        factionDisplayName = factionDisplayName .. " (" .. L(info2.name, client) .. ")"
                    end

                    return L("spawnAdded", client, factionDisplayName)
                else
                    return L("invalidFaction", client)
                end
            else
                return L("invalidArg", client, 1)
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "spawnremove",
    {
        privilege = "Management - Change Spawns",
        adminOnly = true,
        syntax = "[number radius]",
        onRun = function(client, arguments)
            local position = client:GetPos()
            local radius = tonumber(arguments[1]) or 120
            local i = 0
            for _, v in pairs(MODULE.spawns) do
                for __, v2 in pairs(v) do
                    for k3, v3 in pairs(v2) do
                        if v3:Distance(position) <= radius then
                            v2[k3] = nil
                            i = i + 1
                        end
                    end
                end
            end

            if i > 0 then
                MODULE:SaveSpawns()
            end

            return L("spawnDeleted", client, i)
        end
    }
)
--------------------------------------------------------------------------------------------------------