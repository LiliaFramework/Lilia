--[[
    Hooks:
        GetPlayerRespawnLocation(client, character)

    Purpose:
        Allows code to provide a custom respawn location before the spawn module falls back to its normal selection logic.

    Parameters:
        client (Player)
            The player who is respawning.

        character (Character)
            The player's active character.

    Returns:
        table|nil
            Return a table containing `pos` or `position`, and optionally `ang` or `angle`, to override the respawn location.

    Realm:
        Server
]]
--[[
    Hooks:
        GetPlayerSpawnLocation(client, character)

    Purpose:
        Allows code to provide a custom spawn location for normal character spawns.

    Parameters:
        client (Player)
            The player who is spawning.

        character (Character)
            The player's active character.

    Returns:
        table|nil
            Return a table containing `pos` or `position`, and optionally `ang` or `angle`, to override the spawn location.

    Realm:
        Server
]]
--[[
    Hooks:
        OnRespawnKeyPressed(ply, key, left, baseTime, lastDeath)

    Purpose:
        Called on the client when a key is pressed while the respawn screen is active.

    Parameters:
        ply (Player)
            The local player using the respawn screen.

        key (number)
            The pressed key code.

        left (number)
            The remaining time before respawn becomes available.

        baseTime (number)
            The configured base respawn delay.

        lastDeath (number)
            The timestamp of the player's last death.

    Returns:
        boolean|nil
            Return false to block the default respawn-screen key handling.

    Realm:
        Client
]]
--[[
    Hooks:
        PlayerSpawnPointSelected(client, position, angle)

    Purpose:
        Called after the spawn module selects a final spawn point for a player.

    Parameters:
        client (Player)
            The player being placed at the spawn point.

        position (Vector)
            The final position chosen for the spawn.

        angle (Angle)
            The eye angle applied to the player at spawn.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldRespawnScreenAppear(ply, left, baseTime, lastDeath)

    Purpose:
        Determines whether the clientside respawn screen should be shown.

    Parameters:
        ply (Player)
            The local player who died.

        left (number)
            The remaining time before respawn becomes available.

        baseTime (number)
            The configured base respawn delay.

        lastDeath (number)
            The timestamp of the player's last death.

    Returns:
        boolean|nil
            Return false to suppress the respawn screen.

    Realm:
        Client
]]
--[[
    Hooks:
        ShouldUseMapSpawns(client, character, isRespawning)

    Purpose:
        Determines whether the spawn module should prefer map-defined spawn entities before its usual class or faction spawn logic.

    Parameters:
        client (Player)
            The player being spawned.

        character (Character)
            The player's active character.

        isRespawning (boolean)
            Whether this spawn is a respawn rather than an initial spawn.

    Returns:
        boolean|nil
            Return true to force use of map spawn entities first.

    Realm:
        Server
]]
MODULE.name = "@spawnsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@spawnSystemDescription"
