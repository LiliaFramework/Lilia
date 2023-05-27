-- This Library is just for PAC3 Integration.
-- You must install PAC3 to make this library works.

PLUGIN.name = "PAC3 Integration"
PLUGIN.author = "Leonheart#7476/Black Tea"
PLUGIN.desc = "More Upgraded, More well organized PAC3 Integration made by Black Tea"
PLUGIN.partData = {}

if (not pac) then
	return
end

lia.util.include("sh_permissions.lua")
lia.util.include("sh_pacoutfit.lua")
lia.util.include("sv_parts.lua")
lia.util.include("cl_parts.lua")
lia.util.include("cl_ragdolls.lua")
