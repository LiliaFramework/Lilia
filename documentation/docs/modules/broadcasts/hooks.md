# Hooks

This document describes the hooks available in the Broadcasts module for managing class and faction broadcast systems.

---

## ClassBroadcastLogged

**Purpose**

Called when a class broadcast is logged to the server logs.

**Parameters**

* `client` (*Player*): The player who sent the broadcast.
* `message` (*string*): The broadcast message content.
* `classList` (*table*): Array of class names that received the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The broadcast has been sent to all target players
- The broadcast has been logged via `lia.log.add()`

**Example Usage**

```lua
-- Track broadcast statistics
hook.Add("ClassBroadcastLogged", "TrackBroadcastStats", function(client, message, classList)
    local char = client:getChar()
    if char then
        local broadcasts = char:getData("class_broadcasts_sent", 0)
        char:setData("class_broadcasts_sent", broadcasts + 1)
        
        -- Track message length
        local avgLength = char:getData("avg_broadcast_length", 0)
        local newAvg = (avgLength * broadcasts + #message) / (broadcasts + 1)
        char:setData("avg_broadcast_length", newAvg)
    end
end)

-- Send to external logging system
hook.Add("ClassBroadcastLogged", "ExternalLogging", function(client, message, classList)
    local data = {
        type = "class_broadcast",
        sender = client:SteamID(),
        sender_name = client:Name(),
        message = message,
        targets = classList,
        timestamp = os.time()
    }
    
    http.Post("https://your-logging-service.com/broadcasts", data, function(response)
        print("Class broadcast logged to external system")
    end)
end)

-- Notify administrators of broadcasts
hook.Add("ClassBroadcastLogged", "NotifyAdmins", function(client, message, classList)
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " sent class broadcast to " .. table.concat(classList, ", ") .. ": " .. message)
        end
    end
end)
```

---

## ClassBroadcastMenuClosed

**Purpose**

Called when the class broadcast selection menu is closed.

**Parameters**

* `client` (*Player*): The player who closed the menu.
* `selectedOptions` (*table*): Array of selected class options.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The player makes their selection from the class broadcast menu
- Before the broadcast is processed

**Example Usage**

```lua
-- Track menu usage
hook.Add("ClassBroadcastMenuClosed", "TrackMenuUsage", function(client, selectedOptions)
    local char = client:getChar()
    if char then
        local menuUses = char:getData("broadcast_menu_uses", 0)
        char:setData("broadcast_menu_uses", menuUses + 1)
        
        -- Track selection patterns
        local selections = char:getData("class_selections", {})
        for _, option in ipairs(selectedOptions) do
            selections[option] = (selections[option] or 0) + 1
        end
        char:setData("class_selections", selections)
    end
end)

-- Validate selections
hook.Add("ClassBroadcastMenuClosed", "ValidateSelections", function(client, selectedOptions)
    if #selectedOptions == 0 then
        client:notify("No classes selected!")
        return false
    end
    
    if #selectedOptions > 5 then
        client:notify("Too many classes selected! Maximum 5 allowed.")
        return false
    end
end)

-- Log menu closure
hook.Add("ClassBroadcastMenuClosed", "LogMenuClosure", function(client, selectedOptions)
    lia.log.add(client, "classBroadcastMenuClosed", #selectedOptions .. " classes selected")
end)
```

---

## ClassBroadcastMenuOpened

**Purpose**

Called when the class broadcast selection menu is opened.

**Parameters**

* `client` (*Player*): The player who opened the menu.
* `options` (*table*): Array of available class options.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `classbroadcast` command is executed
- Before the menu is displayed to the client

**Example Usage**

```lua
-- Track menu opening
hook.Add("ClassBroadcastMenuOpened", "TrackMenuOpening", function(client, options)
    local char = client:getChar()
    if char then
        char:setData("last_broadcast_menu", os.time())
        char:setData("available_classes", #options)
    end
    
    lia.log.add(client, "classBroadcastMenuOpened", #options .. " classes available")
end)

-- Filter available options
hook.Add("ClassBroadcastMenuOpened", "FilterOptions", function(client, options)
    local char = client:getChar()
    if char and char:getData("restricted_classes", false) then
        -- Remove restricted classes from options
        local restricted = char:getData("restricted_class_list", {})
        for i = #options, 1, -1 do
            for _, restrictedClass in ipairs(restricted) do
                if string.find(options[i], restrictedClass) then
                    table.remove(options, i)
                    break
                end
            end
        end
    end
end)

-- Apply menu restrictions
hook.Add("ClassBroadcastMenuOpened", "ApplyRestrictions", function(client, options)
    -- Check cooldown
    local lastBroadcast = client:getData("last_class_broadcast", 0)
    if os.time() - lastBroadcast < 300 then -- 5 minute cooldown
        client:notify("Please wait before sending another class broadcast!")
        return false
    end
end)
```

