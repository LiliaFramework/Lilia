--[[
    Hooks:
        GetPlayerRespawnLocation(client, character)

    Purpose:
        Allows code to provide a custom respawn location before the spawn module falls back to its normal selection logic.

    Category:
        Spawns

    Parameters:
        client (Player)
            The player who is respawning.

        character (Character)
            The player's active character.

    Example Usage:
        ```lua
        hook.Add("GetPlayerRespawnLocation", "liaExampleGetPlayerRespawnLocation", function(client, character)
            return {
                {name = "Example", value = 1}
            }
        end)
        ```

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

    Category:
        Spawns

    Parameters:
        client (Player)
            The player who is spawning.

        character (Character)
            The player's active character.

    Example Usage:
        ```lua
        hook.Add("GetPlayerSpawnLocation", "liaExampleGetPlayerSpawnLocation", function(client, character)
            return {
                {name = "Example", value = 1}
            }
        end)
        ```

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

    Category:
        Spawns

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

    Example Usage:
        ```lua
        hook.Add("OnRespawnKeyPressed", "liaExampleOnRespawnKeyPressed", function(ply, key, left, baseTime, lastDeath)
            if IsValid(ply) and ply:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Spawns

    Parameters:
        client (Player)
            The player being placed at the spawn point.

        position (Vector)
            The final position chosen for the spawn.

        angle (Angle)
            The eye angle applied to the player at spawn.

    Example Usage:
        ```lua
        hook.Add("PlayerSpawnPointSelected", "liaExamplePlayerSpawnPointSelected", function(client, position, angle)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled PlayerSpawnPointSelected for %s", client:Name()))
        end)
        ```

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

    Category:
        Spawns

    Parameters:
        ply (Player)
            The local player who died.

        left (number)
            The remaining time before respawn becomes available.

        baseTime (number)
            The configured base respawn delay.

        lastDeath (number)
            The timestamp of the player's last death.

    Example Usage:
        ```lua
        hook.Add("ShouldRespawnScreenAppear", "liaExampleShouldRespawnScreenAppear", function(ply, left, baseTime, lastDeath)
            if IsValid(ply) and ply:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Spawns

    Parameters:
        client (Player)
            The player being spawned.

        character (Character)
            The player's active character.

        isRespawning (boolean)
            Whether this spawn is a respawn rather than an initial spawn.

    Example Usage:
        ```lua
        hook.Add("ShouldUseMapSpawns", "liaExampleShouldUseMapSpawns", function(client, character, isRespawning)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return true to force use of map spawn entities first.

    Realm:
        Server
]]
--[[
    Hooks:
        FetchSpawns()

    Purpose:
        Loads the stored faction spawn table and normalizes saved entries into structured spawn data.

    Category:
        Spawns

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("FetchSpawns", "liaExampleFetchSpawns", function()
            print("[MyModule] handled FetchSpawns")
        end)
        ```

    Returns:
        Deferred
            Resolves with the normalized faction spawn table.

    Realm:
        Server
]]
--[[
    Hooks:
        StoreSpawns(spawns)

    Purpose:
        Saves the provided faction spawn table into persistent module data.

    Category:
        Spawns

    Parameters:
        spawns (table)
            The faction spawn data to persist.

    Example Usage:
        ```lua
        hook.Add("StoreSpawns", "liaExampleStoreSpawns", function(spawns)
            print("[MyModule] handled StoreSpawns")
        end)
        ```

    Returns:
        Deferred
            Resolves true after the spawn data is queued for persistence.

    Realm:
        Server
]]
MODULE.name = "@spawnsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@spawnSystemDescription"
