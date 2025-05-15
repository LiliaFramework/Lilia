--[[
    ShouldHideBars()

    Description:
        Determines whether the player's HUD bars (action/status) should be hidden.
        If this hook returns true, lia.bar.drawAll will skip rendering all bars.

    Parameters:
        None

    Realm:
        Client

    Returns:
        boolean – Return true to hide bars, false or nil to show them.
]]
--[[
    ShouldBarDraw(bar)

    Description:
        Determines whether a specific HUD bar should be drawn.
        Called for each bar individually during lia.bar.drawAll.
        If this hook returns false, the bar will not be rendered.

    Parameters:
        bar (table) – The bar data table. Contains fields such as .priority, .color, .getValue, etc.

    Realm:
        Client

    Returns:
        boolean – Return false to skip drawing this bar. Return true or nil to allow drawing.
]]
--[[
    InitializedOptions()

    Description:
        Called after the lia.option.load function has finished loading and applying saved option values.
        Use this hook to perform any setup or updates that rely on options being initialized.

    Parameters:
        None

    Realm:
        Client

    Returns:
        None
]]
--[[
    InitializedConfig()

    Description:
        Called after the config system finishes loading stored configuration values.
        Useful for executing logic that depends on finalized config state.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    InitializedModules()

    Description:
        Called after all modules have been loaded and initialized.
        Use this hook to perform any final setup or adjustments that require all modules to be available.
        Useful for inter-module interactions or post-initialization configuration.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    InitializedSchema()

    Description:
        Invoked after the schema (core game mode) has been loaded.
        Use this hook to execute any logic or initialization that depends on the schema being fully set up.
        This is typically one of the first hooks called during module initialization.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    DoModuleIncludes(path, MODULE)

    Description:
        Called during the module loading process to allow custom file includes or additional initialization.
        This hook is executed after extras like languages, factions, classes, entities, and items have been loaded.
        Use this hook to include extra files or perform custom setup for a module.

    Parameters:
        path (string) – The file system path of the module being processed.
        MODULE (table) – The module table containing all loaded data and functions.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    OnServerLog(client, logType, logString, category)

    Description:
        Called when a server log event is generated. Triggered during the logging process (typically within lia.log.add)
        after a log string has been produced. Allows other modules or systems to process, display, or modify the log event
        before it is saved or further handled.

    Parameters:
        client (Player) – The player associated with the log event.
        logType (string) – The identifier for the type of log event.
        logString (string) – The formatted log message.
        category (string) – The category for the log event, used to organize log files.

    Realm:
        Server

    Returns:
        None
]]
--[[
    OnLocalizationLoaded()

    Description:
        Triggered after all language files have been loaded and processed by the localization system.
        This hook signals that the language data is fully available and that any further initialization
        or updates depending on localization can now be safely performed.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    InitializedKeybinds()

    Description:
        Triggered once the keybind system has finished loading and initializing keybind configurations.
        This hook indicates that keybind settings are now available and ready for use or further modifications,
        allowing other modules or systems to perform additional setup or adjustments related to keybinds.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    EasyIconsLoaded()

    Description:
        Triggered once the easy icons have been loaded and processed.
        This hook indicates that icon data is now available for use by other systems that require icon fonts.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    OnMySQLOOConnected()

    Description:
        Called when MySQLOO successfully connects to the database.
        This hook is triggered after all connection pools are connected and is used
        to perform post-connection setup such as registering prepared statements.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    LiliaTablesLoaded()

    Description:
        Triggered after the database tables have been loaded or updated.
        This hook indicates that the database schema is now ready for use and
        allows further initialization routines to run.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    OnLoadTables()

    Description:
        Called immediately after the database tables have been loaded.
        Use this hook to perform additional setup actions that depend on the database schema.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    RegisterPreparedStatements()

    Description:
        Triggered to register prepared SQL statements for database operations.
        This hook is typically called after a successful database connection to prepare
        commonly used queries for improved performance.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    LoadData()

    Description:
        Triggered to load persistent data from storage.
        This hook is typically called during initialization or when the map changes
        to restore saved data.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    PostLoadData()

    Description:
        Triggered immediately after data is loaded.
        Use this hook for any post-loading initialization that requires the loaded data.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    SaveData()

    Description:
        Triggered to save persistent data to storage.
        This hook is commonly called during shutdown or at regular intervals to ensure data persistence.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    PersistenceSave()

    Description:
        Triggered to perform additional persistence operations.
        This hook can be used to save supplementary data that may not be covered by the standard SaveData hook.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    ShouldDataBeSaved()

    Description:
        Triggered to determine whether data should be saved.
        Handlers of this hook can return false to prevent data from being saved.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Return false to cancel data saving; otherwise, true or nil to proceed.
]]
--[[
    CanPlayerUseCommand(client, command)

    Description:
        Triggered to determine if a player has permission to execute a specific command.
        Invoked within the command access check function. If any callback returns false,
        the command is considered not accessible to the player.

    Parameters:
        client (Player) – The player attempting to execute the command.
        command (string) – The command being executed.

    Realm:
        Shared

    Returns:
        boolean – Return false to deny access, or true or nil to allow access.
]]
--[[
    CanPlayerJoinClass(client, class, info)

    Description:
        Triggered during the class join process to allow custom logic.
        If any callback returns false, the player is prevented from joining the specified class.

    Parameters:
        client (Player) – The player attempting to join the class.
        class (string) – The identifier of the class being joined.
        info (table) – The table containing metadata about the class (e.g., name, description, attributes).

    Realm:
        Shared

    Returns:
        boolean – Return false to block the class change; return true or nil to allow it.
]]
--[[
    GetDisplayedName(speaker, chatType)

    Description:
        Called when the chatbox needs to determine what name to display for a speaker.
        Allows overriding the default player name or providing a custom label.

    Parameters:
        speaker (Player or Entity) – The entity sending the chat message.
        chatType (string) – The type/category of chat (e.g., "say", "yell", "pm").

    Realm:
        Shared

    Returns:
        string – A custom display name. Returning nil falls back to speaker:Name() or “Console”.
]]
--[[
    PlayerMessageSend(sender, chatType, text, anonymous, receivers)

    Description:
        Fired just before a chat message is broadcast (server) or echoed locally (client).
        Allows modifying or blocking the outgoing message text.

    Parameters:
        sender (Player or Entity) – The entity sending the message.
        chatType (string) – The chat category (e.g., "say", "yell").
        text (string) – The original message content.
        anonymous (boolean) – True if the sender should be hidden.
        receivers (table<Player>) – (Server only) List of recipients.

    Realm:
        Shared

    Returns:
        string or boolean – Return a modified message string to replace the original, false to block sending, or nil to leave unchanged.
]]
--[[
    CreateInventoryPanel(inventory, parent)

    Description:
        Called to create the inventory UI panel for a given inventory.

    Parameters:
        inventory (table) – The inventory instance to display.
        parent (Panel) – The parent VGUI element.

    Realm:
        Client

    Returns:
        Panel – The newly created inventory UI panel.
]]
--[[
    CanPlayerViewInventory()

    Description:
        Determines whether the local player is allowed to view their inventory.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean or nil – Return false to block inventory viewing; anything else allows it.
]]
--[[
    PostDrawInventory(mainPanel)

    Description:
        Called after the inventory panel is rendered each frame, for drawing custom overlays or effects.

    Parameters:
        mainPanel (Panel) – The inventory UI panel that was drawn.

    Realm:
        Client

    Returns:
        None
]]
--[[
    OnCharVarChanged(self, key, oldVar, value)

    Description:
        Called whenever a character variable changes. Provides the old and new values.

    Parameters:
        self (table) – The character object whose variable changed.
        key (string) – The name of the variable that changed.
        oldVar (any) – The previous value of the variable.
        value (any) – The new value of the variable.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    GetDefaultCharName(client, faction, data)

    Description:
        Called to retrieve a default name for a newly created or adjusted character.
        If a string and an override are returned, the character's name will be set to that string.

    Parameters:
        client (Player) – The player creating or adjusting the character.
        faction (any) – The faction of the character (number/index or string).
        data (table) – Additional data relevant to the character creation process.

    Realm:
        Shared

    Returns:
        string or nil, boolean or nil – name and override flag. Name to set if returned, override determines forced use.
]]
--[[
    GetDefaultCharDesc(client, faction)

    Description:
        Called to retrieve a default description for a newly created or adjusted character.
        If a string and an override are returned, the character's description will be set to that string.

    Parameters:
        client (Player) – The player creating or adjusting the character.
        faction (any) – The faction of the character (number/index or string).

    Realm:
        Shared

    Returns:
        string or nil, boolean or nil – desc and override flag. Description to set if returned, override determines forced use.
]]
--[[
    PlayerModelChanged(client, newModel)

    Description:
        Called when a character's model is changed, allowing for custom logic like updating UI or applying extra changes.

    Parameters:
        client (Player) – The player whose model changed.
        newModel (string) – The new model path.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    GetAttributeStartingMax(client, attribKey)

    Description:
        Called when determining the maximum starting value for a particular attribute during character creation.

    Parameters:
        client (Player) – The player creating or adjusting the character.
        attribKey (string) – The attribute key to check for a maximum.

    Realm:
        Shared

    Returns:
        number or nil – The maximum allowed attribute value. Return nil to ignore.
]]
--[[
    GetMaxStartingAttributePoints(client, currentTotal)

    Description:
        Called when validating total attribute points during character creation.

    Parameters:
        client (Player) – The player creating or adjusting the character.
        currentTotal (number) – The current total of assigned attribute points.

    Realm:
        Shared

    Returns:
        number or nil – The maximum total attribute points allowed. Return nil to ignore.
]]
--[[
    CharRestored(character)

    Description:
        Fired after a character is successfully loaded from the database. Useful for post-load operations or modifications.

    Parameters:
        character (table) – The character object that was restored.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    CreateDefaultInventory(character)

    Description:
        Called when a newly created or restored character needs a default inventory setup.
        Should return a promise object resolving to an inventory, or nil if handling is deferred.

    Parameters:
        character (table) – The character object that needs a default inventory.

    Realm:
        Shared

    Returns:
        promise or nil – A promise resolving to the default inventory, or nil if not handled.
]]
--[[
    CharCleanUp(character)

    Description:
        Called when a character is removed or cleaned up from memory. Allows for custom cleanup operations.

    Parameters:
        character (table) – The character object being cleaned up.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    PreCharDelete(id)

    Description:
        Called before a character is fully deleted. Useful for final checks or additional removal logic.

    Parameters:
        id (number) – The unique ID of the character about to be deleted.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    OnCharDelete(client, id)

    Description:
        Called after a character has been deleted from the database and cleaned up.

    Parameters:
        client (Player or nil) – The player associated with the deleted character, or nil if not valid.
        id (number) – The unique ID of the character that was deleted.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    InitializedItems()

    Description:
        Fired once all items have been loaded and registered. Useful for performing any setup or initialization logic that depends on the complete item list.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None
]]
--[[
    OnItemRegistered(ITEM)

    Description:
        Fired immediately after a single item definition has been registered into the system.

    Parameters:
        ITEM (table) – The item table that was just registered.

    Realm:
        Shared

    Returns:
        None
]]
--[[
    HandleItemTransferRequest(client, itemID, fromInvID, fromSlotX, fromSlotY, toInvID)

    Description:
        Fired when an item transfer is requested (e.g., via giving or moving items between inventories).
        Handlers should return a deferred that resolves when the transfer is allowed/completed, or return false to cancel the transfer.

    Parameters:
        client (Player) – The player initiating the transfer.
        itemID (number) – The ID of the item being transferred.
        fromInvID (number or nil) – The ID of the source inventory, if any.
        fromSlotX (number or nil) – The X coordinate in a grid inventory, if applicable.
        fromSlotY (number or nil) – The Y coordinate in a grid inventory, if applicable.
        toInvID (number) – The ID of the destination inventory.

    Realm:
        Shared

    Returns:
        promise or boolean – A deferred resolving when allowed, or false to cancel the transfer.
]]
