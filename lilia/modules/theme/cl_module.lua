--------------------------------------------------------------------------------------------------------------------------
function MODULE:ForceDermaSkin()
    if lia.config.DarkTheme then
        return "lilia_darktheme"
    else
        return "lilia"
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:SpawnMenuOpen()
    timer.Simple(
        0,
        function()
            g_SpawnMenu:SetSkin("Default")
            g_SpawnMenu:GetToolMenu():SetSkin("Default")
            timer.Simple(
                0,
                function()
                    derma.RefreshSkins()
                end
            )
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:OnContextMenuOpen()
    timer.Simple(
        0,
        function()
            g_ContextMenu:SetSkin("Default")
            timer.Simple(
                0,
                function()
                    derma.RefreshSkins()
                end
            )
        end
    )
end
--------------------------------------------------------------------------------------------------------------------------