--- Configuration for Storage Module.
-- @realm shared
-- @configurations Storage

-- @table Configuration
-- @field SaveStorage Enable or disable the saving of storage data | bool
-- @field PasswordDelay Set the delay (in seconds) until password retries are allowed | integer
-- @field StorageOpenTime Set the duration (in seconds) for how long a storage container takes to open | **float**
-- @field TrunkOpenTime Set the duration (in seconds) for how long a trunk takes to open | **float**
-- @field TrunkOpenDistance Set the distance a trunk must be to be opened | integer
-- @field StorageDefinitions List of props that will become storaged when spawned | table
-- @field VehicleTrunk List of settings for car trunks | table
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
