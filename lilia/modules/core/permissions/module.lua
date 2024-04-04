--[[--
Core - Permissions.

This module manages general permission configurations. It also contains the permission management modules within itself.

**Configuration Values:**.

- **RestrictedEnts**: List of entities blocked from physgun pick up and proprieties when used by regular players | **table**.

- **RemoverBlockedEntities**: List of entities blocked from the remover tool when used by regular players | **table**.

- **DuplicatorBlackList**: List of entities blocked from the duplicator tool when used by regular players | **table**.

- **RestrictedVehicles**: List of vehicles restricted from general spawn | **table**.

- **BlackListedProps**: List of props restricted from general spawn | **table**.

- **CanNotPermaProp**: List of entities restricted from perma propping | **table**.

- **ButtonList**: List of button models to prevent button spamming exploits | **table**.

- **PassableOnFreeze**: Makes it so that props frozen can be passed through when frozen | **bool**.

- **PlayerSpawnVehicleDelay**: Delay for spawning a vehicle after the previous one | **integer**.

- **ToolInterval**: ToolGun Usage Cooldown | **integer**.
]]
-- @moduleinfo permissions
MODULE.name = "Core - Permissions"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements CAMI Based Permissions."
MODULE.identifier = "PermissionCore"
MODULE.CAMIPrivileges = {
    {
        Name = "UserGroups - Staff Group",
        MinAccess = "admin",
        Description = "Defines Player as Staff."
    },
    {
        Name = "UserGroups - VIP Group",
        MinAccess = "superadmin",
        Description = "Defines Player as VIP."
    },
    {
        Name = "Staff Permissions - List Entities",
        MinAccess = "superadmin",
        Description = "Allows a User to List Entities."
    },
}