---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------o
--[[ List of entities blocked from physgun move ]]
MODULE.RestrictedEnts = {"func_button", "class C_BaseEntity", "func_brush", "func_tracktrain", "func_door", "func_door_rotating", "prop_static", "prop_physics_override", "prop_dynamic", "func_movelinear", "prop_door_rotating", "lia_vendor"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of entities blocked from the remover tool ]]
MODULE.RemoverBlockedEntities = {"lia_bodygroupcloset", "lia_vendor",}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of entities blocked from the duplicator tool ]]
MODULE.DuplicatorBlackList = {"lia_storage", "lia_money"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of vehicles restricted from general spawn ]]
MODULE.RestrictedVehicles = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of props restricted from general spawn ]]
MODULE.BlackListedProps = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of props restricted from perma propping ]]
MODULE.CanNotPermaProp = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ List of button models to prevent button exploit ]]
MODULE.ButtonList = {"models/maxofs2d/button_01.mdl", "models/maxofs2d/button_02.mdl", "models/maxofs2d/button_03.mdl", "models/maxofs2d/button_04.mdl", "models/maxofs2d/button_05.mdl", "models/maxofs2d/button_06.mdl", "models/maxofs2d/button_slider.mdl"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Makes it so that props frozen can be passed through ]]
MODULE.PassableOnFreeze = false
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Delay for spawning a vehicle after the previous one ]]
MODULE.PlayerSpawnVehicleDelay = 30
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Adds ToolGun Cooldown ]]
MODULE.ToolInterval = 0.5
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
