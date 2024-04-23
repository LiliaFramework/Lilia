--[[--

**Configuration Values**:

- **FamilySharingEnabled**: Indicates whether Family Sharing is enabled on this server. | **bool**.

- **CarRagdoll**: Determines whether being hit by a car results in ragdolling. | **bool**.

- **OnDamageCharacterSwitchCooldown**: Specifies whether cooldown on character switching is enabled. | **bool**.

- **OnDamageCharacterSwitchCooldownTimer**: Sets the cooldown duration on character switching after taking damage. | **integer**.

- **SwitchCooldownOnAllEntities**: Specifies whether damage cooldown applies to all entities or just humans. If false, it applies only to humans. | **bool**.

- **CharacterSwitchCooldown**: Indicates whether a cooldown for character switching exists. | **bool**.

- **CharacterSwitchCooldownTimer**: Sets the duration of the character switch cooldown. | **integer**.

- **NPCsDropWeapons**: Controls whether NPCs drop weapons. | **bool**.

- **TimeUntilDroppedSWEPRemoved**: Specifies the duration until a dropped SWEP is removed. This pertains to actual SWEPs, not weapon items. | **bool**.

- **BlockedCollideEntities**: Lists entities with collisions disabled. | **table**.

- **KnownExploits**: Lists known exploits. | **table**.

- **HackCommands**: Lists commands available in the hack menu. | **table**.

- **HackGlobals**: Lists global variables accessible in the hack menu. | **table**.

- **BadCVars**: Lists undesirable console variables. | **table**.

- **ExploitableNetMessages**: Lists exploitable Net Messages. | **table**.
]]
-- @configurations Protection

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