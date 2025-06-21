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

--[[
        PlayerLoadout(client)

        Description:
            Runs when a player spawns and equips items.
            Allows modification of the default loadout.

        Parameters:
            client (Player) – Player being loaded out.

        Realm:
            Server
        Example:
            -- Gives players a crowbar on spawn.
            hook.Add("PlayerLoadout", "GiveCrowbar", function(ply)
                ply:Give("weapon_crowbar")
            end)
]]

--[[
        PlayerShouldPermaKill(client, inflictor, attacker)

        Description:
            Determines if a player's death should permanently kill their character.
            Return true to mark the character for deletion.

        Parameters:
            client (Player) – Player that died.
            inflictor (Entity) – Damage inflictor.
            attacker (Entity) – Damage attacker.

        Realm:
            Server
        Example:
            -- Prevent permanent death from fall damage.
            hook.Add("PlayerShouldPermaKill", "NoFallPK", function(ply, inflictor)
                if inflictor == game.GetWorld() then return false end
            end)
]]

--[[
        CanPlayerDropItem(client, item)

        Description:
            Checks if a player may drop an item.
            Return false to block dropping.

        Parameters:
            client (Player) – Player attempting to drop.
            item (table) – Item being dropped.

        Realm:
            Server
        Example:
            -- Disallow dropping locked items.
            hook.Add("CanPlayerDropItem", "NoLockedDrop", function(ply, item)
                if item.locked then return false end
            end)
]]

--[[
        CanPlayerTakeItem(client, item)

        Description:
            Determines if a player can pick up an item.
            Return false to prevent taking.

        Parameters:
            client (Player) – Player attempting pickup.
            item (table) – Item in question.

        Realm:
            Server
        Example:
            -- Block taking admin items.
            hook.Add("CanPlayerTakeItem", "NoAdminPickup", function(ply, item)
                if item.adminOnly then return false end
            end)
]]

--[[
        CanPlayerEquipItem(client, item)

        Description:
            Queries if a player can equip an item.
            Returning false stops the equip action.

        Parameters:
            client (Player) – Player equipping.
            item (table) – Item to equip.

        Realm:
            Server
        Example:
            -- Allow equipping only if level requirement met.
            hook.Add("CanPlayerEquipItem", "CheckLevel", function(ply, item)
                if item.minLevel and ply:getChar():getAttrib("level", 0) < item.minLevel then
                    return false
                end
            end)
]]

--[[
        CanPlayerUnequipItem(client, item)

        Description:
            Called before an item is unequipped.
            Return false to keep the item equipped.

        Parameters:
            client (Player) – Player unequipping.
            item (table) – Item being unequipped.

        Realm:
            Server
        Example:
            -- Prevent unequipping cursed gear.
            hook.Add("CanPlayerUnequipItem", "Cursed", function(ply, item)
                if item.cursed then return false end
            end)
]]

--[[
        PostPlayerSay(client, message, chatType, anonymous)

        Description:
            Runs after chat messages are processed.
            Allows reacting to player chat.

        Parameters:
            client (Player) – Speaking player.
            message (string) – Chat text.
            chatType (string) – Chat channel.
            anonymous (boolean) – Whether the message was anonymous.

        Realm:
            Server
        Example:
            -- Log all OOC chat.
            hook.Add("PostPlayerSay", "LogOOC", function(ply, msg, chatType)
                if chatType == "ooc" then print("[OOC]", ply:Nick(), msg) end
            end)
]]

--[[
        ShouldSpawnClientRagdoll(client)

        Description:
            Decides if a corpse ragdoll should spawn for a player.
            Return false to skip ragdoll creation.

        Parameters:
            client (Player) – Player that died.

        Realm:
            Server
        Example:
            -- Disable ragdolls for bots.
            hook.Add("ShouldSpawnClientRagdoll", "NoBotRagdoll", function(ply)
                if ply:IsBot() then return false end
            end)
]]

--[[
        SaveData()

        Description:
            Called when the framework saves persistent data.
            Modules can store custom information here.

        Realm:
            Server
        Example:
            -- Save a timestamp to file.
            hook.Add("SaveData", "RecordTime", function()
                file.Write("lastsave.txt", os.time())
            end)
]]

--[[
        PersistenceSave()

        Description:
            Fires when map persistence should be written to disk.
            Allows adding extra persistent entities.

        Realm:
            Server
        Example:
            hook.Add("PersistenceSave", "Notice", function()
                print("Saving persistent entities")
            end)
]]

--[[
        LoadData()

        Description:
            Triggered when stored data should be loaded.
            Modules can restore custom information here.

        Realm:
            Server
        Example:
            hook.Add("LoadData", "LoadExtras", function()
                print("Loading custom data")
            end)
]]

