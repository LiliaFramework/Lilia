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
        AddBarField(...)

        Description:
            Called when the F1 menu builds status bars so new fields can be added.

        Realm:
            Client
        Example:
            -- Adds a custom thirst bar next to stamina.
            hook.Add("AddBarField", "AddThirstBar", function(section, id, label, min, max, value)
                lia.bar.add(value, Color(0, 150, 255), nil, id)
            end)
]]

--[[
        AddSection(...)

        Description:
            Fired when building the F1 menu so modules can insert additional sections.

        Realm:
            Client
        Example:
            -- Add a custom "Settings" tab.
            hook.Add("AddSection", "AddSettingsSection", function(name, color, priority)
                if name == "settings" then
                    color = Color(0, 128, 255)
                    priority = 5
                end
            end)
]]

--[[
        CanItemBeTransfered(...)

        Description:
            Determines whether an item may move between inventories.

        Realm:
            Server
        Example:
            -- Prevent quest items from being dropped.
            hook.Add("CanItemBeTransfered", "BlockQuestItemDrop", function(item, newInv, oldInv)
                if item.isQuest then return false, "Quest items cannot be moved" end
            end)
]]

--[[
        CanOpenBagPanel(...)

        Description:
            Called right before a bag inventory UI opens. Return false to block opening.

        Realm:
            Client
        Example:
            -- Disallow bag use while fighting.
            hook.Add("CanOpenBagPanel", "BlockBagInCombat", function(item)
                if LocalPlayer():getNetVar("inCombat") then return false end
            end)
]]

--[[
        CanOutfitChangeModel(...)

        Description:
            Checks if an outfit is allowed to change the player model.

        Realm:
            Shared
        Example:
            -- Restrict model swaps for certain factions.
            hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
                if item.factionRestricted then return false end
            end)
]]

--[[
        CanPerformVendorEdit(...)

        Description:
            Determines if a player can modify a vendor's settings.

        Realm:
            Shared
        Example:
            -- Allow only admins to edit vendors.
            hook.Add("CanPerformVendorEdit", "AdminVendorEdit", function(client)
                return client:IsAdmin()
            end)
]]

--[[
        CanPickupMoney(...)

        Description:
            Called when a player attempts to pick up a money entity.

        Realm:
            Shared
        Example:
            -- Prevent money pickup while handcuffed.
            hook.Add("CanPickupMoney", "BlockWhileCuffed", function(client)
                if client:isHandcuffed() then return false end
            end)
]]

--[[
        CanPlayerAccessDoor(...)

        Description:
            Determines if a player can open or lock a door entity.

        Realm:
            Shared
        Example:
            -- Only police can unlock jail cells.
            hook.Add("CanPlayerAccessDoor", "PoliceDoors", function(client, door, access)
                if door.isJail and not client:isPolice() then return false end
            end)
]]

--[[
        CanPlayerAccessVendor(...)

        Description:
            Checks if a player is permitted to open a vendor menu.

        Realm:
            Server
        Example:
            -- Block access unless the vendor allows the player's faction.
            hook.Add("CanPlayerAccessVendor", "CheckVendorFaction", function(client, vendor)
                if not vendor:isFactionAllowed(client:Team()) then return false end
            end)
]]

--[[
        CanPlayerHoldObject(...)

        Description:
            Determines if the player can pick up an entity with the hands swep.

        Realm:
            Shared
        Example:
            -- Prevent grabbing heavy physics objects.
            hook.Add("CanPlayerHoldObject", "WeightLimit", function(client, ent)
                if ent:GetMass() > 50 then return false end
            end)
]]

--[[
        CanPlayerInteractItem(...)

        Description:
            Called when a player tries to use or drop an item.

        Realm:
            Shared
        Example:
            -- Block medkit use inside safe zones.
            hook.Add("CanPlayerInteractItem", "SafeZoneBlock", function(client, action, item)
                if action == "use" and item.uniqueID == "medkit" and client:isInSafeZone() then
                    return false
                end
            end)
]]

--[[
        CanPlayerKnock(...)

        Description:
            Called when a player attempts to knock on a door.

        Realm:
            Shared
        Example:
            -- Prevent knocking while disguised.
            hook.Add("CanPlayerKnock", "BlockDisguisedKnock", function(client, door)
                if client:getNetVar("disguised") then return false end
            end)
]]

--[[
        CanPlayerSpawnStorage(...)

        Description:
            Checks if the player is allowed to spawn a storage container.

        Realm:
            Server
        Example:
            -- Limit players to one storage crate.
            hook.Add("CanPlayerSpawnStorage", "LimitStorage", function(client, ent, data)
                if client.storageSpawned then return false end
            end)
]]

--[[
        CanPlayerThrowPunch(...)

        Description:
            Called when the fists weapon tries to punch.

        Realm:
            Shared
        Example:
            -- Prevent punching while restrained.
            hook.Add("CanPlayerThrowPunch", "NoPunchWhenTied", function(client)
                if client:IsFlagSet(FL_KNOCKED) then return false end
            end)
]]

--[[
        CanPlayerTradeWithVendor(...)

        Description:
            Checks whether a vendor trade is allowed.

        Realm:
            Server
        Example:
            -- Block selling stolen goods.
            hook.Add("CanPlayerTradeWithVendor", "DisallowStolenItems", function(client, vendor, itemType, selling)
                if lia.stolen[itemType] then return false, "Stolen items" end
            end)
]]

--[[
        CanPlayerViewInventory(...)

        Description:
            Called before any inventory menu is shown.

        Realm:
            Client
        Example:
            -- Prevent opening inventory while in a cutscene.
            hook.Add("CanPlayerViewInventory", "BlockDuringCutscene", function()
                return not LocalPlayer():getNetVar("cutscene")
            end)
]]

--[[
        CanSaveData(...)

        Description:
            Called before persistent storage saves.

        Realm:
            Server
        Example:
            -- Disable saving during special events.
            hook.Add("CanSaveData", "NoEventSaves", function(entity, inv)
                if lia.eventActive then return false end
            end)
]]

--[[
        CharHasFlags(...)

        Description:
            Allows custom checks for a character's permission flags.

        Realm:
            Shared
        Example:
            -- Grant extra access if the character is VIP.
            hook.Add("CharHasFlags", "VIPExtraFlags", function(char, flags)
                if char:isVIP() and flags == "v" then return true end
            end)
]]

--[[
        CharPostSave(...)

        Description:
            Runs after a character's data has been saved to the database.

        Realm:
            Shared
        Example:
            -- Log every time characters save data.
            hook.Add("CharPostSave", "LogCharSaves", function(char)
                print(char:getName() .. " saved")
            end)
]]

--[[
        DatabaseConnected(...)

        Description:
            Fired after the database has been successfully connected.

        Realm:
            Shared
        Example:
            -- Prepare custom tables once the DB connects.
            hook.Add("DatabaseConnected", "CreateCustomTables", function()
                lia.db.query("CREATE TABLE IF NOT EXISTS extras(id INT)")
            end)
]]

--[[
        DrawItemDescription(...)

        Description:
            Called when an item entity draws its description text.

        Realm:
            Client
        Example:
            -- Display remaining uses next to item name.
            hook.Add("DrawItemDescription", "AddUseCount", function(item, x, y, color, alpha)
                draw.SimpleText("Uses: " .. item:getData("uses", 0), "DermaDefault", x, y + 20, color)
            end)
]]

--[[
        GetAttributeMax(...)

        Description:
            Returns the maximum value allowed for an attribute.

        Realm:
            Shared
        Example:
            -- Increase stamina cap for VIP players.
            hook.Add("GetAttributeMax", "VIPStamina", function(client, attrib)
                if attrib == "stm" and client:isVIP() then return 150 end
            end)
]]

--[[
        GetDefaultInventorySize(...)

        Description:
            Returns the default width and height for new inventories.

        Realm:
            Server
        Example:
            -- Expand default bags for premium players.
            hook.Add("GetDefaultInventorySize", "PremiumBags", function(client)
                if client:isVIP() then return 6, 6 end
            end)
]]

