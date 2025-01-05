local MODULE = MODULE
lia.command.add("doorsell", {
    adminOnly = false,
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client == door:GetDTEntity(0) then
                local price = math.Round(door:getNetVar("price", MODULE.DoorCost) * MODULE.DoorSellRatio)
                door:removeDoorAccessData()
                MODULE:callOnDoorChildren(door, function(child) child:removeDoorAccessData() end)
                client:getChar():giveMoney(price)
                client:notifyLocalized("DoorSold", lia.currency.get(price))
                hook.Run("OnPlayerPurchaseDoor", client, door, false, MODULE.callOnDoorChildren)
                lia.log.add(client, "selldoor", price)
            else
                client:notifyLocalized("DoorNotOwner")
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("admindoorsell", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local owner = door:GetDTEntity(0)
            if IsValid(owner) and owner:IsPlayer() then
                local price = math.Round(door:getNetVar("price", MODULE.DoorCost) * MODULE.DoorSellRatio)
                door:removeDoorAccessData()
                MODULE:callOnDoorChildren(door, function(child) child:removeDoorAccessData() end)
                owner:getChar():giveMoney(price)
                owner:notifyLocalized("DoorSold", lia.currency.get(price))
                client:notifyLocalized("DoorSold", lia.currency.get(price))
                hook.Run("OnPlayerPurchaseDoor", owner, door, false, MODULE.callOnDoorChildren)
                lia.log.add(client, "admindoorsell", owner:Name(), price)
            else
                client:notifyLocalized("DoorNotOwner")
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doortogglelock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local currentLockState = door:GetInternalVariable("m_bLocked")
            local toggleState = not currentLockState
            if toggleState then
                door:Fire("lock")
                door:EmitSound("doors/door_latch3.wav")
                client:notifyLocalized("DoorToggleLocked", "locked")
                lia.log.add(client, "toggleLock", door, "locked")
            else
                door:Fire("unlock")
                door:EmitSound("doors/door_latch1.wav")
                client:notifyLocalized("DoorToggleLocked", "unlocked")
                lia.log.add(client, "toggleLock", door, "unlocked")
            end

            local partner = door:getDoorPartner()
            if IsValid(partner) then
                if toggleState then
                    partner:Fire("lock")
                else
                    partner:Fire("unlock")
                end
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorbuy", {
    adminOnly = false,
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if door:getNetVar("noSell") or door:getNetVar("faction") or door:getNetVar("class") then return client:notifyLocalized("DoorNotAllowedToOwn") end
            if IsValid(door:GetDTEntity(0)) then
                client:notifyLocalized("DoorOwnedBy", door:GetDTEntity(0):Name())
                return false
            end

            local price = door:getNetVar("price", MODULE.DoorCost)
            if client:getChar():hasMoney(price) then
                door:SetDTEntity(0, client)
                door.liaAccess = {
                    [client] = DOOR_OWNER
                }

                MODULE:callOnDoorChildren(door, function(child) child:SetDTEntity(0, client) end)
                client:getChar():takeMoney(price)
                client:notifyLocalized("DoorPurchased", lia.currency.get(price))
                hook.Run("OnPlayerPurchaseDoor", client, door, true, MODULE.callOnDoorChildren)
                lia.log.add(client, "buydoor", price)
            else
                client:notifyLocalized("DoorCanNotAfford")
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doortoggleownable", {
    adminOnly = true,
    syntax = "[string name]",
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local isUnownable = door:getNetVar("noSell", false)
            local newState = not isUnownable
            door:setNetVar("noSell", newState and true or nil)
            MODULE:callOnDoorChildren(door, function(child) child:setNetVar("noSell", newState and true or nil) end)
            lia.log.add(client, "doorToggleOwnable", door, newState)
            client:notifyLocalized(newState and "DoorMadeUnownable" or "DoorMadeOwnable")
            MODULE:SaveData()
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("dooraddfaction", {
    adminOnly = true,
    syntax = "[string faction]",
    privilege = "Manage Doors",
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
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
                door.liaFactionID = faction.uniqueID
                local facs = door:getNetVar("factions", "[]")
                facs = util.JSONToTable(facs)
                facs[faction.index] = true
                local json = util.TableToJSON(facs)
                door:setNetVar("factions", json)
                MODULE:callOnDoorChildren(door, function()
                    local facs = door:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = true
                    local json = util.TableToJSON(facs)
                    door:setNetVar("factions", json)
                end)

                lia.log.add(client, "doorSetFaction", door, faction.name)
                client:notifyLocalized("DoorSetFaction", L(faction.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidFaction")
            else
                door:setNetVar("factions", "[]")
                MODULE:callOnDoorChildren(door, function() door:setNetVar("factions", "[]") end)
                lia.log.add(client, "doorRemoveFaction", door, "all")
                client:notifyLocalized("DoorRemoveFaction")
            end

            MODULE:SaveData()
        end
    end
})

lia.command.add("doorremovefaction", {
    adminOnly = true,
    syntax = "[string faction]",
    privilege = "Manage Doors",
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
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
                door.liaFactionID = nil
                local facs = door:getNetVar("factions", "[]")
                facs = util.JSONToTable(facs)
                facs[faction.index] = nil
                local json = util.TableToJSON(facs)
                door:setNetVar("factions", json)
                MODULE:callOnDoorChildren(door, function()
                    local facs = door:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = nil
                    local json = util.TableToJSON(facs)
                    door:setNetVar("factions", json)
                end)

                lia.log.add(client, "doorRemoveFaction", door, faction.name)
                client:notifyLocalized("DoorRemoveFaction", L(faction.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidFaction")
            else
                door:setNetVar("factions", "[]")
                MODULE:callOnDoorChildren(door, function() door:setNetVar("factions", "[]") end)
                lia.log.add(client, "doorRemoveFaction", door, "all")
                client:notifyLocalized("DoorRemoveFaction")
            end

            MODULE:SaveData()
        end
    end
})

lia.command.add("doorresetdata", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            lia.log.add(client, "doorResetData", door)
            door:setNetVar("disabled", nil)
            door:setNetVar("noSell", nil)
            door:setNetVar("hidden", nil)
            door:setNetVar("class", nil)
            door:setNetVar("factions", "[]")
            door:setNetVar("title", nil)
            door:setNetVar("price", MODULE.DoorCost)
            MODULE:callOnDoorChildren(door, function(child)
                child:setNetVar("disabled", nil)
                child:setNetVar("noSell", nil)
                child:setNetVar("hidden", nil)
                child:setNetVar("class", nil)
                child:setNetVar("factions", "[]")
                child:setNetVar("title", nil)
                child:setNetVar("price", MODULE.DoorCost)
            end)

            client:notifyLocalized("DoorResetData")
            MODULE:SaveData()
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorsetdisabled", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            if door:getNetVar("disabled", false) then
                client:notifyLocalized("DoorAlreadyDisabled")
            else
                door:setNetVar("disabled", true)
                MODULE:callOnDoorChildren(door, function(child) child:setNetVar("disabled", true) end)
                lia.log.add(client, "doorDisable", door)
                client:notifyLocalized("DoorSetDisabled")
                MODULE:SaveData()
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorforcelock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            door:Fire("lock")
            door:EmitSound("doors/door_latch3.wav")
            lia.log.add(client, "doorForceLock", door)
            client:notifyLocalized("DoorForceLock")
            local partner = door:getDoorPartner()
            if IsValid(partner) then partner:Fire("lock") end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorforceunlock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            door:Fire("unlock")
            door:EmitSound("doors/door_latch1.wav")
            lia.log.add(client, "doorForceUnlock", door)
            client:notifyLocalized("DoorForceUnlock")
            local partner = door:getDoorPartner()
            if IsValid(partner) then partner:Fire("unlock") end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("disablealldoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
                door:setNetVar("disabled", true)
                lia.log.add(client, "doorDisable", door)
                MODULE:callOnDoorChildren(door, function(child)
                    child:setNetVar("disabled", true)
                    lia.log.add(client, "doorDisable", child)
                end)

                count = count + 1
            end
        end

        client:notifyLocalized("DoorDisableAll", count)
        lia.log.add(client, "doorDisableAll", count)
        MODULE:SaveData()
    end
})

lia.command.add("enablealldoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() and door:getNetVar("disabled", false) then
                door:setNetVar("disabled", false)
                lia.log.add(client, "doorEnable", door)
                MODULE:callOnDoorChildren(door, function(child)
                    child:setNetVar("disabled", false)
                    lia.log.add(client, "doorEnable", child)
                end)

                count = count + 1
            end
        end

        client:notifyLocalized("DoorEnableAll", count)
        lia.log.add(client, "doorEnableAll", count)
        MODULE:SaveData()
    end
})

lia.command.add("doorsetenabled", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            if not door:getNetVar("disabled", false) then
                client:notifyLocalized("DoorAlreadyEnabled")
            else
                door:setNetVar("disabled", false)
                lia.log.add(client, "doorEnable", door)
                MODULE:callOnDoorChildren(door, function(child)
                    child:setNetVar("disabled", false)
                    lia.log.add(client, "doorEnable", child)
                end)

                client:notifyLocalized("DoorSetNotDisabled")
                MODULE:SaveData()
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doortogglehidden", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local entity = client:GetEyeTrace().Entity
        if IsValid(entity) and entity:isDoor() then
            local currentState = entity:getNetVar("hidden", false)
            local newState = not currentState
            entity:setNetVar("hidden", newState)
            lia.log.add(client, "doorSetHidden", entity, newState)
            MODULE:callOnDoorChildren(entity, function(child)
                child:setNetVar("hidden", newState)
                lia.log.add(client, "doorSetHidden", child, newState)
            end)

            client:notifyLocalized(newState and "DoorSetHidden" or "DoorSetNotHidden")
            MODULE:SaveData()
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorsettitle", {
    adminOnly = true,
    syntax = "[string title]",
    privilege = "Manage Doors",
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local name = table.concat(arguments, " ")
            if not name:find("%S") then return client:notifyLocalized("invalidArg", 1) end
            if door:checkDoorAccess(client, DOOR_TENANT) then
                door:setNetVar("title", name)
                lia.log.add(client, "doorSetTitle", door, name)
            elseif client:isStaff() then
                door:setNetVar("name", name)
                MODULE:callOnDoorChildren(door, function(child) child:setNetVar("name", name) end)
                lia.log.add(client, "doorSetTitle", door, name)
            else
                client:notifyLocalized("notOwner")
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorsetparent", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            client.liaDoorParent = door
            lia.log.add(client, "doorSetParent", door)
            client:notifyLocalized("DoorSetParentDoor")
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorsetchild", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client.liaDoorParent == door then return client:notifyLocalized("DoorCanNotSetAsChild") end
            if IsValid(client.liaDoorParent) then
                client.liaDoorParent.liaChildren = client.liaDoorParent.liaChildren or {}
                client.liaDoorParent.liaChildren[door:MapCreationID()] = true
                door.liaParent = client.liaDoorParent
                lia.log.add(client, "doorAddChild", client.liaDoorParent, door)
                client:notifyLocalized("DoorAddChildDoor")
                MODULE:SaveData()
                MODULE:copyParentDoor(door)
            else
                client:notifyLocalized("DoorNoParentDoor")
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorremovechild", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client.liaDoorParent == door then
                MODULE:callOnDoorChildren(door, function(child)
                    lia.log.add(client, "doorRemoveChild", door, child)
                    child.liaParent = nil
                end)

                door.liaChildren = nil
                return client:notifyLocalized("DoorRemoveChildren")
            end

            if IsValid(door.liaParent) and door.liaParent.liaChildren then
                door.liaParent.liaChildren[door:MapCreationID()] = nil
                lia.log.add(client, "doorRemoveChild", door.liaParent, door)
                door.liaParent = nil
                client:notifyLocalized("DoorRemoveChildDoor")
                MODULE:SaveData()
            end
        else
            client:notifyLocalized("DoorNotValid")
        end
    end
})

lia.command.add("doorsetclass", {
    adminOnly = true,
    syntax = "[string class]",
    privilege = "Manage Doors",
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
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
                door.liaClassID = class
                door:setNetVar("class", class)
                MODULE:callOnDoorChildren(door, function()
                    door.liaClassID = class
                    door:setNetVar("class", class)
                end)

                lia.log.add(client, "doorSetClass", door, classData.name)
                client:notifyLocalized("DoorSetClass", L(classData.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidClass")
            else
                door:setNetVar("class", nil)
                MODULE:callOnDoorChildren(door, function() door:setNetVar("class", nil) end)
                lia.log.add(client, "doorRemoveClass", door)
                client:notifyLocalized("DoorRemoveClass")
            end

            MODULE:SaveData()
        end
    end,
    alias = {"jobdoor"}
})

lia.command.add("savedoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        MODULE:SaveData()
        lia.log.add(client, "doorSaveData")
        client:notify("Saved Doors!")
    end
})
