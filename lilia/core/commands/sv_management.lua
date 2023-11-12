--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "freezeallprops",
    {
        superAdminOnly = true,
        privilege = "Freeze All Props",
        onRun = function(client, arguments)
            for k, v in pairs(ents.FindByClass("prop_physics")) do
                local physObj = v:GetPhysicsObject()
                if IsValid(physObj) then
                    physObj:EnableMotion(false)
                    physObj:Sleep()
                end
            end
        end
    }
)

-------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkmoney",
    {
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "status",
    {
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            if not client.metaAntiSpam or client.metaAntiSpam < CurTime() and SERVER then
                local char = client:getChar()
                client:ChatPrint("________________________________" .. "\n➣ Your SteamID: " .. client:SteamID() .. "\n➣ Your ping: " .. client:Ping() .. " ms")
                client:ChatPrint("➣ Your faction: " .. team.GetName(client:Team()) .. "\n➣ Your class: " .. "\n➣ Your health: " .. client:Health())
                client:ChatPrint("➣ Your description: " .. "\n[ " .. char:getDesc() .. " ]")
                client:ChatPrint("➣ Your max health: " .. client:GetMaxHealth() .. "\n➣ Your max run speed: " .. client:GetRunSpeed() .. "\n➣ Your max walk speed: " .. client:GetWalkSpeed() .. "\n➣________________________________")
                client.metaAntiSpam = CurTime() + 8
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "setclass",
    {
        privilege = "Set Class",
        adminOnly = true,
        syntax = "<string target> <string class>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target and target:getChar() then
                local character = target:getChar()
                local classFound
                if lia.class.list[name] then classFound = lia.class.list[name] end
                if not classFound then
                    for k, v in ipairs(lia.class.list) do
                        if lia.util.stringMatches(L(v.name, client), arguments[2]) then
                            classFound = v
                            break
                        end
                    end
                end

                if classFound then
                    character:joinClass(classFound.index, true)
                    target:notify("Your class was set to " .. classFound.name .. (client ~= target and "by " .. client:GetName() or "") .. ".")
                    if client ~= target then client:notify("You set " .. target:GetName() .. "'s class to " .. classFound.name .. ".") end
                else
                    client:notify("Invalid class.")
                end
            end
        end,
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleanitems",
    {
        superAdminOnly = true,
        privilege = "Clean Items",
        onRun = function(client, arguments)
            local count = 0
            for k, v in pairs(ents.FindByClass("lia_item")) do
                count = count + 1
                v:Remove()
            end

            client:notify(count .. " items have been cleaned up from the map.")
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleanprops",
    {
        superAdminOnly = true,
        privilege = "Clean Props",
        onRun = function(client, arguments)
            local count = 0
            for k, v in pairs(ents.FindByClass("prop_physics")) do
                count = count + 1
                v:Remove()
            end

            client:notify(count .. " props have been cleaned up from the map.")
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "savemap",
    {
        superAdminOnly = true,
        privilege = "Save Map Data",
        onRun = function(client, arguments) hook.Run("SaveData") end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleannpcs",
    {
        superAdminOnly = true,
        privilege = "Clean NPCs",
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flags",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Check Flags",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) and target:getChar() then client:notify("Their character flags are: '" .. target:getChar():getFlags() .. "'") end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "clearchat",
    {
        superAdminOnly = true,
        privilege = "Clear Chat",
        onRun = function(client, arguments) netstream.Start(player.GetAll(), "adminClearChat") end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkallmoney",
    {
        superAdminOnly = true,
        syntax = "<string charname>",
        privilege = "Check All Money",
        onRun = function(client, arguments)
            for k, v in pairs(player.GetAll()) do
                if v:getChar() then client:ChatPrint(v:Name() .. " has " .. v:getChar():getMoney()) end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "return",
    {
        adminOnly = true,
        privilege = "Return",
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "findallflags",
    {
        adminOnly = false,
        privilege = "Find All Flags",
        onRun = function(client, arguments)
            for k, v in pairs(player.GetHumans()) do
                client:ChatPrint(v:Name() .. " — " .. v:getChar():getFlags())
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargiveitem",
    {
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "netmessagelogs",
    {
        superAdminOnly = true,
        privilege = "Check Net Message Log",
        onRun = function(client, arguments) sendData(1, client) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "returnitems",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Return Items",
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "announce",
    {
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
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "voiceunban",
    {
        adminOnly = true,
        privilege = "Voice Unban Character",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target == client then
                client:notify("You cannot run mute commands on yourself.")
                return false
            end

            if IsValid(target) and target:getChar():getData("VoiceBan", false) then target:getChar():setData("VoiceBan", false) end
            client:notify("You have unmuted a player.")
            target:notify("You've been unmuted by the admin.")
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "voiceban",
    {
        adminOnly = true,
        privilege = "Voice ban Character",
        syntax = "<string name>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target == client then
                client:notify("You cannot run mute commands on yourself.")
                return false
            end

            if IsValid(target) then if not target:getData("VoiceBan", false) then target:setData("VoiceBan", true) end end
            client:notify("You have muted a player.")
            target:notify("You've been muted by the admin.")
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
for k, v in pairs(lia.config.ServerURLs) do
    lia.command.add(
        k,
        {
            adminOnly = false,
            privilege = "Default User Commands",
            onRun = function(client, arguments) client:SendLua("gui.OpenURL('" .. v .. "')") end
        }
    )
end
--------------------------------------------------------------------------------------------------------------------------
