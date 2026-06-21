--[[
    Hooks:
        CanCharBeTransfered(character, targetValue, previousValue)

    Purpose:
        Determines whether a character may be transferred to a different faction or class.

    Parameters:
        character (Character)
            The character being transferred.

        targetValue (number|string)
            The destination faction or class identifier.

        previousValue (number|string)
            The character's current faction or class identifier.

    Returns:
        boolean|nil
            Return false to block the transfer.

    Realm:
        Server
]]
--[[
    Hooks:
        CanInviteToClass(client, target)

    Purpose:
        Determines whether a player may invite another player to a class.

    Parameters:
        client (Player)
            The player sending the invite.

        target (Player)
            The player being invited.

    Returns:
        boolean|nil
            Return false to block the class invitation.

    Realm:
        Server
]]
--[[
    Hooks:
        CanInviteToFaction(client, target)

    Purpose:
        Determines whether a player may invite another player to a faction.

    Parameters:
        client (Player)
            The player sending the invite.

        target (Player)
            The player being invited.

    Returns:
        boolean|nil
            Return false to block the faction invitation.

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerJoinClass(client, class, info)

    Purpose:
        Determines whether a player may join a class during class eligibility checks.

    Parameters:
        client (Player)
            The player attempting to join the class.

        class (number)
            The class index being checked.

        info (table)
            The registered class data for the class.

    Returns:
        boolean|nil
            Return false to block the class join attempt.

    Realm:
        Server
]]
--[[
    Hooks:
        CheckFactionLimitReached(faction, character, client)

    Purpose:
        Allows code to override faction population limit checks.

    Parameters:
        faction (number|string)
            The faction being checked.

        character (Character)
            The character being evaluated for the faction.

        client (Player)
            The player associated with the character.

    Returns:
        boolean|nil
            Return true when the faction should be treated as full.

    Realm:
        Server
]]
--[[
    Hooks:
        OverrideFactionDesc(uniqueID, desc)

    Purpose:
        Allows clientside code to override a faction description before display.

    Parameters:
        uniqueID (string)
            The faction unique ID or display identifier.

        desc (string)
            The current faction description text.

    Returns:
        string|nil
            Return replacement description text.

    Realm:
        Client
]]
--[[
    Hooks:
        OverrideFactionModelCustomization(client, faction, context, skinAllowed, bodygroupsAllowed)

    Purpose:
        Allows clientside code to override whether faction model skins or bodygroups may be customized.

    Parameters:
        client (Player)
            The player viewing or creating the character.

        faction (table)
            The faction data being customized.

        context (any)
            The customization context provided by the caller.

        skinAllowed (boolean)
            The current skin customization permission.

        bodygroupsAllowed (boolean)
            The current bodygroup customization permission.

    Returns:
        boolean|nil, boolean|nil
            Return replacement values for skin and bodygroup customization permissions.

    Realm:
        Client
]]
--[[
    Hooks:
        OverrideFactionModels(uniqueID, models)

    Purpose:
        Allows clientside code to override the model list used for a faction.

    Parameters:
        uniqueID (string)
            The faction unique ID or display identifier.

        models (table)
            The current faction model list.

    Returns:
        table|nil
            Return a replacement model list.

    Realm:
        Client
]]
--[[
    Hooks:
        OverrideFactionName(uniqueID, name)

    Purpose:
        Allows clientside code to override a faction name before display.

    Parameters:
        uniqueID (string)
            The faction unique ID or display identifier.

        name (string)
            The current faction name.

    Returns:
        string|nil
            Return replacement faction name text.

    Realm:
        Client
]]
--[[
    Hooks:
        PopulateFactionRosterOptions(list, members)

    Purpose:
        Allows clientside code to add extra options to the faction roster UI.

    Parameters:
        list (table)
            The mutable list of roster option entries.

        members (table)
            The current roster member data.

    Returns:
        nil

    Realm:
        Client
]]
MODULE.name = "@teamsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@teamsSystemDescription"
MODULE.NetworkStrings = {"liaFactionMembers", "liaKickCharacterToBase", "liaRequestFactionMembers",}
MODULE.Privileges = {
    ["canManageFactions"] = {
        Name = "@canManageFactions",
        MinAccess = "admin",
        Category = "@factionManagement",
    },
    ["manageWhitelists"] = {
        Name = "@manageWhitelists",
        MinAccess = "admin",
        Category = "@factionManagement",
    },
}
