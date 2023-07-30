-- @type command advertisement - Advertisement Command
-- @typeCommentStart
-- Sends an advertisement message to all players and deducts 25 Lilia Currency from the player's wallet.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /advertisement <string factions> <string text> - Send an advertisement message.
-- @usageEnd
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
                    client:notify("25 " .. lia.currency.plural .. " have been deducted from your wallet for advertising.")
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

-- @type command announce - Announcement Command
-- @typeCommentStart
-- Sends an announcement message to all players.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /announce <string factions> <string text> - Send an announcement message.
-- @usageEnd
lia.command.add("announce", {
    syntax = "<string factions> <string text>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        if not arguments[1] then return "Invalid argument (#1)" end
        local message = table.concat(arguments, " ", 1)

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        net.Start("announcement_client")
        net.WriteString(message)
        net.Broadcast()
        client:notify("Announcement sent.")
    end
})

-- @type command checkinventory - Check Inventory
-- @typeCommentStart
-- Opens the inventory of the specified player for inspection.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /checkinventory <string target> - Open the inventory of the specified player.
-- @usageEnd
lia.command.add("checkinventory", {
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not client:IsSuperAdmin() then return "This command is only available to Admin+" end

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