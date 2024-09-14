lia.command.add("playglobalsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    onRun = function(_, arguments)
        local sound = arguments[1]
        for _, v in pairs(player.GetAll()) do
            v:PlaySound(sound)
        end
    end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    syntax = "<string name> <string sound>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local sound = arguments[2]
        target:PlaySound(sound)
    end
})

lia.command.add("return", {
    adminOnly = true,
    privilege = "Return Players",
    onRun = function(client)
        if IsValid(client) and client:Alive() then
            local character = client:getChar()
            local oldPos = character:getData("deathPos")
            if oldPos then
                client:SetPos(oldPos)
                character:setData("deathPos", nil)
            else
                client:notify("No death position saved.")
            end
        else
            client:notify("Wait until you respawn.")
        end
    end
})

lia.command.add("roll", {
    adminOnly = false,
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
        lia.log.add(client, "roll", rollValue)
    end
})

lia.command.add("chardesc", {
    adminOnly = false,
    syntax = "<string desc>",
    onRun = function(client, arguments)
        arguments = table.concat(arguments, " ")
        if not arguments:find("%S") then return client:requestString("Change Description", "Change Your Description", function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar():getDesc()) end
        client:getChar():setDesc(arguments)
        return "@descChanged"
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    onRun = function(client)
        if not client:hasRagdoll() then client:notify("You don't have a ragdoll to get up from!") end
        local entity = client:getRagdoll()
        if entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("@gettingUp", 5, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end
    end
})

lia.command.add("givemoney", {
    adminOnly = false,
    syntax = "<number amount>",
    onRun = function(client, arguments)
        local number = tonumber(arguments[1])
        number = number or 0
        local amount = math.floor(number)
        if not amount or not isnumber(amount) or amount <= 0 then return L("invalidArg", client, 1) end
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local target = util.TraceLine(data).Entity
        if IsValid(target) and target:IsPlayer() and target:getChar() then
            amount = math.Round(amount)
            if not client:getChar():hasMoney(amount) then return end
            target:getChar():giveMoney(amount)
            client:getChar():takeMoney(amount)
            local character = client:getChar()
            local id = target:getChar():getID()
            local tCharacter = target:getChar()
            local charID = client:getChar():getID()
            target:notify("You were given " .. lia.currency.get(amount) .. " by " .. (hook.Run("isCharRecognized", tCharacter, charID) and client:Name() or "someone you don't recognize"))
            client:notify("You gave " .. lia.currency.get(amount) .. " to " .. (hook.Run("isCharRecognized", character, id) and target:Name() or "someone you don't recognize"))
            client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
            lia.log.add(client, "moneyGiven", target:Name(), amount)
        else
            client:notify("You need to be looking at someone!")
        end
    end
})

lia.command.add("fallover", {
    adminOnly = false,
    syntax = "[number time]",
    onRun = function(client, arguments)
        if client:GetNW2Bool("FallOverCooldown", false) then
            client:notify("This Command Is In Cooldown!")
            return
        elseif client:IsFrozen() then
            client:notify("You cannot use this while frozen!")
            return
        elseif not client:Alive() then
            client:notify("You cannot use this while dead!")
            return
        elseif client:hasValidVehicle() then
            client:notify("You cannot use this as you are in a vehicle!")
            return
        elseif client:GetMoveType() == MOVETYPE_NOCLIP then
            client:notify("You cannot use this while in noclip!")
            return
        end

        local time = tonumber(arguments[1])
        if not isnumber(time) then time = 5 end
        if time > 0 then
            time = math.Clamp(time, 1, 60)
        else
            time = nil
        end

        client:SetNW2Bool("FallOverCooldown", true)
        if not client:hasRagdoll() then
            client:setRagdolled(true, time)
            timer.Simple(10, function() client:SetNW2Bool("FallOverCooldown", false) end)
        end
    end
})

lia.command.add("dropmoney", {
    syntax = "<number amount>",
    onRun = function(client, arguments)
        if client:GetNW2Bool("DropMoneyCooldown", false) then
            local remainingTime = math.ceil(client:GetNW2Float("DropMoneyCooldownEnd", 0) - CurTime())
            client:notify("You can't use this command yet. Cooldown remaining: " .. remainingTime .. " seconds.")
            return
        end

        local amount = tonumber(arguments[1])
        if not amount or not isnumber(amount) or amount < 1 then return "@invalidArg", 1 end
        amount = math.Round(amount)
        if not client:getChar():hasMoney(amount) then
            client:notify("You lack the funds for this!")
            return
        end

        local moneyCount = 0
        for _, v in pairs(lia.util.findPlayerEntities(client)) do
            if not v:IsPlayer() and v:isMoney() and v.client == client then moneyCount = moneyCount + 1 end
        end

        if moneyCount >= 3 then
            local admins = lia.util.getAdmins()
            for _, admin in ipairs(admins) do
                admin:chatNotify("Player " .. client:Nick() .. " attempted to drop more than 3 pieces of money. They might be exploiting!")
            end

            client:notify("You can't drop more than 3 pieces of money at a time.")
            return
        end

        client:getChar():takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        money.client = client
        money.charID = client:getChar():getID()
        money.isMoney = true
        client:SetNW2Bool("DropMoneyCooldown", true)
        client:SetNW2Float("DropMoneyCooldownEnd", CurTime() + 5)
        timer.Simple(5, function() if IsValid(client) then client:SetNW2Bool("DropMoneyCooldown", false) end end)
    end
})

lia.command.add("entityName", {
    adminOnly = false,
    onRun = function(client)
        local entity = client:GetTracedEntity()
        if not IsValid(entity) then
            client:chatNotify("Invalid Entity!")
            return
        end

        local entityClass = entity:GetClass()
        if entityClass == "worldspawn" then
            client:chatNotify("Invalid Entity!")
            return
        end

        if entity:IsPlayer() then
            client:chatNotify("You can't use this on humans!")
            return
        end

        local entityName = entity:GetName()
        client:chatNotify("Entity Name: " .. entityName)
        client:chatNotify("Entity Class: " .. entityClass)
    end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    privilege = "Check Inventories",
    syntax = "<string target>",
    onRun = function(client, arguments)
        local function ItemCanEnterForEveryone(_, action, _)
            if action == "transfer" then return true end
        end

        local function CanReplicateItemsForEveryone(_, action, _)
            if action == "repl" then return true end
        end

        local target = lia.command.findPlayer(client, arguments[1])
        local isTargDiff = target ~= client
        if IsValid(target) and target:getChar() and isTargDiff then
            local inventory = target:getChar():getInv()
            inventory:addAccessRule(ItemCanEnterForEveryone, 1)
            inventory:addAccessRule(CanReplicateItemsForEveryone, 1)
            inventory:sync(client)
            net.Start("OpenInvMenu")
            net.WriteEntity(target)
            net.WriteType(inventory:getID())
            net.Send(client)
        elseif not isTargDiff then
            client:notifyLocalized("This isn't meant for checking your own inventory.")
        end
    end
})

lia.command.add("flagpet", {
    adminOnly = true,
    syntax = "[character name]",
    privilege = "Manage Flags",
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

lia.command.add("flaggive", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local flags = arguments[2]
            if not flags then
                local available = ""
                for k in SortedPairs(lia.flag.list) do
                    if not target:getChar():hasFlags(k) then available = available .. k end
                end
                return client:requestString("@flagGiveTitle", "@flagGiveDesc", function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
            end

            target:getChar():giveFlags(flags)
            client:notifyLocalized("flagGive", client:Name(), target:Name(), flags)
        end
    end,
    alias = {"giveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local character = target:getChar()
        if not character or not target then
            client:notify("Invalid Target!")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not character:hasFlags(k) then target:getChar():giveFlags(k) end
        end

        client:notify("You gave this player all flags!")
    end
})

lia.command.add("flagpet", {
    adminOnly = true,
    privilege = "Manage Flags",
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
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local character = target:getChar()
        if not character or not target then
            client:notify("Invalid Target!")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if character:hasFlags(k) then target:getChar():takeFlags(k) end
        end

        client:notify("You took this players flags!")
    end
})

lia.command.add("flagtake", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local flags = arguments[2]
            if not flags then return client:requestString("@flagTakeTitle", "@flagTakeDesc", function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, target:getChar():getFlags()) end
            target:getChar():takeFlags(flags)
            client:notifyLocalized("flagTake", client:Name(), flags, target:Name())
        end
    end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    privilege = "Manage Items",
    onRun = function(client)
        for _, v in pairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function(client)
        local count = 0
        for _, v in pairs(ents.FindByClass("lia_item")) do
            count = count + 1
            v:Remove()
        end

        client:notify(count .. " items have been cleaned up from the map.")
    end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function(client)
        local count = 0
        for _, v in pairs(ents.GetAll()) do
            if v:isProp() then
                count = count + 1
                v:Remove()
            end
        end

        client:notify(count .. " props have been cleaned up from the map.")
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function(client)
        local count = 0
        for _, v in pairs(ents.GetAll()) do
            if IsValid(v) and v:IsNPC() then
                count = count + 1
                v:Remove()
            end
        end

        client:notify(count .. " NPCs have been cleaned up from the map.")
    end
})

lia.command.add("charunban", {
    syntax = "<string name>",
    superAdminOnly = true,
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        if (client.liaNextSearch or 0) >= CurTime() then return L("charSearching", client) end
        local name = table.concat(arguments, " ")
        for _, v in pairs(lia.char.loaded) do
            if lia.util.stringMatches(v:getName(), name) then
                if v:getData("banned") then
                    v:setData("banned")
                    v:setData("permakilled")
                else
                    return "@charNotBanned"
                end
                return lia.notices.notifyLocalized("charUnBan", nil, client:Name(), v:getName())
            end
        end

        client.liaNextSearch = CurTime() + 15
        lia.db.query("SELECT _id, _name, _data FROM lia_characters WHERE _name LIKE \"%" .. lia.db.escape(name) .. "%\" LIMIT 1", function(data)
            if data and data[1] then
                local charID = tonumber(data[1]._id)
                local data = util.JSONToTable(data[1]._data or "[]")
                client.liaNextSearch = 0
                if not data.banned then return client:notifyLocalized("charNotBanned") end
                data.banned = nil
                lia.db.updateTable({
                    _data = data
                }, nil, nil, "_id = " .. charID)

                lia.notices.notifyLocalized("charUnBan", nil, client:Name(), lia.char.loaded[charID]:getName())
            end
        end)
    end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            target:getChar():getInv():wipeItems()
            client:notifyLocalized("resetInv", target:getChar():getName())
        end
    end
})

lia.command.add("charkick", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Kick Characters",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for _, v in player.Iterator() do
                    v:notifyLocalized("charKick", client:Name(), target:Name())
                end

                character:kick()
            end
        end
    end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local count = 0
            for _, v in pairs(cleanup.GetList(target)[target:UniqueID()] or {}) do
                for _, n in pairs(v) do
                    if IsValid(n) and IsValid(n:GetPhysicsObject()) then
                        n:GetPhysicsObject():EnableMotion(false)
                        count = count + 1
                    end
                end
            end

            client:notify("You have frozen all of " .. target:Name() .. "'s Entities.")
            client:ChatPrint("Frozen " .. count .. " Entities belonging to " .. target:Name())
        end
    end
})

lia.command.add("charban", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                lia.log.add(client, "charBan", target:Name())
                character:setData("banned", true)
                character:setData("charBanInfo", {
                    name = client.steamName and client:steamName() or client:Name(),
                    steamID = client:SteamID(),
                    rank = client:GetUserGroup()
                })

                character:save()
                character:kick()
                client:notifyLocalized("charBan", client:Name(), target:Name())
            end
        end
    end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    privilege = "Get Character Info",
    onRun = function(client)
        for _, v in pairs(player.GetAll()) do
            if v:getChar() then client:chatNotify(v:Name() .. " has " .. v:getChar():getMoney()) end
        end
    end
})

lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Get Character Info",
    onRun = function(client)
        for _, v in pairs(player.GetHumans()) do
            client:chatNotify(v:Name() .. " — " .. v:getChar():getFlags())
        end
    end
})

