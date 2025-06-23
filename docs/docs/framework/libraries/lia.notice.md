# lia.notices

---

**Logging and Notification System**

The `lia.notices` library provides a comprehensive system for managing notifications within the Lilia Framework. It allows developers to create, organize, and display various types of notices to players, enhancing user experience through timely and categorized information delivery.

---

## Functions

### **lia.notices.notifyAll**

**Description:**  
Sends a notification message to all connected players. This function is useful for broadcasting important messages or announcements that should be visible to every player in the game.

**Realm:**  
`Server`

**Parameters:**  

- `msg` (`string`):  
  The message to send to all players.

**Example Usage:**
```lua
-- Broadcast a server-wide announcement
lia.notices.notifyAll("The server will undergo maintenance in 10 minutes.")
```

---

### **lia.notices.notify**

**Description:**  
Displays a notification message to a specific player or broadcasts it to all players. On the server side, it sends the message via the network to the intended recipients. On the client side, it creates a visual notice panel on the player's screen.

**Realm:**  
- `Server`
- `Client`

**Parameters:**  

- `message` (`string`):  
  The message to be notified.

- `recipient` (`Player`, optional server side):  
  The specific player to receive the notification. If omitted, the message is sent to all players.

**Example Usage:**
```lua
-- Notify a specific player
lia.notices.notify("You have received a new item!", targetPlayer)

-- Broadcast a message to all players
lia.notices.notify("A new event has started!", nil)
```

**Example Usage:**
```lua
-- Display a notification on the client's screen
lia.notices.notify("Welcome to the server!", true)
```

---

### **lia.notices.notifyLocalized**

**Description:**  
Displays a localized notification message to a specific player or broadcasts it to all players. This function leverages the localization system to ensure messages are presented in the player's selected language.

**Realm:**  
- `Server`
- `Client`

**Parameters:**  

- `message` (`string`):  
  The localized message identifier to be notified.

- `recipient` (`Player`, optional server side):  
  The specific player to receive the notification. If omitted, the message is sent to all players.

- `...` (`any`, optional):  
  Additional parameters for string formatting within the localized message.

**Example Usage:**
```lua
-- Notify a player with a formatted localized message
lia.notices.notifyLocalized("welcomeMessage", targetPlayer, "Alice")

-- Broadcast a localized victory message to all players
lia.notices.notifyLocalized("victory", nil, "Bob")
```

**Example Usage:**
```lua
-- Display a localized notification on the client's screen
lia.notices.notifyLocalized("achievementUnlocked", true, "First Blood")
```

---