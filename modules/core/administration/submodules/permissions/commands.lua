lia.command.add("playglobalsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    desc = "Play a global sound for all players.",
    syntax = "[string sound]",
    onRun = function(client, arguments)
        local sound = arguments[1]
        if not sound or sound == "" then
            client:notifyLocalized("mustSpecifySound")
            return
        end

        for _, target in player.Iterator() do
            target:PlaySound(sound)
        end
    end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    desc = "Play the specified sound on a specific player.",
    syntax = "[string player] [string sound]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local sound = arguments[2]
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not sound or sound == "" then
            client:notifyLocalized("NoSound")
            return
        end

        target:PlaySound(sound)
    end
})

lia.command.add("returntodeathpos", {
    adminOnly = true,
    privilege = "Return Players",
    desc = "Return to your last recorded death position.",
    onRun = function(client)
        if IsValid(client) and client:Alive() then
            local character = client:getChar()
            local oldPos = character and character:getData("deathPos")
            if oldPos then
                client:SetPos(oldPos)
                character:setData("deathPos", nil)
            else
                client:notifyLocalized("noDeathPosition")
            end
        else
            client:notifyLocalized("waitRespawn")
        end
    end
})

lia.command.add("roll", {
    adminOnly = false,
    desc = "Roll a random number between 0 and 100.",
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
    end
})

lia.command.add("forcefallover", {
    adminOnly = true,
    privilege = "Force Fallover",
    desc = "Force another player to fall over (go into ragdoll).",
    syntax = "[player target] [number time]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target:getNetVar("FallOverCooldown", false) then
            target:notifyLocalized("cmdCooldown")
            return
        elseif target:IsFrozen() then
            target:notifyLocalized("cmdFrozen")
            return
        elseif not target:Alive() then
            target:notifyLocalized("cmdDead")
            return
        elseif target:hasValidVehicle() then
            target:notifyLocalized("cmdVehicle")
            return
        elseif target:isNoClipping() then
            target:notifyLocalized("cmdNoclip")
            return
        end

        local time = tonumber(arguments[2])
        if not time or time < 1 then
            time = 5
        else
            time = math.Clamp(time, 1, 60)
        end

        target:setNetVar("FallOverCooldown", true)
        if not target:hasRagdoll() then
            target:setRagdolled(true, time)
            timer.Simple(10, function() if IsValid(target) then target:setNetVar("FallOverCooldown", false) end end)
        end
    end
})

lia.command.add("forcegetup", {
    adminOnly = true,
    privilege = "Force GetUp",
    desc = "Force another player to get up from ragdoll.",
    syntax = "[player target]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not target:hasRagdoll() then
            target:notifyLocalized("noRagdoll")
            return
        end

        local entity = target:getRagdoll()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            target:setAction("gettingUp", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", target, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end
})

lia.command.add("chardesc", {
    adminOnly = false,
    desc = "Change your character's description.",
    syntax = "[string desc]",
    onRun = function(client, arguments)
        local desc = table.concat(arguments, " ")
        if not desc:find("%S") then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar() and client:getChar():getDesc() or "") end
        local character = client:getChar()
        if character then character:setDesc(desc) end
        return "descChanged"
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    desc = "Force yourself to get up from ragdoll (if possible).",
    onRun = function(client)
        if not client:hasRagdoll() then
            client:notifyLocalized("noRagdoll")
            return
        end

        local entity = client:getRagdoll()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("gettingUp", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", client, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end,
    alias = {"getup"}
})

lia.command.add("fallover", {
    adminOnly = false,
    desc = "Fall over (ragdoll) for a certain duration.",
    syntax = "[number time]",
    onRun = function(client, arguments)
        if client:getNetVar("FallOverCooldown", false) then
            client:notifyLocalized("cmdCooldown")
            return
        end

        if client:IsFrozen() then
            client:notifyLocalized("cmdFrozen")
            return
        end

        if not client:Alive() then
            client:notifyLocalized("cmdDead")
            return
        end

        if client:hasValidVehicle() then
            client:notifyLocalized("cmdVehicle")
            return
        end

        if client:isNoClipping() then
            client:notifyLocalized("cmdNoclip")
            return
        end

        local t = tonumber(arguments[1])
        if not t or t < 1 then
            t = 5
        else
            t = math.Clamp(t, 1, 60)
        end

        client:setNetVar("FallOverCooldown", true)
        if not client:hasRagdoll() then
            client:setRagdolled(true, t)
            timer.Simple(10, function() if IsValid(client) then client:setNetVar("FallOverCooldown", false) end end)
        end
    end
})

lia.command.add("togglelockcharacters", {
    superAdminOnly = true,
    privilege = "Toggle Character Lock",
    desc = "Toggle whether players can swap characters.",
    syntax = "[boolean lock]",
    onRun = function()
        local newVal = not GetGlobalBool("characterSwapLock", false)
        SetGlobalBool("characterSwapLock", newVal)
        if not newVal then
            return "Now the players will be able to change character"
        else
            return "Now the players won't be able to change character until the server is restarted or until you re-enable it"
        end
    end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    privilege = "Check Inventories",
    desc = "Check another player's inventory.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickCheckInventoryName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryItems"),
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyLocalized("invCheckSelf")
            return
        end

        local inventory = target:getChar():getInv()
        inventory:addAccessRule(function(_, action, _) return action == "transfer" end, 1)
        inventory:addAccessRule(function(_, action, _) return action == "repl" end, 1)
        inventory:sync(client)
        net.Start("OpenInvMenu")
        net.WriteEntity(target)
        net.WriteType(inventory:getID())
        net.Send(client)
    end
})

