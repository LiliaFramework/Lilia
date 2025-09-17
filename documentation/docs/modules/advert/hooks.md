# Hooks

This document describes the hooks available in the Advertisement module.

---

## AdvertSent

**Purpose**

Called when a player successfully sends an advertisement message through the `/advert` command.

**Parameters**

* `client` (*Player*): The player who sent the advertisement.
* `message` (*string*): The advertisement message content.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The player has sufficient funds to pay for the advertisement
- The cooldown period has passed
- The money has been deducted from the player's character
- The advertisement has been broadcast to all players
- The advertisement has been logged

**Example Usage**

```lua
-- Track advertisement statistics
hook.Add("AdvertSent", "TrackAdvertStats", function(client, message)
    local char = client:getChar()
    if char then
        local currentAds = char:getData("advertisements_sent", 0)
        char:setData("advertisements_sent", currentAds + 1)
    end
end)

-- Log advertisements to external system
hook.Add("AdvertSent", "LogToExternalSystem", function(client, message)
    local data = {
        player = client:SteamID(),
        name = client:Name(),
        message = message,
        timestamp = os.time()
    }
    
    -- Send to external logging service
    http.Post("https://your-logging-service.com/advertisements", data, function(response)
        print("Advertisement logged to external system")
    end)
end)

-- Award achievement for first advertisement
hook.Add("AdvertSent", "FirstAdvertAchievement", function(client, message)
    local char = client:getChar()
    if char and not char:getData("first_advertisement", false) then
        char:setData("first_advertisement", true)
        client:notify("Congratulations! You've sent your first advertisement!")
        
        -- Award some bonus money for first advertisement
        char:giveMoney(50)
        client:notify("You received a 50 credit bonus for your first advertisement!")
    end
end)

-- Filter inappropriate content
hook.Add("AdvertSent", "ContentFilter", function(client, message)
    local filteredWords = {"spam", "scam", "hack"}
    
    for _, word in ipairs(filteredWords) do
        if string.find(string.lower(message), word) then
            client:notify("Your advertisement contains inappropriate content and has been flagged for review.")
            
            -- Notify administrators
            for _, admin in player.Iterator() do
                if admin:IsAdmin() then
                    admin:notify(client:Name() .. " sent a potentially inappropriate advertisement: " .. message)
                end
            end
            break
        end
    end
end)

-- Track advertisement costs for analytics
hook.Add("AdvertSent", "AdvertAnalytics", function(client, message)
    local advertPrice = lia.config.get("AdvertPrice", 10)
    local char = client:getChar()
    
    if char then
        local totalSpent = char:getData("total_advert_spent", 0)
        char:setData("total_advert_spent", totalSpent + advertPrice)
        
        -- Check if player has spent over 100 credits on advertisements
        if totalSpent + advertPrice >= 100 then
            client:notify("You've spent over 100 credits on advertisements! You're a true advertiser!")
        end
    end
end)
```