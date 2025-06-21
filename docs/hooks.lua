--[[
    This file documents hooks triggered via hook.Run within
    gamemode/core/derma and gamemode/core/libraries/thirdparty.

    Generated automatically.
]]

--[[
        LoadCharInformation()

        Description:
            Called after the F1 menu panel is created so additional sections can be added.
            Populates the character information sections of the F1 menu.

        Realm:
            Client
        Example:
            -- Prints a message after the info panel is built.
            hook.Add("LoadCharInformation", "PrintLoad", function()
                print("F1 information sections loaded")
            end)
]]

--[[
        CreateMenuButtons(tabs)

        Description:
            Executed during menu creation allowing you to define custom tabs.
            Allows modules to insert additional tabs into the F1 menu.

        Parameters:
            tabs (table) – Table to add menu definitions to.

        Realm:
            Client
        Example:
            -- Inserts a custom "Help" tab into the F1 menu.
            hook.Add("CreateMenuButtons", "AddHelpTab", function(tabs)
                tabs.help = {text = "Help", panel = "liaHelp"}
            end)
]]

--[[
        DrawLiliaModelView(panel, entity)

        Description:
            Runs every frame when the character model panel draws.
            Lets code draw over the model view used in character menus.

        Parameters:
            panel (Panel) – The model panel being drawn.
            entity (Entity) – Model entity displayed.

        Realm:
            Client
        Example:
            -- Draws "Preview" text over the character model each frame.
            hook.Add("DrawLiliaModelView", "Watermark", function(panel, entity)
                draw.SimpleText("Preview", "Trebuchet24", 8, 8, color_white)
            end)
]]

--[[
        ShouldAllowScoreboardOverride(client, field)

        Description:
            Queries if a scoreboard field like the player's name or model may be replaced.
            Determines if a scoreboard field can be overridden.

        Parameters:
            client (Player) – Player being displayed.
            field (string) – Field name such as "name" or "model".

        Realm:
            Client
        Example:
            -- Allows other hooks to replace player names on the scoreboard.
            hook.Add("ShouldAllowScoreboardOverride", "OverrideNames", function(ply, field)
                if field == "name" then return true end
            end)
]]

--[[
        GetDisplayedName(client)

        Description:
            Provides the player name text shown in UI panels.
            Returns a display name for a player.

        Parameters:
            client (Player) – Player to query.

        Realm:
            Client
        Example:
            -- Displays player names with a VIP prefix.
            hook.Add("GetDisplayedName", "VIPPrefix", function(ply)
                return "[VIP] " .. ply:Nick()
            end)
]]

--[[
        PlayerEndVoice(client)

        Description:
            Fired when a player's voice indicator is removed from the HUD.
            Called when a player's voice panel is removed.

        Parameters:
            client (Player) – Player whose panel ended.

        Realm:
            Client
        Example:
            -- Announces in chat when someone stops using voice chat.
            hook.Add("PlayerEndVoice", "NotifyVoiceStop", function(ply)
                chat.AddText(ply:Nick() .. " stopped talking")
            end)
]]

--[[
        SpawnlistContentChanged(icon)

        Description:
            Triggered when a spawn icon is removed from the extended spawn menu.
            Fired when content is removed from the spawn menu.

        Parameters:
            icon (Panel) – Icon affected.

        Realm:
            Client
        Example:
            -- Lets you react when a spawn menu icon is removed.
            hook.Add("SpawnlistContentChanged", "IconRemoved", function(icon)
                print("Removed spawn icon", icon)
            end)
]]

