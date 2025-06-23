# lia

---

Top-level library containing all Lilia libraries.

The `lia` library serves as the core container for all other libraries within the Lilia Framework. It provides essential functions for including and managing Lua files across different realms (server, client, and shared). This library ensures that all necessary components are correctly loaded and accessible, maintaining the integrity and functionality of the framework. By organizing the framework into modular libraries, `lia` facilitates easier maintenance, scalability, and customization of your game or application.

**NOTE:** Ensure that all file paths and realms are correctly specified when using inclusion functions to prevent loading issues. Properly managing realms is crucial for maintaining server-client synchronization and optimizing performance.

---

### **lia.include**

**Description:**  
Includes a Lua file into the specified realm (`server`, `client`, or `shared`). This function determines the appropriate realm based on the provided `state`, the file's prefix (`sv_`, `cl_`, `sh_`), or its directory structure. It ensures that server-side files are only executed on the server, client-side files on the client, and shared files on both.

**Realm:**  
`Shared`

**Parameters:**  

- `fileName` (`string`):  
  The path to the Lua file to be included. Ensure that the path is relative to the Lua directory.

- `state` (`string`):  
  The realm in which the Lua file should be included. Acceptable values are `"server"`, `"client"`, or `"shared"`. The function also infers the realm based on file naming conventions (`sv_` for server, `cl_` for client, `sh_` for shared) and the directory structure.

**Returns:**  
If the Lua file is included on the server and the state is `"server"`, it returns the included file. Otherwise, there is no return value.

**Example Usage:**
```lua
-- Include a shared library
lia.include("lilia/gamemode/core/libraries/util.lua", "shared")

-- Include a server-side script
lia.include("lilia/gamemode/core/hooks/server.lua", "server")

-- Include a client-side script
lia.include("lilia/gamemode/core/libraries/menu.lua", "client")
```

---

### **lia.includeDir**

**Description:**  
Includes all Lua files from a specified directory into the designated realm. This function supports recursive inclusion, allowing for nested directories to be processed. It ensures that each Lua file is correctly loaded into the appropriate realm based on its location and naming conventions.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`):  
  The path to the directory containing the Lua files to be included.

- `fromLua` (`bool`):  
  Specifies if the Lua files are located directly within the `lua/` folder. Set to `true` if files are within `lua/`, otherwise `false`.

- `recursive` (`bool`):  
  Determines whether subdirectories should be included recursively. Set to `true` to include all nested directories, or `false` to include only the top-level files.

- `realm` (`string`):  
  The realm in which the Lua files should be included. Acceptable values are `"server"`, `"client"`, or `"shared"`.


**Example Usage:**
```lua
-- Include all shared libraries from the core libraries directory recursively
lia.includeDir("core/libraries", false, true, "shared")

-- Include all client-side libraries from the client directory without recursion
lia.includeDir("core/libraries/client", true, false, "client")
```

**Legacy Alias:**  
`lia.util.includeDir` can be used interchangeably with `lia.includeDir`.

---

### **lia.includeEntities**

**Description:**  
Dynamically loads Lua files for entities, weapons, tools, and effects into the appropriate realm of a Garry's Mod Lua project. This function iterates through a specified directory and its subdirectories, including Lua files for entities, weapons, tools, and effects into the server, client, or shared realms as needed. It automatically registers the entities, weapons, tools, and effects in the correct context (server, client, or shared).

**Realm:**  
`Shared`

**Parameters:**  

- `path` (`string`):  
  The directory containing the Lua files to be included. Typically points to the `entities`, `weapons`, `tools`, or `effects` directories within the gamemode.

**Example Usage:**
```lua
-- Include all entity-related Lua files
lia.includeEntities("lilia/gamemode/entities")

-- Include all weapon-related Lua files
lia.includeEntities("lilia/gamemode/weapons")

-- Include all tool-related Lua files
lia.includeEntities("lilia/gamemode/tools")

-- Include all effect-related Lua files
lia.includeEntities("lilia/gamemode/effects")
```

**Legacy Alias:**  
`lia.util.loadEntities` can be used interchangeably with `lia.includeEntities`.

---