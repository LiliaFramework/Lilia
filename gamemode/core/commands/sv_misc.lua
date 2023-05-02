-------------------------------------------------------------------------------------------------------------------------
lia.command.add("advertisement", {
    syntax = "<string factions> <string text>",
    onRun = function(client, arguments)
        if not arguments[1] then return "Invalid argument (#1)" end
        local message = table.concat(arguments, " ", 1)

        if not client.advertdelay then
            client.advertdelay = 0
        end

        if CurTime() < client.advertdelay then
            client:notify("This command is in cooldown!")

            return
        else
            if string.len(message) <= 250 then
                if client:getChar():hasMoney(25) then
                    client.advertdelay = CurTime() + 60
                    client:getChar():takeMoney(25)
                    client:notify("25 Reichsmarks have been deducted from your wallet for advertising.")
                    net.Start("advert_client")
                    net.WriteString(client:Nick())
                    net.WriteString(message)
                    net.Broadcast()
                else
                    client:notify("You lack sufficient funds to make an advertisement.")

                    return
                end
            else
                client:notify("This Advertisement is too big.")
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("announce", {
    syntax = "<string factions> <string text>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        if not arguments[1] then return "Invalid argument (#1)" end
        local message = table.concat(arguments, " ", 1)

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        net.Start("announcement_client")
        net.WriteString(message)
        net.Broadcast()
        client:notify("Announcement sent.")
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("checkinventory", {
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not UserGroups.adminRanks[client:GetUserGroup()] then return "This command is only available to Admin+" end

        if IsValid(target) and target:getChar() and target ~= client then
            local inventory = target:getChar():getInv()
            inventory:addAccessRule(ItemCanEnterForEveryone, 1)
            inventory:addAccessRule(CanReplicateItemsForEveryone, 1)
            inventory:sync(client)
            net.Start("OpenInvMenu")
            net.WriteEntity(target)
            net.WriteType(inventory:getID())
            net.Send(client)
        elseif target == client then
            client:notifyLocalized("This isn't meant for checking your own inventory.")
        end
    end
})