lia.command.add("flaggive", {
    adminOnly = true,
    privilege = "Manage Flags",
    desc = "Give one or more flags to a character.",
    syntax = "[string playerName] [string flags]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local available = ""
            for k in SortedPairs(lia.flag.list) do
                if not target:getChar():hasFlags(k) then available = available .. k .. " " end
            end

            available = available:Trim()
            if available == "" then
                client:notifyLocalized("noAvailableFlags")
                return
            end
            return client:requestString(L("flagGiveTitle"), L("flagGiveDesc"), function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
        end

        target:getChar():giveFlags(flags)
        client:notifyLocalized("flagGive", client:Name(), flags, target:Name())
    end,
    alias = {"giveflag", "chargiveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    privilege = "Manage Flags",
    desc = "Give all possible flags to a character.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGiveAllFlagsName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/flag_blue.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        for k, _ in SortedPairs(lia.flag.list) do
            if not character:hasFlags(k) then character:giveFlags(k) end
        end

        client:notifyLocalized("gaveAllFlags")
    end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    privilege = "Manage Flags",
    desc = "Remove all flags from a character.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickTakeAllFlagsName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/flag_green.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if not character then
            client:notifyLocalized("invalidTarget")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if character:hasFlags(k) then character:takeFlags(k) end
        end

        client:notifyLocalized("tookAllFlags")
    end
})

lia.command.add("flagtake", {
    adminOnly = true,
    privilege = "Manage Flags",
    desc = "Take one or more flags away from a character.",
    syntax = "[string playerName] [string flags]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local currentFlags = target:getChar():getFlags()
            return client:requestString(L("flagTakeTitle"), L("flagTakeDesc"), function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, table.concat(currentFlags, ", "))
        end

        target:getChar():takeFlags(flags)
        client:notifyLocalized("flagTake", client:Name(), flags, target:Name())
    end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    privilege = "Manage Items",
    desc = "Bring lost items in a 500 radius to your position.",
    onRun = function(client)
        for _, v in ipairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    desc = "Remove all item entities from the map.",
    onRun = function(client)
        local count = 0
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            count = count + 1
            SafeRemoveEntity(v)
        end

        client:notifyLocalized("cleaningFinished", "Items", count)
    end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    desc = "Remove all prop entities from the map.",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:isProp() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifyLocalized("cleaningFinished", "Props", count)
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    desc = "Remove all NPC entities from the map.",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:IsNPC() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifyLocalized("cleaningFinished", "NPCs", count)
    end
})

lia.command.add("charunban", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Unban a character by name or ID.",
    syntax = "[string name or number id]",
    onRun = function(client, arguments)
        if (client.liaNextSearch or 0) >= CurTime() then return L("searchingChar", client) end
        local queryArg = table.concat(arguments, " ")
        local charFound
        local id = tonumber(queryArg)
        if id then
            for _, v in pairs(lia.char.loaded) do
                if v:getID() == id then
                    charFound = v
                    break
                end
            end
        else
            for _, v in pairs(lia.char.loaded) do
                if lia.util.stringMatches(v:getName(), queryArg) then
                    charFound = v
                    break
                end
            end
        end

        if charFound then
            if charFound:getData("banned") then
                charFound:setData("banned", nil)
                charFound:setData("permakilled", nil)
                return lia.notices.notifyLocalized("charUnBan", nil, client:Name(), charFound:getName())
            else
                return L("charNotBanned")
            end
        end

        client.liaNextSearch = CurTime() + 15
        local sqlCondition = id and "_id = " .. id or "_name LIKE \"%" .. lia.db.escape(queryArg) .. "%\""
        lia.db.query("SELECT _id, _name, _data FROM lia_characters WHERE " .. sqlCondition .. " LIMIT 1", function(data)
            if data and data[1] then
                local charID = tonumber(data[1]._id)
                local charData = util.JSONToTable(data[1]._data or "[]")
                client.liaNextSearch = 0
                if not charData.banned then
                    client:notifyLocalized("charNotBanned")
                    return
                end

                charData.banned = nil
                lia.db.updateTable({
                    _data = util.TableToJSON(charData)
                }, nil, nil, "_id = " .. charID)

                lia.notices.notifyLocalized("charUnBan", nil, client:Name(), data[1]._name)
            end
        end)
    end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Clear a player's entire inventory.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickClearInventoryName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryItems"),
        Icon = "icon16/bin.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():getInv():wipeItems()
        client:notifyLocalized("resetInv", target:getChar():getName())
    end
})

lia.command.add("charkick", {
    adminOnly = true,
    privilege = "Kick Characters",
    desc = "Kick the target's active character to the character menu.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickKickCharacterName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryBans"),
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            for _, targets in player.Iterator() do
                targets:notifyLocalized("charKick", client:Name(), target:Name())
            end

            character:kick()
        else
            client:notifyLocalized("noChar")
        end
    end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Freeze all props owned by a specific player.",
    syntax = "[string playerName]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local count = 0
        local tbl = cleanup.GetList(target)[target:UniqueID()] or {}
        for _, propTable in pairs(tbl) do
            for _, ent in pairs(propTable) do
                if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
                    ent:GetPhysicsObject():EnableMotion(false)
                    count = count + 1
                end
            end
        end

        client:notifyLocalized("freezeAllProps", target:Name())
        client:ChatPrint(L("freezeAllPropsCount", count, target:Name()))
    end
})

