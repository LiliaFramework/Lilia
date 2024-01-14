concommand.Add(
    "lia",
    function(client, _, arguments)
        local command = arguments[1]
        table.remove(arguments, 1)
        lia.command.parse(client, nil, command or "", arguments)
    end
)

concommand.Add(
    "list_entities",
    function(client)
        local count = 0
        if client:IsSuperAdmin() then
            print("Entities on the server:")
            for _, ent in pairs(ents.GetAll()) do
                count = count + 1
                print(string.format("Entity #%d - Class: %s", ent:EntIndex(), ent:GetClass()))
            end

            print("There is currently " .. count .. " entities on the server.")
        else
            print("Nuh-uh!")
        end
    end
)
