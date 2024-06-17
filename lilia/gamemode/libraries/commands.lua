--[[--
Registration, parsing, and handling of commands.

Commands can be ran through the chat with slash commands or they can be executed through the console. Commands can be manually
restricted to certain usergroups using a [CAMI](https://github.com/glua/CAMI)-compliant admin mod.

If you are looking for the command structure, you can find it [here](https://liliaframework.github.io/manual/structure_command).
]]
-- @library lia.command
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
-- This callback should NOT** be used in conjunction with `adminOnly` or `superAdminOnly`, as populating those
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
--- Creates a new command.
-- @realm shared
-- @string command Name of the command (recommended in UpperCamelCase)
-- @tab data Data describing the command
-- @see CommandStructure
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
    if not CAMI.GetPrivilege(privilege) and privilege ~= "Dummy Command" then
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

--- Returns true if a player is allowed to run a certain command.
-- @realm shared
-- @internal
-- @client client to check access for
-- @string command Name of the command to check access for
-- @tab[opt] data command data, if not provided, it will be fetched from `lia.command.list`
-- @treturn bool Whether or not the player is allowed to run the command
function lia.command.hasAccess(client, command, data)
    if data == nil then data = lia.command.list[command] end
    local privilege = data.privilege
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local acessLevels = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user")
    if not privilege then privilege = acessLevels == "user" and "Default User Commands" or command end
    local hasAccess, _ = CAMI.PlayerHasAccess(client, "Commands - " .. privilege, nil)
    return hasAccess
end

--- Returns a table of arguments from a given string.
-- Words separated by spaces will be considered one argument. To have an argument containing multiple words, they must be
-- contained within quotation marks.
-- @realm shared
-- @string text String to extract arguments from
-- @treturn table Arguments extracted from string
-- @usage PrintTable(lia.command.extractArgs("these are \"some arguments\""))
-- > 1 = these
-- > 2 = are
-- > 3 = some arguments
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
    --- Attempts to find a player by an identifier. If unsuccessful, a notice will be displayed to the specified player. The
    -- search criteria is derived from `lia.command.findPlayer`.
    -- @realm server
    -- @client client to give a notification to if the player could not be found
    -- @string name Search query
    -- @treturn[1] player Player that matches the given search query
    -- @treturn[2] nil If a player could not be found
    -- @see lia.util.findPlayer
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

    --- Attempts to find a faction by an identifier.
    -- @realm server
    -- @client client to give a notification to if the faction could not be found
    -- @string name Search query
    -- @treturn[1] table Faction that matches the given search query
    -- @treturn[2] nil If a faction could not be found
    function lia.command.findFaction(client, name)
        if lia.faction.teams[name] then return lia.faction.teams[name] end
        for _, v in ipairs(lia.faction.indices) do
            if lia.util.stringMatches(L(v.name, client), name) then return v end
        end

        client:notifyLocalized("invalidFaction")
    end

    --- Attempts to find a player by an identifier silently.
    -- @realm server
    -- @client client to give a notification to if the player could not be found
    -- @string name Search query
    -- @treturn player|nil Player that matches the given search query, or nil if not found
    function lia.command.findPlayerSilent(client, name)
        local target = type(name) == "string" and lia.util.findPlayer(name) or NULL
        if type(name) == "string" and name == "@" then
            local lookingAt = client:GetEyeTrace().Entity
            if IsValid(lookingAt) and lookingAt:IsPlayer() then target = lookingAt end
        end

        if IsValid(target) then return target end
    end

    --- Forces a player to execute a command by name.
    -- @realm server
    -- @client client who is executing the command
    -- @string command Full name of the command to be executed. This string gets lowered, but it's good practice to stick with the exact name of the command
    -- @tab arguments Array of arguments to be passed to the command
    -- @usage lia.command.run(player.GetByID(1), "Roll", {10})
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
                else
                    print(result)
                end
            end
        end
    end

    --- Parses a command from an input string and executes it.
    -- @realm server
    -- @client client The player who is executing the command
    -- @string text Input string to search for the command format
    -- @string[opt] realCommand Specific command to check for. If specified, it will only try to run this command
    -- @tab[opt] arguments Array of arguments to pass to the command. If not specified, it will try to extract them from the text
    -- @return bool Whether or not a command has been found and executed
    -- @usage lia.command.parse(player.GetByID(1), "/roll 10")
    -- @internal
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
                    LiliaInformation("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    --- Request the server to run a command. This mimics similar functionality to the client typing `/CommandName` in the chatbox.
    -- @realm client
    -- @string command Unique ID of the command
    -- @tab ... Arguments to pass to the command
    -- @usage lia.command.send("roll", 10)
    function lia.command.send(command, ...)
        netstream.Start("cmd", command, {...})
    end
end
--- A list of available commands for use within the game.
-- Each command is represented by a table with fields defining its functionality.
-- @realm shared
-- @table CommandList
-- @field charsetspeed Sets the speed of the character | **Staff Command**.
-- @field playglobalsound Plays a sound globally for all players | **Staff Command**.
-- @field playsound Plays a sound for the invoking player | **Staff Command**.
-- @field charsetscale Sets the scale of the character | **Staff Command**.
-- @field charsetjump Sets the jump height of the character | **Staff Command**.
-- @field charaddmoney Adds money to the character's account | **Staff Command**.
-- @field charban Bans a character from the server | **Staff Command**.
-- @field charsetdesc Sets the description of the character | **Staff Command**.
-- @field charsetname Sets the name of the character | **Staff Command**.
-- @field chargetmodel Sets the target model for a character | **Staff Command**.
-- @field charsetmodel Sets the model of the character | **Staff Command**.
-- @field charsetbodygroup Sets the bodygroup of the character | **Staff Command**.
-- @field charsetskin Sets the skin of the character | **Staff Command**.
-- @field chargetmoney Sets the target money for a character | **Staff Command**.
-- @field charsetmoney Sets the money of the character | **Staff Command**.
-- @field clearinv Clears the inventory of the character | **Staff Command**.
-- @field flaggive Gives a flag to a character | **Staff Command**.
-- @field flaggiveall Gives a flag to all characters | **Staff Command**.
-- @field flagtakeall Removes all flags from all characters | **Staff Command**.
-- @field flagtake Removes a flag from a character | **Staff Command**.
-- @field charkick Kicks a character from the server | **Staff Command**.
-- @field viewcoreinformation Displays core faction information | **Staff Command**.
-- @field charunban Unbans a character from the server | **Staff Command**.
-- @field flagpet Sets a character as a pet | **Staff Command**.
-- @field flagragdoll Sets a character as a ragdoll | **Staff Command**.
-- @field flags Displays all available flags | **Staff Command**.
-- @field freezeallprops Freezes all props on the map | **Staff Command**.
-- @field checkmoney Checks the money of a character | **Staff Command**.
-- @field status Displays your character's status information.
-- @field redownloadlightmaps Forces a redownload of lightmaps | **Staff Command**.
-- @field cleanitems Cleans up all dropped items on the map | **Staff Command**.
-- @field cleanprops Cleans up all props on the map | **Staff Command**.
-- @field forcesave Forces a save of server data | **Staff Command**.
-- @field cleannpcs Cleans up all NPCs on the map | **Staff Command**.
-- @field checkallmoney Checks the money of all characters | **Staff Command**.
-- @field return Returns to a previous position | **Staff Command**.
-- @field findallflags Finds all characters with a specific flag | **Staff Command**.
-- @field chargiveitem Gives an item to a character | **Staff Command**.
-- @field announce Announces a message to all players | **Staff Command**.
-- @field listents Lists all entities on the server | **Staff Command**.
-- @field flip Flips a coin.
-- @field liststaff Lists all staff members on the server.
-- @field listondutystaff Lists all staff members currently on duty.
-- @field listvip Lists all VIP members on the server.
-- @field listusers Lists all users on the server.
-- @field rolld Rolls a specific-sided die | **Staff Command**.
-- @field vieweventlog Views the server's event log | **Staff Command**.
-- @field editeventlog Edits the server's event log | **Staff Command**.
-- @field roll Rolls a die.
-- @field chardesc Sets the description of a character.
-- @field chargetup Sets the target usergroup of a character.
-- @field givemoney Gives money to a character.
-- @field bringlostitems Brings lost items back to the character's inventory | **Staff Command**.
-- @field carddraw Draws a card from a deck.
-- @field fallover Causes an entity to fall over.
-- @field getpos Gets the position of an entity.
-- @field entname Gets the name of an entity.
-- @field permflaggive Gives a flag permanently to a character | **Staff Command**.
-- @field permflagtake Removes a flag permanently from a character | **Staff Command**.
-- @field permflags Displays all permanent flags | **Staff Command**.
-- @field flagblacklist Adds a flag to the blacklist | **Staff Command**.
-- @field flagunblacklist Removes a flag from the blacklist | **Staff Command**.
-- @field flagblacklists Displays all flags on the blacklist | **Staff Command**.
-- @field dropmoney Drops money at the character's position.
-- @field membercount Displays the count of members in the server.
-- @field charsetattrib Sets the attributes of the character | **Staff Command**.
-- @field charaddattrib Adds attributes to the character | **Staff Command**.
-- @field viewBodygroups Displays the bodygroups of the character | **Staff Command**.
-- @field storagelock Locks the storage container.
-- @field trunk Accesses the trunk of a vehicle.
-- @field pktoggle Toggles the player's PK mode | **Staff Command**.
-- @field toggleraise Toggles whether the player raises their weapon.
-- @field fixpac Fixes the PAC3 outfit of the player | **Staff Command**.
-- @field pacenable Enables PAC3 for the player | **Staff Command**.
-- @field pacdisable Disables PAC3 for the player | **Staff Command**.
-- @field cleardecals Clears all decals from the world | **Staff Command**.
-- @field playtime Displays the playtime of the player | **Staff Command**.
-- @field 3dradioclean Cleans up 3D radio entities on the map | **Staff Command**.
-- @field auditmoney Audits the money transactions on the server | **Staff Command**.
-- @field report Reports a player to the staff team |  Player Command.
-- @field spawnadd Adds a spawn point to the map | **Staff Command**.
-- @field respawn Respawns the player at their last location |  Player Command.
-- @field spawnremove Removes a spawn point from the map | **Staff Command**.
-- @field returnitems Returns lost items to the player's inventory | **Staff Command**.
-- @field classwhitelist Whitelists a class for spawning | **Staff Command**.
-- @field plytransfer Transfers a player to a different server | **Staff Command**.
-- @field plywhitelist Whitelists a player for spawning | **Staff Command**.
-- @field plyunwhitelist Removes a player from the whitelist | **Staff Command**.
-- @field beclass Sets the player's class.
-- @field setclass Sets the player's class | **Staff Command**.
-- @field classunwhitelist Removes a class from the whitelist | **Staff Command**.
-- @field factionlist Displays a list of factions.
-- @field charvoiceunban Unbans a character's voice | **Staff Command**.
-- @field charvoiceban Bans a character's voice | **Staff Command**.
-- @field voicetoggle Toggles the player's voice | **Staff Command**.
-- @field banooc Bans OOC chat for the player | **Staff Command**.
-- @field unbanooc Unbans OOC chat for the player | **Staff Command**.
-- @field blockooc Blocks OOC chat for the player | **Staff Command**.
-- @field refreshfonts Refreshes the fonts for the player | **Staff Command**.
-- @field clearchat Clears the chat for the player | **Staff Command**.
-- @field doorsell Sells a door to the player | **Staff Command**.
-- @field doorsetlocked Sets the door as locked | **Staff Command**.
-- @field doorbuy Buys a door for the player | **Staff Command**.
-- @field doorsetunownable Sets the door as unownable | **Staff Command**.
-- @field doorsetownable Sets the door as ownable | **Staff Command**.
-- @field dooraddfaction Adds a faction to the door | **Staff Command**.
-- @field doorremovefaction Removes a faction from the door | **Staff Command**.
-- @field doorsetdisabled Sets the door as disabled | **Staff Command**.
-- @field doorsettitle Sets the title of the door | **Staff Command**.
-- @field doorsetparent Sets the parent of the door | **Staff Command**.
-- @field doorsetchild Sets the child of the door | **Staff Command**.
-- @field doorremovechild Removes the child from the door | **Staff Command**.
-- @field doorsetclass Sets the class of the door | **Staff Command**.
-- @field savedoors Saves the state of the doors | **Staff Command**.
-- @field legacylogs Views the legacy logs | **Staff Command**.
-- @field logger Views the server's log | **Staff Command**.
-- @field deletelogs Deletes the logs | **Staff Command**.
-- @field restockallvendors Restocks all vendors on the map | **Staff Command**.
-- @field resetallvendormoney Resets all vendor money on the map | **Staff Command**.
-- @field savevendors Saves the state of the vendors | **Staff Command**.