# Attribute Definitions

Character attribute definition system for the Lilia framework.

---

Overview

The attribute system provides functionality for defining character attributes within the Lilia framework. Attributes represent character statistics that can be modified, boosted, and used in gameplay calculations. The system includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior. Attributes can be configured with maximum values, starting limits, and whether they appear in character creation. The system supports attribute boosts through the character system and validation through callback methods that are automatically invoked during character setup.

---

<a id="name"></a>
### name

#### 📋 Purpose
Sets the display name of the attribute

#### ⏰ When Called
During attribute definition

#### 💡 Example Usage

```lua
    ATTRIBUTE.name = "Strength"

```

---

<a id="desc"></a>
### desc

#### 📋 Purpose
Sets the description of the attribute that appears in tooltips and UI

#### ⏰ When Called
During attribute definition

#### 💡 Example Usage

```lua
    ATTRIBUTE.desc = "Physical power and muscle strength. Affects melee damage and carrying capacity."

```

---

<a id="maxvalue"></a>
### maxValue

#### 📋 Purpose
Sets the maximum value this attribute can reach

#### ⏰ When Called
During attribute definition (used by GetAttributeMax hook)

#### 💡 Example Usage

```lua
    ATTRIBUTE.maxValue = 50

```

---

<a id="startingmax"></a>
### startingMax

#### 📋 Purpose
Sets the maximum value this attribute can have during character creation

#### ⏰ When Called
During attribute definition (used by GetAttributeStartingMax hook)

#### 💡 Example Usage

```lua
    ATTRIBUTE.startingMax = 20

```

---

<a id="nostartbonus"></a>
### noStartBonus

#### 📋 Purpose
Prevents this attribute from appearing in character creation attribute allocation

#### ⏰ When Called
During attribute definition (checked in character creation UI)

#### 💡 Example Usage

```lua
    ATTRIBUTE.noStartBonus = true

```

---

<a id="onsetup"></a>
### OnSetup

#### 📋 Purpose
Hook function called when setting up attributes for a character

#### ⏰ When Called
When a character spawns or when their attributes are initialized

#### 🌐 Realm
Server

<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The client whose character is being set up</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">value</span> The current attribute value</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None</a></span></p>

#### 💡 Example Usage

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

