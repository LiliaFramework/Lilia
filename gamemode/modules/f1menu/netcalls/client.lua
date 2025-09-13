net.Receive("removeF1", function() if IsValid(lia.gui.menu) then lia.gui.menu:remove() end end)
net.Receive("ForceUpdateF1", function()
    if IsValid(lia.gui.menu) then
        lia.gui.menu:Remove()
        vgui.Create("liaMenu")
    end
end)