lia.command.add("checkmoney", {
    syntax = "<string target>",
    privilege = "Get Character Info",
    adminOnly = true,
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            client:chatNotify(target:GetName() .. " has: " .. target:getChar():getMoney() .. lia.currency.plural .. " (s)")
        else
            client:chatNotify("Invalid Target")
        end
    end
})

lia.command.add("listbodygroups", {
    syntax = "<string target>",
    privilege = "Get Character Info",
    adminOnly = true,
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            client:chatNotify("Available bodygroups for \"" .. target:GetModel() .. "\":")
            for i = 0, target:GetNumBodyGroups() - 1 do
                if target:GetBodygroupCount(i) > 1 then client:chatNotify(i .. " = " .. target:GetBodygroupName(i) .. "(0-" .. (target:GetBodygroupCount(i) - 1) .. ")") end
            end
        end
    end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Get Character Info",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            client:notify(target:GetModel())
        else
            client:notify("Invalid Target")
        end
    end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Get Character Info",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local character = target:getChar()
            client:notify(character:getMoney())
        else
            client:notify("Invalid Target")
        end
    end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    syntax = "<string name> <number speed>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local speed = tonumber(arguments[2]) or lia.config.WalkSpeed
        if IsValid(target) and target:getChar() then
            target:SetRunSpeed(speed)
        else
            client:notify("Invalid Target")
        end
    end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    syntax = "<string name> <string model>",
    privilege = "Manage Character Informations",
    onRun = function(client, arguments)
        if not arguments[2] then return L("invalidArg", client, 2) end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local oldModel = target:getChar():getModel()
            target:getChar():setModel(arguments[2])
            target:SetupHands()
            client:notifyLocalized("cChangeModel", client:Name(), target:Name(), arguments[2])
            lia.log.add(client, "charsetmodel", target:Name(), arguments[2], oldModel)
        end
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Manage Items",
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
                if target ~= client then client:notifyLocalized("itemCreated") end
            else
                target:notify(tostring(succ))
                target:notify(tostring(err))
            end
        end
    end
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    syntax = "<string name> <string desc>",
    privilege = "Manage Character Informations",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then return end
        if not target:getChar() then return "No character loaded" end
        local arg = table.concat(arguments, " ", 2)
        if not arg:find("%S") then return client:requestString("Change " .. target:Name() .. "'s Description", "Enter new description", function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        lia.log.add(client, "charsetdesc", target:Name(), arg)
        target:getChar():setDesc(arg)
        return "Successfully changed " .. target:Name() .. "'s description"
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    syntax = "<string name> [string newName]",
    privilege = "Manage Character Informations",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and not arguments[2] then return client:requestString("@chgName", "@chgNameDesc", function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        table.remove(arguments, 1)
        local targetName = table.concat(arguments, " ")
        if IsValid(target) and target:getChar() then
            lia.log.add(client, "charsetname", target:Name(), targetName)
            client:notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
            target:getChar():setName(targetName:gsub("#", "#?"))
        end
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    syntax = "<string name> <number value>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local scale = tonumber(arguments[2]) or 1
        if IsValid(target) and target:getChar() then
            target:SetModelScale(scale, 0)
        else
            client:notify("Invalid Target")
        end
    end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    privilege = "Manage Character Stats",
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
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    privilege = "Manage Bodygroups",
    syntax = "<string name> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local value = tonumber(arguments[3])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local index = target:FindBodygroupByName(arguments[2])
            if index > -1 then
                local oldValue = target:GetBodygroup(index)
                if value and value < 1 then value = nil end
                local groups = target:getChar():getData("groups", {})
                groups[index] = value
                target:getChar():setData("groups", groups)
                target:SetBodygroup(index, value or 0)
                client:notifyLocalized("cChangeGroups", client:Name(), target:Name(), arguments[2], value or 0)
                lia.log.add(client, "charsetbodygroup", target:Name(), arguments[2], value or 0, oldValue)
            else
                return "@invalidArg", 2
            end
        end
    end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    syntax = "<string name> [number skin]",
    privilege = "Manage Character Stats",
    onRun = function(client, arguments)
        local skin = tonumber(arguments[2])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local oldSkin = target:GetSkin()
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
            lia.log.add(client, "charsetskin", target:Name(), skin or 0, oldSkin)
        end
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        local amount = tonumber(arguments[2])
        if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 2 end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character and amount then
                amount = math.Round(amount)
                character:setMoney(amount)
                client:notify("You set " .. target:Name() .. "'s money to " .. lia.currency.get(amount))
            end
        end
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Manage Characters",
    onRun = function(client, arguments)
        local amount = tonumber(arguments[2])
        if not amount or not isnumber(amount) then return "@invalidArg", 2 end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                amount = math.Round(amount)
                local currentMoney = character:getMoney()
                character:setMoney(currentMoney + amount)
                client:notify("You added " .. lia.currency.get(amount) .. " to " .. target:Name() .. "'s money. Total: " .. lia.currency.get(currentMoney + amount))
            end
        end
    end,
    alias = {"chargivemoney"}
})

lia.command.add("flaglist", {
    adminOnly = true,
    privilege = "Manage Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local flags = {}
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for flag, data in pairs(lia.flag.list) do
                    if character:hasFlags(flag) then
                        table.insert(flags, {
                            flag = flag,
                            desc = data.desc
                        })
                    end
                end
            end
        else
            for flag, data in pairs(lia.flag.list) do
                table.insert(flags, {
                    flag = flag,
                    desc = data.desc
                })
            end
        end

        lia.util.CreateTableUI(client, "Flag List", {
            {
                name = "Flag",
                field = "flag"
            },
            {
                name = "Description",
                field = "desc"
            }
        }, flags)
    end,
    alias = {"flags"}
})

lia.command.add("itemlist", {
    adminOnly = true,
    privilege = "List Items",
    onRun = function(client)
        local items = {}
        for _, item in pairs(lia.item.list) do
            table.insert(items, {
                uniqueID = item.uniqueID or "N/A",
                name = item.name or "N/A",
                desc = item.desc or "N/A",
                category = item.category or "Misc",
                price = item.price or "0"
            })
        end

        lia.util.CreateTableUI(client, "Item List", {
            {
                name = "Unique ID",
                field = "uniqueID"
            },
            {
                name = "Name",
                field = "name"
            },
            {
                name = "Description",
                field = "desc"
            },
            {
                name = "Category",
                field = "category"
            },
            {
                name = "Price",
                field = "price"
            }
        }, items)
    end
})

lia.command.add("modulelist", {
    adminOnly = false,
    onRun = function(client)
        local modules = {}
        for uniqueID, mod in pairs(lia.module.list) do
            table.insert(modules, {
                uniqueID = uniqueID,
                name = mod.name or "Unknown",
                desc = mod.desc or "No description available",
                author = mod.author or "Anonymous",
                discord = mod.discord or "N/A",
                version = mod.version or "N/A"
            })
        end

        lia.util.CreateTableUI(client, "Modules List", {
            {
                name = "Unique ID",
                field = "uniqueID"
            },
            {
                name = "Name",
                field = "name"
            },
            {
                name = "Description",
                field = "desc"
            },
            {
                name = "Author",
                field = "author"
            },
            {
                name = "Discord",
                field = "discord"
            },
            {
                name = "Version",
                field = "version"
            }
        }, modules)
    end,
    alias = {"modules"}
})

lia.command.add("listents", {
    syntax = "<No Input>",
    onRun = function(client)
        local entityList = {}
        for _, v in pairs(ents.GetAll()) do
            local creator = v:GetCreator()
            table.insert(entityList, {
                class = v:GetClass(),
                creator = IsValid(creator) and creator:Nick() or "N/A",
                position = tostring(v:GetPos()),
                model = v:GetModel() or "N/A",
                health = v:Health() or "N/A"
            })
        end

        lia.util.CreateTableUI(client, "Entity List", {
            {
                name = "Class",
                field = "class"
            },
            {
                name = "Creator",
                field = "creator"
            },
            {
                name = "Position",
                field = "position"
            },
            {
                name = "Model",
                field = "model"
            },
            {
                name = "Health",
                field = "health"
            }
        }, entityList)
    end
})

lia.command.add("liststaff", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function(client)
        local staffList = {}
        for _, target in player.Iterator() do
            if target:isStaff() then
                local char = target:getChar()
                table.insert(staffList, {
                    name = target:Nick(),
                    class = char:getClass() and lia.class.list[char:getClass()].name or "N/A",
                    faction = char:getFaction(),
                    characterID = char:getID(),
                    usergroup = target:GetUserGroup()
                })
            end
        end

        if #staffList > 0 then
            lia.util.CreateTableUI(client, "Staff List", {
                {
                    name = "Name",
                    field = "name"
                },
                {
                    name = "Class",
                    field = "class"
                },
                {
                    name = "Faction",
                    field = "faction"
                },
                {
                    name = "Character ID",
                    field = "characterID"
                },
                {
                    name = "Usergroup",
                    field = "usergroup"
                }
            }, staffList)
        else
            client:notify("No valid players found!")
        end
    end
})

lia.command.add("listondutystaff", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function(client)
        local onDutyStaffList = {}
        for _, target in player.Iterator() do
            if target:isStaffOnDuty() then
                local char = target:getChar()
                table.insert(onDutyStaffList, {
                    name = target:Nick(),
                    class = char:getClass() and lia.class.list[char:getClass()].name or "N/A",
                    faction = char:getFaction(),
                    characterID = char:getID(),
                    usergroup = target:GetUserGroup()
                })
            end
        end

        if #onDutyStaffList > 0 then
            lia.util.CreateTableUI(client, "On Duty Staff List", {
                {
                    name = "Name",
                    field = "name"
                },
                {
                    name = "Class",
                    field = "class"
                },
                {
                    name = "Faction",
                    field = "faction"
                },
                {
                    name = "Character ID",
                    field = "characterID"
                },
                {
                    name = "Usergroup",
                    field = "usergroup"
                }
            }, onDutyStaffList)
        else
            client:notify("No valid players found!")
        end
    end
})

