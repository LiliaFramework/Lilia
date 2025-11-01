--[[
    Chatbox Library

    Comprehensive chat system management with message routing and formatting for the Lilia framework.
]]
--[[
    Overview:
        The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework. It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing, distance-based hearing mechanics, and chat formatting. The library operates on both server and client sides, with the server managing message distribution and validation, while the client handles parsing and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based communication, and integration with the command system for chat-based commands.
]]
lia.chat = lia.chat or {}
lia.chat.classes = lia.chat.classes or {}
--[[
    Purpose:
        Generates a formatted timestamp string for chat messages based on current time

    When Called:
        Automatically called when displaying chat messages if timestamps are enabled

    Parameters:
        ooc (boolean) - Whether this is an OOC message (affects spacing format)

    Returns:
        string - Formatted timestamp string or empty string if timestamps disabled

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get timestamp for IC message
        local timestamp = lia.chat.timestamp(false)

        -- Returns: " (14:30) " or "" if timestamps disabled
        ```

    Medium Complexity:
        ```lua
        -- Medium: Use timestamp in custom chat format
        local function customChatFormat(speaker, text)
            local timeStr = lia.chat.timestamp(false)
            chat.AddText(timeStr, Color(255, 255, 255), speaker:Name() .. ": " .. text)
        end
        ```

    High Complexity:
        ```lua
        -- High: Dynamic timestamp with custom formatting
        local function getFormattedTimestamp(isOOC, customFormat)
            local baseTime = lia.chat.timestamp(isOOC)
            if customFormat and baseTime ~= "" then
                return baseTime:gsub("%((%d+:%d+)%)", "[" .. customFormat .. "]")
            end
            return baseTime
        end
        ```
]]
function lia.chat.timestamp(ooc)
    return lia.option.ChatShowTime and (ooc and " " or "") .. "(" .. lia.time.getHour() .. ")" .. (ooc and "" or " ") or ""
end

--[[
    Purpose:
        Registers a new chat type with the chatbox system, defining its behavior and properties

    When Called:
        During module initialization to register custom chat types (IC, OOC, whisper, etc.)

    Parameters:
        chatType (string) - Unique identifier for the chat type
        data (table) - Configuration table containing chat type properties

    Returns:
        void

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register basic IC chat
        lia.chat.register("ic", {
            prefix = "/",
            color  = Color(255, 255, 255),
            radius = 200
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register whisper chat with custom properties
        lia.chat.register("whisper", {
            prefix = {"/w", "/whisper"},
            color  = Color(150, 150, 255),
            radius = 50,
            format = "whisperFormat",
            desc   = "Whisper to nearby players"
        })
        ```

    High Complexity:
        ```lua
        -- High: Register admin chat with complex validation
        lia.chat.register("admin", {
            prefix    = "/a",
            color     = Color(255, 100, 100),
            onCanSay  = function(speaker)
                return speaker:IsAdmin()
            end,
            onCanHear = function(speaker, listener)
                return listener:IsAdmin()
            end,
            format    = "adminFormat",
            arguments = {
                {type = "string", name = "message"}
            },
            desc      = "Admin-only communication channel"
        })
        ```
]]
function lia.chat.register(chatType, data)
    data.arguments = data.arguments or {}
    data.syntax = L(lia.command.buildSyntaxFromArguments(data.arguments))
    data.desc = data.desc or ""
    if data.prefix then
        local prefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local processed, lookup = {}, {}
        for _, prefix in ipairs(prefixes) do
            if prefix ~= "" and not lookup[prefix] then
                processed[#processed + 1] = prefix
                lookup[prefix] = true
            end

            local noSlash = prefix:gsub("^/", "")
            if noSlash ~= "" and not lookup[noSlash] and noSlash:sub(1, 1) ~= "/" then
                processed[#processed + 1] = noSlash
                lookup[noSlash] = true
            end
        end

        data.prefix = processed
    end

    if not data.onCanHear then
        if isfunction(data.radius) then
            data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= data.radius() ^ 2 end
        elseif isnumber(data.radius) then
            local range = data.radius ^ 2
            data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range end
        else
            data.onCanHear = function() return true end
        end
    elseif isnumber(data.onCanHear) then
        local range = data.onCanHear ^ 2
        data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= range end
    end

    data.onCanSay = data.onCanSay or function(speaker)
        if not data.deadCanChat and not speaker:Alive() then
            speaker:notifyErrorLocalized("noPerm")
            return false
        end
        return true
    end

    data.color = data.color or (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150)
    data.format = data.format or "chatFormat"
    data.onChatAdd = data.onChatAdd or function(speaker, text, anonymous) chat.AddText(lia.chat.timestamp(false), (lia.color.theme and lia.color.theme.chat) or Color(255, 239, 150), L(data.format, anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or L("console"), text)) end
    if CLIENT and data.prefix then
        local rawPrefixes = istable(data.prefix) and data.prefix or {data.prefix}
        local aliases, lookup = {}, {}
        for _, prefix in ipairs(rawPrefixes) do
            if prefix:sub(1, 1) == "/" then
                local cmd = prefix:gsub("^/", ""):lower()
                local isCommonWord = cmd == "it" or cmd == "me" or cmd == "w" or cmd == "y" or cmd == "a"
                if cmd ~= "" and not lookup[cmd] and not isCommonWord then
                    table.insert(aliases, cmd)
                    lookup[cmd] = true
                end
            end
        end

        if #aliases > 0 then
            lia.command.add(chatType, {
                arguments = data.arguments,
                desc = data.desc,
                alias = aliases,
                onRun = function(_, args) lia.chat.parse(LocalPlayer(), table.concat(args, " ")) end
            })
        end
    end

    data.filter = data.filter or "ic"
    lia.chat.classes[chatType] = data
end

--[[
    Purpose:
        Parses a chat message to determine its type and extract the actual message content

    When Called:
        When a player sends a chat message, either from client input or server processing

    Parameters:
        client (Player) - The player who sent the message
        message (string) - The raw message text to parse
        noSend (boolean, optional) - If true, prevents sending the message to other players

    Returns:
        chatType (string), message (string), anonymous (boolean)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Parse a basic IC message
        local chatType, message, anonymous = lia.chat.parse(LocalPlayer(), "Hello everyone!")

        -- Returns: "ic", "Hello everyone!", false
        ```

    Medium Complexity:
        ```lua
        -- Medium: Parse message with prefix detection
        local function processPlayerMessage(player, rawMessage)
            local chatType, cleanMessage, anonymous = lia.chat.parse(player, rawMessage)
            if chatType == "ooc" then
                print(player:Name() .. " said OOC: " .. cleanMessage)
            end
            return chatType, cleanMessage, anonymous
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced message processing with validation
        local function advancedMessageParser(player, message, options)
            local chatType, cleanMessage, anonymous = lia.chat.parse(player, message, options.noSend)

            -- Custom validation based on chat type
            if chatType == "admin" and not player:IsAdmin() then
                player:notifyErrorLocalized("noPerm")
                return nil, nil, nil
            end

            -- Log message for moderation
            if options.logMessages then
                lia.log.add("chat", player:Name() .. " [" .. chatType .. "]: " .. cleanMessage)
            end

            return chatType, cleanMessage, anonymous
        end
        ```
]]
function lia.chat.parse(client, message, noSend)
    local anonymous = false
    local chatType = "ic"
    for k, v in pairs(lia.chat.classes) do
        local isChosen = false
        local chosenPrefix = ""
        local noSpaceAfter = v.noSpaceAfter
        if istable(v.prefix) then
            for _, prefix in ipairs(v.prefix) do
                if message:sub(1, #prefix + (noSpaceAfter and 0 or 1)):lower() == (prefix .. (noSpaceAfter and "" or " ")):lower() then
                    isChosen = true
                    chosenPrefix = prefix .. (v.noSpaceAfter and "" or " ")
                    break
                end
            end
        elseif isstring(v.prefix) then
            isChosen = message:sub(1, #v.prefix + (noSpaceAfter and 0 or 1)):lower() == (v.prefix .. (v.noSpaceAfter and "" or " ")):lower()
            chosenPrefix = v.prefix .. (v.noSpaceAfter and "" or " ")
        end

        if isChosen then
            chatType = k
            message = message:sub(#chosenPrefix + 1)
            if lia.chat.classes[k].noSpaceAfter and message:sub(1, 1):match("%s") then message = message:sub(2) end
            break
        end
    end

    if not message:find("%S") then return end
    local newType, newMsg, newAnon = hook.Run("ChatParsed", client, chatType, message, anonymous)
    chatType = newType or chatType
    message = newMsg or message
    anonymous = newAnon ~= nil and newAnon or anonymous
    if SERVER and not noSend then
        if chatType == "ooc" then hook.Run("OnOOCMessageSent", client, message) end
        lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous)
    end
    return chatType, message, anonymous
end

--[[
    Purpose:
        Sends a chat message to appropriate recipients based on chat type and hearing rules

    When Called:
        Server-side when distributing parsed chat messages to players

    Parameters:
        speaker (Player) - The player who sent the message
        chatType (string) - The type of chat message (ic, ooc, whisper, etc.)
        text (string) - The message content to send
        anonymous (boolean, optional) - Whether to hide the speaker's identity
        receivers (table, optional) - Specific list of players to send to

    Returns:
        void

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Send IC message to all nearby players
        lia.chat.send(player, "ic", "Hello everyone!")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send anonymous whisper to specific players
        local function sendAnonymousWhisper(speaker, message, targets)
            lia.chat.send(speaker, "whisper", message, true, targets)
        end
        ```

    High Complexity:
        ```lua
        -- High: Advanced message broadcasting with custom logic
        local function broadcastAdminMessage(speaker, message, options)
            local receivers = {}

            -- Collect admin players
            for _, player in pairs(player.GetAll()) do
                if player:IsAdmin() and (not options.excludeSelf or player ~= speaker) then
                    table.insert(receivers, player)
                end
            end

            -- Send with custom formatting
            lia.chat.send(speaker, "admin", "[ADMIN] " .. message, false, receivers)

            -- Log the message
            lia.log.add("admin_chat", speaker:Name() .. ": " .. message)
        end
        ```
]]
if SERVER then
    function lia.chat.send(speaker, chatType, text, anonymous, receivers)
        local class = lia.chat.classes[chatType]
        if class and class.onCanSay(speaker, text) ~= false then
            if class.onCanHear and not receivers then
                receivers = {}
                for _, v in player.Iterator() do
                    if v:getChar() and class.onCanHear(speaker, v) ~= false then receivers[#receivers + 1] = v end
                end

                if #receivers == 0 then return end
            end

            net.Start("liaChatMsg")
            net.WriteEntity(speaker)
            net.WriteString(chatType)
            net.WriteString(hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text)
            net.WriteBool(anonymous)
            if istable(receivers) then
                net.Send(receivers)
            else
                net.Broadcast()
            end
        end
    end
end
