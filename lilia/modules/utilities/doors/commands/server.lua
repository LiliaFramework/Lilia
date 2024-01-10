
lia.command.add(
    "doorsell",
    {
        privilege = "Default User Commands",
        onRun = function(client)
            local entity = client:GetTracedEntity()
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                if client == entity:GetDTEntity(0) then
                    local price = math.Round(entity:getNetVar("price", DoorsCore.DoorCost) * DoorsCore.DoorSellRatio)
                    entity:removeDoorAccessData()
                    DoorsCore:callOnDoorChildren(entity, function(child) child:removeDoorAccessData() end)
                    client:getChar():giveMoney(price)
                    client:notifyLocalized("dSold", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, entity, false, DoorsCore.callOnDoorChildren)
                    lia.log.add(client, "selldoor")
                else
                    client:notifyLocalized("notOwner")
                end
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorbuy",
    {
        privilege = "Default User Commands",
        onRun = function(client)
            local entity = client:GetTracedEntity()
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                if entity:getNetVar("noSell") or entity:getNetVar("faction") or entity:getNetVar("class") then return client:notifyLocalized("dNotAllowedToOwn") end
                if IsValid(entity:GetDTEntity(0)) then
                    client:notifyLocalized("dOwnedBy", entity:GetDTEntity(0):Name())
                    return false
                end

                local price = entity:getNetVar("price", DoorsCore.DoorCost)
                if client:getChar():hasMoney(price) then
                    entity:SetDTEntity(0, client)
                    entity.liaAccess = {
                        [client] = DOOR_OWNER
                    }

                    DoorsCore:callOnDoorChildren(entity, function(child) child:SetDTEntity(0, client) end)
                    client:getChar():takeMoney(price)
                    client:notifyLocalized("dPurchased", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, entity, true, DoorsCore.callOnDoorChildren)
                    lia.log.add(client, "buydoor")
                else
                    client:notifyLocalized("canNotAfford")
                end
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsetunownable",
    {
        adminOnly = true,
        syntax = "[string name]",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetTracedEntity()
            local name = table.concat(arguments, " ")
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                entity:setNetVar("noSell", true)
                if arguments[1] and name:find("%S") then entity:setNetVar("name", name) end
                DoorsCore:callOnDoorChildren(
                    entity,
                    function(child)
                        child:setNetVar("noSell", true)
                        if arguments[1] and name:find("%S") then child:setNetVar("name", name) end
                    end
                )

                client:notifyLocalized("dMadeUnownable")
                DoorsCore:SaveData()
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsetownable",
    {
        adminOnly = true,
        syntax = "[string name]",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            local name = table.concat(arguments, " ")
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                entity:setNetVar("noSell", nil)
                if arguments[1] and name:find("%S") then entity:setNetVar("name", name) end
                DoorsCore:callOnDoorChildren(
                    entity,
                    function(child)
                        child:setNetVar("noSell", nil)
                        if arguments[1] and name:find("%S") then child:setNetVar("name", name) end
                    end
                )

                client:notifyLocalized("dMadeOwnable")
                DoorsCore:SaveData()
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "dooraddfaction",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                local faction
                if arguments[1] then
                    local name = table.concat(arguments, " ")
                    for k, v in pairs(lia.faction.teams) do
                        if lia.util.stringMatches(k, name) or lia.util.stringMatches(L(v.name, client), name) then
                            faction = v
                            break
                        end
                    end
                end

                if faction then
                    entity.liaFactionID = faction.uniqueID
                    local facs = entity:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = true
                    local json = util.TableToJSON(facs)
                    entity:setNetVar("factions", json)
                    DoorsCore:callOnDoorChildren(
                        entity,
                        function()
                            local facs = entity:getNetVar("factions", "[]")
                            facs = util.JSONToTable(facs)
                            facs[faction.index] = true
                            local json = util.TableToJSON(facs)
                            entity:setNetVar("factions", json)
                        end
                    )

                    client:notifyLocalized("dSetFaction", L(faction.name, client))
                elseif arguments[1] then
                    client:notifyLocalized("invalidFaction")
                else
                    entity:setNetVar("factions", "[]")
                    DoorsCore:callOnDoorChildren(entity, function() entity:setNetVar("factions", "[]") end)
                    client:notifyLocalized("dRemoveFaction")
                end

                DoorsCore:SaveData()
            end
        end
    }
)


lia.command.add(
    "doorremovefaction",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                local faction
                if arguments[1] then
                    local name = table.concat(arguments, " ")
                    for k, v in pairs(lia.faction.teams) do
                        if lia.util.stringMatches(k, name) or lia.util.stringMatches(L(v.name, client), name) then
                            faction = v
                            break
                        end
                    end
                end

                if faction then
                    entity.liaFactionID = nil
                    local facs = entity:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = nil
                    local json = util.TableToJSON(facs)
                    entity:setNetVar("factions", json)
                    DoorsCore:callOnDoorChildren(
                        entity,
                        function()
                            local facs = entity:getNetVar("factions", "[]")
                            facs = util.JSONToTable(facs)
                            facs[faction.index] = nil
                            local json = util.TableToJSON(facs)
                            entity:setNetVar("factions", json)
                        end
                    )

                    client:notifyLocalized("dRemoveFaction", L(faction.name, client))
                elseif arguments[1] then
                    client:notifyLocalized("invalidFaction")
                else
                    entity:setNetVar("factions", "[]")
                    DoorsCore:callOnDoorChildren(entity, function() entity:setNetVar("factions", "[]") end)
                    client:notifyLocalized("dRemoveFaction")
                end

                DoorsCore:SaveData()
            end
        end
    }
)


lia.command.add(
    "doorsetdisabled",
    {
        adminOnly = true,
        syntax = "<bool disabled>",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() then
                local disabled = tobool(arguments[1] or true)
                entity:setNetVar("disabled", disabled)
                DoorsCore:callOnDoorChildren(entity, function(child) child:setNetVar("disabled", disabled) end)
                client:notifyLocalized("dSet" .. (disabled and "" or "Not") .. "Disabled")
                DoorsCore:SaveData()
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsettitle",
    {
        syntax = "<string title>",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetTracedEntity()
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                local name = table.concat(arguments, " ")
                if not name:find("%S") then return client:notifyLocalized("invalidArg", 1) end
                if entity:checkDoorAccess(client, DOOR_TENANT) then
                    entity:setNetVar("title", name)
                elseif client:IsAdmin() then
                    entity:setNetVar("name", name)
                    DoorsCore:callOnDoorChildren(entity, function(child) child:setNetVar("name", name) end)
                else
                    client:notifyLocalized("notOwner")
                end
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsetparent",
    {
        adminOnly = true,
        privilege = "Manage Doors",
        onRun = function(client)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                client.liaDoorParent = entity
                client:notifyLocalized("dSetParentDoor")
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsetchild",
    {
        adminOnly = true,
        privilege = "Manage Doors",
        onRun = function(client)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                if client.liaDoorParent == entity then return client:notifyLocalized("dCanNotSetAsChild") end
                if IsValid(client.liaDoorParent) then
                    client.liaDoorParent.liaChildren = client.liaDoorParent.liaChildren or {}
                    client.liaDoorParent.liaChildren[entity:MapCreationID()] = true
                    entity.liaParent = client.liaDoorParent
                    client:notifyLocalized("dAddChildDoor")
                    DoorsCore:SaveData()
                    DoorsCore:copyParentDoor(entity)
                else
                    client:notifyLocalized("dNoParentDoor")
                end
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorremovechild",
    {
        adminOnly = true,
        privilege = "Manage Doors",
        onRun = function(client)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                if client.liaDoorParent == entity then
                    DoorsCore:callOnDoorChildren(entity, function(child) child.liaParent = nil end)
                    entity.liaChildren = nil
                    return client:notifyLocalized("dRemoveChildren")
                end

                if IsValid(entity.liaParent) and entity.liaParent.liaChildren then
                    entity.liaParent.liaChildren[entity:MapCreationID()] = nil
                    entity.liaParent = nil
                    client:notifyLocalized("dRemoveChildDoor")
                    DoorsCore:SaveData()
                end
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsethidden",
    {
        adminOnly = true,
        syntax = "<bool hidden>",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() then
                local hidden = tobool(arguments[1] or true)
                entity:setNetVar("hidden", hidden)
                DoorsCore:callOnDoorChildren(entity, function(child) child:setNetVar("hidden", hidden) end)
                client:notifyLocalized("dSet" .. (hidden and "" or "Not") .. "Hidden")
                DoorsCore:SaveData()
            else
                client:notifyLocalized("dNotValid")
            end
        end
    }
)


lia.command.add(
    "doorsetclass",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Manage Doors",
        onRun = function(client, arguments)
            local entity = client:GetEyeTrace().Entity
            if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
                local class, classData
                if arguments[1] then
                    local name = table.concat(arguments, " ")
                    for k, v in pairs(lia.class.list) do
                        if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(L(v.name, client), name) then
                            class, classData = k, v
                            break
                        end
                    end
                end

                if class then
                    entity.liaClassID = class
                    entity:setNetVar("class", class)
                    DoorsCore:callOnDoorChildren(
                        entity,
                        function()
                            entity.liaClassID = class
                            entity:setNetVar("class", class)
                        end
                    )

                    client:notifyLocalized("dSetClass", L(classData.name, client))
                elseif arguments[1] then
                    client:notifyLocalized("invalidClass")
                else
                    entity:setNetVar("class", nil)
                    DoorsCore:callOnDoorChildren(entity, function() entity:setNetVar("class", nil) end)
                    client:notifyLocalized("dRemoveClass")
                end

                DoorsCore:SaveData()
            end
        end,
        alias = {"jobdoor"}
    }
)

