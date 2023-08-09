function GM:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]

    if info.onSet then
        info:onSet(client)
    end

    if info2 and info2.onLeave then
        info2:onLeave(client)
    end

    netstream.Start(nil, "classUpdate", client)
end