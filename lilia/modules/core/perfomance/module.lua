--- Configuration for Perfomance Module.
-- @configurations Perfomance

--- This table defines the default settings for the Perfomance Module.
-- @realm shared
-- @table Configuration
-- @field PlayerCountCarLimitEnabled Should Car Wipe be enabled? | **bool**
-- @field PlayerCountCarLimit How many players are needed for cars to wipe | **integer**
-- @field tblAlwaysSend Entities that transmit States | **table**
-- @field RagdollCleaningTimer Time between Ragdolling Cleanups | **integer**
-- @field SoundsToMute What sounds should be muted | **table**
MODULE.tblPlayers = MODULE.tblPlayers or {}
MODULE.name = "Core - Perfomance"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Perfomance"
