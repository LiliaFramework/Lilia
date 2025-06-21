--[[
    This file documents hooks triggered via hook.Run within
    gamemode/core/derma and gamemode/core/libraries/thirdparty.

    Generated automatically.
]]

--[[
        LoadCharInformation()

        Description:
            Populates the character information sections of the F1 menu.

        Realm:
            Client
]]

--[[
        CreateMenuButtons(tabs)

        Description:
            Allows modules to insert additional tabs into the F1 menu.

        Parameters:
            tabs (table) – Table to add menu definitions to.

        Realm:
            Client
]]

--[[
        DrawLiliaModelView(panel, entity)

        Description:
            Lets code draw over the model view used in character menus.

        Parameters:
            panel (Panel) – The model panel being drawn.
            entity (Entity) – Model entity displayed.

        Realm:
            Client
]]

--[[
        ShouldAllowScoreboardOverride(client, field)

        Description:
            Determines if a scoreboard field can be overridden.

        Parameters:
            client (Player) – Player being displayed.
            field (string) – Field name such as "name" or "model".

        Realm:
            Client
]]

--[[
        GetDisplayedName(client)

        Description:
            Returns a display name for a player.

        Parameters:
            client (Player) – Player to query.

        Realm:
            Client
]]

--[[
        PlayerEndVoice(client)

        Description:
            Called when a player's voice panel is removed.

        Parameters:
            client (Player) – Player whose panel ended.

        Realm:
            Client
]]

--[[
        SpawnlistContentChanged(icon)

        Description:
            Fired when content is removed from the spawn menu.

        Parameters:
            icon (Panel) – Icon affected.

        Realm:
            Client
]]

--[[
        ItemPaintOver(panel, itemTable, width, height)

        Description:
            Allows drawing over item icons in inventories.

        Parameters:
            panel (Panel) – Icon panel.
            itemTable (table) – Item data.
            width (number) – Panel width.
            height (number) – Panel height.

        Realm:
            Client
]]

--[[
        OnCreateItemInteractionMenu(panel, menu, itemTable)

        Description:
            Allows overriding the context menu for an item icon.

        Parameters:
            panel (Panel) – Icon panel.
            menu (Panel) – Menu being built.
            itemTable (table) – Item data.

        Realm:
            Client
]]

--[[
        CanRunItemAction(itemTable, action)

        Description:
            Determines whether a specific item action is allowed.

        Parameters:
            itemTable (table) – Item data.
            action (string) – Action key.

        Realm:
            Client

        Returns:
            boolean – True if the action can run.
]]

--[[
        GetMaxStartingAttributePoints(client, context)

        Description:
            Retrieves the maximum attribute points available at character creation.

        Parameters:
            client (Player) – Viewing player.
            context (string) – Creation context.

        Realm:
            Client
]]

--[[
        GetAttributeStartingMax(client, attribute)

        Description:
            Returns the starting maximum for a specific attribute.

        Parameters:
            client (Player) – Viewing player.
            attribute (string) – Attribute identifier.

        Realm:
            Client
]]

--[[
        ShouldShowPlayerOnScoreboard(player)

        Description:
            Determines if a player should appear on the scoreboard.

        Parameters:
            player (Player) – Player to test.

        Realm:
            Client
]]

--[[
        ShowPlayerOptions(player, options)

        Description:
            Allows modules to add scoreboard options for a player.

        Parameters:
            player (Player) – Target player.
            options (table) – Options table to populate.

        Realm:
            Client
]]

--[[
        GetDisplayedDescription(player, isOOC)

        Description:
            Returns the description text to display for a player.

        Parameters:
            player (Player) – Target player.
            isOOC (boolean) – Whether OOC description is requested.

        Realm:
            Client
]]

--[[
        ChatTextChanged(text)

        Description:
            Called whenever the chat entry text changes.

        Parameters:
            text (string) – Current text.

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
        StartChat()

        Description:
            Fired when the chat box is opened.

        Realm:
            Client
]]

--[[
        ChatAddText(text, ...)

        Description:
            Allows modification of markup before chat text is shown.

        Parameters:
            text (string) – Base markup text.
            ... – Additional segments.

        Realm:
            Client

        Returns:
            string – Modified markup text.
]]

--[[
        DisplayItemRelevantInfo(extra, client, item)

        Description:
            Populates additional information for an item tooltip.

        Parameters:
            extra (table) – Info table to fill.
            client (Player) – Local player.
            item (table) – Item being displayed.

        Realm:
            Client
]]

--[[
        GetMainMenuPosition(character)

        Description:
            Provides the camera position and angle for the main menu model.

        Parameters:
            character (Character) – Character being viewed.

        Realm:
            Client

        Returns:
            Vector, Angle – Position and angle values.
]]

