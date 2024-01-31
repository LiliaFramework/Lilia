---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetspeed", {
    adminOnly = true,
    privilege = "Set Character Speed",
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("playglobalsound", {
    superAdminOnly = true,
    privilege = "Play Global Sounds",
    onRun = function(_, arguments)
        local sound = arguments[1]
        for _, v in pairs(player.GetAll()) do
            v:PlaySound(sound)
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("playsound", {
    superAdminOnly = true,
    privilege = "Play Targetted Sounds",
    syntax = "<string name> <string sound>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local sound = arguments[2]
        target:PlaySound(sound)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetscale", {
    superAdminOnly = true,
    privilege = "Set Character scale",
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetjump", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charaddmoney", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charban", {
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
                char:setData("charBanInfo", {
                    name = client.steamName and client:steamName() or client:Nick(),
                    steamID = client:SteamID(),
                    rank = client:GetUserGroup()
                })

                char:save()
                char:kick()
            end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetdesc", {
    adminOnly = true,
    syntax = "<string name> <string desc>",
    privilege = "Change Description",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then return end
        if not target:getChar() then return "No character loaded" end
        local arg = table.concat(arguments, " ", 2)
        if not arg:find("%S") then return client:requestString("Change " .. target:Nick() .. "'s Description", "Enter new description", function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        local info = lia.char.vars.desc
        local result, fault, count = info.onValidate(arg)
        if result == false then return "@" .. fault, count end
        target:getChar():setDesc(arg)
        return "Successfully changed " .. target:Nick() .. "'s description"
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetname", {
    adminOnly = true,
    syntax = "<string name> [string newName]",
    privilege = "Change Name",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and not arguments[2] then return client:requestString("@chgName", "@chgNameDesc", function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        table.remove(arguments, 1)
        local targetName = table.concat(arguments, " ")
        if IsValid(target) and target:getChar() then
            client:notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
            target:getChar():setName(targetName:gsub("#", "#?"))
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("chargetmodel", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetmodel", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetbodygroup", {
    adminOnly = true,
    privilege = "Change Bodygroups",
    syntax = "<string name> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local value = tonumber(arguments[3])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local index = target:FindBodygroupByName(arguments[2])
            if index > -1 then
                if value and value < 1 then value = nil end
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetskin", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("chargetmoney", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charsetmoney", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("clearinv", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Clear Inventory",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            for _, v in pairs(target:getChar():getInv():getItems()) do
                v:remove()
            end

            client:notifyLocalized("resetInv", target:getChar():getName())
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flaggive", {
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
                    if not target:getChar():hasFlags(k) then available = available .. k end
                end
                return client:requestString("@flagGiveTitle", "@flagGiveDesc", function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
            end

            target:getChar():giveFlags(flags)
            client:notifyLocalized("flagGive", client:Name(), target:Name(), flags)
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flaggiveall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Toggle All Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local char = target:getChar()
        if not char or not target then
            client:notify("Invalid Target!")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not char:hasFlags(k) then target:getChar():giveFlags(k) end
        end

        client:notify("You gave this player all flags!")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flagtakeall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Toggle All Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local char = target:getChar()
        if not char or not target then
            client:notify("Invalid Target!")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if char:hasFlags(k) then target:getChar():takeFlags(k) end
        end

        client:notify("You took this players flags!")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flagtake", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Toggle Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then
            local flags = arguments[2]
            if not flags then return client:requestString("@flagTakeTitle", "@flagTakeDesc", function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, target:getChar():getFlags()) end
            target:getChar():takeFlags(flags)
            client:notifyLocalized("flagTake", client:Name(), flags, target:Name())
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charkick", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Kick Characters",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local char = target:getChar()
            if char then
                for _, v in ipairs(player.GetAll()) do
                    v:notifyLocalized("charKick", client:Name(), target:Name())
                end

                char:kick()
            end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("viewcoreinformation", {
    privilege = "See Core Information",
    superAdminOnly = true,
    onRun = function(client)
        net.Start("OpenInformationMenu")
        net.Send(client)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("charunban", {
    syntax = "<string name>",
    superAdminOnly = true,
    privilege = "Un-Ban Characters",
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
                return lia.util.notifyLocalized("charUnBan", nil, client:Name(), v:getName())
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

                lia.util.notifyLocalized("charUnBan", nil, client:Name(), lia.char.loaded[charID]:getName())
            end
        end)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flagpet", {
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
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flagragdoll", {
    adminOnly = true,
    privilege = "Hand Ragdoll Medals",
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        target:getChar():giveFlags("r")
        client:notifyLocalized("You have given " .. arguments[1] .. " Ragdoll Flags")
        target:notifyLocalized("You have been given Ragdoll flags by " .. client:Name())
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flags", {
    privilege = "Check Flags",
    adminOnly = true,
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")
            return false
        end

        if IsValid(target) and target:getChar() then client:notify("Their character flags are: '" .. target:getChar():getFlags() .. "'") end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Freeze All Props",
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

            client:notify("You have frozen all of " .. target:Nick() .. "'s Entities.")
            client:SendMessage("Frozen " .. count .. " Entities belonging to " .. target:Nick())
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("checkmoney", {
    syntax = "<string target>",
    privilege = "Check Money",
    adminOnly = true,
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            client:ChatPrint(target:GetName() .. " has: " .. target:getChar():getMoney() .. lia.currency.plural .. " (s)")
        else
            client:ChatPrint("Invalid Target")
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("status", {
    privilege = "Default User Commands",
    onRun = function(client)
        if not client.metaAntiSpam or client.metaAntiSpam < CurTime() and SERVER then
            local char = client:getChar()
            client:ChatPrint("________________________________" .. "\n➣ Your SteamID: " .. client:SteamID() .. "\n➣ Your ping: " .. client:Ping() .. " ms")
            client:ChatPrint("➣ Your faction: " .. team.GetName(client:Team()) .. "\n➣ Your health: " .. client:Health())
            client:ChatPrint("➣ Your description: " .. "\n[ " .. char:getDesc() .. " ]")
            client:ChatPrint("➣ Your max health: " .. client:GetMaxHealth() .. "\n➣ Your max run speed: " .. client:GetRunSpeed() .. "\n➣ Your max walk speed: " .. client:GetWalkSpeed() .. "\n➣________________________________")
            client.metaAntiSpam = CurTime() + 8
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("redownloadlightmaps", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        net.Start("ReloadLightMaps")
        net.Send(client)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Clean Items",
    onRun = function(client)
        local count = 0
        for _, v in pairs(ents.FindByClass("lia_item")) do
            count = count + 1
            v:Remove()
        end

        client:notify(count .. " items have been cleaned up from the map.")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Clean Props",
    onRun = function(client)
        local count = 0
        for _, v in pairs(ents.FindByClass("prop_physics")) do
            count = count + 1
            v:Remove()
        end

        client:notify(count .. " props have been cleaned up from the map.")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("forcesave", {
    superAdminOnly = true,
    privilege = "Force Save Server",
    onRun = function(client)
        hook.Run("SaveData")
        for _, v in ipairs(player.GetAll()) do
            if v:getChar() then v:getChar():save() end
        end

        client:notify("You've force-saved all data.")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Clean NPCs",
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flags", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Check Flags",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target:getChar() then client:notify("Their character flags are: '" .. target:getChar():getFlags() .. "'") end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("checkallmoney", {
    superAdminOnly = true,
    syntax = "<string charname>",
    privilege = "Check All Money",
    onRun = function(client)
        for _, v in pairs(player.GetAll()) do
            if v:getChar() then client:ChatPrint(v:Name() .. " has " .. v:getChar():getMoney()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("return", {
    adminOnly = true,
    privilege = "Return",
    onRun = function(client)
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Find All Flags",
    onRun = function(client)
        for _, v in pairs(player.GetHumans()) do
            client:ChatPrint(v:Name() .. " — " .. v:getChar():getFlags())
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Give Item",
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("netmessagelogs", {
    superAdminOnly = true,
    privilege = "Check Net Message Log",
    onRun = function(client) sendData(1, client) end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("announce", {
    superAdminOnly = true,
    syntax = "<string factions> <string text>",
    privilege = "Make Announcements",
    onRun = function(client, arguments)
        if not arguments[1] then return "Invalid argument (#1)" end
        local message = table.concat(arguments, " ", 1)
        net.Start("announcement_client")
        net.WriteString(message)
        net.Broadcast()
        client:notify("Announcement sent.")
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("listents", {
    privilege = "Default User Commands",
    syntax = "<No Input>",
    onRun = function(client)
        local cent = {}
        for _, v in pairs(ents.GetAll()) do
            local class = v:GetClass()
            if not cent[class] then
                cent[class] = 1
            else
                cent[class] = cent[class] + 1
            end
        end

        local output = "{\n"
        for class, count in pairs(cent) do
            output = output .. "  " .. class .. " = " .. count .. ",\n"
        end

        output = output:sub(1, -3) .. "\n}"
        client:ChatPrint(output)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("flip", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        local roll = math.random(0, 1)
        if roll == 1 then
            lia.chat.send(client, "flip", "Heads")
        else
            lia.chat.send(client, "flip", "Tails")
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("liststaff", {
    adminOnly = false,
    privilege = "List Staff",
    onRun = function(client)
        for _, target in ipairs(player.GetAll()) do
            if target:isStaff() then client:ChatPrint("Off Duty Staff Meber: " .. target:Name()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("listondutystaff", {
    adminOnly = false,
    privilege = "List Staff",
    onRun = function(client)
        for _, target in ipairs(player.GetAll()) do
            if target:isStaffOnDuty() then client:ChatPrint("Off Duty Staff Meber: " .. target:Name()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("listvip", {
    adminOnly = false,
    privilege = "List VIPs",
    onRun = function(client)
        for _, target in ipairs(player.GetAll()) do
            if target:isVIP() then client:ChatPrint("VIP Member: " .. target:Name()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("listusers", {
    adminOnly = false,
    privilege = "List Users",
    onRun = function(client)
        for _, target in ipairs(player.GetAll()) do
            if target:isUser() then client:ChatPrint("User Member: " .. target:Name()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("rolld", {
    adminOnly = false,
    privilege = "Default User Commands",
    syntax = "<number dice> <number pips> <number bonus>",
    onRun = function(client, arguments)
        local dice = math.Clamp(tonumber(arguments[1]) or 1, 1, 100)
        local pips = math.Clamp(tonumber(arguments[2]) or 6, 1, 100)
        local bonus = tonumber(arguments[3]) or nil
        if bonus then bonus = math.Clamp(bonus, 0, 1000000) end
        local total = 0
        local dmsg = ""
        for i = 1, dice do
            local roll = math.random(1, pips)
            total = total + roll
            if i > 1 then dmsg = dmsg .. ", " end
            dmsg = dmsg .. roll
        end

        local msg = ""
        if bonus then
            total = total + bonus
            msg = msg .. " + " .. bonus
        end

        msg = "rolled " .. total .. " [" .. dmsg .. "]" .. " on " .. dice .. "d" .. pips .. msg
        lia.chat.send(client, "rolld", msg)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("roll", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client) lia.chat.send(client, "roll", math.random(0, 100)) end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("chardesc", {
    adminOnly = false,
    privilege = "Default User Commands",
    syntax = "<string desc>",
    onRun = function(client, arguments)
        arguments = table.concat(arguments, " ")
        if not arguments:find("%S") then return client:requestString("Change Description", "Change Your Description", function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar():getDesc()) end
        local info = lia.char.vars.desc
        local result, fault, count = info.onValidate(arguments)
        if result == false then return "@" .. fault, count end
        client:getChar():setDesc(arguments)
        return "@descChanged"
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("chargetup", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        local entity = client.liaRagdoll
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("@gettingUp", 5, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("givemoney", {
    adminOnly = false,
    privilege = "Default User Commands",
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
            target:notifyLocalized("moneyTaken", lia.currency.get(amount))
            client:notifyLocalized("moneyGiven", lia.currency.get(amount))
            client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
        else
            client:notify("You need to be looking at someone!")
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("bringlostitems", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        for _, v in pairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:GetClass() == "lia_item" then v:SetPos(client:GetPos()) end
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("carddraw", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        local cards = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Ace", "Queen", "King", "Jack"}
        local family = {"Spades", "Hearts", "Diamonds", "Clubs"}
        local msg = "draws the " .. table.Random(cards) .. " of " .. table.Random(family)
        lia.chat.send(client, "rolld", msg)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("fallover", {
    adminOnly = false,
    privilege = "Default User Commands",
    syntax = "[number time]",
    onRun = function(client, arguments)
        if client:GetNWBool("FallOverCooldown", false) then
            client:notify("This Command Is In Cooldown!")
            return
        elseif client:IsFrozen() then
            client:notify("You cannot use this while frozen!")
            return
        elseif not client:Alive() then
            client:notify("You cannot use this while dead!")
            return
        elseif client:InVehicle() then
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

        client:SetNWBool("FallOverCooldown", true)
        if not IsValid(client.liaRagdoll) then
            client:setRagdolled(true, time)
            timer.Simple(10, function() client:SetNWBool("FallOverCooldown", false) end)
        end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("getpos", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client) client:ChatPrint("MY POSITION: " .. tostring(client:GetPos())) end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("entname", {
    adminOnly = false,
    privilege = "Default User Commands",
    onRun = function(client)
        local tr = util.TraceLine(util.GetPlayerTrace(client))
        if IsValid(tr.Entity) then client:ChatPrint("I saw a " .. tr.Entity:GetName()) end
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("dropmoney", {
    privilege = "Default User Commands",
    syntax = "<number amount>",
    onRun = function(client, arguments)
        if client:GetNWBool("DropMoneyCooldown", false) then
            local remainingTime = math.ceil(client:GetNWFloat("DropMoneyCooldownEnd", 0) - CurTime())
            client:notify("You can't use this command yet. Cooldown remaining: " .. remainingTime .. " seconds.")
            return
        end

        local amount = tonumber(arguments[1])
        if not amount or not isnumber(amount) or amount < 1 then return "@invalidArg", 1 end
        amount = math.Round(amount)
        if not client:getChar():hasMoney(amount) then return end
        client:getChar():takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        money.client = client
        money.charID = client:getChar():getID()
        client:SetNWBool("DropMoneyCooldown", true)
        client:SetNWFloat("DropMoneyCooldownEnd", CurTime() + 5)
        timer.Simple(5, function() if IsValid(client) then client:SetNWBool("DropMoneyCooldown", false) end end)
    end
})