---

## ClassBroadcastSent

**Purpose**

Called when a class broadcast has been successfully sent to all target players.

**Parameters**

* `client` (*Player*): The player who sent the broadcast.
* `message` (*string*): The broadcast message content.
* `classList` (*table*): Array of class names that received the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The broadcast has been sent to all target players
- Before the success notification is sent to the client

**Example Usage**

```lua
-- Apply post-send effects
hook.Add("ClassBroadcastSent", "PostSendEffects", function(client, message, classList)
    -- Play success sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 1, 0)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos() + Vector(0, 0, 50))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track successful broadcasts
hook.Add("ClassBroadcastSent", "TrackSuccessfulBroadcasts", function(client, message, classList)
    local char = client:getChar()
    if char then
        local successful = char:getData("successful_class_broadcasts", 0)
        char:setData("successful_class_broadcasts", successful + 1)
        
        -- Track reach
        local totalReach = char:getData("total_class_reach", 0)
        char:setData("total_class_reach", totalReach + #classList)
    end
end)

-- Award achievements
hook.Add("ClassBroadcastSent", "BroadcastAchievements", function(client, message, classList)
    local char = client:getChar()
    if char then
        local broadcasts = char:getData("successful_class_broadcasts", 0)
        
        if broadcasts == 1 then
            client:notify("Achievement: First Class Broadcast!")
        elseif broadcasts == 10 then
            client:notify("Achievement: Class Communicator!")
        elseif broadcasts == 50 then
            client:notify("Achievement: Class Broadcast Master!")
        end
    end
end)
```

---

## FactionBroadcastLogged

**Purpose**

Called when a faction broadcast is logged to the server logs.

**Parameters**

* `client` (*Player*): The player who sent the broadcast.
* `message` (*string*): The broadcast message content.
* `factionList` (*table*): Array of faction names that received the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The broadcast has been sent to all target players
- The broadcast has been logged via `lia.log.add()`

**Example Usage**

```lua
-- Track faction broadcast statistics
hook.Add("FactionBroadcastLogged", "TrackFactionBroadcastStats", function(client, message, factionList)
    local char = client:getChar()
    if char then
        local broadcasts = char:getData("faction_broadcasts_sent", 0)
        char:setData("faction_broadcasts_sent", broadcasts + 1)
        
        -- Track faction reach
        for _, faction in ipairs(factionList) do
            local factionReach = char:getData("faction_reach_" .. faction, 0)
            char:setData("faction_reach_" .. faction, factionReach + 1)
        end
    end
end)

-- Send to external monitoring
hook.Add("FactionBroadcastLogged", "ExternalMonitoring", function(client, message, factionList)
    local data = {
        type = "faction_broadcast",
        sender = client:SteamID(),
        sender_name = client:Name(),
        message = message,
        targets = factionList,
        timestamp = os.time()
    }
    
    http.Post("https://your-monitoring-service.com/faction-broadcasts", data, function(response)
        print("Faction broadcast sent to monitoring system")
    end)
end)

-- Alert high-priority factions
hook.Add("FactionBroadcastLogged", "AlertHighPriorityFactions", function(client, message, factionList)
    local highPriorityFactions = {"police", "government", "military"}
    
    for _, faction in ipairs(factionList) do
        for _, priorityFaction in ipairs(highPriorityFactions) do
            if string.find(string.lower(faction), priorityFaction) then
                lia.log.add(client, "highPriorityFactionBroadcast", faction, message)
                break
            end
        end
    end
end)
```

---

## FactionBroadcastMenuClosed

**Purpose**

Called when the faction broadcast selection menu is closed.

**Parameters**

* `client` (*Player*): The player who closed the menu.
* `selectedOptions` (*table*): Array of selected faction options.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The player makes their selection from the faction broadcast menu
- Before the broadcast is processed

**Example Usage**

