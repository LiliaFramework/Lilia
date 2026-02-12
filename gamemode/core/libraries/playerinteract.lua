--[[
    Folder: Libraries
    File: playerinteract.md
]]
--[[
    Player Interaction

    Player-to-player and entity interaction management system for the Lilia framework.
]]
--[[
    Overview:
        The player interaction library provides comprehensive functionality for managing player interactions and actions within the Lilia framework. It handles the creation, registration, and execution of various interaction types including player-to-player interactions, entity interactions, and personal actions. The library operates on both server and client sides, with the server managing interaction registration and validation, while the client handles UI display and user input. It includes range checking, timed actions, and network synchronization to ensure consistent interaction behavior across all clients. The library supports both immediate and delayed actions with progress indicators, making it suitable for complex interaction systems like money transfers, voice changes, and other gameplay mechanics.
]]
local VOICE_WHISPERING = "whispering"
local VOICE_TALKING = "talking"
local VOICE_YELLING = "yelling"
lia.playerinteract = lia.playerinteract or {}
lia.playerinteract.stored = lia.playerinteract.stored or {}
lia.playerinteract.categories = lia.playerinteract.categories or {}
lia.playerinteract._lastSyncInteractionCount = lia.playerinteract._lastSyncInteractionCount or 0
lia.playerinteract._lastSyncCategoryCount = lia.playerinteract._lastSyncCategoryCount or 0
--[[
    Purpose:
        Check if a client is within a usable range of an entity.

    When Called:
        Before running interaction logic or building interaction menus.

    Parameters:
        client (Player)
            The player attempting the interaction.
        entity (Entity)
            Target entity to test.
        customRange (number|nil)
            Optional override distance in Hammer units (default 100).

    Returns:
        boolean
            true if both are valid and distance is within range.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Validate a timed hack action before starting the progress bar.
            local function tryHackDoor(client, door)
                if not lia.playerinteract.isWithinRange(client, door, 96) then
                    client:notifyLocalized("tooFarAway")
                    return
                end
                client:setAction("@hackingDoor", 5, function()
                    if IsValid(door) then door:Fire("Unlock") end
                end)
            end
        ```
]]
function lia.playerinteract.isWithinRange(client, entity, customRange)
    if not IsValid(client) or not IsValid(entity) then return false end
    local range = customRange or 100
    return entity:GetPos():DistToSqr(client:GetPos()) < range * range
end

--[[
    Purpose:
        Collect interaction options for the entity the player is aiming at.

    When Called:
        When opening the interaction menu (TAB keybind) to populate entries.

    Parameters:
        client (Player|nil)
            Player to use for trace; defaults to LocalPlayer on client.

    Returns:
        table
            Map of interaction name → data filtered for the target.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Server: send only valid interactions for the traced entity.
            net.Receive("liaRequestInteractOptions", function(_, ply)
                local interactions = lia.playerinteract.getInteractions(ply)
                local categorized = lia.playerinteract.getCategorizedOptions(interactions)
                lia.net.writeBigTable(ply, "liaInteractionOptions", categorized)
            end)
        ```
]]
function lia.playerinteract.getInteractions(client)
    client = client or LocalPlayer()
    local ent = client:getTracedEntity(100)
    if not IsValid(ent) then return {} end
    local interactions = {}
    local isPlayerTarget = ent:IsPlayer()
    for name, opt in pairs(lia.playerinteract.stored) do
        if opt.type == "interaction" then
            local targetType = opt.target or "player"
            local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
            if targetMatches and (not opt.shouldShow or opt.shouldShow(client, ent)) then interactions[name] = opt end
        end
    end
    return interactions
end

