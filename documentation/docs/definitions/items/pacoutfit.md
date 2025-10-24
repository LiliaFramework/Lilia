# PAC Outfit Item Definition

PAC outfit item system for the Lilia framework.

---

### if not pac then return end

**Purpose**

Prevents loading if PAC addon is not available

**When Called**

During item definition

---

### name

**Purpose**

Sets the display name of the PAC outfit item

**When Called**

During item definition

---

### desc

**Purpose**

Sets the description of the PAC outfit item

**When Called**

During item definition

---

### category

**Purpose**

Sets the category for the PAC outfit item

**When Called**

During item definition

---

### model

**Purpose**

Sets the 3D model for the PAC outfit item

**When Called**

During item definition

---

### width

**Purpose**

Sets the inventory width of the PAC outfit item

**When Called**

During item definition

---

### height

**Purpose**

Sets the inventory height of the PAC outfit item

**When Called**

During item definition

---

### outfitCategory

**Purpose**

Sets the outfit category for conflict checking

**When Called**

During item definition

---

### pacData

**Purpose**

Sets the PAC data for the outfit

**When Called**

During item definition

---

### ITEM:paintOver(item, w, h)

**Purpose**

Custom paint function to show equipped status

**When Called**

When rendering the item in inventory (CLIENT only)

---

### ITEM:removePart(client)

**Purpose**

Removes the PAC part from the player

**When Called**

When unequipping the PAC outfit

---

### ITEM:onCanBeTransfered(_, newInventory)

**Purpose**

Prevents transfer of equipped PAC outfits

**When Called**

When attempting to transfer the item

---

### ITEM:onLoadout()

**Purpose**

Handles PAC outfit loading on player spawn

**When Called**

When player spawns with equipped PAC outfit

---

### ITEM:onRemoved()

**Purpose**

Handles PAC outfit removal when item is removed

**When Called**

When item is removed from inventory

---

### ITEM:hook("drop", function(item) ... end)

**Purpose**

Handles PAC outfit removal when item is dropped

**When Called**

When item is dropped

---

