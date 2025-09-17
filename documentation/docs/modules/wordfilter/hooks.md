# Hooks

This document describes the hooks available in the Word Filter module for managing chat word filtering and content moderation.

---

## FilterCheckFailed

**Purpose**

Called when a word filter check fails (filtered word detected).

**Parameters**

* `player` (*Player*): The player who used the filtered word.
* `text` (*string*): The original text that was filtered.
* `bad` (*string*): The specific word that was filtered.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's message contains a filtered word
- After `FilteredWordUsed` hook
- After `PostFilterCheck` hook with false result

**Example Usage**

```lua
-- Track filter check failures
hook.Add("FilterCheckFailed", "TrackFilterCheckFailures", function(player, text, bad)
    local char = player:getChar()
    if char then
        local filterFailures = char:getData("filter_check_failures", 0)
        char:setData("filter_check_failures", filterFailures + 1)
        
        -- Track specific filtered words
        local filteredWords = char:getData("filtered_words_used", {})
        filteredWords[bad] = (filteredWords[bad] or 0) + 1
        char:setData("filtered_words_used", filteredWords)
    end
    
    lia.log.add(player, "filterCheckFailed", bad, text)
end)

-- Apply filter failure effects
hook.Add("FilterCheckFailed", "FilterFailureEffects", function(player, text, bad)
    -- Play failure sound
    player:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
    
    -- Notify player
    player:notify("Your message contained a filtered word: " .. bad)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track filter failure patterns
hook.Add("FilterCheckFailed", "TrackFilterFailurePatterns", function(player, text, bad)
    local char = player:getChar()
    if char then
        -- Track failure frequency
        local failureFrequency = char:getData("filter_failure_frequency", 0)
        char:setData("filter_failure_frequency", failureFrequency + 1)
        
        -- Track failure patterns
        local failurePatterns = char:getData("filter_failure_patterns", {})
        table.insert(failurePatterns, {
            word = bad,
            text = text,
            time = os.time()
        })
        char:setData("filter_failure_patterns", failurePatterns)
    end
end)
```

---

## FilterCheckPassed

**Purpose**

Called when a word filter check passes (no filtered words detected).

**Parameters**

* `player` (*Player*): The player whose message passed the filter.
* `text` (*string*): The text that passed the filter.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's message passes the word filter
- After `PostFilterCheck` hook with true result
- When no filtered words are found

**Example Usage**

```lua
-- Track filter check passes
hook.Add("FilterCheckPassed", "TrackFilterCheckPasses", function(player, text)
    local char = player:getChar()
    if char then
        local filterPasses = char:getData("filter_check_passes", 0)
        char:setData("filter_check_passes", filterPasses + 1)
        
        -- Track clean messages
        local cleanMessages = char:getData("clean_messages", 0)
        char:setData("clean_messages", cleanMessages + 1)
    end
end)

-- Apply filter pass effects
hook.Add("FilterCheckPassed", "FilterPassEffects", function(player, text)
    -- Play pass sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.3, 0)
    
    -- Notify player
    player:notify("Message sent successfully!")
end)

-- Track filter pass patterns
hook.Add("FilterCheckPassed", "TrackFilterPassPatterns", function(player, text)
    local char = player:getChar()
    if char then
        -- Track pass frequency
        local passFrequency = char:getData("filter_pass_frequency", 0)
        char:setData("filter_pass_frequency", passFrequency + 1)
        
        -- Track pass patterns
        local passPatterns = char:getData("filter_pass_patterns", {})
        table.insert(passPatterns, {
            text = text,
            time = os.time()
        })
        char:setData("filter_pass_patterns", passPatterns)
    end
end)
```

---

## FilteredWordUsed

**Purpose**

Called when a filtered word is detected in a player's message.

**Parameters**

* `player` (*Player*): The player who used the filtered word.
* `bad` (*string*): The specific word that was filtered.
* `text` (*string*): The original text that contained the filtered word.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's message contains a filtered word
- After `PreFilterCheck` hook
- Before `PostFilterCheck` hook with false result

