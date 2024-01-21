--[[ List of entities blocked from physgun move ]]
PermissionCore.RestrictedEnts = {"func_button", "class C_BaseEntity", "func_brush", "func_tracktrain", "func_door", "func_door_rotating", "prop_static", "prop_physics_override", "prop_dynamic", "func_movelinear", "prop_door_rotating", "lia_vendor"}
--[[ List of entities blocked from the remover tool ]]
PermissionCore.RemoverBlockedEntities = {"lia_bodygroupcloset", "lia_vendor",}
--[[ List of entities blocked from the duplicator tool ]]
PermissionCore.DuplicatorBlackList = {"lia_storage", "lia_money"}
--[[ List of vehicles restricted from general spawn ]]
PermissionCore.RestrictedVehicles = {}
--[[ List of props restricted from general spawn ]]
PermissionCore.BlackListedProps = {}
--[[ List of props restricted from perma propping ]]
PermissionCore.CanNotPermaProp = {}
--[[ List of button models to prevent button exploit ]]
PermissionCore.ButtonList = {"models/maxofs2d/button_01.mdl", "models/maxofs2d/button_02.mdl", "models/maxofs2d/button_03.mdl", "models/maxofs2d/button_04.mdl", "models/maxofs2d/button_05.mdl", "models/maxofs2d/button_06.mdl", "models/maxofs2d/button_slider.mdl"}
--[[ Makes it so that props frozen can be passed through ]]
PermissionCore.PassableOnFreeze = false
--[[ Delay for spawning a vehicle after the previous one ]]
PermissionCore.PlayerSpawnVehicleDelay = 30
--[[ Adds ToolGun Cooldown ]]
PermissionCore.ToolInterval = 0.5