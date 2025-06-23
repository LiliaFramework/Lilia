
# lia.darkrp

---

The `lia.darkrp` library provides a set of utility functions designed to enhance compatibility and streamline interactions within the DarkRP game mode of the Lilia Framework. These functions handle tasks such as position validation, empty space searching, client notifications, text wrapping, and money formatting. By leveraging these utilities, developers can efficiently manage common DarkRP-related operations, ensuring smoother gameplay experiences and more robust server management.

---

## Functions

### **lia.darkrp.isEmpty**

**Description:**  
Checks if a given position is empty by evaluating the presence of obstacles, entities, and specific content types. This function ensures that the position is free from solid objects, movable items, ladders, player clips, monster clips, and other obstructive entities, while also ignoring specified entities.

**Realm:**  
`Server`

**Parameters:**  

- `position` (`Vector`):  
  The position to check for emptiness.

- `entitiesToIgnore` (`table`, optional):  
  A table of entities to ignore during the check. Defaults to an empty table if not provided.

**Returns:**  
`boolean` - Returns `true` if the position is empty; otherwise, `false`.

**Example Usage:**
```lua
local position = Vector(0, 0, 0)
local ignoredEntities = {someEntity}
local isPositionEmpty = lia.darkrp.isEmpty(position, ignoredEntities)

if isPositionEmpty then
    print("The position is empty.")
else
    print("The position is occupied.")
end
```

---

### **lia.darkrp.findEmptyPos**

**Description:**  
Finds an empty position within a specified maximum distance from a starting position. The function searches in multiple directions and steps to locate a suitable empty space, taking into account entities to ignore and the defined check area around each position.

**Realm:**  
`Server`

**Parameters:**  

- `startPos` (`Vector`):  
  The starting position from which to begin the search.

- `entitiesToIgnore` (`table`, optional):  
  A table of entities to ignore during the search. Defaults to an empty table if not provided.

- `maxDistance` (`number`):  
  The maximum distance to search for an empty position.

- `searchStep` (`number`):  
  The incremental step size for each search iteration.

- `checkArea` (`Vector`):  
  A vector defining the area around each position to check for emptiness.

**Returns:**  
`Vector` - Returns the found empty position. If none are found within the specified distance, it returns the original starting position.

**Example Usage:**
```lua
local startPosition = Vector(100, 200, 300)
local ignoredEntities = {someEntity}
local maxSearchDistance = 500
local stepSize = 50
local areaToCheck = Vector(10, 10, 10)

local emptyPosition = lia.darkrp.findEmptyPos(startPosition, ignoredEntities, maxSearchDistance, stepSize, areaToCheck)
print("Found empty position at:", emptyPosition)
```

---

### **lia.darkrp.notify**

**Description:**  
Sends a notification message to a specific client. This function utilizes the client's `notify` method to display messages, ensuring that notifications are delivered reliably.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`):  
  The client who will receive the notification.

- `_` (`any`, unused):  
  Unused argument. This parameter is retained for compatibility purposes.

- `_` (`any`, unused):  
  Unused argument. This parameter is retained for compatibility purposes.

- `message` (`string`):  
  The message to be sent to the client.

**Returns:**  
None

**Example Usage:**
```lua
local targetClient = somePlayer
local notificationMessage = "You have received a new item!"

lia.darkrp.notify(targetClient, nil, nil, notificationMessage)
```

---

### **lia.darkrp.textWrap**

**Description:**  
Wraps text to fit within a specified maximum line width by inserting line breaks where necessary. This function calculates the width of each character and word based on the chosen font, ensuring that the wrapped text maintains proper formatting and readability.

**Realm:**  
`Client`

**Parameters:**  

- `text` (`string`):  
  The text string to be wrapped.

- `fontName` (`string`):  
  The name of the font used to measure text width.

- `maxLineWidth` (`number`):  
  The maximum width in pixels allowed for each line of text.

**Returns:**  
`string` - The wrapped text with inserted line breaks.

**Example Usage:**
```lua
local originalText = "This is a sample text that needs to be wrapped properly."
local font = "Arial"
local maxWidth = 300

local wrappedText = lia.darkrp.textWrap(originalText, font, maxWidth)
print(wrappedText)
-- Output:
-- "This is a sample text
-- that needs to be wrapped
-- properly."
```

---

### **lia.darkrp.formatMoney**

**Description:**  
Formats a given amount of money according to the server's currency system. This function leverages the currency formatting utilities to present monetary values in a standardized and readable format.

**Realm:**  
`Shared`

**Parameters:**  

- `amount` (`number`):  
  The amount of money to format.

**Returns:**  
`string` - The formatted money string.

**Example Usage:**
```lua
local moneyAmount = 1500.75
local formattedMoney = lia.darkrp.formatMoney(moneyAmount)
print(formattedMoney)
-- Output: "$1,500.75" (Assuming the currency symbol is "$")
```

---

## Integration with DarkRP

The `lia.darkrp` library integrates seamlessly with the DarkRP framework by mapping its utility functions to DarkRP's native functions. This ensures that existing DarkRP functionalities remain compatible while enhancing them with additional features provided by the `lia.darkrp` library.

```lua
DarkRP.formatMoney = lia.darkrp.formatMoney
DarkRP.isEmpty = lia.darkrp.isEmpty
DarkRP.findEmptyPos = lia.darkrp.findEmptyPos
DarkRP.notify = lia.darkrp.notify
DarkRP.textWrap = lia.darkrp.textWrap
```

This integration allows developers to utilize `lia.darkrp` functions interchangeably with DarkRP's built-in functions, providing greater flexibility and extended capabilities within their game modes.

---
