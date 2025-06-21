--[[
        CAMI.OnPrivilegeRegistered(privilege)

        Description:
            Fired when a privilege is registered.

        Parameters:
            privilege (table) – Privilege being registered.

        Realm:
            Shared
    ]]

--[[
        CAMI.OnPrivilegeUnregistered(privilege)

        Description:
            Fired when a privilege is unregistered.

        Parameters:
            privilege (table) – Privilege being removed.

        Realm:
            Shared
    ]]

--[[
        CAMI.OnUsergroupRegistered(usergroup, source)

        Description:
            Fired when a usergroup is registered.

        Parameters:
            usergroup (table) – Usergroup information.
            source (string) – Identifier of the origin.

        Realm:
            Shared
    ]]

--[[
        CAMI.OnUsergroupUnregistered(usergroup, source)

        Description:
            Fired when a usergroup is unregistered.

        Parameters:
            usergroup (table) – Usergroup information.
            source (string) – Identifier of the origin.

        Realm:
            Shared
    ]]

--[[
        CAMI.PlayerHasAccess(defaultAccessHandler, player, privilegeName, callback, target, info)

        Description:
            Called when checking if a player has access to a privilege.

        Parameters:
            defaultAccessHandler (table) – Fallback access handler.
            player (Player) – The player requesting access.
            privilegeName (string) – Privilege identifier.
            callback (function) – Function to receive the result.
            target (Player) – Player the privilege acts upon.
            info (table) – Optional extra information.

        Realm:
            Shared
    ]]

--[[
        CAMI.PlayerUsergroupChanged(player, oldGroup, newGroup, source)

        Description:
            Fired when a player's user group changes.

        Parameters:
            player (Player) – The player that changed groups.
            oldGroup (string) – Previous group name.
            newGroup (string) – New group name.
            source (string) – Identifier of the origin.

        Realm:
            Shared
    ]]

--[[
        CAMI.SteamIDHasAccess(defaultAccessHandler, steamID, privilegeName, callback, targetSteamID, info)

        Description:
            Called when querying if a SteamID has access to a privilege.

        Parameters:
            defaultAccessHandler (table) – Fallback access handler.
            steamID (string) – SteamID being checked.
            privilegeName (string) – Privilege identifier.
            callback (function) – Function to receive the result.
            targetSteamID (string) – SteamID the privilege acts upon.
            info (table) – Optional extra information.

        Realm:
            Shared
    ]]

--[[
        CAMI.SteamIDUsergroupChanged(steamID, oldGroup, newGroup, source)

        Description:
            Fired when a SteamID's user group changes.

        Parameters:
            steamID (string) – SteamID that changed groups.
            oldGroup (string) – Previous group name.
            newGroup (string) – New group name.
            source (string) – Identifier of the origin.

        Realm:
            Shared
    ]]
--[[
        CanDeleteChar(characterID)

        Description:
            Determines whether a character can be deleted.

        Parameters:
            characterID (number) – Identifier of the character to delete.

        Realm:
            Client
    ]]

--[[
        CanPlayerCreateChar(client)

        Description:
            Checks if the given player is allowed to create a character.

        Parameters:
            client (Player) – Player requesting creation.

        Realm:
            Client
    ]]

--[[
        CanRunItemAction(itemTable, actionKey)

        Description:
            Called before running an item action to determine if it should execute.

        Parameters:
            itemTable (Item) – Item the action belongs to.
            actionKey (string) – Identifier of the action.

        Realm:
            Client
    ]]

--[[
        ChatAddText(text, ...)

        Description:
            Allows modification of chat text before it is displayed.

        Parameters:
            text (string) – Formatted markup string.
            ... – Additional arguments passed to the chat box.

        Realm:
            Client
    ]]

--[[
        ChatTextChanged(text)

        Description:
            Called whenever the chat entry text changes.

        Parameters:
            text (string) – Current text from the entry box.

        Realm:
            Client
    ]]

--[[
        ConfigureCharacterCreationSteps(panel)

        Description:
            Allows modules to add or reorder character creation steps.

        Parameters:
            panel (Panel) – Character creation panel.

        Realm:
            Client
    ]]

--[[
        CreateMenuButtons(definitions)

        Description:
            Provides a table to populate custom F1 menu buttons.

        Parameters:
            definitions (table) – Table to insert button callbacks into.

        Realm:
            Client
    ]]

--[[
        DisplayItemRelevantInfo(infoTable, client, item)

        Description:
            Allows adding extra lines to the item information panel.

        Parameters:
            infoTable (table) – Table to insert information into.
            client (Player) – Local player viewing the item.
            item (Item) – Item being inspected.

        Realm:
            Client
    ]]

