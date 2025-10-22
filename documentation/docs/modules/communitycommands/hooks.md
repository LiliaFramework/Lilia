# Hooks

This document describes the hooks available in the Community Commands module for managing community URL commands and external link handling.

---

## CommunityURLOpened

**Purpose**

Called when a community URL is opened on the client side.

**Parameters**

* `commandName` (*string*): The name of the command that was executed.
* `url` (*string*): The URL that was opened.
* `openIngame` (*boolean*): Whether the URL should open in-game or in the external browser.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A community URL command is executed
- The URL is about to be opened (either in-game or externally)
- After `CommunityURLRequest` hook on the server

**Example Usage**

```lua
-- Track URL usage
hook.Add("CommunityURLOpened", "TrackURLUsage", function(commandName, url, openIngame)
    local char = LocalPlayer():getChar()
    if char then
        local urlsOpened = char:getData("community_urls_opened", 0)
        char:setData("community_urls_opened", urlsOpened + 1)
        
        -- Track specific command usage
        local commandUsage = char:getData("command_usage", {})
        commandUsage[commandName] = (commandUsage[commandName] or 0) + 1
        char:setData("command_usage", commandUsage)
        
        -- Track in-game vs external usage
        if openIngame then
            char:setData("ingame_urls", char:getData("ingame_urls", 0) + 1)
        else
            char:setData("external_urls", char:getData("external_urls", 0) + 1)
        end
    end
end)

-- Apply custom effects when URL opens
hook.Add("CommunityURLOpened", "ApplyURLEffects", function(commandName, url, openIngame)
    -- Play sound effect
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.5, 0)
    
    -- Notify player
    LocalPlayer():notify("Opening " .. commandName .. " URL...")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos() + Vector(0, 0, 50))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Customize in-game browser
hook.Add("CommunityURLOpened", "CustomizeInGameBrowser", function(commandName, url, openIngame)
    if openIngame then
        -- Add custom styling to in-game browser
        timer.Simple(0.1, function()
            local frames = vgui.GetWorldPanel():GetChildren()
            for _, frame in ipairs(frames) do
                if frame:GetName() == "DFrame" and frame:GetTitle() == commandName then
                    -- Customize the frame
                    frame:SetBackgroundColor(Color(50, 50, 50, 255))
                    frame:SetTitleColor(Color(255, 255, 255))
                    
                    -- Add custom close button
                    local closeBtn = frame:Add("DButton")
                    closeBtn:SetText("Close")
                    closeBtn:SetPos(frame:GetWide() - 80, 5)
                    closeBtn:SetSize(70, 25)
                    closeBtn.DoClick = function()
                        frame:Close()
                    end
                end
            end
        end)
    end
end)

-- Log URL openings
hook.Add("CommunityURLOpened", "LogURLOpenings", function(commandName, url, openIngame)
    print("Community URL opened: " .. commandName .. " -> " .. url .. " (In-game: " .. tostring(openIngame) .. ")")
end)

-- Apply URL-specific effects
hook.Add("CommunityURLOpened", "ApplyURLSpecificEffects", function(commandName, url, openIngame)
    -- Apply different effects based on command
    if commandName == "Discord" then
        LocalPlayer():EmitSound("buttons/button15.wav", 75, 100)
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(114, 137, 218, 10), 1, 0)
    elseif commandName == "Rules" then
        LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 1, 0)
    elseif commandName == "SteamGroup" then
        LocalPlayer():EmitSound("buttons/button16.wav", 75, 100)
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 100, 200, 10), 1, 0)
    end
end)
```

---

## CommunityURLRequest

**Purpose**

Called when a community URL command is requested on the server side.

**Parameters**

* `client` (*Player*): The client who requested the URL.
* `command` (*string*): The command that was executed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A community URL command is executed
- Before the URL is sent to the client
- After command validation

**Example Usage**

