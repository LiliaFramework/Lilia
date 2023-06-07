-- @type method charsetdesc - Set Character Description
-- @typeCommentStart
-- Sets the description for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetdesc <name> <desc> - Sets the description for the character with the specified name.
-- @usageEnd
lia.command.add("charsetdesc", {
    syntax = "<string name> <string desc>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then return end
        if not target:getChar() then return "No character loaded" end
        local arg = table.concat(arguments, " ", 2)

        if not arg:find("%S") then
            return client:requestString("Change " .. target:Nick() .. "'s Description", "Enter new description", function(text)
                lia.command.run(client, "charsetdesc", {arguments[1], text})
            end, target:getChar():getDesc())
        end

        local info = lia.char.vars.desc
        local result, fault, count = info.onValidate(arg)
        if result == false then return "@" .. fault, count end
        target:getChar():setDesc(arg)

        return "Successfully changed " .. target:Nick() .. "'s description"
    end
})

-- @type command charsetattrib - Set Character Attribute
-- @typeCommentStart
-- Allows super-admin users to set attributes for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetattrib <string charname> <string attribname> <number level> - Set the attribute level for a character.
-- @usageEnd
lia.command.add("charsetattrib", {
    syntax = "<string charname> <string attribname> <number level>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        -- Check if the client has the required rank to use this command
        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local attribName = arguments[2]
        if not attribName then return L("invalidArg", client, 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
        -- Find the target player
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                -- Loop through the attribute list to find the matching attribute
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        -- Set the attribute level for the character
                        char:setAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))

                        return
                    end
                end
            end
        end
    end
})

-- @type command charsetattrib - Add Character Attributes
-- @typeCommentStart
-- Allows super-admin users to add attributes for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetattrib <string charname> <string attribname> <number level> - Adds the attribute level for a character.
-- @usageEnd
lia.command.add("charaddattrib", {
    syntax = "<string charname> <string attribname> <number level>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        -- Check if the client is a super-admin
        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local attribName = arguments[2]
        if not attribName then return L("invalidArg", client, 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                -- Loop through the attributes to find a match
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        char:updateAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribUpdate", target:Name(), L(v.name, client), math.abs(attribNumber))

                        return
                    end
                end
            end
        end
    end
})

-- @type command plytransfer - Transfer Player
-- @typeCommentStart
-- Allows admin users to transfer a player to a different faction.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /plytransfer <string name> <string faction> - Transfer the specified player to the specified faction.
-- @usageEnd
lia.command.add("plytransfer", {
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        -- Check if the client is an admin
        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        local name = table.concat(arguments, " ", 2)
        if IsValid(target) and target == client and not client:IsSuperAdmin() then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            local faction = lia.faction.teams[name]

            if not faction then
                -- Loop through the factions to find a match
                for k, v in pairs(lia.faction.indices) do
                    if lia.util.stringMatches(L(v.name, client), name) then
                        faction = v
                        break
                    end
                end
            end

            if faction then
                target:getChar().vars.faction = faction.uniqueID
                target:getChar():setFaction(faction.index)

                if faction.onTransfered then
                    faction:onTransfered(target)
                end

                client:notify("You have transferred " .. target:Name() .. " to " .. faction.name)
                target:notify("You have been transferred to " .. faction.name .. " by " .. client:Name())
            else
                return "@invalidFaction"
            end
        end
    end
})

-- @type command charsetname - Set Character Name
-- @typeCommentStart
-- Allows admin users to set the name of a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetname <string name> [string newName] - Set the name of the specified character. If the new name is not provided, a prompt will appear to enter the new name.
-- @usageEnd
lia.command.add("charsetname", {
    syntax = "<string name> [string newName]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        -- Check if the client is an admin
        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and not client:IsSuperAdmin() then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and not arguments[2] then
            return client:requestString("@chgName", "@chgNameDesc", function(text)
                lia.command.run(client, "charsetname", {target:Name(), text})
            end, target:Name())
        end

        table.remove(arguments, 1)
        local targetName = table.concat(arguments, " ")

        if IsValid(target) and target:getChar() then
            client:notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
            target:getChar():setName(targetName:gsub("#", "#?"))
        end
    end
})

-- @type command charsetmodel - Set Character Model
-- @typeCommentStart
-- Allows admin users to set the model of a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetmodel <string name> <string model> - Set the model of the specified character.
-- @usageEnd
lia.command.add("charsetmodel", {
    syntax = "<string name> <string model>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        -- Check if the client is an admin
        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if not arguments[2] then return L("invalidArg", client, 2) end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and not client:IsSuperAdmin() then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            target:getChar():setModel(arguments[2])
            target:SetupHands()
            client:notifyLocalized("cChangeModel", client:Name(), target:Name(), arguments[2])
        end
    end
})

-- @type command charsetskin - Set Character Skin
-- @typeCommentStart
-- Allows admin users to set the skin for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetskin <string name> [number skin] - Set the skin for a character.
-- @usageEnd
lia.command.add("charsetskin", {
    syntax = "<string name> [number skin]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local skin = tonumber(arguments[2])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and not client:IsSuperAdmin() then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
        end
    end
})

-- @type command charsetbodygroup - Set Character Bodygroup
-- @typeCommentStart
-- Allows admin users to set the bodygroup value for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetbodygroup <string name> <string bodyGroup> [number value] - Set the bodygroup value for a character.
-- @usageEnd
lia.command.add("charsetbodygroup", {
    syntax = "<string name> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local value = tonumber(arguments[3])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and not client:IsSuperAdmin() then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            local index = target:FindBodygroupByName(arguments[2])

            if index > -1 then
                if value and value < 1 then
                    value = nil
                end

                local groups = target:getChar():getData("groups", {})
                groups[index] = value
                target:getChar():setData("groups", groups)
                target:SetBodygroup(index, value or 0)
                client:notifyLocalized("cChangeGroups", client:Name(), target:Name(), arguments[2], value or 0)
            else
                return "@invalidArg", 2
            end
        end
    end
})

-- @type command charban - Ban Character
-- @typeCommentStart
-- Allows superadmin users to ban a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charban <string name> - Ban a character.
-- @usageEnd
lia.command.add("charban", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                client:notifyLocalized("charBan", client:Name(), target:Name())
                char:setData("banned", true)

                char:setData("charBanInfo", {
                    name = client.SteamName and client:SteamName() or client:Nick(),
                    steamID = client:SteamID(),
                    rank = client:GetUserGroup()
                })

                char:save()
                char:kick()
            end
        end
    end
})