--[[
        GetMoneyModel(...)

        Description:
            Allows overriding the entity model used for dropped money.

        Realm:
            Shared
        Example:
            -- Use a golden model for large sums.
            hook.Add("GetMoneyModel", "GoldMoneyModel", function(amount)
                if amount > 5000 then return "models/props_lab/box01a.mdl" end
            end)
]]

        GetPlayerPunchDamage(...)

        Description:
            Lets addons modify how much damage the fists weapon deals.

        Realm:
            Shared
        Example:
            -- Scale punch damage by strength attribute.
            hook.Add("GetPlayerPunchDamage", "StrengthPunch", function(client, dmg, context)
                return dmg * (1 + client:getChar():getAttrib("str", 0) / 100)
            end)
]]

        InterceptClickItemIcon(...)

        Description:
            Allows overriding default clicks on inventory icons.

        Realm:
            Client
        Example:
            -- Shift-click to quickly move items.
            hook.Add("InterceptClickItemIcon", "ShiftQuickMove", function(panel, icon, key)
                if key == KEY_LSHIFT then return true end
            end)
]]

        ItemCombine(...)

        Description:
            Called when attempting to combine one item with another.

        Realm:
            Server
        Example:
            -- Combine two ammo boxes into one stack.
            hook.Add("ItemCombine", "StackAmmo", function(client, base, other)
                if base.uniqueID == "ammo" and other.uniqueID == "ammo" then
                    base:setData("amount", base:getData("amount",0) + other:getData("amount",0))
                    return true
                end
            end)
]]

--[[
        ItemDraggedOutOfInventory(...)

        Description:
            Called when an item icon is dragged completely out of an inventory.

        Realm:
            Server
        Example:
            -- Drop the item into the world when removed.
            hook.Add("ItemDraggedOutOfInventory", "DropOnDragOut", function(invPanel, item)
                item:spawn(invPanel:LocalToWorld(item:getPosition()))
            end)
]]

--[[
        ItemFunctionCalled(...)

        Description:
            Triggered whenever an item function is executed by a player.

        Realm:
            Shared
        Example:
            -- Log item function usage for analytics.
            hook.Add("ItemFunctionCalled", "TrackItemUse", function(item, action, client, entity, result)
                lia.log.add(client, "item_use", item.uniqueID, action)
            end)
]]
--[[
        ItemTransfered(...)

        Description:
            Runs after an item successfully moves between inventories.

        Realm:
            Server
        Example:
            -- Notify the player about the transfer result.
            hook.Add("ItemTransfered", "NotifyTransfer", function(context)
                context.client:notify("Item moved!")
            end)
]]

--[[
        OnCharAttribBoosted(...)

        Description:
            Fired when an attribute boost is added or removed.

        Realm:
            Shared
        Example:
            -- Notify the player when they gain a temporary bonus.
            hook.Add("OnCharAttribBoosted", "BoostNotice", function(client, char, key, id, amount)
                if amount ~= true then client:notify("Boosted " .. key .. " by " .. amount) end
            end)
]]
--[[
        OnCharAttribUpdated(...)

        Description:
            Fired when a character attribute value is changed.

        Realm:
            Shared
        Example:
            -- Sync the new attribute to the HUD.
            hook.Add("OnCharAttribUpdated", "UpdateHUDAttrib", function(client, char, key, value)
                if client == LocalPlayer() then MyHUD:SetStat(key, value) end
            end)
]]
--[[
        OnCharFallover(...)

        Description:
            Called when a character ragdolls or is forced to fall over.

        Realm:
            Server
        Example:
            -- Apply a stun effect when knocked down.
            hook.Add("OnCharFallover", "ApplyStun", function(client, _, forced)
                if forced then client:setAction("stunned", 3) end
            end)
]]
--[[
        OnCharKick(...)

        Description:
            Called when a character is kicked from the server.

        Realm:
            Shared
        Example:
            -- Record the kick reason.
            hook.Add("OnCharKick", "LogKickReason", function(char, client)
                print(char:getName(), "was kicked")
            end)
]]
--[[
        OnCharPermakilled(...)

        Description:
            Called when a character is permanently killed.

        Realm:
            Shared
        Example:
            -- Announce permadeath in chat.
            hook.Add('OnCharPermakilled', 'AnnouncePK', function(char, time)
                PrintMessage(HUD_PRINTTALK, char:getName() .. ' has met their end!')
            end)
]]
--[[
        OnCharRecognized(...)

        Description:
            Called clientside when your character recognizes another.

        Realm:
            Client
        Example:
            -- Play a sound whenever someone becomes recognized.
            hook.Add('OnCharRecognized', 'PlayRecognizeSound', function(client)
                surface.PlaySound('buttons/button17.wav')
            end)
]]
--[[
        OnCharTradeVendor(...)

        Description:
            Called after a character buys from or sells to a vendor.

        Realm:
            Server
        Example:
            -- Log vendor transactions to the console.
            hook.Add('OnCharTradeVendor', 'LogVendorTrade', function(client, vendor, item, selling)
                print(client:Nick(), selling and 'sold' or 'bought', item and item:getName() or 'unknown')
            end)
]]

--[[
        OnCreatePlayerRagdoll(...)

        Description:
            Called when a ragdoll entity is created for a player.

        Realm:
            Shared
        Example:
            -- Tint death ragdolls red.
            hook.Add('OnCreatePlayerRagdoll', 'RedRagdoll', function(client, ent, dead)
                if dead then ent:SetColor(Color(255,0,0)) end
            end)
]]
--[[
        OnCreateStoragePanel(...)

        Description:
            Called when both the player's inventory and storage panels are created.

        Realm:
            Client
        Example:
            -- Add a custom tab to storage windows.
            hook.Add('OnCreateStoragePanel', 'AddSortTab', function(localPanel, storagePanel, storage)
                storagePanel:AddTab('Sort', function() return vgui.Create('liaStorageSort') end)
            end)
]]

--[[
        OnItemAdded(...)

        Description:
            Called when a new item instance is placed into an inventory.

        Realm:
            Shared
        Example:
            -- Update the HUD when we pick up ammo.
            hook.Add('OnItemAdded', 'UpdateAmmoHUD', function(ply, item)
                if item.category == 'ammo' then MyHUD:AddAmmo(item) end
            end)
]]

--[[
        OnItemCreated(...)

        Description:
            Called when a new item instance table is initialized.

        Realm:
            Shared
        Example:
            -- Set custom data on freshly made items.
            hook.Add('OnItemCreated', 'InitCustomData', function(item)
                item:setData('born', os.time())
            end)
]]
--[[
        OnItemSpawned(...)

        Description:
            Called when an item entity has been spawned in the world.

        Realm:
            Shared
        Example:
            -- Play a sound when rare items appear.
            hook.Add('OnItemSpawned', 'RareSpawnSound', function(itemEnt)
                if itemEnt.rare then itemEnt:EmitSound('items/ammo_pickup.wav') end
            end)
]]
--[[
        OnOpenVendorMenu(...)

        Description:
            Called when the vendor dialog panel is opened.

        Realm:
            Client
        Example:
            -- Automatically switch to the buy tab.
            hook.Add('OnOpenVendorMenu', 'DefaultBuyTab', function(panel, vendor)
                panel:openTab('Buy')
            end)
]]
--[[
        OnPickupMoney(...)

        Description:
            Called after a player picks up a money entity.

        Realm:
            Shared
        Example:
            -- Reward an achievement for looting money.
            hook.Add('OnPickupMoney', 'MoneyAchievement', function(client, ent)
                client:addProgress('rich', ent:getAmount())
            end)
]]

--[[
        OnPlayerEnterSequence(...)

        Description:
            Fired when a scripted animation sequence begins.

        Realm:
            Shared
        Example:
            -- Freeze the player during the sequence.
            hook.Add('OnPlayerEnterSequence', 'FreezeDuringSeq', function(client, seq, callback, time, noFreeze)
                if not noFreeze then client:Freeze(true) end
            end)
]]

