lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name)
            return string.format("Player '%s' recognized character with ID %s and name '%s'.", client:Name(), id, name)
        end,
        category = "Recognition"
    },
    ["charCreate"] = {
        func = function(client, character)
            return string.format("Player '%s' created a new character named '%s'.", client:Name(), character:getName())
        end,
        category = "Character"
    },
    ["charLoad"] = {
        func = function(client, name)
            return string.format("Player '%s' loaded character '%s'.", client:Name(), name)
        end,
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
        func = function(client, attacker, damage, health)
            return string.format("Player '%s' took %s damage from '%s'. Current Health: %s", client:Name(), damage, attacker, health)
        end,
        category = "Damage"
    },
    ["playerDeath"] = {
        func = function(client, attacker)
            return string.format("Player '%s' was killed by '%s'.", client:Name(), attacker)
        end,
        category = "Death"
    },
    ["playerSpawn"] = {
        func = function(client)
            return string.format("Player '%s' spawned.", client:Name())
        end,
        category = "Character"
    },
    ["spawned_prop"] = {
        func = function(client, model)
            return string.format("Player '%s' spawned prop: %s.", client:Name(), model)
        end,
        category = "Spawn"
    },
    ["spawned_ragdoll"] = {
        func = function(client, model)
            return string.format("Player '%s' spawned ragdoll: %s.", client:Name(), model)
        end,
        category = "Spawn"
    },
    ["spawned_effect"] = {
        func = function(client, effect)
            return string.format("Player '%s' spawned effect: %s.", client:Name(), effect)
        end,
        category = "Spawn"
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model)
            return string.format("Player '%s' spawned vehicle '%s' with model '%s'.", client:Name(), vehicle, model)
        end,
        category = "Spawn"
    },
    ["spawned_npc"] = {
        func = function(client, npc, model)
            return string.format("Player '%s' spawned NPC '%s' with model '%s'.", client:Name(), npc, model)
        end,
        category = "Spawn"
    },
    ["spawned_sent"] = {
        func = function(client, class, model)
            return string.format("Player '%s' spawned entity '%s' with model '%s'.", client:Name(), class, model)
        end,
        category = "Spawn"
    },
    ["swep_spawning"] = {
        func = function(client, swep)
            return string.format("Player '%s' spawned SWEP '%s'.", client:Name(), swep)
        end,
        category = "SWEP"
    },
    ["chat"] = {
        func = function(client, chatType, message)
            return string.format("(%s) %s said: '%s'", chatType, client:Name(), message)
        end,
        category = "Chat"
    },
    ["chatOOC"] = {
        func = function(client, msg)
            return string.format("Player '%s' said (OOC): '%s'.", client:Name(), msg)
        end,
        category = "Chat"
    },
    ["chatLOOC"] = {
        func = function(client, msg)
            return string.format("Player '%s' said (LOOC): '%s'.", client:Name(), msg)
        end,
        category = "Chat"
    },
    ["command"] = {
        func = function(client, text)
            return string.format("Player '%s' ran command: %s.", client:Name(), text)
        end,
        category = "Chat"
    },
    ["money"] = {
        func = function(client, amount)
            return string.format("Player '%s' changed money by: %s.", client:Name(), amount)
        end,
        category = "Money"
    },
    ["moneyPickedUp"] = {
        func = function(client, amount)
            return string.format("Player '%s' picked up %s %s.", client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular)
        end,
        category = "Money"
    },
    ["charSetMoney"] = {
        func = function(client, targetName, amount)
            return string.format("Admin '%s' set %s's money to %s.", client:Name(), targetName, lia.currency.get(amount))
        end,
        category = "Money"
    },
    ["charAddMoney"] = {
        func = function(client, targetName, amount, total)
            return string.format("Admin '%s' gave %s %s (New Total: %s).", client:Name(), targetName, lia.currency.get(amount), lia.currency.get(total))
        end,
        category = "Money"
    },
    ["itemTake"] = {
        func = function(client, item)
            return string.format("Player '%s' took item '%s'.", client:Name(), item)
        end,
        category = "Items"
    },
    ["use"] = {
        func = function(client, item)
            return string.format("Player '%s' used item '%s'.", client:Name(), item)
        end,
        category = "Items"
    },
    ["itemDrop"] = {
        func = function(client, item)
            return string.format("Player '%s' dropped item '%s'.", client:Name(), item)
        end,
        category = "Items"
    },
    ["itemInteraction"] = {
        func = function(client, action, item)
            return string.format("Player '%s' %s item '%s'.", client:Name(), action, item.name)
        end,
        category = "Items"
    },
    ["itemEquip"] = {
        func = function(client, item)
            return string.format("Player '%s' equipped item '%s'.", client:Name(), item)
        end,
        category = "Items"
    },
    ["itemUnequip"] = {
        func = function(client, item)
            return string.format("Player '%s' unequipped item '%s'.", client:Name(), item)
        end,
        category = "Items"
    },
    ["toolgunUse"] = {
        func = function(client, tool)
            return string.format("Player '%s' used toolgun: '%s'.", client:Name(), tool)
        end,
        category = "Toolgun"
    },
    ["observeToggle"] = {
        func = function(client, state)
            return string.format("Player '%s' toggled observe mode %s.", client:Name(), state)
        end,
        category = "Admin Actions"
    },
    ["playerConnected"] = {
        func = function(client)
            return string.format("Player connected: '%s'.", client:Name())
        end,
        category = "Connections"
    },
    ["playerDisconnected"] = {
        func = function(client)
            return string.format("Player disconnected: '%s'.", client:Name())
        end,
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
        func = function(client)
            return string.format("Client %s triggered hack detection.", client:Name())
        end,
        category = "Connections"
    },
    ["dupeCrashAttempt"] = {
        func = function(client)
            local name = IsValid(client) and client:Name() or L("unknown")
            local steamID = IsValid(client) and client:SteamID64() or L("na")
            return string.format("Player '%s' [%s] attempted to duplicate oversized entities.", name, steamID)
        end,
        category = "Security"
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return string.format("%s set door class to %s on door %s.", client:Name(), className, door:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return string.format("%s removed door class from door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorSaveData"] = {
        func = function(client) return string.format("%s saved door data on door %s.", client:Nick(), client:Name()) end,
        category = "Doors"
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return string.format("%s set door %s to %s.", client:Name(), door:GetClass(), state and "unownable" or "ownable") end,
        category = "Doors"
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return string.format("%s set door faction to %s on door %s.", client:Name(), factionName, door:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return string.format("%s removed door faction %s from door %s.", client:Name(), factionName, door:GetClass()) end,
        category = "Doors"
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return string.format("%s set door %s to %s.", client:Name(), door:GetClass(), state and "hidden" or "visible") end,
        category = "Doors"
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return string.format("%s set door title to '%s' on door %s.", client:Name(), title, door:GetClass()) end,
        category = "Doors"
    },
    ["doorResetData"] = {
        func = function(client, door) return string.format("%s reset door data on door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorSetParent"] = {
        func = function(client, door) return string.format("%s set door parent for door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorAddChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("%s added child door %s to parent door %s.", client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "Doors"
    },
    ["doorRemoveChild"] = {
        func = function(client, parentDoor, childDoor) return string.format("%s removed child door %s from parent door %s.", client:Name(), childDoor:GetClass(), parentDoor:GetClass()) end,
        category = "Doors"
    },
    ["doorDisable"] = {
        func = function(client, door) return string.format("%s disabled door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorEnable"] = {
        func = function(client, door) return string.format("%s enabled door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["doorDisableAll"] = {
        func = function(client, count) return string.format("%s disabled all doors (%d total).", client:Name(), count) end,
        category = "Doors"
    },
    ["doorEnableAll"] = {
        func = function(client, count) return string.format("%s enabled all doors (%d total).", client:Name(), count) end,
        category = "Doors"
    },
    ["lockDoor"] = {
        func = function(client, door) return string.format("%s forcibly locked door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["unlockDoor"] = {
        func = function(client, door) return string.format("%s forcibly unlocked door %s.", client:Name(), door:GetClass()) end,
        category = "Doors"
    },
    ["toggleLock"] = {
        func = function(client, door, state) return string.format("%s toggled door %s to %s.", client:Name(), door:GetClass(), state) end,
        category = "Doors"
    },
    ["doorsell"] = {
        func = function(client, price) return string.format("Player '%s' sold a door for %s.", client:Name(), lia.currency.get(price)) end,
        category = "Doors"
    },
    ["admindoorsell"] = {
        func = function(client, ownerName, price) return string.format("Admin '%s' sold a door for '%s' and refunded %s.", client:Name(), ownerName, lia.currency.get(price)) end,
        category = "Doors"
    },
    ["buydoor"] = {
        func = function(client, price) return string.format("Player '%s' purchased a door for %s.", client:Name(), lia.currency.get(price)) end,
        category = "Doors"
    },
    ["doorSetPrice"] = {
        func = function(client, door, price) return string.format("%s set door price to %s on door %s.", client:Name(), lia.currency.get(price), door:GetClass()) end,
        category = "Doors"
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return string.format("Player '%s' spawned an item: '%s' %s.", client:Name(), displayName, message) end,
        category = "Item Spawner"
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return string.format("Player '%s' gave item '%s' to %s. Info: %s", client:Name(), itemName, target:Name(), message) end,
        category = "Item Spawner"
    },
    ["vendorAccess"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s accessed vendor %s", client:Name(), vendorName)
        end,
        category = "Vendors"
    },
    ["vendorExit"] = {
        func = function(client, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s exited vendor %s", client:Name(), vendorName)
        end,
        category = "Vendors"
    },
    ["vendorSell"] = {
        func = function(client, item, vendor)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s sold a %s to %s", client:Name(), item, vendorName)
        end,
        category = "Vendors"
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key)
            local vendorName = vendor:getNetVar("name") or L("unknown")
            return string.format("%s edited vendor %s with key %s", client:Name(), vendorName, key)
        end,
        category = "Vendors"
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
        category = "Vendors"
    },
    ["restockvendor"] = {
        func = function(client, vendor)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s restocked vendor %s", client:Name(), vendorName)
        end,
        category = "Vendors"
    },
    ["restockallvendors"] = {
        func = function(client, count)
            return string.format("%s restocked all vendors (%d total)", client:Name(), count)
        end,
        category = "Vendors"
    },
    ["resetvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s set vendor %s money to %s", client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Vendors"
    },
    ["resetallvendormoney"] = {
        func = function(client, amount, count)
            return string.format("%s reset all vendors money to %s (%d affected)", client:Name(), lia.currency.get(amount), count)
        end,
        category = "Vendors"
    },
    ["restockvendormoney"] = {
        func = function(client, vendor, amount)
            local vendorName = IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")
            return string.format("%s restocked vendor %s money to %s", client:Name(), vendorName, lia.currency.get(amount))
        end,
        category = "Vendors"
    },
    ["savevendors"] = {
        func = function(client) return string.format("%s saved all vendor data", client:Name()) end,
        category = "Vendors"
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return string.format("Configuration changed: '%s' from '%s' to '%s'.", name, tostring(oldValue), tostring(value)) end,
        category = "Admin Actions"
    },
    ["warningIssued"] = {
        func = function(client, target, reason, count, index)
            return string.format(
                "Warning issued at %s by admin '%s' to player '%s' for: '%s'. Total warnings: %d (added #%d).",
                os.date("%Y-%m-%d %H:%M:%S"),
                client:Name(),
                IsValid(target) and target:Name() or L("na"),
                reason,
                count or 0,
                index or count or 0
            )
        end,
        category = "Warnings"
    },
    ["warningRemoved"] = {
        func = function(client, target, warning, count, index)
            return string.format(
                "Warning removed at %s by admin '%s' for player '%s'. Reason: '%s'. Remaining warnings: %d (removed #%d).",
                os.date("%Y-%m-%d %H:%M:%S"),
                client:Name(),
                IsValid(target) and target:Name() or L("na"),
                warning.reason,
                count or 0,
                index or 0
            )
        end,
        category = "Warnings"
    },
    ["viewWarns"] = {
        func = function(client, target)
            return string.format(
                "Admin '%s' viewed warnings for player '%s'.",
                client:Name(),
                IsValid(target) and target:Name() or tostring(target)
            )
        end,
        category = "Warnings"
    },
    ["adminMode"] = {
        func = function(client, id, message)
            return string.format("Admin Mode toggled at %s by '%s': %s. (ID: %s)", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, id)
        end,
        category = "Admin Actions"
    },
    ["charsetmodel"] = {
        func = function(client, targetName, newModel, oldModel)
            return string.format("Admin '%s' changed %s's model from %s to %s", client:Name(), targetName, oldModel, newModel)
        end,
        category = "Admin Actions"
    },
    ["forceSay"] = {
        func = function(client, targetName, message)
            return string.format("Admin '%s' forced %s to say: %s", client:Name(), targetName, message)
        end,
        category = "Admin Actions"
    },
    ["plyTransfer"] = {
        func = function(client, targetName, oldFaction, newFaction)
            return string.format("Admin '%s' transferred '%s' from faction '%s' to '%s'.", client:Name(), targetName, oldFaction, newFaction)
        end,
        category = "Factions"
    },
    ["plyWhitelist"] = {
        func = function(client, targetName, faction)
            return string.format("Admin '%s' whitelisted '%s' for faction '%s'.", client:Name(), targetName, faction)
        end,
        category = "Factions"
    },
    ["plyUnwhitelist"] = {
        func = function(client, targetName, faction)
            return string.format("Admin '%s' removed '%s' from faction '%s' whitelist.", client:Name(), targetName, faction)
        end,
        category = "Factions"
    },
    ["beClass"] = {
        func = function(client, className)
            return string.format("Player '%s' joined class '%s'.", client:Name(), className)
        end,
        category = "Classes"
    },
    ["setClass"] = {
        func = function(client, targetName, className)
            return string.format("Admin '%s' set '%s' to class '%s'.", client:Name(), targetName, className)
        end,
        category = "Classes"
    },
    ["classWhitelist"] = {
        func = function(client, targetName, className)
            return string.format("Admin '%s' whitelisted '%s' for class '%s'.", client:Name(), targetName, className)
        end,
        category = "Classes"
    },
    ["classUnwhitelist"] = {
        func = function(client, targetName, className)
            return string.format("Admin '%s' removed '%s' from class '%s' whitelist.", client:Name(), targetName, className)
        end,
        category = "Classes"
    },
    ["flagGive"] = {
        func = function(client, targetName, flags)
            return string.format("Admin '%s' gave flags '%s' to %s.", client:Name(), flags, targetName)
        end,
        category = "Flags"
    },
    ["flagGiveAll"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' gave all flags to %s.", client:Name(), targetName)
        end,
        category = "Flags"
    },
    ["flagTake"] = {
        func = function(client, targetName, flags)
            return string.format("Admin '%s' took flags '%s' from %s.", client:Name(), flags, targetName)
        end,
        category = "Flags"
    },
    ["flagTakeAll"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' removed all flags from %s.", client:Name(), targetName)
        end,
        category = "Flags"
    },
    ["voiceToggle"] = {
        func = function(client, targetName, state)
            return string.format("Admin '%s' toggled voice ban for %s: %s.", client:Name(), targetName, state)
        end,
        category = "Admin Actions"
    },
    ["charBan"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' banned character '%s'.", client:Name(), targetName)
        end,
        category = "Admin Actions"
    },
    ["charUnban"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' unbanned character '%s'.", client:Name(), targetName)
        end,
        category = "Admin Actions"
    },
    ["charKick"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' kicked character '%s'.", client:Name(), targetName)
        end,
        category = "Admin Actions"
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message)
            return string.format("Sit room set at %s by '%s': %s. Position: %s", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, pos)
        end,
        category = "Sit Rooms"
    },
    ["sitRoomRenamed"] = {
        func = function(client, details)
            return string.format("%s renamed a SitRoom: %s", client:Name(), details)
        end,
        category = "Sit Rooms"
    },
    ["sitRoomRepositioned"] = {
        func = function(client, details)
            return string.format("%s repositioned a SitRoom: %s", client:Name(), details)
        end,
        category = "Sit Rooms"
    },
    ["sendToSitRoom"] = {
        func = function(client, targetName, roomName)
            if targetName == client:Name() then
                return string.format("Player '%s' teleported to SitRoom '%s'.", client:Name(), roomName)
            end
            return string.format("Player '%s' sent '%s' to SitRoom '%s'.", client:Name(), targetName, roomName)
        end,
        category = "Sit Rooms"
    },
    ["sitRoomReturn"] = {
        func = function(client, targetName)
            if targetName == client:Name() then
                return string.format("Player '%s' returned from a SitRoom.", client:Name())
            end
            return string.format("Player '%s' returned '%s' from a SitRoom.", client:Name(), targetName)
        end,
        category = "Sit Rooms"
    },
    ["attribSet"] = {
        func = function(client, targetName, attrib, value)
            return string.format("Admin '%s' set %s's '%s' attribute to %d.", client:Name(), targetName, attrib, value)
        end,
        category = "Attributes"
    },
    ["attribAdd"] = {
        func = function(client, targetName, attrib, value)
            return string.format("Admin '%s' added %d to %s's '%s' attribute.", client:Name(), value, targetName, attrib)
        end,
        category = "Attributes"
    },
    ["attribCheck"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' viewed attributes of %s.", client:Name(), targetName)
        end,
        category = "Attributes"
    },
    ["invUpdateSize"] = {
        func = function(client, targetName, w, h)
            return string.format("Admin '%s' reset %s's inventory size to %dx%d.", client:Name(), targetName, w, h)
        end,
        category = "Inventory"
    },
    ["invSetSize"] = {
        func = function(client, targetName, w, h)
            return string.format("Admin '%s' set %s's inventory size to %dx%d.", client:Name(), targetName, w, h)
        end,
        category = "Inventory"
    },
    ["storageLock"] = {
        func = function(client, entClass, state)
            return string.format("Admin '%s' %s storage %s.", client:Name(), state and "locked" or "unlocked", entClass)
        end,
        category = "Storage"
    },
    ["storageUnlock"] = {
        func = function(client, entClass)
            return string.format("Client %s unlocked storage %s.", client:Name(), entClass)
        end,
        category = "Storage"
    },
    ["storageUnlockFailed"] = {
        func = function(client, entClass, password)
            return string.format("Client %s failed to unlock storage %s with password '%s'.", client:Name(), entClass, password)
        end,
        category = "Storage"
    },
    ["spawnAdd"] = {
        func = function(client, faction)
            return string.format("Admin '%s' added a spawn for faction '%s'.", client:Name(), faction)
        end,
        category = "Spawns"
    },
    ["spawnRemoveRadius"] = {
        func = function(client, radius, count)
            return string.format("Admin '%s' removed %d spawns within %d units.", client:Name(), count, radius)
        end,
        category = "Spawns"
    },
    ["spawnRemoveByName"] = {
        func = function(client, faction, count)
            return string.format("Admin '%s' removed %d spawns for faction '%s'.", client:Name(), count, faction)
        end,
        category = "Spawns"
    },
    ["returnItems"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' returned lost items to %s.", client:Name(), targetName)
        end,
        category = "Admin Actions"
    },
    ["banOOC"] = {
        func = function(client, targetName, steamID)
            return string.format("Admin '%s' banned %s (%s) from OOC chat.", client:Name(), targetName, steamID)
        end,
        category = "Admin Actions"
    },
    ["unbanOOC"] = {
        func = function(client, targetName, steamID)
            return string.format("Admin '%s' unbanned %s (%s) from OOC chat.", client:Name(), targetName, steamID)
        end,
        category = "Admin Actions"
    },
    ["blockOOC"] = {
        func = function(client, state)
            return string.format("Admin '%s' %s OOC chat globally.", client:Name(), state and "blocked" or "unblocked")
        end,
        category = "Admin Actions"
    },
    ["clearChat"] = {
        func = function(client) return string.format("Admin '%s' cleared the chat.", client:Name()) end,
        category = "Admin Actions"
    },
    ["cheaterBanned"] = {
        func = function(_, name, steamID) return string.format("Cheater '%s' (%s) was automatically banned.", name, steamID) end,
        category = "Admin Actions"
    },
    ["altKicked"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' (%s) was kicked.", name, steamID) end,
        category = "Admin Actions"
    },
    ["altBanned"] = {
        func = function(_, name, steamID) return string.format("Alt account '%s' (%s) was banned due to blacklist.", name, steamID) end,
        category = "Admin Actions"
    },
    ["viewPlayerClaims"] = {
        func = function(client, targetName)
            return string.format("Admin '%s' viewed claims for %s.", client:Name(), targetName)
        end,
        category = "Tickets"
    },
    ["viewAllClaims"] = {
        func = function(client) return string.format("Admin '%s' viewed all ticket claims.", client:Name()) end,
        category = "Tickets"
    },
    ["ticketClaimed"] = {
        func = function(client, requester, count)
            return string.format("Admin '%s' claimed a ticket for %s. Total claims: %d.", client:Name(), requester, count or 0)
        end,
        category = "Tickets"
    },
    ["ticketClosed"] = {
        func = function(client, requester, count)
            return string.format("Admin '%s' closed a ticket for %s. Total claims: %d.", client:Name(), requester, count or 0)
        end,
        category = "Tickets"
    },
    ["unprotectedVJNetCall"] = {
        func = function(client, netMessage) return string.format("%s triggered unprotected net message '%s'", client:Name(), netMessage) end,
        category = "VJ Base"
    },
    ["permaPropSaved"] = {
        func = function(client, class, model, pos)
            return string.format("%s perma-propped %s (%s) at %s", client:Name(), class, model, pos)
        end,
        category = "PermaProps"
    },
    ["permaPropOverlap"] = {
        func = function(_, pos, other) return string.format("Perma-prop spawned at %s overlapping prop at %s.", pos, other) end,
        category = "PermaProps"
    },
}
