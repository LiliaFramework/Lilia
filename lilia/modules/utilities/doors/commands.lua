local MODULE = MODULE
lia.command.add("doorsell", {
    adminOnly = false,
    AdminStick = {
        Name = "Sell Door",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client == door:GetDTEntity(0) then
                local price = math.Round(door:getNetVar("price", 0) * lia.config.get("DoorSellRatio", 0.5))
                door:removeDoorAccessData()
                MODULE:callOnDoorChildren(door, function(child) child:removeDoorAccessData() end)
                client:getChar():giveMoney(price)
                client:notify(L("doorSold", lia.currency.get(price)))
                hook.Run("OnPlayerPurchaseDoor", client, door, false, MODULE.callOnDoorChildren)
                lia.log.add(client, "doorsell", price)
            else
                client:notify(L("doorNotOwner"))
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("admindoorsell", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Admin Sell Door",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local owner = door:GetDTEntity(0)
            if IsValid(owner) and owner:IsPlayer() then
                local price = math.Round(door:getNetVar("price", 0) * lia.config.get("DoorSellRatio", 0.5))
                door:removeDoorAccessData()
                MODULE:callOnDoorChildren(door, function(child) child:removeDoorAccessData() end)
                owner:getChar():giveMoney(price)
                owner:notify(L("doorSold", lia.currency.get(price)))
                client:notify(L("doorSold", lia.currency.get(price)))
                hook.Run("OnPlayerPurchaseDoor", owner, door, false, MODULE.callOnDoorChildren)
                lia.log.add(client, "admindoorsell", owner:Name(), price)
            else
                client:notify(L("doorNotOwner"))
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doortogglelock", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Toggle Door Lock",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local currentLockState = door:GetInternalVariable("m_bLocked")
            local toggleState = not currentLockState
            if toggleState then
                door:Fire("lock")
                door:EmitSound("doors/door_latch3.wav")
                client:notify(L("doorToggleLocked", "locked"))
                lia.log.add(client, "toggleLock", door, "locked")
            else
                door:Fire("unlock")
                door:EmitSound("doors/door_latch1.wav")
                client:notify(L("doorToggleLocked", "unlocked"))
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
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorbuy", {
    adminOnly = false,
    AdminStick = {
        Name = "Buy Door",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if door:getNetVar("noSell") or door:getNetVar("faction") or door:getNetVar("class") then return client:notify(L("doorNotAllowedToOwn")) end
            if IsValid(door:GetDTEntity(0)) then
                client:notify(L("doorOwnedBy", door:GetDTEntity(0):Name()))
                return false
            end

            local price = door:getNetVar("price", 0)
            if client:getChar():hasMoney(price) then
                door:SetDTEntity(0, client)
                door.liaAccess = {
                    [client] = DOOR_OWNER
                }

                MODULE:callOnDoorChildren(door, function(child) child:SetDTEntity(0, client) end)
                client:getChar():takeMoney(price)
                client:notify(L("doorPurchased", lia.currency.get(price)))
                hook.Run("OnPlayerPurchaseDoor", client, door, true, MODULE.callOnDoorChildren)
                lia.log.add(client, "buydoor", price)
            else
                client:notify(L("doorCanNotAfford"))
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doortoggleownable", {
    adminOnly = true,
    syntax = "[string name]",
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Toggle Door Ownable",
        TargetClass = "Door",
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local isUnownable = door:getNetVar("noSell", false)
            local newState = not isUnownable
            door:setNetVar("noSell", newState and true or nil)
            MODULE:callOnDoorChildren(door, function(child) child:setNetVar("noSell", newState and true or nil) end)
            lia.log.add(client, "doorToggleOwnable", door, newState)
            client:notify(newState and L("doorMadeUnownable") or L("doorMadeOwnable"))
            MODULE:SaveData()
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorresetdata", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Reset Door Data",
        TargetClass = "Door"
    },
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
            door:setNetVar("price", 0)
            door:setNetVar("locked", false)
            MODULE:callOnDoorChildren(door, function(child)
                child:setNetVar("disabled", nil)
                child:setNetVar("noSell", nil)
                child:setNetVar("hidden", nil)
                child:setNetVar("class", nil)
                child:setNetVar("factions", "[]")
                child:setNetVar("title", nil)
                child:setNetVar("price", 0)
                child:setNetVar("locked", false)
            end)

            client:notify(L("doorResetData"))
            MODULE:SaveData()
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doortoggleenabled", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Toggle Door Enabled",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local isDisabled = door:getNetVar("disabled", false)
            local newState = not isDisabled
            door:setNetVar("disabled", newState and true or nil)
            MODULE:callOnDoorChildren(door, function(child) child:setNetVar("disabled", newState and true or nil) end)
            lia.log.add(client, newState and "doorDisable" or "doorEnable", door)
            client:notify(newState and L("doorSetDisabled") or L("doorSetNotDisabled"))
            MODULE:SaveData()
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doortogglehidden", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Toggle Door Hidden",
        TargetClass = "Door"
    },
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

            client:notify(newState and L("doorSetHidden") or L("doorSetNotHidden"))
            MODULE:SaveData()
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorsetprice", {
    adminOnly = true,
    syntax = "[number price]",
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Set Door Price",
        TargetClass = "Door",
        ExtraFields = {
            ["price"] = "text"
        }
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if not arguments[1] or not tonumber(arguments[1]) then return client:notify(L("invalidClass")) end
            local price = math.Clamp(math.floor(tonumber(arguments[1])), 0, 1000000)
            door:setNetVar("price", price)
            MODULE:callOnDoorChildren(door, function(child) child:setNetVar("price", price) end)
            lia.log.add(client, "doorSetPrice", door, price)
            client:notify(L("doorPrice", lia.currency.get(price)))
            MODULE:SaveData()
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorsettitle", {
    adminOnly = true,
    syntax = "[string title]",
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Set Door Title",
        TargetClass = "Door",
        ExtraFields = {
            ["title"] = "text"
        }
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            local name = table.concat(arguments, " ")
            if not name:find("%S") then return client:notify(L("invalidClass")) end
            if door:checkDoorAccess(client, DOOR_TENANT) then
                door:setNetVar("title", name)
                lia.log.add(client, "doorSetTitle", door, name)
            elseif client:isStaff() then
                door:setNetVar("name", name)
                MODULE:callOnDoorChildren(door, function(child) child:setNetVar("name", name) end)
                lia.log.add(client, "doorSetTitle", door, name)
            else
                client:notify(L("doorNotOwner"))
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorsetparent", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Set Door Parent",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            client.liaDoorParent = door
            lia.log.add(client, "doorSetParent", door)
            client:notify(L("doorSetParentDoor"))
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorsetchild", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Set Door Child",
        TargetClass = "Door"
    },
    ExtraFields = {},
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client.liaDoorParent == door then return client:notify(L("doorCanNotSetAsChild")) end
            if IsValid(client.liaDoorParent) then
                client.liaDoorParent.liaChildren = client.liaDoorParent.liaChildren or {}
                client.liaDoorParent.liaChildren[door:MapCreationID()] = true
                door.liaParent = client.liaDoorParent
                lia.log.add(client, "doorAddChild", client.liaDoorParent, door)
                client:notify(L("doorAddChildDoor"))
                MODULE:SaveData()
                MODULE:copyParentDoor(door)
            else
                client:notify(L("doorNoParentDoor"))
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("doorremovechild", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Remove Door Child",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() and not door:getNetVar("disabled", false) then
            if client.liaDoorParent == door then
                MODULE:callOnDoorChildren(door, function(child)
                    lia.log.add(client, "doorRemoveChild", door, child)
                    child.liaParent = nil
                end)

                door.liaChildren = nil
                client:notify(L("doorRemoveChildren"))
                return
            end

            if IsValid(door.liaParent) and door.liaParent.liaChildren then
                door.liaParent.liaChildren[door:MapCreationID()] = nil
                lia.log.add(client, "doorRemoveChild", door.liaParent, door)
                door.liaParent = nil
                client:notify(L("doorRemoveChildDoor"))
                MODULE:SaveData()
            end
        else
            client:notify(L("doorNotValid"))
        end
    end
})

lia.command.add("savedoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Save Doors",
        TargetClass = "Door"
    },
    onRun = function(client)
        MODULE:SaveData()
        lia.log.add(client, "doorSaveData")
        client:notify("Saved Doors!")
    end
})

