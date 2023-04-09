function PLUGIN:ShowSpare1(client)
    if client:getChar() then
        netstream.Start(client, "rgnMenu")
    end
end

netstream.Hook("rgnDirect", function(client, target)
    if target:GetPos():DistToSqr(client:GetPos()) > 100000 then return end
    local id = client:getChar():getID()

    if target:getChar():recognize(id) then
        netstream.Start(client, "rgnDone")
        hook.Run("OnCharRecognized", client, id)
        client:notifyLocalized("recognized")
    else
        client:notifyLocalized("already_recognized")
    end
end)

netstream.Hook("rgn", function(client, level)
    local targets = {}

    if level < 2 then
        local entity = client:GetEyeTraceNoCursor().Entity

        if IsValid(entity) and entity:IsPlayer() and entity:getChar() and lia.chat.classes.ic.onCanHear(client, entity) then
            targets[1] = entity
        end
    else
        local class = "w"

        if level == 3 then
            class = "ic"
        elseif level == 4 then
            class = "y"
        end

        class = lia.chat.classes[class]

        for k, v in ipairs(player.GetAll()) do
            if client ~= v and v:getChar() and class.onCanHear(client, v) then
                targets[#targets + 1] = v
            end
        end
    end

    if #targets > 0 then
        local id = client:getChar():getID()
        local i = 0

        for k, v in ipairs(targets) do
            if v:getChar():recognize(id) then
                i = i + 1
            end
        end

        if i > 0 then
            netstream.Start(client, "rgnDone")
            hook.Run("OnCharRecognized", client, id)
        end
    end
end)