--[[
        OnPlayerInteractItem(...)

        Description:
            Runs after a player has interacted with an item.

        Realm:
            Shared
        Example:
            -- Send analytics for item usage.
            hook.Add('OnPlayerInteractItem', 'Analytics', function(client, action, item, result, data)
                lia.analytics.log(client, action, item.uniqueID)
            end)
]]
--[[
        OnPlayerJoinClass(...)

        Description:
            Called when a player changes to a new class.

        Realm:
            Shared
        Example:
            -- Give class specific weapons.
            hook.Add('OnPlayerJoinClass', 'ClassWeapons', function(client, class, oldClass)
                for _, wep in ipairs(class.weapons or {}) do client:Give(wep) end
            end)
]]
--[[
        OnPlayerLeaveSequence(...)

        Description:
            Fired when a scripted animation sequence ends for a player.

        Realm:
            Shared
        Example:
            -- Unfreeze the player after the sequence.
            hook.Add('OnPlayerLeaveSequence', 'UnfreezeAfterSeq', function(client)
                client:Freeze(false)
            end)
]]
--[[
        OnPlayerLostStackItem(...)

        Description:
            Called if a stackable item is removed unexpectedly.

        Realm:
            Shared
        Example:
            -- Warn players when their ammo stack disappears.
            hook.Add('OnPlayerLostStackItem', 'WarnLostAmmo', function(item)
                if item.category == 'ammo' then print('Ammo stack lost!') end
            end)
]]
--[[
        OnPlayerSwitchClass(...)

        Description:
            Occurs right before a player's class changes.

        Realm:
            Shared
        Example:
            -- Prevent switching while in combat.
            hook.Add('OnPlayerSwitchClass', 'NoCombatSwap', function(client, class, oldClass)
                if client:getNetVar('inCombat') then return false end
            end)
]]
--[[
        OnRequestItemTransfer(...)

        Description:
            Called when the UI asks to move an item between inventories.

        Realm:
            Client
        Example:
            -- Validate transfers before sending to the server.
            hook.Add('OnRequestItemTransfer', 'ValidateTransfer', function(panel, itemID, invID, x, y)
                return itemID ~= 0 -- block invalid ids
            end)
]]
--[[
        PersistenceLoad(...)

        Description:
            Called when map persistence data is loaded.

        Realm:
            Server
        Example:
            -- Verify entities when the map reloads.
            hook.Add('PersistenceLoad', 'CheckPersistent', function(name)
                print('Loading persistence file', name)
            end)
]]
--[[
        PlayerAccessVendor(...)

        Description:
            Occurs when a player successfully opens a vendor.

        Realm:
            Shared
        Example:
            -- Track how often players browse vendors.
            hook.Add('PlayerAccessVendor', 'VendorAnalytics', function(client, vendor)
                lia.log.add(client, 'vendor_open', vendor:GetClass())
            end)
]]
--[[
        PlayerStaminaGained(...)

        Description:
            Called when a player regenerates stamina points.

        Realm:
            Shared
        Example:
            -- Update a stamina HUD element.
            hook.Add('PlayerStaminaGained', 'HUDUpdateGain', function(client)
                MyHUD:UpdateStamina(client:getLocalVar('stamina'))
            end)
]]
--[[
        PlayerStaminaLost(...)

        Description:
            Called when a player's stamina decreases.

        Realm:
            Shared
        Example:
            -- Flash the stamina bar when exhausted.
            hook.Add('PlayerStaminaLost', 'FlashStamina', function(client)
                if client:getLocalVar('stamina', 0) <= 0 then MyHUD:Flash() end
            end)
]]
--[[
        PlayerThrowPunch(...)

        Description:
            Fires when a player lands a punch with the fists weapon.

        Realm:
            Shared
        Example:
            -- Play a custom sound on punch.
            hook.Add('PlayerThrowPunch', 'PunchSound', function(client, trace)
                client:EmitSound('npc/vort/claw_swing1.wav')
            end)
]]
--[[
        PostDrawInventory(...)

        Description:
            Called each frame after the inventory panel draws.

        Realm:
            Client
        Example:
            -- Draw a watermark over the inventory.
            hook.Add('PostDrawInventory', 'InventoryWatermark', function(panel)
                draw.SimpleText('MY SERVER', 'DermaLarge', panel:GetWide()-100, 8, color_white)
            end)
]]
--[[
        PrePlayerInteractItem(...)

        Description:
            Called just before a player interacts with an item.

        Realm:
            Shared
        Example:
            -- Deny using keys on locked chests.
            hook.Add('PrePlayerInteractItem', 'BlockChestKeys', function(client, action, item)
                if action == 'use' and item.uniqueID == 'key' and client.lockedChest then return false end
            end)
]]
--[[
        SetupBagInventoryAccessRules(...)

        Description:
            Allows modules to define who can access a bag inventory.

        Realm:
            Shared
        Example:
            -- Only the bag owner may open it.
            hook.Add('SetupBagInventoryAccessRules', 'OwnerOnlyBags', function(inv)
                inv:allowAccess('transfer', inv:getOwner())
            end)
]]
--[[
        SetupDatabase(...)

        Description:
            Runs before the gamemode initializes its database connection.

        Realm:
            Server
        Example:
            -- Register additional tables.
            hook.Add('SetupDatabase', 'AddExtraTables', function()
                lia.db.query('CREATE TABLE IF NOT EXISTS mytable(id INT)')
            end)
]]
--[[
        StorageCanTransferItem(...)

        Description:
            Determines if an item can move in or out of a storage entity.

        Realm:
            Server
        Example:
            -- Prevent weapons from being stored in car trunks.
            hook.Add('StorageCanTransferItem', 'NoWeaponsInCars', function(client, storage, item)
                if storage.isCar and item.category == 'weapons' then return false end
            end)
]]
--[[
        StorageEntityRemoved(...)

        Description:
            Fired when a storage entity is removed from the world.

        Realm:
            Shared
        Example:
            -- Drop items when a crate is destroyed.
            hook.Add('StorageEntityRemoved', 'DropContents', function(entity, inv)
                inv:dropItems(entity:GetPos())
            end)
]]
--[[
        StorageInventorySet(...)

        Description:
            Called when a storage entity is assigned an inventory.

        Realm:
            Shared
        Example:
            -- Send a notification when storage is initialized.
            hook.Add('StorageInventorySet', 'NotifyStorage', function(entity, inv, isCar)
                if isCar then print('Trunk inventory ready') end
            end)
]]
--[[
        StorageOpen(...)

        Description:
            Called clientside when a storage menu is opened.

        Realm:
            Client
        Example:
            -- Display storage name in the chat.
            hook.Add('StorageOpen', 'AnnounceStorage', function(entity, isCar)
                chat.AddText('Opened storage:', entity:GetClass())
            end)
]]
--[[
        StorageRestored(...)

        Description:
            Called when a storage's contents are loaded from disk.

        Realm:
            Server
        Example:
            -- Log how many items were restored.
            hook.Add('StorageRestored', 'PrintRestore', function(storage, inv)
                print('Storage restored with', #inv:getItems(), 'items')
            end)
]]
--[[
        StorageUnlockPrompt(...)

        Description:
            Called clientside when you must enter a storage password.

        Realm:
            Client
        Example:
            -- Auto-fill a remembered password.
            hook.Add('StorageUnlockPrompt', 'AutoFill', function(entity)
                return '1234' -- automatically send this string
            end)
]]
--[[
        VendorClassUpdated(vendor, id, allowed)

        Description:
            Called when a vendor's allowed classes are updated.

        Realm:
            Client
        Example:
            -- React to class access changes.
            hook.Add("VendorClassUpdated", "LogVendorClassChange", function(vendor, id, allowed)
                print("Vendor class", id, "now", allowed and "allowed" or "blocked")
            end)
]]

--[[
        VendorEdited(vendor, key)

        Description:
            Called after a delay when a vendor's data is edited.

        Realm:
            Client
        Example:
            -- Log which key changed.
            hook.Add("VendorEdited", "PrintVendorEdit", function(vendor, key)
                print("Vendor", vendor:GetClass(), "edited key", key)
            end)
]]

--[[
        VendorExited()

        Description:
            Called when a player exits from interacting with a vendor.

        Realm:
            Client
        Example:
            -- Notify the player when they leave a vendor.
            hook.Add("VendorExited", "PrintVendorExit", function()
                print("Stopped interacting with vendor")
            end)
]]

--[[
        VendorFactionUpdated(vendor, id, allowed)

        Description:
            Called when a vendor's allowed factions are updated.

        Realm:
            Client
        Example:
            -- Print updated faction permissions.
            hook.Add("VendorFactionUpdated", "LogVendorFactionUpdate", function(vendor, id, allowed)
                print("Vendor faction", id, "now", allowed and "allowed" or "blocked")
            end)
]]

--[[
        VendorItemMaxStockUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item max stock value changes.

        Realm:
            Client
        Example:
            -- Log stock limit changes.
            hook.Add("VendorItemMaxStockUpdated", "LogVendorStockLimits", function(vendor, itemType, value)
                print("Vendor stock limit for", itemType, "set to", value)
            end)
]]

--[[
        VendorItemModeUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item mode is changed.

        Realm:
            Client
        Example:
            -- Print the new mode value.
            hook.Add("VendorItemModeUpdated", "PrintVendorMode", function(vendor, itemType, value)
                print("Vendor mode for", itemType, "changed to", value)
            end)
]]

--[[
        VendorItemPriceUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item price is changed.

        Realm:
            Client
        Example:
            -- Print the new item price.
            hook.Add("VendorItemPriceUpdated", "LogVendorItemPrice", function(vendor, itemType, value)
                print("Vendor price for", itemType, "is now", value)
            end)
]]

--[[
        VendorItemStockUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item stock value changes.

        Realm:
            Client
        Example:
            -- Log remaining stock for the item.
            hook.Add("VendorItemStockUpdated", "LogVendorItemStock", function(vendor, itemType, value)
                print("Vendor stock for", itemType, "is now", value)
            end)
]]

--[[
        VendorMoneyUpdated(vendor, money, oldMoney)

        Description:
            Called when a vendor's available money changes.

        Realm:
            Client
        Example:
            -- Print the vendor's new money amount.
            hook.Add("VendorMoneyUpdated", "LogVendorMoney", function(vendor, money, oldMoney)
                print("Vendor money changed from", oldMoney, "to", money)
            end)
]]

--[[
        VendorOpened(vendor)

        Description:
            Called when a vendor menu is opened on the client.

        Realm:
            Client
        Example:
            -- Print which vendor was opened.
            hook.Add("VendorOpened", "PrintVendorOpened", function(vendor)
                print("Opened vendor", vendor:GetClass())
            end)
]]

--[[
        VendorSynchronized(vendor)

        Description:
            Called when vendor synchronization data is received.

        Realm:
            Client
        Example:
            -- Print a message when vendor data syncs.
            hook.Add("VendorSynchronized", "LogVendorSync", function(vendor)
                print("Vendor", vendor:GetClass(), "synchronized")
            end)
]]

--[[
        VendorTradeEvent(client, entity, uniqueID, isSellingToVendor)

        Description:
            Called when a player attempts to trade with a vendor.

        Realm:
            Server
        Example:
            -- Log all vendor trades to the console.
            hook.Add("VendorTradeEvent", "LogVendorTrades", function(client, entity, uniqueID, isSellingToVendor)
                local action = isSellingToVendor and "sold" or "bought"
                print(client:Name() .. " " .. action .. " " .. uniqueID .. " with " .. entity:GetClass())
            end)
]]

--[[
        getItemDropModel(itemTable, entity)

        Description:
            Returns an alternate model path for a dropped item.

        Realm:
            Server

        Returns:
            string|nil – Alternate model path or nil for default.
        Example:
            -- Replace drop model for weapons.
            hook.Add("getItemDropModel", "CustomDropModelForWeapons", function(itemTable, entity)
                if itemTable.category == "Weapon" then
                    return "models/weapons/w_rif_ak47.mdl"
                end
            end)
]]

--[[
        getPriceOverride(vendor, uniqueID, price, isSellingToVendor)

        Description:
            Allows modules to override a vendor item's price dynamically.

        Realm:
            Shared

        Returns:
            integer|nil – New price or nil for default.
        Example:
            -- Increase price for rare items when buying from the vendor.
            hook.Add("getPriceOverride", "DynamicPricing", function(vendor, uniqueID, price, isSellingToVendor)
                if uniqueID == "rare_item" then
                    if isSellingToVendor then
                        return math.floor(price * 0.75)
                    else
                        return math.floor(price * 1.25)
                    end
                end
            end)
]]

--[[
        isCharFakeRecognized(character, id)

        Description:
            Checks if a character is fake recognized rather than truly known.

        Realm:
            Shared

        Returns:
            boolean
        Example:
            -- Flag suspicious characters as fake.
            hook.Add("isCharFakeRecognized", "DetectFakeCharacters", function(character, id)
                if character:isSuspicious() then
                    return true
                end
            end)
]]

--[[
        isCharRecognized(character, id)

        Description:
            Determines whether one character recognizes another.

        Realm:
            Shared

        Returns:
            boolean
        Example:
            -- Only recognize characters from the same faction.
            hook.Add("isCharRecognized", "ValidateCharacterRecognition", function(character, id)
                return character:getFaction() == lia.char.loaded[id]:getFaction()
            end)
]]

--[[
        isRecognizedChatType(chatType)

        Description:
            Determines if a chat type counts toward recognition.

        Realm:
            Shared

        Returns:
            boolean
        Example:
            -- Mark admin chat as recognized to reveal player names.
            hook.Add("isRecognizedChatType", "ValidateRecognitionChat", function(chatType)
                local recognized = {"admin", "system", "recognition"}
                return table.HasValue(recognized, chatType)
            end)
]]

--[[
        isSuitableForTrunk(entity)

        Description:
            Determines whether an entity can be used as trunk storage.

        Realm:
            Shared

        Returns:
            boolean
        Example:
            -- Only vehicles are valid trunk containers.
            hook.Add("isSuitableForTrunk", "AllowOnlyCars", function(entity)
                return entity:IsVehicle()
            end)
]]

--[[
        CanPlayerEarnSalary(client, faction, class)

        Description:
            Determines if a player is allowed to earn salary.

        Parameters:
            client (Player)
            faction (table)
            class (table)

        Realm:
            Shared

        Returns:
            bool
        Example:
            hook.Add("CanPlayerEarnSalary", "RestrictSalaryToActivePlayers", function(client, faction, class)
                if not client:isActive() then
                    return false -- Inactive players do not earn salary
                end
                return true
            end)
]]

--[[
        CanPlayerJoinClass(client, class, info)

        Description:
            Determines whether a player can join a certain class. Return `false` to block.

        Parameters:
            client (Player)
            class (number)
            info (table)

        Realm:
            Shared

        Returns:
            bool|nil: false to block, nil to allow.
        Example:
            hook.Add("CanPlayerJoinClass", "RestrictEliteClass", function(client, class, info)
                if class == CLASS_ELITE and not client:hasPermission("join_elite") then
                    return false
                end
            end)
]]

--[[
        CanPlayerUseCommand(client, command)

        Description:
            Determines if a player can use a specific command. Return `false` to block usage.

        Parameters:
            client (Player)
            command (string)

        Realm:
            Shared

        Returns:
            bool|nil: false to block, nil to allow.
        Example:
            hook.Add("CanPlayerUseCommand", "BlockSensitiveCommands", function(client, command)
                local blockedCommands = {"shutdown", "restart"}
                if table.HasValue(blockedCommands, command) and not client:isSuperAdmin() then
                    return false
                end
            end)
]]

--[[
        CanPlayerUseDoor(client, door, access)

        Description:
            Determines if a player is allowed to use a door entity, such as opening, locking, or unlocking. Return `false` to prevent the action.

        Parameters:
            client (Player): The player attempting to use the door.
            door (Entity): The door entity being used.
            access (int): The type of access attempted (e.g., DOOR_LOCK).

        Realm:
            Server

        Returns:
            bool: false to block, nil or true to allow.
        Example:
            hook.Add("CanPlayerUseDoor", "AllowOnlyOwners", function(client, door, access)
                if access == DOOR_LOCK and door:getOwner() ~= client then
                    return false -- Only the owner can lock the door
                end
                return true
            end)
]]

--[[
        CharCleanUp(character:)

        Description:
            Used during character cleanup routines for additional steps when removing or transitioning a character.

        Parameters:
            character: The character being cleaned up.

        Realm:
            Server
        Example:
            hook.Add("CharCleanUp", "RemoveTemporaryItems", function(character)
                local inventory = character:getInv()
                for _, item in ipairs(inventory:getItems()) do
                    if item:isTemporary() then
                        inventory:removeItem(item.id)
                        print("Removed temporary item:", item.name)
                    end
                end
            end)
]]

--[[
        CharRestored()

        Description:
            Called after a character has been restored from the database. Useful for post-restoration logic such as awarding default items or setting up data.

        Realm:
            Server
        Example:
            hook.Add("CharRestored", "AwardWelcomePackage", function(character)
                local welcomePackage = {"welcome_pack", "starter_weapon", "basic_armor"}
                for _, itemID in ipairs(welcomePackage) do
                    character:getInv():addItem(itemID)
                end
                print("Welcome package awarded to:", character:getName())
            end)
]]

--[[
        CreateDefaultInventory()

        Description:
            Called when creating a default inventory for a character. Should return a [deferred](https://github.com/Be1zebub/luassert-deferred) (or similar promise) object that resolves with the new inventory.

        Realm:
            Server
        Example:
            hook.Add("CreateDefaultInventory", "InitializeStarterInventory", function(character)
                local d = deferred.new()
            
                someInventoryCreationFunction(character)
                    :next(function(inventory)
                        -- Add starter items
                        inventory:addItem("health_potion")
                        inventory:addItem("basic_sword")
                        d:resolve(inventory)
                    end, function(err)
                        print("Failed to create inventory:", err)
                        d:reject(err)
                    end)
            
                return d
            end)
]]

--[[
        CreateInventoryPanel(inventory, parent)

        Description:
            Client-side call when creating the graphical representation of an inventory.

        Parameters:
            inventory
            parent (Panel)

        Realm:
            Client
        Example:
            hook.Add("CreateInventoryPanel", "CustomInventoryUI", function(inventory, parent)
                local panel = vgui.Create("DPanel", parent)
                panel:SetSize(400, 600)
                panel.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 200))
                end
            
                local itemList = vgui.Create("DScrollPanel", panel)
                itemList:Dock(FILL)
            
                for _, item in ipairs(inventory:getItems()) do
                    local itemPanel = vgui.Create("DButton", itemList)
                    itemPanel:SetText(item.name)
                    itemPanel:Dock(TOP)
                    itemPanel:SetTall(40)
                    itemPanel.DoClick = function()
                        print("Selected item:", item.name)
                    end
                end
            
                return panel
            end)
]]

