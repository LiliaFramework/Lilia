# Hooks

This document describes the hooks available in the Chat Messages module for managing automated chat messages.

---

## ChatMessagesTimerStarted

**Purpose**

Called when the chat messages timer is started with a specific interval.

**Parameters**

* `interval` (*number*): The interval in seconds between chat messages.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The chat messages module initializes
- The timer for automated messages is created
- Before any messages are sent

**Example Usage**

```lua
-- Track when chat messages timer starts
hook.Add("ChatMessagesTimerStarted", "TrackChatMessagesTimer", function(interval)
    print("Chat messages timer started with interval:", interval, "seconds")
    
    -- Log to server console
    if SERVER then
        print("Chat messages timer started with interval:", interval, "seconds")
    end
end)

-- Modify chat messages behavior based on timer
hook.Add("ChatMessagesTimerStarted", "ModifyChatMessagesBehavior", function(interval)
    -- Store the interval for later use
    local char = LocalPlayer():getChar()
    if char then
        char:setData("chat_messages_interval", interval)
    end
    
    -- Notify player about automated messages
    LocalPlayer():notify("Automated chat messages enabled with " .. interval .. " second intervals")
end)

-- Apply custom timer modifications
hook.Add("ChatMessagesTimerStarted", "CustomTimerModifications", function(interval)
    -- Double the interval for certain players
    local char = LocalPlayer():getChar()
    if char and char:getData("vip_status", false) then
        timer.Adjust("MessageTimer", interval * 2, 0, function()
            -- Custom VIP message handling
            local messageData = {"VIP Message 1", "VIP Message 2"}
            local nextMessageIndex = 1
            local text = messageData[nextMessageIndex]
            chat.AddText(Color(255, 215, 0), "[VIP] ", color_white, text)
        end)
    end
end)
```

---

## ChatMessageSent

**Purpose**

Called when a chat message is sent by the automated system.

**Parameters**

* `messageIndex` (*number*): The index of the message that was sent.
* `text` (*string*): The text content of the message that was sent.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An automated chat message is displayed
- After the message is added to chat
- When the message timer fires

**Example Usage**

```lua
-- Track sent messages
hook.Add("ChatMessageSent", "TrackSentMessages", function(messageIndex, text)
    local char = LocalPlayer():getChar()
    if char then
        local sentMessages = char:getData("sent_messages", 0)
        char:setData("sent_messages", sentMessages + 1)
        
        -- Log message details
        print("Message", messageIndex, "sent:", text)
    end
end)

-- Apply custom effects to sent messages
hook.Add("ChatMessageSent", "CustomMessageEffects", function(messageIndex, text)
    -- Play sound effect
    LocalPlayer():EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    LocalPlayer():notify("Automated message sent: " .. text)
end)

-- Modify message content
hook.Add("ChatMessageSent", "ModifyMessageContent", function(messageIndex, text)
    local char = LocalPlayer():getChar()
    if char then
        -- Add character-specific prefix
        local charName = char:getName()
        local modifiedText = "[" .. charName .. "] " .. text
        
        -- Send modified message
        chat.AddText(Color(255, 0, 0), "[MODIFIED] ", color_white, modifiedText)
    end
end)

-- Track message statistics
hook.Add("ChatMessageSent", "TrackMessageStatistics", function(messageIndex, text)
    local char = LocalPlayer():getChar()
    if char then
        local messageStats = char:getData("message_statistics", {})
        messageStats[messageIndex] = {
            text = text,
            timestamp = os.time(),
            length = string.len(text)
        }
        char:setData("message_statistics", messageStats)
    end
end)
```
