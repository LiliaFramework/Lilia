# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

### name

**Purpose**

Prevents loading if PAC addon is not available

**When Called**

During item definition

**Example Usage**

```lua
if not pac then return end

```

---

### name

**Purpose**

Sets the display name of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Hat"

```

---

### desc

**Purpose**

Sets the description of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A stylish hat"

```

---

### category

**Purpose**

Sets the category for the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "outfit"

```

---

### model

**Purpose**

Sets the 3D model for the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/Gibs/HGIBS.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the PAC outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### outfitCategory

**Purpose**

Sets the outfit category for conflict checking

**When Called**

During item definition

**Example Usage**

```lua
ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category

```

---

### pacData

**Purpose**

Sets the PAC data for the outfit

**When Called**

During item definition

**Example Usage**

```lua
ITEM.pacData = {}  -- PAC attachment data

```

---

### removePart

**Purpose**

Custom paint function to show equipped status

**When Called**

When rendering the item in inventory (CLIENT only)

**Example Usage**

```lua
function ITEM:paintOver(item, w, h)
    if item:getData("equip") then
        surface.SetDrawColor(110, 255, 110, 100)
        surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end

```

---

### onCanBeTransfered

**Purpose**

Removes the PAC part from the player

**When Called**

When unequipping the PAC outfit

**Example Usage**

```lua
function ITEM:removePart(client)
    local char = client:getChar()
    self:setData("equip", false)
    if client.removePart then client:removePart(self.uniqueID) end
        -- Remove attribute boosts
        end

```

---

### onLoadout

**Purpose**

Prevents transfer of equipped PAC outfits

**When Called**

When attempting to transfer the item

**Example Usage**

```lua
function ITEM:onCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
        return true
        end

```

---

### onRemoved

**Purpose**

Handles PAC outfit loading on player spawn

**When Called**

When player spawns with equipped PAC outfit

**Example Usage**

```lua
function ITEM:onLoadout()
    if self:getData("equip") and self.player.addPart then self.player:addPart(self.uniqueID) end
        end

```

---

### name

**Purpose**

Handles PAC outfit removal when item is removed

**When Called**

When item is removed from inventory

**Example Usage**

```lua
function ITEM:onRemoved()
    local inv = lia.item.inventories[self.invID]
    local receiver = inv.getReceiver and inv:getReceiver()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removePart(receiver) end
        end

```

---

### name

**Purpose**

Handles PAC outfit removal when item is dropped

**When Called**

When item is dropped

**Example Usage**

```lua
ITEM:hook("drop", function(item)
local client = item.player
if item:getData("equip") then item:removePart(client) end
    end)

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
if not pac then return end

ITEM.name = "Hat"

ITEM.desc = "A stylish hat"

ITEM.category = "outfit"

ITEM.model = "models/Gibs/HGIBS.mdl"

ITEM.width = 1  -- Takes 1 slot width

ITEM.height = 1  -- Takes 1 slot height

ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category

ITEM.pacData = {}  -- PAC attachment data

```

```lua
function ITEM:paintOver(item, w, h)
    if item:getData("equip") then
        surface.SetDrawColor(110, 255, 110, 100)
        surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end

```

```lua
function ITEM:removePart(client)
    local char = client:getChar()
    self:setData("equip", false)
    if client.removePart then client:removePart(self.uniqueID) end
        -- Remove attribute boosts
        end

```

```lua
function ITEM:onCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
        return true
        end

```

```lua
function ITEM:onLoadout()
    if self:getData("equip") and self.player.addPart then self.player:addPart(self.uniqueID) end
        end

```

```lua
function ITEM:onRemoved()
    local inv = lia.item.inventories[self.invID]
    local receiver = inv.getReceiver and inv:getReceiver()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removePart(receiver) end
        end

```

```lua
        ITEM:hook("drop", function(item)
        local client = item.player
        if item:getData("equip") then item:removePart(client) end
            end)

-- Basic item identification
ITEM.name = "Hat"                               -- Display name shown to players
ITEM.desc = "A stylish hat"                     -- Description text
ITEM.category = "outfit"                        -- Category for inventory sorting
ITEM.model = "models/Gibs/HGIBS.mdl"            -- 3D model for the item
ITEM.width = 1                                  -- Inventory width (1 slot)
ITEM.height = 1                                 -- Inventory height (1 slot)
ITEM.outfitCategory = "hat"                     -- Outfit category for conflict checking

```

---

