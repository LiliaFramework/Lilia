local UserGroups = UserGroups

lia.command.add("CharPK", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            local targetchar = target:getChar()

            if not targetchar:getData("permakilled") then
                targetchar:setData("permakilled", true)
                target:Spawn()
                client:notify("Perma killed " .. target:Name())
            end
        end
    end
})



lia.command.add("flagbank", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.superRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target:getChar():hasFlags("bl") then
            target:getChar():takeFlags("bl")
            client:notify("Taken bl Flag!")
        else
            target:getChar():giveFlags("bl")
            client:notify("Given bl Flag!")
        end
    end
})

lia.command.add("flagmedal", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target:getChar():hasFlags("m") then
            client:notify("Taken m Flag!")
            target:getChar():takeFlags("m")
        else
            client:notify("Given m Flag!")
            target:getChar():giveFlags("m")
        end
    end
})

lia.command.add("flagbroadcast", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target:getChar():hasFlags("B") then
            client:notify("Taken B Flag!")
            target:getChar():takeFlags("B")
        else
            target:getChar():giveFlags("B")
            client:notify("Given B Flag!")
        end
    end
})

lia.command.add("flagpet", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
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

lia.command.add("namechange", {
    syntax = "[character name]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local target = lia.command.findPlayer(client, arguments[1])

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        net.Start("namechange")
        net.WriteEntity(target)
        net.Send(client)
    end
})

lia.command.add("charkick", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
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