--[[--
Chat manipulation and helper functions.

Chat messages are a core part of the framework - it's takes up a good chunk of the gameplay, and is also used to interact with
the framework. Chat messages can have types or "classes" that describe how the message should be interpreted. All chat messages
will have some type of class: `ic` for regular in-character speech, `me` for actions, `ooc` for out-of-character, etc. These
chat classes can affect how the message is displayed in each player's chatbox. See `lia.chat.register`.
to create your own chat classes.
]]
-- @module lia.chat
lia.chat = lia.chat or {}
--- List of all chat classes that have been registered by the framework, where each key is the name of the chat class, and value
-- is the chat class data. Accessing a chat class's data is useful for when you want to copy some functionality or properties
-- to use in your own. Note that if you're accessing this table, you should do so inside of the `InitializedChatClasses` hook.
-- @realm shared
-- @table lia.chat.classes
-- @usage print(lia.chat.classes.ic.format)
-- > "%s says \"%s\""
lia.chat.classes = lia.char.classes or {}
local DUMMY_COMMAND = {
    syntax = "<string text>",
    privilege = "Dummy Command",
    onRun = function() end
}

--- Generates a timestamp string for chat messages.
-- @bool ooc Whether the message is Out of Character (OOC).
-- @return string The formatted timestamp string, including date and time if configured to show.
-- @realm shared
function lia.chat.timestamp(ooc)
    return lia.config.ChatShowTime and (ooc and " " or "") .. "(" .. lia.date.GetFormattedDate(nil, false, false, false, false, true) .. ")" .. (ooc and "" or " ") or ""
end

-- note we can't use commas in the "color" field's default value since the metadata is separated by commas which will break the
-- formatting for that field
--- Chat messages can have different classes or "types" of messages that have different properties. This can include how the
-- text is formatted, color, hearing distance, etc.
-- @realm shared
-- @table ChatClassStructure
-- @see lia.chat.register
-- @field[type=string] prefix What the player must type before their message in order to use this chat class. For example,
-- having a prefix of `/y` will require to type `/y I am yelling` in order to send a message with this chat class. This can also
-- be a table of strings if you want to allow multiple prefixes, such as `{"//", "/ooc"}`.
--
-- **NOTE:** the prefix should usually start with a `/` to be consistent with the rest of the framework. However, you are able
-- to use something different like the `LOOC` chat class where the prefixes are `.//`, `[[`, and `/looc`.
-- @field[type=bool,opt=false] noSpaceAfter Whether or not the `prefix` can be used without a space after it. For example, the
-- `OOC` chat class allows you to type `//my message` instead of `// my message`. **NOTE:** this only works if the last
-- character in the prefix is non-alphanumeric (i.e `noSpaceAfter` with `/y` will not work, but `/!` will).
-- @field[type=string,opt="%s: \"%s\""] format How to format a message with this chat class. The first `%s` will be the speaking
-- player's name, and the second one will be their message
-- @field[type=color,opt=Color(242 230 160)] color Color to use when displaying a message with this chat class
-- @field[type=string,opt=liaChatFont] font Font to use for displaying a message with this chat class
-- @field[type=bool,opt=false] deadCanChat Whether or not a dead player can send a message with this chat class
-- @field[type=number] onCanHear This can be either a `number` representing how far away another player can hear this message.
-- IC messages will use the `ChatboxCore.ChatRange`, for example. This can also be a function, which returns `true` if the given
-- listener can hear the message emitted from a speaker.
-- 	-- message can be heard by any player 1000 units away from the speaking player
-- 	onCanHear = 1000
-- OR
-- 	onCanHear = function(self, speaker, listener)
-- 		-- the speaking player will be heard by everyone
-- 		return true
-- 	end
-- @field[type=function,opt] onCanSay Function to run to check whether or not a player can send a message with this chat class.
-- By default, it will return `false` if the player is dead and `deadCanChat` is `false`. Overriding this function will prevent
-- `deadCanChat` from working, and you must implement this functionality manually.
-- 	onCanSay = function(self, speaker, text)
-- 		-- the speaker will never be able to send a message with this chat class
-- 		return false
-- 	end
-- @field[type=function,opt] onGetColor Function to run to set the color of a message with this chat class. You should generally
-- stick to using `color`, but this is useful for when you want the color of the message to change with some criteria.
-- 	onGetColor = function(self, speaker, text)
-- 		-- each message with this chat class will be colored a random shade of red
-- 		return Color(math.random(120, 200), 0, 0)
-- 	end
-- @field[type=function,opt] onChatAdd Function to run when a message with this chat class should be added to the chatbox. If
-- using this function, make sure you end the function by calling `chat.AddText` in order for the text to show up.
--
-- **NOTE:** using your own `onChatAdd` function will prevent `color`, `onGetColor`, or `format` from being used since you'll be
-- overriding the base function that uses those properties. In such cases you'll need to add that functionality back in
-- manually. In general, you should avoid overriding this function where possible. The `data` argument in the function is
-- whatever is passed into the same `data` argument in `lia.chat.send`.
--
-- 	onChatAdd = function(self, speaker, text, bAnonymous, data)
-- 		-- adds white text in the form of "Player Name: Message contents"
-- 		chat.AddText(color_white, speaker:GetName(), ": ", text)
-- 	end
--- Registers a new chat type with the information provided. Chat classes should usually be created inside of the
-- `InitializedChatClasses` hook.
-- @realm shared
-- @string chatType Name of the chat type
-- @tparam ChatClassStructure data Properties and functions to assign to this chat class
-- @usage -- this is the "me" chat class taken straight from the framework as an example
-- lia.chat.register("me", {
--     format = "**%s %s",
--     onGetColor = lia.chat.classes.ic.onGetColor,
--     onCanHear = ChatboxCore.ChatRange,
--     prefix = {"/me", "/action"},
--     deadCanChat = true
-- })
-- @see ChatClassStructure
function lia.chat.register(chatType, data)
    if not data.onCanHear then
        if isfunction(data.radius) then
            data.onCanHear = function(speaker, listener) return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.radius() ^ 2) end
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

    if not data.onCanSay then
        data.onCanSay = function(speaker)
            if not data.deadCanChat and not speaker:Alive() then
                speaker:notifyLocalized("noPerm")
                return false
            end
            return true
        end
    end

    data.color = data.color or Color(242, 230, 160)
    if not data.onChatAdd then
        data.format = data.format or "%s: \"%s\""
        data.onChatAdd = function(speaker, text, anonymous)
            local color = data.color
            local name = anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or (IsValid(speaker) and speaker:Name() or "Console")
            if data.onGetColor then color = data.onGetColor(speaker, text) end
            local timestamp = lia.chat.timestamp(false)
            local translated = L2(chatType .. "Format", name, text)
            chat.AddText(timestamp, color, translated or string.format(data.format, name, text))
        end
    end

    if CLIENT and data.prefix then
        if istable(data.prefix) then
            for _, v in ipairs(data.prefix) do
                if v:sub(1, 1) == "/" then lia.command.add(v:sub(2), DUMMY_COMMAND) end
            end
        else
            lia.command.add(chatType, DUMMY_COMMAND)
        end
    end

    data.filter = data.filter or "ic"
    lia.chat.classes[chatType] = data
