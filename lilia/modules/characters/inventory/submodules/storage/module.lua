--[[--

- SaveStorage: Enable or disable the saving of storage data | bool.

- PasswordDelay: Set the delay (in seconds) until password retries are allowed | integer.

- StorageOpenTime: Set the duration (in seconds) for how long a storage container takes to open | **float**.

- TrunkOpenTime: Set the duration (in seconds) for how long a trunk takes to open | **float**.

- TrunkOpenDistance: Set the distance a trunk must be to be opened | integer.

- StorageDefinitions: List of props that will become storaged when spawned | table.

- VehicleTrunk: List of settings for car trunks | table.

]]
-- @configurations Storage
MODULE.name = "Framework Inventory - Storage"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Storage Options for Lilia's Inventory."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Spawn Storage",
        MinAccess = "superadmin",
        Description = "Allows access to Spawning Storage.",
    }
}