lia.command.add("charban", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Ban a character by name or ID.",
    syntax = "[string name or number id]",
    AdminStick = {
        Name = L("adminStickBanCharacterName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryBans"),
        Icon = "icon16/user_red.png"
    },
    onRun = function(client, arguments)
        local queryArg = table.concat(arguments, " ")
        local target
        local id = tonumber(queryArg)
        if id then
            for _, ply in player.Iterator() do
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == id then
                    target = ply
                    break
                end
            end
        else
            target = lia.util.findPlayer(client, arguments[1])
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            character:setData("banned", true)
            character:setData("charBanInfo", {
                name = client.steamName and client:steamName() or client:Name(),
                steamID = client:SteamID64(),
                rank = client:GetUserGroup()
            })

            character:save()
            character:kick()
            client:notifyLocalized("charBan", client:Name(), target:Name())
        else
            client:notifyLocalized("noChar")
        end
    end
})

lia.command.add("checkmoney", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Check how much money the target player has.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickCheckMoneyName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryItems"),
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:ChatPrint(L("playerMoney", target:GetName(), lia.currency.get(money)))
    end
})

lia.command.add("listbodygroups", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "List the available bodygroups for a target player.",
    syntax = "[string playerName]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local bodygroups = {}
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) > 1 then
                table.insert(bodygroups, {
                    group = i,
                    name = target:GetBodygroupName(i),
                    range = "0-" .. target:GetBodygroupCount(i) - 1
                })
            end
        end

        if #bodygroups > 0 then
            local title = L("uiBodygroupsFor")
            lia.util.CreateTableUI(client, title, {
                {
                    name = L("groupID"),
                    field = "group"
                },
                {
                    name = L("name"),
                    field = "name"
                },
                {
                    name = L("range"),
                    field = "range"
                }
            }, bodygroups)
        else
            client:notifyLocalized("noBodygroups")
        end
    end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    desc = "Set a player's run speed.",
    syntax = "[string playerName] [number speed]",
    AdminStick = {
        Name = L("adminStickSetCharSpeedName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/lightning.png",
        ExtraFields = {
            ["speed"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local speed = tonumber(arguments[2]) or lia.config.get("WalkSpeed")
        target:SetRunSpeed(speed)
    end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    privilege = "Manage Character Information",
    desc = "Set a player's model.",
    syntax = "[string playerName] [string model]",
    AdminStick = {
        Name = L("adminStickSetCharModelName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/user_gray.png",
        ExtraFields = {
            ["model"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local oldModel = target:getChar():getModel()
        target:getChar():setModel(arguments[2] or oldModel)
        target:SetupHands()
        client:notifyLocalized("changeModel", client:Name(), target:Name(), arguments[2] or oldModel)
        lia.log.add(client, "charsetmodel", target:Name(), arguments[2], oldModel)
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    privilege = "Manage Items",
    desc = "Give an item to a player's inventory.",
    syntax = "[string playerName] [string itemNameOrID]",
    AdminStick = {
        Name = L("adminStickGiveItemName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryItems"),
        Icon = "icon16/user_gray.png",
        ExtraFields = {
            ["item"] = function()
                local items = {}
                for _, v in pairs(lia.item.list) do
                    table.insert(items, v.name)
                end
                return items, "combo"
            end
        }
    },
    onRun = function(client, arguments)
        local itemName = arguments[2]
        if not itemName or itemName == "" then
            client:notifyLocalized("mustSpecifyItem")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local uniqueID
        for _, v in SortedPairs(lia.item.list) do
            if lia.util.stringMatches(v.name, itemName) or lia.util.stringMatches(v.uniqueID, itemName) then
                uniqueID = v.uniqueID
                break
            end
        end

        if not uniqueID then
            client:notifyLocalized("itemNoExist")
            return
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
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    privilege = "Manage Character Information",
    desc = "Set a player's character description.",
    syntax = "[string playerName] [string description]",
    AdminStick = {
        Name = L("adminStickSetCharDescName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/user_comment.png",
        ExtraFields = {
            ["desc"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyLocalized("noChar")
            return
        end

        local desc = table.concat(arguments, " ", 2)
        if not desc:find("%S") then return client:requestString("Change " .. target:Name() .. "'s Description", L("enterNewDesc"), function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        target:getChar():setDesc(desc)
        return L("descChangedTarget", client:Name(), target:Name())
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    privilege = "Manage Character Information",
    desc = "Set a player's character name.",
    syntax = "[string playerName] [string newName]",
    AdminStick = {
        Name = L("adminStickSetCharNameName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/user_edit.png",
        ExtraFields = {
            ["newName"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local newName = table.concat(arguments, " ", 2)
        if newName == "" then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        target:getChar():setName(newName:gsub("#", "#?"))
        client:notifyLocalized("changeName", client:Name(), target:Name(), newName)
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    desc = "Set a player's model scale.",
    syntax = "[string playerName] [number scale]",
    AdminStick = {
        Name = L("adminStickSetCharScaleName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/arrow_out.png",
        ExtraFields = {
            ["value"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local scale = tonumber(arguments[2]) or 1
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:SetModelScale(scale, 0)
        client:notifyLocalized("changedScale", client:Name(), target:Name(), scale)
    end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    desc = "Set a player's jump power.",
    syntax = "[string playerName] [number power]",
    AdminStick = {
        Name = L("adminStickSetCharJumpName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/arrow_up.png",
        ExtraFields = {
            ["power"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local power = tonumber(arguments[2]) or 200
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:SetJumpPower(power)
        client:notifyLocalized("changedJump", client:Name(), target:Name(), power)
    end
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    privilege = "Manage Bodygroups",
    desc = "Set a specific bodygroup on a player's model.",
    syntax = "[string playerName] [string bodyGroupName] [number value]",
    onRun = function(client, arguments)
        local name = arguments[1]
        local bodyGroup = arguments[2]
        local value = tonumber(arguments[3])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local index = target:FindBodygroupByName(bodyGroup)
        if index > -1 then
            if value and value < 1 then value = nil end
            local groups = target:getChar():getData("groups", {})
            groups[index] = value
            target:getChar():setData("groups", groups)
            target:SetBodygroup(index, value or 0)
            client:notifyLocalized("changeBodygroups", client:Name(), target:Name(), bodyGroup, value or 0)
        else
            client:notifyLocalized("invalidArg")
        end
    end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    desc = "Set a player's skin.",
    syntax = "[string playerName] [number skin]",
    AdminStick = {
        Name = L("adminStickChangeName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategorySetInfos"),
        Icon = "icon16/user_gray.png",
        ExtraFields = {
            ["skin"] = "text"
        }
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local skin = tonumber(arguments[2])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():setData("skin", skin)
        target:SetSkin(skin or 0)
        client:notifyLocalized("changeSkin", client:Name(), target:Name(), skin or 0)
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Set a player's money to a specific amount.",
    syntax = "[string playerName] [number amount]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount or amount < 0 then
            client:notifyLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:getChar():setMoney(math.floor(amount))
        client:notifyLocalized("setMoney", target:Name(), lia.currency.get(math.floor(amount)))
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    desc = "Add a certain amount of money to a player's balance.",
    syntax = "[string playerName] [number amount]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount then
            client:notifyLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        amount = math.Round(amount)
        local currentMoney = target:getChar():getMoney()
        target:getChar():setMoney(currentMoney + amount)
        client:notifyLocalized("addMoney", target:Name(), lia.currency.get(amount), lia.currency.get(currentMoney + amount))
    end,
    alias = {"chargivemoney"}
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    privilege = "Bot Say",
    desc = "Force all bots on the server to say something.",
    syntax = "[string message]",
    onRun = function(client, arguments)
        local message = table.concat(arguments, " ")
        if message == "" then
            client:notifyLocalized("noMessage")
            return
        end

        for _, bot in player.Iterator() do
            if bot:IsBot() then bot:Say(message) end
        end
    end
})

lia.command.add("botsay", {
    superAdminOnly = true,
    privilege = "Bot Say",
    desc = "Force a specific bot to say something.",
    syntax = "[string botName] [string message]",
    onRun = function(client, arguments)
        if #arguments < 2 then
            client:notifyLocalized("needBotAndMessage")
            return
        end

        local botName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local targetBot
        for _, bot in player.Iterator() do
            if bot:IsBot() and string.find(string.lower(bot:Nick()), string.lower(botName)) then
                targetBot = bot
                break
            end
        end

        if not targetBot then
            client:notifyLocalized("botNotFound", botName)
            return
        end

        targetBot:Say(message)
    end
})

lia.command.add("forcesay", {
    superAdminOnly = true,
    privilege = "Force Say",
    desc = "Force a player to say something in chat.",
    syntax = "[string playerName] [string message]",
    AdminStick = {
        Name = "Force Say",
        Category = L("adminStickCategoryModeration"),
        SubCategory = L("adminStickSubCategoryMisc"),
        Icon = "icon16/comments.png",
        ExtraFields = {
            ["message"] = "text"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local message = table.concat(arguments, " ", 2)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if message == "" then
            client:notifyLocalized("noMessage")
            return
        end

        target:Say(message)
    end
})

lia.command.add("getmodel", {
    desc = "Get the model of the entity you are looking at.",
    onRun = function(client)
        local entity = client:getTracedEntity()
        if not IsValid(entity) then
            client:notify("No valid entity found in front of you.")
            return
        end

        local model = entity:GetModel() or "No model found."
        client:ChatPrint("The model is: " .. model)
    end
})

lia.command.add("pm", {
    desc = "Send a private message to another player (if PMs are enabled).",
    syntax = "[string playerName] [string message]",
    onRun = function(client, arguments)
        if not lia.config.get("AllowPMs") then
            client:notifyLocalized("pmsDisabled")
            return
        end

        local targetName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        if not message:find("%S") then
            client:notifyLocalized("noMessage")
            return
        end

        lia.chat.send(client, "pm", message, false, {client, target})
    end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Get the model of a player's character.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharModelName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint("Character Model: " .. target:GetModel())
    end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    privilege = "Get Character Info",
    desc = "Check every player's money balance.",
    onRun = function(client)
        for _, target in player.Iterator() do
            local char = target:getChar()
            if char then client:ChatPrint(client:ChatPrint(L("playerMoney", target:GetName(), lia.currency.get(char:getMoney())))) end
        end
    end
})

lia.command.add("checkflags", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Check which flags a player has.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharFlagsName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/flag_yellow.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local flags = target:getChar():getFlags()
        if flags and #flags > 0 then
            client:ChatPrint(target:Name() .. " — " .. table.concat(flags, ", "))
        else
            client:ChatPrint(target:Name() .. " has no flags.")
        end
    end
})

lia.command.add("chargetname", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Get a player's character name.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharNameName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/user.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint("Character Name: " .. target:getChar():getName())
    end
})

lia.command.add("chargethealth", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Get a player's current health.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharHealthName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/heart.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        client:ChatPrint("Character Health: " .. target:Health() .. "/" .. target:GetMaxHealth())
    end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Get how much money a player has.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharMoneyName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:ChatPrint("Character Money: " .. lia.currency.get(money))
    end
})

lia.command.add("chargetinventory", {
    adminOnly = true,
    privilege = "Get Character Info",
    desc = "Get the contents of a player's inventory.",
    syntax = "[string playerName]",
    AdminStick = {
        Name = L("adminStickGetCharInventoryName"),
        Category = L("adminStickCategoryCharManagement"),
        SubCategory = L("adminStickSubCategoryGetInfos"),
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local inventory = target:getChar():getInv()
        local items = inventory:getItems()
        if not items or table.Count(items) < 1 then
            client:notifyLocalized("charInvEmpty")
            return
        end

        local result = {}
        for _, item in pairs(items) do
            table.insert(result, item.name)
        end

        client:ChatPrint("Character Inventory: " .. table.concat(result, ", "))
    end
})