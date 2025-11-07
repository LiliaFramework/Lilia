# Entities Item Definition

Entity placement item system for the Lilia framework.

---

### name

#### 📋 Purpose
Sets the display name of the entity item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.name = "Chair"

```

---

### model

#### 📋 Purpose
Sets the 3D model for the entity item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.model = "models/props_c17/FurnitureChair001a.mdl"

```

---

### desc

#### 📋 Purpose
Sets the description of the entity item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.desc = "A comfortable chair for sitting"

```

---

### category

#### 📋 Purpose
Sets the category for the entity item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.category = "entities"

```

---

### entityid

#### 📋 Purpose
Sets the entity class name to spawn

#### ⏰ When Called
During item definition (used in Place function)

#### 💡 Example Usage

```lua
    ITEM.entityid = "prop_physics"

```

---

### health

#### 📋 Purpose
Sets the health value for the item when it's dropped as an entity in the world

#### ⏰ When Called
During item definition (used when item is spawned as entity)
Notes:
- Defaults to 100 if not specified
- When the item entity takes damage, its health decreases
- Item is destroyed when health reaches 0
- Only applies if ITEM.CanBeDestroyed is true (controlled by config)

#### 💡 Example Usage

```lua
    ITEM.health = 250  -- Item can take 250 damage before being destroyed

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
            ITEM.name = "Chair"

            ITEM.model = "models/props_c17/FurnitureChair001a.mdl"

            ITEM.desc = "A comfortable chair for sitting"

            ITEM.category = "entities"

            ITEM.entityid = "prop_physics"

            ITEM.health = 250  -- Item can take 250 damage before being destroyed

    -- Basic item identification
        ITEM.name = "Chair"                                          -- Display name shown to players
        ITEM.model = "models/props_c17/FurnitureChair001a.mdl"       -- 3D model for the item
        ITEM.desc = "A comfortable chair for sitting"                -- Description text
        ITEM.category = "entities"                                   -- Category for inventory sorting
        ITEM.entityid = "prop_physics"                               -- Entity class to spawn when placed
        ITEM.health = 250                                            -- Health when dropped (default: 100)

```

---

