--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetspeed",
    {
        adminOnly = true,
        privilege = "Set Character Speed",
        syntax = "<string name> <number speed>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            local speed = tonumber(arguments[2]) or lia.config.get("walkSpeed")
            if IsValid(target) and target:getChar() then
                target:SetRunSpeed(speed)
            else
                client:notify("Invalid Target")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetjump",
    {
        adminOnly = true,
        privilege = "Set Character Jump",
        syntax = "<string name> <number power>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            local power = tonumber(arguments[2]) or 200
            if IsValid(target) and target:getChar() then
                target:SetJumpPower(power)
            else
                client:notify("Invalid Target")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charaddmoney",
    {
        privilege = "Add Money",
        superAdminOnly = true,
        syntax = "<string target> <number amount>",
        onRun = function(client, arguments)
            local amount = tonumber(arguments[2])
            if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 2 end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char and amount then
                    amount = math.Round(amount)
                    char:giveMoney(amount)
                    client:notify("You gave " .. lia.currency.get(amount) .. " to " .. target:Name())
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charban",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Ban Characters",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char then
                    client:notifyLocalized("charBan", client:Name(), target:Name())
                    char:setData("banned", true)
                    char:setData(
                        "charBanInfo",
                        {
                            name = client.steamName and client:steamName() or client:Nick(),
                            steamID = client:SteamID(),
                            rank = client:GetUserGroup()
                        }
                    )

                    char:save()
                    char:kick()
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetdesc",
    {
        adminOnly = true,
        syntax = "<string name> <string desc>",
        privilege = "Change Description",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if not IsValid(target) then return end
            if not target:getChar() then return "No character loaded" end
            local arg = table.concat(arguments, " ", 2)
            if not arg:find("%S") then
                return client:requestString(
                    "Change " .. target:Nick() .. "'s Description",
                    "Enter new description",
                    function(text)
                        lia.command.run(client, "charsetdesc", {arguments[1], text})
                    end, target:getChar():getDesc()
                )
            end

            local info = lia.char.vars.desc
            local result, fault, count = info.onValidate(arg)
            if result == false then return "@" .. fault, count end
            target:getChar():setDesc(arg)

            return "Successfully changed " .. target:Nick() .. "'s description"
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plytransfer",
    {
        adminOnly = true,
        syntax = "<string name> <string faction>",
        privilege = "Transfer Player",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            local name = table.concat(arguments, " ", 2)
            if IsValid(target) and target:getChar() then
                local faction = lia.faction.teams[name]
                if not faction then
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
                    hook.Run("PlayerOnFactionTransfer", target)
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetname",
    {
        adminOnly = true,
        syntax = "<string name> [string newName]",
        privilege = "Change Name",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and not arguments[2] then
                return client:requestString(
                    "@chgName",
                    "@chgNameDesc",
                    function(text)
                        lia.command.run(client, "charsetname", {target:Name(), text})
                    end, target:Name()
                )
            end

            table.remove(arguments, 1)
            local targetName = table.concat(arguments, " ")
            if IsValid(target) and target:getChar() then
                client:notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
                target:getChar():setName(targetName:gsub("#", "#?"))
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetmodel",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Retrieve Model",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                client:notify(target:GetModel())
            else
                client:notify("Invalid Target")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetmodel",
    {
        adminOnly = true,
        syntax = "<string name> <string model>",
        privilege = "Change Model",
        onRun = function(client, arguments)
            if not arguments[2] then return L("invalidArg", client, 2) end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                target:getChar():setModel(arguments[2])
                target:SetupHands()
                client:notifyLocalized("cChangeModel", client:Name(), target:Name(), arguments[2])
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetbodygroup",
    {
        adminOnly = true,
        syntax = "<string name> <string bodyGroup> [number value]",
        privilege = "Change Bodygroups",
        onRun = function(client, arguments)
            local value = tonumber(arguments[3])
            local target = lia.command.findPlayer(client, arguments[1])
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetskin",
    {
        adminOnly = true,
        syntax = "<string name> [number skin]",
        privilege = "Change Skin",
        onRun = function(client, arguments)
            local skin = tonumber(arguments[2])
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                target:getChar():setData("skin", skin)
                target:SetSkin(skin or 0)
                client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetmoney",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Retrieve Money",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                local char = target:getChar()
                client:notify(char:getMoney())
            else
                client:notify("Invalid Target")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetmoney",
    {
        superAdminOnly = true,
        syntax = "<string target> <number amount>",
        privilege = "Change Money",
        onRun = function(client, arguments)
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments)
            local attribName = arguments[2]
            if not attribName then return L("invalidArg", client, 2) end
            local attribNumber = arguments[3]
            attribNumber = tonumber(attribNumber)
            if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char then
                    for k, v in pairs(lia.attribs.list) do
                        if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                            char:setAttrib(k, math.abs(attribNumber))
                            client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))

                            return
                        end
                    end
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charaddattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments)
            local attribName = arguments[2]
            if not attribName then return L("invalidArg", client, 2) end
            local attribNumber = arguments[3]
            attribNumber = tonumber(attribNumber)
            if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char then
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkinventory",
    {
        superAdminOnly = true,
        syntax = "<string target>",
        privilege = "Check Inventory",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "clearinv",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Clear Inventory",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                for k, v in pairs(target:getChar():getInv():getItems()) do
                    v:remove()
                end

                client:notifyLocalized("resetInv", target:getChar():getName())
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flaggive",
    {
        adminOnly = true,
        syntax = "<string name> [string flags]",
        privilege = "Toggle Flags",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                local flags = arguments[2]
                if not flags then
                    local available = ""
                    for k in SortedPairs(lia.flag.list) do
                        if not target:getChar():hasFlags(k) then
                            available = available .. k
                        end
                    end

                    return client:requestString(
                        "@flagGiveTitle",
                        "@flagGiveDesc",
                        function(text)
                            lia.command.run(client, "flaggive", {target:Name(), text})
                        end, available
                    )
                end

                target:getChar():giveFlags(flags)
                client:notifyLocalized("flagGive", client:Name(), target:Name(), flags)
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagtake",
    {
        adminOnly = true,
        syntax = "<string name> [string flags]",
        privilege = "Toggle Flags",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then
                local flags = arguments[2]
                if not flags then
                    return client:requestString(
                        "@flagTakeTitle",
                        "@flagTakeDesc",
                        function(text)
                            lia.command.run(client, "flagtake", {target:Name(), text})
                        end, target:getChar():getFlags()
                    )
                end

                target:getChar():takeFlags(flags)
                client:notifyLocalized("flagTake", client:Name(), flags, target:Name())
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charkick",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Kick Characters",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plywhitelist",
    {
        adminOnly = true,
        privilege = "Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
                if faction and target:setWhitelisted(faction.index, true) then
                    for k, v in ipairs(player.GetAll()) do
                        v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
                    end
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plyunwhitelist",
    {
        adminOnly = true,
        privilege = "Un-Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
                if faction and target:setWhitelisted(faction.index, false) then
                    for k, v in ipairs(player.GetAll()) do
                        v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
                    end
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charunban",
    {
        syntax = "<string name>",
        superAdminOnly = true,
        privilege = "Un-Ban Characters",
        onRun = function(client, arguments)
            if (client.liaNextSearch or 0) >= CurTime() then return L("charSearching", client) end
            local name = table.concat(arguments, " ")
            for k, v in pairs(lia.char.loaded) do
                if lia.util.stringMatches(v:getName(), name) then
                    if v:getData("banned") then
                        v:setData("banned")
                        v:setData("permakilled")
                    else
                        return "@charNotBanned"
                    end

                    return lia.util.notifyLocalized("charUnBan", nil, client:Name(), v:getName())
                end
            end

            client.liaNextSearch = CurTime() + 15
            lia.db.query(
                "SELECT _id, _name, _data FROM lia_characters WHERE _name LIKE \"%" .. lia.db.escape(name) .. "%\" LIMIT 1",
                function(data)
                    if data and data[1] then
                        local charID = tonumber(data[1]._id)
                        local data = util.JSONToTable(data[1]._data or "[]")
                        client.liaNextSearch = 0
                        if not data.banned then return client:notifyLocalized("charNotBanned") end
                        data.banned = nil
                        lia.db.updateTable(
                            {
                                _data = data
                            }, nil, nil, "_id = " .. charID
                        )

                        lia.util.notifyLocalized("charUnBan", nil, client:Name(), lia.char.loaded[charID]:getName())
                    end
                end
            )
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "viewextdescription",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            net.Start("OpenDetailedDescriptions")
            net.WriteEntity(client)
            net.WriteString(client:getChar():getData("textDetDescData", nil) or "No detailed description found.")
            net.WriteString(client:getChar():getData("textDetDescDataURL", nil) or "No detailed description found.")
            net.Send(client)
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetextdescription",
    {
        adminOnly = true,
        privilege = "Change Description",
        onRun = function(client, arguments)
            net.Start("SetDetailedDescriptions")
            net.WriteString(client:steamName())
            net.Send(client)
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagpet",
    {
        privilege = "Give pet Flags",
        syntax = "[character name]",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target:getChar():hasFlags("pet") then
                target:getChar():takeFlags("pet")
                client:notify("Taken pet Flags!")
            else
                target:getChar():giveFlags("pet")
                client:notify("Given pet Flags!")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagragdoll",
    {
        adminOnly = true,
        privilege = "Hand Ragdoll Medals",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            target:getChar():giveFlags("r")
            client:notifyLocalized("You have given " .. arguments[1] .. " Ragdoll Flags")
            target:notifyLocalized("You have been given Ragdoll flags by " .. client:Name())
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flags",
    {
        privilege = "Check Flags",
        adminOnly = true,
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if not client:IsSuperAdmin() then
                client:notify("Your rank is not high enough to use this command.")

                return false
            end

            if IsValid(target) and target:getChar() then
                client:notify("Their character flags are: '" .. target:getChar():getFlags() .. "'")
            end
        end
    }
)
--------------------------------------------------------------------------------------------------------------------------