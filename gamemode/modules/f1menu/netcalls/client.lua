net.Receive("liaRemoveFOne", function() if IsValid(lia.gui.menu) then lia.gui.menu:remove() end end)
net.Receive("liaForceUpdateFOne", function()
    if IsValid(lia.gui.menu) then
        lia.gui.menu:Remove()
        vgui.Create("liaMenu")
    end
end)

net.Receive("liaCfgSet", function()
    local key = net.ReadString()
    local value = net.ReadType()
    if key == "Theme" then
        lia.config.set(key, value)
        lia.color.applyTheme(value, true)
        if IsValid(lia.gui.menu) and lia.gui.menu.currentTab == "themes" then
            lia.gui.menu:Remove()
            vgui.Create("liaMenu")
        end
    elseif key == "Font" then
        lia.config.set(key, value)
        if IsValid(lia.gui.menu) then lia.gui.menu:Update() end
    end
end)