--[[
        DrawLiliaModelView(panel, entity)

        Description:
            Called before drawing a model panel's entity.

        Parameters:
            panel (Panel) – The model panel being drawn.
            entity (Entity) – Entity about to be rendered.

        Realm:
            Client
    ]]
--[[
        EasyIconsLoaded()

        Description:
            Fired when the easy icon set has finished loading.

        Realm:
            Client
    ]]

--[[
        FinishChat()

        Description:
            Fired when the chat box is closed.

        Realm:
            Client
    ]]

--[[
        GetAttributeStartingMax(client, attributeKey)

        Description:
            Returns the maximum starting value for a character attribute.

        Parameters:
            client (Player) – Player configuring attributes.
            attributeKey (string) – Attribute identifier.

        Realm:
            Client
    ]]

--[[
        GetDisplayedDescription(player, noWrap)

        Description:
            Provides the description text shown on the scoreboard.

        Parameters:
            player (Player) – Player being displayed.
            noWrap (boolean) – Whether the text will be wrapped.

        Realm:
            Client
    ]]

--[[
        GetDisplayedName(player)

        Description:
            Provides the display name shown on the scoreboard.

        Parameters:
            player (Player) – Player being displayed.

        Realm:
            Client
    ]]

--[[
        GetMainMenuPosition(character)

        Description:
            Allows overriding the camera position for the main menu character model.

        Parameters:
            character (Character) – Character being displayed.

        Realm:
            Client
    ]]

--[[
        GetMaxPlayerChar(client)

        Description:
            Returns how many characters a player may create.

        Parameters:
            client (Player) – Player querying their limit.

        Realm:
            Client
    ]]

--[[
        GetMaxStartingAttributePoints(client, context)

        Description:
            Determines the total points available during attribute allocation.

        Parameters:
            client (Player) – Player allocating points.
            context (table) – Current creation context table.

        Realm:
            Client
    ]]

--[[
        ItemPaintOver(panel, item, w, h)

        Description:
            Allows drawing additional information over an item icon.

        Parameters:
            panel (Panel) – Icon panel being painted.
            item (Item) – Item being displayed.
            w (number) – Panel width.
            h (number) – Panel height.

        Realm:
            Client
    ]]

--[[
        LoadCharInformation()

        Description:
            Called when the character information window is opened.

        Realm:
            Client
    ]]

--[[
        LoadMainMenuInformation(info, character)

        Description:
            Populates additional information on the main menu panel.

        Parameters:
            info (table) – Table to add information to.
            character (Character) – Character being shown.

        Realm:
            Client
    ]]

--[[
        ModifyCharacterModel(entity, character)

        Description:
            Allows final adjustments to a character model before display.

        Parameters:
            entity (Entity) – Model entity being configured.
            character (Character|nil) – Character associated with the model.

        Realm:
            Client
    ]]

--[[
        OnCreateItemInteractionMenu(panel, menu, item)

        Description:
            Invoked when building an item's context menu.
            Return true to stop the default menu from being shown.

        Parameters:
            panel (Panel) – The item panel opening the menu.
            menu (Panel) – The Derma menu being built.
            item (Item) – Item the menu is for.

        Realm:
            Client
    ]]

--[[
        PlayerEndVoice(client)

        Description:
            Called when a voice panel should be removed for a player.

        Parameters:
            client (Player) – Player whose voice panel ended.

        Realm:
            Client
    ]]

--[[
        ResetCharacterPanel()

        Description:
            Resets the character selection or creation panel after use.

        Realm:
            Client
    ]]

--[[
        ShouldAllowScoreboardOverride(player, field)

        Description:
            Determines if scoreboard values like name, description, or model should be overridden.

        Parameters:
            player (Player) – Player being displayed.
            field (string) – Field being requested ("name", "desc", or "model").

        Realm:
            Client
    ]]

--[[
        ShouldMenuButtonShow(id)

        Description:
            Decides if a main menu button should be visible.

        Parameters:
            id (string) – Identifier of the button.

        Realm:
            Client
    ]]

--[[
        ShouldShowPlayerOnScoreboard(player)

        Description:
            Determines whether a player should appear on the scoreboard.

        Parameters:
            player (Player) – Player being evaluated.

        Realm:
            Client
    ]]

--[[
        ShowPlayerOptions(player, options)

        Description:
            Allows adding options to a player's scoreboard context menu.

        Parameters:
            player (Player) – Player the menu is for.
            options (table) – Table to insert options into.

        Realm:
            Client
    ]]

--[[
        SpawnlistContentChanged(icon)

        Description:
            Fired after an entry in the spawnlist is removed.

        Parameters:
            icon (Panel) – The spawnlist icon that was affected.

        Realm:
            Client
    ]]

--[[
        StartChat()

        Description:
            Fired when the chat box is opened.

        Realm:
            Client
    ]]