--[[
        CreateSalaryTimer(client)

        Description:
            Creates a timer to manage player salary.

        Parameters:
            client (Player)

        Realm:
            Shared
        Example:
            hook.Add("CreateSalaryTimer", "SetupSalaryTimer", function(client)
                timer.Create("SalaryTimer_" .. client:SteamID(), 60, 0, function()
                    if IsValid(client) and MODULE:CanPlayerEarnSalary(client, client:getFaction(), client:getClass()) then
                        local salary = MODULE:GetSalaryAmount(client, client:getFaction(), client:getClass())
                        client:addMoney(salary)
                        client:ChatPrint("You have received your salary of $" .. salary)
                        print("Salary of $" .. salary .. " awarded to:", client:Name())
                    end
                end)
                print("Salary timer created for:", client:Name())
            end)
]]

--[[
        DoModuleIncludes(path, module)

        Description:
            Called when modules include submodules. Useful for advanced module handling or dependency management.

        Parameters:
            path (string)
            module (table)

        Realm:
            Shared
        Example:
            hook.Add("DoModuleIncludes", "TrackModuleDependencies", function(path, module)
                print("Including submodule from path:", path)
                module.dependencies = module.dependencies or {}
                table.insert(module.dependencies, "base_module")
            end)
]]

--[[
        GetDefaultCharDesc(client, faction)

        Description:
            Retrieves a default description for a character during creation. Return `(defaultDesc, overrideBool)`.

        Parameters:
            client (Player)
            faction (number)

        Realm:
            Server

        Returns:
            string: The default description.
            bool: Whether to override.
        Example:
            hook.Add("GetDefaultCharDesc", "CitizenDefaultDesc", function(client, faction)
                if faction == FACTION_CITIZEN then
                    return "A hardworking member of society.", true
                end
            end)
]]

