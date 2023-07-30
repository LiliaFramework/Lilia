lia.config.add("StaminaBlur", false, "Whether or not the Stamina Blur shown.", nil, {
    category = "Client Settings"
})

lia.config.add("CrosshairEnabled", false, "Enables Crosshair?", nil, {
    category = "Client Settings"
})

lia.config.add("DrawEntityShadows", true, "Should Entity Shadows Be Drawn?", nil, {
    category = "Client Settings"
})

lia.config.add("vignette", true, "Whether or not the vignette is shown.", nil, {
    category = "Client Settings"
})

lia.config.add("BarsDisabled", false, "Whether or not Bars is Disabled.", nil, {
    category = "Client Settings"
})

lia.config.add("AmmoDrawEnabled", true, "Whether or not Ammo Draw is enabled.", nil, {
    category = "Client Settings"
})

lia.config.add("DarkTheme", false, "Whether or not Dark Theme is enabled.", nil, {
    category = "Client Settings"
})

lia.config.add("chatSizeDiff", false, "Whether or not to use different chat sizes.", nil, {
    category = "Client Settings"
})

lia.config.add("color", Color(75, 119, 190), "The main color theme for the framework.", nil, {
    category = "Client Settings"
})

lia.config.add("font", "Arial", "The font used to display titles.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", newValue, lia.config.get("genericFont"))
    end
end, {
    category = "Client Settings"
})

lia.config.add("genericFont", "Segoe UI", "The font used to display generic texts.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), newValue)
    end
end, {
    category = "Client Settings"
})

lia.config.add("fontScale", 1.0, "The scale for the font.", function(oldValue, newValue)
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))
    end
end, {
    form = "Float",
    data = {
        min = 0.1,
        max = 2.0
    },
    category = "Client Settings"
})