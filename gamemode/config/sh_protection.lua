function lia.config.load_protection()
    lia.config.DisallowedBagForbiddenActions = {
        ["Equip"] = true,
        ["EquipUn"] = true,
    }

    lia.config.TimeUntilDroppedSWEPRemoved = 30
    lia.config.PlayerSpawnVehicleDelay = 30
    lia.config.CharacterSwitchCooldownTimer = 5
    lia.config.NPCsDropWeapons = true
    lia.config.CarRagdoll = true
    lia.config.CharacterSwitchCooldown = true
    lia.config.PlayerSprayEnabled = true
    lia.config.AntiBunnyHopEnabled = true
    lia.config.BHOPStamina = 10
    lia.config.FlashlightEnabled = true
    lia.config.FlashlightItemNeeded = false
end