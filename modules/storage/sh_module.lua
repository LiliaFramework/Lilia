--------------------------------------------------------------------------------------------------------
LiliaStorage = MODULE
lia.config.StorageDefinitions = lia.config.StorageDefinitions or {}
--------------------------------------------------------------------------------------------------------
MODULE.name = "Storage Base"
MODULE.author = "STEAM_0:1:176123778/Cheesenut"
MODULE.desc = "Useful things for storage modules."
--------------------------------------------------------------------------------------------------------
lia.util.include("sv_storage.lua")
lia.util.include("sv_networking.lua")
lia.util.include("sv_access_rules.lua")
lia.util.include("cl_networking.lua")
lia.util.include("cl_password.lua")
lia.util.include("cl_storage.lua")
lia.util.include("sh_definitions.lua")
--------------------------------------------------------------------------------------------------------
lia.config.SaveStorage = true
lia.config.PasswordDelay = 1
lia.config.StorageOpenTime = 0.7
--------------------------------------------------------------------------------------------------------