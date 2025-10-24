# Stackable Item Definition

Stackable item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the stackable item

**When Called**

During item definition

---

### model

**Purpose**

Sets the 3D model for the stackable item

**When Called**

During item definition

---

### width

**Purpose**

Sets the inventory width of the stackable item

**When Called**

During item definition

---

### height

**Purpose**

Sets the inventory height of the stackable item

**When Called**

During item definition

---

### isStackable

**Purpose**

Marks the item as stackable

**When Called**

During item definition

---

### maxQuantity

**Purpose**

Sets the maximum quantity for the stackable item

**When Called**

During item definition

---

### canSplit

**Purpose**

Sets whether the item can be split

**When Called**

During item definition

---

### ITEM:getDesc()

**Purpose**

Custom description function that shows quantity

**When Called**

When displaying item description

---

### ITEM:paintOver(item)

**Purpose**

Custom paint function to display quantity on the item

**When Called**

When rendering the item in inventory

---

### ITEM:onCombine(other)

**Purpose**

Handles combining stackable items

**When Called**

When two stackable items are combined

---