--[[
        PostLoadData()

        Description:
            Called after all persistent data has loaded.
            Useful for post-processing.

        Realm:
            Server
        Example:
            hook.Add("PostLoadData", "Ready", function()
                print("Data fully loaded")
            end)
]]

--[[
        ShouldDataBeSaved()

        Description:
            Queries if data saving should occur during shutdown.
            Return false to cancel saving.

        Realm:
            Server
        Example:
            -- Skip saving during quick restarts.
            hook.Add("ShouldDataBeSaved", "NoSave", function()
                return game.IsDedicated() and os.getenv("NOSAVE")
            end)
]]

--[[
        OnCharDisconnect(client, character)

        Description:
            Called when a player's character disconnects.
            Provides a last chance to handle data.

        Parameters:
            client (Player) – Disconnecting player.
            character (Character) – Their character.

        Realm:
            Server
        Example:
            hook.Add("OnCharDisconnect", "Goodbye", function(ply, char)
                print(char:getName(), "has left")
            end)
]]

--[[
        SetupBotPlayer(client)

        Description:
            Initializes a bot's character when it first joins.
            Allows custom bot setup.

        Parameters:
            client (Player) – Bot player.

        Realm:
            Server
        Example:
            hook.Add("SetupBotPlayer", "WelcomeBot", function(bot)
                bot:ChatPrint("Beep boop!")
            end)
]]

--[[
        PlayerLiliaDataLoaded(client)

        Description:
            Fired after a player's personal data has loaded.
            Useful for syncing additional info.

        Parameters:
            client (Player) – Player that loaded data.

        Realm:
            Server
        Example:
            hook.Add("PlayerLiliaDataLoaded", "SendWelcome", function(ply)
                ply:ChatPrint("Data loaded")
            end)
]]

--[[
        PostPlayerInitialSpawn(client)

        Description:
            Runs after the player entity has spawned and data is ready.
            Allows post-initialization logic.

        Parameters:
            client (Player) – Newly spawned player.

        Realm:
            Server
        Example:
            hook.Add("PostPlayerInitialSpawn", "Greet", function(ply)
                print("Hello", ply:Nick())
            end)
]]

--[[
        FactionOnLoadout(client)

        Description:
            Gives factions a chance to modify player loadouts.
            Runs before weapons are equipped.

        Parameters:
            client (Player) – Player being equipped.

        Realm:
            Server
        Example:
            hook.Add("FactionOnLoadout", "GiveRadio", function(ply)
                if ply:getChar():getFaction() == "police" then
                    ply:Give("weapon_radio")
                end
            end)
]]

--[[
        ClassOnLoadout(client)

        Description:
            Allows classes to modify the player's starting gear.
            Executed prior to PostPlayerLoadout.

        Parameters:
            client (Player) – Player being equipped.

        Realm:
            Server
        Example:
            hook.Add("ClassOnLoadout", "MedicItems", function(ply)
                if ply:getChar():getClass() == "medic" then
                    ply:Give("medkit")
                end
            end)
]]

--[[
        PostPlayerLoadout(client)

        Description:
            Called after the player has been equipped.
            Last chance to modify the loadout.

        Parameters:
            client (Player) – Player loaded out.

        Realm:
            Server
        Example:
            hook.Add("PostPlayerLoadout", "SetColor", function(ply)
                ply:SetPlayerColor(Vector(0,1,0))
            end)
]]

--[[
        FactionPostLoadout(client)

        Description:
            Runs after faction loadout logic completes.
            Allows post-loadout tweaks.

        Parameters:
            client (Player) – Player affected.

        Realm:
            Server
        Example:
            hook.Add("FactionPostLoadout", "Shout", function(ply)
                if ply:getChar():getFaction() == "soldier" then
                    ply:EmitSound("npc/combine_soldier/gear6.wav")
                end
            end)
]]

--[[
        ClassPostLoadout(client)

        Description:
            Runs after class loadout logic completes.
            Allows post-loadout tweaks for classes.

        Parameters:
            client (Player) – Player affected.

        Realm:
            Server
        Example:
            hook.Add("ClassPostLoadout", "Pose", function(ply)
                ply:ConCommand("act muscle")
            end)
]]

--[[
        GetDefaultInventoryType(character)

        Description:
            Returns the inventory type used for new characters.
            Modules can override to provide custom types.

        Parameters:
            character (Character) – Character being created.

        Realm:
            Server
        Example:
            hook.Add("GetDefaultInventoryType", "UseGrid", function()
                return "GridInv"
            end)
]]

