# Discord Library

This page documents the functions for working with Discord integration and webhooks.

---

## Overview

The discord library (`lia.discord`) provides a comprehensive system for Discord integration, webhook management, and message relaying in the Lilia framework. It includes webhook configuration, message sending, and Discord API integration functionality.

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