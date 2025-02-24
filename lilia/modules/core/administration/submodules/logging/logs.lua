lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name) return L("charRecognizeLog", client:SteamID(), client:Name(), id, name, client:getChar():getID()) end,
        category = L("recognition")
    },
    ["charCreate"] = {
        func = function(client, character) return L("charCreateLog", client:SteamID(), client:Name(), character:getName(), character:getID()) end,
        category = L("characterCategory")
    },
    ["charLoad"] = {
        func = function(client, name) return L("charLoadLog", client:SteamID(), client:Name(), name, client:getChar():getID()) end,
        category = L("characterCategory")
    },
    ["charDelete"] = {
        func = function(client, id) return L("charDeleteLog", IsValid(client) and client:SteamID() or "CONSOLE", IsValid(client) and client:Name() or "CONSOLE", id, IsValid(client) and client:getChar():getID() or "Unknown") end,
        category = L("characterCategory")
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return L("playerHurtLog", client:SteamID(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = L("damage")
    },
    ["playerDeath"] = {
        func = function(client, attacker) return L("playerDeathLog", client:SteamID(), client:Name(), attacker, client:getChar():getID()) end,
        category = L("death")
    },
    ["spawned_prop"] = {
        func = function(client, model) return L("spawned_propLog", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return L("spawned_ragdollLog", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_effect"] = {
        func = function(client, effect) return L("spawned_effectLog", client:SteamID(), client:Name(), effect, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return L("spawned_vehicleLog", client:SteamID(), client:Name(), vehicle, model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return L("spawned_npcLog", client:SteamID(), client:Name(), npc, model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["swep_spawning"] = {
        func = function(client, swep) return L("swep_spawningLog", client:SteamID(), client:Name(), swep, client:getChar():getID()) end,
        category = L("swep")
    },
    ["chat"] = {
        func = function(client, chatType, message) return L("chatLog", client:SteamID(), chatType, client:Name(), message, client:getChar():getID()) end,
        category = L("chatCategory")
    },
    ["chatOOC"] = {
        func = function(client, msg) return L("chatOOCLog", client:SteamID(), client:Name(), msg, client:getChar():getID()) end,
        category = L("chatCategory")
    },
    ["chatLOOC"] = {
        func = function(client, msg) return L("chatLOOCLog", client:SteamID(), client:Name(), msg, client:getChar():getID()) end,
        category = L("chatCategory")
    },
    ["command"] = {
        func = function(client, text) return L("commandLog", client:SteamID(), client:Name(), text, client:getChar():getID()) end,
        category = L("chatCategory")
    },
    ["money"] = {
        func = function(client, amount) return L("moneyLog", client:SteamID(), client:Name(), amount, client:getChar():getID()) end,
        category = L("moneyCategory")
    },
    ["moneyGiven"] = {
        func = function(client, name, amount) return L("moneyGivenLog", client:SteamID(), client:Name(), name, lia.currency.get(amount), client:getChar():getID()) end,
        category = L("moneyCategory")
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return L("moneyPickedUpLog", client:SteamID(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = L("moneyCategory")
    },
    ["itemTake"] = {
        func = function(client, item) return L("itemTakeLog", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["itemUse"] = {
        func = function(client, item) return L("itemUseLog", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["itemDrop"] = {
        func = function(client, item) return L("itemDropLog", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return L("itemInteractionLog", client:SteamID(), client:Name(), action, item.name, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["itemEquip"] = {
        func = function(client, item) return L("itemEquipLog", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["itemUnequip"] = {
        func = function(client, item) return L("itemUnequipLog", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = L("itemCategory")
    },
    ["invalidNet"] = {
        func = function(client) return L("invalidNetLog", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = L("protection")
    },
    ["toolgunUse"] = {
        func = function(client, tool) return L("toolgunUseLog", client:SteamID(), client:Name(), tool, client:getChar():getID()) end,
        category = L("toolgun")
    },
    ["playerConnected"] = {
        func = function(client) return L("playerConnectedLog", client:SteamID(), client:Name()) end,
        category = L("connections")
    },
    ["playerDisconnected"] = {
        func = function(client) return L("playerDisconnectedLog", client:SteamID(), client:Name()) end,
        category = L("connections")
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return L("doorLogSetClass", client:SteamID(), client:Name(), className, door:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return L("doorLogRemoveClass", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorSaveData"] = {
        func = function(client) return L("doorLogSaveData", client:SteamID(), client:Name()) end,
        category = L("doors")
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return L("doorLogToggleOwnable", client:SteamID(), client:Name(), door:GetClass(), state and "unownable" or "ownable") end,
        category = L("doors")
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return L("doorLogSetFaction", client:SteamID(), client:Name(), factionName, door:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return L("doorLogRemoveFaction", client:SteamID(), client:Name(), factionName, door:GetClass()) end,
        category = L("doors")
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return L("doorLogSetHidden", client:SteamID(), client:Name(), door:GetClass(), state and "hidden" or "visible") end,
        category = L("doors")
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return L("doorLogSetTitle", client:SteamID(), client:Name(), title, door:GetClass()) end,
        category = L("doors")
    },
    ["doorResetData"] = {
        func = function(client, door) return L("doorLogResetData", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorSetParent"] = {
        func = function(client, door) return L("doorLogSetParent", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorAddChild"] = {
        func = function(client, parentDoor, childDoor) return L("doorLogAddChild", client:SteamID(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveChild"] = {
        func = function(client, parentDoor, childDoor) return L("doorLogRemoveChild", client:SteamID(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = L("doors")
    },
    ["doorForceLock"] = {
        func = function(client, door) return L("doorLogForceLock", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorForceUnlock"] = {
        func = function(client, door) return L("doorLogForceUnlock", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorDisable"] = {
        func = function(client, door) return L("doorLogDisable", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorEnable"] = {
        func = function(client, door) return L("doorLogEnable", client:SteamID(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorDisableAll"] = {
        func = function(client, count) return L("doorLogDisableAll", client:SteamID(), client:Name(), count) end,
        category = L("doors")
    },
    ["doorEnableAll"] = {
        func = function(client, count) return L("doorLogEnableAll", client:SteamID(), client:Name(), count) end,
        category = L("doors")
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return L("spawnItemLog", client:SteamID(), displayName, message) end,
        category = L("itemSpawner")
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return L("chargiveItemLog", client:SteamID(), target:Name(), itemName, message) end,
        category = L("itemSpawner")
    },
    ["vendorAccess"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return L("vendorLogAccess", client:SteamID(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorExit"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return L("vendorLogExit", client:SteamID(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorSell"] = {
        func = function(client, item, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return L("vendorLogSell", client:SteamID(), client:Name(), item, vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return L("vendorLogEdit", client:SteamID(), client:Name(), vendorName, key, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor, isFailed)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            if isFailed then
                return L("vendorLogBuyFail", client:SteamID(), client:Name(), item, vendorName, client:getChar():getID())
            else
                return L("vendorLogBuySuccess", client:SteamID(), client:Name(), item, vendorName, client:getChar():getID())
            end
        end,
        category = L("vendors")
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return L("configChangeLog", name, tostring(oldValue), tostring(value)) end,
        category = L("adminActions")
    },
    ["warningIssued"] = {
        func = function(client, target, reason) return L("warningIssuedLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), target:SteamID(), reason) end,
        category = L("warnings")
    },
    ["warningRemoved"] = {
        func = function(client, target, warning) return L("warningRemovedLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), target:SteamID(), warning.reason) end,
        category = L("warnings")
    },
    ["adminMode"] = {
        func = function(client, id, message) return L("adminModeLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, id) end,
        category = L("adminActions")
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message) return L("sitRoomSetLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, pos) end,
        category = L("sitRooms")
    },
    ["sendToSitRoom"] = {
        func = function(client, target, message) return L("sendToSitRoomLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), message, target) end,
        category = L("sitRooms")
    },
    ["unprotectedVJNetCall"] = {
        func = function(client, netMessage) return L("unprotectedVJNetCallLog", client:SteamID(), client:Name(), netMessage) end,
        category = L("logCategoryVJNet")
    }
}
