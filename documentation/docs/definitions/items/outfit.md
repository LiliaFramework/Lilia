# Outfit Item Definition

Outfit item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the outfit item

**When Called**

During item definition

---

### desc

**Purpose**

Sets the description of the outfit item

**When Called**

During item definition

---

### category

**Purpose**

Sets the category for the outfit item

**When Called**

During item definition

---

### model

**Purpose**

Sets the 3D model for the outfit item

**When Called**

During item definition

---

### width

**Purpose**

Sets the inventory width of the outfit item

**When Called**

During item definition

---

### height

**Purpose**

Sets the inventory height of the outfit item

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

### isOutfit

**Purpose**

Marks the item as an outfit

**When Called**

During item definition

---

### ITEM:paintOver(item, w, h)

**Purpose**

Custom paint function to show equipped status

**When Called**

When rendering the item in inventory (CLIENT only)

---

### ITEM:removeOutfit(client)

**Purpose**

Removes the outfit from the player

**When Called**

When unequipping the outfit

---

### ITEM:wearOutfit(client, isForLoadout)

**Purpose**

Applies the outfit to the player

**When Called**

When equipping the outfit

---

### ITEM:OnCanBeTransfered(_, newInventory)

**Purpose**

Prevents transfer of equipped outfits

**When Called**

When attempting to transfer the item

---

### ITEM:onLoadout()

**Purpose**

Handles outfit loading on player spawn

**When Called**

When player spawns with equipped outfit

---

### ITEM:onRemoved()

**Purpose**

Handles outfit removal when item is removed

**When Called**

When item is removed from inventory

---

### ITEM:hook("drop", function(item) ... end)

**Purpose**

Handles outfit removal when item is dropped

**When Called**

When item is dropped

---