--[[
        CanDeleteChar(characterID)

        Description:
            Determines if a character can be deleted.

        Parameters:
            characterID (number) – Identifier of the character.

        Realm:
            Client

        Returns:
            boolean – False to disallow deletion.
]]

--[[
        LoadMainMenuInformation(info, character)

        Description:
            Allows modules to populate extra information on the main menu panel.

        Parameters:
            info (table) – Table to receive information.
            character (Character) – Selected character.

        Realm:
            Client
]]

--[[
        CanPlayerCreateChar(player)

        Description:
            Determines if the player may create a new character.

        Parameters:
            player (Player) – Local player.

        Realm:
            Client

        Returns:
            boolean – False to disallow creation.
]]

--[[
        ModifyCharacterModel(entity, character)

        Description:
            Allows adjustments to the character model in menus.

        Parameters:
            entity (Entity) – Model entity.
            character (Character) – Character data.

        Realm:
            Client
]]

--[[
        ConfigureCharacterCreationSteps(panel)

        Description:
            Lets modules alter the character creation step layout.

        Parameters:
            panel (Panel) – Creation panel.

        Realm:
            Client
]]

--[[
        GetMaxPlayerChar(player)

        Description:
            Returns the maximum number of characters a player can have.

        Parameters:
            player (Player) – Local player.

        Realm:
            Client

        Returns:
            number – Maximum character count.
]]

--[[
        ShouldMenuButtonShow(name)

        Description:
            Determines if a button should be visible on the main menu.

        Parameters:
            name (string) – Button identifier.

        Realm:
            Client

        Returns:
            boolean, string – False and reason to hide.
]]

--[[
        ResetCharacterPanel()

        Description:
            Called to reset the character creation panel.

        Realm:
            Client
]]

--[[
        EasyIconsLoaded()

        Description:
            Fired when the EasyIcons library has loaded.

        Realm:
            Client
]]

--[[
        CAMI.OnUsergroupRegistered(usergroup, source)

        Description:
            CAMI notification that a usergroup was registered.

        Parameters:
            usergroup (table) – Registered usergroup data.
            source (string) – Source identifier.

        Realm:
            Shared
]]

--[[
        CAMI.OnUsergroupUnregistered(usergroup, source)

        Description:
            CAMI notification that a usergroup was removed.

        Parameters:
            usergroup (table) – Unregistered usergroup data.
            source (string) – Source identifier.

        Realm:
            Shared
]]

--[[
        CAMI.OnPrivilegeRegistered(privilege)

        Description:
            CAMI notification that a privilege was registered.

        Parameters:
            privilege (table) – Privilege data.

        Realm:
            Shared
]]

--[[
        CAMI.OnPrivilegeUnregistered(privilege)

        Description:
            CAMI notification that a privilege was unregistered.

        Parameters:
            privilege (table) – Privilege data.

        Realm:
            Shared
]]

--[[
        CAMI.PlayerHasAccess(handler, actor, privilegeName, callback, target, extra)

        Description:
            Allows external libraries to override privilege checks.

        Parameters:
            handler (function) – Default handler.
            actor (Player) – Player requesting access.
            privilegeName (string) – Privilege identifier.
            callback (function) – Callback to receive result.
            target (Player) – Optional target player.
            extra (table) – Extra information table.

        Realm:
            Shared
]]

--[[
        CAMI.SteamIDHasAccess(handler, steamID, privilegeName, callback, targetID, extra)

        Description:
            Similar to PlayerHasAccess but for SteamIDs.

        Parameters:
            handler (function) – Default handler.
            steamID (string) – SteamID to check.
            privilegeName (string) – Privilege identifier.
            callback (function) – Callback to receive result.
            targetID (string) – Target SteamID.
            extra (table) – Extra information table.

        Realm:
            Shared
]]

--[[
        CAMI.PlayerUsergroupChanged(player, oldGroup, newGroup, source)

        Description:
            Fired when a player's usergroup has changed.

        Parameters:
            player (Player) – Affected player.
            oldGroup (string) – Previous group.
            newGroup (string) – New group.
            source (string) – Source identifier.

        Realm:
            Shared
]]

--[[
        CAMI.SteamIDUsergroupChanged(steamID, oldGroup, newGroup, source)

        Description:
            Fired when a SteamID's usergroup has changed.

        Parameters:
            steamID (string) – Affected SteamID.
            oldGroup (string) – Previous group.
            newGroup (string) – New group.
            source (string) – Source identifier.

        Realm:
            Shared
]]