--[[
        ShouldDeleteSavedItems()

        Description:
            Decides whether saved persistent items should be deleted on load.
            Return true to wipe them from the database.

        Realm:
            Server
        Example:
            hook.Add("ShouldDeleteSavedItems", "ClearDrops", function()
                return false
            end)
]]

--[[
        OnSavedItemLoaded(items)

        Description:
            Called after map items have been loaded from storage.
            Provides the table of created items.

        Parameters:
            items (table) – Loaded item entities.

        Realm:
            Server
        Example:
            hook.Add("OnSavedItemLoaded", "PrintCount", function(items)
                print("Loaded", #items, "items")
            end)
]]

--[[
        ShouldDrawEntityInfo(entity)

        Description:
            Determines if world-space info should be rendered for an entity.
            Return false to hide the tooltip.

        Parameters:
            entity (Entity) – Entity being considered.

        Realm:
            Client
        Example:
            hook.Add("ShouldDrawEntityInfo", "HideNPCs", function(ent)
                if ent:IsNPC() then return false end
            end)
]]

--[[
        DrawEntityInfo(entity, alpha, position)

        Description:
            Allows custom drawing of entity information in the world.
            Drawn every frame while visible.

        Parameters:
            entity (Entity) – Entity to draw info for.
            alpha (number) – Current alpha value.
            position (table) – Screen position table.

        Realm:
            Client
        Example:
            hook.Add("DrawEntityInfo", "LabelProps", function(ent, a, pos)
                draw.SimpleText(ent:GetClass(), "DermaDefault", pos.x, pos.y, Color(255,255,255,a))
            end)
]]

--[[
        GetInjuredText(client)

        Description:
            Provides the health status text and color for a player.
            Return a table with text and color values.

        Parameters:
            client (Player) – Player to check.

        Realm:
            Client
        Example:
            hook.Add("GetInjuredText", "SimpleHealth", function(ply)
                if ply:Health() <= 20 then return {"Critical", Color(255,0,0)} end
            end)
]]

--[[
        ShouldDrawPlayerInfo(player)

        Description:
            Determines if character info should draw above a player.
            Return false to suppress drawing.

        Parameters:
            player (Player) – Player being rendered.

        Realm:
            Client
        Example:
            hook.Add("ShouldDrawPlayerInfo", "HideLocal", function(ply)
                if ply == LocalPlayer() then return false end
            end)
]]

--[[
        DrawCharInfo(player, character, info)

        Description:
            Allows modules to add lines to the character info display.
            Called when building the info table.

        Parameters:
            player (Player) – Player being displayed.
            character (Character) – Their character data.
            info (table) – Table to add lines to.

        Realm:
            Client
        Example:
            hook.Add("DrawCharInfo", "JobTitle", function(ply, char, info)
                info[#info + 1] = {"Job: " .. (char:getClass() or "None")}
            end)
]]

--[[
        ItemShowEntityMenu(entity)

        Description:
            Opens the context menu for a world item when used.
            Allows replacing the default menu.

        Parameters:
            entity (Entity) – Item entity clicked.

        Realm:
            Client
        Example:
            hook.Add("ItemShowEntityMenu", "QuickTake", function(ent)
                print("Opening menu for", ent)
            end)
]]

--[[
        PreLiliaLoaded()

        Description:
            Fired just before the client finishes loading the framework.
            Useful for setup tasks.

        Realm:
            Client
        Example:
            hook.Add("PreLiliaLoaded", "Prep", function()
                print("About to finish loading")
            end)
]]

--[[
        LiliaLoaded()

        Description:
            Indicates the client finished initializing the framework.
            Modules can start creating panels here.

        Realm:
            Client
        Example:
            hook.Add("LiliaLoaded", "Ready", function()
                print("Lilia client ready")
            end)
]]

--[[
        InventoryDataChanged(inventory, key, oldValue, value)

        Description:
            Notifies when inventory metadata changes.
            Provides old and new values.

        Parameters:
            inventory (table) – Inventory affected.
            key (string) – Data key.
            oldValue (any) – Previous value.
            value (any) – New value.

        Realm:
            Client
        Example:
            hook.Add("InventoryDataChanged", "TrackWeight", function(inv, k, old, new)
                if k == "weight" then print("Weight changed to", new) end
            end)
]]

--[[
        ItemInitialized(item)

        Description:
            Called when a new item instance is created clientside.
            Allows additional setup for the item.

        Parameters:
            item (table) – Item created.

        Realm:
            Client
        Example:
            hook.Add("ItemInitialized", "PrintID", function(item)
                print("Created item", item.uniqueID)
            end)
]]

--[[
        InventoryInitialized(inventory)

        Description:
            Fired when an inventory instance finishes loading.
            Modules may modify it here.

        Parameters:
            inventory (table) – Inventory initialized.

        Realm:
            Client
        Example:
            hook.Add("InventoryInitialized", "AnnounceInv", function(inv)
                print("Inventory", inv:getID(), "ready")
            end)
]]

--[[
        InventoryItemAdded(inventory, item)

        Description:
            Invoked when an item is placed into an inventory.
            Lets code react to the addition.

        Parameters:
            inventory (table) – Inventory receiving the item.
            item (table) – Item added.

        Realm:
            Client
        Example:
            hook.Add("InventoryItemAdded", "NotifyAdd", function(inv, item)
                print("Added", item.name)
            end)
]]

--[[
        InventoryItemRemoved(inventory, item)

        Description:
            Called when an item is removed from an inventory.
            Runs after the item table is updated.

        Parameters:
            inventory (table) – Inventory modified.
            item (table) – Item removed.

        Realm:
            Client
        Example:
            hook.Add("InventoryItemRemoved", "NotifyRemove", function(inv, item)
                print("Removed", item.name)
            end)
]]

--[[
        InventoryDeleted(inventory)

        Description:
            Signals that an inventory was deleted clientside.
            Allows cleanup of references.

        Parameters:
            inventory (table) – Deleted inventory.

        Realm:
            Client
        Example:
            hook.Add("InventoryDeleted", "Clear", function(inv)
                print("Inventory", inv:getID(), "deleted")
            end)
]]

--[[
        ItemDeleted(item)

        Description:
            Fired when an item is removed entirely.
            Modules should clear any cached data.

        Parameters:
            item (table) – Item that was deleted.

        Realm:
            Client
        Example:
            hook.Add("ItemDeleted", "Log", function(item)
                print("Item", item.uniqueID, "gone")
            end)
]]

--[[
        OnCharVarChanged(character, key, oldValue, value)

        Description:
            Runs when a networked character variable changes.
            Gives both old and new values.

        Parameters:
            character (Character) – Affected character.
            key (string) – Variable name.
            oldValue (any) – Previous value.
            value (any) – New value.

        Realm:
            Client
        Example:
            hook.Add("OnCharVarChanged", "WatchMoney", function(char, k, old, new)
                if k == "money" then print("Money changed", new) end
            end)
]]

--[[
        OnCharLocalVarChanged(character, key, oldVar, value)

        Description:
            Similar to OnCharVarChanged but for local-only variables.
            Called after the table updates.

        Parameters:
            character (Character) – Affected character.
            key (string) – Variable name.
            oldVar (any) – Old value.
            value (any) – New value.

        Realm:
            Client
        Example:
            hook.Add("OnCharLocalVarChanged", "WatchFlags", function(char, k, old, new)
                if k == "flags" then print("Flags changed") end
            end)
]]

--[[
        ItemDataChanged(item, key, oldValue, value)

        Description:
            Called when item data values change clientside.
            Provides both the old and new values.

        Parameters:
            item (table) – Item modified.
            key (string) – Key that changed.
            oldValue (any) – Previous value.
            value (any) – New value.

        Realm:
            Client
        Example:
            hook.Add("ItemDataChanged", "TrackDurability", function(item, key)
                if key == "durability" then print("New durability", item.data[key]) end
            end)
]]

--[[
        ItemQuantityChanged(item, oldQuantity, quantity)

        Description:
            Runs when an item's quantity value updates.
            Allows reacting to stack changes.

        Parameters:
            item (table) – Item affected.
            oldQuantity (number) – Previous quantity.
            quantity (number) – New quantity.

        Realm:
            Client
        Example:
            hook.Add("ItemQuantityChanged", "CountStacks", function(item, old, new)
                print("Quantity now", new)
            end)
]]

--[[
        KickedFromChar(id, isCurrentChar)

        Description:
            Indicates that a character was forcefully removed.
            isCurrentChar denotes if it was the active one.

        Parameters:
            id (number) – Character identifier.
            isCurrentChar (boolean) – Was this the active character?

        Realm:
            Client
        Example:
            hook.Add("KickedFromChar", "Notify", function(id, current)
                print("Kicked from", id, current and "(current)" or "")
            end)
]]

--[[
        HandleItemTransferRequest(client, itemID, x, y, inventoryID)

        Description:
            Server receives a request to move an item.
            Modules can validate or modify the transfer.

        Parameters:
            client (Player) – Requesting player.
            itemID (number) – Item identifier.
            x (number) – X position.
            y (number) – Y position.
            inventoryID (number|string) – Target inventory ID.

        Realm:
            Server
        Example:
            hook.Add("HandleItemTransferRequest", "LogMove", function(ply, itemID, x, y)
                print(ply, "moved item", itemID, "to", x, y)
            end)
]]

--[[
        CharLoaded(id)

        Description:
            Fired when a character object is fully loaded.
            Receives the character ID.

        Parameters:
            id (number) – Character identifier.

        Realm:
            Shared
        Example:
            hook.Add("CharLoaded", "Notify", function(id)
                print("Character", id, "loaded")
            end)
]]

--[[
        PreCharDelete(id)

        Description:
            Called before a character is removed.
            Return false to cancel deletion.

        Parameters:
            id (number) – Character identifier.

        Realm:
            Shared
        Example:
            hook.Add("PreCharDelete", "Protect", function(id)
                if id == 1 then return false end
            end)
]]

--[[
        OnCharDelete(client, id)

        Description:
            Fired when a character is deleted.
            Provides the owning player if available.

        Parameters:
            client (Player) – Player who deleted.
            id (number) – Character identifier.

        Realm:
            Shared
        Example:
            hook.Add("OnCharDelete", "Announce", function(ply, id)
                print(ply, "deleted char", id)
            end)
]]

--[[
        OnCharCreated(client, character, data)

        Description:
            Invoked after a new character is created.
            Supplies the character table and creation data.

        Parameters:
            client (Player) – Owner player.
            character (table) – New character object.
            data (table) – Raw creation info.

        Realm:
            Shared
        Example:
            hook.Add("OnCharCreated", "Welcome", function(ply, char)
                print("Created", char:getName())
            end)
]]

--[[
        OnTransferred(client)

        Description:
            Runs when a player transfers to another server.
            Useful for cleanup.

        Parameters:
            client (Player) – Transferring player.

        Realm:
            Shared
        Example:
            hook.Add("OnTransferred", "Goodbye", function(ply)
                print(ply, "left the server")
            end)
]]

--[[
        CharPreSave(character)

        Description:
            Executed before a character is saved to disk.
            Allows writing custom data.

        Parameters:
            character (Character) – Character being saved.

        Realm:
            Shared
        Example:
            hook.Add("CharPreSave", "Record", function(char)
                char:setData("lastSave", os.time())
            end)
]]

--[[
        CanDisplayCharInfo(client, id)

        Description:
            Replacement for deprecated CanDisplayCharacterInfo.
            Determines if a character can be shown.

        Parameters:
            client (Player) – Local player.
            id (number) – Character ID.

        Realm:
            Client
        Example:
            hook.Add("CanDisplayCharInfo", "AllowAll", function()
                return true
            end)
]]

--[[
        CharListLoaded(newCharList)

        Description:
            Called when the character selection list finishes loading.
            Provides the loaded list table.

        Parameters:
            newCharList (table) – Table of characters.

        Realm:
            Client
        Example:
            hook.Add("CharListLoaded", "CountChars", function(list)
                print("Loaded", #list, "characters")
            end)
]]

--[[
        CharListUpdated(oldCharList, newCharList)

        Description:
            Fires when the character list is refreshed.
            Gives both old and new tables.

        Parameters:
            oldCharList (table) – Previous list.
            newCharList (table) – Updated list.

        Realm:
            Client
        Example:
            hook.Add("CharListUpdated", "Diff", function(old, new)
                print("Characters updated")
            end)
]]

--[[
        getCharMaxStamina(character)

        Description:
            Returns the maximum stamina for a character.
            Override to change stamina capacity.

        Parameters:
            character (Character) – Character queried.

        Realm:
            Shared
        Example:
            hook.Add("getCharMaxStamina", "Double", function(char)
                return 200
            end)
]]

--[[
        PostLoadFonts(...)

        Description:
            Runs after all font files have loaded.
            Allows registering additional fonts.

        Parameters:
            ... – Extra arguments passed through.

        Realm:
            Shared
        Example:
            hook.Add("PostLoadFonts", "LogoFont", function()
                surface.CreateFont("Logo", {size = 32, font = "Tahoma"})
            end)
]]

--[[
        ItemFunctionCalled(item, method, player, entity, results)

        Description:
            Fires whenever an ITEM method is invoked via ITEM:call.
            Useful for logging custom item function calls.

        Parameters:
            item (table) – Item table executing the method.
            method (string) – Name of the function run.
            player (Player) – Player that triggered the call.
            entity (Entity) – Item entity involved.
            results (table) – Table of returned values.

        Realm:
            Shared
        Example:
            hook.Add("ItemFunctionCalled", "DebugItemCall", function(item, method)
                print(item.uniqueID, "ran", method)
            end)
]]

--[[
        CanPlayerInteractItem(client, action, item, data)

        Description:
            Determines if a player may interact with an item.
            Return false and a reason string to block the action.

        Parameters:
            client (Player) – Player attempting the action.
            action (string) – Interaction identifier.
            item (table) – Item being used.
            data (table) – Additional data passed to the function.

        Realm:
            Server
        Example:
            hook.Add("CanPlayerInteractItem", "RestrictDrop", function(ply, act)
                if act == "drop" then return false, "You cannot drop this." end
            end)
]]

--[[
        PrePlayerInteractItem(client, action, item)

        Description:
            Called right before an item interaction executes.
            Allows last minute setup or cancellation.

        Parameters:
            client (Player) – Player performing the action.
            action (string) – Interaction name.
            item (table) – Item affected.

        Realm:
            Server
        Example:
            hook.Add("PrePlayerInteractItem", "Sound", function(ply, act)
                if act == "use" then ply:EmitSound("buttons/button14.wav") end
            end)
]]

--[[
        OnPlayerInteractItem(client, action, item, result, data)

        Description:
            Runs after an item interaction completes.
            Provides the result returned from the action.

        Parameters:
            client (Player) – Player performing the action.
            action (string) – Interaction name.
            item (table) – Item affected.
            result (any) – Value returned from the function.
            data (table) – Extra data passed in.

        Realm:
            Server
        Example:
            hook.Add("OnPlayerInteractItem", "NotifyUse", function(ply, act, itm)
                print(ply:Name(), "did", act, "on", itm.uniqueID)
            end)
]]

--[[
        CanPlayerAccessDoor(client, door, access)

        Description:
            Queries if a player has permission for a door.
            Returning true grants the requested access level.

        Parameters:
            client (Player) – Player checking the door.
            door (Entity) – Door entity being accessed.
            access (number) – Door access constant.

        Realm:
            Server
        Example:
            hook.Add("CanPlayerAccessDoor", "Admins", function(ply)
                if ply:IsAdmin() then return true end
            end)
]]

--[[
        CharHasFlags(character, flags)

        Description:
            Allows custom checks for character flag strings.
            Should return true if any flag applies.

        Parameters:
            character (table) – Character being queried.
            flags (string) – Flag characters being tested.

        Realm:
            Shared
        Example:
            hook.Add("CharHasFlags", "AllFlags", function() return true end)
]]

--[[
        isCharRecognized(character, id)

        Description:
            Determines if a character recognizes another character.
            Override to implement unique recognition logic.

        Parameters:
            character (table) – Character doing the check.
            id (number) – ID of the other character.

        Realm:
            Shared
        Example:
            hook.Add("isCharRecognized", "Always", function() return true end)
]]

--[[
        isCharFakeRecognized(character, id)

        Description:
            Similar to isCharRecognized but for fake recognition.
            Allows pretending to know a character.

        Parameters:
            character (table) – Character doing the check.
            id (number) – ID of the other character.

        Realm:
            Shared
        Example:
            hook.Add("isCharFakeRecognized", "None", function() return false end)
]]

--[[
        OnPlayerSwitchClass(player, newClass, oldClass)

        Description:
            Fired when a character changes class.
            Provides both the new and previous class IDs.

        Parameters:
            player (Player) – Player owning the character.
            newClass (number) – Class joined.
            oldClass (number) – Previous class or nil.

        Realm:
            Server
        Example:
            hook.Add("OnPlayerSwitchClass", "Announce", function(ply, new, old)
                print(ply:Name(), "switched from", old, "to", new)
            end)
]]

--[[
        OnPlayerJoinClass(player, classID, oldClass)

        Description:
            Called when a character first joins a class.
            Runs instead of OnPlayerSwitchClass when no prior class.

        Parameters:
            player (Player) – Player joining the class.
            classID (number) – Class selected.
            oldClass (number) – Previous class or nil.

        Realm:
            Server
        Example:
            hook.Add("OnPlayerJoinClass", "Welcome", function(ply, class)
                print(ply:Name(), "joined class", class)
            end)
]]

--[[
        GetAttributeMax(player, key)

        Description:
            Returns the maximum level an attribute may reach.
            Used when characters gain attribute points.

        Parameters:
            player (Player) – Player owning the character.
            key (string) – Attribute identifier.

        Realm:
            Server
        Example:
            hook.Add("GetAttributeMax", "Cap", function(ply, key)
                if key == "str" then return 50 end
            end)
]]

--[[
        OnCharAttribUpdated(player, character, key, value)

        Description:
            Triggered when a character attribute changes.
            Useful for achievements or syncing stats.

        Parameters:
            player (Player) – Player whose character changed.
            character (table) – Character table updated.
            key (string) – Attribute updated.
            value (number) – New attribute value.

        Realm:
            Server
        Example:
            hook.Add("OnCharAttribUpdated", "Print", function(ply, char, k, val)
                print(char:getName(), k, "=", val)
            end)
]]

--[[
        OnCharAttribBoosted(player, character, attribID, boostID, amount)

        Description:
            Invoked when an attribute boost is added or removed.
            Amount is true when a boost is removed.

        Parameters:
            player (Player) – Owner of the boost.
            character (table) – Character affected.
            attribID (string) – Attribute boosted.
            boostID (string) – Identifier for the boost source.
            amount (number|boolean) – Boost amount or true when removed.

        Realm:
            Server
        Example:
            hook.Add("OnCharAttribBoosted", "LogBoost", function(_, char, id)
                print("Boost updated for", char:getName(), id)
            end)
]]

--[[
        CharPostSave(character)

        Description:
            Called after a character's data has been saved.

        Parameters:
            character (table) – Character that finished saving.

        Realm:
            Server
        Example:
            hook.Add("CharPostSave", "Notify", function(char)
                print("Saved", char:getName())
            end)
]]

--[[
        OnCharKick(character, player)

        Description:
            Runs when a character is kicked from the server.

        Parameters:
            character (table) – Character being removed.
            player (Player) – Player owning the character.

        Realm:
            Server
        Example:
            hook.Add("OnCharKick", "RecordKick", function(char, ply)
                print(ply:Name(), "kicked", char:getName())
            end)
]]

--[[
        OnCharPermakilled(character, time)

        Description:
            Fired when a character is permanently banned or killed.
            Time will be nil for permanent removal.

        Parameters:
            character (table) – Character affected.
            time (number) – Unix timestamp when ban expires or nil.

        Realm:
            Server
        Example:
            hook.Add("OnCharPermakilled", "Log", function(char, until)
                print(char:getName(), "permakilled", until)
            end)
]]

--[[
        CanPerformVendorEdit(player, vendor)

        Description:
            Determines if a player can edit a vendor entity.
            Returning true grants edit permissions.

        Parameters:
            player (Player) – Player making the request.
            vendor (Entity) – Vendor being edited.

        Realm:
            Server
        Example:
            hook.Add("CanPerformVendorEdit", "Admins", function(ply)
                return ply:IsAdmin()
            end)
]]

--[[
        OnPlayerEnterSequence(player, name, callback, time, noFreeze)

        Description:
            Called when a player begins a forced animation sequence.

        Parameters:
            player (Player) – Player entering the sequence.
            name (string) – Sequence name.
            callback (function) – Function run when finished.
            time (number) – Duration override.
            noFreeze (boolean) – If true the player can move.

        Realm:
            Server
        Example:
            hook.Add("OnPlayerEnterSequence", "Report", function(ply, seq)
                print(ply:Name(), "started", seq)
            end)
]]

--[[
        OnPlayerLeaveSequence(player)

        Description:
            Fires when a forced animation sequence ends.

        Parameters:
            player (Player) – Player leaving the sequence.

        Realm:
            Server
        Example:
            hook.Add("OnPlayerLeaveSequence", "Report", function(ply)
                print(ply:Name(), "sequence finished")
            end)
]]

--[[
        PlayerStaminaGained(player)

        Description:
            Invoked when a player's stamina rises above half.
            Signals the end of heavy breathing effects.

        Parameters:
            player (Player) – Player who recovered stamina.

        Realm:
            Server
        Example:
            hook.Add("PlayerStaminaGained", "Message", function(ply)
                ply:ChatPrint("You feel rested.")
            end)
]]

--[[
        PlayerStaminaLost(player)

        Description:
            Runs when a player's stamina depletes completely.
            Often used to apply movement penalties.

        Parameters:
            player (Player) – Exhausted player.

        Realm:
            Server
        Example:
            hook.Add("PlayerStaminaLost", "Warn", function(ply)
                ply:ChatPrint("You are exhausted!")
            end)
]]

--[[
        OnCreatePlayerRagdoll(player, ragdoll, isDead)

        Description:
            Called after a player ragdoll entity is created.
            isDead is true when the ragdoll represents a corpse.

        Parameters:
            player (Player) – Player spawning the ragdoll.
            ragdoll (Entity) – Ragdoll entity created.
            isDead (boolean) – Whether the player died.

        Realm:
            Server
        Example:
            hook.Add("OnCreatePlayerRagdoll", "Log", function(ply, rag)
                print("Ragdoll created for", ply:Name())
            end)
]]

--[[
        OnCharFallover(player, ragdoll, gettingUp)

        Description:
            Fired when a player exits the fallover ragdoll state.
            gettingUp will be false when standing back up.

        Parameters:
            player (Player) – Player affected.
            ragdoll (Entity) – Associated ragdoll or nil.
            gettingUp (boolean) – False when getting up.

        Realm:
            Server
        Example:
            hook.Add("OnCharFallover", "Cleanup", function(ply)
                print(ply:Name(), "stood up")
            end)
]]

--[[
        OnItemAdded(player, item)

        Description:
            Triggered when an item is placed into an inventory.
            Only runs server-side when replication occurs.

        Parameters:
            player (Player) – Owner receiving the item.
            item (table) – Item added to the inventory.

        Realm:
            Server
        Example:
            hook.Add("OnItemAdded", "Notice", function(ply, it)
                print(ply:Name(), "received", it.uniqueID)
            end)
]]

--[[
        OnItemSpawned(entity)

        Description:
            Fired when an item entity first initializes in the world.

        Parameters:
            entity (Entity) – The spawned item entity.

        Realm:
            Server
        Example:
            hook.Add("OnItemSpawned", "Glow", function(ent)
                ent:SetColor(Color(255, 200, 200))
            end)
]]

--[[
        getItemDropModel(item, entity)

        Description:
            Allows overriding the model used for dropped items.

        Parameters:
            item (table) – Item being spawned.
            entity (Entity) – Item entity about to spawn.

        Realm:
            Server
        Example:
            hook.Add("getItemDropModel", "Box", function(it)
                return "models/props_junk/cardboard_box001a.mdl"
            end)
]]

--[[
        OnItemCreated(item, entity)

        Description:
            Called after an item entity finishes spawning.

        Parameters:
            item (table) – Item table linked to the entity.
            entity (Entity) – Spawned item entity.

        Realm:
            Server
        Example:
            hook.Add("OnItemCreated", "Message", function(it)
                print("Spawned", it.name)
            end)
]]

--[[
        DrawItemDescription(entity, x, y, color, alpha)

        Description:
            Lets code draw extra information on item tooltips.
            Only runs clientside when inspecting a dropped item.

        Parameters:
            entity (Entity) – Item entity being drawn.
            x (number) – Screen X position.
            y (number) – Screen Y position.
            color (table) – Base text color.
            alpha (number) – Tooltip alpha amount.

        Realm:
            Client
        Example:
            hook.Add("DrawItemDescription", "Hint", function(ent, x, y)
                draw.SimpleText("Rare", "DermaDefault", x, y - 20, color)
            end)
]]

--[[
        GetMoneyModel(amount)

        Description:
            Allows a custom model to be used for money piles.

        Parameters:
            amount (number) – Value of the money entity.

        Realm:
            Server
        Example:
            hook.Add("GetMoneyModel", "Large", function(amount)
                if amount > 1000 then return "models/props_lab/box01a.mdl" end
            end)
]]

--[[
        CanPickupMoney(player, entity)

        Description:
            Called when a player attempts to take money.
            Returning false blocks the pickup.

        Parameters:
            player (Player) – Player using the money entity.
            entity (Entity) – Money entity being used.

        Realm:
            Server
        Example:
            hook.Add("CanPickupMoney", "Restrict", function(ply)
                if ply:IsCombine() then return false end
            end)
]]

--[[
        OnPickupMoney(player, entity)

        Description:
            Fires after money has been successfully picked up.

        Parameters:
            player (Player) – Player who picked up the money.
            entity (Entity) – Money entity removed.

        Realm:
            Server
        Example:
            hook.Add("OnPickupMoney", "Log", function(ply, ent)
                print(ply:Name(), "took", ent:getAmount())
            end)
]]

--[[
        SetupDatabase()

        Description:
            Called during gamemode load before database connection.
            Use to configure database drivers.

        Realm:
            Server
        Example:
            hook.Add("SetupDatabase", "Init", function()
                print("Preparing database")
            end)
]]

--[[
        DatabaseConnected()

        Description:
            Runs once the connection to the database is established.

        Realm:
            Server
        Example:
            hook.Add("DatabaseConnected", "Notify", function()
                print("Database connected")
            end)
]]

--[[
        PersistenceLoad(saveName)

        Description:
            Invoked when map persistence data is loaded.

        Parameters:
            saveName (string) – Name of the save file loaded.

        Realm:
            Server
        Example:
            hook.Add("PersistenceLoad", "Announce", function(name)
                print("Loaded persistence", name)
            end)
]]

--[[
        CanOutfitChangeModel(item)

        Description:
            Checks if an outfit item may adjust the player's model.
            Return false to block the change.

        Parameters:
            item (table) – Outfit item being equipped.

        Realm:
            Server
        Example:
            hook.Add("CanOutfitChangeModel", "Restrict", function(it)
                if it.noModelChange then return false end
            end)
]]