--[[
        GetDefaultCharName(client, faction, data)

        Description:
            Retrieves a default name for a character during creation. Return `(defaultName, overrideBool)`.

        Parameters:
            client (Player): The player creating the character.
            faction (number): The faction index.
            data (table): Additional creation data.

        Realm:
            Server

        Returns:
            string: The default name.
            bool: Whether to override the user-provided name.
        Example:
            hook.Add("GetDefaultCharName", "PoliceDefaultName", function(client, faction, data)
                if faction == FACTION_POLICE then
                    return "Officer " .. data.lastName or "Smith", true
                end
            end)
]]

--[[
        GetSalaryAmount(client, faction, class)

        Description:
            Retrieves the amount of salary a player should receive.

        Parameters:
            client (Player)
            faction (table)
            class (table)

        Realm:
            Shared

        Returns:
            any: The salary amount
        Example:
            hook.Add("GetSalaryAmount", "CalculateDynamicSalary", function(client, faction, class)
                local baseSalary = faction.baseSalary or 1000
                local classBonus = class.salaryBonus or 0
                return baseSalary + classBonus
            end)
]]

--[[
        GetSalaryLimit(client, faction, class)

        Description:
            Retrieves the salary limit for a player.

        Parameters:
            client (Player)
            faction (table)
            class (table)

        Realm:
            Shared

        Returns:
            any: The salary limit
        Example:
            hook.Add("GetSalaryLimit", "SetSalaryLimitsBasedOnRole", function(client, faction, class)
                if faction.name == "Police" then
                    return 5000 -- Police have a higher salary limit
                elseif faction.name == "Citizen" then
                    return 2000
                end
            end)
]]

--[[
        InitializedConfig()

        Description:
            Called when `lia.config` is fully initialized.

        Realm:
            Shared
        Example:
            function MODULE:InitializedConfig()
                if lia.config.enableSpecialFeatures then
                    lia.features.enable()
                    print("Special features have been enabled.")
                else
                    print("Special features are disabled in the config.")
                end
            end
]]

--[[
        InitializedItems()

        Description:
            Called once all item modules have been loaded from a directory.

        Realm:
            Shared
        Example:
            hook.Add("InitializedItems", "SetupSpecialItems", function()
                local specialItem = lia.item.create({
                    uniqueID = "magic_ring",
                    name = "Magic Ring",
                    description = "A ring imbued with magical properties.",
                    onUse = function(self, player)
                        player:grantAbility("invisibility")
                        print(player:Name() .. " has activated the Magic Ring!")
                    end
                })
                print("Special items have been set up.")
            end)
]]

--[[
        InitializedModules()

        Description:
            Called after all modules are fully initialized.

        Realm:
            Shared
        Example:
            hook.Add("InitializedModules", "FinalizeModuleSetup", function()
                lia.modules.finalizeSetup()
                print("All modules have been fully initialized.")
            end)
]]

--[[
        InitializedOptions()

        Description:
            Called when `lia.option` is fully initialized.

        Realm:
            Client
        Example:
            function MODULE:InitializedOptions()
               LocalPlayer():ChatPrint("LOADED OPTIONS!")
            end
]]

--[[
        InitializedSchema()

        Description:
            Called after the schema has finished initializing.

        Realm:
            Shared
        Example:
            hook.Add("InitializedSchema", "SchemaReadyNotification", function()
                print("Schema has been successfully initialized.")
                lia.notifications.broadcast("Welcome to the server! The schema is now active.")
            end)
]]

--[[
        InterceptClickItemIcon(self, itemIcon, keyCode)

        Description:
            Called when a player clicks on an item icon.

        Parameters:
            self (panel)
            itemIcon (panel)
            keyCode (int)

        Realm:
            Client
        Example:
            hook.Add("InterceptClickItemIcon", "HandleItemDoubleClick", function(self, itemIcon, keyCode)
                if keyCode == KEY_MOUSE2 then -- Right-click
                    local item = itemIcon:getItem()
                    lia.ui.openItemContextMenu(item, itemIcon:GetPos())
                    print("Item context menu opened for:", item.name)
                end
            end)
]]

--[[
        ItemCombine(client, item, targetItem)

        Description:
            Called when the system attempts to combine one item with another in an inventory.

        Parameters:
            client (Player)
            item (Item)
            targetItem (Item)

        Realm:
            Server

        Returns:
            bool: true if combination is valid and consumed, false otherwise.
        Example:
            hook.Add("ItemCombine", "CombineHealthAndHerb", function(client, item, targetItem)
                if item.uniqueID == "health_potion" and targetItem.uniqueID == "herb" then
                    local newItem = lia.item.create("super_health_potion")
                    client:getInv():addItem(newItem)
                    client:getInv():removeItem(item.id)
                    client:getInv():removeItem(targetItem.id)
                    print(client:Name() .. " combined Health Potion with Herb to create Super Health Potion.")
                    return true
                end
                return false
            end)
]]

--[[
        KeyLock(owner, entity, time)

        Description:
            Called when a player attempts to lock a door.

        Parameters:
            owner (Player)
            entity (Entity)
            time (float)

        Realm:
            Server
        Example:
            hook.Add("KeyLock", "LogDoorLock", function(owner, entity, time)
                entity:setLocked(true)
                lia.log.write("DoorLock", owner:Name() .. " locked door ID: " .. entity:EntIndex() .. " for " .. time .. " seconds.")
                print(owner:Name() .. " locked door ID:", entity:EntIndex(), "for", time, "seconds.")
            end)
]]