--[[
        ItemPaintOver(panel, itemTable, width, height)

        Description:
            Gives a chance to draw additional info over item icons.
            Allows drawing over item icons in inventories.

        Parameters:
            panel (Panel) – Icon panel.
            itemTable (table) – Item data.
            width (number) – Panel width.
            height (number) – Panel height.

        Realm:
            Client
        Example:
            -- Draws the item quantity in the bottom-right corner.
            hook.Add("ItemPaintOver", "ShowQuantity", function(panel, item, w, h)
                draw.SimpleText(item.qty or 1, "DermaDefault", w - 4, h - 4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end)
]]

--[[
        OnCreateItemInteractionMenu(panel, menu, itemTable)

        Description:
            Allows extensions to populate the right-click menu for an item.
            Allows overriding the context menu for an item icon.

        Parameters:
            panel (Panel) – Icon panel.
            menu (Panel) – Menu being built.
            itemTable (table) – Item data.

        Realm:
            Client
        Example:
            -- Adds an "Inspect" choice to an item's context menu.
            hook.Add("OnCreateItemInteractionMenu", "AddInspect", function(panel, menu, item)
                menu:AddOption("Inspect", function() print("Inspecting", item.name) end)
            end)
]]

--[[
        CanRunItemAction(itemTable, action)

        Description:
            Determines whether an item action should be displayed.
            Determines whether a specific item action is allowed.

        Parameters:
            itemTable (table) – Item data.
            action (string) – Action key.

        Realm:
            Client

        Returns:
            boolean – True if the action can run.
        Example:
            -- Disables the drop action for all items.
            hook.Add("CanRunItemAction", "BlockDrop", function(item, action)
                if action == "drop" then return false end
            end)
]]

--[[
        GetMaxStartingAttributePoints(client, context)

        Description:
            Lets you change how many attribute points a new character receives.
            Retrieves the maximum attribute points available at character creation.

        Parameters:
            client (Player) – Viewing player.
            context (string) – Creation context.

        Realm:
            Client
        Example:
            -- Gives every new character 60 starting points.
            hook.Add("GetMaxStartingAttributePoints", "DoublePoints", function(client)
                return 60
            end)
]]

--[[
        GetAttributeStartingMax(client, attribute)

        Description:
            Sets a limit for a specific attribute at character creation.
            Returns the starting maximum for a specific attribute.

        Parameters:
            client (Player) – Viewing player.
            attribute (string) – Attribute identifier.

        Realm:
            Client
        Example:
            -- Limits the Strength attribute to a maximum of 20.
            hook.Add("GetAttributeStartingMax", "CapStrength", function(client, attribute)
                if attribute == "strength" then return 20 end
            end)
]]

--[[
        ShouldShowPlayerOnScoreboard(player)

        Description:
            Return false to omit players from the scoreboard.
            Determines if a player should appear on the scoreboard.

        Parameters:
            player (Player) – Player to test.

        Realm:
            Client
        Example:
            -- Stops bots from showing up on the scoreboard.
            hook.Add("ShouldShowPlayerOnScoreboard", "HideBots", function(ply)
                if ply:IsBot() then return false end
            end)
]]

--[[
        ShowPlayerOptions(player, options)

        Description:
            Populate the scoreboard context menu with extra options.
            Allows modules to add scoreboard options for a player.

        Parameters:
            player (Player) – Target player.
            options (table) – Options table to populate.

        Realm:
            Client
        Example:
            -- Adds a friendly "Wave" choice in the scoreboard menu.
            hook.Add("ShowPlayerOptions", "WaveOption", function(ply, options)
                options[#options + 1] = {name = "Wave", func = function() RunConsoleCommand("say", "/me waves to " .. ply:Nick()) end}
            end)
]]

--[[
        GetDisplayedDescription(player, isOOC)

        Description:
            Supplies the description text shown on the scoreboard.
            Returns the description text to display for a player.

        Parameters:
            player (Player) – Target player.
            isOOC (boolean) – Whether OOC description is requested.

        Realm:
            Client
        Example:
            -- Shows an OOC description when requested by the scoreboard.
            hook.Add("GetDisplayedDescription", "OOCDesc", function(ply, isOOC)
                if isOOC then return ply:GetNWString("oocDesc", "") end
            end)
]]

--[[
        ChatTextChanged(text)

        Description:
            Runs whenever the chat entry text is modified.
            Called whenever the chat entry text changes.

        Parameters:
            text (string) – Current text.

        Realm:
            Client
        Example:
            -- Displays a hint when the user types "/help".
            hook.Add("ChatTextChanged", "CommandHint", function(text)
                if text == "/help" then chat.AddText("Type /commands for commands list") end
            end)
]]

--[[
        FinishChat()

        Description:
            Fires when the chat box closes.
            Fired when the chat box is closed.

        Realm:
            Client
        Example:
            -- Prints a message whenever the chat box closes.
            hook.Add("FinishChat", "ChatClosed", function()
                print("Chat closed")
            end)
]]

--[[
        StartChat()

        Description:
            Fires when the chat box opens.
            Fired when the chat box is opened.

        Realm:
            Client
        Example:
            -- Plays a sound whenever the chat box opens.
            hook.Add("StartChat", "ChatOpened", function()
                surface.PlaySound("buttons/lightswitch2.wav")
            end)
]]

--[[
        ChatAddText(text, ...)

        Description:
            Allows modification of the markup before chat messages are printed.
            Allows modification of markup before chat text is shown.

        Parameters:
            text (string) – Base markup text.
            ... – Additional segments.

        Realm:
            Client

        Returns:
            string – Modified markup text.
        Example:
            -- Turns chat messages green before they appear.
            hook.Add("ChatAddText", "GreenSystem", function(text, ...)
                return Color(0,255,0), text, ...
            end)
]]

--[[
        DisplayItemRelevantInfo(extra, client, item)

        Description:
            Add extra lines to an item tooltip.
            Populates additional information for an item tooltip.

        Parameters:
            extra (table) – Info table to fill.
            client (Player) – Local player.
            item (table) – Item being displayed.

        Realm:
            Client
        Example:
            -- Adds the item's weight to its tooltip.
            hook.Add("DisplayItemRelevantInfo", "ShowWeight", function(extra, client, item)
                extra[#extra + 1] = "Weight: " .. (item.weight or 0)
            end)
]]

--[[
        GetMainMenuPosition(character)

        Description:
            Returns the camera position and angle for the main menu character preview.
            Provides the camera position and angle for the main menu model.

        Parameters:
            character (Character) – Character being viewed.

        Realm:
            Client

        Returns:
            Vector, Angle – Position and angle values.
        Example:
            -- Positions the main menu camera with a slight offset.
            hook.Add("GetMainMenuPosition", "OffsetCharView", function(character)
                return Vector(30, 10, 60), Angle(0, 30, 0)
            end)
]]

--[[
        CanDeleteChar(characterID)

        Description:
            Return false here to prevent character deletion.
            Determines if a character can be deleted.

        Parameters:
            characterID (number) – Identifier of the character.

        Realm:
            Client

        Returns:
            boolean – False to disallow deletion.
        Example:
            -- Blocks deletion of the first character slot.
            hook.Add("CanDeleteChar", "ProtectSlot1", function(id)
                if id == 1 then return false end
            end)
]]

--[[
        LoadMainMenuInformation(info, character)

        Description:
            Lets modules insert additional information on the main menu info panel.
            Allows modules to populate extra information on the main menu panel.

        Parameters:
            info (table) – Table to receive information.
            character (Character) – Selected character.

        Realm:
            Client
        Example:
            -- Adds the character's faction to the menu info panel.
            hook.Add("LoadMainMenuInformation", "AddFactionInfo", function(info, character)
                info.faction = character:getFaction() or "Citizen"
            end)
]]

--[[
        CanPlayerCreateChar(player)

        Description:
            Checks if the local player may start creating a character.
            Determines if the player may create a new character.

        Parameters:
            player (Player) – Local player.

        Realm:
            Client

        Returns:
            boolean – False to disallow creation.
        Example:
            -- Restricts character creation to admins only.
            hook.Add("CanPlayerCreateChar", "AdminsOnly", function(ply)
                if not ply:IsAdmin() then return false end
            end)
]]

--[[
        ModifyCharacterModel(entity, character)

        Description:
            Lets you edit the clientside model used in the main menu.
            Allows adjustments to the character model in menus.

        Parameters:
            entity (Entity) – Model entity.
            character (Character) – Character data.

        Realm:
            Client
        Example:
            -- Changes a bodygroup on the preview model.
            hook.Add("ModifyCharacterModel", "ApplyBodygroup", function(ent, character)
                ent:SetBodygroup(2, 1)
            end)
]]

--[[
        ConfigureCharacterCreationSteps(panel)

        Description:
            Add or reorder steps in the character creation flow.
            Lets modules alter the character creation step layout.

        Parameters:
            panel (Panel) – Creation panel.

        Realm:
            Client
        Example:
            -- Adds a custom "background" step to the character creator.
            hook.Add("ConfigureCharacterCreationSteps", "InsertBackground", function(panel)
                panel:AddStep("background")
            end)
]]

--[[
        GetMaxPlayerChar(player)

        Description:
            Override to change how many characters a player can have.
            Returns the maximum number of characters a player can have.

        Parameters:
            player (Player) – Local player.

        Realm:
            Client

        Returns:
            number – Maximum character count.
        Example:
            -- Gives admins extra character slots.
            hook.Add("GetMaxPlayerChar", "AdminSlots", function(ply)
                return ply:IsAdmin() and 10 or 5
            end)
]]

--[[
        ShouldMenuButtonShow(name)

        Description:
            Return false and a reason to hide buttons on the main menu.
            Determines if a button should be visible on the main menu.

        Parameters:
            name (string) – Button identifier.

        Realm:
            Client

        Returns:
            boolean, string – False and reason to hide.
        Example:
            -- Hides the delete button when the feature is locked.
            hook.Add("ShouldMenuButtonShow", "HideDelete", function(name)
                if name == "delete" then return false, "Locked" end
            end)
]]

--[[
        ResetCharacterPanel()

        Description:
            Called when the character creation panel should reset.
            Called to reset the character creation panel.

        Realm:
            Client
        Example:
            -- Notifies whenever the creation panel resets.
            hook.Add("ResetCharacterPanel", "ClearFields", function()
                print("Character creator reset")
            end)
]]

--[[
        EasyIconsLoaded()

        Description:
            Notifies when the EasyIcons font sheet has loaded.
            Fired when the EasyIcons library has loaded.

        Realm:
            Client
        Example:
            -- Prints a message once the EasyIcons font is loaded.
            hook.Add("EasyIconsLoaded", "Notify", function()
                print("EasyIcons ready")
            end)
]]

--[[
        CAMI.OnUsergroupRegistered(usergroup, source)

        Description:
            Called when CAMI registers a new usergroup.
            CAMI notification that a usergroup was registered.

        Parameters:
            usergroup (table) – Registered usergroup data.
            source (string) – Source identifier.

        Realm:
            Shared
        Example:
            -- Logs newly registered CAMI usergroups.
            hook.Add("CAMI.OnUsergroupRegistered", "LogGroup", function(group)
                print("Registered group:", group.Name)
            end)
]]

--[[
        CAMI.OnUsergroupUnregistered(usergroup, source)

        Description:
            Called when a usergroup is removed from CAMI.
            CAMI notification that a usergroup was removed.

        Parameters:
            usergroup (table) – Unregistered usergroup data.
            source (string) – Source identifier.

        Realm:
            Shared
        Example:
            -- Logs whenever a usergroup is removed from CAMI.
            hook.Add("CAMI.OnUsergroupUnregistered", "LogRemoval", function(group)
                print("Removed group:", group.Name)
            end)
]]

--[[
        CAMI.OnPrivilegeRegistered(privilege)

        Description:
            Fired when a privilege is created in CAMI.
            CAMI notification that a privilege was registered.

        Parameters:
            privilege (table) – Privilege data.

        Realm:
            Shared
        Example:
            -- Reports when a new CAMI privilege is registered.
            hook.Add("CAMI.OnPrivilegeRegistered", "LogPrivilege", function(priv)
                print("Registered privilege:", priv.Name)
            end)
]]

--[[
        CAMI.OnPrivilegeUnregistered(privilege)

        Description:
            Fired when a privilege is removed from CAMI.
            CAMI notification that a privilege was unregistered.

        Parameters:
            privilege (table) – Privilege data.

        Realm:
            Shared
        Example:
            -- Reports when a CAMI privilege is removed.
            hook.Add("CAMI.OnPrivilegeUnregistered", "LogPrivRemoval", function(priv)
                print("Removed privilege:", priv.Name)
            end)
]]

--[[
        CAMI.PlayerHasAccess(handler, actor, privilegeName, callback, target, extra)

        Description:
            Allows an override of player privilege checks.
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
        Example:
            -- Lets superadmins bypass privilege checks.
            hook.Add("CAMI.PlayerHasAccess", "AllowSuperadmins", function(_, actor, priv, cb)
                if actor:IsSuperAdmin() then cb(true) return true end
            end)
]]

--[[
        CAMI.SteamIDHasAccess(handler, steamID, privilegeName, callback, targetID, extra)

        Description:
            Allows an override of SteamID-based privilege checks.
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
        Example:
            -- Grants access for a specific SteamID.
            hook.Add("CAMI.SteamIDHasAccess", "AllowSteamID", function(_, steamID, priv, cb)
                if steamID == "STEAM_0:1:1" then cb(true) return true end
            end)
]]

--[[
        CAMI.PlayerUsergroupChanged(player, oldGroup, newGroup, source)

        Description:
            Notification that a player's group changed.
            Fired when a player's usergroup has changed.

        Parameters:
            player (Player) – Affected player.
            oldGroup (string) – Previous group.
            newGroup (string) – New group.
            source (string) – Source identifier.

        Realm:
            Shared
        Example:
            -- Announces when a player's usergroup changes.
            hook.Add("CAMI.PlayerUsergroupChanged", "AnnounceChange", function(ply, old, new)
                print(ply:Nick() .. " moved from " .. old .. " to " .. new)
            end)
]]

--[[
        CAMI.SteamIDUsergroupChanged(steamID, oldGroup, newGroup, source)

        Description:
            Notification that a SteamID's group changed.
            Fired when a SteamID's usergroup has changed.

        Parameters:
            steamID (string) – Affected SteamID.
            oldGroup (string) – Previous group.
            newGroup (string) – New group.
            source (string) – Source identifier.

        Realm:
            Shared
        Example:
            -- Logs usergroup changes by SteamID.
            hook.Add("CAMI.SteamIDUsergroupChanged", "LogSIDChange", function(sid, old, new)
                print(sid .. " changed from " .. old .. " to " .. new)
            end)
]]--[[
        TooltipLayout(panel)

        Description:
            Customize tooltip sizing and layout before it appears.

        Parameters:
            panel (Panel) – Tooltip panel being laid out.

        Realm:
            Client
        Example:
            -- Sets a fixed width for tooltips before layout.
            hook.Add("TooltipLayout", "FixedWidth", function(panel)
                panel:SetWide(200)
            end)
]]
--[[
        TooltipPaint(panel, width, height)

        Description:
            Draw custom visuals on the tooltip, returning true skips default painting.

        Parameters:
            panel (Panel) – Tooltip panel.
            width (number) – Panel width.
            height (number) – Panel height.

        Realm:
            Client
        Example:
            -- Adds a dark background and skips default paint.
            hook.Add("TooltipPaint", "BlurBackground", function(panel, w, h)
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(0, 0, w, h)
                return true
            end)
]]
--[[
        TooltipInitialize(panel, target)

        Description:
            Runs when a tooltip is opened for a panel.

        Parameters:
            panel (Panel) – Tooltip panel.
            target (Panel) – Target panel that opened the tooltip.

        Realm:
            Client
        Example:
            -- Fades tooltips in when they are created.
            hook.Add("TooltipInitialize", "SetupFade", function(panel, target)
                panel:SetAlpha(0)
                panel:AlphaTo(255, 0.2, 0)
            end)
]]

