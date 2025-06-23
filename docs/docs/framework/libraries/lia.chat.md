# lia.chat

---

Chat manipulation and helper functions.

Chat messages are a core part of the framework—it takes up a significant portion of the gameplay and is also used to interact with the framework. Chat messages can have types or "classes" that describe how the message should be interpreted. All chat messages will have some type of class: `ic` for regular in-character speech, `me` for actions, `ooc` for out-of-character, etc. These chat classes can affect how the message is displayed in each player's chatbox. See `lia.chat.register` to create your own chat classes.

**NOTE:** For the most part, you shouldn't use this library unless you know what you're doing. You can very easily corrupt character data using these functions!

---

### **lia.chat.timestamp**

**Description:**  
Generates a timestamp string for chat messages.

**Realm:**  
`Shared`

**Parameters:**  

- `ooc` (`boolean`): Whether the message is Out of Character (OOC).

**Returns:**  
`string` - The formatted timestamp string, including date and time if configured to show.

**Example Usage:**
```lua
local timestamp = lia.chat.timestamp(true)
print(timestamp) -- Outputs: (12:34) 
```

---

### **lia.chat.register**

**Description:**  
Registers a new chat type with the information provided. Chat classes should usually be created inside of the `InitializedChatClasses` hook.

**Realm:**  
`Shared`

**Parameters:**  

- `chatType` (`string`): Name of the chat type.
- `data` (`table`): Properties and functions to assign to this chat class.

**Example Usage:**
```lua
lia.chat.register("me", {
    format = "**%s %s",
    onGetColor = lia.chat.classes.ic.onGetColor,
    onCanHear = lia.config.get("ChatRange", 280),
    prefix = {"/me", "/action"},
    deadCanChat = true
})
```

**See:** [ChatClassStructure](#chatclassstructure)

---

### **lia.chat.parse**

**Description:**  
Identifies which chat mode should be used.

**Realm:**  
`Shared`

**Parameters:**  

- `client` (`Player`): Player who is speaking.
- `message` (`string`): Message to parse.
- `noSend` (`boolean`, optional, default `false`): Whether or not to send the chat message after parsing.

**Returns:**  
- `string`: Name of the chat type.
- `string`: Message that was parsed.
- `boolean`: Whether or not the speaker should be anonymous.

**Example Usage:**
```lua
local chatType, parsedMessage, isAnonymous = lia.chat.parse(playerInstance, "/me waves")
if chatType then
    print("Chat Type:", chatType)
    print("Message:", parsedMessage)
end
```

---

### **lia.chat.send**

**Description:**  
Sends a chat message from a speaker to specified receivers, based on the provided chat type and text. The message is processed according to the properties and functions defined for the chat class.

**Realm:**  
`Server`

**Parameters:**  

- `speaker` (`Entity`): Entity sending the message.
- `chatType` (`string`): Type of the chat message.
- `text` (`string`): The message content.
- `anonymous` (`boolean`, optional, default `false`): Whether the message should be sent anonymously.
- `receivers` (`table`, optional): List of entities to receive the message (if specified).

**Example Usage:**
```lua
lia.chat.send(playerInstance, "ic", "Hello, world!", false)
```

---

## Variables

### **lia.chat.classes**

**Description:**  
List of all chat classes that have been registered by the framework, where each key is the name of the chat class, and the value is the chat class data. Accessing a chat class's data is useful for when you want to copy some functionality or properties to use in your own. Note that if you're accessing this table, you should do so inside of the `InitializedChatClasses` hook.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
print(lia.chat.classes.ic.format)
-- Output: "%s says \"%s\""
```

---

## Structures

### **ChatClassStructure**

**Description:**  
Chat messages can have different classes or "types" of messages that have different properties. This can include how the text is formatted, color, hearing distance, etc.

**Realm:**  
`Shared`

**Fields:**

- **`prefix`** (`string` or `table` of `string`):  
  What the player must type before their message in order to use this chat class. For example, having a prefix of `/y` will require typing `/y I am yelling` to send a message with this chat class. This can also be a table of strings if you want to allow multiple prefixes, such as `{"//", "/ooc"}`.
  
  **NOTE:** The prefix should usually start with a `/` to be consistent with the rest of the framework. However, you can use something different like the `LOOC` chat class where the prefixes are `.//`, `[[`, and `/looc`.

- **`noSpaceAfter`** (`boolean`, optional, default `false`):  
  Whether or not the `prefix` can be used without a space after it. For example, the `OOC` chat class allows you to type `//my message` instead of `// my message`. **NOTE:** This only works if the last character in the prefix is non-alphanumeric (i.e., `noSpaceAfter` with `/y` will not work, but `/!` will).

- **`format`** (`string`, optional, default `"%s: \"%s\""`):  
  How to format a message with this chat class. The first `%s` will be the speaking player's name, and the second one will be their message.

- **`color`** (`Color`, optional, default `Color(242, 230, 160)`):  
  Color to use when displaying a message with this chat class.

- **`font`** (`string`, optional, default `liaChatFont`):  
  Font to use for displaying a message with this chat class.

- **`deadCanChat`** (`boolean`, optional, default `false`):  
  Whether or not a dead player can send a message with this chat class.

- **`onCanHear`** (`number` or `function`, optional):  
  This can be either a `number` representing how far away another player can hear this message, or a `function` which returns `true` if the given listener can hear the message emitted from a speaker.
  
  **Examples:**
  ```lua
  onCanHear = 1000 -- Message can be heard by any player 1000 units away from the speaking player
  
  onCanHear = function(speaker, text)
      return true -- The speaking player will be heard by everyone
  end
  ```

- **`onCanSay`** (`function`, optional):  
  Function to run to check whether or not a player can send a message with this chat class. By default, it will return `false` if the player is dead and `deadCanChat` is `false`. Overriding this function will prevent `deadCanChat` from working, and you must implement this functionality manually.
  
  **Example Usage:**
  ```lua
  onCanSay = function(speaker, text)
      return false -- The speaker will never be able to send a message with this chat class
  end
  ```

- **`onGetColor`** (`function`, optional):  
  Function to run to set the color of a message with this chat class. Generally, stick to using `color`, but this is useful for when you want the color of the message to change based on some criteria.
  
  **Example Usage:**
  ```lua
  onGetColor = function(speaker, text)
      return Color(math.random(120, 200), 0, 0) -- Each message will be colored a random shade of red
  end
  ```

- **`onChatAdd`** (`function`, optional):  
  Function to run when a message with this chat class should be added to the chatbox. If using this function, make sure to end the function by calling `chat.AddText` for the text to show up.
  
  **NOTE:** Using your own `onChatAdd` function will prevent `color`, `onGetColor`, or `format` from being used since you'll be overriding the base function that uses those properties. In such cases, you'll need to add that functionality back in manually. In general, avoid overriding this function where possible. The `data` argument in the function is whatever is passed into the same `data` argument in `lia.chat.send`.
  
  **Example Usage:**
  ```lua
  onChatAdd = function(speaker, text, bAnonymous, data)
      chat.AddText(color_white, speaker:GetName(), ": ", text) -- Adds white text in the form of "Player Name: Message contents"
  end
  ```

**See:** [lia.chat.register](#liachatregister)

---