end

--- Identifies which chat mode should be used.
-- @realm shared
-- @client client Player who is speaking
-- @string message Message to parse
-- @internal
-- @bool[opt=false] noSend Whether or not to send the chat message after parsing
-- @treturn string Name of the chat type
-- @treturn string Message that was parsed
-- @treturn bool Whether or not the speaker should be anonymous
function lia.chat.parse(client, message, noSend)
    local anonymous = false
    local chatType = "ic"
    for k, v in pairs(lia.chat.classes) do
        local isChosen = false
        local chosenPrefix = ""
        local noSpaceAfter = v.noSpaceAfter
        if istable(v.prefix) then
            for _, prefix in ipairs(v.prefix) do
                if message:sub(1, #prefix + (noSpaceAfter and 0 or 1)):lower() == prefix .. (noSpaceAfter and "" or " "):lower() then
                    isChosen = true
                    chosenPrefix = prefix .. (v.noSpaceAfter and "" or " ")
                    break
                end
            end
        elseif isstring(v.prefix) then
            isChosen = message:sub(1, #v.prefix + (noSpaceAfter and 1 or 0)):lower() == v.prefix .. (noSpaceAfter and "" or " "):lower()
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
    if SERVER and not noSend then lia.chat.send(client, chatType, hook.Run("PlayerMessageSend", client, chatType, message, anonymous) or message, anonymous) end
    return chatType, message, anonymous
end

if SERVER then
    --- Sends a chat message from a speaker to specified receivers, based on the provided chat type and text.
    -- The message is processed according to the properties and functions defined for the chat class.
    -- @realm server
    -- @entity Entity sending the message
    -- @string chatType Type of the chat message
    -- @string text The message content
    -- @bool[opt=false] anonymous Whether the message should be sent anonymously
    -- @tparam[opt] table receivers List of entities to receive the message (if specified)
    function lia.chat.send(speaker, chatType, text, anonymous, receivers)
        local class = lia.chat.classes[chatType]
        if class and class.onCanSay(speaker, text) ~= false then
            if class.onCanHear and not receivers then
                receivers = {}
                for _, v in ipairs(player.GetAll()) do
                    if v:getChar() and class.onCanHear(speaker, v) ~= false then receivers[#receivers + 1] = v end
                end

                if #receivers == 0 then return end
            end

            netstream.Start(receivers, "cMsg", speaker, chatType, hook.Run("PlayerMessageSend", speaker, chatType, text, anonymous, receivers) or text, anonymous)
        end
    end
end
