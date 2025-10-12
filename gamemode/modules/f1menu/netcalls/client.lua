net.Receive("liaRemoveFOne", function() if IsValid(lia.gui.menu) then lia.gui.menu:remove() end end)
net.Receive("liaForceUpdateFOne", function()
    if IsValid(lia.gui.menu) then
        lia.gui.menu:Remove()
        vgui.Create("liaMenu")
    end
end)