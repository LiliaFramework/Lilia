lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name) return L("charRecognizeLog", client:SteamID64(), client:Name(), id, name, client:getChar():getID()) end,
        category = L("recognition")
    },
    ["charCreate"] = {
        func = function(client, character) return L("charCreateLog", client:SteamID64(), client:Name(), character:getName(), character:getID()) end,
        category = L("character")
    },
    ["charLoad"] = {
        func = function(client, name) return L("charLoadLog", client:SteamID64(), client:Name(), name, client:getChar():getID()) end,
        category = L("character")
    },
    ["charDelete"] = {
        func = function(client, id) return L("charDeleteLog", IsValid(client) and client:SteamID64() or "CONSOLE", IsValid(client) and client:Name() or "CONSOLE", id, IsValid(client) and client:getChar():getID() or L("unknown")) end,
        category = L("character")
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return L("playerHurtLog", client:SteamID64(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = L("damage")
    },
    ["playerDeath"] = {
        func = function(client, attacker) return L("playerDeathLog", client:SteamID64(), client:Name(), attacker, client:getChar():getID()) end,
        category = L("death")
    },
    ["spawned_prop"] = {
        func = function(client, model) return L("spawned_propLog", client:SteamID64(), client:Name(), model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return L("spawned_ragdollLog", client:SteamID64(), client:Name(), model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_effect"] = {
        func = function(client, effect) return L("spawned_effectLog", client:SteamID64(), client:Name(), effect, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return L("spawned_vehicleLog", client:SteamID64(), client:Name(), vehicle, model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return L("spawned_npcLog", client:SteamID64(), client:Name(), npc, model, client:getChar():getID()) end,
        category = L("spawn")
    },
    ["swep_spawning"] = {
        func = function(client, swep) return L("swep_spawningLog", client:SteamID64(), client:Name(), swep, client:getChar():getID()) end,
        category = L("swep")
    },
    ["chat"] = {
        func = function(client, chatType, message) return L("chatLog", client:SteamID64(), chatType, client:Name(), message, client:getChar():getID()) end,
        category = L("chat")
    },
    ["chatOOC"] = {
        func = function(client, msg) return L("chatOOCLog", client:SteamID64(), client:Name(), msg, client:getChar():getID()) end,
        category = L("chat")
    },
    ["chatLOOC"] = {
        func = function(client, msg) return L("chatLOOCLog", client:SteamID64(), client:Name(), msg, client:getChar():getID()) end,
        category = L("chat")
    },
    ["command"] = {
        func = function(client, text) return L("commandLog", client:SteamID64(), client:Name(), text, client:getChar():getID()) end,
        category = L("chat")
    },
    ["money"] = {
        func = function(client, amount) return L("moneyLog", client:SteamID64(), client:Name(), amount, client:getChar():getID()) end,
        category = L("money")
    },
    ["moneyGiven"] = {
        func = function(client, name, amount) return L("moneyGivenLog", client:SteamID64(), client:Name(), name, lia.currency.get(amount), client:getChar():getID()) end,
        category = L("money")
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return L("moneyPickedUpLog", client:SteamID64(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = L("money")
    },
    ["itemTake"] = {
        func = function(client, item) return L("itemTakeLog", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = L("items")
    },
    ["use"] = {
        func = function(client, item) return L("itemUseLog", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = L("items")
    },
    ["itemDrop"] = {
        func = function(client, item) return L("itemDropLog", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = L("items")
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return L("itemInteractionLog", client:SteamID64(), client:Name(), action, item.name, client:getChar():getID()) end,
        category = L("items")
    },
    ["itemEquip"] = {
        func = function(client, item) return L("itemEquipLog", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = L("items")
    },
    ["itemUnequip"] = {
        func = function(client, item) return L("itemUnequipLog", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = L("items")
    },
    ["toolgunUse"] = {
        func = function(client, tool) return L("toolgunUseLog", client:SteamID64(), client:Name(), tool, client:getChar():getID()) end,
        category = L("toolgun")
    },
    ["playerConnected"] = {
        func = function(client) return L("playerConnectedLog", client:SteamID64(), client:Name()) end,
        category = L("connections")
    },
    ["playerDisconnected"] = {
        func = function(client) return L("playerDisconnectedLog", client:SteamID64(), client:Name()) end,
        category = L("connections")
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return L("doorLogSetClass", client:SteamID64(), client:Name(), className, door:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return L("doorLogRemoveClass", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorSaveData"] = {
        func = function(client) return L("doorLogSaveData", client:Nick(), client:SteamID64(), client:Name()) end,
        category = L("doors")
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return L("doorLogToggleOwnable", client:SteamID64(), client:Name(), door:GetClass(), state and "unownable" or "ownable") end,
        category = L("doors")
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return L("doorLogSetFaction", client:SteamID64(), client:Name(), factionName, door:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return L("doorLogRemoveFaction", client:SteamID64(), client:Name(), factionName, door:GetClass()) end,
        category = L("doors")
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return L("doorLogToggleOwnable", client:SteamID64(), client:Name(), door:GetClass(), state and "hidden" or "visible") end,
        category = L("doors")
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return L("doorLogSetTitle", client:SteamID64(), client:Name(), title, door:GetClass()) end,
        category = L("doors")
    },
    ["doorResetData"] = {
        func = function(client, door) return L("doorLogResetData", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorSetParent"] = {
        func = function(client, door) return L("doorLogSetParent", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorAddChild"] = {
        func = function(client, parentDoor, childDoor) return L("doorLogAddChild", client:SteamID64(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = L("doors")
    },
    ["doorRemoveChild"] = {
        func = function(client, parentDoor, childDoor) return L("doorLogRemoveChild", client:SteamID64(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = L("doors")
    },
    ["doorForceLock"] = {
        func = function(client, door) return L("doorLogForceLock", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorForceUnlock"] = {
        func = function(client, door) return L("doorLogForceUnlock", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorDisable"] = {
        func = function(client, door) return L("doorLogDisable", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorEnable"] = {
        func = function(client, door) return L("doorLogEnable", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = L("doors")
    },
    ["doorDisableAll"] = {
        func = function(client, count) return L("doorLogDisableAll", client:SteamID64(), client:Name(), count) end,
        category = L("doors")
    },
    ["doorEnableAll"] = {
        func = function(client, count) return L("doorLogEnableAll", client:SteamID64(), client:Name(), count) end,
        category = L("doors")
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return L("spawnItemLog", client:SteamID64(), displayName, message) end,
        category = L("itemSpawner")
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return L("chargiveItemLog", client:SteamID64(), target:Name(), itemName, message) end,
        category = L("itemSpawner")
    },
    ["vendorAccess"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return L("vendorLogAccess", client:SteamID64(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorExit"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return L("vendorLogExit", client:SteamID64(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorSell"] = {
        func = function(client, item, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return L("vendorLogSell", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return L("vendorLogEdit", client:SteamID64(), client:Name(), vendorName, key, client:getChar():getID())
        end,
        category = L("vendors")
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor, isFailed)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            if isFailed then
                return L("vendorLogBuyFail", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
            else
                return L("vendorLogBuySuccess", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
            end
        end,
        category = L("vendors")
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return L("configChangeLog", name, tostring(oldValue), tostring(value)) end,
        category = L("adminActions")
    },
    ["warningIssued"] = {
        func = function(client, target, reason) return L("warningIssuedLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), target:SteamID64(), reason) end,
        category = L("warnings")
    },
    ["warningRemoved"] = {
        func = function(client, target, warning) return L("warningRemovedLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), target:SteamID64(), warning.reason) end,
        category = L("warnings")
    },
    ["adminMode"] = {
        func = function(client, id, message) return L("adminModeLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), message, id) end,
        category = L("adminActions")
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message) return L("sitRoomSetLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), message, pos) end,
        category = L("sitRooms")
    },
    ["sendToSitRoom"] = {
        func = function(client, target, message) return L("sendToSitRoomLog", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), message, target) end,
        category = L("sitRooms")
    },
    ["unprotectedVJNetCall"] = {
        func = function(client, netMessage) return L("unprotectedVJNetCallLog", client:SteamID64(), client:Name(), netMessage) end,
        category = L("logCategoryVJNet")
    }
}
