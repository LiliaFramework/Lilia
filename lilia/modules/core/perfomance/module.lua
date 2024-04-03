--[[--
Core - Perfomance.

This module adds several perfomance improving tweaks, both to clients and servers.

-- Configuration Values.

- **PlayerCountCarLimitEnabled**: Should Car Wipe be enabled?| **bool**.

- **PlayerCountCarLimit**: How many players are needed for cars to wipe | **integer**.

- **tblAlwaysSend**: Entities that transmit States | **table**.

- **RagdollCleaningTimer**: Time between Ragdolling Cleanups | **integer**.

- **SoundsToMute**: What sounds should be muted. | **table**.
]]
-- @moduleinfo perfomance
MODULE.tblPlayers = MODULE.tblPlayers or {}
MODULE.name = "Core - Perfomance"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds Perfomance"