lia.log = lia.log or {}
lia.log.types = {
    ["charRecognize"] = {
        func = function(client, id, name) return L("logPlayerRecognizedCharacter", client:Name(), id, name) end,
        category = L("character")
    },
    ["charCreate"] = {
        func = function(client, character) return L("logPlayerCreatedCharacter", client:Name(), character:getName()) end,
        category = L("character")
    },
    ["charLoad"] = {
        func = function(client, name) return L("logPlayerLoadedCharacter", client:Name(), name) end,
        category = L("character")
    },
    ["charDelete"] = {
        func = function(client, id)
            local name = IsValid(client) and client:Name() or L("console")
            return L("logPlayerDeletedCharacter", name, id)
        end,
        category = L("character")
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return L("logPlayerTookDamage", client:Name(), damage, attacker, health) end,
        category = L("categoryCombat")
    },
    ["playerDeath"] = {
        func = function(client, attacker) return L("logPlayerKilled", client:Name(), attacker) end,
        category = L("categoryCombat")
    },
    ["playerSpawn"] = {
        func = function(client) return L("logPlayerSpawned", client:Name()) end,
        category = L("character")
    },
    ["spawned_prop"] = {
        func = function(client, model) return L("logPlayerSpawnedProp", client:Name(), model) end,
        category = L("categoryWorld")
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return L("logPlayerSpawnedRagdoll", client:Name(), model) end,
        category = L("categoryWorld")
    },
    ["spawned_effect"] = {
        func = function(client, effect) return L("logPlayerSpawnedEffect", client:Name(), effect) end,
        category = L("categoryWorld")
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return L("logPlayerSpawnedVehicle", client:Name(), vehicle, model) end,
        category = L("categoryWorld")
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return L("logPlayerSpawnedNPC", client:Name(), npc, model) end,
        category = L("categoryWorld")
    },
    ["spawned_sent"] = {
        func = function(client, class, model) return L("logPlayerSpawnedEntity", client:Name(), class, model) end,
        category = L("categoryWorld")
    },
    ["swep_spawning"] = {
        func = function(client, swep) return L("logPlayerSpawnedSWEP", client:Name(), swep) end,
        category = L("categoryCombat")
    },
    ["physgunPickup"] = {
        func = function(client, class, model) return L("logPhysgunPickup", client:Name(), class, model) end,
        category = L("categoryTools")
    },
    ["physgunDrop"] = {
        func = function(client, class, model) return L("logPhysgunDrop", client:Name(), class, model) end,
        category = L("categoryTools")
    },
    ["physgunFreeze"] = {
        func = function(client, class, model) return L("logPhysgunFreeze", client:Name(), class, model) end,
        category = L("categoryTools")
    },
    ["vehicleEnter"] = {
        func = function(client, class, model) return L("logVehicleEnter", client:Name(), class, model) end,
        category = L("categoryWorld")
    },
    ["vehicleExit"] = {
        func = function(client, class, model) return L("logVehicleExit", client:Name(), class, model) end,
        category = L("categoryWorld")
    },
    ["chat"] = {
        func = function(client, chatType, message) return L("logChatMessage", chatType, client:Name(), message) end,
        category = L("categoryChat")
    },
    ["chatOOC"] = {
        func = function(client, msg) return L("logChatOOC", client:Name(), msg) end,
        category = L("categoryChat")
    },
    ["chatLOOC"] = {
        func = function(client, msg) return L("logChatLOOC", client:Name(), msg) end,
        category = L("categoryChat")
    },
    ["command"] = {
        func = function(client, text) return L("logCommand", client:Name(), text) end,
        category = L("commands")
    },
    ["money"] = {
        func = function(client, amount) return L("logMoneyChange", client:Name(), amount) end,
        category = L("money")
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return L("logMoneyPickedUp", client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular) end,
        category = L("money")
    },
    ["charSetMoney"] = {
        func = function(client, targetName, amount) return L("logCharSetMoney", client:Name(), targetName, lia.currency.get(amount)) end,
        category = L("money")
    },
    ["charAddMoney"] = {
        func = function(client, targetName, amount, total) return L("logCharAddMoney", client:Name(), targetName, lia.currency.get(amount), lia.currency.get(total)) end,
        category = L("money")
    },
    ["moneyDropped"] = {
        func = function(client, amount) return L("logMoneyDropped", client:Name(), lia.currency.get(amount)) end,
        category = L("money")
    },
    ["itemTake"] = {
        func = function(client, item) return L("logItemTake", client:Name(), item) end,
        category = L("items")
    },
    ["use"] = {
        func = function(client, item) return L("logItemUse", client:Name(), item) end,
        category = L("items")
    },
    ["itemDrop"] = {
        func = function(client, item) return L("logItemDrop", client:Name(), item) end,
        category = L("items")
    },
    ["itemInteractionFailed"] = {
        func = function(client, action, itemName) return L("logItemInteractionFailed", client:Name(), action, itemName) end,
        category = L("items")
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return L("logItemInteraction", client:Name(), action, item.name) end,
        category = L("items")
    },
    ["itemEquip"] = {
        func = function(client, item) return L("logItemEquip", client:Name(), item) end,
        category = L("items")
    },
    ["itemUnequip"] = {
        func = function(client, item) return L("logItemUnequip", client:Name(), item) end,
        category = L("items")
    },
    ["itemTransfer"] = {
        func = function(client, itemName, fromID, toID) return L("logItemTransfer", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        category = L("items")
    },
    ["itemTransferFailed"] = {
        func = function(client, itemName, fromID, toID) return L("logItemTransferFailed", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        category = L("items")
    },
    ["itemCombine"] = {
        func = function(client, itemName, targetName) return L("logItemCombine", client:Name(), itemName, targetName) end,
        category = L("items")
    },
    ["itemFunction"] = {
        func = function(client, action, itemName) return L("logItemFunction", client:Name(), action, itemName) end,
        category = L("items")
    },
    ["itemAdded"] = {
        func = function(client, itemName) return L("logItemAdded", itemName, IsValid(client) and client:Name() or L("unknown")) end,
        category = L("items")
    },
    ["itemCreated"] = {
        func = function(_, itemName) return L("logItemCreated", itemName) end,
        category = L("items")
    },
    ["itemSpawned"] = {
        func = function(_, itemName) return L("logItemSpawned", itemName) end,
        category = L("items")
    },
    ["itemDraggedOut"] = {
        func = function(client, itemName) return L("logItemDraggedOut", client:Name(), itemName) end,
        category = L("items")
    },
    ["toolgunUse"] = {
        func = function(client, tool) return L("logToolgunUse", client:Name(), tool) end,
        category = L("categoryTools")
    },
    ["permissionDenied"] = {
        func = function(client, action) return L("logPermissionDenied", client:Name(), action) end,
        category = L("modulePermissionsName")
    },
    ["spawnDenied"] = {
        func = function(client, objectType, model) return L("logSpawnDenied", client:Name(), objectType, tostring(model)) end,
        category = L("modulePermissionsName")
    },
    ["toolDenied"] = {
        func = function(client, tool) return L("logToolDenied", client:Name(), tool) end,
        category = L("modulePermissionsName")
    },
    ["observeToggle"] = {
        func = function(client, state) return L("logObserveToggle", client:Name(), state) end,
        category = L("admin")
    },
    ["playerConnect"] = {
        func = function(_, name, ip) return L("logPlayerConnecting", name, ip) end,
        category = L("categoryConnections"),
    },
    ["playerConnected"] = {
        func = function(client) return L("logPlayerConnected", client:Name()) end,
        category = L("categoryConnections")
    },
    ["playerDisconnected"] = {
        func = function(client) return L("logPlayerDisconnected", client:Name()) end,
        category = L("categoryConnections")
    },
    ["failedPassword"] = {
        func = function(_, steamID, name, svpass, clpass) return L("logFailedPassword", steamID, name, svpass, clpass) end,
        category = L("categoryConnections")
    },
    ["exploitAttempt"] = {
        func = function(_, name, steamID, netMessage) return L("logExploitAttempt", name, steamID, netMessage) end,
        category = L("categoryExploits")
    },
    ["backdoorDetected"] = {
        func = function(_, netMessage, file, line)
            if file then return L("logBackdoorDetectedFile", netMessage, file, tostring(line)) end
            return L("logBackdoorDetected", netMessage)
        end,
        category = L("categoryExploits")
    },
    ["steamIDMissing"] = {
        func = function(_, name, steamID) return L("logSteamIDMissing", name, steamID) end,
        category = L("categoryConnections")
    },
    ["steamIDMismatch"] = {
        func = function(_, name, realSteamID, sentSteamID) return L("logSteamIDMismatch", name, realSteamID, sentSteamID) end,
        category = L("categoryConnections")
    },
    ["hackAttempt"] = {
        func = function(client, netName)
            if netName then return L("logHackAttemptNet", client:Name(), netName) end
            return L("logHackAttempt", client:Name())
        end,
        category = L("categoryCheating")
    },
    ["verifyCheatsOK"] = {
        func = function(client) return L("logVerifyCheatsOK", client:Name()) end,
        category = L("categoryCheating")
    },
    ["doorSetClass"] = {
        func = function(client, door, className) return L("logDoorSetClass", client:Name(), className, door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorRemoveClass"] = {
        func = function(client, door) return L("logDoorRemoveClass", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorSaveData"] = {
        func = function(client) return L("logDoorSaveData", client:Nick(), client:Name()) end,
        category = L("categoryWorld")
    },
    ["doorToggleOwnable"] = {
        func = function(client, door, state) return L("logDoorToggleOwnable", client:Name(), door:GetClass(), state and L("unownable") or L("ownable")) end,
        category = L("categoryWorld")
    },
    ["doorSetFaction"] = {
        func = function(client, door, factionName) return L("logDoorSetFaction", client:Name(), factionName, door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorRemoveFaction"] = {
        func = function(client, door, factionName) return L("logDoorRemoveFaction", client:Name(), factionName, door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorSetHidden"] = {
        func = function(client, door, state) return L("logDoorSetHidden", client:Name(), door:GetClass(), state and L("hidden") or L("visible")) end,
        category = L("categoryWorld")
    },
    ["doorSetTitle"] = {
        func = function(client, door, title) return L("logDoorSetTitle", client:Name(), title, door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorResetData"] = {
        func = function(client, door) return L("logDoorResetData", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorDisable"] = {
        func = function(client, door) return L("logDoorDisable", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorEnable"] = {
        func = function(client, door) return L("logDoorEnable", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["doorDisableAll"] = {
        func = function(client, count) return L("logDoorDisableAll", client:Name(), count) end,
        category = L("categoryWorld")
    },
    ["doorEnableAll"] = {
        func = function(client, count) return L("logDoorEnableAll", client:Name(), count) end,
        category = L("categoryWorld")
    },
    ["lockDoor"] = {
        func = function(client, door) return L("logDoorLock", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["unlockDoor"] = {
        func = function(client, door) return L("logDoorUnlock", client:Name(), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["toggleLock"] = {
        func = function(client, door, state) return L("logDoorToggleLock", client:Name(), door:GetClass(), state) end,
        category = L("categoryWorld")
    },
    ["doorsell"] = {
        func = function(client, price) return L("logDoorSell", client:Name(), lia.currency.get(price)) end,
        category = L("categoryWorld")
    },
    ["admindoorsell"] = {
        func = function(client, ownerName, price) return L("logAdminDoorSell", client:Name(), ownerName, lia.currency.get(price)) end,
        category = L("categoryWorld")
    },
    ["buydoor"] = {
        func = function(client, price) return L("logDoorPurchase", client:Name(), lia.currency.get(price)) end,
        category = L("categoryWorld")
    },
    ["doorSetPrice"] = {
        func = function(client, door, price) return L("logDoorSetPrice", client:Name(), lia.currency.get(price), door:GetClass()) end,
        category = L("categoryWorld")
    },
    ["spawnItem"] = {
        func = function(client, displayName, message) return L("logSpawnItem", client:Name(), displayName, message) end,
        category = L("items")
    },
    ["chargiveItem"] = {
        func = function(client, itemName, target, message) return L("logCharGiveItem", client:Name(), itemName, target:Name(), message) end,
        category = L("items")
    },
    ["vendorAccess"] = {
        func = function(client, vendor) return L("logVendorAccess", client:Name(), vendor:getNetVar("name") or L("unknown")) end,
        category = L("items")
    },
    ["vendorExit"] = {
        func = function(client, vendor) return L("logVendorExit", client:Name(), vendor:getNetVar("name") or L("unknown")) end,
        category = L("items")
    },
    ["vendorSell"] = {
        func = function(client, item, vendor) return L("logVendorSell", client:Name(), item, vendor:getNetVar("name") or L("unknown")) end,
        category = L("items")
    },
    ["vendorEdit"] = {
        func = function(client, vendor, key) return L("logVendorEdit", client:Name(), vendor:getNetVar("name") or L("unknown"), key) end,
        category = L("items")
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor, isFailed)
            if isFailed then
                return L("logVendorBuyFailed", client:Name(), item, vendor:getNetVar("name") or L("unknown"))
            else
                return L("logVendorBuy", client:Name(), item, vendor:getNetVar("name") or L("unknown"))
            end
        end,
        category = L("items")
    },
    ["restockvendor"] = {
        func = function(client, vendor) return L("logVendorRestock", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")) end,
        category = L("items")
    },
    ["restockallvendors"] = {
        func = function(client, count) return L("logVendorsRestockAll", client:Name(), count) end,
        category = L("items")
    },
    ["resetvendormoney"] = {
        func = function(client, vendor, amount) return L("logVendorMoneyReset", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown"), lia.currency.get(amount)) end,
        category = L("items")
    },
    ["resetallvendormoney"] = {
        func = function(client, amount, count) return L("logVendorMoneyResetAll", client:Name(), lia.currency.get(amount), count) end,
        category = L("items")
    },
    ["restockvendormoney"] = {
        func = function(client, vendor, amount) return L("logVendorMoneyRestock", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown"), lia.currency.get(amount)) end,
        category = L("items")
    },
    ["savevendors"] = {
        func = function(client) return L("logVendorsSave", client:Name()) end,
        category = L("items")
    },
    ["configChange"] = {
        func = function(name, oldValue, value) return L("logConfigChange", name, tostring(oldValue), tostring(value)) end,
        category = L("admin")
    },
    ["warningIssued"] = {
        func = function(client, target, reason, count, index) return L("logWarningIssued", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), reason, count or 0, index or count or 0) end,
        category = L("admin")
    },
    ["warningRemoved"] = {
        func = function(client, target, warning, count, index) return L("logWarningRemoved", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), warning.reason, count or 0, index or 0) end,
        category = L("admin")
    },
    ["viewWarns"] = {
        func = function(client, target) return L("logViewWarns", client:Name(), IsValid(target) and target:Name() or tostring(target)) end,
        category = L("admin")
    },
    ["adminMode"] = {
        func = function(client, id, message) return L("logAdminMode", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, id) end,
        category = L("admin")
    },
    ["charsetmodel"] = {
        func = function(client, targetName, newModel, oldModel) return L("logCharSetModel", client:Name(), targetName, oldModel, newModel) end,
        category = L("admin")
    },
    ["forceSay"] = {
        func = function(client, targetName, message) return L("logForceSay", client:Name(), targetName, message) end,
        category = L("admin")
    },
    ["plyTransfer"] = {
        func = function(client, targetName, oldFaction, newFaction) return L("logPlyTransfer", client:Name(), targetName, oldFaction, newFaction) end,
        category = L("factions")
    },
    ["plyWhitelist"] = {
        func = function(client, targetName, faction) return L("logPlyWhitelist", client:Name(), targetName, faction) end,
        category = L("factions")
    },
    ["plyUnwhitelist"] = {
        func = function(client, targetName, faction) return L("logPlyUnwhitelist", client:Name(), targetName, faction) end,
        category = L("factions")
    },
    ["beClass"] = {
        func = function(client, className) return L("logBeClass", client:Name(), className) end,
        category = L("factions")
    },
    ["setClass"] = {
        func = function(client, targetName, className) return L("logSetClass", client:Name(), targetName, className) end,
        category = L("factions")
    },
    ["classWhitelist"] = {
        func = function(client, targetName, className) return L("logClassWhitelist", client:Name(), targetName, className) end,
        category = L("factions")
    },
    ["classUnwhitelist"] = {
        func = function(client, targetName, className) return L("logClassUnwhitelist", client:Name(), targetName, className) end,
        category = L("factions")
    },
    ["flagGive"] = {
        func = function(client, targetName, flags) return L("logFlagGive", client:Name(), targetName, flags) end,
        category = L("admin")
    },
    ["flagGiveAll"] = {
        func = function(client, targetName) return L("logFlagGiveAll", client:Name(), targetName) end,
        category = L("admin")
    },
    ["flagTake"] = {
        func = function(client, targetName, flags) return L("logFlagTake", client:Name(), targetName, flags) end,
        category = L("admin")
    },
    ["flagTakeAll"] = {
        func = function(client, targetName) return L("logFlagTakeAll", client:Name(), targetName) end,
        category = L("admin")
    },
    ["playerFlagGive"] = {
        func = function(client, targetName, flags) return L("logPlayerFlagGive", client:Name(), targetName, flags) end,
        category = L("admin"),
    },
    ["playerFlagGiveAll"] = {
        func = function(client, targetName) return L("logPlayerFlagGiveAll", client:Name(), targetName) end,
        category = L("admin"),
    },
    ["playerFlagTake"] = {
        func = function(client, targetName, flags) return L("logPlayerFlagTake", client:Name(), targetName, flags) end,
        category = L("admin"),
    },
    ["playerFlagTakeAll"] = {
        func = function(client, targetName) return L("logPlayerFlagTakeAll", client:Name(), targetName) end,
        category = L("admin"),
    },
    ["voiceToggle"] = {
        func = function(client, targetName, state) return L("logVoiceToggle", client:Name(), targetName, state) end,
        category = L("admin")
    },
    ["charBan"] = {
        func = function(client, targetName) return L("logCharBan", client:Name(), targetName) end,
        category = L("admin")
    },
    ["charUnban"] = {
        func = function(client, targetName) return L("logCharUnban", client:Name(), targetName) end,
        category = L("admin")
    },
    ["charKick"] = {
        func = function(client, targetName) return L("logCharKick", client:Name(), targetName) end,
        category = L("admin")
    },
    ["sitRoomSet"] = {
        func = function(client, pos, message) return L("sitroomSetLog", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, pos) end,
        category = L("admin"),
    },
    ["sitRoomRenamed"] = {
        func = function(client, details) return L("sitroomRenamedLog", client:Name(), details) end,
        category = L("admin"),
    },
    ["sitRoomRepositioned"] = {
        func = function(client, details) return L("sitroomRepositionedLog", client:Name(), details) end,
        category = L("admin"),
    },
    ["sendToSitRoom"] = {
        func = function(client, targetName, roomName)
            if targetName == client:Name() then return L("sitroomTeleportedLog", client:Name(), roomName) end
            return L("sitroomSentLog", client:Name(), targetName, roomName)
        end,
        category = L("admin"),
    },
    ["sitRoomReturn"] = {
        func = function(client, targetName)
            if targetName == client:Name() then return L("sitroomReturnSelfLog", client:Name()) end
            return L("sitroomReturnOtherLog", client:Name(), targetName)
        end,
        category = L("admin"),
    },
    ["attribSet"] = {
        func = function(client, targetName, attrib, value) return L("logAttribSet", client:Name(), targetName, attrib, value) end,
        category = L("character")
    },
    ["attribAdd"] = {
        func = function(client, targetName, attrib, value) return L("logAttribAdd", client:Name(), value, targetName, attrib) end,
        category = L("character")
    },
    ["attribCheck"] = {
        func = function(client, targetName) return L("logAttribCheck", client:Name(), targetName) end,
        category = L("character")
    },
    ["invUpdateSize"] = {
        func = function(client, targetName, w, h) return L("logInvUpdateSize", client:Name(), targetName, w, h) end,
        category = L("inv")
    },
    ["invSetSize"] = {
        func = function(client, targetName, w, h) return L("logInvSetSize", client:Name(), targetName, w, h) end,
        category = L("inv")
    },
    ["storageLock"] = {
        func = function(client, entClass, state) return L("logStorageLock", client:Name(), state and L("locked") or L("unlocked"), entClass) end,
        category = L("inv")
    },
    ["storageUnlock"] = {
        func = function(client, entClass) return L("logStorageUnlock", client:Name(), entClass) end,
        category = L("inv")
    },
    ["storageUnlockFailed"] = {
        func = function(client, entClass, password) return L("logStorageUnlockFailed", client:Name(), entClass, password) end,
        category = L("inv")
    },
    ["spawnAdd"] = {
        func = function(client, faction) return L("logSpawnAdd", client:Name(), faction) end,
        category = L("categoryWorld")
    },
    ["spawnRemoveRadius"] = {
        func = function(client, radius, count) return L("logSpawnRemoveRadius", client:Name(), count, radius) end,
        category = L("categoryWorld")
    },
    ["spawnRemoveByName"] = {
        func = function(client, faction, count) return L("logSpawnRemoveByName", client:Name(), count, faction) end,
        category = L("categoryWorld")
    },
    ["returnItems"] = {
        func = function(client, targetName) return L("logReturnItems", client:Name(), targetName) end,
        category = L("admin")
    },
    ["banOOC"] = {
        func = function(client, targetName, steamID) return L("logBanOOC", client:Name(), targetName, steamID) end,
        category = L("admin")
    },
    ["unbanOOC"] = {
        func = function(client, targetName, steamID) return L("logUnbanOOC", client:Name(), targetName, steamID) end,
        category = L("admin")
    },
    ["blockOOC"] = {
        func = function(client, state) return L("logBlockOOC", client:Name(), state and L("blocked") or L("unblocked")) end,
        category = L("admin")
    },
    ["clearChat"] = {
        func = function(client) return L("logClearChat", client:Name()) end,
        category = L("admin")
    },
    ["cheaterBanned"] = {
        func = function(_, name, steamID) return L("logCheaterBanned", name, steamID) end,
        category = L("categoryCheating")
    },
    ["cheaterDetected"] = {
        func = function(_, name, steamID) return L("logCheaterDetected", name, steamID) end,
        category = L("categoryCheating")
    },
    ["cheaterToggle"] = {
        func = function(client, targetName, state) return L("logCheaterToggle", client:Name(), targetName, state) end,
        category = L("categoryCheating")
    },
    ["cheaterAction"] = {
        func = function(client, action) return L("logCheaterAction", client:Name(), action) end,
        category = L("categoryCheaterActions")
    },
    ["altKicked"] = {
        func = function(_, name, steamID) return L("logAltKicked", name, steamID) end,
        category = L("admin")
    },
    ["altBanned"] = {
        func = function(_, name, steamID) return L("logAltBanned", name, steamID) end,
        category = L("admin")
    },
    ["plyKick"] = {
        func = function(client, targetName) return L("logPlyKick", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyBan"] = {
        func = function(client, targetName) return L("logPlyBan", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUnban"] = {
        func = function(client, targetIdentifier) return L("logPlyUnban", client:Name(), targetIdentifier) end,
        category = L("admin")
    },
    ["viewPlayerClaims"] = {
        func = function(client, targetName) return L("logViewPlayerClaims", client:Name(), targetName) end,
        category = L("admin")
    },
    ["viewAllClaims"] = {
        func = function(client) return L("logViewAllClaims", client:Name()) end,
        category = L("admin")
    },
    ["viewPlayerTickets"] = {
        func = function(client, targetName) return L("logViewPlayerTickets", client:Name(), targetName) end,
        category = L("admin")
    },
    ["ticketClaimed"] = {
        func = function(client, requester, count) return L("logTicketClaimed", client:Name(), requester, count or 0) end,
        category = L("admin")
    },
    ["ticketClosed"] = {
        func = function(client, requester, count) return L("logTicketClosed", client:Name(), requester, count or 0) end,
        category = L("admin")
    },
    ["teleportToEntity"] = {
        func = function(client, entClass) return L("logTeleportToEntity", client:Name(), entClass) end,
        category = L("admin")
    },
    ["plyBring"] = {
        func = function(client, targetName) return L("logPlyBring", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyGoto"] = {
        func = function(client, targetName) return L("logPlyGoto", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyReturn"] = {
        func = function(client, targetName) return L("logPlyReturn", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyJail"] = {
        func = function(client, targetName) return L("logPlyJail", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUnjail"] = {
        func = function(client, targetName) return L("logPlyUnjail", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyKill"] = {
        func = function(client, targetName) return L("logPlyKill", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plySlay"] = {
        func = function(client, targetName) return L("logPlySlay", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyRespawn"] = {
        func = function(client, targetName) return L("logPlyRespawn", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyFreeze"] = {
        func = function(client, targetName, duration) return L("logPlyFreeze", client:Name(), targetName, tostring(duration)) end,
        category = L("admin")
    },
    ["plyUnfreeze"] = {
        func = function(client, targetName) return L("logPlyUnfreeze", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyBlind"] = {
        func = function(client, targetName, duration) return L("logPlyBlind", client:Name(), targetName, tostring(duration)) end,
        category = L("admin")
    },
    ["plyUnblind"] = {
        func = function(client, targetName) return L("logPlyUnblind", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyBlindFade"] = {
        func = function(client, targetName, duration, color) return L("logPlyBlindFade", client:Name(), targetName, tostring(duration), color) end,
        category = L("admin")
    },
    ["blindFadeAll"] = {
        func = function(_, duration, color) return L("logBlindFadeAll", tostring(duration), color) end,
        category = L("admin")
    },
    ["plyGag"] = {
        func = function(client, targetName) return L("logPlyGag", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUngag"] = {
        func = function(client, targetName) return L("logPlyUngag", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyMute"] = {
        func = function(client, targetName) return L("logPlyMute", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUnmute"] = {
        func = function(client, targetName) return L("logPlyUnmute", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyCloak"] = {
        func = function(client, targetName) return L("logPlyCloak", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUncloak"] = {
        func = function(client, targetName) return L("logPlyUncloak", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyGod"] = {
        func = function(client, targetName) return L("logPlyGod", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyUngod"] = {
        func = function(client, targetName) return L("logPlyUngod", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyIgnite"] = {
        func = function(client, targetName, duration) return L("logPlyIgnite", client:Name(), targetName, tostring(duration)) end,
        category = L("admin")
    },
    ["plyExtinguish"] = {
        func = function(client, targetName) return L("logPlyExtinguish", client:Name(), targetName) end,
        category = L("admin")
    },
    ["plyStrip"] = {
        func = function(client, targetName) return L("logPlyStrip", client:Name(), targetName) end,
        category = L("admin")
    },
    ["charBanOffline"] = {
        func = function(client, charID) return L("logCharBanOffline", client:Name(), tostring(charID)) end,
        category = L("admin")
    },
    ["charUnbanOffline"] = {
        func = function(client, charID) return L("logCharUnbanOffline", client:Name(), tostring(charID)) end,
        category = L("admin")
    },

}

function lia.log.addType(logType, func, category)
    lia.log.types[logType] = {
        func = func,
        category = category,
    }
end

function lia.log.getString(client, logType, ...)
    local logData = lia.log.types[logType]
    if not logData then return end
    if isfunction(logData.func) then
        local success, result = pcall(logData.func, client, ...)
        if success then return result, logData.category end
    end
end

function lia.log.add(client, logType, ...)
    local logString, category = lia.log.getString(client, logType, ...)
    if not isstring(category) then category = L("uncategorized") end
    if not isstring(logString) then return end
    hook.Run("OnServerLog", client, logType, logString, category)
    lia.printLog(category, logString)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local charID
    local steamID
    if IsValid(client) then
        local char = client:getChar()
        charID = char and char:getID() or nil
        steamID = client:SteamID()
    end

    lia.db.insertTable({
        timestamp = timestamp,
        gamemode = engine.ActiveGamemode(),
        category = category,
        message = logString,
        charID = charID,
        steamID = steamID
    }, nil, "logs")
end
