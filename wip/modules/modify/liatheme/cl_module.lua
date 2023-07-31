function MODULE:ForceDermaSkin()
    if CONFIG.DarkTheme then return "lilia_darktheme" end
    return "lilia"
end

function MODULE:SpawnMenuOpen()
    timer.Simple(0, function()
        g_SpawnMenu:SetSkin("Default")
        g_SpawnMenu:GetToolMenu():SetSkin("Default")

        timer.Simple(0, function()
            derma.RefreshSkins()
        end)
    end)
end

function MODULE:OnContextMenuOpen()
    timer.Simple(0, function()
        g_ContextMenu:SetSkin("Default")

        timer.Simple(0, function()
            derma.RefreshSkins()
        end)
    end)
end