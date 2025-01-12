netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.Options[name]
    if opt then
        local tracedEntity = client:getTracedEntity()
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
    if opt and opt.runServer then opt.onRun(client) end
end)