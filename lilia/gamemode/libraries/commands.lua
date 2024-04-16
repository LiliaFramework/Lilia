--[[--
Registration, parsing, and handling of commands.

Commands can be ran through the chat with slash commands or they can be executed through the console. Commands can be manually
restricted to certain usergroups using a [CAMI](https://github.com/glua/CAMI)-compliant admin mod.
]]
-- @module lia.command

--- A list of available commands for use within the game.
-- Each command is represented by a table with fields defining its functionality.
-- @realm shared
-- @table CommandList
-- **Commands List:**.
--
-- **charsetspeed**: Sets the speed of the character. | **Staff Command**.
--
-- **playglobalsound**: Plays a sound globally for all players. | **Staff Command**.
--
-- **playsound**: Plays a sound for the invoking player. | **Staff Command**.
--
-- **charsetscale**: Sets the scale of the character. | **Staff Command**.
--
-- **charsetjump**: Sets the jump height of the character. | **Staff Command**.
--
-- **charaddmoney**: Adds money to the character's account. | **Staff Command**.
--
-- **charban**: Bans a character from the server. | **Staff Command**.
--
-- **charsetdesc**: Sets the description of the character. | **Staff Command**.
--
-- **charsetname**: Sets the name of the character. | **Staff Command**.
--
-- **chargetmodel**: Sets the target model for a character. | **Staff Command**.
--
-- **charsetmodel**: Sets the model of the character. | **Staff Command**.
--
-- **charsetbodygroup**: Sets the bodygroup of the character. | **Staff Command**.
--
-- **charsetskin**: Sets the skin of the character. | **Staff Command**.
--
-- **chargetmoney**: Sets the target money for a character. | **Staff Command**.
--
-- **charsetmoney**: Sets the money of the character. | **Staff Command**.
--
-- **clearinv**: Clears the inventory of the character. | **Staff Command**.
--
-- **flaggive**: Gives a flag to a character. | **Staff Command**.
--
-- **flaggiveall**: Gives a flag to all characters. | **Staff Command**.
--
-- **flagtakeall**: Removes all flags from all characters. | **Staff Command**.
--
-- **flagtake**: Removes a flag from a character. | **Staff Command**.
--
-- **charkick**: Kicks a character from the server. | **Staff Command**.
--
-- **viewcoreinformation**: Displays core faction information. | **Staff Command**.
--
-- **charunban**: Unbans a character from the server. | **Staff Command**.
--
-- **flagpet**: Sets a character as a pet. | **Staff Command**.
--
-- **flagragdoll**: Sets a character as a ragdoll. | **Staff Command**.
--
-- **flags**: Displays all available flags. | **Staff Command**.
--
-- **freezeallprops**: Freezes all props on the map. | **Staff Command**.
--
-- **checkmoney**: Checks the money of a character. | **Staff Command**.
--
-- **status**: Displays your character's status information.
--
-- **redownloadlightmaps**: Forces a redownload of lightmaps. | **Staff Command**.
--
-- **cleanitems**: Cleans up all dropped items on the map. | **Staff Command**.
--
-- **cleanprops**: Cleans up all props on the map. | **Staff Command**.
--
-- **forcesave**: Forces a save of server data. | **Staff Command**.
--
-- **cleannpcs**: Cleans up all NPCs on the map. | **Staff Command**.
--
-- **checkallmoney**: Checks the money of all characters. | **Staff Command**.
--
-- **return**: Returns to a previous position. | **Staff Command**.
--
-- **findallflags**: Finds all characters with a specific flag. | **Staff Command**.
--
-- **chargiveitem**: Gives an item to a character. | **Staff Command**.
--
-- **announce**: Announces a message to all players. | **Staff Command**.
--
-- **listents**: Lists all entities on the server. | **Staff Command**.
--
-- **flip**: Flips a coin.
--
-- **liststaff**: Lists all staff members on the server.
--
-- **listondutystaff**: Lists all staff members currently on duty.
--
-- **listvip**: Lists all VIP members on the server.
--
-- **listusers**: Lists all users on the server.
--
-- **rolld**: Rolls a specific-sided die. | **Staff Command**.
--
-- **vieweventlog**: Views the server's event log. | **Staff Command**.
--
-- **editeventlog**: Edits the server's event log. | **Staff Command**.
--
-- **roll**: Rolls a die.
--
-- **chardesc**: Sets the description of a character.
--
-- **chargetup**: Sets the target usergroup of a character.
--
-- **givemoney**: Gives money to a character.
--
-- **bringlostitems**: Brings lost items back to the character's inventory. | **Staff Command**.
--
-- **carddraw**: Draws a card from a deck.
--
-- **fallover**: Causes an entity to fall over.
--
-- **getpos**: Gets the position of an entity.
--
-- **entname**: Gets the name of an entity.
--
-- **permflaggive**: Gives a flag permanently to a character. | **Staff Command**.
--
-- **permflagtake**: Removes a flag permanently from a character. | **Staff Command**.
--
-- **permflags**: Displays all permanent flags. | **Staff Command**.
--
-- **flagblacklist**: Adds a flag to the blacklist. | **Staff Command**.
--
-- **flagunblacklist**: Removes a flag from the blacklist. | **Staff Command**.
--
-- **flagblacklists**: Displays all flags on the blacklist. | **Staff Command**.
--
-- **dropmoney**: Drops money at the character's position.
--
-- **membercount**: Displays the count of members in the server.
--
-- **charsetattrib**: Sets the attributes of the character. | **Staff Command**.
--
-- **charaddattrib**: Adds attributes to the character. | **Staff Command**.
--
-- **viewBodygroups**: Displays the bodygroups of the character. | **Staff Command**.
--
-- **storagelock**: Locks the storage container.
--
-- **trunk**: Accesses the trunk of a vehicle.
--
-- **pktoggle**: Toggles the player's PK mode. | **Staff Command**.
--
-- **toggleraise**: Toggles whether the player raises their weapon.
--
-- **fixpac**: Fixes the PAC3 outfit of the player. | **Staff Command**.
--
-- **pacenable**: Enables PAC3 for the player. | **Staff Command**.
--
-- **pacdisable**: Disables PAC3 for the player. | **Staff Command**.
--
-- **cleardecals**: Clears all decals from the world. | **Staff Command**.
--
-- **playtime**: Displays the playtime of the player. | **Staff Command**.
--
-- **3dradioclean**: Cleans up 3D radio entities on the map. | **Staff Command**.
--
-- **auditmoney**: Audits the money transactions on the server. | **Staff Command**.
--
-- **report**: Reports a player to the staff team. | **Player Command**.
--
-- **spawnadd**: Adds a spawn point to the map. | **Staff Command**.
--
-- **respawn**: Respawns the player at their last location. | **Player Command**.
--
-- **spawnremove**: Removes a spawn point from the map. | **Staff Command**.
--
-- **returnitems**: Returns lost items to the player's inventory. | **Staff Command**.
--
-- **classwhitelist**: Whitelists a class for spawning. | **Staff Command**.
--
-- **plytransfer**: Transfers a player to a different server. | **Staff Command**.
--
-- **plywhitelist**: Whitelists a player for spawning. | **Staff Command**.
--
-- **plyunwhitelist**: Removes a player from the whitelist. | **Staff Command**.
--
-- **beclass**: Sets the player's class.
--
-- **setclass**: Sets the player's class. | **Staff Command**.
--
-- **classunwhitelist**: Removes a class from the whitelist. | **Staff Command**.
--
-- **factionlist**: Displays a list of factions.
--
-- **charvoiceunban**: Unbans a character's voice. | **Staff Command**.
--
-- **charvoiceban**: Bans a character's voice. | **Staff Command**.
--
-- **voicetoggle**: Toggles the player's voice. | **Staff Command**.
--
-- **banooc**: Bans OOC chat for the player. | **Staff Command**.
--
-- **unbanooc**: Unbans OOC chat for the player. | **Staff Command**.
--
-- **blockooc**: Blocks OOC chat for the player. | **Staff Command**.
--
-- **refreshfonts**: Refreshes the fonts for the player. | **Staff Command**.
--
-- **clearchat**: Clears the chat for the player. | **Staff Command**.
--
-- **doorsell**: Sells a door to the player. | **Staff Command**.
--
-- **doorsetlocked**: Sets the door as locked. | **Staff Command**.
--
-- **doorbuy**: Buys a door for the player. | **Staff Command**.
--
-- **doorsetunownable**: Sets the door as unownable. | **Staff Command**.
--
-- **doorsetownable**: Sets the door as ownable. | **Staff Command**.
--
-- **dooraddfaction**: Adds a faction to the door. | **Staff Command**.
--
-- **doorremovefaction**: Removes a faction from the door. | **Staff Command**.
--
-- **doorsetdisabled**: Sets the door as disabled. | **Staff Command**.
--
-- **doorsettitle**: Sets the title of the door. | **Staff Command**.
--
-- **doorsetparent**: Sets the parent of the door. | **Staff Command**.
--
-- **doorsetchild**: Sets the child of the door. | **Staff Command**.
--
-- **doorremovechild**: Removes the child from the door. | **Staff Command**.
--
-- **doorsetclass**: Sets the class of the door. | **Staff Command**.
--
-- **savedoors**: Saves the state of the doors. | **Staff Command**.
--
-- **legacylogs**: Views the legacy logs. | **Staff Command**.
--
-- **logger**: Views the server's log. | **Staff Command**.
--
-- **deletelogs**: Deletes the logs. | **Staff Command**.
--
-- **netlogs**: Views the network logs. | **Staff Command**.
--
-- **concommandlogs**: Views the concommand logs. | **Staff Command**.
--
-- **restockallvendors**: Restocks all vendors on the map. | **Staff Command**.
--
-- **resetallvendormoney**: Resets all vendor money on the map. | **Staff Command**.
--
-- **savevendors**: Saves the state of the vendors. | **Staff Command**.

lia.command = lia.command or {}
lia.command.list = lia.command.list or {}

--- When registering commands with `lia.command.add`, you'll need to pass in a valid command structure. This is simply a table
-- with various fields defined to describe the functionality of the command.
-- @realm shared
-- @table CommandStructure
-- @field[type=function] onRun This function is called when the command has passed all the checks and can execute. The
-- arguments will be the calling player and subsequent argument list.
--
-- @field[type=boolean,opt=false] adminOnly Provides an additional check to see if the user is an admin before running.
-- @field[type=boolean,opt=false] superAdminOnly Provides an additional check to see if the user is a superadmin before running.
-- @field[type=string,opt=nil] privilege Manually specify a privilege name for this command. It will always be prefixed with
-- `"Commands - "`. This is used in the case that you want to group commands under the same privilege, or use a privilege that
-- you've already defined (i.e grouping `/charban` and `/charunban` into the `Commands - Ban Characters` privilege).
-- @field[type=function,opt=nil] onCheckAccess This callback checks whether or not the player is allowed to run the command.
-- This callback should **NOT** be used in conjunction with `adminOnly` or `superAdminOnly`, as populating those
-- fields create a custom a `OnCheckAccess` callback for you internally. This is used in cases where you want more fine-grained
-- access control for your command.

-- Consider this example command:
-- 	lia.command.add("slap", {
-- 		adminOnly = true,
-- 		privilege = "Can Slap",
-- 		onRun = function(client, arguments)
-- 			-- WHAM!
-- 		end
-- 	})

function lia.command.add(command, data)
    data.syntax = data.syntax or "[none]"
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local acessLevels = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user")
    local userCommand = acessLevels == "user"
    if not data.onRun then return ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n") end
    if data.group then
        ErrorNoHalt("Command '" .. data.name .. "' tried to use the deprecated field 'group'!\n")
        return
    end

    local privilege = "Commands - " .. (isstring(data.privilege) and data.privilege or (userCommand and "Default User Commands" or command))
    if not CAMI.GetPrivilege(privilege) then
        CAMI.RegisterPrivilege({
            Name = privilege,
            MinAccess = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user"),
            Description = data.description
        })
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        if lia.command.hasAccess(client, command, data) then
            return onRun(client, arguments)
        else
            return "@noPerm"
        end
    end

    local alias = data.alias
    if alias then
        if istable(alias) then
            for _, v in ipairs(alias) do
                lia.command.list[v:lower()] = data
            end
        elseif isstring(alias) then
            lia.command.list[alias:lower()] = data
        end
    end

    if command == command:lower() then
        lia.command.list[command] = data
    else
        data.realCommand = command
        lia.command.list[command:lower()] = data
    end
end

function lia.command.hasAccess(client, command, data)
    if data == nil then data = lia.command.list[command] end
    local privilege = data.privilege
    if not privilege then privilege = command end
    local bHasAccess, _ = CAMI.PlayerHasAccess(client, "Commands - " .. privilege, nil)
    if hook.GetTable()["CanPlayerUseCommand"] then return hook.Run("CanPlayerUseCommand") end
    return bHasAccess
end

function lia.command.extractArgs(text)
    local skip = 0
    local arguments = {}
    local curString = ""
    for i = 1, #text do
        if i <= skip then continue end
        local c = text:sub(i, i)
        if c == "\"" then
            local match = text:sub(i):match("%b" .. c .. c)
            if match then
                curString = ""
                skip = i + #match
                arguments[#arguments + 1] = match:sub(2, -2)
            else
                curString = curString .. c
            end
        elseif c == " " and curString ~= "" then
            arguments[#arguments + 1] = curString
            curString = ""
        else
            if c == " " and curString == "" then continue end
            curString = curString .. c
        end
    end

    if curString ~= "" then arguments[#arguments + 1] = curString end
    return arguments
end

if SERVER then
    function lia.command.findPlayer(client, name)
        if isstring(name) then
            if name == "^" then
                return client
            elseif name == "@" then
                local trace = client:GetEyeTrace().Entity
                if IsValid(trace) and trace:IsPlayer() then
                    return trace
                else
                    client:notifyLocalized("lookToUseAt")
                    return
                end
            end

            local target = lia.util.findPlayer(name) or NULL
            if IsValid(target) then
                return target
            else
                client:notifyLocalized("plyNoExist")
            end
        else
            client:notifyLocalized("mustProvideString")
        end
    end

    function lia.command.findFaction(client, name)
        if lia.faction.teams[name] then return lia.faction.teams[name] end
        for _, v in ipairs(lia.faction.indices) do
            if lia.util.stringMatches(L(v.name, client), name) then return v end
        end

        client:notifyLocalized("invalidFaction")
    end

    function lia.command.findPlayerSilent(client, name)
        local target = type(name) == "string" and lia.util.findPlayer(name) or NULL
        if type(name) == "string" and name == "@" then
            local lookingAt = client:GetEyeTrace().Entity
            if IsValid(lookingAt) and lookingAt:IsPlayer() then target = lookingAt end
        end

        if IsValid(target) then return target end
    end

    function lia.command.findFaction(client, name)
        if lia.faction.teams[name] then return lia.faction.teams[name] end
        for _, v in ipairs(lia.faction.indices) do
            if lia.util.stringMatches(L(v.name, client), name) then return v end
        end

        client:notifyLocalized("invalidFaction")
    end

    function lia.command.run(client, command, arguments)
        command = lia.command.list[command:lower()]
        if command then
            local results = {command.onRun(client, arguments or {})}
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyLocalized(result:sub(2), unpack(results, 2))
                    else
                        client:notify(result)
                    end

                    lia.log.add(client, "command", command, table.concat(arguments, ", "))
                else
                    print(result)
                end
            end
        end
    end

    function lia.command.parse(client, text, realCommand, arguments)
        if realCommand or text:utf8sub(1, 1) == "/" then
            local match = realCommand or text:lower():match("/" .. "([_%w]+)")
            if not match then
                local post = string.Explode(" ", text)
                local len = string.len(post[1])
                match = post[1]:utf8sub(2, len)
            end

            match = match:lower()
            local command = lia.command.list[match]
            if command then
                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                lia.command.run(client, match, arguments)
                if not realCommand then lia.log.add(client, "command", text) end
            else
                if IsValid(client) then
                    client:notifyLocalized("cmdNoExist")
                else
                    print("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    function lia.command.send(command, ...)
        netstream.Start("cmd", command, {...})
    end
end