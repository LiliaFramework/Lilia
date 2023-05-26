lia.command.add("CharPK", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            local targetchar = target:getChar()

            if not targetchar:getData("banned") then
                targetchar:ban()
                client:notify("Perma killed " .. target:Name())
            end
        end
    end
})

lia.command.add("flagpet", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target:getChar():hasFlags("pet") then
            target:getChar():takeFlags("pet")
            client:notify("Taken pet Flags!")
        else
            target:getChar():giveFlags("pet")
            client:notify("Given pet Flags!")
        end
    end
})

lia.command.add("charkick", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) then
            local char = target:getChar()

            if char then
                for k, v in ipairs(player.GetAll()) do
                    v:notifyLocalized("charKick", client:Name(), target:Name())
                end

                char:kick()
            end
        end
    end
})