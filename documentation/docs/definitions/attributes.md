# Attribute Definitions

Character attribute definition system for the Lilia framework.

---

Overview

The attribute system provides functionality for defining character attributes within the Lilia framework. Attributes represent character statistics that can be modified, boosted, and used in gameplay calculations. The system includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior. Attributes can be configured with maximum values, starting limits, and whether they appear in character creation. The system supports attribute boosts through the character system and validation through callback methods that are automatically invoked during character setup.

---

### name

**Purpose**

Sets the display name of the attribute

**When Called**

During attribute definition

**Example Usage**

```lua
ATTRIBUTE.name = "Strength"

```

---

### desc

**Purpose**

Sets the description of the attribute that appears in tooltips and UI

**When Called**

During attribute definition

**Example Usage**

```lua
ATTRIBUTE.desc = "Physical power and muscle strength. Affects melee damage and carrying capacity."

```

---

### maxValue

**Purpose**

Sets the maximum value this attribute can reach

**When Called**

During attribute definition (used by GetAttributeMax hook)

**Example Usage**

```lua
ATTRIBUTE.maxValue = 50

```

---

### startingMax

**Purpose**

Sets the maximum value this attribute can have during character creation

**When Called**

During attribute definition (used by GetAttributeStartingMax hook)

**Example Usage**

```lua
ATTRIBUTE.startingMax = 20

```

---

### noStartBonus

**Purpose**

Prevents this attribute from appearing in character creation attribute allocation

**When Called**

During attribute definition (checked in character creation UI)

**Example Usage**

```lua
ATTRIBUTE.noStartBonus = true

```

---

### OnSetup

**Purpose**

Hook function called when setting up attributes for a character

**When Called**

When a character spawns or when their attributes are initialized

**Realm**

Server

**Parameters**

* `client` (*Player*): The client whose character is being set up
* `value` (*number*): The current attribute value

**Returns**

* None

**Example Usage**

```lua
function ATTRIBUTE:OnSetup(client, value)
    local char = client:getChar()
    if not char then return end
        -- Set default attribute value if not already set
        if value == 0 then
            char:setAttrib(self.uniqueID, 10)
            end
        end

```

---