```lua
-- Track faction menu usage
hook.Add("FactionBroadcastMenuClosed", "TrackFactionMenuUsage", function(client, selectedOptions)
    local char = client:getChar()
    if char then
        local menuUses = char:getData("faction_broadcast_menu_uses", 0)
        char:setData("faction_broadcast_menu_uses", menuUses + 1)
        
        -- Track faction selection patterns
        local selections = char:getData("faction_selections", {})
        for _, option in ipairs(selectedOptions) do
            selections[option] = (selections[option] or 0) + 1
        end
        char:setData("faction_selections", selections)
    end
end)

-- Validate faction selections
hook.Add("FactionBroadcastMenuClosed", "ValidateFactionSelections", function(client, selectedOptions)
    if #selectedOptions == 0 then
        client:notify("No factions selected!")
        return false
    end
    
    -- Check for conflicting factions
    local conflictingFactions = {"police", "criminal"}
    local hasPolice = false
    local hasCriminal = false
    
    for _, option in ipairs(selectedOptions) do
        if string.find(string.lower(option), "police") then hasPolice = true end
        if string.find(string.lower(option), "criminal") then hasCriminal = true end
    end
    
    if hasPolice and hasCriminal then
        client:notify("Cannot broadcast to both police and criminal factions!")
        return false
    end
end)

-- Log faction menu closure
hook.Add("FactionBroadcastMenuClosed", "LogFactionMenuClosure", function(client, selectedOptions)
    lia.log.add(client, "factionBroadcastMenuClosed", #selectedOptions .. " factions selected")
end)
```

---

## FactionBroadcastMenuOpened

**Purpose**

Called when the faction broadcast selection menu is opened.

**Parameters**

* `client` (*Player*): The player who opened the menu.
* `options` (*table*): Array of available faction options.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `factionbroadcast` command is executed
- Before the menu is displayed to the client

**Example Usage**

```lua
-- Track faction menu opening
hook.Add("FactionBroadcastMenuOpened", "TrackFactionMenuOpening", function(client, options)
    local char = client:getChar()
    if char then
        char:setData("last_faction_broadcast_menu", os.time())
        char:setData("available_factions", #options)
    end
    
    lia.log.add(client, "factionBroadcastMenuOpened", #options .. " factions available")
end)

-- Filter faction options based on player permissions
hook.Add("FactionBroadcastMenuOpened", "FilterFactionOptions", function(client, options)
    local char = client:getChar()
    if char then
        local faction = char:getFaction()
        
        -- Remove own faction from options (can't broadcast to self)
        for i = #options, 1, -1 do
            if string.find(options[i], faction) then
                table.remove(options, i)
            end
        end
        
        -- Check for restricted factions
        local restrictedFactions = char:getData("restricted_factions", {})
        for i = #options, 1, -1 do
            for _, restricted in ipairs(restrictedFactions) do
                if string.find(options[i], restricted) then
                    table.remove(options, i)
                    break
                end
            end
        end
    end
end)

-- Apply faction-specific restrictions
hook.Add("FactionBroadcastMenuOpened", "ApplyFactionRestrictions", function(client, options)
    local char = client:getChar()
    if char then
        local faction = char:getFaction()
        
        -- Check faction-specific cooldowns
        local lastBroadcast = char:getData("last_faction_broadcast", 0)
        local cooldown = 600 -- 10 minutes for faction broadcasts
        
        if os.time() - lastBroadcast < cooldown then
            client:notify("Please wait before sending another faction broadcast!")
            return false
        end
    end
end)
```

---

## FactionBroadcastSent

**Purpose**

Called when a faction broadcast has been successfully sent to all target players.

**Parameters**

* `client` (*Player*): The player who sent the broadcast.
* `message` (*string*): The broadcast message content.
* `factionList` (*table*): Array of faction names that received the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The broadcast has been sent to all target players
- Before the success notification is sent to the client

**Example Usage**

```lua
-- Apply post-send effects for faction broadcasts
hook.Add("FactionBroadcastSent", "PostFactionSendEffects", function(client, message, factionList)
    -- Play faction-specific sound
    client:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply faction-specific screen effect
    local char = client:getChar()
    if char then
        local faction = char:getFaction()
        local color = Color(255, 255, 255, 10)
        
        if faction == "police" then
            color = Color(0, 0, 255, 10)
        elseif faction == "criminal" then
            color = Color(255, 0, 0, 10)
        end
        
        client:ScreenFade(SCREENFADE.IN, color, 1, 0)
    end
end)

-- Track successful faction broadcasts
hook.Add("FactionBroadcastSent", "TrackSuccessfulFactionBroadcasts", function(client, message, factionList)
    local char = client:getChar()
    if char then
        local successful = char:getData("successful_faction_broadcasts", 0)
        char:setData("successful_faction_broadcasts", successful + 1)
        
        -- Track cross-faction communication
        local ownFaction = char:getFaction()
        local crossFaction = false
        for _, faction in ipairs(factionList) do
            if faction ~= ownFaction then
                crossFaction = true
                break
            end
        end
        
        if crossFaction then
            char:setData("cross_faction_broadcasts", char:getData("cross_faction_broadcasts", 0) + 1)
        end
    end
end)

-- Award faction-specific achievements
hook.Add("FactionBroadcastSent", "FactionBroadcastAchievements", function(client, message, factionList)
    local char = client:getChar()
    if char then
        local broadcasts = char:getData("successful_faction_broadcasts", 0)
        
        if broadcasts == 1 then
            client:notify("Achievement: First Faction Broadcast!")
        elseif broadcasts == 5 then
            client:notify("Achievement: Faction Communicator!")
        elseif broadcasts == 25 then
            client:notify("Achievement: Faction Broadcast Leader!")
        end
    end
end)
```

