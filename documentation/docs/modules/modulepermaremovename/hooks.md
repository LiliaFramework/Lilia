# Hooks

Module-specific events raised by the Perma Remove module.

---

### `CanPermaRemoveEntity`

**Purpose**

`Determines if an entity can be permanently removed by an admin.`

**Parameters**

* `client` (`Player`): `Admin requesting the removal.`

* `entity` (`Entity`): `Map entity targeted for deletion.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to block the removal.`

**Example**

```lua
hook.Add("CanPermaRemoveEntity", "BlockDoors", function(client, entity)
    if entity:GetClass() == "prop_door_rotating" then return false end
end)
```

---

### `OnPermaRemoveEntity`

**Purpose**

`Called after an entity is permanently removed with the command.`

**Parameters**

* `client` (`Player`): `Admin that removed the entity.`

* `entity` (`Entity`): `Entity that was deleted.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnPermaRemoveEntity", "LogRemoval", function(client, entity)
    print(client:Name(), "removed", entity)
end)
```

---

### `OnPermaRemoveLoaded`

**Purpose**

`Runs during map loading for each stored entity that is removed.`

**Parameters**

* `entity` (`Entity`): `Map entity being removed automatically.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnPermaRemoveLoaded", "HandleLoadedRemoval", function(entity)
    print("Removed on load", entity)
end)
```

---

