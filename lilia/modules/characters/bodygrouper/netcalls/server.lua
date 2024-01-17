util.AddNetworkString("BodygrouperMenu")
util.AddNetworkString("BodygrouperMenuClose")
util.AddNetworkString("BodygrouperMenuCloseClientside")
net.Receive(
    "BodygrouperMenuClose",
    function(_, client)
        for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
            if v:HasUser(client) then v:RemoveUser(client) end
        end
    end
)

net.Receive(
    "BodygrouperMenu",
    function(_, client)
        local target = net.ReadEntity()
        local skn = net.ReadUInt(10)
        local groups = net.ReadTable()
        local closetuser = false
        if not IsValid(target) then return end
        if target ~= client then
            if not CAMI.PlayerHasAccess(client, "Commands - Change Bodygroups", nil) then
                client:notifyLocalized("noAccess")
                return
            end
        else
            if not BodygrouperCore:CanAccessMenu(client) then
                client:notifyLocalized("noAccess")
                return
            end

            closetuser = true
        end

        if target:SkinCount() and skn > target:SkinCount() then
            client:notifyLocalized("invalidSkin")
            return
        end

        if target:GetNumBodyGroups() and target:GetNumBodyGroups() > 0 then
            for k, v in pairs(groups) do
                if v > target:GetBodygroupCount(k) then
                    client:notifyLocalized("invalidBodygroup")
                    return
                end
            end
        end

        local char = target:getChar()
        if not char then return end
        target:SetSkin(skn)
        char:setData("skin", skn)
        for k, v in pairs(groups) do
            target:SetBodygroup(k, v)
        end

        char:setData("groups", groups)
        if target == client then
            target:notifyLocalized("bodygroupChanged", "your")
        else
            client:notifyLocalized("bodygroupChanged", target:Name() .. "'s")
            target:notifyLocalized("bodygroupChangedBy", client:Name())
        end
        
        net.Start("BodygrouperMenuCloseClientside")
        net.Send(client)

        client:SendLua("BodygrouperCore.Menu:Close()")
        if closetuser then
            for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
                if v:HasUser(target) then v:RemoveUser(target) end
            end
        end
    end
)