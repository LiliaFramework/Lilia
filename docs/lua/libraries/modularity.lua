--[[
   lia.module.load

   Description:
      Loads a module from a specified path. If the module is a single file, it includes it directly;
      if it is a directory, it loads the core file (or its extended version), applies permissions, workshop content, dependencies, extras, and submodules.
      It also registers the module in the module list if applicable.

   Parameters:
      uniqueID - The unique identifier of the module.
      path - The file system path where the module is located.
      isSingleFile - Boolean indicating if the module is a single file.
      variable - A global variable name used to temporarily store the module.

   Realm:
      Server

   Returns:
      nil

   Example Usage:
        -- This snippet demonstrates a common usage of lia.module.load
      lia.module.load("example", "lilia/modules/example", false)
]]
--[[
   lia.module.initialize

   Description:
      Initializes the module system by loading the schema and various module directories,
      then running the appropriate hooks after modules have been loaded.

   Parameters:
      None

   Realm:
      Server

   Returns:
      nil

   Example Usage:
        -- This snippet demonstrates a common usage of lia.module.initialize
      lia.module.initialize()
]]
--[[
   lia.module.loadFromDir

   Description:
      Loads modules from a specified directory. It iterates over all subfolders and .lua files in the directory.
      Each subfolder is treated as a multi-file module, and each .lua file as a single-file module.
      Non-Lua files are ignored.

   Parameters:
      directory - The directory path from which to load modules.
      group - A string representing the module group (e.g., "schema" or "module").

   Realm:
      Server

   Returns:
      nil

   Example Usage:
        -- This snippet demonstrates a common usage of lia.module.loadFromDir
      lia.module.loadFromDir("lilia/modules/core", "module")
]]
--[[
   lia.module.get

   Description:
      Retrieves a module table by its identifier.

   Parameters:
      identifier - The unique identifier of the module to retrieve.

   Realm:
      Server

   Returns:
      The module table if found, or nil if the module is not registered.

   Example Usage:
        -- This snippet demonstrates a common usage of lia.module.get
      local mod = lia.module.get("schema")
]]