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

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Adds a custom hunger info field after the menu is ready.
            hook.Add("LoadCharInformation", "AddHungerField", function()
                local char = LocalPlayer():getChar()
                if char then
                    hook.Run("AddTextField", L("generalInfo"), "hunger", "Hunger", function()
                        return char:getData("hunger", 0) .. "%"
                    end)
                end
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

        Returns:
            None

        Example Usage:
            -- Inserts a custom "Help" tab listing available commands.
            hook.Add("CreateMenuButtons", "AddHelpTab", function(tabs)
                tabs.help = {
                    text = "Help",
                    panel = function()
                        local pnl = vgui.Create("DPanel")
                        pnl:Dock(FILL)
                        local label = vgui.Create("DLabel", pnl)
                        local commands = {}
                        for k in pairs(lia.command.list) do
                            commands[#commands + 1] = k
                        end
                        label:SetText(table.concat(commands, "\n"))
                        label:Dock(FILL)
                        label:SetFont("DermaDefault")
                        return pnl
                    end
                }
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

        Returns:
            None

        Example Usage:
            -- Overlays the player's name above the preview model.
            hook.Add("DrawLiliaModelView", "ShowName", function(panel, entity)
                local char = LocalPlayer():getChar()
                if not char then return end
                draw.SimpleTextOutlined(char:getName(), "Trebuchet24",
                    panel:GetWide() / 2, 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
            end)
]]
--[[
        ShouldAllowScoreboardOverride(client, field)

        Description:
            Determines if a scoreboard field such as a player's name or model can be replaced.

        Parameters:
            client (Player) – Player being displayed.
            field (string) – Field name such as "name" or "model".

        Realm:
            Client

        Returns:
            boolean – Return true to allow override

        Example Usage:
            -- Allows other hooks to replace player names on the scoreboard.
            hook.Add("ShouldAllowScoreboardOverride", "OverrideNames", function(ply, field)
                if field == "name" then return true end
            end)
]]
--[[
        GetDisplayedName(client)

        Description:
            Returns the name text to display for a player in UI panels.

        Parameters:
            client (Player) – Player to query.

        Realm:
            Client

        Returns:
            string or nil – Name text to display

        Example Usage:
            -- Displays player names with an admin prefix.
            hook.Add("GetDisplayedName", "AdminPrefix", function(ply)
                if ply:IsAdmin() then
                    return "[ADMIN] " .. ply:Nick()
                end
            end)
]]
--[[
        PlayerEndVoice(client)

        Description:
            Fired when the voice panel for a player is removed from the HUD.

        Parameters:
            client (Player) – Player whose panel ended.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Announces in chat and plays a sound when someone stops using voice chat.
            hook.Add("PlayerEndVoice", "NotifyVoiceStop", function(ply)
                chat.AddText(Color(200, 200, 255), ply:Nick() .. " stopped talking")
                surface.PlaySound("buttons/button19.wav")
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

        Returns:
            None

        Example Usage:
            -- Plays a sound and prints which model was removed from the spawn menu.
            hook.Add("SpawnlistContentChanged", "IconRemovedNotify", function(icon)
                surface.PlaySound("buttons/button9.wav")
                local name = icon:GetSpawnName() or icon:GetModelName() or tostring(icon)
                print("Removed spawn icon", name)
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Example Usage:
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

        Returns:
            number – Maximum starting points

        Example Usage:
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

        Returns:
            number – Maximum starting value

        Example Usage:
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

        Returns:
            boolean – False to hide the player

        Example Usage:
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

        Returns:
            None

        Example Usage:
            -- Adds a friendly "Wave" choice in the scoreboard menu.
            hook.Add("ShowPlayerOptions", "WaveOption", function(ply, options)
                options[#options + 1] = {
                    name = "Wave",
                    func = function()
                        RunConsoleCommand("say", "/me waves to " .. ply:Nick())
                        LocalPlayer():ConCommand("act wave")
                    end
                }
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

        Returns:
            string – Description text

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Fade out the chat box when it closes.
            hook.Add("FinishChat", "ChatClosed", function()
                if IsValid(lia.gui.chat) then
                    lia.gui.chat:AlphaTo(0, 0.2, 0, function() lia.gui.chat:Remove() end)
                end
            end)
]]
--[[
        StartChat()

        Description:
            Fires when the chat box opens.
            Fired when the chat box is opened.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Plays a sound and focuses the chat window when it opens.
            hook.Add("StartChat", "ChatOpened", function()
                surface.PlaySound("buttons/lightswitch2.wav")
                if IsValid(lia.gui.chat) then
                    lia.gui.chat:MakePopup()
                end
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

        Example Usage:
            -- Turns chat messages green and prefixes the time before they appear.
            hook.Add("ChatAddText", "GreenSystem", function(text, ...)
                local stamp = os.date("[%H:%M] ")
                return Color(0,255,0), stamp .. text, ...
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

        Returns:
            None

        Example Usage:
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

        Example Usage:
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

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Example Usage:
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

        Example Usage:
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

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
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

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Rebuild icons using the font after it loads.
            hook.Add("EasyIconsLoaded", "Notify", function()
                surface.SetFont("liaEasyIcons")
                chat.AddText(Color(0, 255, 200), "EasyIcons font loaded!")
                hook.Run("RefreshFonts")
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
            -- Logs usergroup changes by SteamID.
            hook.Add("CAMI.SteamIDUsergroupChanged", "LogSIDChange", function(sid, old, new)
                print(sid .. " changed from " .. old .. " to " .. new)
            end)
]]
--[[
        TooltipLayout(panel)

        Description:
            Customize tooltip sizing and layout before it appears.

        Parameters:
            panel (Panel) – Tooltip panel being laid out.

        Realm:
            Client

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            None

        Example Usage:
            -- Gives players a crowbar and ammo on spawn.
            hook.Add("PlayerLoadout", "GiveCrowbar", function(ply)
                ply:Give("weapon_crowbar")
                ply:GiveAmmo(10, "357", true)
                ply:SelectWeapon("weapon_crowbar")
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

        Returns:
            boolean – Return true to mark for permanent death

        Example Usage:
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

        Returns:
            boolean – False to block dropping

        Example Usage:
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

        Returns:
            boolean – False to prevent pickup

        Example Usage:
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

        Returns:
            boolean – False to block equipping

        Example Usage:
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

        Returns:
            boolean – False to prevent unequipping

        Example Usage:
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

        Returns:
            None

        Example Usage:
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

        Returns:
            boolean – False to skip ragdoll

        Example Usage:
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Backs up all persistent entities to a data file whenever saving occurs.
            hook.Add("PersistenceSave", "BackupEntities", function()
                local entities = {}
                for _, ent in ents.Iterator() do
                    if ent:GetPersistent() then
                        entities[#entities + 1] = {
                            class = ent:GetClass(),
                            pos = ent:GetPos(),
                            ang = ent:GetAngles()
                        }
                    end
                end
                file.Write("backup/entities.txt", util.TableToJSON(entities, true))
            end)
]]
--[[
        CanPersistEntity(entity)

        Description:
            Invoked before an entity is saved as persistent.
            Return false to disallow persisting the entity.

        Parameters:
            entity (Entity) – Entity being considered for persistence.

        Realm:
            Server

        Returns:
            boolean – False to prevent the entity from being saved.

        Example Usage:
            -- Skip weapons when marking props permanent.
            hook.Add("CanPersistEntity", "BlockWeapons", function(entity)
                if entity:IsWeapon() then return false end
            end)
]]
--[[
        LoadData()

        Description:
            Triggered when stored data should be loaded.
            Modules can restore custom information here.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Restores map props from a saved JSON file on disk.
            hook.Add("LoadData", "LoadCustomProps", function()
                if file.Exists("map/props.txt", "DATA") then
                    local props = util.JSONToTable(file.Read("map/props.txt", "DATA")) or {}
                    for _, info in ipairs(props) do
                        local ent = ents.Create(info.class)
                        if IsValid(ent) then
                            ent:SetPos(info.pos)
                            ent:SetAngles(info.ang)
                            ent:Spawn()
                            ent:Activate()
                        end
                    end
                end
            end)
]]
--[[
        PostLoadData()

        Description:
            Called after all persistent data has loaded.
            Useful for post-processing.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Spawns a supply crate at a stored position once everything is loaded.
            hook.Add("PostLoadData", "SpawnCrate", function()
                local info = lia.data.get("supplyCrate")
                if info then
                    local crate = ents.Create("prop_physics")
                    crate:SetModel("models/props_junk/wood_crate001a.mdl")
                    crate:SetPos(info.pos)
                    crate:Spawn()
                end
            end)
]]
--[[
        ShouldDataBeSaved()

        Description:
            Queries if data saving should occur during shutdown.
            Return false to cancel saving.

        Parameters:
            None

        Realm:
            Server

        Returns:
            boolean – False to cancel saving

        Example Usage:
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

        Returns:
            None

        Example Usage:
            -- Store the character's last position so it can be restored later.
            hook.Add("OnCharDisconnect", "SaveLogoutPos", function(ply, char)
                char:setData("logoutPos", ply:GetPos())
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

        Returns:
            None

        Example Usage:
            -- Give the bot a starter pistol and set up a small inventory.
            hook.Add("SetupBotPlayer", "InitBot", function(bot)
                local char = bot:getChar()
                char.vars.inv = {lia.inventory.new("GridInv")}
                bot:Give("weapon_pistol")
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

        Returns:
            None

        Example Usage:
            -- Cache the player's faction color from saved data for use after their character loads.
            hook.Add("PlayerLiliaDataLoaded", "CacheFactionColor", function(ply)
                local fid = ply:getData("factionID", 0)
                local faction = lia.faction.indices[fid]
                if faction then
                    ply.cachedFactionColor = faction.color
                end
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

        Returns:
            None

        Example Usage:
            -- Initialize some default variables for new players.
            hook.Add("PostPlayerInitialSpawn", "SetupTutorialState", function(ply)
                ply:setNetVar("inTutorial", true)
                ply:ChatPrint("Welcome! Follow the arrows to begin the tutorial.")
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

        Returns:
            None

        Example Usage:
            -- Prints a message when FactionOnLoadout is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ClassOnLoadout is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when PostPlayerLoadout is triggered
            hook.Add("PostPlayerLoadout", "SetColor", function(ply)
                ply:SetPlayerColor(Vector(0, 1, 0))
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

        Returns:
            None

        Example Usage:
            -- Prints a message when FactionPostLoadout is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ClassPostLoadout is triggered
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

        Returns:
            string – Inventory type

        Example Usage:
            -- Prints a message when GetDefaultInventoryType is triggered
            hook.Add("GetDefaultInventoryType", "UseGrid", function()
                return "GridInv"
            end)
]]
--[[
        ShouldDeleteSavedItems()

        Description:
            Decides whether saved persistent items should be deleted on load.
            Return true to wipe them from the database.

        Parameters:
            None

        Realm:
            Server

        Returns:
            boolean – True to delete items

        Example Usage:
            -- Remove stored items if too many exist on the map.
            hook.Add("ShouldDeleteSavedItems", "ClearDrops", function()
                if table.Count(lia.item.instances) > 1000 then
                    return true
                end
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

        Returns:
            None

        Example Usage:
            -- Adjusts item collision settings after loading from storage.
            hook.Add("OnSavedItemLoaded", "PrintCount", function(items)
                for _, ent in ipairs(items) do
                    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                end
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

        Returns:
            boolean – False to hide info

        Example Usage:
            -- Prints a message when ShouldDrawEntityInfo is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when DrawEntityInfo is triggered
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

        Returns:
            table – {text, color} info

        Example Usage:
            -- Prints a message when GetInjuredText is triggered
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

        Returns:
            boolean – False to hide info

        Example Usage:
            -- Prints a message when ShouldDrawPlayerInfo is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when DrawCharInfo is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ItemShowEntityMenu is triggered
            hook.Add("ItemShowEntityMenu", "QuickTake", function(ent)
                print("Opening menu for", ent)
            end)
]]
--[[
        PreLiliaLoaded()

        Description:
            Fired just before the client finishes loading the framework.
            Useful for setup tasks.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when PreLiliaLoaded is triggered
            hook.Add("PreLiliaLoaded", "Prep", function()
                print("About to finish loading")
            end)
]]
--[[
        LiliaLoaded()

        Description:
            Indicates the client finished initializing the framework.
            Modules can start creating panels here.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when LiliaLoaded is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when InventoryDataChanged is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ItemInitialized is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when InventoryInitialized is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when InventoryItemAdded is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when InventoryItemRemoved is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when InventoryDeleted is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ItemDeleted is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when OnCharVarChanged is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when OnCharLocalVarChanged is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ItemDataChanged is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when ItemQuantityChanged is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when KickedFromChar is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when HandleItemTransferRequest is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when CharLoaded is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when PreCharDelete is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when OnCharDelete is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when OnCharCreated is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when OnTransferred is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when CharPreSave is triggered
            hook.Add("CharPreSave", "Record", function(char)
                char:setData("lastSave", os.time())
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

        Returns:
            None

        Example Usage:
            -- Prints a message when CharListLoaded is triggered
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

        Returns:
            None

        Example Usage:
            -- Prints a message when CharListUpdated is triggered
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

        Returns:
            None

        Example Usage:
        -- Prints a message when getCharMaxStamina is triggered
        hook.Add("getCharMaxStamina", "Double", function(char)
            return 200
        end)
]]
--[[
        AdjustStaminaOffsetRunning(client, runCost)

        Description:
            Alters the stamina offset applied each tick while sprinting.
            Return a new cost to modify how quickly stamina drains when running.

        Parameters:
            client (Player) – Player that is sprinting.
            runCost (number) – Proposed stamina cost.

        Realm:
            Shared

        Returns:
            number – Modified stamina cost.

        Example Usage:
            -- Prints a message when AdjustStaminaOffsetRunning is triggered
            hook.Add("AdjustStaminaOffsetRunning", "EnduranceBonus", function(ply, cost)
                return cost + ply:getChar():getAttrib("stamina", 0) * -0.01
            end)
]]
--[[
        AdjustStaminaRegeneration(client, regen)

        Description:
            Allows changing how quickly stamina regenerates when not sprinting.
            Return a new amount to modify regeneration speed.

        Parameters:
            client (Player) – Player recovering stamina.
            regen (number) – Default regeneration per tick.

        Realm:
            Shared

        Returns:
            number – Modified regeneration amount.

        Example Usage:
            -- Prints a message when AdjustStaminaRegeneration is triggered
            hook.Add("AdjustStaminaRegeneration", "RestAreaBoost", function(ply, amount)
                if ply:isInSafeZone() then
                    return amount * 2
                end
            end)
]]
--[[
        AdjustStaminaOffset(client, offset)

        Description:
            Final hook for tweaking the calculated stamina offset.
            Return the modified offset value to apply each tick.

        Parameters:
            client (Player) – Player whose stamina is updating.
            offset (number) – Current offset after other adjustments.

        Realm:
            Shared

        Returns:
            number – New offset to apply.

        Example Usage:
            -- Prints a message when AdjustStaminaOffset is triggered
            hook.Add("AdjustStaminaOffset", "MinimumDrain", function(ply, off)
                return math.max(off, -1)
            end)
]]
--[[
        PostLoadFonts(currentFont, genericFont)

        Description:
            Runs after all font files have loaded.
            Allows registering additional fonts.

        Parameters:
            currentFont (string) – Name of the primary UI font.
            genericFont (string) – Name of the generic fallback font.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when PostLoadFonts is triggered
            hook.Add("PostLoadFonts", "LogoFont", function()
                surface.CreateFont("Logo", {size = 32, font = "Tahoma"})
            end)
]]
--[[
        AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)

        Description:
            Called when the F1 menu builds status bars so new fields can be added.

        Parameters:
            sectionName (string) – Section identifier.
            fieldName (string) – Unique field name.
            labelText (string) – Display label for the bar.
            minFunc (function) – Returns the minimum value.
            maxFunc (function) – Returns the maximum value.
            valueFunc (function) – Returns the current value.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Adds a custom thirst bar next to stamina.
            hook.Add("AddBarField", "AddThirstBar", function(section, id, label, min, max, value)
                lia.bar.add(value, Color(0, 150, 255), nil, id)
            end)
]]
--[[
        AddSection(sectionName, color, priority, location)

        Description:
            Fired when building the F1 menu so modules can insert additional sections.

        Parameters:
            sectionName (string) – Name of the section.
            color (Color) – Display color.
            priority (number) – Sort order priority.
            location (number) – Column/location index.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Add a custom "Settings" tab.
            hook.Add("AddSection", "AddSettingsSection", function(name, color, priority)
                if name == "settings" then
                    color = Color(0, 128, 255)
                    priority = 5
                end
            end)
]]
--[[
        CanItemBeTransfered(item, oldInventory, newInventory, client)

        Description:
            Determines whether an item may move between inventories.

        Parameters:
            item (Item) – Item being transferred.
            oldInventory (Inventory) – Source inventory.
            newInventory (Inventory) – Destination inventory.
            client (Player) – Owning player.

        Realm:
            Server

        Returns:
            boolean, string – False and reason to block

        Example Usage:
            -- Prevent quest items from being dropped.
            hook.Add("CanItemBeTransfered", "BlockQuestItemDrop", function(item, newInv, oldInv)
                if item.isQuest then return false, "Quest items cannot be moved" end
            end)
]]
--[[
        CanOpenBagPanel(item)

        Description:
            Called right before a bag inventory UI opens. Return false to block opening.

        Parameters:
            item (Item) – Bag item being opened.

        Realm:
            Client

        Returns:
            boolean – False to block opening.

        Example Usage:
            -- Disallow bag use while fighting.
            hook.Add("CanOpenBagPanel", "BlockBagInCombat", function(item)
                if LocalPlayer():getNetVar("inCombat") then return false end
            end)
]]
--[[
        CanOutfitChangeModel(item)

        Description:
            Checks if an outfit is allowed to change the player model.

        Parameters:
            item (Item) – Outfit item attempting to change the model.

        Realm:
            Shared

        Returns:
            boolean – False to block the change.

        Example Usage:
            -- Restrict model swaps for certain factions.
            hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
                if item.factionRestricted then return false end
            end)
]]
--[[
        CanPerformVendorEdit(client, vendor)

        Description:
            Determines if a player can modify a vendor's settings.

        Parameters:
            client (Player) – Player attempting the edit.
            vendor (Entity) – Vendor entity targeted.

        Realm:
            Shared

        Returns:
            boolean – False to disallow editing.

        Example Usage:
            -- Allow only admins to edit vendors.
            hook.Add("CanPerformVendorEdit", "AdminVendorEdit", function(client)
                return client:IsAdmin()
            end)
]]
--[[
        CanPickupMoney(client, moneyEntity)

        Description:
            Called when a player attempts to pick up a money entity.

        Parameters:
            client (Player) – Player attempting to pick up the money.
            moneyEntity (Entity) – The money entity.

        Realm:
            Shared

        Returns:
            boolean – False to disallow pickup.

        Example Usage:
            -- Prevent money pickup while handcuffed.
            hook.Add("CanPickupMoney", "BlockWhileCuffed", function(client)
                if client:isHandcuffed() then return false end
            end)
]]
--[[
        CanPlayerAccessDoor(client, door, access)

        Description:
            Determines if a player can open or lock a door entity.

        Parameters:
            client (Player) – Player attempting access.
            door (Entity) – Door entity in question.
            access (number) – Desired access level.

        Realm:
            Shared

        Returns:
            boolean – False to deny access.

        Example Usage:
            -- Only police can unlock jail cells.
            hook.Add("CanPlayerAccessDoor", "PoliceDoors", function(client, door, access)
                if door.isJail and not client:isPolice() then return false end
            end)
]]
--[[
        CanPlayerAccessVendor(client, vendor)

        Description:
            Checks if a player is permitted to open a vendor menu.

        Parameters:
            client (Player) – Player requesting access.
            vendor (Entity) – Vendor entity.

        Realm:
            Server

        Returns:
            boolean – False to deny access.

        Example Usage:
            -- Block access unless the vendor allows the player's faction.
            hook.Add("CanPlayerAccessVendor", "CheckVendorFaction", function(client, vendor)
                if not vendor:isFactionAllowed(client:Team()) then return false end
            end)
]]
--[[
        CanPlayerHoldObject(client, entity)

        Description:
            Determines if the player can pick up an entity with the hands swep.

        Parameters:
            client (Player) – Player attempting to hold the entity.
            entity (Entity) – Target entity.

        Realm:
            Shared

        Returns:
            boolean – False to prevent holding.

        Example Usage:
            -- Prevent grabbing heavy physics objects.
            hook.Add("CanPlayerHoldObject", "WeightLimit", function(client, ent)
                if ent:GetMass() > 50 then return false end
            end)
]]
--[[
        CanPlayerInteractItem(client, action, item)

        Description:
            Called when a player tries to use or drop an item.

        Parameters:
            client (Player) – Player interacting with the item.
            action (string) – Action name such as "use" or "drop".
            item (Item) – Item being interacted with.

        Realm:
            Shared

        Returns:
            boolean – False to block the action.

        Example Usage:
            -- Block medkit use inside safe zones.
            hook.Add("CanPlayerInteractItem", "SafeZoneBlock", function(client, action, item)
                if action == "use" and item.uniqueID == "medkit" and client:isInSafeZone() then
                    return false
                end
            end)
]]
--[[
        CanPlayerKnock(client, door)

        Description:
            Called when a player attempts to knock on a door.

        Parameters:
            client (Player) – Player knocking.
            door (Entity) – Door being knocked on.

        Realm:
            Shared

        Returns:
            boolean – False to block knocking.

        Example Usage:
            -- Prevent knocking while disguised.
            hook.Add("CanPlayerKnock", "BlockDisguisedKnock", function(client, door)
                if client:getNetVar("disguised") then return false end
            end)
]]
--[[
        CanPlayerSpawnStorage(client, entity, data)

        Description:
            Checks if the player is allowed to spawn a storage container.

        Parameters:
            client (Player) – Player attempting to spawn.
            entity (Entity) – Prop that will become storage.
            data (table) – Storage definition data.

        Realm:
            Server

        Returns:
            boolean – False to deny spawning.

        Example Usage:
            -- Limit players to one storage crate.
            hook.Add("CanPlayerSpawnStorage", "LimitStorage", function(client, ent, data)
                if client.storageSpawned then return false end
            end)
]]
--[[
        CanPlayerThrowPunch(client)

        Description:
            Called when the fists weapon tries to punch.

        Parameters:
            client (Player) – Player performing the punch.

        Realm:
            Shared

        Returns:
            boolean – False to block punching.

        Example Usage:
            -- Prevent punching while restrained.
            hook.Add("CanPlayerThrowPunch", "NoPunchWhenTied", function(client)
                if client:IsFlagSet(FL_KNOCKED) then return false end
            end)
]]
--[[
        CanPlayerTradeWithVendor(client, vendor, itemType, selling)

        Description:
            Checks whether a vendor trade is allowed.

        Parameters:
            client (Player) – Player attempting the trade.
            vendor (Entity) – Vendor entity involved.
            itemType (string) – Item identifier.
            selling (boolean) – True if the player is selling to the vendor.

        Realm:
            Server

        Returns:
            boolean, string – False and reason to deny trade

        Example Usage:
            -- Block selling stolen goods.
            hook.Add("CanPlayerTradeWithVendor", "DisallowStolenItems", function(client, vendor, itemType, selling)
                if lia.stolen[itemType] then return false, "Stolen items" end
            end)
]]
--[[
        CanPlayerViewInventory()

        Description:
            Called before any inventory menu is shown.

        Parameters:
            None

        Realm:
            Client

        Returns:
            boolean – False to prevent opening

        Example Usage:
            -- Prevent opening inventory while in a cutscene.
            hook.Add("CanPlayerViewInventory", "BlockDuringCutscene", function()
                return not LocalPlayer():getNetVar("cutscene")
            end)
]]
--[[
        CanSaveData(entity, inventory)

        Description:
            Called before persistent storage saves.

        Parameters:
            entity (Entity) – Storage entity being saved.
            inventory (Inventory) – Inventory associated with the entity.

        Realm:
            Server

        Returns:
            boolean – False to cancel saving

        Example Usage:
            -- Disable saving during special events.
            hook.Add("CanSaveData", "NoEventSaves", function(entity, inv)
                if lia.eventActive then return false end
            end)
]]
--[[
        CharHasFlags(character, flags)

        Description:
            Allows custom checks for a character's permission flags.

        Parameters:
            character (Character) – Character to check.
            flags (string) – Flags being queried.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Grant extra access for characters owned by admins.
            hook.Add("CharHasFlags", "AdminExtraFlags", function(char, flags)
                local ply = char:getPlayer()
                if IsValid(ply) and ply:IsAdmin() and flags == "a" then
                    return true
                end
            end)
]]
--[[
        CharPostSave(character)

        Description:
            Runs after a character's data has been saved to the database.

        Parameters:
            character (Character) – Character that finished saving.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Log every time characters save data.
            hook.Add("CharPostSave", "LogCharSaves", function(char)
                print(char:getName() .. " saved")
            end)
]]
--[[
        DatabaseConnected()

        Description:
            Fired after the database has been successfully connected.

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prepare custom tables once the DB connects.
            hook.Add("DatabaseConnected", "CreateCustomTables", function()
                lia.db.query("CREATE TABLE IF NOT EXISTS extras(id INT)")
            end)
]]
--[[
        DrawItemDescription(entity, x, y, color, alpha)

        Description:
            Called when an item entity draws its description text.

        Parameters:
            entity (Entity) – Item entity being drawn.
            x (number) – X screen position.
            y (number) – Y screen position.
            color (Color) – Text color.
            alpha (number) – Current alpha value.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Display remaining uses next to item name.
            hook.Add("DrawItemDescription", "AddUseCount", function(item, x, y, color, alpha)
                draw.SimpleText("Uses: " .. item:getData("uses", 0), "DermaDefault", x, y + 20, color)
            end)
]]
--[[
        GetAttributeMax(client, attribute)

        Description:
            Returns the maximum value allowed for an attribute.

        Parameters:
            client (Player) – Player being queried.
            attribute (string) – Attribute identifier.

        Realm:
            Shared

        Returns:
            number – Maximum attribute value

        Example Usage:
            -- Increase stamina cap for admins.
            hook.Add("GetAttributeMax", "AdminStamina", function(client, attrib)
                if attrib == "stamina" and client:IsAdmin() then
                    return 150
                end
            end)
]]
--[[
        GetDefaultInventorySize(client)

        Description:
            Returns the default width and height for new inventories.

        Parameters:
            client (Player) – Player the inventory belongs to.

        Realm:
            Server

        Returns:
            number, number – Width and height

        Example Usage:
            -- Expand default bags for admins.
            hook.Add("GetDefaultInventorySize", "AdminBags", function(client)
                if client:IsAdmin() then
                    return 6, 6
                end
            end)
]]
--[[
        GetMoneyModel(amount)

        Description:
            Allows overriding the entity model used for dropped money.

        Parameters:
            amount (number) – Money amount being dropped.

        Realm:
            Shared

        Returns:
            string – Model path to use

        Example Usage:
            -- Use a golden model for large sums.
            hook.Add("GetMoneyModel", "GoldMoneyModel", function(amount)
                if amount > 5000 then return "models/props_lab/box01a.mdl" end
            end)
]]
--[[

        GetPlayerPunchDamage(client, damage, context)

        Description:
            Lets addons modify how much damage the fists weapon deals.

        Parameters:
            client (Player) – Punching player.
            damage (number) – Base damage value.
            context (table) – Additional context table.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Scale punch damage by strength attribute.
            hook.Add("GetPlayerPunchDamage", "StrengthPunch", function(client, dmg, context)
                return dmg * (1 + client:getChar():getAttrib("str", 0) / 100)
            end)
]]
--[[
        InterceptClickItemIcon(self, itemIcon, keyCode)

        Description:
            Allows overriding default clicks on inventory icons.

        Parameters:
            self (Panel) – Inventory panel.
            itemIcon (Panel) – Icon that was clicked.
            keyCode (number) – Key that was pressed.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Shift-click to quickly move items.
            hook.Add("InterceptClickItemIcon", "ShiftQuickMove", function(panel, icon, key)
                if key == KEY_LSHIFT then return true end
            end)
]]
--[[
        ItemCombine(client, item, targetItem)

        Description:
            Called when the system attempts to combine one item with another in an inventory.

        Parameters:
            client (Player) – Owning player.
            item (Item) – Item being combined.
            targetItem (Item) – Item it is being combined with.

        Realm:
            Server

        Returns:
            bool – true if combination succeeds and items are consumed, false otherwise.

        Example Usage:
            -- Combine two ammo boxes into one stack.
            hook.Add("ItemCombine", "StackAmmo", function(client, base, other)
                if base.uniqueID == "ammo" and other.uniqueID == "ammo" then
                    base:setData("amount", base:getData("amount",0) + other:getData("amount",0))
                    client:getChar():getInv():removeItem(other.id)
                    return true
                end
            end)
]]
--[[
        ItemDraggedOutOfInventory(client, item)

        Description:
            Called when an item icon is dragged completely out of an inventory.

        Parameters:
            client (Player) – Player dragging the item.
            item (Item) – Item being removed.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Drop the item into the world when removed.
            hook.Add("ItemDraggedOutOfInventory", "DropOnDragOut", function(_, item)
                item:spawn(LocalPlayer():getItemDropPos())
            end)
]]
--[[
        ItemFunctionCalled(item, action, client, entity, result)

        Description:
            Triggered whenever an item function is executed by a player.

        Parameters:
            item (Item) – Item on which the function ran.
            action (string) – Action identifier.
            client (Player) – Player performing the action.
            entity (Entity|nil) – Target entity if any.
            result (any) – Result returned by the item function.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Log item function usage for analytics.
            hook.Add("ItemFunctionCalled", "TrackItemUse", function(item, action, client, entity, result)
                lia.log.add(client, "item_use", item.uniqueID, action)
            end)
]]
--[[
        ItemTransfered(context)

        Description:
            Runs after an item successfully moves between inventories.

        Parameters:
            context (table) – Transfer context table containing client, item, from and to inventories.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Notify the player about the transfer result.
            hook.Add("ItemTransfered", "NotifyTransfer", function(context)
                context.client:notify("Item moved!")
            end)
]]
--[[
        OnCharAttribBoosted(client, character, key, boostID, amount)

        Description:
            Fired when an attribute boost is added or removed.

        Parameters:
            client (Player) – Player owning the character.
            character (Character) – Character affected.
            key (string) – Attribute identifier.
            boostID (string) – Unique boost key.
            amount (number|boolean) – Amount added or true when removed.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Notify the player when they gain a temporary bonus.
            hook.Add("OnCharAttribBoosted", "BoostNotice", function(client, char, key, id, amount)
                if amount ~= true then client:notify("Boosted " .. key .. " by " .. amount) end
            end)
]]
--[[
        OnCharAttribUpdated(client, character, key, value)

        Description:
            Fired when a character attribute value is changed.

        Parameters:
            client (Player) – Player owning the character.
            character (Character) – Character updated.
            key (string) – Attribute identifier.
            value (number) – New attribute value.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Print the changed attribute on the local player's HUD.
            hook.Add("OnCharAttribUpdated", "PrintAttribChange", function(client, char, key, value)
                if client == LocalPlayer() then
                    chat.AddText(key .. ": " .. value)
                end
            end)
]]
--[[
        OnCharFallover(client, ragdoll, forced)

        Description:
            Called when a character ragdolls or is forced to fall over.

        Parameters:
            client (Player) – Player being ragdolled.
            ragdoll (Entity|nil) – Created ragdoll entity if any.
            forced (boolean) – True when the ragdoll was forced.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Apply a stun effect when knocked down.
            hook.Add("OnCharFallover", "ApplyStun", function(client, _, forced)
                if forced then client:setAction("stunned", 3) end
            end)
]]
--[[
        OnCharKick(character, client)

        Description:
            Called when a character is kicked from the server.

        Parameters:
            character (Character) – Character that was kicked.
            client (Player) – Player owning the character.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Record the kick reason.
            hook.Add("OnCharKick", "LogKickReason", function(char, client)
                print(char:getName(), "was kicked")
            end)
]]
--[[
        OnCharPermakilled(character, time)

        Description:
            Called when a character is permanently killed.

        Parameters:
            character (Character) – Character being permanently killed.
            time (number|nil) – Ban duration or nil for permanent.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Announce permadeath in chat.
            hook.Add('OnCharPermakilled', 'AnnouncePK', function(char, time)
                PrintMessage(HUD_PRINTTALK, char:getName() .. ' has met their end!')
            end)
]]
--[[
        OnCharRecognized(client)

        Description:
            Called clientside when your character recognizes another.

        Parameters:
            client (Player) – Player that initiated recognition.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Play a sound whenever someone becomes recognized.
            hook.Add('OnCharRecognized', 'PlayRecognizeSound', function(client)
                surface.PlaySound('buttons/button17.wav')
            end)
]]
--[[
        OnCharTradeVendor(client, vendor, item, selling, character, itemType, failed)

        Description:
            Called after a character buys from or sells to a vendor.

        Parameters:
            client (Player) – Player completing the trade.
            vendor (Entity) – Vendor entity involved.
            item (Item|nil) – Item traded, if any.
            selling (boolean) – True if selling to the vendor.
            character (Character) – Player's character.
            itemType (string|nil) – Item identifier when item is nil.
            failed (boolean|nil) – True if the trade failed.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Log vendor transactions to the console.
            hook.Add('OnCharTradeVendor', 'LogVendorTrade', function(client, vendor, item, selling)
                print(client:Nick(), selling and 'sold' or 'bought', item and item:getName() or 'unknown')
            end)
]]
--[[
        OnCreatePlayerRagdoll(client, entity, dead)

        Description:
            Called when a ragdoll entity is created for a player.

        Parameters:
            client (Player) – The player the ragdoll belongs to.
            entity (Entity) – The ragdoll entity.
            dead (boolean) – True if the player died.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Tint death ragdolls red.
            hook.Add('OnCreatePlayerRagdoll', 'RedRagdoll', function(client, ent, dead)
                if dead then ent:SetColor(Color(255,0,0)) end
            end)
]]
--[[
        OnCreateStoragePanel(localPanel, storagePanel, storage)

        Description:
            Called when both the player's inventory and storage panels are created.

        Parameters:
            localPanel (Panel) – The player's inventory panel.
            storagePanel (Panel) – The storage entity's panel.
            storage (Entity) – The storage entity.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Add a custom tab to storage windows.
            hook.Add('OnCreateStoragePanel', 'AddSortTab', function(localPanel, storagePanel, storage)
                storagePanel:AddTab('Sort', function() return vgui.Create('liaStorageSort') end)
            end)
]]
--[[
        OnItemAdded(client, item)

        Description:
            Called when a new item instance is placed into an inventory.

        Parameters:
            client (Player|nil) – Owner of the inventory the item was added to.
            item (Item) – Item that was inserted.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Play a sound when ammo is picked up.
            hook.Add('OnItemAdded', 'AmmoPickupSound', function(ply, item)
                if item.category == 'ammo' then
                    ply:EmitSound('items/ammo_pickup.wav')
                end
            end)
]]
--[[
        OnItemCreated(itemTable, entity)

        Description:
            Called when a new item instance table is initialized.

        Parameters:
            itemTable (table) – Item definition table.
            entity (Entity) – Spawned item entity.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Set custom data on freshly made items.
            hook.Add('OnItemCreated', 'InitCustomData', function(item)
                item:setData('born', os.time())
            end)
]]
--[[
        OnItemSpawned(entity)

        Description:
            Called when an item entity has been spawned in the world.

        Parameters:
            entity (Entity) – Spawned item entity.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Play a sound when rare items appear.
            hook.Add('OnItemSpawned', 'RareSpawnSound', function(itemEnt)
                if itemEnt.rare then itemEnt:EmitSound('items/ammo_pickup.wav') end
            end)
]]
--[[
        OnOpenVendorMenu(panel, vendor)

        Description:
            Called when the vendor dialog panel is opened.

        Parameters:
            panel (Panel) – The vendor menu panel.
            vendor (Entity) – The vendor entity.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Automatically switch to the buy tab.
            hook.Add('OnOpenVendorMenu', 'DefaultBuyTab', function(panel, vendor)
                panel:openTab('Buy')
            end)
]]
--[[
        OnPickupMoney(client, moneyEntity)

        Description:
            Called after a player picks up a money entity.

        Parameters:
            client (Player) – The player picking up the money.
            moneyEntity (Entity) – The money entity collected.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Reward an achievement for looting money.
            hook.Add('OnPickupMoney', 'MoneyAchievement', function(client, ent)
                client:addProgress('rich', ent:getAmount())
            end)
]]
--[[
        OnPlayerEnterSequence(client, sequence, callback, time, noFreeze)

        Description:
            Fired when a scripted animation sequence begins.

        Parameters:
            client (Player) – Player starting the sequence.
            sequence (string) – Sequence name.
            callback (function) – Completion callback.
            time (number) – Duration in seconds.
            noFreeze (boolean) – True if the player should not be frozen.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Freeze the player during the sequence.
            hook.Add('OnPlayerEnterSequence', 'FreezeDuringSeq', function(client, seq, callback, time, noFreeze)
                if not noFreeze then client:Freeze(true) end
            end)
]]
--[[
        OnPlayerInteractItem(client, action, item, result, data)

        Description:
            Runs after a player has interacted with an item.

        Parameters:
            client (Player) – Player performing the interaction.
            action (string) – Action key used.
            item (Item) – Item affected.
            result (any) – Result returned by the action.
            data (table|nil) – Additional data table.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Send analytics for item usage.
            hook.Add('OnPlayerInteractItem', 'Analytics', function(client, action, item, result, data)
                lia.analytics.log(client, action, item.uniqueID)
            end)
]]
--[[
        OnPlayerJoinClass(client, class, oldClass)

        Description:
            Called when a player changes to a new class.

        Parameters:
            client (Player) – The player switching classes.
            class (table|number) – New class table or index.
            oldClass (table|number) – Previous class table or index.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Give class specific weapons.
            hook.Add('OnPlayerJoinClass', 'ClassWeapons', function(client, class, oldClass)
                for _, wep in ipairs(class.weapons or {}) do client:Give(wep) end
            end)
]]
--[[
        OnPlayerLeaveSequence(client)

        Description:
            Fired when a scripted animation sequence ends for a player.

        Parameters:
            client (Player) – Player that finished the sequence.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Unfreeze the player after the sequence.
            hook.Add('OnPlayerLeaveSequence', 'UnfreezeAfterSeq', function(client)
                client:Freeze(false)
            end)
]]
--[[
        OnPlayerLostStackItem(item)

        Description:
            Called if a stackable item is removed unexpectedly.

        Parameters:
            item (Item) – The item that disappeared.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Warn players when their ammo stack disappears.
            hook.Add('OnPlayerLostStackItem', 'WarnLostAmmo', function(item)
                if item.category == 'ammo' then print('Ammo stack lost!') end
            end)
]]
--[[
        OnPlayerSwitchClass(client, class, oldClass)

        Description:
            Occurs right before a player's class changes.

        Parameters:
            client (Player) – Player who is switching.
            class (table|number) – Class being joined.
            oldClass (table|number) – Class being left.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prevent switching while in combat.
            hook.Add('OnPlayerSwitchClass', 'NoCombatSwap', function(client, class, oldClass)
                if client:getNetVar('inCombat') then return false end
            end)
]]
--[[
        OnRequestItemTransfer(panel, itemID, inventoryID, x, y)

        Description:
            Called when the UI asks to move an item between inventories.

        Parameters:
            panel (Panel) – Inventory panel requesting the move.
            itemID (number) – Identifier of the item to move.
            inventoryID (number|string) – Destination inventory ID.
            x (number) – Destination X coordinate.
            y (number) – Destination Y coordinate.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Validate transfers before sending to the server.
            hook.Add('OnRequestItemTransfer', 'ValidateTransfer', function(panel, itemID, invID, x, y)
                return itemID ~= 0 -- block invalid ids
            end)
]]
--[[
        PersistenceLoad(name)

        Description:
            Called when map persistence data is loaded.

        Parameters:
            name (string) – Name of the persistence file.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Verify entities when the map reloads.
            hook.Add('PersistenceLoad', 'CheckPersistent', function(name)
                print('Loading persistence file', name)
            end)
]]
--[[
        PlayerAccessVendor(client, vendor)

        Description:
            Occurs when a player successfully opens a vendor.

        Parameters:
            client (Player) – Player accessing the vendor.
            vendor (Entity) – Vendor entity opened.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Track how often players browse vendors.
            hook.Add('PlayerAccessVendor', 'VendorAnalytics', function(client, vendor)
                lia.log.add(client, 'vendor_open', vendor:GetClass())
            end)
]]
--[[
        PlayerStaminaGained(client)

        Description:
            Called when a player regenerates stamina points.

        Parameters:
            client (Player) – Player gaining stamina.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Print the player's stamina amount whenever it increases.
            hook.Add('PlayerStaminaGained', 'PrintStaminaGain', function(client)
                if client == LocalPlayer() then
                    print('Stamina:', client:getLocalVar('stamina'))
                end
            end)
]]
--[[
        PlayerStaminaLost(client)

        Description:
            Called when a player's stamina decreases.

        Parameters:
            client (Player) – Player losing stamina.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Play a sound when the player runs out of stamina.
            hook.Add('PlayerStaminaLost', 'TiredSound', function(client)
                if client:getLocalVar('stamina', 0) <= 0 then
                    client:EmitSound('player/suit_denydevice.wav')
                end
            end)
]]
--[[
        PlayerThrowPunch(client, trace)

        Description:
            Fires when a player lands a punch with the fists weapon.

        Parameters:
            client (Player) – Punching player.
            trace (table) – Trace result of the punch.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Play a custom sound on punch.
            hook.Add('PlayerThrowPunch', 'PunchSound', function(client, trace)
                client:EmitSound('npc/vort/claw_swing1.wav')
            end)
]]
--[[
        PostDrawInventory(panel, parentPanel)

        Description:
            Called each frame after the inventory panel draws.

        Parameters:
            panel (Panel) – The inventory panel being drawn.
            parentPanel (Panel|nil) – Parent panel if any.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Draw a watermark over the inventory.
            hook.Add('PostDrawInventory', 'InventoryWatermark', function(panel)
                draw.SimpleText('MY SERVER', 'DermaLarge', panel:GetWide()-100, 8, color_white)
            end)
]]
--[[
        PrePlayerInteractItem(client, action, item)

        Description:
            Called just before a player interacts with an item.

        Parameters:
            client (Player) – Player performing the action.
            action (string) – Action identifier.
            item (Item) – Target item.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Deny using keys on locked chests.
            hook.Add('PrePlayerInteractItem', 'BlockChestKeys', function(client, action, item)
                if action == 'use' and item.uniqueID == 'key' and client.lockedChest then return false end
            end)
]]
--[[
        SetupBagInventoryAccessRules(inventory)

        Description:
            Allows modules to define who can access a bag inventory.

        Parameters:
            inventory (Inventory) – Bag inventory object.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Only the bag owner may open it.
            hook.Add('SetupBagInventoryAccessRules', 'OwnerOnlyBags', function(inv)
                inv:allowAccess('transfer', inv:getOwner())
            end)
]]
--[[
        SetupDatabase()

        Description:
            Runs before the gamemode initializes its database connection.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Register additional tables.
            hook.Add('SetupDatabase', 'AddExtraTables', function()
                lia.db.query('CREATE TABLE IF NOT EXISTS mytable(id INT)')
            end)
]]
--[[
        StorageCanTransferItem(client, storage, item)

        Description:
            Determines if an item can move in or out of a storage entity.

        Parameters:
            client (Player) – Player moving the item.
            storage (Entity) – Storage entity.
            item (Item) – Item being transferred.

        Realm:
            Server

        Returns:
            boolean – False to disallow transfer

        Example Usage:
            -- Prevent weapons from being stored in car trunks.
            hook.Add('StorageCanTransferItem', 'NoWeaponsInCars', function(client, storage, item)
                if storage.isCar and item.category == 'weapons' then return false end
            end)
]]
--[[
        StorageEntityRemoved(entity, inventory)

        Description:
            Fired when a storage entity is removed from the world.

        Parameters:
            entity (Entity) – The storage entity being removed.
            inventory (Inventory) – Inventory associated with the entity.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Drop items when a crate is destroyed.
            hook.Add('StorageEntityRemoved', 'DropContents', function(entity, inv)
                inv:dropItems(entity:GetPos())
            end)
]]
--[[
        StorageInventorySet(entity, inventory, isCar)

        Description:
            Called when a storage entity is assigned an inventory.

        Parameters:
            entity (Entity) – The storage entity.
            inventory (Inventory) – Inventory assigned.
            isCar (boolean) – True if the entity is a vehicle trunk.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Send a notification when storage is initialized.
            hook.Add('StorageInventorySet', 'NotifyStorage', function(entity, inv, isCar)
                if isCar then print('Trunk inventory ready') end
            end)
]]
--[[
        StorageOpen(entity, isCar)

        Description:
            Called clientside when a storage menu is opened.

        Parameters:
            entity (Entity) – Storage entity opened.
            isCar (boolean) – True if opening a vehicle trunk.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Display storage name in the chat.
            hook.Add('StorageOpen', 'AnnounceStorage', function(entity, isCar)
                chat.AddText('Opened storage:', entity:GetClass())
            end)
]]
--[[
        StorageRestored(storage, inventory)

        Description:
            Called when a storage's contents are loaded from disk.

        Parameters:
            storage (Entity) – Storage entity.
            inventory (Inventory) – Inventory loaded.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Log how many items were restored.
            hook.Add('StorageRestored', 'PrintRestore', function(storage, inv)
                print('Storage restored with', #inv:getItems(), 'items')
            end)
]]
--[[
        StorageUnlockPrompt(entity)

        Description:
            Called clientside when you must enter a storage password.

        Parameters:
            entity (Entity) – Storage entity being opened.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Auto-fill a remembered password.
            hook.Add('StorageUnlockPrompt', 'AutoFill', function(entity)
                return '1234' -- automatically send this string
            end)
]]
--[[
        VendorClassUpdated(vendor, id, allowed)

        Description:
            Called when a vendor's allowed classes are updated.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- React to class access changes.
            hook.Add("VendorClassUpdated", "LogVendorClassChange", function(vendor, id, allowed)
                print("Vendor class", id, "now", allowed and "allowed" or "blocked")
            end)
]]
--[[
        VendorEdited(vendor, key)

        Description:
            Called after a delay when a vendor's data is edited.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Log which key changed.
            hook.Add("VendorEdited", "PrintVendorEdit", function(vendor, key)
                print("Vendor", vendor:GetClass(), "edited key", key)
            end)
]]
--[[
        VendorExited()

        Description:
            Called when a player exits from interacting with a vendor.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Notify the player when they leave a vendor.
            hook.Add("VendorExited", "PrintVendorExit", function()
                print("Stopped interacting with vendor")
            end)
]]
--[[
        VendorFactionUpdated(vendor, id, allowed)

        Description:
            Called when a vendor's allowed factions are updated.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print updated faction permissions.
            hook.Add("VendorFactionUpdated", "LogVendorFactionUpdate", function(vendor, id, allowed)
                print("Vendor faction", id, "now", allowed and "allowed" or "blocked")
            end)
]]
--[[
        VendorItemMaxStockUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item max stock value changes.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Log stock limit changes.
            hook.Add("VendorItemMaxStockUpdated", "LogVendorStockLimits", function(vendor, itemType, value)
                print("Vendor stock limit for", itemType, "set to", value)
            end)
]]
--[[
        VendorItemModeUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item mode is changed.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print the new mode value.
            hook.Add("VendorItemModeUpdated", "PrintVendorMode", function(vendor, itemType, value)
                print("Vendor mode for", itemType, "changed to", value)
            end)
]]
--[[
        VendorItemPriceUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item price is changed.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print the new item price.
            hook.Add("VendorItemPriceUpdated", "LogVendorItemPrice", function(vendor, itemType, value)
                print("Vendor price for", itemType, "is now", value)
            end)
]]
--[[
        VendorItemStockUpdated(vendor, itemType, value)

        Description:
            Called when a vendor's item stock value changes.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Log remaining stock for the item.
            hook.Add("VendorItemStockUpdated", "LogVendorItemStock", function(vendor, itemType, value)
                print("Vendor stock for", itemType, "is now", value)
            end)
]]
--[[
        VendorMoneyUpdated(vendor, money, oldMoney)

        Description:
            Called when a vendor's available money changes.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print the vendor's new money amount.
            hook.Add("VendorMoneyUpdated", "LogVendorMoney", function(vendor, money, oldMoney)
                print("Vendor money changed from", oldMoney, "to", money)
            end)
]]
--[[
        VendorOpened(vendor)

        Description:
            Called when a vendor menu is opened on the client.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print which vendor was opened.
            hook.Add("VendorOpened", "PrintVendorOpened", function(vendor)
                print("Opened vendor", vendor:GetClass())
            end)
]]
--[[
        VendorSynchronized(vendor)

        Description:
            Called when vendor synchronization data is received.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Print a message when vendor data syncs.
            hook.Add("VendorSynchronized", "LogVendorSync", function(vendor)
                print("Vendor", vendor:GetClass(), "synchronized")
            end)
]]
--[[
        VendorTradeEvent(client, entity, uniqueID, isSellingToVendor)

        Description:
            Called when a player attempts to trade with a vendor.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            string|nil – Alternate model path or nil for default.

        Example Usage:
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            integer|nil – New price or nil for default.

        Example Usage:
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            boolean

        Example Usage:
            -- Flag suspicious characters as fake.
            hook.Add("isCharFakeRecognized", "DetectFakeCharacters", function(character, id)
                if character:getData("suspicious", false) then
                    return true
                end
            end)
]]
--[[
        isCharRecognized(character, id)

        Description:
            Determines whether one character recognizes another.

        Parameters:
            None

        Realm:
            Shared

        Returns:
            boolean

        Example Usage:
            -- Only recognize characters from the same faction.
            hook.Add("isCharRecognized", "ValidateCharacterRecognition", function(character, id)
                return character:getFaction() == lia.char.loaded[id]:getFaction()
            end)
]]
--[[
        isRecognizedChatType(chatType)

        Description:
            Determines if a chat type counts toward recognition.

        Parameters:
            None

        Realm:
            Shared

        Returns:
            boolean

        Example Usage:
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            boolean

        Example Usage:
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
            client (Player) – Player to check.
            faction (table) – Faction data for the player.
            class (table) – Class table for the player.

        Realm:
            Shared

        Returns:
            bool

        Example Usage:
            -- Prints a message when CanPlayerEarnSalary is triggered
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
            client (Player) – Player requesting the class.
            class (number) – Class index being joined.
            info (table) – Additional class info table.

        Realm:
            Shared

        Returns:
            bool|nil: false to block, nil to allow.

        Example Usage:
            -- Prints a message when CanPlayerJoinClass is triggered
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
            client (Player) – Player running the command.
            command (string) – Command name.

        Realm:
            Shared

        Returns:
            bool|nil: false to block, nil to allow.

        Example Usage:
            -- Prints a message when CanPlayerUseCommand is triggered
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
            client (Player) – The player attempting to use the door.
            door (Entity) – The door entity being used.
            access (int) – Access type attempted (e.g. DOOR_LOCK).

        Realm:
            Server

        Returns:
            bool: false to block, nil or true to allow.

        Example Usage:
            -- Prints a message when CanPlayerUseDoor is triggered
            hook.Add("CanPlayerUseDoor", "AllowOnlyOwners", function(client, door, access)
                if access == DOOR_LOCK and door:getOwner() ~= client then
                    return false -- Only the owner can lock the door
                end
                return true
            end)
]]
--[[
        CharCleanUp(character)

        Description:
            Used during character cleanup routines for additional steps when removing or transitioning a character.

        Parameters:
            character (Character) – The character being cleaned up.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when CharCleanUp is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when CharRestored is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when CreateDefaultInventory is triggered
            hook.Add("CreateDefaultInventory", "InitializeStarterInventory", function(character)
                local d = deferred.new()

                lia.inventory.new("bag")
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
            inventory (Inventory) – Inventory instance to draw.
            parent (Panel) – Parent container panel.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when CreateInventoryPanel is triggered
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
            client (Player) – Player receiving the salary timer.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when CreateSalaryTimer is triggered
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
            path (string) – Directory path containing the submodule.
            module (table) – Module performing the include.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when DoModuleIncludes is triggered
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
            client (Player) – Player creating the character.
            faction (number) – Faction index of the new character.

        Realm:
            Server

        Returns:
            string: The default description.
            bool: Whether to override.

        Example Usage:
            -- Prints a message when GetDefaultCharDesc is triggered
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
            client (Player) – Player creating the character.
            faction (number) – Faction index.
            data (table) – Additional creation data.

        Realm:
            Server

        Returns:
            string: The default name.
            bool: Whether to override the user-provided name.

        Example Usage:
            -- Prints a message when GetDefaultCharName is triggered
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
            client (Player) – Player receiving salary.
            faction (table) – Player's faction data.
            class (table) – Player's class data.

        Realm:
            Shared

        Returns:
            any: The salary amount

        Example Usage:
            -- Prints a message when GetSalaryAmount is triggered
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
            client (Player) – Player being checked.
            faction (table) – Player's faction data.
            class (table) – Player's class data.

        Realm:
            Shared

        Returns:
            any: The salary limit

        Example Usage:
            -- Prints a message when GetSalaryLimit is triggered
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when this hook is triggered
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when InitializedItems is triggered
            hook.Add("InitializedItems", "SetupSpecialItems", function()
                local specialItem = lia.item.create({
                    uniqueID = "magic_ring",
                    name = "Magic Ring",
                    description = "A ring imbued with magical properties.",
                    onUse = function(self, player)
                        player:SetNoDraw(true)
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when InitializedModules is triggered
            hook.Add("InitializedModules", "FinalizeModuleSetup", function()
                lia.modules.finalizeSetup()
                print("All modules have been fully initialized.")
            end)
]]
--[[
        InitializedOptions()

        Description:
            Called when `lia.option` is fully initialized.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when this hook is triggered
            function MODULE:InitializedOptions()
               LocalPlayer():ChatPrint("LOADED OPTIONS!")
            end
]]
--[[
        InitializedSchema()

        Description:
            Called after the schema has finished initializing.

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when InitializedSchema is triggered
            hook.Add("InitializedSchema", "SchemaReadyNotification", function()
                print("Schema has been successfully initialized.")
                lia.notifications.broadcast("Welcome to the server! The schema is now active.")
            end)
]]
--[[
        KeyLock(owner, entity, time)

        Description:
            Called when a player attempts to lock a door.

        Parameters:
            owner (Player) – Player locking the door.
            entity (Entity) – Door entity being locked.
            time (float) – Duration of the locking animation.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when KeyLock is triggered
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
            owner (Player) – Player unlocking the door.
            entity (Entity) – Door entity being unlocked.
            time (float) – How long the process took.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when KeyUnlock is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when LiliaTablesLoaded is triggered
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
            item (Item) – Item definition being registered.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when OnItemRegistered is triggered
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

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when OnLoadTables is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnMySQLOOConnected is triggered
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
            client (Player) – Player buying or selling the door.
            entity (Entity) – Door entity affected.
            buying (bool) – True if buying, false if selling.
            CallOnDoorChild (function) – Optional callback for door children.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnPlayerPurchaseDoor is triggered
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
            client (Player) – Player associated with the log or nil.
            logType (string) – Type identifier for the log entry.
            logString (string) – Formatted log text.
            category (string) – Category name.
            color (Color) – Display color.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnServerLog is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnWipeTables is triggered
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
            speaker (Player) – Player sending the message.
            chatType (string) – Chat type key.
            message (string) – Message contents.
            anonymous (bool) – True if the speaker is hidden.

        Realm:
            Shared

        Returns:
            bool|nil|modifiedString: false to cancel, or return a modified string to change the message.

        Example Usage:
            -- Prints a message when PlayerMessageSend is triggered
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
            client (Player) – The player whose model changed.
            model (string) – The new model path.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when PlayerModelChanged is triggered
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
            client (Player) – Player using the door.
            entity (Entity) – Door entity targeted.

        Realm:
            Server

        Returns:
            bool|nil: false to disallow, true to allow, or nil to let other hooks decide.

        Example Usage:
            -- Prints a message when PlayerUseDoor is triggered
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

        Parameters:
            None

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Set up a prepared SQL statement for later use.
            hook.Add("RegisterPreparedStatements", "InitLogStatement", function()
                lia.db.prepare("insert_log", "INSERT INTO logs(text) VALUES(?)")
            end)
]]
--[[
        ShouldBarDraw(barName)

        Description:
            Determines whether a specific HUD bar should be drawn.

        Parameters:
            barName (string) – HUD bar identifier, e.g. "health" or "armor".

        Realm:
            Client

        Returns:
            bool|nil: false to hide, nil to allow.

        Example Usage:
            -- Prints a message when ShouldBarDraw is triggered
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
            client (Player) – Player to test.

        Realm:
            Client

        Returns:
            bool (true if 3rd-person should be disabled)

        Example Usage:
            -- Prints a message when ShouldDisableThirdperson is triggered
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

        Parameters:
            None

        Realm:
            Client

        Returns:
            bool|nil: true to hide, nil to allow rendering.

        Example Usage:
            -- Prints a message when ShouldHideBars is triggered
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
            state (bool) – true if third-person is enabled, false if disabled.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when thirdPersonToggled is triggered
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
            sectionName (string) – Target section name.
            fieldName (string) – Unique field identifier.
            labelText (string) – Text shown for the field.
            valueFunc (function) – Function returning the value string.

        Realm:
            Client

        Returns:
            None

        Example Usage:
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
            sectionName (string) – Section name that received the field.
            fieldName (string) – Identifier of the new field.
            labelText (string) – Field label.
            valueFunc (function) – Function returning the field value.

        Realm:
            Client

        Returns:
            None

        Example Usage:
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
            sectionName (string) – Section identifier.
            fieldName (string) – Bar field name.
            labelText (string) – Bar label text.
            minFunc (function) – Function returning the minimum value.
            maxFunc (function) – Function returning the maximum value.
            valueFunc (function) – Function returning the current value.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when F1OnAddBarField is triggered
            hook.Add("F1OnAddBarField", "TrackBars", function(section, name)
                print("Added bar", name)
            end)
]]
--[[
        CreateInformationButtons(pages)

        Description:
            Called while building the F1 information menu to populate navigation buttons.

        Parameters:
            pages (table) – Table to add page definitions into.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when CreateInformationButtons is triggered
            hook.Add("CreateInformationButtons", "AddHelpPage", function(pages)
                table.insert(pages, {name = "Help", drawFunc = function(parent) end})
            end)
]]
--[[
        PopulateConfigurationButtons(pages)

        Description:
            Invoked when the settings tab is constructed allowing new configuration pages.

        Parameters:
            pages (table) – Table to populate with config pages.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when PopulateConfigurationButtons is triggered
            hook.Add("PopulateConfigurationButtons", "AddControlsPage", function(pages)
                table.insert(pages, {name = "Controls", drawFunc = function(p) end})
            end)
]]
--[[
        InitializedKeybinds()

        Description:
            Called after keybinds have been loaded from disk.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when InitializedKeybinds is triggered
            hook.Add("InitializedKeybinds", "NotifyKeybinds", function()
                chat.AddText("Keybinds loaded")
            end)
]]
--[[
        getOOCDelay(client)

        Description:
            Allows modification of the cooldown delay between OOC messages.

        Parameters:
            client (Player) – Player sending OOC chat.

        Realm:
            Server

        Returns:
            number|nil – Custom cooldown in seconds.

        Example Usage:
            -- Prints a message when getOOCDelay is triggered
            hook.Add("getOOCDelay", "AdminOOC", function(ply)
                if ply:IsAdmin() then
                    return 5
                end
            end)
]]
--[[
        OnChatReceived(client, chatType, text, anonymous)

        Description:
            Runs on the client when chat text is received before display.
            Returning modified text will replace the message.

        Parameters:
            client (Player) – Player that sent the chat.
            chatType (string) – Chat type identifier.
            text (string) – Message text.
            anonymous (boolean) – True if anonymous chat.

        Realm:
            Client

        Returns:
            string|nil – Replacement text.

        Example Usage:
            -- Prints a message when OnChatReceived is triggered
            hook.Add("OnChatReceived", "CensorChat", function(ply, type, msg)
                return msg:gsub("badword", "****")
            end)
]]
--[[
        getAdjustedPartData(wearer, id)

        Description:
            Requests PAC3 part data after adjustments have been applied.

        Parameters:
            wearer (Entity) – Entity wearing the outfit.
            id (string) – Part identifier.

        Realm:
            Client

        Returns:
            table|nil – Adjusted part data.

        Example Usage:
            -- Prints a message when getAdjustedPartData is triggered
            hook.Add("getAdjustedPartData", "DebugParts", function(ply, partID)
                print("Requesting part", partID)
            end)
]]
--[[
        AdjustPACPartData(wearer, id, data)

        Description:
            Allows modules to modify PAC3 part data before it is attached.

        Parameters:
            wearer (Entity) – Entity wearing the part.
            id (string) – Part identifier.
            data (table) – Part data table.

        Realm:
            Client

        Returns:
            table|nil – Modified data table.

        Example Usage:
            -- Prints a message when AdjustPACPartData is triggered
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
            client (Player) – Player receiving the part.
            id (string) – Part identifier.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when attachPart is triggered
            hook.Add("attachPart", "AnnouncePart", function(ply, partID)
                print(ply, "received part", partID)
            end)
]]
--[[
        removePart(client, id)

        Description:
            Triggered when a PAC3 part is removed from a player.

        Parameters:
            client (Player) – Player losing the part.
            id (string) – Part identifier being removed.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when removePart is triggered
            hook.Add("removePart", "LogPartRemoval", function(ply, partID)
                print(partID, "removed from", ply)
            end)
]]
--[[
        OnPAC3PartTransfered(part)

        Description:
            Fired when a PAC3 outfit part transfers ownership to a ragdoll.

        Parameters:
            part (Entity) – The outfit part being transferred.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when OnPAC3PartTransfered is triggered
            hook.Add("OnPAC3PartTransfered", "TrackTransfers", function(p)
                print("Part transferred", p)
            end)
]]
--[[
        DrawPlayerRagdoll(entity)

        Description:
            Allows custom rendering of a player's ragdoll created by PAC3.

        Parameters:
            entity (Entity) – Ragdoll entity to draw.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when DrawPlayerRagdoll is triggered
            hook.Add("DrawPlayerRagdoll", "TintRagdoll", function(ent)
                render.SetColorModulation(1,0,0)
            end)
]]
--[[
        setupPACDataFromItems()

        Description:
            Initializes PAC3 outfits from equipped items after modules load.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when setupPACDataFromItems is triggered
            hook.Add("setupPACDataFromItems", "InitPAC", function()
                print("Equipped PAC data loaded")
            end)
]]
--[[
        TryViewModel(entity)

        Description:
            Allows PAC3 to swap the view model entity for event checks.

        Parameters:
            entity (Entity) – The view model entity.

        Realm:
            Client

        Returns:
            Entity – Replacement entity.

        Example Usage:
            -- Prints a message when TryViewModel is triggered
            hook.Add("TryViewModel", "UsePlayerViewModel", function(ent)
                return ent == LocalPlayer():GetViewModel() and LocalPlayer() or ent
            end)
]]
--[[
        WeaponCycleSound()

        Description:
            Lets modules provide a custom sound when cycling weapons in the selector.

        Parameters:
            None

        Realm:
            Client

        Returns:
            string|nil – Sound path.
            number|nil – Playback pitch.

        Example Usage:
            -- Prints a message when WeaponCycleSound is triggered
            hook.Add("WeaponCycleSound", "SilentCycle", function()
                return "buttons/button15.wav", 100
            end)
]]
--[[
        WeaponSelectSound()

        Description:
            Similar to WeaponCycleSound but used when confirming a weapon choice.

        Parameters:
            None

        Realm:
            Client

        Returns:
            string|nil – Sound path.
            number|nil – Playback pitch.

        Example Usage:
            -- Prints a message when WeaponSelectSound is triggered
            hook.Add("WeaponSelectSound", "CustomSelectSound", function()
                return "buttons/button24.wav", 90
            end)
]]
--[[
        ShouldDrawWepSelect(client)

        Description:
            Determines if the weapon selection UI should be visible.

        Parameters:
            client (Player) – Player whose UI is drawing.

        Realm:
            Client

        Returns:
            boolean

        Example Usage:
            -- Prints a message when ShouldDrawWepSelect is triggered
            hook.Add("ShouldDrawWepSelect", "HideInVehicles", function(ply)
                return not ply:InVehicle()
            end)
]]
--[[
        CanPlayerChooseWeapon(weapon)

        Description:
            Checks whether the active weapon can be selected via the weapon wheel.

        Parameters:
            weapon (Weapon) – Weapon to name.

        Realm:
            Client

        Returns:
            boolean|nil – false to block selection.

        Example Usage:
            -- Prints a message when CanPlayerChooseWeapon is triggered
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
            client (Player) – Respawning player.
            baseTime (number) – Default respawn delay.

        Realm:
            Client

        Returns:
            number|nil – New respawn time.

        Example Usage:
            -- Prints a message when OverrideSpawnTime is triggered
            hook.Add("OverrideSpawnTime", "ShortRespawns", function(ply, time)
                if ply:IsAdmin() then return 2 end
            end)
]]
--[[
        ShouldRespawnScreenAppear()

        Description:
            Lets modules suppress the respawn HUD from showing.

        Parameters:
            None

        Realm:
            Client

        Returns:
            boolean|nil – false to hide.

        Example Usage:
            -- Prints a message when ShouldRespawnScreenAppear is triggered
            hook.Add("ShouldRespawnScreenAppear", "NoRespawnHUD", function()
                return false
            end)
]]
--[[
        VoiceToggled(enabled)

        Description:
            Fired when voice chat is enabled or disabled via config.

        Parameters:
            enabled (boolean) – Current voice chat state.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when VoiceToggled is triggered
            hook.Add("VoiceToggled", "AnnounceVoice", function(state)
                print("Voice chat set to", state)
            end)
]]
--[[
        RefreshFonts()

        Description:
            Requests recreation of all registered UI fonts.

        Parameters:
            None

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when RefreshFonts is triggered
            hook.Add("RefreshFonts", "ReloadFonts", function()
                print("Fonts refreshed")
            end)
]]
--[[
        AdjustCreationData(client, data, newData, originalData)

        Description:
            Allows modification of character creation data before the character is saved.

        Parameters:
            client (Player) – Player creating the character.
            data (table) – Sanitized creation data.
            newData (table) – Table to modify.
            originalData (table) – Raw data before adjustments.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when AdjustCreationData is triggered
            hook.Add("AdjustCreationData", "EnforceName", function(ply, data, newData)
                if data.name == "" then newData.name = "Unnamed" end
            end)
]]
--[[
        CanCharBeTransfered(character, newFaction, oldFaction)

        Description:
            Determines if a character may switch factions.

        Parameters:
            character (table) – Character being transferred.
            newFaction (table) – Faction to join.
            oldFaction (number) – Index of the current faction.

        Realm:
            Server

        Returns:
            bool|nil – false to block.

        Example Usage:
            -- Prints a message when CanCharBeTransfered is triggered
            hook.Add("CanCharBeTransfered", "BlockRestrictedFactions", function(char, faction)
                if faction.isRestricted then return false end
            end)
]]
--[[
        CanPlayerUseChar(client, character)

        Description:
            Called when a player attempts to load one of their characters.

        Parameters:
            client (Player) – Player loading the character.
            character (table) – Character being loaded.

        Realm:
            Server

        Returns:
            bool|nil – false to deny.

        Example Usage:
            -- Prints a message when CanPlayerUseChar is triggered
            hook.Add("CanPlayerUseChar", "CheckBans", function(ply, char)
                if char:isBanned() then return false, "Character banned" end
            end)
]]
--[[
        CanPlayerSwitchChar(client, currentChar, newChar)

        Description:
            Checks if a player can switch from their current character to another.

        Parameters:
            client (Player) – Player attempting the switch.
            currentChar (table) – Currently loaded character.
            newChar (table) – Character to switch to.

        Realm:
            Server

        Returns:
            bool|nil – false to block the switch.

        Example Usage:
            -- Prints a message when CanPlayerSwitchChar is triggered
            hook.Add("CanPlayerSwitchChar", "NoSwitchInCombat", function(ply)
                if ply:isInCombat() then return false end
            end)
]]
--[[
        CanPlayerLock(client, door)

        Description:
            Determines whether the player may lock the given door or vehicle.

        Parameters:
            client (Player) – Player attempting to lock.
            door (Entity) – Door or vehicle entity.

        Realm:
            Server

        Returns:
            bool|nil – false to disallow.

        Example Usage:
            -- Prints a message when CanPlayerLock is triggered
            hook.Add("CanPlayerLock", "AdminsAlwaysLock", function(ply)
                if ply:IsAdmin() then return true end
            end)
]]
--[[
        CanPlayerUnlock(client, door)

        Description:
            Determines whether the player may unlock the given door or vehicle.

        Parameters:
            client (Player) – Player attempting to unlock.
            door (Entity) – Door or vehicle entity.

        Realm:
            Server

        Returns:
            bool|nil – false to disallow.

        Example Usage:
            -- Prints a message when CanPlayerUnlock is triggered
            hook.Add("CanPlayerUnlock", "AdminsAlwaysUnlock", function(ply)
                if ply:IsAdmin() then return true end
            end)
]]
--[[
        CanPlayerModifyConfig(client, key)

        Description:
            Called when a player attempts to change a configuration value.

        Parameters:
            client (Player) – Player attempting the change.
            key (string) – Config key being modified.

        Realm:
            Server

        Returns:
            bool|nil – false to deny modification.

        Example Usage:
            -- Prints a message when CanPlayerModifyConfig is triggered
            hook.Add("CanPlayerModifyConfig", "RestrictConfig", function(ply, k)
                return ply:IsSuperAdmin()
            end)
]]
--[[
        CharDeleted(client, character)

        Description:
            Fired after a character is permanently removed.

        Parameters:
            client (Player) – Player who owned the character.
            character (table) – Character that was deleted.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when CharDeleted is triggered
            hook.Add("CharDeleted", "LogDeletion", function(ply, char)
                print(ply:Name(), "deleted character", char:getName())
            end)
]]
--[[
        CheckFactionLimitReached(faction, character, client)

        Description:
            Allows custom logic for determining if a faction has reached its player limit.

        Parameters:
            faction (table) – Faction being checked.
            character (table) – Character requesting to join.
            client (Player) – Owning player.

        Realm:
            Shared

        Returns:
            boolean

        Example Usage:
            -- Prints a message when CheckFactionLimitReached is triggered
            hook.Add("CheckFactionLimitReached", "IgnoreAdmins", function(faction, char, ply)
                if ply:IsAdmin() then
                    return false
                end
            end)
]]
--[[
        F1OnAddSection(sectionName, color, priority, location)

        Description:
            Triggered after AddSection inserts a new information section.

        Parameters:
            sectionName (string) – Name of the inserted section.
            color (Color) – Display color for the section.
            priority (number) – Sorting priority.
            location (number) – Column index.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when F1OnAddSection is triggered
            hook.Add("F1OnAddSection", "PrintSection", function(name)
                print("Added section", name)
            end)
]]
--[[
        GetWeaponName(weapon)

        Description:
            Allows overriding of the displayed weapon name in the selector.

        Parameters:
            weapon (Weapon) – Weapon to name.

        Realm:
            Client

        Returns:
            string|nil – Replacement name.

        Example Usage:
            -- Prints a message when GetWeaponName is triggered
            hook.Add("GetWeaponName", "UppercaseName", function(wep)
                return wep:GetClass():upper()
            end)
]]
--[[
        OnCharGetup(client, entity)

        Description:
            Called when a ragdolled character finishes getting up.

        Parameters:
            client (Player) – Player getting up.
            entity (Entity) – Ragdoll entity.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnCharGetup is triggered
            hook.Add("OnCharGetup", "NotifyGetup", function(ply)
                ply:ChatPrint("You stood up")
            end)
]]
--[[
        OnLocalizationLoaded()

        Description:
            Fired once language files finish loading.

        Parameters:
            None

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Prints a message when OnLocalizationLoaded is triggered
            hook.Add("OnLocalizationLoaded", "PrintLang", function()
                print("Localization ready")
            end)
]]
--[[
        OnPlayerObserve(client, state)

        Description:
            Called when a player's observe mode is toggled.

        Parameters:
            client (Player) – Player toggling observe mode.
            state (boolean) – True to enable observing.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when OnPlayerObserve is triggered
            hook.Add("OnPlayerObserve", "AnnounceObserve", function(ply, s)
                print(ply, s and "entered" or "left", "observe mode")
            end)
]]
--[[
        PlayerLoadedChar(client, character, previousChar)

        Description:
            Runs after a character has been loaded and set up for a player.

        Parameters:
            client (Player) – Player who loaded the character.
            character (table) – New character object.
            previousChar (table|nil) – Previously active character.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when PlayerLoadedChar is triggered
            hook.Add("PlayerLoadedChar", "WelcomeBack", function(ply, char)
                ply:ChatPrint("Welcome, " .. char:getName())
            end)
]]
--[[
        PrePlayerLoadedChar(client, newChar, oldChar)

        Description:
            Fired right before a player switches to a new character.

        Parameters:
            client (Player) – Player switching characters.
            newChar (table) – Character being loaded.
            oldChar (table|nil) – Character being left.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when PrePlayerLoadedChar is triggered
            hook.Add("PrePlayerLoadedChar", "SaveStuff", function(ply, new, old)
                print("Switching characters")
            end)
]]
--[[
        PostPlayerLoadedChar(client, character, previousChar)

        Description:
            Called after PlayerLoadedChar to allow post-load operations.

        Parameters:
            client (Player) – Player that finished loading.
            character (table) – Active character table.
            previousChar (table|nil) – Previous character if any.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when PostPlayerLoadedChar is triggered
            hook.Add("PostPlayerLoadedChar", "GiveItems", function(ply, char)
                -- Give starter items here
            end)
]]
--[[
        PlayerSay(client, text)

        Description:
            Custom hook executed when a player sends a chat message server-side.

        Parameters:
            client (Player) – Speaking player.
            text (string) – Message content.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when PlayerSay is triggered
            hook.Add("PlayerSay", "LogChat", function(ply, msg)
                print(ply:Name() .. ": " .. msg)
            end)
]]
--[[
        PopulateAdminStick(menu, target)

        Description:
            Called after the admin stick menu is created so additional commands can be added.

        Parameters:
            menu (DermaPanel) – Context menu panel.
            target (Entity) – Target entity of the admin stick.

        Realm:
            Client

        Returns:
            None

        Example Usage:
            -- Prints a message when PopulateAdminStick is triggered
            hook.Add("PopulateAdminStick", "AddCustomOption", function(menu, ent)
                menu:AddOption("Wave", function() RunConsoleCommand("act", "wave") end)
            end)
]]
--[[
        TicketSystemClaim(admin, requester)

        Description:
            Fired when a staff member claims a help ticket.

        Parameters:
            admin (Player) – Staff member claiming the ticket.
            requester (Player) – Player who opened the ticket.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when TicketSystemClaim is triggered
            hook.Add("TicketSystemClaim", "NotifyClaim", function(staff, ply)
                staff:ChatPrint("Claimed ticket from " .. ply:Name())
            end)
]]
--[[
        liaOptionReceived(client, key, value)

        Description:
            Triggered when a shared option value is changed.

        Parameters:
            client (Player|nil) – Player that changed the option or nil if server.
            key (string) – Option identifier.
            value (any) – New value.

        Realm:
            Server

        Returns:
            None

        Example Usage:
            -- Prints a message when liaOptionReceived is triggered
            hook.Add("liaOptionReceived", "PrintOptionChange", function(_, k, v)
                print("Option", k, "set to", v)
            end)
]]
