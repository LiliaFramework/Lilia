netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.Options[name]
    if opt then
        local tracedEntity = client:GetTracedEntity()
        if opt.runServer then
            if IsValid(tracedEntity) then
                opt.onRun(client, tracedEntity)
                lia.log.add(client, "P2PAction", "Executed P2P Action '%s' on entity '%s'.", name, tostring(tracedEntity))
            else
                lia.log.add(client, "P2PAction", "Attempted to execute P2P Action '%s', but no valid entity was targeted.", name)
            end
        end
    else
        lia.log.add(client, "P2PAction", "Attempted to run non-existent P2P Action '%s'.", name)
    end
end)

netstream.Hook("PIMRunLocalOption", function(client, name)
    local opt = PIM.SelfOptions[name]
    if opt then
        if opt.runServer then
            opt.onRun(client)
            lia.log.add(client, "PersonalAction", "Executed Personal Action '%s'.", name)
        end
    else
        lia.log.add(client, "PersonalAction", "Attempted to run non-existent Personal Action '%s'.", name)
    end
end)

lia.log.addType("P2PAction", function(client, name, entity) return string.format("[%s] %s ran a P2P Action '%s' on entity '%s'.", client:SteamID(), client:Name(), name, entity) end, "P2P Actions", Color(255, 165, 0))
lia.log.addType("PersonalAction", function(client, name) return string.format("[%s] %s ran a Personal Action '%s'.", client:SteamID(), client:Name(), name) end, "Personal Actions", Color(255, 140, 0))