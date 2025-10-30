# Outfit Item Definition

Outfit item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Police Uniform"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A standard police uniform"

```

---

### category

**Example Usage**

```lua
ITEM.category = "outfit"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/props_c17/BriefCase001a.mdl"

```

---

### width

**Example Usage**

```lua
ITEM.width = 1  -- Takes 1 slot width

```

---

### height

**Example Usage**

```lua
ITEM.height = 1  -- Takes 1 slot height

```

---

### outfitCategory

**Example Usage**

```lua
ITEM.outfitCategory = "model"  -- Prevents multiple items of same category

```

---

### pacData

**Example Usage**

```lua
ITEM.pacData = {}  -- PAC attachment data

```

---

### isOutfit

**Example Usage**

```lua
ITEM.isOutfit = true

```

---

### ITEM:paintOver(item, w, h)

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

**Example Usage**

```lua
function ITEM:removeOutfit(client)
    -- Custom removal logic
end

```

---

### ITEM:wearOutfit(client, isForLoadout)

**Example Usage**

```lua
function ITEM:wearOutfit(client, isForLoadout)
    -- Custom wear logic
end

```

---

### ITEM:OnCanBeTransfered(_, newInventory)

**Example Usage**

```lua
function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
        return true
    end

```

---

### ITEM:onLoadout()

**Example Usage**

```lua
function ITEM:onLoadout()
    if self:getData("equip") then self:wearOutfit(self.player, true) end
    end

```

---

### ITEM:onRemoved()

**Example Usage**

```lua
function ITEM:onRemoved()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removeOutfit(receiver) end
    end

```

---

### ITEM:hook("drop", function(item) ... end)

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

