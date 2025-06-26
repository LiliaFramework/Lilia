## lia.include(path, realm)

**Description:**
Includes a Lua file based on its realm. Determines the realm from the file name or the provided `realm` argument, and handles server/client/shared inclusion logic automatically.

---

### Parameters

* **path** *(string)*: The filesystem path to the Lua file to include.  
* **realm** *(string)*: Optional override of the realm state. One of `"server"`, `"client"`, or `"shared"`. If omitted, the realm is inferred from filename prefixes (`sv_`, `cl_`, `sh_`) or the `RealmIDs` table.

---

### Returns

* Whatever the underlying `include` or `AddCSLuaFile` call returns (if anything).

---

**Realm:**  
Shared (but will dispatch to server/client appropriately)

---

### Example

```lua
lia.include("lilia/gamemode/core/libraries/util.lua", "shared")
````

---

## lia.includeDir(dir, raw, deep, realm)

**Description:**
Includes all `.lua` files in a specified directory. If `deep` is `true`, it recursively descends into subdirectories. Builds the full search path from the active schema or gamemode folder unless `raw` is set.

---

### Parameters

* **dir** *(string)*: Directory path relative to the gamemode/schema folder (unless `raw == true`).
* **raw** *(boolean)*: If `true`, treats `dir` as an absolute filesystem path.
* **deep** *(boolean)*: If `true`, includes subdirectories recursively.
* **realm** *(string)*: Optional realm override for all files (`"server"`, `"client"`, or `"shared"`).

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
```

---

## lia.includeGroupedDir(dir, raw, recursive, forceRealm)

**Description:**
Recursively includes all `.lua` files in a directory (and subdirectories, if `recursive == true`), preserving alphabetical order. Determines each file’s realm via filename prefix or an optional `forceRealm` override before calling `lia.include`.

---

### Parameters

* **dir** *(string)*: Directory path relative to the gamemode/schema root (unless `raw == true`).
* **raw** *(boolean)*: If `true`, uses `dir` verbatim as the filesystem path.
* **recursive** *(boolean)*: If `true`, will traverse subdirectories.
* **forceRealm** *(string)*: Optional override realm (`"server"`, `"client"`, or `"shared"`). If omitted, realm is inferred from each filename’s prefix.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.includeGroupedDir("lilia/gamemode/core/derma", true, true, "client")
```

---

## lia.error(msg)

**Description:**
Prints a colored error message prefixed with `[Lilia] [Error]` to the console.

---

### Parameters

* **msg** *(string)*: The error text to display.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.error("Invalid configuration detected")
```

---

## lia.deprecated(methodName, callback)

**Description:**
Logs a deprecation warning for the given method name, then optionally runs a fallback callback.

---

### Parameters

* **methodName** *(string)*: Name of the deprecated method to warn about.
* **callback** *(function)*: Optional function to execute after logging the warning.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.deprecated("OldFunction", function()
    NewFunction()
end)
```

---

## lia.updater(msg)

**Description:**
Prints an updater message in cyan, prefixed with `[Lilia] [Updater]`, to the console.

---

### Parameters

* **msg** *(string)*: Update text to display.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.updater("Loading additional content...")
```

---

## lia.information(msg)

**Description:**
Prints an informational message with the `[Lilia] [Information]` prefix to the console.

---

### Parameters

* **msg** *(string)*: The informational text to display.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.information("Server started successfully")
```

---

## lia.bootstrap(section, msg)

**Description:**
Logs a bootstrap stage message with a colored section tag for clarity.

---

### Parameters

* **section** *(string)*: Category or stage of the bootstrap process.
* **msg** *(string)*: Descriptive message for this bootstrap step.

---

### Returns

* None

---

**Realm:**
Shared

---

### Example

```lua
lia.bootstrap("Database", "Connection established")
```

---

## lia.includeEntities(path)

**Description:**
Recursively includes all entity, weapon, tool, and effect definitions in a given directory. For each subfolder/item, loads `init.lua`, `shared.lua`, or `cl_init.lua` based on realm, registers the entity/weapon/tool/effect, and supports optional callbacks for creation and completion.

---

### Parameters

* **path** *(string)*: Base directory containing entity folders (e.g. `"lilia/gamemode/entities"`).

---

### Returns

* None

---

**Realm:**
Client/Server (files themselves determine realm)

---

### Example

```lua
lia.includeEntities("lilia/gamemode/core/entities")
```

```