--[[
        KeyUnlock(owner, entity, time)

        Description:
            Called when a player attempts to unlock a door.

        Parameters:
            owner (Player)
            entity (Entity)
            time (float)

        Realm:
            Server
        Example:
            hook.Add("KeyUnlock", "LogDoorUnlock", function(owner, entity, time)
                entity:setLocked(false)
                lia.log.write("DoorUnlock", owner:Name() .. " unlocked door ID: " .. entity:EntIndex() .. " after " .. time .. " seconds.")
                print(owner:Name() .. " unlocked door ID:", entity:EntIndex(), "after", time, "seconds.")
            end)
]]

--[[
        LiliaTablesLoaded()

        Description:
            Called after all essential DB tables have been loaded.

        Realm:
            Server
        Example:
            hook.Add("LiliaTablesLoaded", "InitializeGameState", function()
                lia.gameState = lia.gameState or {}
                lia.gameState.activeEvents = {}
                print("All essential Lilia tables have been loaded. Game state initialized.")
            end)
]]

--[[
        OnItemRegistered(item)

        Description:
            Called after an item has been registered. Useful for customizing item behavior or adding properties.

        Parameters:
            item (Item)

        Realm:
            Shared
        Example:
            hook.Add("OnItemRegistered", "AddItemDurability", function(item)
                if item.uniqueID == "sword_basic" then
                    item.durability = 100
                    item.onUse = function(self)
                        self.durability = self.durability - 10
                        if self.durability <= 0 then
                            self:destroy()
                            print("Your sword has broken!")
                        end
                    end
                    print("Durability added to:", item.name)
                end
            end)
]]

--[[
        OnLoadTables()

        Description:
            Called before the faction tables are loaded. Good spot for data setup prior to factions being processed.

        Realm:
            Shared
        Example:
            hook.Add("OnLoadTables", "SetupFactionDefaults", function()
                lia.factions = lia.factions or {}
                lia.factions.defaultPermissions = {canUseWeapons = true, canAccessBank = false}
                print("Faction defaults have been set up.")
            end)
]]

--[[
        OnMySQLOOConnected()

        Description:
            Called when MySQLOO successfully connects to the database. Use to register prepared statements or init DB logic.

        Realm:
            Server
        Example:
            hook.Add("OnMySQLOOConnected", "PrepareDatabaseStatements", function()
                lia.db.prepare("insertPlayer", "INSERT INTO lia_players (_steamID, _steamName) VALUES (?, ?)", {MYSQLOO_STRING, MYSQLOO_STRING})
                lia.db.prepare("updatePlayerStats", "UPDATE lia_players SET kills = ?, deaths = ? WHERE _steamID = ?", {MYSQLOO_NUMBER, MYSQLOO_NUMBER, MYSQLOO_STRING})
                print("Prepared MySQLOO statements.")
            end)
]]

--[[
        OnPlayerPurchaseDoor(client, entity, buying, CallOnDoorChild)

        Description:
            Called when a player purchases or sells a door.

        Parameters:
            client (Player)
            entity (Entity): The door
            buying (bool): True if buying, false if selling
            CallOnDoorChild (function)

        Realm:
            Server
        Example:
            hook.Add("OnPlayerPurchaseDoor", "HandleDoorPurchase", function(client, entity, buying, CallOnDoorChild)
                if buying then
                    client:deductMoney(entity:getPrice())
                    lia.log.write("DoorPurchase", client:Name() .. " purchased door ID: " .. entity:EntIndex())
                    print(client:Name() .. " purchased a door.")
                else
                    client:addMoney(entity:getSellPrice())
                    lia.log.write("DoorSale", client:Name() .. " sold door ID: " .. entity:EntIndex())
                    print(client:Name() .. " sold a door.")
                end
                CallOnDoorChild(entity)
            end)
]]

--[[
        OnServerLog(client, logType, logString, category, color)

        Description:
            Called whenever a new log message is added. Allows for custom logic or modifications to log handling.

        Parameters:
            client (Player)
            logType (string)
            logString (string)
            category (string)
            color (Color)

        Realm:
            Server
        Example:
            hook.Add("OnServerLog", "AlertAdminsOnHighSeverity", function(client, logType, logString, category, color)
                if category == "error" then
                for _, admin in player.Iterator() do
                        if admin:isAdmin() then
                            lia.notifications.send(admin, "Error Log: " .. logString, color)
                        end
                    end
                end
            end)
]]

--[[
        OnWipeTables()

        Description:
            Called after wiping tables in the DB, typically after major resets/cleanups.

        Realm:
            Server
        Example:
            hook.Add("OnWipeTables", "ReinitializeDefaults", function()
                lia.db.execute("INSERT INTO lia_factions (name, description) VALUES ('Citizen', 'Regular inhabitants.')")
                lia.db.execute("INSERT INTO lia_classes (name, faction) VALUES ('Warrior', 'Citizen')")
                print("Database tables wiped and defaults reinitialized.")
            end)
]]

--[[
        PlayerMessageSend(speaker, chatType, message, anonymous)

        Description:
            Called before a chat message is sent. Return `false` to cancel, or modify the message if returning a string.

        Parameters:
            speaker (Player)
            chatType (string)
            message (string)
            anonymous (bool)

        Realm:
            Shared

        Returns:
            bool|nil|modifiedString: false to cancel, or return a modified string to change the message.
        Example:
            hook.Add("PlayerMessageSend", "FilterProfanity", function(speaker, chatType, message, anonymous)
                local filteredMessage = string.gsub(message, "badword", "****")
                if filteredMessage ~= message then
                    return filteredMessage
                end
            end)
]]

--[[
        PlayerModelChanged(client, model)

        Description:
            Called when a player's model changes.

        Parameters:
            client (Player): The player whose model changed.
            model (string): The new model path.

        Realm:
            Shared
        Example:
            hook.Add("PlayerModelChanged", "UpdatePlayerAppearance", function(client, model)
                print(client:Name() .. " changed their model to " .. model)
                -- Update related appearance settings
                client:setBodygroup(1, 2) -- Example of setting a bodygroup based on the new model
            end)
]]

--[[
        PlayerUseDoor(client, entity)

        Description:
            Called when a player attempts to use a door entity.

        Parameters:
            client (Player)
            entity (Entity)

        Realm:
            Server

        Returns:
            bool|nil: false to disallow, true to allow, or nil to let other hooks decide.
        Example:
            hook.Add("PlayerUseDoor", "LogDoorUsage", function(client, entity)
                print(client:Name() .. " is attempting to use door ID:", entity:EntIndex())
                -- Allow or disallow based on custom conditions
                if client:isBanned() then
                    return false -- Disallow use if the player is banned
                end
            end)
]]

--[[
        RegisterPreparedStatements()

        Description:
            Called for registering DB prepared statements post-MySQLOO connection.

        Realm:
            Server
        Example:
]]

--[[
        ShouldBarDraw(barName)

        Description:
            Determines whether a specific HUD bar should be drawn.

        Parameters:
            barName (string): e.g. "health", "armor".

        Realm:
            Client

        Returns:
            bool|nil: false to hide, nil to allow.
        Example:
            hook.Add("ShouldBarDraw", "HideArmorHUD", function(barName)
                if barName == "armor" then
                    return false
                end
            end)
]]

--[[
        ShouldDisableThirdperson(client)

        Description:
            Checks if third-person view is allowed or disabled.

        Parameters:
            client (Player)

        Realm:
            Client

        Returns:
            bool (true if 3rd-person should be disabled)
        Example:
            hook.Add("ShouldDisableThirdperson", "DisableForInvisibles", function(client)
                if client:isInvisible() then
                    return true -- Disable third-person view when invisible
                end
            end)
]]

--[[
        ShouldHideBars()

        Description:
            Determines whether all HUD bars should be hidden.

        Realm:
            Client

        Returns:
            bool|nil: true to hide, nil to allow rendering.
        Example:
            hook.Add("ShouldHideBars", "HideHUDInCinematic", function()
                if gui.IsInCinematicMode() then
                    return true
                end
            end)
]]

--[[
        thirdPersonToggled(state)

        Description:
            Called when third-person mode is toggled on or off. Allows for custom handling of third-person mode changes.

        Parameters:
            state (bool): true if third-person is enabled, false if disabled.

        Realm:
            Client
        Example:
            hook.Add("thirdPersonToggled", "NotifyThirdPersonChange", function(state)
                if state then
                    chat.AddText(Color(0,255,0), "Third-person view enabled.")
                else
                    chat.AddText(Color(255,0,0), "Third-person view disabled.")
                end
                print("Third-person mode toggled to:", state)
            end)
]]

