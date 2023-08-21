--------------------------------------------------------------------------------------------------------
lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Management - Freeze All Props",
    onRun = function(client, arguments)
        for k, v in pairs(ents.FindByClass("prop_physics")) do
            local physObj = v:GetPhysicsObject()

            if IsValid(physObj) then
                physObj:EnableMotion(false)
                physObj:Sleep()
            end
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Management - Clean Items",
    onRun = function(client, arguments)
        local count = 0

        for k, v in pairs(ents.FindByClass("lia_item")) do
            count = count + 1
            v:Remove()
        end

        client:notify(count .. " items have been cleaned up from the map.")
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Management - Clean Props",
    onRun = function(client, arguments)
        local count = 0

        for k, v in pairs(ents.FindByClass("prop_physics")) do
            count = count + 1
            v:Remove()
        end

        client:notify(count .. " props have been cleaned up from the map.")
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Management - Clean NPCs",
    onRun = function(client, arguments)
        local count = 0

        for k, v in pairs(ents.GetAll()) do
            if IsValid(v) and v:IsNPC() then
                count = count + 1
                v:Remove()
            end
        end

        client:notify(count .. " NPCs have been cleaned up from the map.")
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("flags", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Management - Check Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            client:notify("Their character flags are: '" .. target:getChar():getFlags() .. "'")
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("clearchat", {
    superAdminOnly = true,
    privilege = "Management - Clear Chat",
    onRun = function(client, arguments)
        netstream.Start(player.GetAll(), "adminClearChat")
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("checkallmoney", {
    superAdminOnly = true,
    syntax = "<string charname>",
    privilege = "Management - Check All Money",
    onRun = function(client, arguments)
        for k, v in pairs(player.GetAll()) do
            if v:getChar() then
                client:ChatPrint(v:Name() .. " has " .. v:getChar():getMoney())
            end
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("return", {
    adminOnly = true,
    privilege = "Management - Return",
    onRun = function(client, arguments)
        if IsValid(client) and client:Alive() then
            local char = client:getChar()
            local oldPos = char:getData("deathPos")

            if oldPos then
                client:SetPos(oldPos)
                char:setData("deathPos", nil)
            else
                client:notify("No death position saved.")
            end
        else
            client:notify("Wait until you respawn.")
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Management - Find All Flags",
    onRun = function(client, arguments)
        for k, v in pairs(player.GetHumans()) do
            client:ChatPrint(v:Name() .. " — " .. v:getChar():getFlags())
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Management - Give Item",
    onRun = function(client, arguments)
        if not arguments[2] then return L("invalidArg", client, 2) end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            local uniqueID = arguments[2]:lower()

            if not lia.item.list[uniqueID] then
                for k, v in SortedPairs(lia.item.list) do
                    if lia.util.stringMatches(v.name, uniqueID) then
                        uniqueID = k
                        break
                    end
                end
            end

            local inv = target:getChar():getInv()
            local succ, err = inv:add(uniqueID)

            if succ then
                target:notifyLocalized("itemCreated")

                if target ~= client then
                    client:notifyLocalized("itemCreated")
                end
            else
                target:notify(tostring(succ))
                target:notify(tostring(err))
            end
        end
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("netmessagelogs", {
    superAdminOnly = true,
    privilege = "Management - Check Net Message Log",
    onRun = function(client, arguments)
        sendData(1, client)
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("returnitems", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Management - Return Items",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if lia.config.LoseWeapononDeathHuman or lia.config.LoseWeapononDeathNPC then
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

--------------------------------------------------------------------------------------------------------
lia.command.add("announce", {
    superAdminOnly = true,
    syntax = "<string factions> <string text>",
    privilege = "Management - Make Announcements",
    onRun = function(client, arguments)
        if not arguments[1] then return "Invalid argument (#1)" end
        local message = table.concat(arguments, " ", 1)
        net.Start("announcement_client")
        net.WriteString(message)
        net.Broadcast()
        client:notify("Announcement sent.")
    end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("logs", {
    adminOnly = true,
    privilege = "Management - Open MLogs",
    onRun = function(client, arguments)
        if not mLogs then
            client:notify("You don't have mLogs installed!")

            return false
        end
    end
})
--------------------------------------------------------------------------------------------------------