--[[
    Hooks:
        CanDeleteChar(client, character)

    Purpose:
        Determines whether a character can be deleted from the character menu.

    Category:
        Protection

    Parameters:
        client (Player)
            The local player attempting to delete the character.

        character (table|Character)
            The target character data being evaluated for deletion.

    Example Usage:
        ```lua
        hook.Add("CanDeleteChar", "liaExampleCanDeleteChar", function(client, character)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block deletion.

    Realm:
        Client
]]
--[[
    Hooks:
        CanPlayerSwitchChar(client, character, newCharacter)

    Purpose:
        Determines whether a player may switch away from their current character to another one.

    Category:
        Protection

    Parameters:
        client (Player)
            The player attempting the character switch.

        character (Character)
            The player's current character.

        newCharacter (Character)
            The character the player wants to switch to.

    Example Usage:
        ```lua
        hook.Add("CanPlayerSwitchChar", "liaExampleCanPlayerSwitchChar", function(client, character, newCharacter)
            if character == newCharacter then
                return false, "You are already using that character."
            end
        end)
        ```

    Returns:
        boolean, string|nil
            Return false and an optional denial message to block the switch.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnCheaterCaught(client)

    Purpose:
        Called after the anti-cheat timeout flow identifies a player as cheating.

    Category:
        Protection

    Parameters:
        client (Player)
            The player flagged by the anti-cheat flow.

    Example Usage:
        ```lua
        hook.Add("OnCheaterCaught", "liaExampleOnCheaterCaught", function(client)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OnCheaterCaught for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerCheatDetected(client)

    Purpose:
        Called when the anti-cheat system detects or flags suspicious cheating behavior for a player.

    Category:
        Protection

    Parameters:
        client (Player)
            The player detected by the anti-cheat system.

    Example Usage:
        ```lua
        hook.Add("PlayerCheatDetected", "liaExamplePlayerCheatDetected", function(client)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled PlayerCheatDetected for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        VerifyCheats()

    Purpose:
        Runs the clientside anti-cheat verification checks and reports suspicious results back to the server.

    Category:
        Protection

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("VerifyCheats", "liaExampleVerifyCheats", function()
            print("[MyModule] handled VerifyCheats")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
MODULE.name = "@protection"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@anticheatDescription"
MODULE.NetworkStrings = {"liaVerifyCheats",}
MODULE.Privileges = {
    ["canSeeAltingNotifications"] = {
        Name = "@canSeeAltingNotifications",
        MinAccess = "admin",
        Category = "@exploiting",
    },
    ["teleportToEntity"] = {
        Name = "@teleportToEntity",
        MinAccess = "admin",
        Category = "@exploiting",
    },
}