--[[
    Purpose:
        Gather personal actions that do not require a target entity.

    When Called:
        When opening the personal actions menu (G keybind).

    Parameters:
        client (Player|nil)
            Player to evaluate; defaults to LocalPlayer on client.

    Returns:
        table
            Map of action name → data available for this player.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Filter actions for a character sheet panel.
            local actions = lia.playerinteract.getActions(ply)
            for name, data in pairs(actions) do
                if name:find("changeTo") then
                    -- add a voice toggle button
                end
            end
        ```
]]
function lia.playerinteract.getActions(client)
    client = client or LocalPlayer()
    if not IsValid(client) or not client:getChar() then return {} end
    local actions = {}
    for name, opt in pairs(lia.playerinteract.stored) do
        if opt.type == "action" and (not opt.shouldShow or opt.shouldShow(client)) then actions[name] = opt end
    end
    return actions
end

--[[
    Purpose:
        Transform option map into a categorized, ordered list for UI display.

    When Called:
        Before rendering interaction/action menus that use category headers.

    Parameters:
        options (table)
            Map of name → option entry (expects `opt.category`).

    Returns:
        table
            Array containing category rows followed by option entries.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Build an options array with headers for a custom menu.
            local options = lia.playerinteract.getCategorizedOptions(interactions)
            local panel = vgui.Create("liaOptionsPanel")
            panel:Populate(options)
        ```
]]
function lia.playerinteract.getCategorizedOptions(options)
    local categorized = {}
    local categories = {}
    for _, entry in pairs(options) do
        local category = entry.opt and entry.opt.category or L("categoryUnsorted")
        if not categories[category] then categories[category] = {} end
        table.insert(categories[category], entry)
    end

    local sortedCategories = {}
    for categoryName, _ in pairs(categories) do
        table.insert(sortedCategories, categoryName)
    end

    table.sort(sortedCategories, function(a, b)
        if a == L("categoryUnsorted") then return false end
        if b == L("categoryUnsorted") then return true end
        return a < b
    end)

    for _, categoryName in ipairs(sortedCategories) do
        local categoryData = lia.playerinteract.categories[categoryName]
        local categoryColor = categoryData and categoryData.color or (lia.color.theme and lia.color.theme.category_accent or Color(100, 150, 200, 255))
        table.insert(categorized, {
            isCategory = true,
            name = categoryName,
            color = categoryColor,
            count = #categories[categoryName]
        })

        for _, entry in ipairs(categories[categoryName]) do
            table.insert(categorized, entry)
        end
    end
    return categorized
end