-- @type command charselectskin - Select Character Skin
-- @typeCommentStart
-- Allows superadmin users to select a skin for their own character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charselectskin [number skin] - Select a skin for your own character.
-- @usageEnd
lia.command.add("charselectskin", {
    syntax = "[number skin]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local skin = tonumber(arguments[1])
        local target = client

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", nil, client:Name(), target:Name(), skin or 0)
        end
    end
})

-- @type command charselectbodygroup - Select Character Bodygroup
-- @typeCommentStart
-- Allows superadmin users to select a bodygroup value for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charselectbodygroup <string target> <string bodyGroup> [number value] - Select a bodygroup value for a character.
-- @usageEnd
lia.command.add("charselectbodygroup", {
    syntax = "<string target> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local value = tonumber(arguments[2])
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if not arguments[1] then
            client:notify("No bodygroup specified.")

            return false
        end

        if IsValid(client) and client:getChar() then
            local index = client:FindBodygroupByName(arguments[1])

            if index > -1 then
                if value and value < 1 then
                    value = nil
                end

                local groups = client:getChar():getData("groups", {})
                groups[index] = value
                client:getChar():setData("groups", groups)
                client:SetBodygroup(index, value or 0)
                client:notify("Bodygroup changed successfully")
                client:notifyLocalized("cChangeGroups", nil, client:Name(), target:Name(), arguments[2], value or 0)
            else
                return "@invalidArg", 2
            end
        end
    end
})

-- @type command charforceunequip - Force Unequip Character Items
-- @typeCommentStart
-- Allows superadmin users to force unequip all items from a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charforceunequip <string name> - Force unequip all items from a character.
-- @usageEnd
lia.command.add("charforceunequip", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            local inventory = target:getChar():getInv()

            for k, v in pairs(inventory:getItems()) do
                if v:getData("equip") then
                    v:setData("equip", false)
                end
            end
        end
    end
})