```lua
-- Track URL requests
hook.Add("CommunityURLRequest", "TrackURLRequests", function(client, command)
    local char = client:getChar()
    if char then
        local requests = char:getData("community_url_requests", 0)
        char:setData("community_url_requests", requests + 1)
        
        -- Track specific command requests
        local commandRequests = char:getData("command_requests", {})
        commandRequests[command] = (commandRequests[command] or 0) + 1
        char:setData("command_requests", commandRequests)
    end
    
    lia.log.add(client, "communityURLRequest", command)
end)

-- Apply request restrictions
hook.Add("CommunityURLRequest", "ApplyRequestRestrictions", function(client, command)
    local char = client:getChar()
    if char then
        -- Check cooldown
        local lastRequest = char:getData("last_url_request", 0)
        if os.time() - lastRequest < 5 then -- 5 second cooldown
            client:notify("Please wait before using another community command!")
            return false
        end
        
        -- Check daily limit
        local today = os.date("%Y-%m-%d")
        local dailyRequests = char:getData("daily_url_requests", {})
        if dailyRequests[today] and dailyRequests[today] >= 10 then
            client:notify("Daily community command limit reached!")
            return false
        end
        
        -- Update counters
        char:setData("last_url_request", os.time())
        dailyRequests[today] = (dailyRequests[today] or 0) + 1
        char:setData("daily_url_requests", dailyRequests)
    end
end)

-- Log URL requests for moderation
hook.Add("CommunityURLRequest", "LogURLRequests", function(client, command)
    -- Log to external system
    local data = {
        player = client:SteamID(),
        player_name = client:Name(),
        command = command,
        timestamp = os.time()
    }
    
    http.Post("https://your-logging-service.com/community-requests", data, function(response)
        print("Community URL request logged to external system")
    end)
    
    -- Notify administrators
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " used community command: " .. command)
        end
    end
end)

-- Apply command-specific restrictions
hook.Add("CommunityURLRequest", "ApplyCommandRestrictions", function(client, command)
    local char = client:getChar()
    if char then
        -- Check faction-based restrictions
        local faction = char:getFaction()
        
        if command == "Discord" and faction == "criminal" then
            client:notify("Criminals cannot access the Discord server!")
            return false
        end
        
        if command == "Rules" and faction == "police" then
            -- Police get priority access
            client:notify("Accessing official rules...")
        end
        
        -- Check for restricted commands
        local restrictedCommands = char:getData("restricted_commands", {})
        if restrictedCommands[command] then
            client:notify("You don't have permission to use this command!")
            return false
        end
    end
end)

-- Track command usage patterns
hook.Add("CommunityURLRequest", "TrackCommandPatterns", function(client, command)
    local char = client:getChar()
    if char then
        -- Track command frequency
        local commandFrequency = char:getData("command_frequency", {})
        commandFrequency[command] = (commandFrequency[command] or 0) + 1
        char:setData("command_frequency", commandFrequency)
        
        -- Track command sequence
        local commandSequence = char:getData("command_sequence", {})
        table.insert(commandSequence, command)
        if #commandSequence > 10 then
            table.remove(commandSequence, 1)
        end
        char:setData("command_sequence", commandSequence)
        
        -- Detect spam patterns
        local recentCommands = {}
        for i = math.max(1, #commandSequence - 5), #commandSequence do
            table.insert(recentCommands, commandSequence[i])
        end
        
        local sameCommandCount = 0
        for _, cmd in ipairs(recentCommands) do
            if cmd == command then
                sameCommandCount = sameCommandCount + 1
            end
        end
        
        if sameCommandCount >= 3 then
            client:notify("Please don't spam community commands!")
            return false
        end
    end
end)

-- Award achievements for command usage
hook.Add("CommunityURLRequest", "CommandAchievements", function(client, command)
    local char = client:getChar()
    if char then
        local totalRequests = char:getData("community_url_requests", 0)
        
        if totalRequests == 1 then
            client:notify("Achievement: First Community Command!")
        elseif totalRequests == 10 then
            client:notify("Achievement: Community Explorer!")
        elseif totalRequests == 50 then
            client:notify("Achievement: Community Master!")
        end
        
        -- Command-specific achievements
        local commandRequests = char:getData("command_requests", {})
        if commandRequests[command] == 1 then
            client:notify("Achievement: First " .. command .. " Command!")
        elseif commandRequests[command] == 10 then
            client:notify("Achievement: " .. command .. " Enthusiast!")
        end
    end
end)

-- Apply request effects
hook.Add("CommunityURLRequest", "ApplyRequestEffects", function(client, command)
    -- Play sound effect
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.3, 0)
    
    -- Notify client
    client:notify("Processing " .. command .. " request...")
end)
```
