# lia.administrator

The `lia.administrator` library provides administrative functions for managing players, including punishment systems, privilege management, and administrative commands.

## Functions

### lia.administrator.applyPunishment

Applies punishment to a player by kicking and/or banning them with customizable messages.

```lua
lia.administrator.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
```

**Parameters:**
- `client` (Player): The player to apply punishment to
- `infraction` (string): The reason for the punishment (will be inserted into the message)
- `kick` (boolean): Whether to kick the player
- `ban` (boolean): Whether to ban the player
- `time` (number, optional): Ban duration in minutes (0 = permanent ban). Defaults to 0
- `kickKey` (string, optional): Language key for kick message. Defaults to "kickedForInfraction"
- `banKey` (string, optional): Language key for ban message. Defaults to "bannedForInfraction"

**Returns:**
- None

**Description:**
This function provides a unified way to apply punishments to players. It can kick, ban, or both, with customizable messages. The function uses the Lilia localization system to format the punishment messages.

**Usage Examples:**

```lua
-- Kick a player for cheating
lia.administrator.applyPunishment(client, "usingThirdPartyCheats", true, false)

-- Ban a player permanently for hacking
lia.administrator.applyPunishment(client, "hackingInfraction", false, true, 0)

-- Kick and ban a player with custom message keys
lia.administrator.applyPunishment(client, "severeInfraction", true, true, 60, "kickedForInfractionPeriod", "bannedForInfractionPeriod")

-- Temporary ban for 24 hours
lia.administrator.applyPunishment(client, "ruleViolation", false, true, 1440)
```

**Message Formatting:**
The function uses language keys to format messages. The infraction reason is inserted into the message using string formatting:

- Default kick message: "Kicked for [infraction]"
- Default ban message: "Banned for [infraction]"
- Period messages: "[Action] for [infraction]." (with period)

**Common Language Keys:**
- `kickedForInfraction`: "Kicked for"
- `bannedForInfraction`: "Banned for"
- `kickedForInfractionPeriod`: "Kicked for %s."
- `bannedForInfractionPeriod`: "Banned for %s."

**Implementation Details:**
- Uses `lia.administrator.execCommand()` internally to execute kick/ban commands
- Automatically logs the punishment through the admin logging system
- Supports both permanent (0) and temporary bans
- Integrates with Lilia's localization system for multi-language support

**Related Functions:**
- `lia.administrator.execCommand()`: Executes administrative commands
- `lia.administrator.hasAccess()`: Checks if a player has administrative privileges
