---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("BodygrouperMenu", function()
    if IsValid(MODULE.Menu) then MODULE.Menu:Remove() end
    local entity = net.ReadEntity()
    MODULE.Menu = vgui.Create("BodygrouperMenu")
    MODULE.Menu:SetTarget(IsValid(entity) and entity or LocalPlayer())
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("BodygrouperMenuCloseClientside", function() if IsValid(MODULE.Menu) then MODULE.Menu:Remove() end end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
