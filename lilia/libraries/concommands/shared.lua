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
        local entityCount = {}
        local totalEntities = 0

        if client:IsSuperAdmin() then
            print("Entities on the server:")
            for _, entity in pairs(ents.GetAll()) do
                local className = entity:GetClass()
                local entityName = entity:GetName()

                entityCount[className] = (entityCount[className] or {})
                entityCount[className][entityName] = (entityCount[className][entityName] or 0) + 1
                totalEntities = totalEntities + 1
            end

            for className, entities in pairs(entityCount) do
                for entityName, count in pairs(entities) do
                    print(string.format("Name: %s | Class: %s | Count: %d", entityName, className, count))
                end
            end

            print("Total entities on the server: " .. totalEntities)
        else
            print("Nuh-uh!")
        end
    end
)
