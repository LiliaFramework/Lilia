--- Configuration for Protection Module.
-- @realm shared
-- @configurations Protection
-- @table Configuration
-- @field FamilySharingEnabled Indicates whether Family Sharing is enabled on this server. | bool
-- @field CarRagdoll Determines whether being hit by a car results in ragdolling. | bool
-- @field OnDamageCharacterSwitchCooldown Specifies whether cooldown on character switching is enabled. | bool
-- @field OnDamageCharacterSwitchCooldownTimer Sets the cooldown duration on character switching after taking damage. | integer
-- @field SwitchCooldownOnAllEntities Specifies whether damage cooldown applies to all entities or just humans. If false, it applies only to humans. | bool
-- @field CharacterSwitchCooldown Indicates whether a cooldown for character switching exists. | bool
-- @field CharacterSwitchCooldownTimer Sets the duration of the character switch cooldown. | integer
-- @field NPCsDropWeapons Controls whether NPCs drop weapons. | bool
-- @field TimeUntilDroppedSWEPRemoved Specifies the duration until a dropped SWEP is removed. This pertains to actual SWEPs, not weapon items. | bool
-- @field BlockedCollideEntities Lists entities with collisions disabled. | table
-- @field KnownExploits Lists known exploits. | table
-- @field HackCommands Lists commands available in the hack menu. | table
-- @field HackGlobals Lists global variables accessible in the hack menu. | table
-- @field BadCVars Lists undesirable console variables. | table
-- @field ExploitableNetMessages Lists exploitable Net Messages. | table
MODULE.name = "Core - Protection"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements Lilia Protection Modules."
MODULE.identifier = "ProtectionCore"
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can See Family Sharing Notifications",
        MinAccess = "admin",
        Description = "Allows access to seeing Family Sharing Notifications ."
    },
}
