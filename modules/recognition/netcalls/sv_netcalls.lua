--------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgnDirect",
    function(client, target, name)
        if target:GetPos():DistToSqr(client:GetPos()) > 100000 then return end
        local character = client:getChar()
        local id = character:getID()

        if target:getChar():recognize(id, name) then
            netstream.Start(client, "rgnDone")
            hook.Run("OnCharRecognized", client, id)
            client:notifyLocalized("recognized")
        else
            client:notifyLocalized("already_recognized")
        end
    end
)

--------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgn",
    function(client, level, name)
        local targets = {}
        local character = client:getChar()
        local id = character:getID()

        if isnumber(level) then
            local class = "w"
            if level == 3 then
                class = "ic"
            elseif level == 4 then
                class = "y"
            end

            class = lia.chat.classes[class]
            for _, v in ipairs(player.GetAll()) do
                if client ~= v and v:getChar() and class.onCanHear(client, v) then
                    targets[#targets + 1] = v
                end
            end
        end

        if #targets > 0 then
            local i = 0
            for _, v in ipairs(targets) do
                if v:getChar():recognize(character, name) then
                    i = i + 1
                end
            end

            if i > 0 then
                netstream.Start(client, "rgnDone")
                hook.Run("OnCharRecognized", client, id)
            end
        end
    end
)
--------------------------------------------------------------------------------------------------------