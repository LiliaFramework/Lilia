# Outfit Item Definition

Outfit item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Police Uniform"

```

---

### desc

**Purpose**

Sets the description of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A standard police uniform"

```

---

### category

**Purpose**

Sets the category for the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "outfit"

```

---

### model

**Purpose**

Sets the 3D model for the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/props_c17/BriefCase001a.mdl"

```

---

### width

**Purpose**

Sets the inventory width of the outfit item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Purpose**

Sets the inventory height of the outfit item

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
ITEM.outfitCategory = "model"  -- Prevents multiple items of same category

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

### isOutfit

**Purpose**

Marks the item as an outfit

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isOutfit = true

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

### ITEM:removeOutfit(client)

**Purpose**

Removes the outfit from the player

**When Called**

When unequipping the outfit

**Example Usage**

```lua
function ITEM:removeOutfit(client)
    -- Custom removal logic
end

```

---

### ITEM:wearOutfit(client, isForLoadout)

**Purpose**

Applies the outfit to the player

**When Called**

When equipping the outfit

**Example Usage**

```lua
function ITEM:wearOutfit(client, isForLoadout)
    -- Custom wear logic
end

```

---

### ITEM:OnCanBeTransfered(_, newInventory)

**Purpose**

Prevents transfer of equipped outfits

**When Called**

When attempting to transfer the item

**Example Usage**

```lua
function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

```

---

### ITEM:onLoadout()

**Purpose**

Handles outfit loading on player spawn

**When Called**

When player spawns with equipped outfit

**Example Usage**

```lua
function ITEM:onLoadout()
    if self:getData("equip") then self:wearOutfit(self.player, true) end
end

```

---

### ITEM:onRemoved()

**Purpose**

Handles outfit removal when item is removed

**When Called**

When item is removed from inventory

**Example Usage**

```lua
function ITEM:onRemoved()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removeOutfit(receiver) end
end

```

---

### ITEM:hook("drop", function(item) ... end)

**Purpose**

Handles outfit removal when item is dropped

**When Called**

When item is dropped

**Example Usage**

```lua
ITEM:hook("drop", function(item) if item:getData("equip") then item:removeOutfit(item.player) end end)

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Police Uniform"                        -- Display name shown to players
ITEM.desc = "A standard police uniform"             -- Description text
ITEM.category = "outfit"                            -- Category for inventory sorting
ITEM.model = "models/props_c17/BriefCase001a.mdl"   -- 3D model for the item
ITEM.width = 1                                      -- Inventory width (1 slot)
ITEM.height = 1                                     -- Inventory height (1 slot)
ITEM.outfitCategory = "model"                       -- Outfit category for conflict checking

```

---

