# Discord Library

This page documents the functions for working with Discord integration and webhooks.

---

## Overview

The discord library (`lia.discord`) provides a comprehensive system for Discord integration, webhook management, and message relaying in the Lilia framework, enabling seamless communication between game servers and Discord communities. This library offers advanced webhook management with support for multiple webhook configurations, automatic failover systems, and rate limiting to ensure reliable message delivery. The system includes sophisticated message formatting with support for embeds, attachments, custom styling, and dynamic content generation based on game events. It features robust Discord API integration with OAuth2 authentication, bot management capabilities, and real-time event processing for bidirectional communication. The library also provides comprehensive logging and monitoring tools, message queuing for high-volume scenarios, and security features including message validation and spam protection. Additional functionality includes user role synchronization, server statistics reporting, and integration with other framework systems for automated notifications, making it an essential tool for modern roleplay servers seeking to maintain active Discord communities and enhance player engagement.

---

### lia.discord.relayMessage

**Purpose**

Relays a message to Discord via webhook.

**Parameters**

* `message` (*string*): The message to relay.
* `webhookUrl` (*string*): The Discord webhook URL.
* `options` (*table*): Optional webhook options.

**Returns**

* `success` (*boolean*): True if message was sent successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Relay a message to Discord
local function relayMessage(message, webhookUrl, options)
    return lia.discord.relayMessage(message, webhookUrl, options)
end

-- Use in a function
local function sendPlayerJoin(client)
    local message = "Player " .. client:Name() .. " joined the server"
    local webhookUrl = lia.config.get("DiscordWebhookURL")
    if webhookUrl then
        lia.discord.relayMessage(message, webhookUrl)
    end
end

-- Use in a hook
hook.Add("PlayerInitialSpawn", "DiscordRelay", function(client)
    local message = "Player " .. client:Name() .. " joined the server"
    local webhookUrl = lia.config.get("DiscordWebhookURL")
    if webhookUrl then
        lia.discord.relayMessage(message, webhookUrl)
    end
end)

-- Use in a command
lia.command.add("discordmessage", {
    arguments = {
        {name = "message", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local webhookUrl = lia.config.get("DiscordWebhookURL")
        if webhookUrl then
            local success = lia.discord.relayMessage(arguments[1], webhookUrl)
            client:notify("Message " .. (success and "sent" or "failed to send"))
        else
            client:notify("Discord webhook not configured")
        end
    end
})
```