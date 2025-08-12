# Hooks

Module-specific events raised by the Code Utilities module.

---

### `CodeUtilsLoaded`

**Purpose**

Indicates the code utilities module has finished loading.

**Parameters**

_None_

**Realm**

`Shared`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CodeUtilsLoaded", "AfterCodeUtils", function()
    print("Code utilities are ready")
end)
```

---

### `UtilityPropSpawned`

**Purpose**

Called after `lia.utilities.spawnProp` creates a new physics prop.

**Parameters**

* `entity` (`Entity`): The prop that was spawned.

* `model` (`string`): Model path of the prop.

* `position` (`Vector`): Spawn position of the prop.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("UtilityPropSpawned", "TrackProp", function(entity, model, position)
    print("Spawned prop", model)
end)
```

---

### `UtilityEntitySpawned`

**Purpose**

Fires for each entity created via `lia.utilities.spawnEntities`.

**Parameters**

* `entity` (`Entity`): The spawned entity.

* `class` (`string`): Entity class name.

* `position` (`Vector`): Spawn position.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("UtilityEntitySpawned", "TrackEntity", function(entity, class, position)
    print("Spawned entity", class)
end)
```

---