--[[
        AddTextField(sectionName, fieldName, labelText, valueFunc)

        Description:
            Called when a text field is added to an F1 menu information section.
            Allows modules to modify or monitor the field being inserted.

        Parameters:
            sectionName (string)
            fieldName (string)
            labelText (string)
            valueFunc (function)

        Realm:
            Client
        Example:
            -- Change the money field label.
            hook.Add("AddTextField", "RenameMoneyField", function(section, name, label, value)
                if name == "money" then
                    return section, name, "Credits", value
                end
            end)
]]

--[[
        F1OnAddTextField(sectionName, fieldName, labelText, valueFunc)

        Description:
            Fired after AddTextField so other modules can react to new fields.

        Parameters:
            sectionName (string)
            fieldName (string)
            labelText (string)
            valueFunc (function)

        Realm:
            Client
        Example:
            -- Log newly added fields.
            hook.Add("F1OnAddTextField", "LogFields", function(section, name)
                print("Added field", name, "to section", section)
            end)
]]

--[[
        F1OnAddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)

        Description:
            Triggered after AddBarField inserts a status bar into the F1 menu.

        Parameters:
            sectionName (string)
            fieldName (string)
            labelText (string)
            minFunc (function)
            maxFunc (function)
            valueFunc (function)

        Realm:
            Client
        Example:
            hook.Add("F1OnAddBarField", "TrackBars", function(section, name)
                print("Added bar", name)
            end)
]]

--[[
        CreateInformationButtons(pages)

        Description:
            Called while building the F1 information menu to populate navigation buttons.

        Parameters:
            pages (table)

        Realm:
            Client
        Example:
            hook.Add("CreateInformationButtons", "AddHelpPage", function(pages)
                table.insert(pages, {name = "Help", drawFunc = function(parent) end})
            end)
]]

--[[
        PopulateConfigurationButtons(pages)

        Description:
            Invoked when the settings tab is constructed allowing new configuration pages.

        Parameters:
            pages (table)

        Realm:
            Client
        Example:
            hook.Add("PopulateConfigurationButtons", "AddControlsPage", function(pages)
                table.insert(pages, {name = "Controls", drawFunc = function(p) end})
            end)
]]

--[[
        InitializedKeybinds()

        Description:
            Called after keybinds have been loaded from disk.

        Realm:
            Client
        Example:
            hook.Add("InitializedKeybinds", "NotifyKeybinds", function()
                chat.AddText("Keybinds loaded")
            end)
]]

--[[
        getOOCDelay(client)

        Description:
            Allows modification of the cooldown delay between OOC messages.

        Parameters:
            client (Player)

        Realm:
            Server
        Returns:
            number|nil – Custom cooldown in seconds.
        Example:
            hook.Add("getOOCDelay", "VIPOOC", function(ply)
                if ply:IsVIP() then return 5 end
            end)
]]

--[[
        OnChatReceived(client, chatType, text, anonymous)

        Description:
            Runs on the client when chat text is received before display.
            Returning modified text will replace the message.

        Parameters:
            client (Player)
            chatType (string)
            text (string)
            anonymous (boolean)

        Realm:
            Client
        Returns:
            string|nil – Replacement text.
        Example:
            hook.Add("OnChatReceived", "CensorChat", function(ply, type, msg)
                return msg:gsub("badword", "****")
            end)
]]

--[[
        getAdjustedPartData(wearer, id)

        Description:
            Requests PAC3 part data after adjustments have been applied.

        Parameters:
            wearer (Entity)
            id (string)

        Realm:
            Client
        Returns:
            table|nil – Adjusted part data.
        Example:
            hook.Add("getAdjustedPartData", "DebugParts", function(ply, partID)
                print("Requesting part", partID)
            end)
]]

--[[
        AdjustPACPartData(wearer, id, data)

        Description:
            Allows modules to modify PAC3 part data before it is attached.

        Parameters:
            wearer (Entity)
            id (string)
            data (table)

        Realm:
            Client
        Returns:
            table|nil – Modified data table.
        Example:
            hook.Add("AdjustPACPartData", "ColorParts", function(ply, partID, d)
                d.Color = Vector(1,0,0)
                return d
            end)
]]

--[[
        attachPart(client, id)

        Description:
            Called when a PAC3 part should be attached to a player.

        Parameters:
            client (Player)
            id (string)

        Realm:
            Client
        Example:
            hook.Add("attachPart", "AnnouncePart", function(ply, partID)
                print(ply, "received part", partID)
            end)
]]

--[[
        removePart(client, id)

        Description:
            Triggered when a PAC3 part is removed from a player.

        Parameters:
            client (Player)
            id (string)

        Realm:
            Client
        Example:
            hook.Add("removePart", "LogPartRemoval", function(ply, partID)
                print(partID, "removed from", ply)
            end)
]]

--[[
        OnPAC3PartTransfered(part)

        Description:
            Fired when a PAC3 outfit part transfers ownership to a ragdoll.

        Parameters:
            part (Entity)

        Realm:
            Client
        Example:
            hook.Add("OnPAC3PartTransfered", "TrackTransfers", function(p)
                print("Part transferred", p)
            end)
]]

--[[
        DrawPlayerRagdoll(entity)

        Description:
            Allows custom rendering of a player's ragdoll created by PAC3.

        Parameters:
            entity (Entity)

        Realm:
            Client
        Example:
            hook.Add("DrawPlayerRagdoll", "TintRagdoll", function(ent)
                render.SetColorModulation(1,0,0)
            end)
]]

--[[
        setupPACDataFromItems()

        Description:
            Initializes PAC3 outfits from equipped items after modules load.

        Realm:
            Client
        Example:
            hook.Add("setupPACDataFromItems", "InitPAC", function()
                print("Equipped PAC data loaded")
            end)
]]

--[[
        TryViewModel(entity)

        Description:
            Allows PAC3 to swap the view model entity for event checks.

        Parameters:
            entity (Entity)

        Realm:
            Client
        Returns:
            Entity – Replacement entity.
        Example:
            hook.Add("TryViewModel", "UsePlayerViewModel", function(ent)
                return ent == LocalPlayer():GetViewModel() and LocalPlayer() or ent
            end)
]]

--[[
        WeaponCycleSound()

        Description:
            Lets modules provide a custom sound when cycling weapons in the selector.

        Realm:
            Client
        Returns:
            string|nil – Sound path.
            number|nil – Playback pitch.
        Example:
            hook.Add("WeaponCycleSound", "SilentCycle", function()
                return "buttons/button15.wav", 100
            end)
]]

--[[
        WeaponSelectSound()

        Description:
            Similar to WeaponCycleSound but used when confirming a weapon choice.

        Realm:
            Client
        Returns:
            string|nil – Sound path.
            number|nil – Playback pitch.
        Example:
            hook.Add("WeaponSelectSound", "CustomSelectSound", function()
                return "buttons/button24.wav", 90
            end)
]]

--[[
        ShouldDrawWepSelect(client)

        Description:
            Determines if the weapon selection UI should be visible.

        Parameters:
            client (Player)

        Realm:
            Client
        Returns:
            boolean
        Example:
            hook.Add("ShouldDrawWepSelect", "HideInVehicles", function(ply)
                return not ply:InVehicle()
            end)
]]

--[[
        CanPlayerChooseWeapon(weapon)

        Description:
            Checks whether the active weapon can be selected via the weapon wheel.

        Parameters:
            weapon (Weapon)

        Realm:
            Client
        Returns:
            boolean|nil – false to block selection.
        Example:
            hook.Add("CanPlayerChooseWeapon", "BlockPhysgun", function(wep)
                if IsValid(wep) and wep:GetClass() == "weapon_physgun" then
                    return false
                end
            end)
]]

--[[
        OverrideSpawnTime(client, baseTime)

        Description:
            Allows modules to modify the respawn delay after death.

        Parameters:
            client (Player)
            baseTime (number)

        Realm:
            Client
        Returns:
            number|nil – New respawn time.
        Example:
            hook.Add("OverrideSpawnTime", "ShortRespawns", function(ply, time)
                if ply:IsAdmin() then return 2 end
            end)
]]

--[[
        ShouldRespawnScreenAppear()

        Description:
            Lets modules suppress the respawn HUD from showing.

        Realm:
            Client
        Returns:
            boolean|nil – false to hide.
        Example:
            hook.Add("ShouldRespawnScreenAppear", "NoRespawnHUD", function()
                return false
            end)
]]