lia.command.add("listvip", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function(client)
        local vipList = {}
        for _, target in player.Iterator() do
            if target:isVIP() then
                local char = target:getChar()
                table.insert(vipList, {
                    name = target:Nick(),
                    class = char:getClass() and lia.class.list[char:getClass()].name or "N/A",
                    faction = char:getFaction(),
                    characterID = char:getID(),
                    usergroup = target:GetUserGroup()
                })
            end
        end

        if #vipList > 0 then
            lia.util.CreateTableUI(client, "VIP List", {
                {
                    name = "Name",
                    field = "name"
                },
                {
                    name = "Class",
                    field = "class"
                },
                {
                    name = "Faction",
                    field = "faction"
                },
                {
                    name = "Character ID",
                    field = "characterID"
                },
                {
                    name = "Usergroup",
                    field = "usergroup"
                }
            }, vipList)
        else
            client:notify("No valid players found!")
        end
    end
})

lia.command.add("listusers", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function(client)
        local userList = {}
        for _, target in player.Iterator() do
            if target:isUser() then
                local char = target:getChar()
                table.insert(userList, {
                    name = target:Nick(),
                    class = char:getClass() and lia.class.list[char:getClass()].name or "N/A",
                    faction = char:getFaction(),
                    characterID = char:getID(),
                    usergroup = target:GetUserGroup()
                })
            end
        end

        if #userList > 0 then
            lia.util.CreateTableUI(client, "User List", {
                {
                    name = "Name",
                    field = "name"
                },
                {
                    name = "Class",
                    field = "class"
                },
                {
                    name = "Faction",
                    field = "faction"
                },
                {
                    name = "Character ID",
                    field = "characterID"
                },
                {
                    name = "Usergroup",
                    field = "usergroup"
                }
            }, userList)
        else
            client:notify("No valid players found!")
        end
    end
})