# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

### if not pac then return end

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

### ITEM:paintOver(item, w, h)

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

### ITEM:removePart(client)

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

### ITEM:onCanBeTransfered(_, newInventory)

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

### ITEM:onLoadout()

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

### ITEM:onRemoved()

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

### ITEM:hook("drop", function(item) ... end)

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