--[[
        VoiceToggled(enabled)

        Description:
            Fired when voice chat is enabled or disabled via config.

        Parameters:
            enabled (boolean)

        Realm:
            Shared
        Example:
            hook.Add("VoiceToggled", "AnnounceVoice", function(state)
                print("Voice chat set to", state)
            end)
]]

--[[
        RefreshFonts()

        Description:
            Requests recreation of all registered UI fonts.

        Realm:
            Client
        Example:
            hook.Add("RefreshFonts", "ReloadFonts", function()
                print("Fonts refreshed")
            end)
]]

--[[
        AdjustCreationData(client, data, newData, originalData)

        Description:
            Allows modification of character creation data before the character is saved.

        Parameters:
            client (Player)
            data (table)
            newData (table)
            originalData (table)

        Realm:
            Server
        Example:
            hook.Add("AdjustCreationData", "EnforceName", function(ply, data, newData)
                if data.name == "" then newData.name = "Unnamed" end
            end)
]]

--[[
        CanCharBeTransfered(character, newFaction, oldFaction)

        Description:
            Determines if a character may switch factions.

        Parameters:
            character (table)
            newFaction (table)
            oldFaction (number)

        Realm:
            Server
        Returns:
            bool|nil – false to block.
        Example:
            hook.Add("CanCharBeTransfered", "BlockRestrictedFactions", function(char, faction)
                if faction.isRestricted then return false end
            end)
]]

--[[
        CanPlayerUseChar(client, character)

        Description:
            Called when a player attempts to load one of their characters.

        Parameters:
            client (Player)
            character (table)

        Realm:
            Server
        Returns:
            bool|nil – false to deny.
        Example:
            hook.Add("CanPlayerUseChar", "CheckBans", function(ply, char)
                if char:isBanned() then return false, "Character banned" end
            end)
]]

--[[
        CanPlayerSwitchChar(client, currentChar, newChar)

        Description:
            Checks if a player can switch from their current character to another.

        Parameters:
            client (Player)
            currentChar (table)
            newChar (table)

        Realm:
            Server
        Returns:
            bool|nil – false to block the switch.
        Example:
            hook.Add("CanPlayerSwitchChar", "NoSwitchInCombat", function(ply)
                if ply:isInCombat() then return false end
            end)
]]

--[[
        CanPlayerLock(client, door)

        Description:
            Determines whether the player may lock the given door or vehicle.

        Parameters:
            client (Player)
            door (Entity)

        Realm:
            Server
        Returns:
            bool|nil – false to disallow.
        Example:
            hook.Add("CanPlayerLock", "AdminsAlwaysLock", function(ply)
                if ply:IsAdmin() then return true end
            end)
]]

--[[
        CanPlayerUnlock(client, door)

        Description:
            Determines whether the player may unlock the given door or vehicle.

        Parameters:
            client (Player)
            door (Entity)

        Realm:
            Server
        Returns:
            bool|nil – false to disallow.
        Example:
            hook.Add("CanPlayerUnlock", "AdminsAlwaysUnlock", function(ply)
                if ply:IsAdmin() then return true end
            end)
]]

--[[
        CanPlayerModifyConfig(client, key)

        Description:
            Called when a player attempts to change a configuration value.

        Parameters:
            client (Player)
            key (string)

        Realm:
            Server
        Returns:
            bool|nil – false to deny modification.
        Example:
            hook.Add("CanPlayerModifyConfig", "RestrictConfig", function(ply, k)
                return ply:IsSuperAdmin()
            end)
]]

--[[
        CharDeleted(client, character)

        Description:
            Fired after a character is permanently removed.

        Parameters:
            client (Player)
            character (table)

        Realm:
            Server
        Example:
            hook.Add("CharDeleted", "LogDeletion", function(ply, char)
                print(ply:Name(), "deleted character", char:getName())
            end)
]]

--[[
        CheckFactionLimitReached(faction, character, client)

        Description:
            Allows custom logic for determining if a faction has reached its player limit.

        Parameters:
            faction (table)
            character (table)
            client (Player)

        Realm:
            Shared
        Returns:
            boolean
        Example:
            hook.Add("CheckFactionLimitReached", "IgnoreVIP", function(faction, char, ply)
                if ply:IsVIP() then return false end
            end)
]]

--[[
        F1OnAddSection(sectionName, color, priority, location)

        Description:
            Triggered after AddSection inserts a new information section.

        Parameters:
            sectionName (string)
            color (Color)
            priority (number)
            location (number)

        Realm:
            Client
        Example:
            hook.Add("F1OnAddSection", "PrintSection", function(name)
                print("Added section", name)
            end)
]]

--[[
        GetWeaponName(weapon)

        Description:
            Allows overriding of the displayed weapon name in the selector.

        Parameters:
            weapon (Weapon)

        Realm:
            Client
        Returns:
            string|nil – Replacement name.
        Example:
            hook.Add("GetWeaponName", "UppercaseName", function(wep)
                return wep:GetClass():upper()
            end)
]]

--[[
        OnCharGetup(client, entity)

        Description:
            Called when a ragdolled character finishes getting up.

        Parameters:
            client (Player)
            entity (Entity) – Ragdoll entity.

        Realm:
            Server
        Example:
            hook.Add("OnCharGetup", "NotifyGetup", function(ply)
                ply:ChatPrint("You stood up")
            end)
]]

--[[
        OnLocalizationLoaded()

        Description:
            Fired once language files finish loading.

        Realm:
            Shared
        Example:
            hook.Add("OnLocalizationLoaded", "PrintLang", function()
                print("Localization ready")
            end)
]]

--[[
        OnPlayerObserve(client, state)

        Description:
            Called when a player's observe mode is toggled.

        Parameters:
            client (Player)
            state (boolean)

        Realm:
            Server
        Example:
            hook.Add("OnPlayerObserve", "AnnounceObserve", function(ply, s)
                print(ply, s and "entered" or "left", "observe mode")
            end)
]]

--[[
        PlayerLoadedChar(client, character, previousChar)

        Description:
            Runs after a character has been loaded and set up for a player.

        Parameters:
            client (Player)
            character (table)
            previousChar (table|nil)

        Realm:
            Server
        Example:
            hook.Add("PlayerLoadedChar", "WelcomeBack", function(ply, char)
                ply:ChatPrint("Welcome, " .. char:getName())
            end)
]]

--[[
        PrePlayerLoadedChar(client, newChar, oldChar)

        Description:
            Fired right before a player switches to a new character.

        Parameters:
            client (Player)
            newChar (table)
            oldChar (table|nil)

        Realm:
            Server
        Example:
            hook.Add("PrePlayerLoadedChar", "SaveStuff", function(ply, new, old)
                print("Switching characters")
            end)
]]

--[[
        PostPlayerLoadedChar(client, character, previousChar)

        Description:
            Called after PlayerLoadedChar to allow post-load operations.

        Parameters:
            client (Player)
            character (table)
            previousChar (table|nil)

        Realm:
            Server
        Example:
            hook.Add("PostPlayerLoadedChar", "GiveItems", function(ply, char)
                -- Give starter items here
            end)
]]

--[[
        PlayerSay(client, text)

        Description:
            Custom hook executed when a player sends a chat message server-side.

        Parameters:
            client (Player)
            text (string)

        Realm:
            Server
        Example:
            hook.Add("PlayerSay", "LogChat", function(ply, msg)
                print(ply:Name() .. ": " .. msg)
            end)
]]

--[[
        PopulateAdminStick(menu, target)

        Description:
            Called after the admin stick menu is created so additional commands can be added.

        Parameters:
            menu (DermaPanel)
            target (Entity)

        Realm:
            Client
        Example:
            hook.Add("PopulateAdminStick", "AddCustomOption", function(menu, ent)
                menu:AddOption("Wave", function() RunConsoleCommand("act", "wave") end)
            end)
]]

--[[
        TicketSystemClaim(admin, requester)

        Description:
            Fired when a staff member claims a help ticket.

        Parameters:
            admin (Player)
            requester (Player)

        Realm:
            Server
        Example:
            hook.Add("TicketSystemClaim", "NotifyClaim", function(staff, ply)
                staff:ChatPrint("Claimed ticket from " .. ply:Name())
            end)
]]

--[[
        liaOptionReceived(client, key, value)

        Description:
            Triggered when a shared option value is changed.

        Parameters:
            client (Player|nil)
            key (string)
            value (any)

        Realm:
            Server
        Example:
            hook.Add("liaOptionReceived", "PrintOptionChange", function(_, k, v)
                print("Option", k, "set to", v)
            end)
]]
