local MODULE = MODULE
MODULE.name = "Storage Base"
MODULE.author = "Leonheart#7476/Cheesenot"
MODULE.desc = "Useful things for storage modules."
STORAGE_DEFINITIONS = STORAGE_DEFINITIONS or {}
MODULE.definitions = STORAGE_DEFINITIONS
lia.util.include("sv_storage.lua")
lia.util.include("sv_networking.lua")
lia.util.include("sv_access_rules.lua")
lia.util.include("cl_networking.lua")
lia.util.include("cl_password.lua")
lia.util.include("cl_storage.lua")
lia.util.include("sh_definitions.lua")
liaStorageBase = MODULE
lia.config.SaveStorage = true
lia.config.PasswordDelay = 1