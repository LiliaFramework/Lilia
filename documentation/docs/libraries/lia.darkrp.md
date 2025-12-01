# DarkRP Compatibility Library

The DarkRP compatibility library provides essential functions for maintaining compatibility

---

### lia.darkrp.isEmpty

#### 📋 Purpose
Checks if a given position is empty and suitable for spawning entities or players

#### ⏰ When Called
Called when checking spawn positions, entity placement, or any position validation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | **Vector** | The world position to check |
| `entitiesToIgnore` | **table, optional** | Table of entities to ignore during the check |

#### ↩️ Returns
* boolean - true if the position is empty, false otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if a position is empty
    local pos = Vector(100, 200, 50)
    if lia.darkrp.isEmpty(pos) then
        print("Position is empty")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check position while ignoring specific entities
    local pos = player:GetPos()
    local ignoreEntities = {player, someProp}
    if lia.darkrp.isEmpty(pos, ignoreEntities) then
        player:SetPos(pos)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Validate spawn position with multiple checks
    local spawnPos = Vector(0, 0, 0)
    local ignoreList = {}
    for _, ent in ents.Iterator() do
        if ent:GetClass() == "prop_physics" then
            table.insert(ignoreList, ent)
        end
    end
    if lia.darkrp.isEmpty(spawnPos, ignoreList) then
        local spawn = ents.Create("npc_citizen")
        spawn:SetPos(spawnPos)
        spawn:Spawn()
    end

```

---

### lia.darkrp.findEmptyPos

#### 📋 Purpose
Finds the nearest empty position to a starting position within specified parameters

#### ⏰ When Called
Called when spawning entities or players and the initial position is occupied

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `startPos` | **Vector** | The starting position to search from |
| `entitiesToIgnore` | **table, optional** | Table of entities to ignore during the search |
| `maxDistance` | **number** | Maximum distance to search from the starting position |
| `searchStep` | **number** | Step size for the search radius |
| `checkArea` | **Vector** | Additional area to check around each position |

#### ↩️ Returns
* Vector - The nearest empty position found, or the original position if none found

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find empty position near spawn point
    local spawnPos = Vector(0, 0, 0)
    local emptyPos = lia.darkrp.findEmptyPos(spawnPos, {}, 100, 10, Vector(0, 0, 0))
    player:SetPos(emptyPos)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find spawn position ignoring specific entities
    local startPos = Vector(100, 200, 50)
    local ignoreList = {player, someNPC}
    local emptyPos = lia.darkrp.findEmptyPos(startPos, ignoreList, 200, 25, Vector(32, 32, 64))
    if emptyPos ~= startPos then
        print("Found empty position at: " .. tostring(emptyPos))
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Advanced spawn system with multiple checks
    local spawnPoints = {Vector(0, 0, 0), Vector(100, 0, 0), Vector(0, 100, 0)}
    local ignoreEntities = {}
    for _, ent in ipairs(ents.FindInSphere(Vector(0, 0, 0), 500)) do
        if ent:IsPlayer() or ent:IsNPC() then
            table.insert(ignoreEntities, ent)
        end
    end
    for _, spawnPoint in ipairs(spawnPoints) do
        local emptyPos = lia.darkrp.findEmptyPos(spawnPoint, ignoreEntities, 150, 20, Vector(16, 16, 32))
        if emptyPos ~= spawnPoint then
            local newPlayer = ents.Create("npc_citizen")
            newPlayer:SetPos(emptyPos)
            newPlayer:Spawn()
            break
        end
    end

```

---

### lia.darkrp.notify

#### 📋 Purpose
Sends a localized notification to a client (DarkRP compatibility function)

#### ⏰ When Called
Called when sending notifications to players in DarkRP-compatible systems

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to send the notification to |
| `_` | **any** | Unused parameter (DarkRP compatibility) |
| `_` | **any** | Unused parameter (DarkRP compatibility) |
| `message` | **string** | The localized message key to send |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send basic notification
    lia.darkrp.notify(player, nil, nil, "welcome_message")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send notification with context
    local message = "player_joined"
    lia.darkrp.notify(player, nil, nil, message)

```

#### ⚙️ High Complexity
```lua
    -- High: Send notifications to multiple players
    local message = "server_restart_warning"
    for _, ply in player.Iterator() do
        if ply:IsValid() and ply:IsConnected() then
            lia.darkrp.notify(ply, nil, nil, message)
        end
    end

