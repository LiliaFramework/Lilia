
MODULE.partData = {}

if not pac then return end

MODULE.name = "PAC3 Integration"
MODULE.author = "STEAM_0:1:176123778/Black Tea"
MODULE.desc = "More Upgraded, More well organized PAC3 Integration made by Black Tea"

lia.util.include("sh_permissions.lua")
lia.util.include("sh_pacoutfit.lua")
lia.util.include("sv_parts.lua")
lia.util.include("cl_parts.lua")
lia.util.include("cl_ragdolls.lua")

lia.config.PACFlag = "P"

lia.flag.add(lia.config.PACFlag, "Access to PAC3.")