lia.command.add("doorinfo", {
    adminOnly = true,
    privilege = "Manage Doors",
    AdminStick = {
        Name = "Get Door Information",
        TargetClass = "Door"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local disabled = door:getNetVar("disabled", false)
            local name = door:getNetVar("title", door:getNetVar("name", L("doorTitle")))
            local price = door:getNetVar("price", 0)
            local noSell = door:getNetVar("noSell", false)
            local faction = door:getNetVar("faction", "None")
            local factions = door:getNetVar("factions", "[]")
            local class = door:getNetVar("class", "None")
            local hidden = door:getNetVar("hidden", false)
            local locked = door:getNetVar("locked", false)
            client:ChatPrint("disabled: " .. tostring(disabled) .. "\n" .. "name: " .. tostring(name) .. "\n" .. "price: " .. lia.currency.get(price) .. "\n" .. "noSell: " .. tostring(noSell) .. "\n" .. "faction: " .. tostring(faction) .. "\n" .. "factions: " .. tostring(factions) .. "\n" .. "class: " .. tostring(class) .. "\n" .. "hidden: " .. tostring(hidden) .. "\n" .. "locked: " .. tostring(locked))
        else
            client:notify(L("doorNotValid"))
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
                    if lia.util.stringMatches(k, name) or lia.util.stringMatches(v.name, name) then
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
                client:notify(L("doorSetFaction", faction.name))
            elseif arguments[1] then
                client:notify(L("invalidFaction"))
            else
                door:setNetVar("factions", "[]")
                MODULE:callOnDoorChildren(door, function() door:setNetVar("factions", "[]") end)
                lia.log.add(client, "doorRemoveFaction", door, "all")
                client:notify(L("doorRemoveFaction"))
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
                    if lia.util.stringMatches(k, name) or lia.util.stringMatches(v.name, name) then
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
                client:notify(L("doorRemoveFaction", faction.name))
            elseif arguments[1] then
                client:notify(L("invalidFaction"))
            else
                door:setNetVar("factions", "[]")
                MODULE:callOnDoorChildren(door, function() door:setNetVar("factions", "[]") end)
                lia.log.add(client, "doorRemoveFaction", door, "all")
                client:notify(L("doorRemoveFaction"))
            end

            MODULE:SaveData()
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
                    if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(v.name, name) then
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
                client:notify(L("doorSetClass", classData.name))
            elseif arguments[1] then
                client:notify(L("invalidClass"))
            else
                door:setNetVar("class", nil)
                MODULE:callOnDoorChildren(door, function() door:setNetVar("class", nil) end)
                lia.log.add(client, "doorRemoveClass", door)
                client:notify(L("doorRemoveClass"))
            end

            MODULE:SaveData()
        end
    end,
    alias = {"jobdoor"}
})

lia.command.add("togglealldoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function(client)
        local toggleToDisable = false
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                toggleToDisable = not door:getNetVar("disabled", false)
                break
            end
        end

        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() and door:getNetVar("disabled", false) ~= toggleToDisable then
                door:setNetVar("disabled", toggleToDisable and true or nil)
                lia.log.add(client, toggleToDisable and "doorDisable" or "doorEnable", door)
                MODULE:callOnDoorChildren(door, function(child)
                    child:setNetVar("disabled", toggleToDisable and true or nil)
                    lia.log.add(client, toggleToDisable and "doorDisable" or "doorEnable", child)
                end)

                count = count + 1
            end
        end

        client:notify(L(toggleToDisable and "doorDisableAll" or "doorEnableAll", count))
        lia.log.add(client, toggleToDisable and "doorDisableAll" or "doorEnableAll", count)
        MODULE:SaveData()
    end
})