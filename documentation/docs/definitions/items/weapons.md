# Weapons Item Definition

Weapon item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the weapon item

**When Called**

During item definition

---

### desc

**Purpose**

Sets the description of the weapon item

**When Called**

During item definition

---

### category

**Purpose**

Sets the category for the weapon item

**When Called**

During item definition

---

### model

**Purpose**

Sets the 3D model for the weapon item

**When Called**

During item definition

---

### class

**Purpose**

Sets the weapon class name

**When Called**

During item definition (used in equip/unequip functions)

---

### width

**Purpose**

Sets the inventory width of the weapon item

**When Called**

During item definition

---

### height

**Purpose**

Sets the inventory height of the weapon item

**When Called**

During item definition

---

### isWeapon

**Purpose**

Marks the item as a weapon

**When Called**

During item definition

---

### RequiredSkillLevels

**Purpose**

Sets required skill levels for the weapon

**When Called**

During item definition

---

### DropOnDeath

**Purpose**

Sets whether the weapon drops when player dies

**When Called**

During item definition

---

### postHooks

**Purpose**

Post-hook for weapon dropping

**When Called**

After weapon is dropped

---

### ITEM:hook("drop", function(item) ... end)

**Purpose**

Handles weapon dropping with ragdoll and equip checks

**When Called**

When weapon is dropped

---

### ITEM:OnCanBeTransfered(_, newInventory)

**Purpose**

Prevents transfer of equipped weapons

**When Called**

When attempting to transfer the weapon

---

### ITEM:onLoadout()

**Purpose**

Handles weapon loading on player spawn

**When Called**

When player spawns with equipped weapon

---

### ITEM:OnSave()

**Purpose**

Saves weapon ammo data

**When Called**

When saving the weapon item

---

### ITEM:getName()

**Purpose**

Custom name function for weapons (CLIENT only)

**When Called**

When displaying weapon name

---

