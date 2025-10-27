--[[
    Logger Library

    Comprehensive logging and audit trail system for the Lilia framework.
]]
--[[
    Overview:
    The logger library provides comprehensive logging functionality for the Lilia framework, enabling detailed tracking and recording of player actions, administrative activities, and system events. It operates on the server side and automatically categorizes log entries into predefined categories such as character management, combat, world interactions, chat communications, item transactions, administrative actions, and security events. The library stores all log entries in a database table with timestamps, player information, and categorized messages. It supports dynamic log type registration and provides hooks for external systems to process log events. The logger ensures accountability and provides administrators with detailed audit trails for server management and moderation.
]]
lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
local logTypeData = {
    character = {
        charRecognize = function(client, id, name) return L("logPlayerRecognizedCharacter", client:Name(), id, name) end,
        charCreate = function(client, character) return L("logPlayerCreatedCharacter", client:Name(), character:getName()) end,
        charLoad = function(client, name) return L("logPlayerLoadedCharacter", client:Name(), name) end,
        charDelete = function(client, id)
            local name = IsValid(client) and client:Name() or L("console")
            return L("logPlayerDeletedCharacter", name, id)
        end,
        playerSpawn = function(client) return L("logPlayerSpawned", client:Name()) end,
        charsetmodel = function(client, targetName, newModel, oldModel) return L("logCharSetModel", client:Name(), targetName, oldModel, newModel) end,
        attribSet = function(client, targetName, attrib, value) return L("logAttribSet", client:Name(), targetName, attrib, value) end,
        attribAdd = function(client, targetName, attrib, value) return L("logAttribAdd", client:Name(), value, targetName, attrib) end,
        attribCheck = function(client, targetName) return L("logAttribCheck", client:Name(), targetName) end,
    },
    combat = {
        playerHurt = function(client, attacker, damage, health) return L("logPlayerTookDamage", client:Name(), damage, attacker, health) end,
        playerDeath = function(client, attacker) return L("logPlayerKilled", client:Name(), attacker) end,
        swep_spawning = function(client, swep) return L("logPlayerSpawnedSWEP", client:Name(), swep) end,
    },
    world = {
        spawned_prop = function(client, model) return L("logPlayerSpawnedProp", client:Name(), model) end,
        spawned_ragdoll = function(client, model) return L("logPlayerSpawnedRagdoll", client:Name(), model) end,
        spawned_effect = function(client, effect) return L("logPlayerSpawnedEffect", client:Name(), effect) end,
        spawned_vehicle = function(client, vehicle, model) return L("logPlayerSpawnedVehicle", client:Name(), vehicle, model) end,
        spawned_npc = function(client, npc, model) return L("logPlayerSpawnedNPC", client:Name(), npc, model) end,
        spawned_sent = function(client, class, model) return L("logPlayerSpawnedEntity", client:Name(), class, model) end,
        vehicleEnter = function(client, class, model) return L("logVehicleEnter", client:Name(), class, model) end,
        vehicleExit = function(client, class, model) return L("logVehicleExit", client:Name(), class, model) end,
    },
    tools = {
        physgunPickup = function(client, class, model) return L("logPhysgunPickup", client:Name(), class, model) end,
        physgunDrop = function(client, class, model) return L("logPhysgunDrop", client:Name(), class, model) end,
        physgunFreeze = function(client, class, model) return L("logPhysgunFreeze", client:Name(), class, model) end,
        toolgunUse = function(client, tool) return L("logToolgunUse", client:Name(), tool) end,
    },
    chat = {
        chat = function(client, chatType, message) return L("logChatMessage", chatType, client:Name(), message) end,
        chatOOC = function(client, msg) return L("logChatOOC", client:Name(), msg) end,
        chatLOOC = function(client, msg) return L("logChatLOOC", client:Name(), msg) end,
        command = function(client, text) return L("logCommand", client:Name(), text) end,
    },
    money = {
        money = function(client, amount) return L("logMoneyChange", client:Name(), amount) end,
        moneyPickedUp = function(client, amount) return L("logMoneyPickedUp", client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular) end,
        charSetMoney = function(client, targetName, amount) return L("logCharSetMoney", client:Name(), targetName, lia.currency.get(amount)) end,
        charAddMoney = function(client, targetName, amount, total) return L("logCharAddMoney", client:Name(), targetName, lia.currency.get(amount), lia.currency.get(total)) end,
        moneyDropped = function(client, amount) return L("logMoneyDropped", client:Name(), lia.currency.get(amount)) end,
    },
    items = {
        itemTake = function(client, item) return L("logItemTake", client:Name(), item) end,
        use = function(client, item) return L("logItemUse", client:Name(), item) end,
        itemDrop = function(client, item) return L("logItemDrop", client:Name(), item) end,
        itemInteractionFailed = function(client, action, itemName) return L("logItemInteractionFailed", client:Name(), action, itemName) end,
        itemInteraction = function(client, action, item) return L("logItemInteraction", client:Name(), action, item.name) end,
        itemEquip = function(client, item) return L("logItemEquip", client:Name(), item) end,
        itemUnequip = function(client, item) return L("logItemUnequip", client:Name(), item) end,
        itemTransfer = function(client, itemName, fromID, toID) return L("logItemTransfer", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        itemTransferFailed = function(client, itemName, fromID, toID) return L("logItemTransferFailed", client:Name(), itemName, tostring(fromID), tostring(toID)) end,
        itemCombine = function(client, itemName, targetName) return L("logItemCombine", client:Name(), itemName, targetName) end,
        itemFunction = function(client, action, itemName) return L("logItemFunction", client:Name(), action, itemName) end,
        itemAdded = function(client, itemName) return L("logItemAdded", itemName, IsValid(client) and client:Name() or L("unknown")) end,
        itemCreated = function(_, itemName) return L("logItemCreated", itemName) end,
        itemSpawned = function(_, itemName) return L("logItemSpawned", itemName) end,
        itemDraggedOut = function(client, itemName) return L("logItemDraggedOut", client:Name(), itemName) end,
        spawnItem = function(client, displayName, message) return L("logSpawnItem", client:Name(), displayName, message) end,
        chargiveItem = function(client, itemName, target, message) return L("logCharGiveItem", client:Name(), itemName, target:Name(), message) end,
        vendorAccess = function(client, vendor) return L("logVendorAccess", client:Name(), vendor:getNetVar("name") or L("unknown")) end,
        vendorExit = function(client, vendor) return L("logVendorExit", client:Name(), vendor:getNetVar("name") or L("unknown")) end,
        vendorSell = function(client, item, vendor) return L("logVendorSell", client:Name(), item, vendor:getNetVar("name") or L("unknown")) end,
        vendorEdit = function(client, vendor, key) return L("logVendorEdit", client:Name(), vendor:getNetVar("name") or L("unknown"), key) end,
        vendorBuy = function(client, item, vendor, isFailed)
            if isFailed then
                return L("logVendorBuyFailed", client:Name(), item, vendor:getNetVar("name") or L("unknown"))
            else
                return L("logVendorBuy", client:Name(), item, vendor:getNetVar("name") or L("unknown"))
            end
        end,
        restockvendor = function(client, vendor) return L("logVendorRestock", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown")) end,
        restockallvendors = function(client, count) return L("logVendorsRestockAll", client:Name(), count) end,
        resetvendormoney = function(client, vendor, amount) return L("logVendorMoneyReset", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown"), lia.currency.get(amount)) end,
        resetallvendormoney = function(client, amount, count) return L("logVendorMoneyResetAll", client:Name(), lia.currency.get(amount), count) end,
        restockvendormoney = function(client, vendor, amount) return L("logVendorMoneyRestock", client:Name(), IsValid(vendor) and (vendor:getNetVar("name") or L("unknown")) or L("unknown"), lia.currency.get(amount)) end,
        savevendors = function(client) return L("logVendorsSave", client:Name()) end,
    },
    permissions = {
        permissionDenied = function(client, action) return L("logPermissionDenied", client:Name(), action) end,
        spawnDenied = function(client, objectType, model) return L("logSpawnDenied", client:Name(), objectType, tostring(model)) end,
        toolDenied = function(client, tool) return L("logToolDenied", client:Name(), tool) end,
    },
    admin = {
        observeToggle = function(client, state) return L("logObserveToggle", client:Name(), state) end,
        configChange = function(name, oldValue, value) return L("logConfigChange", name, tostring(oldValue), tostring(value)) end,
        warningIssued = function(client, target, reason, count, index) return L("logWarningIssued", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), reason, count or 0, index or count or 0) end,
        warningRemoved = function(client, target, warning, count, index) return L("logWarningRemoved", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), IsValid(target) and target:Name() or L("na"), warning.reason, count or 0, index or 0) end,
        viewWarns = function(client, target) return L("logViewWarns", client:Name(), IsValid(target) and target:Name() or tostring(target)) end,
        viewWarnsIssued = function(client, target) return L("logViewWarnsIssued", client:Name(), IsValid(target) and target:Name() or tostring(target)) end,
        adminMode = function(client, id, message) return L("logAdminMode", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, id) end,
        forceSay = function(client, targetName, message) return L("logForceSay", client:Name(), targetName, message) end,
        flagGive = function(client, targetName, flags) return L("logFlagGive", client:Name(), targetName, flags) end,
        flagGiveAll = function(client, targetName) return L("logFlagGiveAll", client:Name(), targetName) end,
        flagTake = function(client, targetName, flags) return L("logFlagTake", client:Name(), targetName, flags) end,
        flagTakeAll = function(client, targetName) return L("logFlagTakeAll", client:Name(), targetName) end,
        voiceToggle = function(client, targetName, state) return L("logVoiceToggle", client:Name(), targetName, state) end,
        charBan = function(client, targetName) return L("logCharBan", client:Name(), targetName) end,
        charUnban = function(client, targetName) return L("logCharUnban", client:Name(), targetName) end,
        charKick = function(client, targetName) return L("logCharKick", client:Name(), targetName) end,
        sitRoomSet = function(client, pos, message) return L("sitroomSetLog", os.date("%Y-%m-%d %H:%M:%S"), client:Name(), message, pos) end,
        sitRoomRenamed = function(client, details) return L("sitroomRenamedLog", client:Name(), details) end,
        sitRoomRepositioned = function(client, details) return L("sitroomRepositionedLog", client:Name(), details) end,
        sendToSitRoom = function(client, targetName, roomName)
            if targetName == client:Name() then return L("sitroomTeleportedLog", client:Name(), roomName) end
            return L("sitroomSentLog", client:Name(), targetName, roomName)
        end,
        sitRoomReturn = function(client, targetName)
            if targetName == client:Name() then return L("sitroomReturnSelfLog", client:Name()) end
            return L("sitroomReturnOtherLog", client:Name(), targetName)
        end,
        returnItems = function(client, targetName) return L("logReturnItems", client:Name(), targetName) end,
        banOOC = function(client, targetName, steamID) return L("logBanOOC", client:Name(), targetName, steamID) end,
        unbanOOC = function(client, targetName, steamID) return L("logUnbanOOC", client:Name(), targetName, steamID) end,
        blockOOC = function(client, state) return L("logBlockOOC", client:Name(), state and L("blocked") or L("unblocked")) end,
        clearChat = function(client) return L("logClearChat", client:Name()) end,
        altKicked = function(_, name, steamID) return L("logAltKicked", name, steamID) end,
        altBanned = function(_, name, steamID) return L("logAltBanned", name, steamID) end,
        plyKick = function(client, targetName) return L("logPlyKick", client:Name(), targetName) end,
        plyBan = function(client, targetName) return L("logPlyBan", client:Name(), targetName) end,
        plyUnban = function(client, targetIdentifier) return L("logPlyUnban", client:Name(), targetIdentifier) end,
        viewPlayerClaims = function(client, targetName) return L("logViewPlayerClaims", client:Name(), targetName) end,
        viewAllClaims = function(client) return L("logViewAllClaims", client:Name()) end,
        viewPlayerTickets = function(client, targetName) return L("logViewPlayerTickets", client:Name(), targetName) end,
        ticketClaimed = function(client, requester, count) return L("logTicketClaimed", client:Name(), requester, count or 0) end,
        ticketClosed = function(client, requester, count) return L("logTicketClosed", client:Name(), requester, count or 0) end,
        plyBring = function(client, targetName) return L("logPlyBring", client:Name(), targetName) end,
        plyGoto = function(client, targetName) return L("logPlyGoto", client:Name(), targetName) end,
        plyReturn = function(client, targetName) return L("logPlyReturn", client:Name(), targetName) end,
        plyJail = function(client, targetName) return L("logPlyJail", client:Name(), targetName) end,
        plyUnjail = function(client, targetName) return L("logPlyUnjail", client:Name(), targetName) end,
        plyKill = function(client, targetName) return L("logPlyKill", client:Name(), targetName) end,
        plySlay = function(client, targetName) return L("logPlySlay", client:Name(), targetName) end,
        plyRespawn = function(client, targetName) return L("logPlyRespawn", client:Name(), targetName) end,
        plyFreeze = function(client, targetName, duration) return L("logPlyFreeze", client:Name(), targetName, tostring(duration)) end,
        plyUnfreeze = function(client, targetName) return L("logPlyUnfreeze", client:Name(), targetName) end,
        plyBlind = function(client, targetName, duration) return L("logPlyBlind", client:Name(), targetName, tostring(duration)) end,
        plyUnblind = function(client, targetName) return L("logPlyUnblind", client:Name(), targetName) end,
        plyBlindFade = function(client, targetName, duration, color) return L("logPlyBlindFade", client:Name(), targetName, tostring(duration), color) end,
        blindFadeAll = function(_, duration, color) return L("logBlindFadeAll", tostring(duration), color) end,
        plyGag = function(client, targetName) return L("logPlyGag", client:Name(), targetName) end,
        plyUngag = function(client, targetName) return L("logPlyUngag", client:Name(), targetName) end,
        plyMute = function(client, targetName) return L("logPlyMute", client:Name(), targetName) end,
        plyUnmute = function(client, targetName) return L("logPlyUnmute", client:Name(), targetName) end,
        plyCloak = function(client, targetName) return L("logPlyCloak", client:Name(), targetName) end,
        plyUncloak = function(client, targetName) return L("logPlyUncloak", client:Name(), targetName) end,
        plyGod = function(client, targetName) return L("logPlyGod", client:Name(), targetName) end,
        plyUngod = function(client, targetName) return L("logPlyUngod", client:Name(), targetName) end,
        plyIgnite = function(client, targetName, duration) return L("logPlyIgnite", client:Name(), targetName, tostring(duration)) end,
        plyExtinguish = function(client, targetName) return L("logPlyExtinguish", client:Name(), targetName) end,
        plyStrip = function(client, targetName) return L("logPlyStrip", client:Name(), targetName) end,
        charBanOffline = function(client, charID) return L("logCharBanOffline", client:Name(), tostring(charID)) end,
        charWipe = function(client, targetName, charID) return L("logCharWipe", client:Name(), targetName, charID) end,
        charWipeOffline = function(client, targetName, charID) return L("logCharWipeOffline", client:Name(), targetName, charID) end,
        charUnbanOffline = function(client, charID) return L("logCharUnbanOffline", client:Name(), tostring(charID)) end,
        missingPrivilege = function(client, privilege, playerInfo, groupInfo)
            if client then
                return L("logMissingPrivilege", client:Name(), privilege, playerInfo or "Unknown", groupInfo or "Unknown")
            else
                return L("logMissingPrivilegeNoClient", privilege, playerInfo or "Unknown", groupInfo or "Unknown")
            end
        end,
    },
    factions = {
        plyTransfer = function(client, targetName, oldFaction, newFaction) return L("logPlyTransfer", client:Name(), targetName, oldFaction, newFaction) end,
        plyWhitelist = function(client, targetName, faction) return L("logPlyWhitelist", client:Name(), targetName, faction) end,
        plyUnwhitelist = function(client, targetName, faction) return L("logPlyUnwhitelist", client:Name(), targetName, faction) end,
        beClass = function(client, className) return L("logBeClass", client:Name(), className) end,
        setClass = function(client, targetName, className) return L("logSetClass", client:Name(), targetName, className) end,
        classWhitelist = function(client, targetName, className) return L("logClassWhitelist", client:Name(), targetName, className) end,
        classUnwhitelist = function(client, targetName, className) return L("logClassUnwhitelist", client:Name(), targetName, className) end,
    },
    inventory = {
        invUpdateSize = function(client, targetName, w, h) return L("logInvUpdateSize", client:Name(), targetName, w, h) end,
        invSetSize = function(client, targetName, w, h) return L("logInvSetSize", client:Name(), targetName, w, h) end,
        storageLock = function(client, entClass, state) return L("logStorageLock", client:Name(), state and L("locked") or L("unlocked"), entClass) end,
        storageUnlock = function(client, entClass) return L("logStorageUnlock", client:Name(), entClass) end,
        storageUnlockFailed = function(client, entClass, password) return L("logStorageUnlockFailed", client:Name(), entClass, password) end,
    },
    connections = {
        playerConnect = function(_, name, ip) return L("logPlayerConnecting", name, ip) end,
        playerConnected = function(client) return L("logPlayerConnected", client:Name()) end,
        playerDisconnected = function(client) return L("logPlayerDisconnected", client:Name()) end,
        failedPassword = function(_, steamID, name, svpass, clpass) return L("logFailedPassword", steamID, name, svpass, clpass) end,
        steamIDMissing = function(_, name, steamID) return L("logSteamIDMissing", name, steamID) end,
        steamIDMismatch = function(_, name, realSteamID, sentSteamID) return L("logSteamIDMismatch", name, realSteamID, sentSteamID) end,
    },
    exploits = {
        exploitAttempt = function(_, name, steamID, netMessage) return L("logExploitAttempt", name, steamID, netMessage) end,
        backdoorDetected = function(_, netMessage, file, line)
            if file then return L("logBackdoorDetectedFile", netMessage, file, tostring(line)) end
            return L("logBackdoorDetected", netMessage)
        end,
    },
    cheating = {
        hackAttempt = function(client, netName)
            if netName then return L("logHackAttemptNet", client:Name(), netName) end
            return L("logHackAttempt", client:Name())
        end,
        verifyCheatsOK = function(client) return L("logVerifyCheatsOK", client:Name()) end,
        cheaterBanned = function(_, name, steamID) return L("logCheaterBanned", name, steamID) end,
        cheaterDetected = function(_, name, steamID) return L("logCheaterDetected", name, steamID) end,
        cheaterToggle = function(client, targetName, state) return L("logCheaterToggle", client:Name(), targetName, state) end,
        cheaterAction = function(client, action) return L("logCheaterAction", client:Name(), action) end,
    }
}

local logTypeCategories = {
    character = L("character"),
    combat = L("categoryCombat"),
    world = L("categoryWorld"),
    tools = L("categoryTools"),
    chat = L("categoryChat"),
    money = L("money"),
    items = L("items"),
    permissions = L("modulePermissionsName"),
    admin = L("admin"),
    factions = L("factions"),
    inventory = L("inv"),
    connections = L("categoryConnections"),
    exploits = L("categoryExploits"),
    cheating = L("categoryCheating"),
}

for category, logTypes in pairs(logTypeData) do
    local categoryName = logTypeCategories[category]
    for logType, func in pairs(logTypes) do
        lia.log.types[logType] = {
            func = func,
            category = categoryName
        }
    end
end

--[[
    Purpose: Registers a new log type with a custom formatting function and category
    When Called: When modules or external systems need to add custom log types
    Parameters:
        - logType (string): Unique identifier for the log type
        - func (function): Function that formats the log message, receives client and additional parameters
        - category (string): Category name for organizing log entries
    Returns: None
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Add a basic custom log type
    lia.log.addType("customAction", function(client, action)
        return client:Name() .. " performed " .. action
    end, "Custom")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Add log type with validation and localization
    lia.log.addType("moduleEvent", function(client, moduleName, event, data)
        if not IsValid(client) then return "System: " .. moduleName .. " - " .. event end
        return L("logModuleEvent", client:Name(), moduleName, event, data or "")
    end, "Modules")
    ```

    High Complexity:
    ```lua
    -- High: Add complex log type with multiple parameters and error handling
    lia.log.addType("advancedAction", function(client, target, action, amount, reason)
        local clientName = IsValid(client) and client:Name() or "Console"
        local targetName = IsValid(target) and target:Name() or tostring(target)
        local timestamp = os.date("%H:%M:%S")
        return string.format("[%s] %s %s %s (Amount: %s, Reason: %s)",
            timestamp, clientName, action, targetName, amount or "N/A", reason or "None")
    end, "Advanced")
    ```
]]
--
function lia.log.addType(logType, func, category)
    lia.log.types[logType] = {
        func = func,
        category = category,
    }
end

--[[
    Purpose: Generates a formatted log string from a log type and parameters
    When Called: Internally by lia.log.add() or when manually retrieving log messages
    Parameters:
        - client (Player): The player who triggered the log event (can be nil for system events)
        - logType (string): The log type identifier to format
        - ... (vararg): Additional parameters passed to the log type's formatting function
    Returns:
        - result (string): The formatted log message, or nil if log type doesn't exist or function fails
        - category (string): The category of the log type, or nil if log type doesn't exist
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get a basic log string
    local message, category = lia.log.getString(client, "charCreate", character)
    if message then
        print("Log: " .. message)
    end
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get log string with multiple parameters
    local message, category = lia.log.getString(client, "itemTransfer", itemName, fromID, toID)
    if message then
        hook.Run("CustomLogHandler", message, category)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get log string with error handling and validation
    local function safeGetLogString(client, logType, ...)
        local success, message, category = pcall(lia.log.getString, client, logType, ...)
        if success and message then
            return message, category
        else
            return "Failed to generate log: " .. tostring(logType), "Error"
        end
    end

    local message, category = safeGetLogString(client, "adminAction", target, action, reason)
    ```
]]
--
function lia.log.getString(client, logType, ...)
    local logData = lia.log.types[logType]
    if not logData then return end
    if isfunction(logData.func) then
        local success, result = pcall(logData.func, client, ...)
        if success then return result, logData.category end
    end
end

--[[
    Purpose: Adds a log entry to the database and displays it in the server console
    When Called: When any significant player action or system event occurs that needs logging
    Parameters:
        - client (Player): The player who triggered the log event (can be nil for system events)
        - logType (string): The log type identifier to use for formatting
        - ... (vararg): Additional parameters passed to the log type's formatting function
    Returns: None
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Log a basic player action
    lia.log.add(client, "charCreate", character)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Log with multiple parameters and validation
    if IsValid(target) then
        lia.log.add(client, "itemTransfer", itemName, fromID, toID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Log with conditional parameters and error handling
    local function logAdminAction(client, target, action, reason, amount)
        local logType = "adminAction"
        local params = {target, action}

        if reason then table.insert(params, reason) end
        if amount then table.insert(params, amount) end

        lia.log.add(client, logType, unpack(params))
    end

    logAdminAction(client, target, "kick", "Rule violation", nil)
    ```
]]
--
function lia.log.add(client, logType, ...)
    local logString, category = lia.log.getString(client, logType, ...)
    if not isstring(category) then category = L("uncategorized") end
    if not isstring(logString) then return end
    hook.Run("OnServerLog", client, logType, logString, category)
    MsgC(Color(83, 143, 239), "[LOG] ")
    MsgC(Color(0, 255, 0), "[" .. L("logCategory") .. ": " .. tostring(category) .. "] ")
    MsgC(Color(255, 255, 255), tostring(logString) .. "\n")
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