**Example Usage**

```lua
-- Track filtered word usage
hook.Add("FilteredWordUsed", "TrackFilteredWordUsage", function(player, bad, text)
    local char = player:getChar()
    if char then
        local filteredWordUsage = char:getData("filtered_word_usage", 0)
        char:setData("filtered_word_usage", filteredWordUsage + 1)
        
        -- Track specific filtered words
        local filteredWords = char:getData("filtered_words_used", {})
        filteredWords[bad] = (filteredWords[bad] or 0) + 1
        char:setData("filtered_words_used", filteredWords)
    end
    
    lia.log.add(player, "filteredWordUsed", bad, text)
end)

-- Apply filtered word effects
hook.Add("FilteredWordUsed", "FilteredWordEffects", function(player, bad, text)
    -- Play filtered word sound
    player:EmitSound("buttons/button17.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
    
    -- Notify player
    player:notify("Filtered word detected: " .. bad)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track filtered word patterns
hook.Add("FilteredWordUsed", "TrackFilteredWordPatterns", function(player, bad, text)
    local char = player:getChar()
    if char then
        -- Track filtered word frequency
        local filteredWordFrequency = char:getData("filtered_word_frequency", 0)
        char:setData("filtered_word_frequency", filteredWordFrequency + 1)
        
        -- Track filtered word patterns
        local filteredWordPatterns = char:getData("filtered_word_patterns", {})
        table.insert(filteredWordPatterns, {
            word = bad,
            text = text,
            time = os.time()
        })
        char:setData("filtered_word_patterns", filteredWordPatterns)
    end
end)
```

---

## PostFilterCheck

**Purpose**

Called after a word filter check has been completed.

**Parameters**

* `player` (*Player*): The player whose message was checked.
* `text` (*string*): The text that was checked.
* `passed` (*boolean*): Whether the filter check passed (true) or failed (false).

**Realm**

Server.

**When Called**

This hook is triggered when:
- A word filter check has been completed
- After `PreFilterCheck` hook
- After all filtering logic has been processed

**Example Usage**

```lua
-- Track filter check completion
hook.Add("PostFilterCheck", "TrackFilterCheckCompletion", function(player, text, passed)
    local char = player:getChar()
    if char then
        local filterChecks = char:getData("filter_checks", 0)
        char:setData("filter_checks", filterChecks + 1)
        
        -- Track filter check results
        local filterResults = char:getData("filter_results", {})
        filterResults[passed and "passed" or "failed"] = (filterResults[passed and "passed" or "failed"] or 0) + 1
        char:setData("filter_results", filterResults)
    end
end)

-- Apply filter check completion effects
hook.Add("PostFilterCheck", "FilterCheckCompletionEffects", function(player, text, passed)
    if passed then
        -- Play pass sound
        player:EmitSound("buttons/button14.wav", 75, 100)
        
        -- Apply screen effect
        player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.3, 0)
    else
        -- Play fail sound
        player:EmitSound("buttons/button16.wav", 75, 100)
        
        -- Apply screen effect
        player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
    end
end)

-- Track filter check statistics
hook.Add("PostFilterCheck", "TrackFilterCheckStats", function(player, text, passed)
    local char = player:getChar()
    if char then
        -- Track filter check frequency
        local filterCheckFrequency = char:getData("filter_check_frequency", 0)
        char:setData("filter_check_frequency", filterCheckFrequency + 1)
        
        -- Track filter check patterns
        local filterCheckPatterns = char:getData("filter_check_patterns", {})
        table.insert(filterCheckPatterns, {
            text = text,
            passed = passed,
            time = os.time()
        })
        char:setData("filter_check_patterns", filterCheckPatterns)
    end
end)
```

---

## PreFilterCheck

**Purpose**

Called before a word filter check is performed on a player's message.

**Parameters**

* `player` (*Player*): The player whose message will be checked.
* `text` (*string*): The text that will be checked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player sends a message
- Before the word filter check begins
- Before any filtering logic is processed

