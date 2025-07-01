lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name) return string.format("Player [%s] '%s' recognized character with ID %s and name '%s'. (Active CharID: %s)", client:SteamID64(), client:Name(), id, name, client:getChar():getID()) end,
        category = "Recognition"
    },
    ["charCreate"] = {
        func = function(client, character) return string.format("Player [%s] '%s' created a new character named '%s' (CharID: %s).", client:SteamID64(), client:Name(), character:getName(), character:getID()) end,
        category = "Character"
    },
    ["charLoad"] = {
        func = function(client, name) return string.format("Player [%s] '%s' loaded character '%s' (CharID: %s).", client:SteamID64(), client:Name(), name, client:getChar():getID()) end,
        category = "Character"
    },
    ["charDelete"] = {
        func = function(client, id) return string.format("Player [%s] '%s' has deleted character ID %s. (Active CharID: %s)", IsValid(client) and client:SteamID64() or "CONSOLE", IsValid(client) and client:Name() or "CONSOLE", id, IsValid(client) and client:getChar():getID() or "Unknown") end,
        category = "Character"
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("Player [%s] '%s' took %s damage from '%s'. Current Health: %s (CharID: %s)", client:SteamID64(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = "Damage"
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("Player [%s] '%s' was killed by '%s'. (CharID: %s)", client:SteamID64(), client:Name(), attacker, client:getChar():getID()) end,
        category = "Death"
    },
    ["playerSpawn"] = {
        func = function(client)
            local char = client:getChar()
            return string.format("Player [%s] '%s' spawned. (CharID: %s)", client:SteamID64(), client:Name(), char and char:getID() or "N/A")
        end,
        category = "Character"
    },
    ["spawned_prop"] = {
        func = function(client, model) return string.format("Player [%s] '%s' spawned prop: %s. (CharID: %s)", client:SteamID64(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn"
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("Player [%s] '%s' spawned ragdoll: %s. (CharID: %s)", client:SteamID64(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn"
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("Player [%s] '%s' spawned effect: %s. (CharID: %s)", client:SteamID64(), client:Name(), effect, client:getChar():getID()) end,
        category = "Spawn"
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return string.format("Player [%s] '%s' spawned vehicle '%s' with model '%s'. (CharID: %s)", client:SteamID64(), client:Name(), vehicle, model, client:getChar():getID()) end,
        category = "Spawn"
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return string.format("Player [%s] '%s' spawned NPC '%s' with model '%s'. (CharID: %s)", client:SteamID64(), client:Name(), npc, model, client:getChar():getID()) end,
        category = "Spawn"
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("Player [%s] '%s' spawned SWEP '%s'. (CharID: %s)", client:SteamID64(), client:Name(), swep, client:getChar():getID()) end,
        category = "SWEP"
    },
    ["chat"] = {
        func = function(client, chatType, message) return string.format("[%s] (Chat Type: %s) %s said: '%s' (CharID: %s)", client:SteamID64(), chatType, client:Name(), message, client:getChar():getID()) end,
        category = "Chat"
    },
    ["chatOOC"] = {
        func = function(client, msg) return string.format("Player [%s] '%s' said (OOC): '%s'. (CharID: %s)", client:SteamID64(), client:Name(), msg, client:getChar():getID()) end,
        category = "Chat"
    },
    ["chatLOOC"] = {
        func = function(client, msg) return string.format("Player [%s] '%s' said (LOOC): '%s'. (CharID: %s)", client:SteamID64(), client:Name(), msg, client:getChar():getID()) end,
        category = "Chat"
    },
    ["command"] = {
        func = function(client, text) return string.format("Player [%s] '%s' ran command: %s. (CharID: %s)", client:SteamID64(), client:Name(), text, client:getChar():getID()) end,
        category = "Chat"
    },
    ["money"] = {
        func = function(client, amount) return string.format("Player [%s] '%s' changed money by: %s. (CharID: %s)", client:SteamID64(), client:Name(), amount, client:getChar():getID()) end,
        category = "Money"
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return string.format("Player [%s] '%s' picked up %s %s. (CharID: %s)", client:SteamID64(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = "Money"
    },
    ["charSetMoney"] = {
        func = function(client, targetName, amount) return string.format("Admin [%s] '%s' set %s's money to %s.", client:SteamID64(), client:Name(), targetName, lia.currency.get(amount)) end,
        category = "Money"
    },
    ["charAddMoney"] = {
        func = function(client, targetName, amount, total) return string.format("Admin [%s] '%s' gave %s %s (New Total: %s).", client:SteamID64(), client:Name(), targetName, lia.currency.get(amount), lia.currency.get(total)) end,
        category = "Money"
    },
    ["itemTake"] = {
        func = function(client, item) return string.format("Player [%s] '%s' took item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = "Items"
    },
    ["use"] = {
        func = function(client, item) return string.format("Player [%s] '%s' used item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = "Items"
    },
    ["itemDrop"] = {
        func = function(client, item) return string.format("Player [%s] '%s' dropped item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = "Items"
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("Player [%s] '%s' %s item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), action, item.name, client:getChar():getID()) end,
        category = "Items"
    },
    ["itemEquip"] = {
        func = function(client, item) return string.format("Player [%s] '%s' equipped item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = "Items"
    },
    ["itemUnequip"] = {
        func = function(client, item) return string.format("Player [%s] '%s' unequipped item '%s'. (CharID: %s)", client:SteamID64(), client:Name(), item, client:getChar():getID()) end,
        category = "Items"
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("Player [%s] '%s' used toolgun: '%s'. (CharID: %s)", client:SteamID64(), client:Name(), tool, client:getChar():getID()) end,
        category = "Toolgun"
    },
    ["observeToggle"] = {
        func = function(client, state)
            local char = client:getChar()
            return string.format("Player [%s] '%s' toggled observe mode %s. (CharID: %s)", client:SteamID64(), client:Name(), state, char and char:getID() or "N/A")
        end,
        category = "Admin Actions"
    },
    ["playerConnected"] = {
        func = function(client) return string.format("Player connected: [%s] '%s'.", client:SteamID64(), client:Name()) end,
        category = "Connections"
    },
    ["playerDisconnected"] = {
        func = function(client) return string.format("Player disconnected: [%s] '%s'.", client:SteamID64(), client:Name()) end,
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
        func = function(client) return string.format("Client [%s] %s triggered hack detection.", client:SteamID64(), client:Name()) end,
        category = "Connections"
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return string.format("Client [%s] %s set door class to %s on door %s.", client:SteamID64(), client:Name(), className, door:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return string.format("Client [%s] %s removed door class from door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorSaveData"] = {
        func = function(client) return string.format("Client [%s] %s saved door data on door %s.", client:Nick(), client:SteamID64(), client:Name()) end,
        category = "Doors"
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return string.format("Client [%s] %s set door %s to %s.", client:SteamID64(), client:Name(), door:GetClass(), state and "unownable" or "ownable") end,
        category = "Doors"
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return string.format("Client [%s] %s set door faction to %s on door %s.", client:SteamID64(), client:Name(), factionName, door:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return string.format("Client [%s] %s removed door faction %s from door %s.", client:SteamID64(), client:Name(), factionName, door:GetClass()) end,
        category = "Doors"
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return string.format("Client [%s] %s set door %s to %s.", client:SteamID64(), client:Name(), door:GetClass(), state and "hidden" or "visible") end,
        category = "Doors"
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return string.format("Client [%s] %s set door title to '%s' on door %s.", client:SteamID64(), client:Name(), title, door:GetClass()) end,
        category = "Doors"
    },
    ["doorResetData"] = {
        func = function(client, door) return string.format("Client [%s] %s reset door data on door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorSetParent"] = {
        func = function(client, door) return string.format("Client [%s] %s set door parent for door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorAddChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("Client [%s] %s added child door %s to parent door %s.", client:SteamID64(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("Client [%s] %s removed child door %s from parent door %s.", client:SteamID64(), client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "Doors"
    },
    ["doorDisable"] = {
        func = function(client, door) return string.format("Client [%s] %s disabled door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorEnable"] = {
        func = function(client, door) return string.format("Client [%s] %s enabled door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorDisableAll"] = {
        func = function(client, count) return string.format("Client [%s] %s disabled all doors (%d total).", client:SteamID64(), client:Name(), count) end,
        category = "Doors"
    },
    ["doorEnableAll"] = {
        func = function(client, count) return string.format("Client [%s] %s enabled all doors (%d total).", client:SteamID64(), client:Name(), count) end,
        category = "Doors"
    },
    ["lockDoor"] = {
        func = function(client, door) return string.format("Client [%s] %s forcibly locked door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["unlockDoor"] = {
        func = function(client, door) return string.format("Client [%s] %s forcibly unlocked door %s.", client:SteamID64(), client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["toggleLock"] = {
        func = function(client, door, state) return string.format("Client [%s] %s toggled door %s to %s.", client:SteamID64(), client:Name(), door:GetClass(), state) end,
        category = "Doors"
    },
    ["doorsell"] = {
        func = function(client, price) return string.format("Player [%s] '%s' sold a door for %s.", client:SteamID64(), client:Name(), lia.currency.get(price)) end,
        category = "Doors"
    },
    ["admindoorsell"] = {
        func = function(client, ownerName, price) return string.format("Admin [%s] '%s' sold a door for '%s' and refunded %s.", client:SteamID64(), client:Name(), ownerName, lia.currency.get(price)) end,
        category = "Doors"
    },
    ["buydoor"] = {
        func = function(client, price) return string.format("Player [%s] '%s' purchased a door for %s.", client:SteamID64(), client:Name(), lia.currency.get(price)) end,
        category = "Doors"
    },
    ["doorSetPrice"] = {
        func = function(client, door, price) return string.format("Client [%s] %s set door price to %s on door %s.", client:SteamID64(), client:Name(), lia.currency.get(price), door:GetClass()) end,
        category = "Doors"
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return string.format("Player [%s] spawned an item: '%s' %s.", client:SteamID64(), displayName, message) end,
        category = "Item Spawner"
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return string.format("Player [%s] gave item '%s' to %s. Info: %s", client:SteamID64(), itemName, target:Name(), message) end,
        category = "Item Spawner"
    },
    ["vendorAccess"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return string.format("[%s] %s accessed vendor %s [CharID: %s]", client:SteamID64(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = "Vendors"
    },
    ["vendorExit"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return string.format("[%s] %s exited vendor %s [CharID: %s]", client:SteamID64(), client:Name(), vendorName, client:getChar():getID())
        end,
        category = "Vendors"
    },
    ["vendorSell"] = {
        func = function(client, item, vendor)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return string.format("[%s] %s sold a %s to %s [CharID: %s]", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
        end,
        category = "Vendors"
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            return string.format("[%s] %s edited vendor %s with key %s [CharID: %s]", client:SteamID64(), client:Name(), vendorName, key, client:getChar():getID())
        end,
        category = "Vendors"
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor, isFailed)
            local vendorName = vendor:getNetVar("name") or "Unknown"
            if isFailed then
                return string.format("[%s] %s tried to buy a %s from %s but it failed. They likely had no space! [CharID: %s]", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
            else
                return string.format("[%s] %s bought a %s from %s [CharID: %s]", client:SteamID64(), client:Name(), item, vendorName, client:getChar():getID())
            end
        end,
        category = "Vendors"
    },
    ["restockvendor"] = {
        func = function(client, vendor)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or "Unknown") or "Unknown"
            return string.format("[%s] %s restocked vendor %s", client:SteamID64(), client:Name(), vendorName)
        end,
        category = "Vendors"
    },
    ["restockallvendors"] = {
        func = function(client, count) return string.format("[%s] %s restocked all vendors (%d total)", client:SteamID64(), client:Name(), count) end,
        category = "Vendors"
    },
    ["resetvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or "Unknown") or "Unknown"
            return string.format("[%s] %s set vendor %s money to %s", client:SteamID64(), client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Vendors"
    },
    ["resetallvendormoney"] = {
        func = function(client, amount, count) return string.format("[%s] %s reset all vendors money to %s (%d affected)", client:SteamID64(), client:Name(), lia.currency.get(amount), count) end,
        category = "Vendors"
    },
    ["restockvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or "Unknown") or "Unknown"
            return string.format("[%s] %s restocked vendor %s money to %s", client:SteamID64(), client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Vendors"
    },
    ["savevendors"] = {
        func = function(client) return string.format("[%s] %s saved all vendor data", client:SteamID64(), client:Name()) end,
        category = "Vendors"
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return string.format("Configuration changed: '%s' from '%s' to '%s'.", name, tostring(oldValue), tostring(value)) end,
        category = "Admin Actions"
    },
    ["warningIssued"] = {
        func = function(client, target, reason, count, index)
            local char = IsValid(target) and target:getChar()
            return string.format(
                "Warning issued at %s by admin [%s] '%s' to player [%s] '%s' for: '%s'. Total warnings: %d (added #%d). (CharID: %s)",
                os.date("%Y-%m-%d %H:%M:%S"),
                client:SteamID64(),
                client:Name(),
                IsValid(target) and target:SteamID64() or "N/A",
                IsValid(target) and target:Name() or "N/A",
                reason,
                count or 0,
                index or count or 0,
                char and char:getID() or "N/A"
            )
        end,
        category = "Warnings"
    },
    ["warningRemoved"] = {
        func = function(client, target, warning, count, index)
            local char = IsValid(target) and target:getChar()
            return string.format(
                "Warning removed at %s by admin [%s] '%s' for player [%s] '%s'. Reason: '%s'. Remaining warnings: %d (removed #%d). (CharID: %s)",
                os.date("%Y-%m-%d %H:%M:%S"),
                client:SteamID64(),
                client:Name(),
                IsValid(target) and target:SteamID64() or "N/A",
                IsValid(target) and target:Name() or "N/A",
                warning.reason,
                count or 0,
                index or 0,
                char and char:getID() or "N/A"
            )
        end,
        category = "Warnings"
    },
    ["viewWarns"] = {
        func = function(client, target)
            local char = IsValid(target) and target:getChar()
            return string.format(
                "Admin [%s] '%s' viewed warnings for player [%s] '%s'. (CharID: %s)",
                client:SteamID64(),
                client:Name(),
                IsValid(target) and target:SteamID64() or "N/A",
                IsValid(target) and target:Name() or tostring(target),
                char and char:getID() or "N/A"
            )
        end,
        category = "Warnings"
    },
    ["adminMode"] = {
        func = function(client, id, message) return string.format("Admin Mode toggled at %s by admin [%s]: %s. (ID: %s)", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), message, id) end,
        category = "Admin Actions"
    },
    ["charsetmodel"] = {
        func = function(client, targetName, newModel, oldModel) return string.format("Admin [%s] '%s' changed %s's model from %s to %s", client:SteamID64(), client:Name(), targetName, oldModel, newModel) end,
        category = "Admin Actions"
    },
    ["forceSay"] = {
        func = function(client, targetName, message) return string.format("Admin [%s] '%s' forced %s to say: %s", client:SteamID64(), client:Name(), targetName, message) end,
        category = "Admin Actions"
    },
    ["plyTransfer"] = {
        func = function(client, targetName, oldFaction, newFaction) return string.format("Admin [%s] '%s' transferred '%s' from faction '%s' to '%s'.", client:SteamID64(), client:Name(), targetName, oldFaction, newFaction) end,
        category = "Factions"
    },
    ["plyWhitelist"] = {
        func = function(client, targetName, faction) return string.format("Admin [%s] '%s' whitelisted '%s' for faction '%s'.", client:SteamID64(), client:Name(), targetName, faction) end,
        category = "Factions"
    },
    ["plyUnwhitelist"] = {
        func = function(client, targetName, faction) return string.format("Admin [%s] '%s' removed '%s' from faction '%s' whitelist.", client:SteamID64(), client:Name(), targetName, faction) end,
        category = "Factions"
    },
    ["beClass"] = {
        func = function(client, className) return string.format("Player [%s] '%s' joined class '%s'. (CharID: %s)", client:SteamID64(), client:Name(), className, client:getChar():getID()) end,
        category = "Classes"
    },
    ["setClass"] = {
        func = function(client, targetName, className) return string.format("Admin [%s] '%s' set '%s' to class '%s'.", client:SteamID64(), client:Name(), targetName, className) end,
        category = "Classes"
    },
    ["classWhitelist"] = {
        func = function(client, targetName, className) return string.format("Admin [%s] '%s' whitelisted '%s' for class '%s'.", client:SteamID64(), client:Name(), targetName, className) end,
        category = "Classes"
    },
    ["classUnwhitelist"] = {
        func = function(client, targetName, className) return string.format("Admin [%s] '%s' removed '%s' from class '%s' whitelist.", client:SteamID64(), client:Name(), targetName, className) end,
        category = "Classes"
    },
    ["flagGive"] = {
        func = function(client, targetName, flags) return string.format("Admin [%s] '%s' gave flags '%s' to %s.", client:SteamID64(), client:Name(), flags, targetName) end,
        category = "Flags"
    },
    ["flagGiveAll"] = {
        func = function(client, targetName) return string.format("Admin [%s] '%s' gave all flags to %s.", client:SteamID64(), client:Name(), targetName) end,
        category = "Flags"
    },
    ["flagTake"] = {
        func = function(client, targetName, flags) return string.format("Admin [%s] '%s' took flags '%s' from %s.", client:SteamID64(), client:Name(), flags, targetName) end,
        category = "Flags"
    },
    ["flagTakeAll"] = {
        func = function(client, targetName) return string.format("Admin [%s] '%s' removed all flags from %s.", client:SteamID64(), client:Name(), targetName) end,
        category = "Flags"
    },
    ["voiceToggle"] = {
        func = function(client, targetName, state) return string.format("Admin [%s] '%s' toggled voice ban for %s: %s.", client:SteamID64(), client:Name(), targetName, state) end,
        category = "Admin Actions"
    },
    ["charBan"] = {
        func = function(client, targetName, charID) return string.format("Admin [%s] '%s' banned character '%s'. (CharID: %s)", client:SteamID64(), client:Name(), targetName, charID or "N/A") end,
        category = "Admin Actions"
    },
    ["charUnban"] = {
        func = function(client, targetName, charID) return string.format("Admin [%s] '%s' unbanned character '%s'. (CharID: %s)", client:SteamID64(), client:Name(), targetName, charID or "N/A") end,
        category = "Admin Actions"
    },
    ["charKick"] = {
        func = function(client, targetName, charID) return string.format("Admin [%s] '%s' kicked character '%s'. (CharID: %s)", client:SteamID64(), client:Name(), targetName, charID or "N/A") end,
        category = "Admin Actions"
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message) return string.format("Sit room set at %s by admin [%s]: %s. Position: %s", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID64(), message, pos) end,
        category = "Sit Rooms"
    },
    ["sitRoomRenamed"] = {
        func = function(client, details) return string.format("[%s] %s renamed a SitRoom: %s", client:SteamID64(), client:Name(), details) end,
        category = "Sit Rooms"
    },
    ["sitRoomRepositioned"] = {
        func = function(client, details) return string.format("[%s] %s repositioned a SitRoom: %s", client:SteamID64(), client:Name(), details) end,
        category = "Sit Rooms"
    },
    ["sendToSitRoom"] = {
        func = function(client, targetName, roomName)
            if targetName == client:Name() then return string.format("Player [%s] '%s' teleported to SitRoom '%s'.", client:SteamID64(), client:Name(), roomName) end
            return string.format("Player [%s] '%s' sent '%s' to SitRoom '%s'.", client:SteamID64(), client:Name(), targetName, roomName)
        end,
        category = "Sit Rooms"
    },
    ["sitRoomReturn"] = {
        func = function(client, targetName)
            if targetName == client:Name() then return string.format("Player [%s] '%s' returned from a SitRoom.", client:SteamID64(), client:Name()) end
            return string.format("Player [%s] '%s' returned '%s' from a SitRoom.", client:SteamID64(), client:Name(), targetName)
        end,
        category = "Sit Rooms"
    },
    ["attribSet"] = {
        func = function(client, targetName, attrib, value) return string.format("Admin [%s] '%s' set %s's '%s' attribute to %d.", client:SteamID64(), client:Name(), targetName, attrib, value) end,
        category = "Attributes"
    },
    ["attribAdd"] = {
        func = function(client, targetName, attrib, value) return string.format("Admin [%s] '%s' added %d to %s's '%s' attribute.", client:SteamID64(), client:Name(), value, targetName, attrib) end,
        category = "Attributes"
    },
    ["attribCheck"] = {
        func = function(client, targetName) return string.format("Admin [%s] '%s' viewed attributes of %s.", client:SteamID64(), client:Name(), targetName) end,
        category = "Attributes"
    },
    ["invUpdateSize"] = {
        func = function(client, targetName, w, h) return string.format("Admin [%s] '%s' reset %s's inventory size to %dx%d.", client:SteamID64(), client:Name(), targetName, w, h) end,
        category = "Inventory"
    },
    ["invSetSize"] = {
        func = function(client, targetName, w, h) return string.format("Admin [%s] '%s' set %s's inventory size to %dx%d.", client:SteamID64(), client:Name(), targetName, w, h) end,
        category = "Inventory"
    },
    ["storageLock"] = {
        func = function(client, entClass, state) return string.format("Admin [%s] '%s' %s storage %s.", client:SteamID64(), client:Name(), state and "locked" or "unlocked", entClass) end,
        category = "Storage"
    },
    ["storageUnlock"] = {
        func = function(client, entClass) return string.format("Client [%s] %s unlocked storage %s.", client:SteamID64(), client:Name(), entClass) end,
        category = "Storage"
    },
    ["storageUnlockFailed"] = {
        func = function(client, entClass, password) return string.format("Client [%s] %s failed to unlock storage %s with password '%s'.", client:SteamID64(), client:Name(), entClass, password) end,
        category = "Storage"
    },
    ["spawnAdd"] = {
        func = function(client, faction) return string.format("Admin [%s] '%s' added a spawn for faction '%s'.", client:SteamID64(), client:Name(), faction) end,
        category = "Spawns"
    },
    ["spawnRemoveRadius"] = {
        func = function(client, radius, count) return string.format("Admin [%s] '%s' removed %d spawns within %d units.", client:SteamID64(), client:Name(), count, radius) end,
        category = "Spawns"
    },
    ["spawnRemoveByName"] = {
        func = function(client, faction, count) return string.format("Admin [%s] '%s' removed %d spawns for faction '%s'.", client:SteamID64(), client:Name(), count, faction) end,
        category = "Spawns"
    },
    ["returnItems"] = {
        func = function(client, targetName) return string.format("Admin [%s] '%s' returned lost items to %s.", client:SteamID64(), client:Name(), targetName) end,
        category = "Admin Actions"
    },
    ["banOOC"] = {
        func = function(client, targetName, steamID) return string.format("Admin [%s] '%s' banned %s (%s) from OOC chat.", client:SteamID64(), client:Name(), targetName, steamID) end,
        category = "Admin Actions"
    },
    ["unbanOOC"] = {
        func = function(client, targetName, steamID) return string.format("Admin [%s] '%s' unbanned %s (%s) from OOC chat.", client:SteamID64(), client:Name(), targetName, steamID) end,
        category = "Admin Actions"
    },
    ["blockOOC"] = {
        func = function(client, state) return string.format("Admin [%s] '%s' %s OOC chat globally.", client:SteamID64(), client:Name(), state and "blocked" or "unblocked") end,
        category = "Admin Actions"
    },
    ["clearChat"] = {
        func = function(client) return string.format("Admin [%s] '%s' cleared the chat.", client:SteamID64(), client:Name()) end,
        category = "Admin Actions"
    },
    ["cheaterBanned"] = {
        func = function(_, name, steamID) return string.format("Cheater '%s' [%s] was automatically banned.", name, steamID) end,
        category = "Admin Actions"
    },
    ["altKicked"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' [%s] was kicked.", name, steamID) end,
        category = "Admin Actions"
    },
    ["altBanned"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' [%s] was banned due to blacklist.", name, steamID) end,
        category = "Admin Actions"
    },
    ["viewPlayerClaims"] = {
        func = function(client, targetName) return string.format("Admin [%s] '%s' viewed claims for %s.", client:SteamID64(), client:Name(), targetName) end,
        category = "Tickets"
    },
    ["viewAllClaims"] = {
        func = function(client) return string.format("Admin [%s] '%s' viewed all ticket claims.", client:SteamID64(), client:Name()) end,
        category = "Tickets"
    },
    ["ticketClaimed"] = {
        func = function(client, requester, count)
            return string.format("Admin [%s] '%s' claimed a ticket for %s. Total claims: %d.", client:SteamID64(), client:Name(), requester, count or 0)
        end,
        category = "Tickets"
    },
    ["ticketClosed"] = {
        func = function(client, requester, count)
            return string.format("Admin [%s] '%s' closed a ticket for %s. Total claims: %d.", client:SteamID64(), client:Name(), requester, count or 0)
        end,
        category = "Tickets"
    },
    ["unprotectedVJNetCall"] = {
        func = function(client, netMessage) return string.format("[%s] %s triggered unprotected net message '%s'", client:SteamID64(), client:Name(), netMessage) end,
        category = "VJ Base"
    }
}
