---
net.Receive(
    "BodygrouperMenu",
    function()
        if IsValid(BodygrouperCore.Menu) then BodygrouperCore.Menu:Remove() end
        local ent = net.ReadEntity()
        BodygrouperCore.Menu = vgui.Create("BodygrouperMenu")
        BodygrouperCore.Menu:SetTarget(IsValid(ent) and ent or LocalPlayer())
    end
)
---
