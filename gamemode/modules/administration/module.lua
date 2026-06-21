--[[
    Hooks:
        CharListColumns(columns)

    Purpose:
        Allows code to add extra columns to the administration character list.

    Parameters:
        columns (table)
            The mutable list of character list column definitions.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        CharListEntry(entry, row)

    Purpose:
        Allows code to append extra values to a generated character list row before it is sent to clients.

    Parameters:
        entry (table)
            The character entry data being serialized.

        row (table)
            The mutable row data that will be sent to the client.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        GetAdminESPTarget(ent, client)

    Purpose:
        Allows clientside code to override which entity should be treated as the admin ESP target.

    Parameters:
        ent (Entity)
            The entity currently under consideration.

        client (Player)
            The local player drawing admin ESP.

    Returns:
        Entity|false|nil
            Return a replacement target entity, or false to suppress the current target.

    Realm:
        Client
]]
--[[
    Hooks:
        OnAdminSystemLoaded(groups, privileges)

    Purpose:
        Called after the administration system finishes loading usergroups and privileges.

    Parameters:
        groups (table)
            The registered administration groups.

        privileges (table)
            The registered privilege definitions.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnPrivilegeRegistered(privilege)

    Purpose:
        Called after a new administration privilege is registered.

    Parameters:
        privilege (table)
            The registered privilege definition.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnPrivilegeUnregistered(privilege)

    Purpose:
        Called after an administration privilege is removed.

    Parameters:
        privilege (table)
            The privilege definition that was removed.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnSetUsergroup(sid, newGroup, source, player)

    Purpose:
        Called after the administration system changes a player's usergroup.

    Parameters:
        sid (string)
            The SteamID being updated.

        newGroup (string)
            The new usergroup name.

        source (string|nil)
            The source or provider that triggered the change.

        player (Player|nil)
            The online player object, if available.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnUsergroupCreated(groupName, groupData)

    Purpose:
        Called after a new administration usergroup is created.

    Parameters:
        groupName (string)
            The created usergroup name.

        groupData (table)
            The stored usergroup definition.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnUsergroupPermissionsChanged(groupName, groupData)

    Purpose:
        Called after a usergroup's permissions are changed.

    Parameters:
        groupName (string)
            The updated usergroup name.

        groupData (table)
            The updated usergroup definition.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnUsergroupRemoved(groupName)

    Purpose:
        Called after an administration usergroup is removed.

    Parameters:
        groupName (string)
            The removed usergroup name.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnUsergroupRenamed(oldName, newName)

    Purpose:
        Called after an administration usergroup is renamed.

    Parameters:
        oldName (string)
            The previous usergroup name.

        newName (string)
            The new usergroup name.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerGagged(target, admin)

    Purpose:
        Called after a player is gagged.

    Parameters:
        target (Player)
            The player who was gagged.

        admin (Player)
            The admin who applied the gag.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerMuted(target, admin)

    Purpose:
        Called after a player is muted.

    Parameters:
        target (Player)
            The player who was muted.

        admin (Player)
            The admin who applied the mute.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerUngagged(target, admin)

    Purpose:
        Called after a player is ungagged.

    Parameters:
        target (Player)
            The player who was ungagged.

        admin (Player)
            The admin who removed the gag.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerUnmuted(target, admin)

    Purpose:
        Called after a player is unmuted.

    Parameters:
        target (Player)
            The player who was unmuted.

        admin (Player)
            The admin who removed the mute.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        RunAdminSystemCommand(cmd, victim, dur, reason)

    Purpose:
        Allows clientside code to handle an admin command before the chat-command fallback runs.

    Parameters:
        cmd (string)
            The admin command being executed.

        victim (Player|string)
            The target player or identifier.

        dur (number|nil)
            The optional duration for timed commands.

        reason (string|nil)
            The optional reason text supplied with the command.

    Returns:
        boolean|nil, function|nil
            Return true and a callback to handle the command through the hook.

    Realm:
        Client
]]
MODULE.Name = "@categoryAdministration"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@administrationToolsDescription"
MODULE.NetworkStrings = {"liaAdminSetCharProperty", "liaAllFlags", "liaAllPks", "liaAllPlayers", "liaFeaturePositions", "liaFeaturePositionsRequest", "liaFullCharList", "liaManagesitroomsAction", "liaMapEntities", "liaOnlineStaffData", "liaPksCount", "liaRequestAllFlags", "liaRequestAllPks", "liaRequestFullCharList", "liaRequestMapEntities", "liaRequestPksCount", "liaRequestPlayers", "liaRequestStaffSummary", "liaSetFeaturePosition", "liaSpawnMenuGiveItem", "liaSpawnMenuSpawnItem", "liaStaffSummary",}
MODULE.Privileges = {
    ["ManageWeaponOverrides"] = {
        Name = "@ManageWeaponOverrides",
        MinAccess = "superadmin",
        Category = "@categoryStaffItems",
    },
    ["canUseItemSpawner"] = {
        Name = "@canUseItemSpawner",
        MinAccess = "admin",
        Category = "@categoryStaffItems",
    },
    ["managePropBlacklist"] = {
        Name = "@managePropBlacklist",
        MinAccess = "superadmin",
        Category = "@categoryBlacklisting",
    },
    ["staffHUD"] = {
        Name = "@staffHUD",
        MinAccess = "superadmin",
        Category = "developmentHUD",
    },
    ["developmentHUD"] = {
        Name = "@developmentHUD",
        MinAccess = "superadmin",
        Category = "developmentHUD",
    },
    ["manageBodygroups"] = {
        Name = "@manageBodygroups",
        MinAccess = "admin",
        Category = "bodygroups",
    },
    ["changeBodygroups"] = {
        Name = "@changeBodygroups",
        MinAccess = "admin",
        Category = "bodygroups",
    },
    ["manageVehicleBlacklist"] = {
        Name = "@manageVehicleBlacklist",
        MinAccess = "superadmin",
        Category = "@categoryBlacklisting",
    },
    ["accessEditConfigurationMenu"] = {
        Name = "@accessEditConfigurationMenu",
        MinAccess = "superadmin",
        Category = "@userInterface",
    },
    ["manageUsergroups"] = {
        Name = "@manageUsergroups",
        MinAccess = "superadmin",
        Category = "@categoryUsergroups",
    },
    ["viewStaffManagement"] = {
        Name = "@viewStaffManagement",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
    ["canAccessPlayerList"] = {
        Name = "@canAccessPlayerList",
        MinAccess = "admin",
        Category = "@players",
    },
    ["listCharacters"] = {
        Name = "@listCharacters",
        MinAccess = "admin",
        Category = "@character",
    },
    ["canAccessFlagManagement"] = {
        Name = "@canAccessFlagManagement",
        MinAccess = "superadmin",
        Category = "@flags",
    },
    ["createStaffCharacter"] = {
        Name = "@createStaffCharacter",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["canBypassSAMFactionWhitelist"] = {
        Name = "@canBypassSAMFactionWhitelist",
        MinAccess = "superadmin",
        Category = "@categorySAM",
    },
    ["canEditSimfphysCars"] = {
        Name = "@canEditSimfphysCars",
        MinAccess = "superadmin",
        Category = "@simfphysVehicles",
    },
    ["canSeeSAMNotificationsOutsideStaff"] = {
        Name = "@canSeeSAMNotificationsOutsideStaff",
        MinAccess = "superadmin",
        Category = "@categorySAM",
    },
    ["checkInventories"] = {
        Name = "@checkInventories",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageAttributes"] = {
        Name = "@manageAttributes",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageCharacterInformation"] = {
        Name = "@manageCharacterInformation",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageCharacters"] = {
        Name = "@manageCharacters",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageClasses"] = {
        Name = "@manageClasses",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageDoors"] = {
        Name = "@manageDoors",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageFlags"] = {
        Name = "@manageFlags",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageSitRooms"] = {
        Name = "@manageSitRooms",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["manageTransfers"] = {
        Name = "@manageTransfers",
        MinAccess = "admin",
        Category = "@categoryStaffManagement",
    },
    ["receiveCheaterNotifications"] = {
        Name = "@receiveCheaterNotifications",
        MinAccess = "admin",
        Category = "@exploiting",
    },
    ["stopSoundForEveryone"] = {
        Name = "@stopSoundForEveryone",
        MinAccess = "superadmin",
        Category = "@categoryServer",
    },
    ["useDisallowedTools"] = {
        Name = "@useDisallowedTools",
        MinAccess = "superadmin",
        Category = "@categoryStaffTools",
    },
    ["canBypassCharacterLock"] = {
        Name = "@canBypassCharacterLock",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
    ["canGrabWorldProps"] = {
        Name = "@canGrabWorldProps",
        MinAccess = "superadmin",
        Category = "@categoryStaffPhysgun",
    },
    ["canGrabPlayers"] = {
        Name = "@canGrabPlayers",
        MinAccess = "superadmin",
        Category = "@categoryStaffPhysgun",
    },
    ["physgunPickup"] = {
        Name = "@physgunPickup",
        MinAccess = "admin",
        Category = "@categoryStaffPhysgun",
    },
    ["canAccessItemInformations"] = {
        Name = "@canAccessItemInformations",
        MinAccess = "superadmin",
        Category = "@categoryStaffItems",
    },
    ["physgunPickupRestrictedEntities"] = {
        Name = "@physgunPickupRestrictedEntities",
        MinAccess = "superadmin",
        Category = "@categoryStaffPhysgun",
    },
    ["physgunPickupVehicles"] = {
        Name = "@physgunPickupVehicles",
        MinAccess = "admin",
        Category = "@categoryStaffPhysgun",
    },
    ["cantBeGrabbedPhysgun"] = {
        Name = "@cantBeGrabbedPhysgun",
        MinAccess = "superadmin",
        Category = "@categoryStaffProtection",
    },
    ["canPhysgunReload"] = {
        Name = "@canPhysgunReload",
        MinAccess = "superadmin",
        Category = "@categoryStaffPhysgun",
    },
    ["noClipOutsideStaff"] = {
        Name = "@noClipOutsideStaff",
        MinAccess = "superadmin",
        Category = "@categoryStaffMovement",
    },
    ["noClipESPOffsetStaff"] = {
        Name = "@noClipESPOffsetStaff",
        MinAccess = "superadmin",
        Category = "@userInterface",
    },
    ["canPropertyWorldEntities"] = {
        Name = "@canPropertyWorldEntities",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
    ["canSpawnRagdolls"] = {
        Name = "@canSpawnRagdolls",
        MinAccess = "admin",
        Category = "@spawnPermissions",
    },
    ["canSpawnSWEPs"] = {
        Name = "@canSpawnSWEPs",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["canEditWeapons"] = {
        Name = "@canEditWeapons",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["canSpawnEffects"] = {
        Name = "@canSpawnEffects",
        MinAccess = "admin",
        Category = "@spawnPermissions",
    },
    ["canSpawnProps"] = {
        Name = "@canSpawnProps",
        MinAccess = "admin",
        Category = "@spawnPermissions",
    },
    ["canSpawnBlacklistedProps"] = {
        Name = "@canSpawnBlacklistedProps",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["canSpawnNPCs"] = {
        Name = "@canSpawnNPCs",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["noCarSpawnDelay"] = {
        Name = "@noCarSpawnDelay",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["canSpawnCars"] = {
        Name = "@canSpawnCars",
        MinAccess = "admin",
        Category = "@spawnPermissions",
    },
    ["canSpawnBlacklistedCars"] = {
        Name = "@canSpawnBlacklistedCars",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    },
    ["canSpawnSENTs"] = {
        Name = "@canSpawnSENTs",
        MinAccess = "admin",
        Category = "@spawnPermissions",
    },
    ["canRemoveBlockedEntities"] = {
        Name = "@canRemoveBlockedEntities",
        MinAccess = "admin",
        Category = "@categoryStaffBlacklisting",
    },
    ["canRemoveWorldEntities"] = {
        Name = "@canRemoveWorldEntities",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
    ["usePositionTool"] = {
        Name = "@usePositionTool",
        MinAccess = "superadmin",
        Category = "@categoryStaffTools",
    },
    ["command_ban"] = {
        Name = "@commandBan",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_kick"] = {
        Name = "@commandKick",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_kill"] = {
        Name = "@commandKill",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_freeze"] = {
        Name = "@commandFreeze",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_unfreeze"] = {
        Name = "@commandUnfreeze",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_slay"] = {
        Name = "@commandSlay",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_respawn"] = {
        Name = "@commandRespawn",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_blind"] = {
        Name = "@commandBlind",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_unblind"] = {
        Name = "@commandUnblind",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_gag"] = {
        Name = "@commandGag",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_ungag"] = {
        Name = "@commandUngag",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_mute"] = {
        Name = "@commandMute",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_unmute"] = {
        Name = "@commandUnmute",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_bring"] = {
        Name = "@commandBring",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_goto"] = {
        Name = "@commandGoto",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_return"] = {
        Name = "@commandReturn",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_jail"] = {
        Name = "@commandJail",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_unjail"] = {
        Name = "@commandUnjail",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_cloak"] = {
        Name = "@commandCloak",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_uncloak"] = {
        Name = "@commandUncloak",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_god"] = {
        Name = "@commandGod",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_ungod"] = {
        Name = "@commandUngod",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_ignite"] = {
        Name = "@commandIgnite",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_extinguish"] = {
        Name = "@commandExtinguish",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["command_strip"] = {
        Name = "@commandStrip",
        MinAccess = "admin",
        Category = "@commands",
    },
    ["canManageNPCs"] = {
        Name = "@canManageNPCs",
        MinAccess = "admin",
        Category = "@npcs",
    },
    ["canManageProperties"] = {
        Name = "@canManageProperties",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
    ["seeInsertNotifications"] = {
        Name = "@seeInsertNotifications",
        MinAccess = "superadmin",
        Category = "@categoryStaffManagement",
    },
}