---

## PreClassBroadcastSend

**Purpose**

Called before a class broadcast is sent to target players.

**Parameters**

* `client` (*Player*): The player who is sending the broadcast.
* `message` (*string*): The broadcast message content.
* `classList` (*table*): Array of class names that will receive the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered when:
- All validations have passed
- Before the broadcast is sent to target players
- Before `ClassBroadcastSent` hook

**Example Usage**

```lua
-- Filter broadcast content
hook.Add("PreClassBroadcastSend", "FilterBroadcastContent", function(client, message, classList)
    -- Check for inappropriate content
    local filteredWords = {"spam", "scam", "hack"}
    
    for _, word in ipairs(filteredWords) do
        if string.find(string.lower(message), word) then
            client:notify("Your broadcast contains inappropriate content!")
            return false
        end
    end
    
    -- Check message length
    if #message > 200 then
        client:notify("Broadcast message too long! Maximum 200 characters.")
        return false
    end
end)

-- Apply pre-send effects
hook.Add("PreClassBroadcastSend", "PreSendEffects", function(client, message, classList)
    -- Notify target classes about incoming broadcast
    for _, ply in player.Iterator() do
        if ply:getChar() then
            local charClass = ply:getChar():getClass()
            for _, className in ipairs(classList) do
                if lia.class.list[charClass] and lia.class.list[charClass].name == className then
                    ply:notify("Incoming class broadcast from " .. client:Name() .. "!")
                    break
                end
            end
        end
    end
end)

-- Track pre-send statistics
hook.Add("PreClassBroadcastSend", "TrackPreSendStats", function(client, message, classList)
    local char = client:getChar()
    if char then
        char:setData("last_class_broadcast", os.time())
        char:setData("last_broadcast_message", message)
        char:setData("last_broadcast_targets", classList)
    end
end)
```

---

## PreFactionBroadcastSend

**Purpose**

Called before a faction broadcast is sent to target players.

**Parameters**

* `client` (*Player*): The player who is sending the broadcast.
* `message` (*string*): The broadcast message content.
* `factionList` (*table*): Array of faction names that will receive the broadcast.

**Realm**

Server.

**When Called**

This hook is triggered when:
- All validations have passed
- Before the broadcast is sent to target players
- Before `FactionBroadcastSent` hook

**Example Usage**

```lua
-- Filter faction broadcast content
hook.Add("PreFactionBroadcastSend", "FilterFactionBroadcastContent", function(client, message, factionList)
    -- Check for sensitive content
    local sensitiveWords = {"classified", "secret", "confidential"}
    
    for _, word in ipairs(sensitiveWords) do
        if string.find(string.lower(message), word) then
            client:notify("Cannot use sensitive words in faction broadcasts!")
            return false
        end
    end
    
    -- Check for faction-specific restrictions
    local char = client:getChar()
    if char then
        local faction = char:getFaction()
        
        -- Police can't broadcast to criminal factions
        if faction == "police" then
            for _, targetFaction in ipairs(factionList) do
                if string.find(string.lower(targetFaction), "criminal") then
                    client:notify("Police cannot broadcast to criminal factions!")
                    return false
                end
            end
        end
    end
end)

-- Apply pre-send effects for faction broadcasts
hook.Add("PreFactionBroadcastSend", "PreFactionSendEffects", function(client, message, factionList)
    -- Notify target factions about incoming broadcast
    for _, ply in player.Iterator() do
        if ply:getChar() then
            local charFaction = ply:getChar():getFaction()
            for _, factionName in ipairs(factionList) do
                if lia.faction.indices[charFaction] and lia.faction.indices[charFaction].name == factionName then
                    ply:notify("Incoming faction broadcast from " .. client:Name() .. "!")
                    break
                end
            end
        end
    end
end)

-- Track pre-send statistics for faction broadcasts
hook.Add("PreFactionBroadcastSend", "TrackPreFactionSendStats", function(client, message, factionList)
    local char = client:getChar()
    if char then
        char:setData("last_faction_broadcast", os.time())
        char:setData("last_faction_broadcast_message", message)
        char:setData("last_faction_broadcast_targets", factionList)
    end
end)
```