-- @type command chargetmoney - Get Character Money
-- @typeCommentStart
-- Allows admin users to retrieve the amount of money a character has.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /chargetmoney <string name> - Get the amount of money a character has.
-- @usageEnd
lia.command.add("chargetmoney", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            local char = target:getChar()
            client:notify(char:getMoney())
        else
            client:notify("Invalid Target")
        end
    end
})

-- @type command chargetmodel - Get Character Model
-- @typeCommentStart
-- Allows admin users to retrieve the model of a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /chargetmodel <string name> - Get the model of a character.
-- @usageEnd
lia.command.add("chargetmodel", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            client:notify(target:GetModel())
        else
            client:notify("Invalid Target")
        end
    end
})

-- @type command checkallmoney - Check All Player's Money
-- @typeCommentStart
-- Allows superadmin users to check the amount of money for all players who have a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /checkallmoney <string charname> - Check the amount of money for all players who have a character.
-- @usageEnd
lia.command.add("checkallmoney", {
    syntax = "<string charname>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        for k, v in pairs(player.GetAll()) do
            if v:getChar() then
                client:ChatPrint(v:Name() .. " has " .. v:getChar():getMoney())
            end
        end
    end
})

-- @type command bringlostitems - Bring Lost Items
-- @typeCommentStart
-- Allows superadmin users to bring lost items within a certain range to their current position.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /bringlostitems - Bring lost items within a certain range to your current position.
-- @usageEnd
lia.command.add("bringlostitems", {
    syntax = "",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        for k, v in pairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:GetClass() == "lia_item" then
                v:SetPos(client:GetPos())
            end
        end
    end
})

-- @type command logs - Open mLogs Menu
-- @typeCommentStart
-- Allows admin users to open the mLogs menu.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /logs - Open the mLogs menu.
-- @usageEnd
lia.command.add("logs", {
    adminOnly = false,
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        elseif not mLogs then
            client:notify("You don't have mLogs installed!")

            return false
        end

        client:ConCommand("mLogs")
    end
})

-- @type command chargiveitem - Give Item to Character
-- @typeCommentStart
-- Allows superadmin users to give an item to a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /chargiveitem <string name> <string item> - Give an item to a character.
-- @usageEnd
lia.command.add("chargiveitem", {
    syntax = "<string name> <string item>",
    onRun = function(client, arguments)
        local rank = client:GetUserGroup()

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

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
            local succ, err = target:getChar():getInv():add(uniqueID)

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

-- @type command charsetmoney - Set Character's Money
-- @typeCommentStart
-- Allows superadmin users to set the amount of money for a character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /charsetmoney <string target> <number amount> - Set the amount of money for a character.
-- @usageEnd
lia.command.add("charsetmoney", {
    syntax = "<string target> <number amount>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local amount = tonumber(arguments[2])
        if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 2 end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char and amount then
                amount = math.Round(amount)
                char:setMoney(amount)
                client:notifyLocalized("setMoney", target:Name(), lia.currency.get(amount))
            end
        end
    end
})

-- @type command getpos - Get Player Position
-- @typeCommentStart
-- Prints the current position of the player in the chat.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /getpos - Get your current position.
-- @usageEnd
lia.command.add("getpos", {
    onRun = function(client, arguments)
        client:ChatPrint("MY POSITION: " .. tostring(client:GetPos()))
    end
})

-- @type command doorname - Get Door Name
-- @typeCommentStart
-- Prints the name of the door that the player is looking at.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /doorname - Get the name of the door you are looking at.
-- @usageEnd
lia.command.add("doorname", {
    onRun = function(client, arguments)
        local tr = util.TraceLine(util.GetPlayerTrace(client))

        if IsValid(tr.Entity) then
            print("I saw a " .. tr.Entity:GetName())
        end
    end
})

-- @type command factionlist - List Factions
-- @typeCommentStart
-- Lists all factions with their names and unique IDs.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /factionlist - List all factions.
-- @usageEnd
lia.command.add("factionlist", {
    syntax = "<string text>",
    onRun = function(client, arguments)
        for k, v in ipairs(lia.faction.indices) do
            client:ChatPrint("NAME: " .. v.name .. " ID: " .. v.uniqueID)
        end
    end
})