# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

### if not pac then return end

**Example Usage**

```lua
if not pac then return end

```

---

### name

**Example Usage**

```lua
ITEM.name = "Hat"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A stylish hat"

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
ITEM.model = "models/Gibs/HGIBS.mdl"

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
ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category

```

---

### pacData

**Example Usage**

```lua
ITEM.pacData = {}  -- PAC attachment data

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

### ITEM:removePart(client)

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

**Example Usage**

```lua
function ITEM:onCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
        return true
    end

```

---

### ITEM:onLoadout()

**Example Usage**

```lua
function ITEM:onLoadout()
    if self:getData("equip") and self.player.addPart then self.player:addPart(self.uniqueID) end
    end

```

---

### ITEM:onRemoved()

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

**Example Usage**

```lua
ITEM:hook("drop", function(item)
local client = item.player
if item:getData("equip") then item:removePart(client) end
end)

```

---

### Example Item:

**Example Usage**

```lua
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

