local MODULE = MODULE
net.Receive("BodygrouperMenu", function()
    local client = LocalPlayer()
    if IsValid(MODULE.Menu) then MODULE.Menu:Remove() end
    local entity = net.ReadEntity()
    MODULE.Menu = vgui.Create("BodygrouperMenu")
    MODULE.Menu:SetTarget(IsValid(entity) and entity or client)
end)

net.Receive("BodygrouperMenuCloseClientside", function() if IsValid(MODULE.Menu) then MODULE.Menu:Remove() end end)
