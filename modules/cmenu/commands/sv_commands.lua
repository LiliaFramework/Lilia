----------------------------------------------------------------------------------------------
lia.command.add(
    "tieplayer",
    {
        onRun = function(client, arguments)
            local foundItem = false
            local target = client:GetTracedEntity()
            if not target:IsPlayer() then
                client:notify("Invalid Target!")

                return
            elseif not target:IsPlayer() then
                client:notify("Invalid Target!")

                return
            elseif client:VerifyCommandDistance(target) then
                client:notify("You can't use this from this distance!")

                return
            else
                for _, itemType in ipairs(lia.config.ZipTieItems) do
                    if client:getChar():getInv():hasItem(itemType) then
                        local item = client:getChar():getInv():getFirstItemOfType(itemType)
                        item:interact("Use", client)
                        foundItem = true
                        break
                    end
                end

                if not foundItem then
                    client:notify("You don't have a Tie!")
                end
            end
        end
    }
)
----------------------------------------------------------------------------------------------