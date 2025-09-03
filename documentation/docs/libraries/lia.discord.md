# lia.discord

The Discord integration library for Lilia Framework, providing webhook functionality and message relaying to Discord channels.

---

## Overview

The `lia.discord` library handles Discord webhook integration, allowing the server to send formatted messages and embeds to Discord channels. It automatically detects whether the CHTTP binary module is available and falls back to HTTP if needed.

---

## Functions

### `lia.discord.relayMessage(embed)`

Sends a formatted embed message to the configured Discord webhook.

**Parameters**

* `embed` (`table`): The embed object to send to Discord

**Returns**

* `void` — Nothing

**Embed Object Properties**

* `title` (`string`, optional): The embed title (defaults to "Lilia")
* `color` (`number`, optional): The embed color as a decimal number (defaults to 7506394)
* `timestamp` (`string`, optional): ISO 8601 timestamp (defaults to current UTC time)
* `footer` (`table`, optional): Footer object with `text` property (defaults to "Lilia Discord Relay")

**Example**

```lua
-- Send a simple message
lia.discord.relayMessage({
    title = "Player Connected",
    description = "A new player has joined the server",
    color = 0x00ff00
})

-- Send a detailed embed
lia.discord.relayMessage({
    title = "Server Event",
    description = "An important server event has occurred",
    color = 0xff0000,
    fields = {
        {name = "Event Type", value = "Player Death", inline = true},
        {name = "Player", value = "John Doe", inline = true}
    }
})
```

---

## Hooks

### `DiscordRelayed`

**Purpose**

Runs after a Discord message has been successfully sent through the webhook.

**Parameters**

* `embed` (`table`): The embed object that was sent to Discord

**Realm**

Server

**Returns**

`void` — Nothing

**Example**

```lua
hook.Add("DiscordRelayed", "LogDiscordMessage", function(embed)
    print("Discord message sent:", embed.title or "Untitled")
end)
```

---

## Configuration

The library requires a Discord webhook URL to be configured. This must be set on the **server side** in your server configuration files.

```lua
-- In your server config file (e.g., config.lua, server.lua, or similar)
lia.discord.webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
```

**Important Notes:**
- The webhook configuration must be set on the **server**, not the client
- This configuration should be placed in server-side files like `config.lua`, `server.lua`, or similar server configuration files
- The webhook URL should never be exposed to clients for security reasons
- You can obtain a webhook URL from your Discord server settings under Integrations > Webhooks

---

## Dependencies

* **CHTTP Binary Module** (optional): Provides faster HTTP requests
* **HTTP Library** (fallback): Used when CHTTP is not available

---

## Error Handling

The library automatically handles HTTP failures and provides fallback mechanisms:

* If CHTTP is available, it uses that for better performance
* If CHTTP is not available, it falls back to the standard HTTP library
* HTTP failures are logged to the console with the error message

---

## Best Practices

1. **Rate Limiting**: Discord webhooks have rate limits, so avoid sending too many messages too quickly
2. **Embed Limits**: Discord embeds have size limits (6000 characters total)
3. **Error Handling**: Always check if the webhook is configured before calling functions
4. **Performance**: Use CHTTP when available for better performance

---

## Troubleshooting

**Common Issues:**

* **Webhook not configured**: Ensure `lia.discord.webhook` is set in your configuration
* **HTTP failures**: Check your server's internet connectivity and firewall settings
* **Rate limiting**: Reduce the frequency of messages being sent
* **Invalid embed format**: Ensure your embed object follows Discord's embed structure

**Debug Mode:**

Enable debug logging by adding this to your configuration:

```lua
hook.Add("DiscordRelayed", "DebugLogging", function(embed)
    -- Debug logging enabled
end)
```
