----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:OpenOptionMenu(ply, target, isHandcuffed)
    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:Center()
    frame:ToggleVisible(false)
    local menu = DermaMenu()
    for name, command in pairs(lia.config.VisualizeOptions) do
    end

    menu:Open()
    menu:MakePopup()
    menu:Center()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------