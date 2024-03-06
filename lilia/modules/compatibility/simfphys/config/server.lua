
--[[ Indicates whether damage while in cars is enabled   ]]
MODULE.DamageInCars = true

--[[ Valid Damages When DMGing a Car]]
MODULE.ValidCarDamages = {DMG_VEHICLE, DMG_BULLET}

--[[ Console Commands To Be Ran on Initialize ]]
MODULE.SimfphysConsoleCommands = {
    ["sv_simfphys_gib_lifetime"] = "0",
    ["sv_simfphys_fuel"] = "0",
    ["sv_simfphys_traction_snow"] = "1",
    ["sv_simfphys_damagemultiplicator"] = "100",
}