**Example Usage**

```lua
-- Validate filter check
hook.Add("PreFilterCheck", "ValidateFilterCheck", function(player, text)
    local char = player:getChar()
    if char then
        -- Check if filter is disabled
        if char:getData("word_filter_disabled", false) then
            player:notify("Word filter is disabled!")
            return false
        end
        
        -- Check filter cooldown
        local lastFilter = char:getData("last_filter_check_time", 0)
        if os.time() - lastFilter < 1 then -- 1 second cooldown
            player:notify("Please wait before sending another message!")
            return false
        end
        
        -- Update last filter time
        char:setData("last_filter_check_time", os.time())
    end
end)

-- Track filter check attempts
hook.Add("PreFilterCheck", "TrackFilterCheckAttempts", function(player, text)
    local char = player:getChar()
    if char then
        local filterAttempts = char:getData("filter_check_attempts", 0)
        char:setData("filter_check_attempts", filterAttempts + 1)
        
        -- Track message patterns
        local messagePatterns = char:getData("message_patterns", {})
        table.insert(messagePatterns, {
            text = text,
            time = os.time()
        })
        char:setData("message_patterns", messagePatterns)
    end
end)

-- Apply pre-filter effects
hook.Add("PreFilterCheck", "PreFilterEffects", function(player, text)
    -- Play pre-filter sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 5), 0.2, 0)
end)
```

---

## WordAddedToFilter

**Purpose**

Called when a word is added to the filter list.

**Parameters**

* `word` (*string*): The word that was added to the filter.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A word is added to the word filter
- After the word is saved to the database
- When the filter list is updated

**Example Usage**

```lua
-- Track word additions
hook.Add("WordAddedToFilter", "TrackWordAdditions", function(word)
    lia.log.add(nil, "wordAddedToFilter", word)
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Word '" .. word .. "' added to filter!")
    end
end)

-- Apply word addition effects
hook.Add("WordAddedToFilter", "WordAdditionEffects", function(word)
    -- Play addition sound
    for _, ply in player.Iterator() do
        ply:EmitSound("buttons/button14.wav", 75, 100)
    end
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(Vector(0, 0, 0))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track word addition statistics
hook.Add("WordAddedToFilter", "TrackWordAdditionStats", function(word)
    -- Track total words added
    local totalWordsAdded = lia.data.get("total_words_added", 0)
    lia.data.set("total_words_added", totalWordsAdded + 1)
    
    -- Track word addition frequency
    local wordAdditionFrequency = lia.data.get("word_addition_frequency", 0)
    lia.data.set("word_addition_frequency", wordAdditionFrequency + 1)
end)
```

---

## WordRemovedFromFilter

**Purpose**

Called when a word is removed from the filter list.

**Parameters**

* `word` (*string*): The word that was removed from the filter.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A word is removed from the word filter
- After the word is removed from the database
- When the filter list is updated

**Example Usage**

```lua
-- Track word removals
hook.Add("WordRemovedFromFilter", "TrackWordRemovals", function(word)
    lia.log.add(nil, "wordRemovedFromFilter", word)
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Word '" .. word .. "' removed from filter!")
    end
end)

-- Apply word removal effects
hook.Add("WordRemovedFromFilter", "WordRemovalEffects", function(word)
    -- Play removal sound
    for _, ply in player.Iterator() do
        ply:EmitSound("buttons/button16.wav", 75, 100)
    end
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(Vector(0, 0, 0))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track word removal statistics
hook.Add("WordRemovedFromFilter", "TrackWordRemovalStats", function(word)
    -- Track total words removed
    local totalWordsRemoved = lia.data.get("total_words_removed", 0)
    lia.data.set("total_words_removed", totalWordsRemoved + 1)
    
    -- Track word removal frequency
    local wordRemovalFrequency = lia.data.get("word_removal_frequency", 0)
    lia.data.set("word_removal_frequency", wordRemovalFrequency + 1)
end)
```
