net.Receive("AppearanceMenuOpen", function()
    local target = net.ReadEntity()
    local allowModelChange = net.ReadBool()
    local models = net.ReadTable()
    if not IsValid(target) then return end
    if IsValid(lia.gui.appearanceMenu) then
        lia.gui.appearanceMenu.suppressCloseSignal = true
        lia.gui.appearanceMenu:Remove()
    end
    lia.gui.appearanceMenu = vgui.Create("AppearanceMenu")
    lia.gui.appearanceMenu:SetData(target, models, allowModelChange)
end)

net.Receive("AppearanceMenuDismiss", function()
    if IsValid(lia.gui.appearanceMenu) then
        lia.gui.appearanceMenu.suppressCloseSignal = true
        lia.gui.appearanceMenu:Remove()
    end
end)
