netstream.Hook(
    "rgnDirect",
    function(client, target, name)
        if target:GetPos():DistToSqr(client:GetPos()) > 100000 then return end
        if target:getChar():recognize(client:getChar(), name) then
            netstream.Start(client, "rgnDone")
            hook.Run("OnCharRecognized", client, client:getChar())
            client:notifyLocalized("recognized")
        else
            client:notifyLocalized("already_recognized")
        end
    end
)

netstream.Hook(
    "rgn",
    function(client, level, name)
        local targets = {}
        if isnumber(level) then
            local class = "w"
            if level == 3 then
                class = "ic"
            elseif level == 4 then
                class = "y"
            end

            class = lia.chat.classes[class]
            for _, v in ipairs(player.GetAll()) do
                if client == v then continue end
                if v:getChar() and class.onCanHear(client, v) then targets[#targets + 1] = v end
            end
        end

        if #targets > 0 then
            local i = 0
            for _, v in ipairs(targets) do
                if v:getChar():recognize(client:getChar(), name) then i = i + 1 end
            end

            if i > 0 then
                netstream.Start(client, "rgnDone")
                hook.Run("OnCharRecognized", client)
            end
        end
    end
)
