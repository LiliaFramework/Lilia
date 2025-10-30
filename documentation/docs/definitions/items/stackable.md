# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Ammo Box"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/props_junk/cardboard_box001a.mdl"

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

### isStackable

**Example Usage**

```lua
ITEM.isStackable = true

```

---

### maxQuantity

**Example Usage**

```lua
ITEM.maxQuantity = 10  -- Maximum 10 items per stack

```

---

### canSplit

**Example Usage**

```lua
ITEM.canSplit = true  -- Allows splitting the stack

```

---

### ITEM:getDesc()

**Example Usage**

```lua
function ITEM:getDesc()
    return L("stackableDesc", self:getQuantity())
end

```

---

### ITEM:paintOver(item)

**Example Usage**

```lua
function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "LiliaFont.16")
end

```

---

### ITEM:onCombine(other)

**Example Usage**

```lua
function ITEM:onCombine(other)
    if other.uniqueID ~= self.uniqueID then return end
        local combined = self:getQuantity() + other:getQuantity()
        if combined <= self.maxQuantity then
            self:setQuantity(combined)
            other:remove()
            else
                self:setQuantity(self.maxQuantity)
                other:setQuantity(combined - self.maxQuantity)
            end
            return true
        end
    end
end

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Ammo Box"                                    -- Display name shown to players
ITEM.model = "models/props_junk/cardboard_box001a.mdl"   -- 3D model for the item
ITEM.width = 1                                            -- Inventory width (1 slot)
ITEM.height = 1                                           -- Inventory height (1 slot)
ITEM.isStackable = true                                   -- Enables stacking functionality
ITEM.maxQuantity = 10                                     -- Maximum items per stack

```

---

