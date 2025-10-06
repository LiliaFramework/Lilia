# Discord Library

This page documents the functions for working with Discord integration and webhooks.

---

## Overview

The discord library (`lia.discord`) provides a comprehensive system for Discord integration, webhook management, and message relaying in the Lilia framework, enabling seamless communication between game servers and Discord communities. This library offers advanced webhook management with support for multiple webhook configurations, automatic failover systems, and rate limiting to ensure reliable message delivery. The system includes sophisticated message formatting with support for embeds, attachments, custom styling, and dynamic content generation based on game events. It features robust Discord API integration with OAuth2 authentication, bot management capabilities, and real-time event processing for bidirectional communication. The library also provides comprehensive logging and monitoring tools, message queuing for high-volume scenarios, and security features including message validation and spam protection. Additional functionality includes user role synchronization, server statistics reporting, and integration with other framework systems for automated notifications, making it an essential tool for modern roleplay servers seeking to maintain active Discord communities and enhance player engagement.

---

### relayMessage

**Purpose**

Relays an embed message to Discord via webhook using the configured webhook URL.

**Parameters**

* `embed` (*table*): The embed data table containing title, description, color, timestamp, footer, etc.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Relay an embed message to Discord
local function relayDiscordMessage(embed)
    lia.discord.relayMessage(embed)
end

-- Use in a function
local function sendPlayerJoin(client)
    local embed = {
        title = "Player Joined",
        description = "Player " .. client:Name() .. " joined the server",
        color = 7506394,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    lia.discord.relayMessage(embed)
end

-- Use in a hook
hook.Add("PlayerInitialSpawn", "DiscordRelay", function(client)
    local embed = {
        title = "Player Joined",
        description = "Player " .. client:Name() .. " joined the server",
        color = 7506394,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    lia.discord.relayMessage(embed)
end)

-- Use in a command
lia.command.add("discordmessage", {
    arguments = {
        {name = "title", type = "string"},
        {name = "message", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local embed = {
            title = arguments[1],
            description = arguments[2],
            color = 7506394,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        lia.discord.relayMessage(embed)
        client:notify("Message sent to Discord")
    end
})

-- Advanced embed example
local function sendRichEmbed()
    local embed = {
        title = "Server Status",
        description = "Server is online and accepting connections",
        color = 65280, -- Green color
        fields = {
            {
                name = "Players Online",
                value = tostring(player.GetCount()),
                inline = true
            },
            {
                name = "Uptime",
                value = "2h 30m",
                inline = true
            }
        },
        footer = {
            text = "Lilia Framework",
            icon_url = "https://example.com/icon.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    lia.discord.relayMessage(embed)
end
```