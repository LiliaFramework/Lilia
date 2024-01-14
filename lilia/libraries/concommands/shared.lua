concommand.Add("lia", function(client, _, arguments)
    local command = arguments[1]
    table.remove(arguments, 1)
    lia.command.parse(client, nil, command or "", arguments)
end)

concommand.Add("list_entities", function(client)
    if client:IsSuperAdmin() then
        print("Entities on the server:")
        for _, ent in pairs(ents.GetAll()) do
            print(string.format("Entity #%d - Class: %s", ent:EntIndex(), ent:GetClass()))
        end
    else
        print("Nuh-uh!")
    end
end)