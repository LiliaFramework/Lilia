------------------------------------------------------------------------------------------------------------------------
-- DISABLES CROSSHAIRS
function MODULE:ShouldDrawCrosshair()
    local wep = LocalPlayer():GetActiveWeapon()

    if wep and wep:IsValid() then
        if wep.ClassName == nil or wep.ClassName == "gmod_tool" or string.find(wep.ClassName, "lia_") or string.find(wep.ClassName, "detector_") then return true end

        return lia.config.CrosshairEnabled
    end

    return false
end