--- Hook Documentation for ChatBox Module.
-- @hooks ChatBox
--- Called when the text in the chat input box changes.
-- This hook allows for additional actions or modifications to be made whenever the chat input text changes.
-- @realm client
-- @string text The current text in the chat input box.
function ChatTextChanged(text)
end

--- Called when the chat input box is closed.
-- This hook allows for any cleanup or additional actions to be performed when the chat input box is closed.
-- @realm client
function FinishChat()
end

--- Called to add text to the chat.
-- This hook allows for customization of the text being added to the chat. It can be used to modify or format the text before it is displayed.
-- @realm client
-- @string text The initial text markup string.
-- @argGroup ... Additional arguments containing the text elements to be added to the chat.
-- @treturn string The modified text markup string to be displayed in the chat.
function ChatAddText(text, ...)
end

--- Called when the chat input box is opened.
-- This hook allows for any setup or additional actions to be performed when the chat input box is opened.
-- @realm client
function StartChat()
end

--- Called after a player sends a chat message.
-- @realm server
-- @client client The player entity who sent the message.
-- @string message The message sent by the player.
-- @string chatType The type of chat message (e.g., "ic" for in-character, "ooc" for out-of-character).
-- @bool anonymous Whether the message was sent anonymously (true) or not (false).
function PostPlayerSay(client, message, chatType, anonymous)
end

--- Called after a player sends a chat message.
-- @realm server
-- @client client The player entity who sent the message.
-- @string message The message sent by the player.
-- @string chatType The type of chat message (e.g., "ic" for in-character, "ooc" for out-of-character).
-- @bool anonymous Whether the message was sent anonymously (true) or not (false).
function OnChatReceived(client, message, chatType, anonymous)
end
