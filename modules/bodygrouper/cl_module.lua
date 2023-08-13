local MODULE = MODULE

net.Receive("BodygrouperMenu", function()
    if IsValid(MODULE.Menu) then
        MODULE.Menu:Remove()
    end

    local ent = net.ReadEntity()
    MODULE.Menu = vgui.Create("BodygrouperMenu")
    MODULE.Menu:SetTarget(IsValid(ent) and ent or LocalPlayer())
end)