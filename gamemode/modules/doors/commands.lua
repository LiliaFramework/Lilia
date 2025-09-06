﻿local MODULE = MODULE
lia.command.add("doorsell", {
    desc = "doorsellDesc",
    adminOnly = false,
    AdminStick = {
        Name = "adminStickDoorSellName",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                if client == door:GetDTEntity(0) then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    client:getChar():giveMoney(price)
                    client:notifyLocalized("doorSold", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, door, false)
                    lia.log.add(client, "doorsell", price)
                else
                    client:notifyLocalized("doorNotOwner")
                end
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("admindoorsell", {
    desc = "admindoorsellDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickAdminDoorSellName",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money_delete.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local owner = door:GetDTEntity(0)
                if IsValid(owner) and owner:IsPlayer() then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    owner:getChar():giveMoney(price)
                    owner:notifyLocalized("doorSold", lia.currency.get(price))
                    client:notifyLocalized("doorSold", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", owner, door, false)
                    lia.log.add(client, "admindoorsell", owner:Name(), price)
                else
                    client:notifyLocalized("doorNotOwner")
                end
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortogglelock", {
    desc = "doortogglelockDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorLockName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/lock.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local currentLockState = door:GetInternalVariable("m_bLocked")
                local toggleState = not currentLockState
                if toggleState then
                    door:Fire("lock")
                    door:EmitSound("doors/door_latch3.wav")
                    client:notifyLocalized("doorToggleLocked", L("locked"):lower())
                    lia.log.add(client, "toggleLock", door, L("locked"))
                else
                    door:Fire("unlock")
                    door:EmitSound("doors/door_latch1.wav")
                    client:notifyLocalized("doorToggleLocked", L("unlocked"))
                    lia.log.add(client, "toggleLock", door, L("unlocked"))
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
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorbuy", {
    desc = "doorbuyDesc",
    adminOnly = false,
    AdminStick = {
        Name = "buyDoor",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money_add.png"
    },
    onRun = function(client)
        if lia.config.get("DisableCheaterActions", true) and client:getNetVar("cheater", false) then
            lia.log.add(client, "cheaterAction", L("buyDoor"):lower())
            client:notifyLocalized("maybeYouShouldntHaveCheated")
            return
        end

        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local factions = doorData.factions
                local classes = doorData.classes
                if doorData.noSell or (factions and #factions > 0) or (classes and #classes > 0) then return client:notifyLocalized("doorNotAllowedToOwn") end
                if IsValid(door:GetDTEntity(0)) then
                    client:notifyLocalized("doorOwnedBy", door:GetDTEntity(0):Name())
                    return false
                end

                local price = doorData.price or 0
                if client:getChar():hasMoney(price) then
                    door:SetDTEntity(0, client)
                    door.liaAccess = {
                        [client] = DOOR_OWNER
                    }

                    client:getChar():takeMoney(price)
                    client:notifyLocalized("doorPurchased", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, door, true)
                    lia.log.add(client, "buydoor", price)
                else
                    client:notifyLocalized("doorCanNotAfford")
                end
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortoggleownable", {
    desc = "doortoggleownableDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorOwnableName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/pencil.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local isUnownable = doorData.noSell or false
                local newState = not isUnownable
                doorData.noSell = newState and true or nil
                door:setNetVar("doorData", doorData)
                lia.log.add(client, "doorToggleOwnable", door, newState)
                hook.Run("DoorOwnableToggled", client, door, newState)
                client:notifyLocalized(newState and "doorMadeUnownable" or "doorMadeOwnable")
                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorresetdata", {
    desc = "doorresetdataDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickResetDoorDataName",
        Category = "doorManagement",
        SubCategory = "doorMaintenance",
        TargetClass = "door",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            lia.log.add(client, "doorResetData", door)
            local doorData = {
                disabled = nil,
                noSell = nil,
                hidden = nil,
                classes = nil,
                factions = {},
                name = nil,
                price = 0,
                locked = false
            }

            door:setNetVar("doorData", doorData)
            client:notifyLocalized("doorResetData")
            MODULE:SaveData()
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortoggleenabled", {
    desc = "doortoggleenabledDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorEnabledName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/stop.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            local isDisabled = doorData.disabled or false
            local newState = not isDisabled
            doorData.disabled = newState and true or nil
            door:setNetVar("doorData", doorData)
            lia.log.add(client, newState and "doorDisable" or "doorEnable", door)
            hook.Run("DoorEnabledToggled", client, door, newState)
            client:notifyLocalized(newState and "doorSetDisabled" or "doorSetNotDisabled")
            MODULE:SaveData()
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortogglehidden", {
    desc = "doortogglehiddenDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorHiddenName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/eye.png"
    },
    onRun = function(client)
        local entity = client:GetEyeTrace().Entity
        if IsValid(entity) and entity:isDoor() then
            local doorData = entity:getNetVar("doorData", {})
            local currentState = doorData.hidden or false
            local newState = not currentState
            doorData.hidden = newState
            entity:setNetVar("doorData", doorData)
            lia.log.add(client, "doorSetHidden", entity, newState)
            hook.Run("DoorHiddenToggled", client, entity, newState)
            client:notifyLocalized(newState and "doorSetHidden" or "doorSetNotHidden")
            MODULE:SaveData()
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsetprice", {
    desc = "doorsetpriceDesc",
    arguments = {
        {
            name = "price",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSetDoorPriceName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                if not arguments[1] or not tonumber(arguments[1]) then return client:notifyLocalized("invalidClass") end
                local price = math.Clamp(math.floor(tonumber(arguments[1])), 0, 1000000)
                doorData.price = price
                door:setNetVar("doorData", doorData)
                lia.log.add(client, "doorSetPrice", door, price)
                hook.Run("DoorPriceSet", client, door, price)
                client:notifyLocalized("doorSetPrice", lia.currency.get(price))
                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsettitle", {
    desc = "doorsettitleDesc",
    arguments = {
        {
            name = "title",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSetDoorTitleName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/textfield.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local name = table.concat(arguments, " ")
                if not name:find("%S") then return client:notifyLocalized("invalidClass") end
                if door:checkDoorAccess(client, DOOR_TENANT) then
                    doorData.title = name
                    door:setNetVar("doorData", doorData)
                    hook.Run("DoorTitleSet", client, door, name)
                    lia.log.add(client, "doorSetTitle", door, name)
                elseif client:isStaff() then
                    doorData.name = name
                    door:setNetVar("doorData", doorData)
                    hook.Run("DoorTitleSet", client, door, name)
                    lia.log.add(client, "doorSetTitle", door, name)
                else
                    client:notifyLocalized("doorNotOwner")
                end
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("savedoors", {
    desc = "savedoorsDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSaveDoorsName",
        Category = "doorManagement",
        SubCategory = "doorMaintenance",
        TargetClass = "door",
        Icon = "icon16/disk.png"
    },
    onRun = function(client)
        MODULE:SaveData()
        lia.log.add(client, "doorSaveData")
        client:notifyLocalized("doorsSaved")
    end
})

lia.command.add("doorinfo", {
    desc = "doorinfoDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickDoorInfoName",
        Category = "doorManagement",
        SubCategory = "doorInformation",
        TargetClass = "door",
        Icon = "icon16/information.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            local disabled = doorData.disabled or false
            local price = doorData.price or 0
            local noSell = doorData.noSell or false
            local factions = doorData.factions or {}
            local factionNames = {}
            for _, id in ipairs(factions) do
                local info = lia.faction.get(id)
                if info then table.insert(factionNames, info.name) end
            end

            local classes = doorData.classes or {}
            local classNames = {}
            for _, uid in ipairs(classes) do
                local idx = lia.class.retrieveClass(uid)
                local info = lia.class.list[idx]
                if info then table.insert(classNames, info.name) end
            end

            local hidden = doorData.hidden or false
            local locked = doorData.locked or false
            local infoData = {
                {
                    property = L("doorInfoDisabled"),
                    value = tostring(disabled)
                },
                {
                    property = L("name"),
                    value = tostring(doorData.title or doorData.name or L("doorTitle"))
                },
                {
                    property = L("price"),
                    value = lia.currency.get(price)
                },
                {
                    property = L("doorInfoNoSell"),
                    value = tostring(noSell)
                },
                {
                    property = L("factions"),
                    value = tostring(not table.IsEmpty(factionNames) and table.concat(factionNames, ", ") or L("none"))
                },
                {
                    property = L("classes"),
                    value = tostring(not table.IsEmpty(classNames) and table.concat(classNames, ", ") or L("none"))
                },
                {
                    property = L("doorInfoHidden"),
                    value = tostring(hidden)
                },
                {
                    property = L("locked"),
                    value = tostring(locked)
                }
            }

            lia.util.SendTableUI(client, L("door") .. " " .. L("information"), {
                {
                    name = "doorInfoProperty",
                    field = "property"
                },
                {
                    name = "doorInfoValue",
                    field = "value"
                }
            }, infoData)
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("dooraddfaction", {
    desc = "dooraddfactionDesc",
    arguments = {
        {
            name = "faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local input = arguments[1]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyLocalized("invalidFaction")
                            return
                        end
                    else
                        for k, v in pairs(lia.faction.teams) do
                            if lia.util.stringMatches(k, input) or lia.util.stringMatches(v.name, input) then
                                faction = v
                                break
                            end
                        end
                    end
                end

                if faction then
                    local facs = doorData.factions or {}
                    if not table.HasValue(facs, faction.uniqueID) then facs[#facs + 1] = faction.uniqueID end
                    doorData.factions = facs
                    door.liaFactions = facs
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorSetFaction", door, faction.name)
                    client:notifyLocalized("doorSetFaction", faction.name)
                elseif arguments[1] then
                    client:notifyLocalized("invalidFaction")
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorRemoveFaction", door, "all")
                    client:notifyLocalized("doorRemoveFaction")
                end

                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorremovefaction", {
    desc = "doorremovefactionDesc",
    arguments = {
        {
            name = "faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local input = arguments[1]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyLocalized("invalidFaction")
                            return
                        end
                    else
                        for k, v in pairs(lia.faction.teams) do
                            if lia.util.stringMatches(k, input) or lia.util.stringMatches(v.name, input) then
                                faction = v
                                break
                            end
                        end
                    end
                end

                if faction then
                    local facs = doorData.factions or {}
                    table.RemoveByValue(facs, faction.uniqueID)
                    doorData.factions = facs
                    door.liaFactions = facs
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorRemoveFaction", door, faction.name)
                    client:notifyLocalized("doorRemoveFactionSpecific", faction.name)
                elseif arguments[1] then
                    client:notifyLocalized("invalidFaction")
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorRemoveFaction", door, "all")
                    client:notifyLocalized("doorRemoveFaction")
                end

                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsetclass", {
    desc = "doorsetclassDesc",
    arguments = {
        {
            name = "class",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local input = arguments[1]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyLocalized("invalidClass")
                            return
                        end
                    else
                        local id = lia.class.retrieveClass(input)
                        if id then
                            class, classData = id, lia.class.list[id]
                        else
                            for k, v in pairs(lia.class.list) do
                                if lia.util.stringMatches(v.name, input) or lia.util.stringMatches(v.uniqueID, input) then
                                    class, classData = k, v
                                    break
                                end
                            end
                        end
                    end
                end

                if class then
                    local classes = doorData.classes or {}
                    if not table.HasValue(classes, classData.uniqueID) then classes[#classes + 1] = classData.uniqueID end
                    doorData.classes = classes
                    door.liaClasses = classes
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorSetClass", door, classData.name)
                    client:notifyLocalized("doorSetClass", classData.name)
                elseif arguments[1] then
                    client:notifyLocalized("invalidClass")
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorRemoveClass", door)
                    client:notifyLocalized("doorRemoveClass")
                end

                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end,
    alias = {"jobdoor"}
})

lia.command.add("doorremoveclass", {
    desc = "doorremoveclassDesc",
    arguments = {
        {
            name = "class",
            type = "string"
        }
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickDoorRemoveClassName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/delete.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = door:getNetVar("doorData", {})
            if not doorData.disabled then
                local input = arguments[1]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyLocalized("invalidClass")
                            return
                        end
                    else
                        local id = lia.class.retrieveClass(input)
                        if id then
                            class, classData = id, lia.class.list[id]
                        else
                            for k, v in pairs(lia.class.list) do
                                if lia.util.stringMatches(v.name, input) or lia.util.stringMatches(v.uniqueID, input) then
                                    class, classData = k, v
                                    break
                                end
                            end
                        end
                    end
                end

                if class then
                    local classes = doorData.classes or {}
                    if table.HasValue(classes, classData.uniqueID) then
                        table.RemoveByValue(classes, classData.uniqueID)
                        doorData.classes = classes
                        door.liaClasses = classes
                        door:setNetVar("doorData", doorData)
                        lia.log.add(client, "doorRemoveClassSpecific", door, classData.name)
                        client:notifyLocalized("doorRemoveClassSpecific", classData.name)
                    else
                        client:notifyLocalized("doorClassNotAssigned", classData.name)
                    end
                elseif arguments[1] then
                    client:notifyLocalized("invalidClass")
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, "doorRemoveClass", door)
                    client:notifyLocalized("doorRemoveClass")
                end

                MODULE:SaveData()
            else
                client:notifyLocalized("doorNotValid")
            end
        else
            client:notifyLocalized("doorNotValid")
        end
    end
})

lia.command.add("togglealldoors", {
    desc = "togglealldoorsDesc",
    adminOnly = true,
    onRun = function(client)
        local toggleToDisable = false
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = door:getNetVar("doorData", {})
                toggleToDisable = not (doorData.disabled or false)
                break
            end
        end

        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = door:getNetVar("doorData", {})
                if (doorData.disabled or false) ~= toggleToDisable then
                    doorData.disabled = toggleToDisable and true or nil
                    door:setNetVar("doorData", doorData)
                    lia.log.add(client, toggleToDisable and "doorDisable" or "doorEnable", door)
                    count = count + 1
                end
            end
        end

        client:notifyLocalized(toggleToDisable and "doorDisableAll" or "doorEnableAll", count)
        lia.log.add(client, toggleToDisable and "doorDisableAll" or "doorEnableAll", count)
        MODULE:SaveData()
    end
})

lia.command.add("doorid", {
    desc = "Shows the door ID of the door you're looking at",
    adminOnly = true,
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local mapID = door:MapCreationID()
            if mapID and mapID > 0 then
                local pos = door:GetPos()
                client:notifyLocalized("Door ID: " .. mapID .. " | Position: " .. string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z))
                lia.log.add(client, "doorID", door, mapID)
            else
                client:notifyLocalized("This door doesn't have a valid map ID")
            end
        else
            client:notifyLocalized("You must be looking at a door")
        end
    end
})

lia.command.add("listdoorids", {
    desc = "Lists all door IDs on the map for preset creation",
    adminOnly = true,
    onRun = function(client)
        local doorData = {}
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local mapID = door:MapCreationID()
                if mapID and mapID > 0 then
                    local pos = door:GetPos()
                    table.insert(doorData, {
                        id = mapID,
                        position = string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z),
                        model = door:GetModel() or "unknown"
                    })
                end
            end
        end

        if #doorData == 0 then
            client:notifyLocalized("No doors found on this map")
            return
        end

        table.sort(doorData, function(a, b) return a.id < b.id end)
        local doorList = {}
        for _, data in ipairs(doorData) do
            table.insert(doorList, {
                property = "Door ID: " .. data.id,
                value = "Pos: " .. data.position .. " | Model: " .. data.model
            })
        end

        lia.util.SendTableUI(client, "Door IDs on " .. game.GetMap(), {
            {
                name = "Door ID",
                field = "property"
            },
            {
                name = "Details",
                field = "value"
            }
        }, doorList)

        client:notifyLocalized("Found " .. #doorData .. " doors. Check your UI for details.")
    end
})
