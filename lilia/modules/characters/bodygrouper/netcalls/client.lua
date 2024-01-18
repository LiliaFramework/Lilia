net.Receive(
    "BodygrouperMenu",
    function()
        if IsValid(BodygrouperCore.Menu) then BodygrouperCore.Menu:Remove() end
        local entity = net.ReadEntity()
        BodygrouperCore.Menu = vgui.Create("BodygrouperMenu")
        BodygrouperCore.Menu:SetTarget(IsValid(entity) and entity or LocalPlayer())
    end
)

net.Receive("BodygrouperMenuCloseClientside", function() if IsValid(BodygrouperCore.Menu) then BodygrouperCore.Menu:Remove() end end)
