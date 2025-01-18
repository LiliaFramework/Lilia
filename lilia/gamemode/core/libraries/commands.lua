
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
-- @field[type=bool,opt=false] adminOnly Provides an additional check to see if the user is an admin before running.
-- @field[type=bool,opt=false] superAdminOnly Provides an additional check to see if the user is a superadmin before running.
-- @field[type=string,opt=nil] privilege Manually specify a privilege name for this command. It will always be prefixed with
-- `"Commands - "`. This is used in the case that you want to group commands under the same privilege, or use a privilege that
-- you've already defined (i.e grouping `/charban` and `/charunban` into the `Commands - Ban Characters` privilege).
-- @field[type=function,opt=nil] onCheckAccess This callback checks whether or not the player is allowed to run the command.
-- This callback should NOT be used in conjunction with `adminOnly` or `superAdminOnly`, as populating those
-- fields create a custom `onCheckAccess` callback for you internally. This is used in cases where you want more fine-grained
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
    data.syntax = data.syntax or "[None]"
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n")
        return
    end

    if data.group then
        ErrorNoHalt("Command '" .. (data.name or command) .. "' tried to use the deprecated field 'group'!\n")
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = "Commands - " .. (isstring(data.privilege) and data.privilege or command)
        if not CAMI.GetPrivilege(privilegeName) then
            CAMI.RegisterPrivilege({
                Name = privilegeName,
                MinAccess = superAdminOnly and "superadmin" or "admin",
                Description = data.description
            })
        end
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        local hasAccess, _ = lia.command.hasAccess(client, command, data)
        if hasAccess then
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

--- Checks if a player has access to execute a specific command.
-- This function determines whether a player is authorized to run a given command based on privileges, admin-only or superadmin-only restrictions, and any custom hooks.
-- @realm shared
-- @internal
-- @client client The player to check access for.
-- @string command The name of the command to check access for.
-- @tab[opt] data The command data. If not provided, the function retrieves the data from `lia.command.list`.
-- @treturn bool Whether or not the player has access to the command.
-- @treturn string The privilege associated with the command.
-- @usage
-- local canUse, privilege = lia.command.hasAccess(player, "ban")
-- if canUse then
--     print("Player can run the command:", privilege)
-- else
--     print("Player does not have access to the command:", privilege)
-- end
function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    local privilege = data.privilege
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user")
    if not privilege then privilege = (accessLevels == "user") and "Global" or command end
    local hasAccess = true
    if accessLevels ~= "user" then
        local privilegeName = "Commands - " .. privilege
        hasAccess = client:hasPrivilege(privilegeName)
    end

    if hook.Run("CanPlayerUseCommand", client, command) == false then hasAccess = false end
    return hasAccess, privilege
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
    -- @client client Player The client to give a notification to if the player could not be found.
    -- @string name Search query
    -- @treturn player|nil Player that matches the given search query, or nil if a player could not be found
    -- @see lia.util.findPlayer
    function lia.command.findPlayer(client, name)
        if isstring(name) then
            if string.find(name, "^STEAM_%d+:%d+:%d+$") then
                local player = player.GetBySteamID(name)
                if IsValid(player) then
                    return player
                else
                    client:notifyLocalized("plyNoExist")
                    return nil
                end
            end

            if name == "^" then
                return client
            elseif name == "@" then
                local trace = client:getTracedEntity()
                if IsValid(trace) and trace:IsPlayer() then
                    return trace
                else
                    client:notifyLocalized("lookToUseAt")
                    return nil
                end
            end

            local target = lia.util.findPlayer(name) or NULL
            if IsValid(target) then
                return target
            else
                client:notifyLocalized("plyNoExist")
                return nil
            end
        else
            client:notifyLocalized("mustProvideString")
            return nil
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
        local target = isstring(name) and lia.util.findPlayer(name) or NULL
        if isstring(name) and name == "@" then
            local lookingAt = client:getTracedEntity()
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
    -- @usage lia.command.send("roll")
    function lia.command.send(command, ...)
        netstream.Start("cmd", command, {...})
    end
end
