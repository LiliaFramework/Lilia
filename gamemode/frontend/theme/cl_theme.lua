hook.Add(
    "ForceDermaSkin",
    "ThemeForceDermaSkin",
    function()
        if lia.config.DarkTheme then
            return "lilia_darktheme"
        else
            return "lilia"
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "SpawnMenuOpen",
    "ThemeSpawnMenuOpen",
    function()
        timer.Simple(
            0,
            function()
                g_SpawnMenu:SetSkin("Default")
                g_SpawnMenu:GetToolMenu():SetSkin("Default")
                timer.Simple(0, function() derma.RefreshSkins() end)
            end
        )
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "OnContextMenuOpen",
    "ThemeOnContextMenuOpen",
    function()
        timer.Simple(
            0,
            function()
                g_ContextMenu:SetSkin("Default")
                timer.Simple(0, function() derma.RefreshSkins() end)
            end
        )
    end
)
--------------------------------------------------------------------------------------------------------