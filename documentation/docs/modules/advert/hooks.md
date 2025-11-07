# Hooks

Hooks provided by the Advertisements module for server-wide announcements.

---

Overview

The Advertisements module provides a paid server-wide announcement system that allows players to broadcast messages to all connected players. It implements spam prevention through cooldowns, message logging for administrative oversight, and colored message formatting for better visibility. The module integrates with the economy system for paid advertisements and includes comprehensive hook support for customizing advertisement behavior, validation, and processing workflows.

---

### AdvertSent

#### 📋 Purpose
Called when a player successfully sends an advertisement message to the server.

#### ⏰ When Called
After an advertisement has been sent, logged, and displayed to all players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the advertisement |
| `message` | **string** | The advertisement message content |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
hook.Add("AdvertSent", "LogAdvertisements", function(client, message)
    print(client:Name() .. " sent an advertisement: " .. message)
end)
```

#### 📊 Medium Complexity
```lua
hook.Add("AdvertSent", "TrackAdvertisementStats", function(client, message)
    if not client.advertCount then client.advertCount = 0 end
    client.advertCount = client.advertCount + 1
    
    -- Track advertisement length
    local stats = client:getNetVar("advertStats", {})
    stats.totalLength = (stats.totalLength or 0) + #message
    stats.count = client.advertCount
    client:setNetVar("advertStats", stats)
end)
```

#### ⚙️ High Complexity
```lua
hook.Add("AdvertSent", "AdvancedAdvertisementSystem", function(client, message)
    -- Store advertisement in database
    local char = client:getChar()
    if char then
        lia.db.insert("advertisements", {
            steamid = client:SteamID(),
            charid = char:getID(),
            message = message,
            timestamp = os.time()
        })
    end
    
    -- Check for special keywords and trigger events
    local keywords = {"sale", "wanted", "hiring", "selling"}
    for _, keyword in ipairs(keywords) do
        if string.find(string.lower(message), keyword) then
            hook.Run("AdvertKeywordTriggered", client, keyword, message)
        end
    end
    
    -- Send notification to admins
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " sent: " .. message)
        end
    end
end)
```