```

---

### lia.darkrp.textWrap

#### 📋 Purpose
Wraps text to fit within a specified maximum line width using font metrics

#### ⏰ When Called
Called when displaying text in UI elements that need to fit within width constraints

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The text to wrap |
| `fontName` | **string** | The font name to use for width calculations |
| `maxLineWidth` | **number** | The maximum width in pixels for each line |

#### ↩️ Returns
* string - The wrapped text with line breaks inserted

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Wrap basic text
    local wrappedText = lia.darkrp.textWrap("Hello world this is a long text", "DermaDefault", 200)
    print(wrappedText)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Wrap text with different fonts
    local text = "This is a sample text that needs to be wrapped properly"
    local font = "liaFont"
    local maxWidth = 300
    local wrapped = lia.darkrp.textWrap(text, font, maxWidth)
    -- Display in a panel
    local label = vgui.Create("DLabel")
    label:SetText(wrapped)
    label:SetFont(font)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic text wrapping with multiple paragraphs
    local paragraphs = {
    "First paragraph with lots of text that needs wrapping",
    "Second paragraph with different content",
    "Third paragraph with even more content"
    }
    local font = "liaFont"
    local maxWidth = 400
    local wrappedParagraphs = {}
    for i, paragraph in ipairs(paragraphs) do
        local wrapped = lia.darkrp.textWrap(paragraph, font, maxWidth)
        table.insert(wrappedParagraphs, wrapped)
    end
    local finalText = table.concat(wrappedParagraphs, "\n\n")
    -- Use finalText in UI

```

---

### lia.darkrp.formatMoney

#### 📋 Purpose
Formats a numeric amount as currency using the Lilia currency system

#### ⏰ When Called
Called when displaying money amounts in UI or chat messages

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number** | The numeric amount to format |

#### ↩️ Returns
* string - The formatted currency string

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Format a basic amount
    local formatted = lia.darkrp.formatMoney(1000)
    print(formatted) -- "$1,000"

```

#### 📊 Medium Complexity
```lua
    -- Medium: Format player's money for display
    local playerMoney = player:getMoney()
    local formattedMoney = lia.darkrp.formatMoney(playerMoney)
    player:notifyInfoLocalized("your_money")

```

#### ⚙️ High Complexity
```lua
    -- High: Format multiple amounts for transaction display
    local amounts = {500, 1250, 9999, 150000}
    local formattedAmounts = {}
    for _, amount in ipairs(amounts) do
        local formatted = lia.darkrp.formatMoney(amount)
        table.insert(formattedAmounts, formatted)
    end
    local displayText = "Transaction amounts: " .. table.concat(formattedAmounts, ", ")
    chat.AddText(Color(255, 255, 255), displayText)

```

---

### lia.darkrp.createEntity

#### 📋 Purpose
Creates a DarkRP-compatible entity item in the Lilia item system

#### ⏰ When Called
Called when registering DarkRP entities for compatibility with existing addons

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The display name of the entity |
| `data` | **table** | Table containing entity configuration data |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a basic entity
    lia.darkrp.createEntity("Chair", {
    model = "models/props_c17/FurnitureChair001a.mdl",
    price = 50
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create entity with full configuration
    lia.darkrp.createEntity("Advanced Computer", {
    cmd = "computer",
    model = "models/props_lab/monitor01b.mdl",
    desc = "A high-tech computer for advanced operations",
    category = "Electronics",
    ent = "prop_physics",
    price = 200
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Create multiple entities from configuration table
    local entities = {
    {
    name = "Office Desk",
    data = {
    cmd = "desk",
    model = "models/props_c17/FurnitureTable002a.mdl",
    desc = "A sturdy office desk",
    category = "Furniture",
    price = 100
    }
    },
    {
    name = "Filing Cabinet",
    data = {
    cmd = "cabinet",
    model = "models/props_c17/FurnitureDrawer001a.mdl",
    desc = "Store important documents",
    category = "Furniture",
    price = 75
    }
    }
    }
    for _, entity in ipairs(entities) do
        lia.darkrp.createEntity(entity.name, entity.data)
    end

```

---

### lia.darkrp.createCategory

#### 📋 Purpose
Creates a DarkRP-compatible category (placeholder function for compatibility)

#### ⏰ When Called
Called by DarkRP addons that expect a createCategory function to exist

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Call the function (no effect)
    lia.darkrp.createCategory()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Use in DarkRP compatibility code
    if DarkRP and DarkRP.createCategory then
        lia.darkrp.createCategory()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Use in addon initialization
    local function initializeDarkRPCompatibility()
        -- Ensure DarkRP compatibility functions exist
        lia.darkrp.createCategory()
        -- Other DarkRP compatibility setup
        if DarkRP and DarkRP.createEntity then
            print("DarkRP compatibility initialized")
        end
    end
    initializeDarkRPCompatibility()

```

---

