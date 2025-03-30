net.Receive("rgnDirect", function(len, client)
    local target = net.ReadEntity()
    local name = net.ReadString()
    if target:GetPos():DistToSqr(client:GetPos()) > 100000 then return end
    if target:getChar():recognize(client:getChar(), name) then
        net.Start("rgnDone")
        net.Send(client)
        hook.Run("OnCharRecognized", client, client:getChar())
        lia.log.add(client, "charRecognize", target:getChar():getID(), name)
        client:notifyLocalized("recognized")
    else
        client:notifyLocalized("already_recognized")
    end
end)

net.Receive("rgn", function(len, client)
    local level = net.ReadInt(32)
    local name = net.ReadString()
    local targets = {}
    if isnumber(level) then
        local class = "w"
        if level == 3 then
            class = "ic"
        elseif level == 4 then
            class = "y"
        end

        class = lia.chat.classes[class]
        for _, v in player.Iterator() do
            if client == v then continue end
            if v:getChar() and class.onCanHear(client, v) then targets[#targets + 1] = v end
        end
    end

    if targets[1] then
        local i = 0
        for _, v in ipairs(targets) do
            if v:getChar():recognize(client:getChar(), name) then i = i + 1 end
        end

        if i > 0 then
            for _, v in ipairs(targets) do
                lia.log.add(client, "charRecognize", v:getChar():getID(), name)
            end

            net.Start("rgnDone")
            net.Send(client)
            hook.Run("OnCharRecognized", client)
        end
    end
end)