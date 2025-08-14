# Hooks

Module-specific events raised by the NPC Drops module.

---

### `NPCDropCheck`

**Purpose**

`First hook called when an NPC dies to determine drops.`

**Parameters**

* `ent` (`NPC`): `The killed NPC entity.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDropCheck", "LogDeath", function(ent)
    print("Checking drops for", ent:GetClass())
end)
```

---

### `NPCDropNoTable`

**Purpose**

`Runs when the NPC has no drop table defined.`

**Parameters**

* `ent` (`NPC`): `The NPC without a table.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDropNoTable", "NoLoot", function(ent)
    -- maybe handle default drops
end)
```

---

### `NPCDropNoItems`

**Purpose**

`Called when the drop table exists but all weights sum to zero.`

**Parameters**

* `ent` (`NPC`): `NPC that will drop nothing.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDropNoItems", "Log", function(ent)
    print(ent:GetClass(), "had no items to drop")
end)
```

---

### `NPCDropRoll`

**Purpose**

`Notifies the roll used to pick which item will drop.`

**Parameters**

* `ent` (`NPC`): `The NPC that died.`

* `choice` (`number`): `Random number selected.`

* `total` (`number`): `Total weight of all items.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDropRoll", "Debug", function(ent, choice, total)
    print("Rolled", choice, "out of", total)
end)
```

---

### `NPCDroppedItem`

**Purpose**

`Runs when an item is successfully spawned from the NPC.`

**Parameters**

* `ent` (`NPC`): `The NPC that dropped the item.`

* `itemName` (`string`): `Name of the spawned item.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDroppedItem", "Celebrate", function(ent, itemName)
    print(ent:GetClass(), "dropped", itemName)
end)
```

---

### `NPCDropFailed`

**Purpose**

`Called if no item matched the random roll.`

**Parameters**

* `ent` (`NPC`): `The NPC whose drop failed.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("NPCDropFailed", "Failure", function(ent)
    print("No item chosen for", ent:GetClass())
end)
```

---

