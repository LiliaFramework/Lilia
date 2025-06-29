# Flags Library

This page explains permission flag management.

---

## Overview

The flags library assigns text-based permission flags to players. It offers tools for checking whether a player possesses a flag and for saving or loading flag data.
--[[--
Grants abilities to characters.

Flags are a simple way of adding/removing certain abilities to players on a per-character basis. Helix comes with a few flags
by default, for example to restrict spawning of props, usage of the physgun, etc. All flags will be listed in the
`Flags` section of the `Help` menu. Flags are usually used when server validation is required to allow a player to do something
on their character. However, it's usually preferable to use in-character methods over flags when possible (i.e restricting
the business menu to characters that have a permit item, rather than using flags to determine availability).
]]
---

### `lia.flag.add`

    
    Description:
    Registers a new flag by adding it to the flag list.
    Each flag has a description and an optional callback that is executed when the flag is applied to a player.
    
    Parameters:
    flag (string) – The unique flag identifier.
    desc (string) – A description of what the flag does.
    callback (function) – An optional callback function executed when the flag is applied to a player.
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.flag.add
    lia.flag.add("C", "Spawn vehicles.")

### `lia.flag.onSpawn`

    
    Description:
    Called when a player spawns. This function checks the player's character flags and triggers
    the associated callbacks for each flag that the character possesses.
    
    Parameters:
    client (Player) – The player who spawned.
    
    Returns:
    nil
    
    Realm:
    Server
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.flag.onSpawn
    lia.flag.onSpawn(player)
