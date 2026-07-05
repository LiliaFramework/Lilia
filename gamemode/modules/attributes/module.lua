--[[
    Hooks:
        AdjustStaminaOffset(client, offset)

    Purpose:
        Allows code to adjust the computed stamina gain or drain before it is applied.

    Category:
        Attributes

    Parameters:
        client (Player)
            The player whose stamina value is being updated.

        offset (number)
            The pending stamina change for this tick. Negative values drain stamina and positive values regenerate it.

    Example Usage:
        ```lua
        hook.Add("AdjustStaminaOffset", "liaExampleAdjustStaminaOffset", function(client, offset)
            return (offset or 0) + 5
        end)
        ```

    Returns:
        number|nil
            Return a replacement stamina offset to override the default value, or nil to leave it unchanged.

    Realm:
        Shared
]]
MODULE.name = "@attributesModuleName"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@attributesSystemDescription"
