lia.command.add("returnitems", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if lia.config.get("LoseWeapononDeath", true) then
            if not client:IsAdmin() then
                client:notify("Your rank is not high enough to use this command.")

                return false
            end

            if IsValid(target) then
                if not target.LostItems then
                    client:notify("The target hasn't died recently or they had their items returned already!")

                    return
                end

                if table.IsEmpty(target.LostItems) then
                    client:notify("Cannot return any items; the player hasn't lost any!")

                    return
                end

                local char = target:getChar()
                if not char then return end
                local inv = char:getInv()
                if not inv then return end

                for k, v in pairs(target.LostItems) do
                    inv:add(v)
                end

                target.LostItems = nil
                target:notify("Your items have been returned.")
                client:notify("Returned the items.")
            end
        else
            client:notify("Weapon on Death not Enabled!")
        end
    end
})