lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name) return string.format("Player '%s' recognized character with ID %s and name '%s'.", client:Name(), id, name) end,
        category = "Character"
    },
    ["charCreate"] = {
        func = function(client, character) return string.format("Player '%s' created a new character named '%s'.", client:Name(), character:getName()) end,
        category = "Character"
    },
    ["charLoad"] = {
        func = function(client, name) return string.format("Player '%s' loaded character '%s'.", client:Name(), name) end,
        category = "Character"
    },
    ["charDelete"] = {
        func = function(client, id)
            local name = IsValid(client) and client:Name() or "CONSOLE"
            return string.format("%s deleted character ID %s.", name, id)
        end,
        category = "Character"
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("Player '%s' took %s damage from '%s'. Current Health: %s", client:Name(), damage, attacker, health) end,
        category = "Combat"
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("Player '%s' was killed by '%s'.", client:Name(), attacker) end,
        category = "Combat"
    },
    ["playerSpawn"] = {
        func = function(client) return string.format("Player '%s' spawned.", client:Name()) end,
        category = "Character"
    },
    ["spawned_prop"] = {
        func = function(client, model) return string.format("Player '%s' spawned prop: %s.", client:Name(), model) end,
        category = "World"
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("Player '%s' spawned ragdoll: %s.", client:Name(), model) end,
        category = "World"
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("Player '%s' spawned effect: %s.", client:Name(), effect) end,
        category = "World"
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return string.format("Player '%s' spawned vehicle '%s' with model '%s'.", client:Name(), vehicle, model) end,
        category = "World"
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return string.format("Player '%s' spawned NPC '%s' with model '%s'.", client:Name(), npc, model) end,
        category = "World"
    },
    ["spawned_sent"] = {
        func = function(client, class, model) return string.format("Player '%s' spawned entity '%s' with model '%s'.", client:Name(), class, model) end,
        category = "World"
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("Player '%s' spawned SWEP '%s'.", client:Name(), swep) end,
        category = "Combat"
    },
    ["physgunPickup"] = {
        func = function(client, class, model) return string.format("Player '%s' picked up '%s' (%s) with the physgun.", client:Name(), class, model) end,
        category = "Tools"
    },
    ["physgunDrop"] = {
        func = function(client, class, model) return string.format("Player '%s' dropped '%s' (%s) with the physgun.", client:Name(), class, model) end,
        category = "Tools"
    },
    ["physgunFreeze"] = {
        func = function(client, class, model) return string.format("Player '%s' froze '%s' (%s) with the physgun.", client:Name(), class, model) end,
        category = "Tools"
    },
    ["vehicleEnter"] = {
        func = function(client, class, model) return string.format("Player '%s' entered vehicle '%s' (%s).", client:Name(), class, model) end,
        category = "World"
    },
    ["vehicleExit"] = {
        func = function(client, class, model) return string.format("Player '%s' left vehicle '%s' (%s).", client:Name(), class, model) end,
        category = "World"
    },
    ["chat"] = {
        func = function(client, chatType, message) return string.format("(%s) %s said: '%s'", chatType, client:Name(), message) end,
        category = "Chat"
    },
    ["chatOOC"] = {
        func = function(client, msg) return string.format("Player '%s' said (OOC): '%s'.", client:Name(), msg) end,
        category = "Chat"
    },
    ["chatLOOC"] = {
        func = function(client, msg) return string.format("Player '%s' said (LOOC): '%s'.", client:Name(), msg) end,
        category = "Chat"
    },
    ["command"] = {
        func = function(client, text) return string.format("Player '%s' ran command: %s.", client:Name(), text) end,
        category = "Chat"
    },
    ["money"] = {
        func = function(client, amount) return string.format("Player '%s' changed money by: %s.", client:Name(), amount) end,
        category = "Money"
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return string.format("Player '%s' picked up %s %s.", client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular) end,
        category = "Money"
    },
    ["charSetMoney"] = {
        func = function(client, targetName, amount) return string.format("Admin '%s' set %s's money to %s.", client:Name(), targetName, lia.currency.get(amount)) end,
        category = "Money"
    },
    ["charAddMoney"] = {
        func = function(client, targetName, amount, total) return string.format("Admin '%s' gave %s %s (New Total: %s).", client:Name(), targetName, lia.currency.get(amount), lia.currency.get(total)) end,
        category = "Money"
    },
    ["itemTake"] = {
        func = function(client, item) return string.format("Player '%s' took item '%s'.", client:Name(), item) end,
        category = "Items"
    },
    ["use"] = {
        func = function(client, item) return string.format("Player '%s' used item '%s'.", client:Name(), item) end,
        category = "Items"
    },
    ["itemDrop"] = {
        func = function(client, item) return string.format("Player '%s' dropped item '%s'.", client:Name(), item) end,
        category = "Items"
    },
    ["itemInteractionFailed"] = {
        func = function(client, action, itemName) return string.format("Player '%s' failed to %s item '%s'.", client:Name(), action, itemName) end,
        category = "Items"
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("Player '%s' %s item '%s'.", client:Name(), action, item.name) end,
        category = "Items"
    },
    ["itemEquip"] = {
        func = function(client, item) return string.format("Player '%s' equipped item '%s'.", client:Name(), item) end,
        category = "Items"
    },
    ["itemUnequip"] = {
        func = function(client, item) return string.format("Player '%s' unequipped item '%s'.", client:Name(), item) end,
        category = "Items"
    },
    ["itemTransfer"] = {
        func = function(client, itemName, fromID, toID) return string.format("Player '%s' moved item '%s' from inventory %s to %s.", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        category = "Items"
    },
    ["itemTransferFailed"] = {
        func = function(client, itemName, fromID, toID) return string.format("Player '%s' failed to move item '%s' from inventory %s to %s.", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        category = "Items"
    },
    ["itemCombine"] = {
        func = function(client, itemName, targetName) return string.format("Player '%s' combined item '%s' with '%s'.", client:Name(), itemName, targetName) end,
        category = "Items"
    },
    ["itemFunction"] = {
        func = function(client, action, itemName) return string.format("Player '%s' called item function '%s' on '%s'.", client:Name(), action, itemName) end,
        category = "Items"
    },
    ["itemAdded"] = {
        func = function(client, itemName)
            local ownerName = IsValid(client) and client:Name() or L("unknown")
            return string.format("Item '%s' added to %s's inventory.", itemName, ownerName)
        end,
        category = "Items"
    },
    ["itemCreated"] = {
        func = function(_, itemName) return string.format("Item '%s' instance created.", itemName) end,
        category = "Items"
    },
    ["itemSpawned"] = {
        func = function(_, itemName) return string.format("Item '%s' spawned in the world.", itemName) end,
        category = "Items"
    },
    ["itemDraggedOut"] = {
        func = function(client, itemName) return string.format("Player '%s' dragged item '%s' out of an inventory.", client:Name(), itemName) end,
        category = "Items"
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("Player '%s' used toolgun: '%s'.", client:Name(), tool) end,
        category = "Tools"
    },
    ["permissionDenied"] = {
        func = function(client, action) return string.format("Player '%s' was denied permission to %s.", client:Name(), action) end,
        category = "Permissions"
    },
    ["spawnDenied"] = {
        func = function(client, objectType, model) return string.format("Player '%s' was denied from spawning %s '%s'.", client:Name(), objectType, tostring(model)) end,
        category = "Permissions"
    },
    ["toolDenied"] = {
        func = function(client, tool) return string.format("Player '%s' was denied tool '%s'.", client:Name(), tool) end,
        category = "Permissions"
    },
    ["observeToggle"] = {
        func = function(client, state) return string.format("Player '%s' toggled observe mode %s.", client:Name(), state) end,
        category = "Admin"
    },
    ["playerConnect"] = {
        func = function(_, name, ip) return string.format("Player '%s' is connecting from %s.", name, ip) end,
        category = "Connections",
    },
    ["playerConnected"] = {
        func = function(client) return string.format("Player finished loading: '%s'.", client:Name()) end,
        category = "Connections"
    },
    ["playerDisconnected"] = {
        func = function(client) return string.format("Player disconnected: '%s'.", client:Name()) end,
        category = "Connections"
    },
    ["failedPassword"] = {
        func = function(_, steamid64, name, svpass, clpass) return string.format("[%s] %s failed server password (Server: '%s', Client: '%s')", steamid64, name, svpass, clpass) end,
        category = "Connections"
    },
    ["exploitAttempt"] = {
        func = function(_, name, steamID, netMessage) return string.format("Player '%s' [%s] triggered exploit net message '%s'.", name, steamID, netMessage) end,
        category = "Connections"
    },
    ["steamIDMissing"] = {
        func = function(_, name, steamID) return string.format("SteamID missing for '%s' [%s] during CheckSeed.", name, steamID) end,
        category = "Connections"
    },
    ["steamIDMismatch"] = {
        func = function(_, name, realSteamID, sentSteamID) return string.format("SteamID mismatch for '%s': expected [%s] but got [%s].", name, realSteamID, sentSteamID) end,
        category = "Connections"
    },
    ["hackAttempt"] = {
        func = function(client) return string.format("Client %s triggered hack detection.", client:Name()) end,
        category = "Connections"
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return string.format("%s set door class to %s on door %s.", client:Name(), className, door:GetClass()) end,
        category = "World"
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return string.format("%s removed door class from door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["doorSaveData"] = {
        func = function(client) return string.format("%s saved door data on door %s.", client:Nick(), client:Name()) end,
        category = "World"
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return string.format("%s set door %s to %s.", client:Name(), door:GetClass(), state and "unownable" or "ownable") end,
        category = "World"
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return string.format("%s set door faction to %s on door %s.", client:Name(), factionName, door:GetClass()) end,
        category = "World"
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return string.format("%s removed door faction %s from door %s.", client:Name(), factionName, door:GetClass()) end,
        category = "World"
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return string.format("%s set door %s to %s.", client:Name(), door:GetClass(), state and "hidden" or "visible") end,
        category = "World"
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return string.format("%s set door title to '%s' on door %s.", client:Name(), title, door:GetClass()) end,
        category = "World"
    },
    ["doorResetData"] = {
        func = function(client, door) return string.format("%s reset door data on door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["doorSetParent"] = {
        func = function(client, door) return string.format("%s set door parent for door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["doorAddChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("%s added child door %s to parent door %s.", client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "World"
    },
    ["doorRemoveChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("%s removed child door %s from parent door %s.", client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "World"
    },
    ["doorDisable"] = {
        func = function(client, door) return string.format("%s disabled door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["doorEnable"] = {
        func = function(client, door) return string.format("%s enabled door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["doorDisableAll"] = {
        func = function(client, count) return string.format("%s disabled all doors (%d total).", client:Name(), count) end,
        category = "World"
    },
    ["doorEnableAll"] = {
        func = function(client, count) return string.format("%s enabled all doors (%d total).", client:Name(), count) end,
        category = "World"
    },
    ["lockDoor"] = {
        func = function(client, door) return string.format("%s forcibly locked door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["unlockDoor"] = {
        func = function(client, door) return string.format("%s forcibly unlocked door %s.", client:Name(), door:GetClass()) end,
        category = "World"
    },
    ["toggleLock"] = {
        func = function(client, door, state) return string.format("%s toggled door %s to %s.", client:Name(), door:GetClass(), state) end,
        category = "World"
    },
    ["doorsell"] = {
        func = function(client, price) return string.format("Player '%s' sold a door for %s.", client:Name(), lia.currency.get(price)) end,
        category = "World"
    },
    ["admindoorsell"] = {
        func = function(client, ownerName, price) return string.format("Admin '%s' sold a door for '%s' and refunded %s.", client:Name(), ownerName, lia.currency.get(price)) end,
        category = "World"
    },
    ["buydoor"] = {
        func = function(client, price) return string.format("Player '%s' purchased a door for %s.", client:Name(), lia.currency.get(price)) end,
        category = "World"
    },
    ["doorSetPrice"] = {
        func = function(client, door, price) return string.format("%s set door price to %s on door %s.", client:Name(), lia.currency.get(price), door:GetClass()) end,
        category = "World"
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return string.format("Player '%s' spawned an item: '%s' %s.", client:Name(), displayName, message) end,
        category = "Items"
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return string.format("Player '%s' gave item '%s' to %s. Info: %s", client:Name(), itemName, target:Name(), message) end,
        category = "Items"
    },
    ["vendorAccess"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s accessed vendor %s", client:Name(), vendorName)
        end,
        category = "Items"
    },
    ["vendorExit"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s exited vendor %s", client:Name(), vendorName)
        end,
        category = "Items"
    },
    ["vendorSell"] = {
        func = function(client, item, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s sold a %s to %s", client:Name(), item, vendorName)
        end,
        category = "Items"
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s edited vendor %s with key %s", client:Name(), vendorName, key)
        end,
        category = "Items"
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor, isFailed)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            if isFailed then
                return string.format("%s tried to buy a %s from %s but it failed. They likely had no space!", client:Name(), item, vendorName)
            else
                return string.format("%s bought a %s from %s", client:Name(), item, vendorName)
            end
        end,
        category = "Items"
    },
    ["restockvendor"] = {
        func = function(client, vendor)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s restocked vendor %s", client:Name(), vendorName)
        end,
        category = "Items"
    },
    ["restockallvendors"] = {
        func = function(client, count) return string.format("%s restocked all vendors (%d total)", client:Name(), count) end,
        category = "Items"
    },
    ["resetvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s set vendor %s money to %s", client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Items"
    },
    ["resetallvendormoney"] = {
        func = function(client, amount, count) return string.format("%s reset all vendors money to %s (%d affected)", client:Name(), lia.currency.get(amount), count) end,
        category = "Items"
    },
    ["restockvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s restocked vendor %s money to %s", client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Items"
    },
    ["savevendors"] = {
        func = function(client) return string.format("%s saved all vendor data", client:Name()) end,
        category = "Items"
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return string.format("Configuration changed: '%s' from '%s' to '%s'.", name, tostring(oldValue), tostring(value)) end,
        category = "Admin"
    },
    ["warningIssued"] = {
        func = function(client, target, reason, count, index) return string.format("Warning issued at %s by admin '%s' to player '%s' for: '%s'. Total warnings: %d (added #%d).", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), reason, count or 0, index or count or 0) end,
        category = "Admin"
    },
    ["warningRemoved"] = {
        func = function(client, target, warning, count, index) return string.format("Warning removed at %s by admin '%s' for player '%s'. Reason: '%s'. Remaining warnings: %d (removed #%d).", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), warning.reason, count or 0, index or 0) end,
        category = "Admin"
    },
    ["viewWarns"] = {
        func = function(client, target) return string.format("Admin '%s' viewed warnings for player '%s'.", client:Name(), IsValid(target) and target:Name() or tostring(target)) end,
        category = "Admin"
    },
    ["adminMode"] = {
        func = function(client, id, message) return string.format("Admin Mode toggled at %s by '%s': %s. (ID: %s)", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, id) end,
        category = "Admin"
    },
    ["charsetmodel"] = {
        func = function(client, targetName, newModel, oldModel) return string.format("Admin '%s' changed %s's model from %s to %s", client:Name(), targetName, oldModel, newModel) end,
        category = "Admin"
    },
    ["forceSay"] = {
        func = function(client, targetName, message) return string.format("Admin '%s' forced %s to say: %s", client:Name(), targetName, message) end,
        category = "Admin"
    },
    ["plyTransfer"] = {
        func = function(client, targetName, oldFaction, newFaction) return string.format("Admin '%s' transferred '%s' from faction '%s' to '%s'.", client:Name(), targetName, oldFaction, newFaction) end,
        category = "Factions"
    },
    ["plyWhitelist"] = {
        func = function(client, targetName, faction) return string.format("Admin '%s' whitelisted '%s' for faction '%s'.", client:Name(), targetName, faction) end,
        category = "Factions"
    },
    ["plyUnwhitelist"] = {
        func = function(client, targetName, faction) return string.format("Admin '%s' removed '%s' from faction '%s' whitelist.", client:Name(), targetName, faction) end,
        category = "Factions"
    },
    ["beClass"] = {
        func = function(client, className) return string.format("Player '%s' joined class '%s'.", client:Name(), className) end,
        category = "Factions"
    },
    ["setClass"] = {
        func = function(client, targetName, className) return string.format("Admin '%s' set '%s' to class '%s'.", client:Name(), targetName, className) end,
        category = "Factions"
    },
    ["classWhitelist"] = {
        func = function(client, targetName, className) return string.format("Admin '%s' whitelisted '%s' for class '%s'.", client:Name(), targetName, className) end,
        category = "Factions"
    },
    ["classUnwhitelist"] = {
        func = function(client, targetName, className) return string.format("Admin '%s' removed '%s' from class '%s' whitelist.", client:Name(), targetName, className) end,
        category = "Factions"
    },
    ["flagGive"] = {
        func = function(client, targetName, flags) return string.format("Admin '%s' gave flags '%s' to %s.", client:Name(), flags, targetName) end,
        category = "Admin"
    },
    ["flagGiveAll"] = {
        func = function(client, targetName) return string.format("Admin '%s' gave all flags to %s.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["flagTake"] = {
        func = function(client, targetName, flags) return string.format("Admin '%s' took flags '%s' from %s.", client:Name(), flags, targetName) end,
        category = "Admin"
    },
    ["flagTakeAll"] = {
        func = function(client, targetName) return string.format("Admin '%s' removed all flags from %s.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["voiceToggle"] = {
        func = function(client, targetName, state) return string.format("Admin '%s' toggled voice ban for %s: %s.", client:Name(), targetName, state) end,
        category = "Admin"
    },
    ["charBan"] = {
        func = function(client, targetName) return string.format("Admin '%s' banned character '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["charUnban"] = {
        func = function(client, targetName) return string.format("Admin '%s' unbanned character '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["charKick"] = {
        func = function(client, targetName) return string.format("Admin '%s' kicked character '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message) return string.format("Sit room set at %s by '%s': %s. Position: %s", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, pos) end,
        category = "Admin"
    },
    ["sitRoomRenamed"] = {
        func = function(client, details) return string.format("%s renamed a SitRoom: %s", client:Name(), details) end,
        category = "Admin"
    },
    ["sitRoomRepositioned"] = {
        func = function(client, details) return string.format("%s repositioned a SitRoom: %s", client:Name(), details) end,
        category = "Admin"
    },
    ["sendToSitRoom"] = {
        func = function(client, targetName, roomName)
            if targetName == client:Name() then return string.format("Player '%s' teleported to SitRoom '%s'.", client:Name(), roomName) end
            return string.format("Player '%s' sent '%s' to SitRoom '%s'.", client:Name(), targetName, roomName)
        end,
        category = "Admin"
    },
    ["sitRoomReturn"] = {
        func = function(client, targetName)
            if targetName == client:Name() then return string.format("Player '%s' returned from a SitRoom.", client:Name()) end
            return string.format("Player '%s' returned '%s' from a SitRoom.", client:Name(), targetName)
        end,
        category = "Admin"
    },
    ["attribSet"] = {
        func = function(client, targetName, attrib, value) return string.format("Admin '%s' set %s's '%s' attribute to %d.", client:Name(), targetName, attrib, value) end,
        category = "Character"
    },
    ["attribAdd"] = {
        func = function(client, targetName, attrib, value) return string.format("Admin '%s' added %d to %s's '%s' attribute.", client:Name(), value, targetName, attrib) end,
        category = "Character"
    },
    ["attribCheck"] = {
        func = function(client, targetName) return string.format("Admin '%s' viewed attributes of %s.", client:Name(), targetName) end,
        category = "Character"
    },
    ["invUpdateSize"] = {
        func = function(client, targetName, w, h) return string.format("Admin '%s' reset %s's inventory size to %dx%d.", client:Name(), targetName, w, h) end,
        category = "Inventory"
    },
    ["invSetSize"] = {
        func = function(client, targetName, w, h) return string.format("Admin '%s' set %s's inventory size to %dx%d.", client:Name(), targetName, w, h) end,
        category = "Inventory"
    },
    ["storageLock"] = {
        func = function(client, entClass, state) return string.format("Admin '%s' %s storage %s.", client:Name(), state and "locked" or "unlocked", entClass) end,
        category = "Inventory"
    },
    ["storageUnlock"] = {
        func = function(client, entClass) return string.format("Client %s unlocked storage %s.", client:Name(), entClass) end,
        category = "Inventory"
    },
    ["storageUnlockFailed"] = {
        func = function(client, entClass, password) return string.format("Client %s failed to unlock storage %s with password '%s'.", client:Name(), entClass, password) end,
        category = "Inventory"
    },
    ["spawnAdd"] = {
        func = function(client, faction) return string.format("Admin '%s' added a spawn for faction '%s'.", client:Name(), faction) end,
        category = "World"
    },
    ["spawnRemoveRadius"] = {
        func = function(client, radius, count) return string.format("Admin '%s' removed %d spawns within %d units.", client:Name(), count, radius) end,
        category = "World"
    },
    ["spawnRemoveByName"] = {
        func = function(client, faction, count) return string.format("Admin '%s' removed %d spawns for faction '%s'.", client:Name(), count, faction) end,
        category = "World"
    },
    ["returnItems"] = {
        func = function(client, targetName) return string.format("Admin '%s' returned lost items to %s.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["banOOC"] = {
        func = function(client, targetName, steamID) return string.format("Admin '%s' banned %s (%s) from OOC chat.", client:Name(), targetName, steamID) end,
        category = "Admin"
    },
    ["unbanOOC"] = {
        func = function(client, targetName, steamID) return string.format("Admin '%s' unbanned %s (%s) from OOC chat.", client:Name(), targetName, steamID) end,
        category = "Admin"
    },
    ["blockOOC"] = {
        func = function(client, state) return string.format("Admin '%s' %s OOC chat globally.", client:Name(), state and "blocked" or "unblocked") end,
        category = "Admin"
    },
    ["clearChat"] = {
        func = function(client) return string.format("Admin '%s' cleared the chat.", client:Name()) end,
        category = "Admin"
    },
    ["cheaterBanned"] = {
        func = function(_, name, steamID) return string.format("Cheater '%s' (%s) was automatically banned.", name, steamID) end,
        category = "Admin"
    },
    ["altKicked"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' (%s) was kicked.", name, steamID) end,
        category = "Admin"
    },
    ["altBanned"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' (%s) was banned due to blacklist.", name, steamID) end,
        category = "Admin"
    },
    ["plyKick"] = {
        func = function(client, targetName) return string.format("Admin '%s' kicked player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyBan"] = {
        func = function(client, targetName) return string.format("Admin '%s' banned player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUnban"] = {
        func = function(client, targetIdentifier) return string.format("Admin '%s' unbanned player '%s'.", client:Name(), targetIdentifier) end,
        category = "Admin"
    },
    ["viewPlayerClaims"] = {
        func = function(client, targetName) return string.format("Admin '%s' viewed claims for %s.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["viewAllClaims"] = {
        func = function(client) return string.format("Admin '%s' viewed all ticket claims.", client:Name()) end,
        category = "Admin"
    },
    ["ticketClaimed"] = {
        func = function(client, requester, count) return string.format("Admin '%s' claimed a ticket for %s. Total claims: %d.", client:Name(), requester, count or 0) end,
        category = "Admin"
    },
    ["ticketClosed"] = {
        func = function(client, requester, count) return string.format("Admin '%s' closed a ticket for %s. Total claims: %d.", client:Name(), requester, count or 0) end,
        category = "Admin"
    },
    ["teleportToEntity"] = {
        func = function(client, entClass) return string.format("Admin '%s' teleported to entity '%s'.", client:Name(), entClass) end,
        category = "Admin"
    },
    ["plyBring"] = {
        func = function(client, targetName) return string.format("Admin '%s' brought player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyGoto"] = {
        func = function(client, targetName) return string.format("Admin '%s' teleported to player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyReturn"] = {
        func = function(client, targetName) return string.format("Admin '%s' returned player '%s' to their previous position.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyJail"] = {
        func = function(client, targetName) return string.format("Admin '%s' jailed player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUnjail"] = {
        func = function(client, targetName) return string.format("Admin '%s' unjailed player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyKill"] = {
        func = function(client, targetName) return string.format("Admin '%s' killed player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plySlay"] = {
        func = function(client, targetName) return string.format("Admin '%s' slayed player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyRespawn"] = {
        func = function(client, targetName) return string.format("Admin '%s' respawned player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyFreeze"] = {
        func = function(client, targetName, duration) return string.format("Admin '%s' froze player '%s' for %s seconds.", client:Name(), targetName, tostring(duration)) end,
        category = "Admin"
    },
    ["plyUnfreeze"] = {
        func = function(client, targetName) return string.format("Admin '%s' unfroze player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plySetGroup"] = {
        func = function(client, targetName, group) return string.format("Admin '%s' set %s's group to '%s'.", client:Name(), targetName, group) end,
        category = "Admin"
    },
    ["plyBlind"] = {
        func = function(client, targetName, duration) return string.format("Admin '%s' blinded player '%s' for %s seconds.", client:Name(), targetName, tostring(duration)) end,
        category = "Admin"
    },
    ["plyUnblind"] = {
        func = function(client, targetName) return string.format("Admin '%s' unblinded player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyBlindFade"] = {
        func = function(client, targetName, duration, color) return string.format("Admin '%s' blind-faded player '%s' for %s seconds with color '%s'.", client:Name(), targetName, tostring(duration), color) end,
        category = "Admin"
    },
    ["blindFadeAll"] = {
        func = function(_, duration, color) return string.format("All players blind-faded for %s seconds with color '%s'.", tostring(duration), color) end,
        category = "Admin"
    },
    ["plyGag"] = {
        func = function(client, targetName) return string.format("Admin '%s' gagged player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUngag"] = {
        func = function(client, targetName) return string.format("Admin '%s' ungagged player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyMute"] = {
        func = function(client, targetName) return string.format("Admin '%s' muted player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUnmute"] = {
        func = function(client, targetName) return string.format("Admin '%s' unmuted player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyCloak"] = {
        func = function(client, targetName) return string.format("Admin '%s' cloaked player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUncloak"] = {
        func = function(client, targetName) return string.format("Admin '%s' uncloaked player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyGod"] = {
        func = function(client, targetName) return string.format("Admin '%s' enabled god mode for '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyUngod"] = {
        func = function(client, targetName) return string.format("Admin '%s' disabled god mode for '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyIgnite"] = {
        func = function(client, targetName, duration) return string.format("Admin '%s' ignited player '%s' for %s seconds.", client:Name(), targetName, tostring(duration)) end,
        category = "Admin"
    },
    ["plyExtinguish"] = {
        func = function(client, targetName) return string.format("Admin '%s' extinguished player '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["plyStrip"] = {
        func = function(client, targetName) return string.format("Admin '%s' stripped weapons from '%s'.", client:Name(), targetName) end,
        category = "Admin"
    },
    ["charBanOffline"] = {
        func = function(client, charID) return string.format("Admin '%s' banned offline character ID %s.", client:Name(), tostring(charID)) end,
        category = "Admin"
    },
    ["charUnbanOffline"] = {
        func = function(client, charID) return string.format("Admin '%s' unbanned offline character ID %s.", client:Name(), tostring(charID)) end,
        category = "Admin"
    },
}