if SERVER then
    --[[
    Purpose:
        Register a targeted interaction and ensure timed actions wrap onRun.

    When Called:
        Server startup or dynamically when new context interactions are added.

    Parameters:
        name (string)
            Unique interaction key.
        data (table)
            Fields: `onRun`, `shouldShow`, `range`, `target`, `category`,
            `timeToComplete`, `actionText`, `targetActionText`, etc.
    Realm:
        Server

    Example Usage:
        ```lua
            lia.playerinteract.addInteraction("zipTie", {
                target = "player",
                range = 96,
                category = "categoryRestraint",
                timeToComplete = 4,
                actionText = "@tying",
                targetActionText = "@beingTied",
                shouldShow = function(client, target)
                    return target:IsPlayer() and not target:getNetVar("ziptied")
                end,
                onRun = function(client, target)
                    target:setNetVar("ziptied", true)
                end
            })
        ```
]]
    function lia.playerinteract.addInteraction(name, data)
        data.type = "interaction"
        data.range = data.range or 100
        data.category = data.category or L("categoryUnsorted")
        data.target = data.target or "player"
        data.timeToComplete = data.timeToComplete or nil
        data.actionText = data.actionText or nil
        data.targetActionText = data.targetActionText or nil
        if data.shouldShow then data.shouldShowName = name end
        if data.onRun and data.timeToComplete and (data.actionText or data.targetActionText) then
            local originalOnRun = data.onRun
            data.onRun = function(client, target)
                if data.actionText then client:setAction(data.actionText, data.timeToComplete, function() originalOnRun(client, target) end) end
                if data.targetActionText and IsValid(target) and target:IsPlayer() then target:setAction(data.targetActionText, data.timeToComplete) end
                if not data.actionText then originalOnRun(client, target) end
            end
        end

        lia.playerinteract.stored[name] = data
        if not lia.playerinteract.categories[data.category] then
            lia.playerinteract.categories[data.category] = {
                name = data.category,
                color = data.categoryColor or (lia.color.theme and lia.color.theme.category_accent or Color(100, 150, 200, 255))
            }
        end
    end

    --[[
    Purpose:
        Register a self-action (no target) and auto-wrap timed executions.

    When Called:
        Server startup or dynamically to add personal actions/emotes.

    Parameters:
        name (string)
            Unique action key.
        data (table)
            Fields similar to interactions but no target differentiation.
    Realm:
        Server

    Example Usage:
        ```lua
            lia.playerinteract.addAction("wave", {
                category = "categoryEmotes",
                timeToComplete = 1,
                actionText = "@gesturing",
                onRun = function(client)
                    client:DoAnimation(ACT_GMOD_GESTURE_WAVE)
                end
            })
        ```
]]
    function lia.playerinteract.addAction(name, data)
        data.type = "action"
        data.range = data.range or 100
        data.category = data.category or L("categoryUnsorted")
        data.timeToComplete = data.timeToComplete or nil
        data.actionText = data.actionText or nil
        data.targetActionText = data.targetActionText or nil
        if data.shouldShow then data.shouldShowName = name end
        if data.onRun and data.timeToComplete and (data.actionText or data.targetActionText) then
            local originalOnRun = data.onRun
            data.onRun = function(client, target)
                if data.actionText then client:setAction(data.actionText, data.timeToComplete, function() originalOnRun(client, target) end) end
                if data.targetActionText and IsValid(target) and target:IsPlayer() then target:setAction(data.targetActionText, data.timeToComplete) end
                if not data.actionText then originalOnRun(client, target) end
            end
        end

        lia.playerinteract.stored[name] = data
        if not lia.playerinteract.categories[data.category] then
            lia.playerinteract.categories[data.category] = {
                name = data.category,
                color = data.categoryColor or (lia.color.theme and lia.color.theme.category_accent or Color(100, 150, 200, 255))
            }
        end
    end

    --[[
    Purpose:
        Push registered interactions/actions and categories to clients.

    When Called:
        After definitions change or when a player joins to keep menus current.

    Parameters:
        client (Player|nil)
            Send to one player if provided; otherwise broadcast in batches.
    Realm:
        Server

    Example Usage:
        ```lua
            if lia.playerinteract.hasChanges() then
                lia.playerinteract.sync() -- broadcast updates
            end
        ```
]]
    function lia.playerinteract.sync(client)
        local filteredData = {}
        for name, data in pairs(lia.playerinteract.stored) do
            filteredData[name] = {
                type = data.type,
                serverOnly = data.serverOnly and true or false,
                name = name,
                range = data.range,
                category = data.category or L("categoryUnsorted"),
                target = data.target,
                timeToComplete = data.timeToComplete,
                actionText = data.actionText,
                targetActionText = data.targetActionText
            }
        end

        if client then
            lia.net.writeBigTable(client, "liaPlayerInteractSync", filteredData)
            lia.net.writeBigTable(client, "liaPlayerInteractCategories", lia.playerinteract.categories)
        else
            lia.playerinteract._lastSyncInteractionCount = table.Count(lia.playerinteract.stored)
            lia.playerinteract._lastSyncCategoryCount = table.Count(lia.playerinteract.categories)
            local players = player.GetAll()
            local batchSize = 3
            local delay = 0
            for i = 1, #players, batchSize do
                timer.Simple(delay, function()
                    local batch = {}
                    for j = i, math.min(i + batchSize - 1, #players) do
                        table.insert(batch, players[j])
                    end

                    for _, ply in ipairs(batch) do
                        if IsValid(ply) then
                            lia.net.writeBigTable(ply, "liaPlayerInteractSync", filteredData)
                            lia.net.writeBigTable(ply, "liaPlayerInteractCategories", lia.playerinteract.categories)
                        end
                    end
                end)

                delay = delay + 0.15
            end
        end
    end

    --[[
    Purpose:
        Determine if interaction/action definitions changed since last sync.

    When Called:
        Prior to syncing to avoid unnecessary network traffic.

    Parameters:
        None

    Returns:
        boolean
            true when counts differ from the last broadcast.

    Realm:
        Server

    Example Usage:
        ```lua
            if lia.playerinteract.hasChanges() then
                lia.playerinteract.sync()
            end
        ```
]]
    function lia.playerinteract.hasChanges()
        local currentInteractionCount = table.Count(lia.playerinteract.stored)
        local currentCategoryCount = table.Count(lia.playerinteract.categories)
        return currentInteractionCount ~= lia.playerinteract._lastSyncInteractionCount or currentCategoryCount ~= lia.playerinteract._lastSyncCategoryCount
    end

    lia.playerinteract.addInteraction("giveMoney", {
        serverOnly = true,
        shouldShow = function(client, target) return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0 end,
        onRun = function(client, target)
            client:requestString("@giveMoney", "@enterAmount", function(amount)
                local originalAmount = tonumber(amount) or 0
                amount = math.floor(originalAmount)
                if originalAmount ~= amount and originalAmount > 0 then
                    lia.log.add(client, "moneyDupeAttempt", "Attempted to give " .. tostring(originalAmount) .. " money (floored to " .. amount .. ")")
                    for _, admin in player.Iterator() do
                        if admin:IsAdmin() then admin:notifyLocalized("moneyDupeAttempt", client:Name(), "givemoney", tostring(originalAmount), tostring(amount)) end
                    end
                end

                if not amount or amount <= 0 then
                    client:notifyErrorLocalized("invalidAmount")
                    return
                end

                if not IsValid(client) or not client:getChar() then return end
                if client:isFamilySharedAccount() and not lia.config.get("AltsDisabled", false) then
                    client:notifyErrorLocalized("familySharedMoneyTransferDisabled")
                    return
                end

                if not IsValid(target) or not target:IsPlayer() or not target:getChar() then return end
                if not client:getChar():hasMoney(amount) then
                    client:notifyErrorLocalized("notEnoughMoney")
                    return
                end

                target:getChar():giveMoney(amount)
                client:getChar():takeMoney(amount)
                local senderName = client:getChar():getDisplayedName(target)
                local targetName = client:getChar():getDisplayedName(client)
                client:notifyMoneyLocalized("moneyTransferSent", lia.currency.get(amount), targetName)
                target:notifyMoneyLocalized("moneyTransferReceived", lia.currency.get(amount), senderName)
                client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
            end, "")
        end
    })

    lia.playerinteract.addAction("changeToWhisper", {
        category = "categoryVoice",
        shouldShow = function(client) return client:getChar() and client:Alive() and client:getLocalVar("VoiceType") ~= L("whispering") end,
        onRun = function(client)
            client:setLocalVar("VoiceType", VOICE_WHISPERING)
            client:notifyInfoLocalized("voiceModeSet", L("whispering"))
            hook.Run("OnVoiceTypeChanged", client)
        end,
        serverOnly = true
    })

    lia.playerinteract.addAction("changeToTalk", {
        category = "categoryVoice",
        shouldShow = function(client) return client:getChar() and client:Alive() and client:getLocalVar("VoiceType") ~= VOICE_TALKING end,
        onRun = function(client)
            client:setLocalVar("VoiceType", VOICE_TALKING)
            client:notifyInfoLocalized("voiceModeSet", L("talking"))
            hook.Run("OnVoiceTypeChanged", client)
        end,
        serverOnly = true
    })

    lia.playerinteract.addAction("changeToYell", {
        category = "categoryVoice",
        shouldShow = function(client) return client:getChar() and client:Alive() and client:getLocalVar("VoiceType") ~= VOICE_YELLING end,
        onRun = function(client)
            client:setLocalVar("VoiceType", VOICE_YELLING)
            client:notifyInfoLocalized("voiceModeSet", L("yelling"))
            hook.Run("OnVoiceTypeChanged", client)
        end,
        serverOnly = true
    })
else
    --[[
    Purpose:
        Open the interaction or personal action menu on the client.

    When Called:
        After receiving options from the server or when keybind handlers fire.

    Parameters:
        options (table)
            Array of option entries plus category rows.
        isInteraction (boolean)
            true for interaction mode; false for personal actions.
        titleText (string|nil)
            Optional menu title override.
        closeKey (number|nil)
            Optional key code to close the menu.
        netMsg (string|nil)
            Net message name to send selections with.
        preFiltered (boolean|nil)
            If true, options are already filtered for target/range visibility.

    Returns:
        Panel|nil
            The created menu panel.

    Realm:
        Client

    Example Usage:
        ```lua
            net.Receive("liaSendInteractOptions", function()
                local data = lia.net.readBigTable()
                local categorized = lia.playerinteract.getCategorizedOptions(data)
                lia.playerinteract.openMenu(categorized, true, L("interactionMenu"))
            end)
        ```
]]
    function lia.playerinteract.openMenu(options, isInteraction, titleText, closeKey, netMsg, preFiltered)
        local client = LocalPlayer()
        if not IsValid(client) then return end
        local ent = isfunction(client.getTracedEntity) and client:getTracedEntity(100) or NULL
        return lia.derma.optionsMenu(options, {
            mode = isInteraction and "interaction" or "action",
            title = titleText,
            closeKey = closeKey,
            netMsg = netMsg,
            preFiltered = preFiltered,
            entity = ent
        })
    end

    lia.net.readBigTable("liaPlayerInteractSync", function(data)
        if not istable(data) then return end
        local newStored = {}
        for name, incoming in pairs(data) do
            local localEntry = lia.playerinteract.stored[name] or {}
            local merged = table.Copy(localEntry)
            merged.type = incoming.type or localEntry.type
            merged.serverOnly = incoming.serverOnly and true or false
            merged.name = name
            merged.category = incoming.category or localEntry.category or L("categoryUnsorted")
            if incoming.range ~= nil then merged.range = incoming.range end
            merged.target = incoming.target or localEntry.target or "player"
            if incoming.timeToComplete ~= nil then merged.timeToComplete = incoming.timeToComplete end
            if incoming.actionText ~= nil then merged.actionText = incoming.actionText end
            if incoming.targetActionText ~= nil then merged.targetActionText = incoming.targetActionText end
            merged.onRun = localEntry.onRun
            newStored[name] = merged
        end

        lia.playerinteract.stored = newStored
    end)

    lia.net.readBigTable("liaPlayerInteractCategories", function(data) if istable(data) then lia.playerinteract.categories = data end end)
    timer.Simple(0.1, function()
        if lia.gui then
            for key, panel in pairs(lia.gui) do
                if IsValid(panel) and panel.Remove then panel:Remove() end
                lia.gui[key] = nil
            end
        end

        local world = vgui.GetWorldPanel()
        if IsValid(world) then
            local children = world:GetChildren()
            for _, panel in ipairs(children) do
                if IsValid(panel) then
                    local initInfo = panel.Init and debug.getinfo(panel.Init, "Sln")
                    local src = initInfo and initInfo.short_src or ""
                    if not (src:find("chatbox") or src:find("spawnmenu") or src:find("creationmenu") or src:find("controlpanel")) then panel:Remove() end
                end
            end
        end
    end)

    if lia.playerinteract.stored then table.Empty(lia.playerinteract.stored) end
    if lia.playerinteract.categories then table.Empty(lia.playerinteract.categories) end
end

lia.keybind.add("interactionMenu", {
    keyBind = KEY_TAB,
    desc = L("interactionMenuDesc"),
    category = "Core",
    onPress = function()
        net.Start("liaRequestInteractOptions")
        net.WriteString("interaction")
        net.SendToServer()
    end,
})

lia.keybind.add("personalActions", {
    keyBind = KEY_G,
    desc = L("personalActionsDesc"),
    category = "Core",
    onPress = function()
        net.Start("liaRequestInteractOptions")
        net.WriteString("action")
        net.SendToServer()
    end,
})
