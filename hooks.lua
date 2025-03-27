--[[
   Hook: ShouldHideBars

   Description:
      Determines whether the player's HUD bars (action/status) should be hidden.
      If this hook returns true, lia.bar.drawAll will skip rendering all bars.

   Parameters:
      None

   Returns:
      boolean - Return true to hide bars, false or nil to show them.

   Realm:
      Client

   Example Usage:
      hook.Add("ShouldHideBars", "MyCustomCondition", function()
         return LocalPlayer():InVehicle()
      end)
]]
--[[
   Hook: ShouldBarDraw

   Description:
      Determines whether a specific HUD bar should be drawn.
      Called for each bar individually during lia.bar.drawAll.
      If this hook returns false, the bar will not be rendered.

   Parameters:
      bar (table) - The bar data table. Contains fields such as .priority, .color, .getValue, etc.

   Returns:
      boolean - Return false to skip drawing this bar. Return true or nil to allow drawing.

   Realm:
      Client

   Example Usage:
      hook.Add("ShouldBarDraw", "HideSpecificBar", function(bar)
         return bar.name ~= "stamina" -- Hide stamina bar, show others
      end)
]]
--[[
   Hook: InitializedOptions

   Description:
      Called after the lia.option.load function has finished loading and applying saved option values.
      Use this hook to perform any setup or updates that rely on options being initialized.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Client

   Example Usage:
      hook.Add("InitializedOptions", "SetupStuffAfterOptions", function()
         print("Options have been loaded and are ready to use.")
      end)
]]
--[[
   Hook: InitializedConfig

   Description:
      Called after the config system finishes loading stored configuration values.
      Useful for executing logic that depends on finalized config state.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("InitializedConfig", "ApplyConfigAfterLoad", function()
         print("All configs have been initialized and are ready.")
      end)
]]
--[[
   Hook: InitializedModules

   Description:
      Called after all modules have been loaded and initialized.
      Use this hook to perform any final setup or adjustments that require all modules to be available.
      This is useful for inter-module interactions or post-initialization configuration.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("InitializedModules", "ModulesReady", function()
         print("All modules have been successfully initialized!")
      end)
]]
--[[
   Hook: InitializedSchema

   Description:
      Invoked after the schema (core game mode) has been loaded.
      Use this hook to execute any logic or initialization that depends on the schema being fully set up.
      This is typically one of the first hooks called during module initialization.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("InitializedSchema", "PostSchemaInit", function()
         print("Schema initialization complete!")
      end)
]]
--[[
   Hook: DoModuleIncludes

   Description:
      Called during the module loading process to allow custom file includes or additional initialization.
      This hook is executed after extras like languages, factions, classes, entities, and items have been loaded.
      Use this hook to include extra files or perform custom setup for a module.

   Parameters:
      path (string) - The file system path of the module being processed.
      MODULE (table) - The module table containing all loaded data and functions.

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("DoModuleIncludes", "CustomIncludes", function(path, MODULE)
         -- Add custom includes or perform additional setup for the module
         print("Running extra includes for module:", MODULE.name)
      end)
]]
--[[
   Hook: OnServerLog

   Description:
      Called when a server log event is generated. This hook is triggered during the logging process (typically within lia.log.add)
      after a log string has been produced. It allows other modules or systems to process, display, or modify the log event before
      it is saved or further handled.

   Parameters:
      client (Player) - The player associated with the log event.
      logType (string) - The identifier for the type of log event.
      logString (string) - The formatted log message.
      category (string) - The category for the log event, used to organize log files.

   Returns:
      nil

   Realm:
      Server

   Example Usage:
      hook.Add("OnServerLog", "CustomLogHandler", function(client, logType, logString, category)
         print("Server Log:", logType, logString, "Category:", category)
      end)
]]
--[[
   Hook: OnLocalizationLoaded

   Description:
      Triggered after all language files have been loaded and processed by the localization system.
      This hook signals that the language data is fully available and that any further initialization
      or updates depending on localization can now be safely performed.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("OnLocalizationLoaded", "MyLocalizationInit", function()
         print("Localization data has been loaded!")
      end)
]]
--[[
   Hook: InitializedKeybinds

   Description:
      Triggered once the keybind system has finished loading and initializing keybind configurations.
      This hook indicates that keybind settings are now available and ready for use or further modifications,
      allowing other modules or systems to perform additional setup or adjustments related to keybinds.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("InitializedKeybinds", "MyKeybindInitialization", function()
         print("Keybinds initialized successfully!")
      end)
]]
--[[
   Hook: EasyIconsLoaded

   Description:
      Triggered once the easy icons have been loaded and processed.
      This hook indicates that icon data is now available for use by other systems that require icon fonts.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("EasyIconsLoaded", "MyIconsInit", function()
         print("Easy icons loaded successfully!")
      end)
]]
--[[
   Hook: OnMySQLOOConnected

   Description:
      Called when MySQLOO successfully connects to the database.
      This hook is triggered after all connection pools are connected and is used
      to perform post-connection setup such as registering prepared statements.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("OnMySQLOOConnected", "MySQLOOHandler", function()
         print("MySQLOO is connected!")
      end)
]]
--[[
   Hook: LiliaTablesLoaded

   Description:
      Triggered after the database tables have been loaded or updated.
      This hook indicates that the database schema is now ready for use and
      allows further initialization routines to run.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("LiliaTablesLoaded", "TablesHandler", function()
         print("Database tables loaded!")
      end)
]]
--[[
   Hook: OnLoadTables

   Description:
      Called immediately after the database tables have been loaded.
      Use this hook to perform additional setup actions that depend on the database schema.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("OnLoadTables", "LoadTablesHandler", function()
         print("Database tables load complete!")
      end)
]]
--[[
   Hook: RegisterPreparedStatements

   Description:
      Triggered to register prepared SQL statements for database operations.
      This hook is typically called after a successful database connection to prepare
      commonly used queries for improved performance.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("RegisterPreparedStatements", "PrepStatementsHandler", function()
         print("Prepared statements registered!")
      end)
]]
--[[
   Hook: LoadData

   Description:
      Triggered to load persistent data from storage.
      This hook is typically called during initialization or when the map changes
      to restore saved data.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("LoadData", "LoadDataHandler", function()
         print("Data loaded!")
      end)
]]
--[[
   Hook: PostLoadData

   Description:
      Triggered immediately after data is loaded.
      Use this hook for any post-loading initialization that requires the loaded data.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("PostLoadData", "PostLoadDataHandler", function()
         print("Post-load processing complete!")
      end)
]]
--[[
   Hook: SaveData

   Description:
      Triggered to save persistent data to storage.
      This hook is commonly called during shutdown or at regular intervals to ensure data persistence.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("SaveData", "SaveDataHandler", function()
         print("Data saved!")
      end)
]]
--[[
   Hook: PersistenceSave

   Description:
      Triggered to perform additional persistence operations.
      This hook can be used to save supplementary data that may not be covered by the standard SaveData hook.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      hook.Add("PersistenceSave", "PersistenceSaveHandler", function()
         print("Supplementary data saved!")
      end)
]]
--[[
   Hook: ShouldDataBeSaved

   Description:
      Triggered to determine whether data should be saved.
      Handlers of this hook can return false to prevent data from being saved.

   Parameters:
      None

   Returns:
      boolean - Return false to cancel data saving; otherwise, true (or no return) to proceed.

   Realm:
      Shared

   Example Usage:
      hook.Add("ShouldDataBeSaved", "ShouldDataBeSavedHandler", function()
         return true -- or false to cancel data saving
      end)
]]
--[[
   Hook: CanPlayerUseCommand

   Description:
      This hook is triggered to determine if a player has permission to execute a specific command.
      It is invoked within the command access check function. If any callback returns false,
      the command is considered not accessible to the player.

   Parameters:
      client (Player) - The player attempting to execute the command.
      command (string) - The command being executed.

   Returns:
      boolean - Return false to deny access, or true/nil to allow access.

   Realm:
      Shared

   Example Usage:
      hook.Add("CanPlayerUseCommand", "CheckAdminCommands", function(client, command)
         if command == "restrictedCommand" then
            return false
         end
      end)
]]
--[[
   Hook: CanPlayerJoinClass

   Description:
      Triggered during the class join process to allow custom logic.
      If any callback returns false, the player is prevented from joining the specified class.

   Parameters:
      client (Player) - The player attempting to join the class.
      class (string) - The identifier of the class being joined.
      info (table) - The table containing metadata about the class (e.g., name, description, attributes).

   Returns:
      boolean - Return false to block the class change; return true or nil to allow it.

   Realm:
      Shared

   Example Usage:
      hook.Add("CanPlayerJoinClass", "PreventBannedClass", function(client, class, info)
         if client:IsBannedFromClass(class) then
            return false
         end
      end)
]]
--[[
   Hook: GetDisplayedName

   Description:
      Called when the chatbox needs to determine what name to display for a speaker.
      Allows overriding the default player name or providing a custom label.

   Parameters:
      speaker (Player or Entity) - The entity sending the chat message.
      chatType (string)         - The type/category of chat (e.g., "say", "yell", "pm").

   Returns:
      string - A custom display name. Returning nil falls back to speaker:Name() or “Console”.

   Realm:
      Shared

   Example Usage:
      hook.Add("GetDisplayedName", "UseSteamName", function(speaker, chatType)
         if IsValid(speaker) then
            return speaker:SteamName()
         end
      end)
]]
--[[
   Hook: PlayerMessageSend

   Description:
      Fired just before a chat message is broadcast (server) or echoed locally (client).
      Allows modifying or blocking the outgoing message text.

   Parameters:
      sender (Player or Entity) - The entity sending the message.
      chatType (string)         - The chat category (e.g., "say", "yell").
      text (string)             - The original message content.
      anonymous (boolean)       - True if the sender should be hidden.
      receivers (table<Player>) - (Server only) List of recipients.

   Returns:
      string or nil - Return a modified message string to replace the original.
                      Return false to block sending. Return nil to leave unchanged.

   Realm:
      Shared

   Example Usage:
      hook.Add("PlayerMessageSend", "FilterSwearWords", function(sender, chatType, text)
         return string.gsub(text, "badword", "****")
      end)
]]
--[[ 
   Hook: CreateInventoryPanel

   Description:
      Called to create the inventory UI panel for a given inventory.

   Parameters:
      inventory (table) — the inventory instance to display  
      parent (Panel) — the parent VGUI element  

   Returns:
      Panel — the newly created inventory UI panel
]]
--[[ 
   Hook: CanPlayerViewInventory

   Description:
      Determines whether the local player is allowed to view their inventory.

   Returns:
      boolean|nil — return false to block inventory viewing; anything else allows it
]]
--[[ 
   Hook: PostDrawInventory

   Description:
      Called after the inventory panel is rendered each frame, for drawing custom overlays or effects.

   Parameters:
      mainPanel (Panel) — the inventory UI panel that was drawn

   Returns:
      nil
]]
--[[
   Hook: OnCharVarChanged

   Description:
      Called whenever a character variable changes. Provides the old and new values.

   Parameters:
      self (table) — The character object whose variable changed.
      key (string) — The name of the variable that changed.
      oldVar (any) — The previous value of the variable.
      value (any) — The new value of the variable.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: GetDefaultCharName

   Description:
      Called to retrieve a default name for a newly created or adjusted character. If a string and an override are returned,
      the character's name will be set to that string.

   Parameters:
      client (Player) - The player creating or adjusting the character.
      faction (any) - The faction of the character (number/index or string).
      data (table) - Additional data relevant to the character creation process.

   Returns:
      name (string|nil) - The default name to set, if any.
      override (boolean|nil) - Whether to forcibly use the returned name.

   Realm:
      Shared
]]
--[[
   Hook: GetDefaultCharDesc

   Description:
      Called to retrieve a default description for a newly created or adjusted character. If a string and an override are returned,
      the character's description will be set to that string.

   Parameters:
      client (Player) - The player creating or adjusting the character.
      faction (any) - The faction of the character (number/index or string).

   Returns:
      desc (string|nil) - The default description to set, if any.
      override (boolean|nil) - Whether to forcibly use the returned description.

   Realm:
      Shared
]]
--[[
   Hook: PlayerModelChanged

   Description:
      Called when a character's model is changed, allowing for custom logic like updating UI or applying extra changes.

   Parameters:
      client (Player) - The player whose model changed.
      newModel (string) - The new model path.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: GetAttributeStartingMax

   Description:
      Called when determining the maximum starting value for a particular attribute during character creation.

   Parameters:
      client (Player) - The player creating or adjusting the character.
      attribKey (string) - The attribute key to check for a maximum.

   Returns:
      number|nil - The maximum allowed attribute value. Return nil to ignore.

   Realm:
      Shared
]]
--[[
   Hook: GetMaxStartingAttributePoints

   Description:
      Called when validating total attribute points during character creation.

   Parameters:
      client (Player) - The player creating or adjusting the character.
      currentTotal (number) - The current total of assigned attribute points.

   Returns:
      number|nil - The maximum total attribute points allowed. Return nil to ignore.

   Realm:
      Shared
]]
--[[
   Hook: CharRestored

   Description:
      Fired after a character is successfully loaded from the database. Useful for post-load operations or modifications.

   Parameters:
      character (table) - The character object that was restored.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: CreateDefaultInventory

   Description:
      Called when a newly created or restored character needs a default inventory setup.
      Should return a promise object resolving to an inventory, or nil if handling is deferred.

   Parameters:
      character (table) - The character object that needs a default inventory.

   Returns:
      promise|nil - A promise resolving to the default inventory, or nil if not handled.

   Realm:
      Shared
]]
--[[
   Hook: CharCleanUp

   Description:
      Called when a character is removed or cleaned up from memory. Allows for custom cleanup operations.

   Parameters:
      character (table) - The character object being cleaned up.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: PreCharDelete

   Description:
      Called before a character is fully deleted. Useful for final checks or additional removal logic.

   Parameters:
      id (number) - The unique ID of the character about to be deleted.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: OnCharDelete

   Description:
      Called after a character has been deleted from the database and cleaned up.

   Parameters:
      client (Player|nil) - The player associated with the deleted character, or nil if not valid.
      id (number) - The unique ID of the character that was deleted.

   Returns:
      nil

   Realm:
      Shared
]]
--[[
   Hook: InitializedItems

   Description:
      Fired once all items have been loaded and registered. Useful for performing any setup
      or initialization logic that depends on the complete item list.

   Parameters:
      None

   Realm:
      Shared
]]
--[[
   Hook: OnItemRegistered

   Description:
      Fired immediately after a single item definition has been registered into the system.

   Parameters:
      ITEM (table) — The item table that was just registered.

   Realm:
      Shared
]]
--[[
   Hook: HandleItemTransferRequest

   Description:
      Fired when an item transfer is requested (e.g., via giving or moving items between inventories).
      Handlers should return a deferred that resolves when the transfer is allowed/completed, or return
      false to cancel the transfer.

   Parameters:
      client (Player) — The player initiating the transfer.
      itemID (number) — The ID of the item being transferred.
      fromInvID (number|nil) — The ID of the source inventory, if any.
      fromSlotX (number|nil) — The X coordinate in a grid inventory, if applicable.
      fromSlotY (number|nil) — The Y coordinate in a grid inventory, if applicable.
      toInvID (number) — The ID of the destination inventory.

   Realm:
      Shared
]]