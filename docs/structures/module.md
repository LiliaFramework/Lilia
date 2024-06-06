# Structure - Module

```lua
MODULE.name = "A Module"

MODULE.author = "76561198312513285"

MODULE.discord = "@liliaplayer"

MODULE.desc = "This is a Example Module."

MODULE.WorkshopContent = {"2959728255"}

MODULE.enabled = true

MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Kekw",
        MinAccess = "superadmin",
        Description = "Allows access to kewking.",
    },
}

MODULE.Dependencies = {
    {
        File = MODULE.path .. "/nicebogusfile.lua",
        Realm = "server",
    },
    {
        File = MODULE.path .. "/badbogusfile.lua",
        Realm = "client",
    },
}
```

---

## Module Configuration

-   **`MODULE.name`:** Specifies the name of the module, which is "Core - Permissions" in this case. This variable identifies the module.

-   **`MODULE.author`:** Indicates the author of the module. It can be a STEAMID64 or Name. Replace "76561198312513285" with the actual author information.

-   **`MODULE.discord`:** Indicates the discord of the module creator, in this case, as shown, is liliaplayer.

-   **`MODULE.desc`:** Provides a brief description of the module's purpose. In this case, it states that the module adds skills functionality to the framework.

-   **`MODULE.identifier`:** This global variable uniquely identifies the module and allows it to be accessed from outside its scope. **Optional**

-   **`MODULE.CAMIPrivileges`:** An example CAMI permission that is loaded alongside the module. **Optional**

-   **`MODULE.WorkshopContent`:** Workshop Content to be added. **Optional**

-   **`MODULE.enabled`:** Indicates if the module is active or not. If False, then it won't be. **Optional**

-   **`MODULE.Dependencies`:** Files and corresponding realms to be included. **Optional**

### Automatically Included Files and Folders in the Module:

**Files:**

-   client.lua

-   cl_module.lua

-   sv_module.lua

-   server.lua

-   config.lua

-   sconfig.lua

**Folders:**

-   dependencies

-   config
-   permissions

-   libs

-   hooks

-   libraries

-   commands

-   netcalls

-   meta

-   derma

-   pim

-   concommands

