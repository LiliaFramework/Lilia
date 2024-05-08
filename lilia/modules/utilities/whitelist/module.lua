--- Configuration for Server Whitelist Module.
-- @realm shared
-- @configurations Whitelist
-- @table Configuration
-- @field WhitelistEnabled Enable or disable the Whitelist | **bool**
-- @field BlacklistedEnabled Enable or disable the Blacklist | **bool**
-- @field BlacklistedSteamID64 Specify SteamID64s to be blacklisted from your server | **table**
-- @field WhitelistedSteamID64 Specify SteamID64s to be whitelisted from your server | **table**
MODULE.name = "Utilities - Server Whitelist"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a Server Whitelist"
MODULE.identifier = "WhitelistCore"
