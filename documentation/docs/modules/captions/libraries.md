# Caption Library

Helpers to show and hide Closed Captions for players or locally on the client.

---

Overview

The caption library provides a simple API for displaying timed on-screen captions/subtitles. It supports both server-side and client-side usage, allowing captions to be triggered from either realm. Captions are displayed for a specified duration and can be manually stopped before the duration expires. The library is ideal for tutorials, story events, or any scenario where temporary on-screen text is needed.

---

### lia.caption.start

#### 📋 Purpose
Begin displaying a caption for a duration.

#### ⏰ When Called
When temporarily showing on-screen captions/subtitles for tutorials, story events, or notifications.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Recipient (Server variant only) |
| `text` | **string** | Caption text to display |
| `duration` | **number** | Seconds to show the caption |

#### ↩️ Returns
* void

#### 🌐 Realm
Server and Client variants exist.

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Show a caption on the client
    lia.caption.start("Welcome", 3)
    
    -- Simple: Show a caption to a player (Server)
    lia.caption.start(ply, "Sector sweep in progress", 5)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Show caption with dynamic text (Client)
    local message = "Loading " .. data.name .. "..."
    lia.caption.start(message, 2.5)
    
    -- Medium: Show caption to multiple players (Server)
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsValid() then
            lia.caption.start(ply, "Event starting soon", 5)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Conditional caption display with validation
    local function showCaption(player, text, duration, condition)
        if not IsValid(player) then return end
        if condition and player:IsValid() then
            local finalText = text
            if player:GetNWBool("isAdmin", false) then
                finalText = "[ADMIN] " .. text
            end
            lia.caption.start(player, finalText, duration or 3)
            hook.Run("OnCaptionShown", player, finalText, duration)
        end
    end
    showCaption(ply, "Mission complete", 5, ply:Alive())

```

---

### lia.caption.finish

#### 📋 Purpose
Stop an active caption before its duration expires.

#### ⏰ When Called
When you need to immediately hide a currently displaying caption.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Recipient (Server variant only, optional on client) |

#### ↩️ Returns
* void

#### 🌐 Realm
Server and Client variants exist.

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Stop caption on client
    lia.caption.finish()
    
    -- Simple: Stop caption for a player (Server)
    lia.caption.finish(ply)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Stop caption after condition
    if condition then
        lia.caption.finish()
    end
    
    -- Medium: Stop captions for all players (Server)
    for _, ply in ipairs(player.GetAll()) do
        lia.caption.finish(ply)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Stop captions with validation and hooks
    local function stopCaptionSafely(player)
        if not IsValid(player) then return end
        if SERVER then
            lia.caption.finish(player)
            hook.Run("OnCaptionStopped", player)
        else
            lia.caption.finish()
            hook.Run("OnCaptionStopped")
        end
    end
    stopCaptionSafely(ply)

```

---
