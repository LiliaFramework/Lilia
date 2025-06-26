        ## LoadCharInformation

        **Realm:** Client

        **Description:**
            Called after the F1 menu panel is created so additional sections can be added.
            Populates the character information sections of the F1 menu.
            

        ---

        ### Example

            ```lua
            -- Prints a message after the info panel is built.
            hook.Add("LoadCharInformation", "PrintLoad", function()
            print("F1 information sections loaded")
            end)
            ```

        ## CreateMenuButtons

        **Realm:** Client

        **Description:**
            Executed during menu creation allowing you to define custom tabs.
            Allows modules to insert additional tabs into the F1 menu.
            

        ---

        ### Parameters

            * **tabs** *(table)*: Table to add menu definitions to.

        ---

        ### Example

            ```lua
            -- Inserts a custom "Help" tab into the F1 menu.
            hook.Add("CreateMenuButtons", "AddHelpTab", function(tabs)
            tabs.help = {text = "Help", panel = "liaHelp"}
            end)
            ```

        ## DrawLiliaModelView

        **Realm:** Client

        **Description:**
            Runs every frame when the character model panel draws.
            Lets code draw over the model view used in character menus.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: The model panel being drawn.
            * **entity** *(Entity)*: Model entity displayed.

        ---

        ### Example

            ```lua
            -- Draws "Preview" text over the character model each frame.
            hook.Add("DrawLiliaModelView", "Watermark", function(panel, entity)
            draw.SimpleText("Preview", "Trebuchet24", 8, 8, color_white)
            end)
            ```

        ## ShouldAllowScoreboardOverride

        **Realm:** Client

        **Description:**
            Queries if a scoreboard field like the player's name or model may be replaced.
            Determines if a scoreboard field can be overridden.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player being displayed.
            * **field** *(string)*: Field name such as "name" or "model".

        ---

        ### Example

            ```lua
            -- Allows other hooks to replace player names on the scoreboard.
            hook.Add("ShouldAllowScoreboardOverride", "OverrideNames", function(ply, field)
            if field == "name" then return true end
            end)
            ```

        ## GetDisplayedName

        **Realm:** Client

        **Description:**
            Provides the player name text shown in UI panels.
            Returns a display name for a player.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player to query.

        ---

        ### Example

            ```lua
            -- Displays player names with an admin prefix.
            hook.Add("GetDisplayedName", "AdminPrefix", function(ply)
            if ply:IsAdmin() then
            return "[ADMIN] " .. ply:Nick()
            end
            end)
            ```

        ## PlayerEndVoice

        **Realm:** Client

        **Description:**
            Fired when a player's voice indicator is removed from the HUD.
            Called when a player's voice panel is removed.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player whose panel ended.

        ---

        ### Example

            ```lua
            -- Announces in chat when someone stops using voice chat.
            hook.Add("PlayerEndVoice", "NotifyVoiceStop", function(ply)
            chat.AddText(ply:Nick() .. " stopped talking")
            end)
            ```

        ## SpawnlistContentChanged

        **Realm:** Client

        **Description:**
            Triggered when a spawn icon is removed from the extended spawn menu.
            Fired when content is removed from the spawn menu.
            

        ---

        ### Parameters

            * **icon** *(Panel)*: Icon affected.

        ---

        ### Example

            ```lua
            -- Lets you react when a spawn menu icon is removed.
            hook.Add("SpawnlistContentChanged", "IconRemoved", function(icon)
            print("Removed spawn icon", icon)
            end)
            ```

        ## ItemPaintOver

        **Realm:** Client

        **Description:**
            Gives a chance to draw additional info over item icons.
            Allows drawing over item icons in inventories.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Icon panel.
            * **itemTable** *(table)*: Item data.
            * **width** *(number)*: Panel width.
            * **height** *(number)*: Panel height.

        ---

        ### Example

            ```lua
            -- Draws the item quantity in the bottom-right corner.
            hook.Add("ItemPaintOver", "ShowQuantity", function(panel, item, w, h)
            draw.SimpleText(item.qty or 1, "DermaDefault", w - 4, h - 4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end)
            ```

        ## OnCreateItemInteractionMenu

        **Realm:** Client

        **Description:**
            Allows extensions to populate the right-click menu for an item.
            Allows overriding the context menu for an item icon.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Icon panel.
            * **menu** *(Panel)*: Menu being built.
            * **itemTable** *(table)*: Item data.

        ---

        ### Example

            ```lua
            -- Adds an "Inspect" choice to an item's context menu.
            hook.Add("OnCreateItemInteractionMenu", "AddInspect", function(panel, menu, item)
            menu:AddOption("Inspect", function() print("Inspecting", item.name) end)
            end)
            ```

        ## CanRunItemAction

        **Realm:** Client

        **Description:**
            Determines whether an item action should be displayed.
            Determines whether a specific item action is allowed.
            

        ---

        ### Parameters

            * **itemTable** *(table)*: Item data.
            * **action** *(string)*: Action key.

        ---

        ### Returns

            * boolean – True if the action can run.

        ---

        ### Example

            ```lua
            -- Disables the drop action for all items.
            hook.Add("CanRunItemAction", "BlockDrop", function(item, action)
            if action == "drop" then return false end
            end)
            ```

        ## GetMaxStartingAttributePoints

        **Realm:** Client

        **Description:**
            Lets you change how many attribute points a new character receives.
            Retrieves the maximum attribute points available at character creation.
            

        ---

        ### Parameters

            * **client** *(Player)*: Viewing player.
            * **context** *(string)*: Creation context.

        ---

        ### Example

            ```lua
            -- Gives every new character 60 starting points.
            hook.Add("GetMaxStartingAttributePoints", "DoublePoints", function(client)
            return 60
            end)
            ```

        ## GetAttributeStartingMax

        **Realm:** Client

        **Description:**
            Sets a limit for a specific attribute at character creation.
            Returns the starting maximum for a specific attribute.
            

        ---

        ### Parameters

            * **client** *(Player)*: Viewing player.
            * **attribute** *(string)*: Attribute identifier.

        ---

        ### Example

            ```lua
            -- Limits the Strength attribute to a maximum of 20.
            hook.Add("GetAttributeStartingMax", "CapStrength", function(client, attribute)
            if attribute == "strength" then return 20 end
            end)
            ```

        ## ShouldShowPlayerOnScoreboard

        **Realm:** Client

        **Description:**
            Return false to omit players from the scoreboard.
            Determines if a player should appear on the scoreboard.
            

        ---

        ### Parameters

            * **player** *(Player)*: Player to test.

        ---

        ### Example

            ```lua
            -- Stops bots from showing up on the scoreboard.
            hook.Add("ShouldShowPlayerOnScoreboard", "HideBots", function(ply)
            if ply:IsBot() then return false end
            end)
            ```

        ## ShowPlayerOptions

        **Realm:** Client

        **Description:**
            Populate the scoreboard context menu with extra options.
            Allows modules to add scoreboard options for a player.
            

        ---

        ### Parameters

            * **player** *(Player)*: Target player.
            * **options** *(table)*: Options table to populate.

        ---

        ### Example

            ```lua
            -- Adds a friendly "Wave" choice in the scoreboard menu.
            hook.Add("ShowPlayerOptions", "WaveOption", function(ply, options)
            options[#options + 1] = {name = "Wave", func = function() RunConsoleCommand("say", "/me waves to " .. ply:Nick()) end}
            end)
            ```

        ## GetDisplayedDescription

        **Realm:** Client

        **Description:**
            Supplies the description text shown on the scoreboard.
            Returns the description text to display for a player.
            

        ---

        ### Parameters

            * **player** *(Player)*: Target player.
            * **isOOC** *(boolean)*: Whether OOC description is requested.

        ---

        ### Example

            ```lua
            -- Shows an OOC description when requested by the scoreboard.
            hook.Add("GetDisplayedDescription", "OOCDesc", function(ply, isOOC)
            if isOOC then return ply:GetNWString("oocDesc", "") end
            end)
            ```

        ## ChatTextChanged

        **Realm:** Client

        **Description:**
            Runs whenever the chat entry text is modified.
            Called whenever the chat entry text changes.
            

        ---

        ### Parameters

            * **text** *(string)*: Current text.

        ---

        ### Example

            ```lua
            -- Displays a hint when the user types "/help".
            hook.Add("ChatTextChanged", "CommandHint", function(text)
            if text == "/help" then chat.AddText("Type /commands for commands list") end
            end)
            ```

        ## FinishChat

        **Realm:** Client

        **Description:**
            Fires when the chat box closes.
            Fired when the chat box is closed.
            

        ---

        ### Example

            ```lua
            -- Prints a message whenever the chat box closes.
            hook.Add("FinishChat", "ChatClosed", function()
            print("Chat closed")
            end)
            ```

        ## StartChat

        **Realm:** Client

        **Description:**
            Fires when the chat box opens.
            Fired when the chat box is opened.
            

        ---

        ### Example

            ```lua
            -- Plays a sound whenever the chat box opens.
            hook.Add("StartChat", "ChatOpened", function()
            surface.PlaySound("buttons/lightswitch2.wav")
            end)
            ```

        ## ChatAddText

        **Realm:** Client

        **Description:**
            Allows modification of the markup before chat messages are printed.
            Allows modification of markup before chat text is shown.
            

        ---

        ### Parameters

            * **text** *(string)*: Base markup text.
            * ... – Additional segments.

        ---

        ### Returns

            * string – Modified markup text.

        ---

        ### Example

            ```lua
            -- Turns chat messages green before they appear.
            hook.Add("ChatAddText", "GreenSystem", function(text, ...)
            return Color(0,255,0), text, ...
            end)
            ```

        ## DisplayItemRelevantInfo

        **Realm:** Client

        **Description:**
            Add extra lines to an item tooltip.
            Populates additional information for an item tooltip.
            

        ---

        ### Parameters

            * **extra** *(table)*: Info table to fill.
            * **client** *(Player)*: Local player.
            * **item** *(table)*: Item being displayed.

        ---

        ### Example

            ```lua
            -- Adds the item's weight to its tooltip.
            hook.Add("DisplayItemRelevantInfo", "ShowWeight", function(extra, client, item)
            extra[#extra + 1] = "Weight: " .. (item.weight or 0)
            end)
            ```

        ## GetMainMenuPosition

        **Realm:** Client

        **Description:**
            Returns the camera position and angle for the main menu character preview.
            Provides the camera position and angle for the main menu model.
            

        ---

        ### Parameters

            * **character** *(Character)*: Character being viewed.

        ---

        ### Returns

            * Vector, Angle – Position and angle values.

        ---

        ### Example

            ```lua
            -- Positions the main menu camera with a slight offset.
            hook.Add("GetMainMenuPosition", "OffsetCharView", function(character)
            return Vector(30, 10, 60), Angle(0, 30, 0)
            end)
            ```

        ## CanDeleteChar

        **Realm:** Client

        **Description:**
            Return false here to prevent character deletion.
            Determines if a character can be deleted.
            

        ---

        ### Parameters

            * **characterID** *(number)*: Identifier of the character.

        ---

        ### Returns

            * boolean – False to disallow deletion.

        ---

        ### Example

            ```lua
            -- Blocks deletion of the first character slot.
            hook.Add("CanDeleteChar", "ProtectSlot1", function(id)
            if id == 1 then return false end
            end)
            ```

        ## LoadMainMenuInformation

        **Realm:** Client

        **Description:**
            Lets modules insert additional information on the main menu info panel.
            Allows modules to populate extra information on the main menu panel.
            

        ---

        ### Parameters

            * **info** *(table)*: Table to receive information.
            * **character** *(Character)*: Selected character.

        ---

        ### Example

            ```lua
            -- Adds the character's faction to the menu info panel.
            hook.Add("LoadMainMenuInformation", "AddFactionInfo", function(info, character)
            info.faction = character:getFaction() or "Citizen"
            end)
            ```

        ## CanPlayerCreateChar

        **Realm:** Client

        **Description:**
            Checks if the local player may start creating a character.
            Determines if the player may create a new character.
            

        ---

        ### Parameters

            * **player** *(Player)*: Local player.

        ---

        ### Returns

            * boolean – False to disallow creation.

        ---

        ### Example

            ```lua
            -- Restricts character creation to admins only.
            hook.Add("CanPlayerCreateChar", "AdminsOnly", function(ply)
            if not ply:IsAdmin() then return false end
            end)
            ```

        ## ModifyCharacterModel

        **Realm:** Client

        **Description:**
            Lets you edit the clientside model used in the main menu.
            Allows adjustments to the character model in menus.
            

        ---

        ### Parameters

            * **entity** *(Entity)*: Model entity.
            * **character** *(Character)*: Character data.

        ---

        ### Example

            ```lua
            -- Changes a bodygroup on the preview model.
            hook.Add("ModifyCharacterModel", "ApplyBodygroup", function(ent, character)
            ent:SetBodygroup(2, 1)
            end)
            ```

        ## ConfigureCharacterCreationSteps

        **Realm:** Client

        **Description:**
            Add or reorder steps in the character creation flow.
            Lets modules alter the character creation step layout.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Creation panel.

        ---

        ### Example

            ```lua
            -- Adds a custom "background" step to the character creator.
            hook.Add("ConfigureCharacterCreationSteps", "InsertBackground", function(panel)
            panel:AddStep("background")
            end)
            ```

        ## GetMaxPlayerChar

        **Realm:** Client

        **Description:**
            Override to change how many characters a player can have.
            Returns the maximum number of characters a player can have.
            

        ---

        ### Parameters

            * **player** *(Player)*: Local player.

        ---

        ### Returns

            * number – Maximum character count.

        ---

        ### Example

            ```lua
            -- Gives admins extra character slots.
            hook.Add("GetMaxPlayerChar", "AdminSlots", function(ply)
            return ply:IsAdmin() and 10 or 5
            end)
            ```

        ## ShouldMenuButtonShow

        **Realm:** Client

        **Description:**
            Return false and a reason to hide buttons on the main menu.
            Determines if a button should be visible on the main menu.
            

        ---

        ### Parameters

            * **name** *(string)*: Button identifier.

        ---

        ### Returns

            * boolean, string – False and reason to hide.

        ---

        ### Example

            ```lua
            -- Hides the delete button when the feature is locked.
            hook.Add("ShouldMenuButtonShow", "HideDelete", function(name)
            if name == "delete" then return false, "Locked" end
            end)
            ```

        ## ResetCharacterPanel

        **Realm:** Client

        **Description:**
            Called when the character creation panel should reset.
            Called to reset the character creation panel.
            

        ---

        ### Example

            ```lua
            -- Notifies whenever the creation panel resets.
            hook.Add("ResetCharacterPanel", "ClearFields", function()
            print("Character creator reset")
            end)
            ```

        ## EasyIconsLoaded

        **Realm:** Client

        **Description:**
            Notifies when the EasyIcons font sheet has loaded.
            Fired when the EasyIcons library has loaded.
            

        ---

        ### Example

            ```lua
            -- Prints a message once the EasyIcons font is loaded.
            hook.Add("EasyIconsLoaded", "Notify", function()
            print("EasyIcons ready")
            end)
            ```

        ## CAMI.OnUsergroupRegistered

        **Realm:** Shared

        **Description:**
            Called when CAMI registers a new usergroup.
            CAMI notification that a usergroup was registered.
            

        ---

        ### Parameters

            * **usergroup** *(table)*: Registered usergroup data.
            * **source** *(string)*: Source identifier.

        ---

        ### Example

            ```lua
            -- Logs newly registered CAMI usergroups.
            hook.Add("CAMI.OnUsergroupRegistered", "LogGroup", function(group)
            print("Registered group:", group.Name)
            end)
            ```

        ## CAMI.OnUsergroupUnregistered

        **Realm:** Shared

        **Description:**
            Called when a usergroup is removed from CAMI.
            CAMI notification that a usergroup was removed.
            

        ---

        ### Parameters

            * **usergroup** *(table)*: Unregistered usergroup data.
            * **source** *(string)*: Source identifier.

        ---

        ### Example

            ```lua
            -- Logs whenever a usergroup is removed from CAMI.
            hook.Add("CAMI.OnUsergroupUnregistered", "LogRemoval", function(group)
            print("Removed group:", group.Name)
            end)
            ```

        ## CAMI.OnPrivilegeRegistered

        **Realm:** Shared

        **Description:**
            Fired when a privilege is created in CAMI.
            CAMI notification that a privilege was registered.
            

        ---

        ### Parameters

            * **privilege** *(table)*: Privilege data.

        ---

        ### Example

            ```lua
            -- Reports when a new CAMI privilege is registered.
            hook.Add("CAMI.OnPrivilegeRegistered", "LogPrivilege", function(priv)
            print("Registered privilege:", priv.Name)
            end)
            ```

        ## CAMI.OnPrivilegeUnregistered

        **Realm:** Shared

        **Description:**
            Fired when a privilege is removed from CAMI.
            CAMI notification that a privilege was unregistered.
            

        ---

        ### Parameters

            * **privilege** *(table)*: Privilege data.

        ---

        ### Example

            ```lua
            -- Reports when a CAMI privilege is removed.
            hook.Add("CAMI.OnPrivilegeUnregistered", "LogPrivRemoval", function(priv)
            print("Removed privilege:", priv.Name)
            end)
            ```

        ## CAMI.PlayerHasAccess

        **Realm:** Shared

        **Description:**
            Allows an override of player privilege checks.
            Allows external libraries to override privilege checks.
            

        ---

        ### Parameters

            * **handler** *(function)*: Default handler.
            * **actor** *(Player)*: Player requesting access.
            * **privilegeName** *(string)*: Privilege identifier.
            * **callback** *(function)*: Callback to receive result.
            * **target** *(Player)*: Optional target player.
            * **extra** *(table)*: Extra information table.

        ---

        ### Example

            ```lua
            -- Lets superadmins bypass privilege checks.
            hook.Add("CAMI.PlayerHasAccess", "AllowSuperadmins", function(_, actor, priv, cb)
            if actor:IsSuperAdmin() then cb(true) return true end
            end)
            ```

        ## CAMI.SteamIDHasAccess

        **Realm:** Shared

        **Description:**
            Allows an override of SteamID-based privilege checks.
            Similar to PlayerHasAccess but for SteamIDs.
            

        ---

        ### Parameters

            * **handler** *(function)*: Default handler.
            * **steamID** *(string)*: SteamID to check.
            * **privilegeName** *(string)*: Privilege identifier.
            * **callback** *(function)*: Callback to receive result.
            * **targetID** *(string)*: Target SteamID.
            * **extra** *(table)*: Extra information table.

        ---

        ### Example

            ```lua
            -- Grants access for a specific SteamID.
            hook.Add("CAMI.SteamIDHasAccess", "AllowSteamID", function(_, steamID, priv, cb)
            if steamID == "STEAM_0:1:1" then cb(true) return true end
            end)
            ```

        ## CAMI.PlayerUsergroupChanged

        **Realm:** Shared

        **Description:**
            Notification that a player's group changed.
            Fired when a player's usergroup has changed.
            

        ---

        ### Parameters

            * **player** *(Player)*: Affected player.
            * **oldGroup** *(string)*: Previous group.
            * **newGroup** *(string)*: New group.
            * **source** *(string)*: Source identifier.

        ---

        ### Example

            ```lua
            -- Announces when a player's usergroup changes.
            hook.Add("CAMI.PlayerUsergroupChanged", "AnnounceChange", function(ply, old, new)
            print(ply:Nick() .. " moved from " .. old .. " to " .. new)
            end)
            ```

        ## CAMI.SteamIDUsergroupChanged

        **Realm:** Shared

        **Description:**
            Notification that a SteamID's group changed.
            Fired when a SteamID's usergroup has changed.
            

        ---

        ### Parameters

            * **steamID** *(string)*: Affected SteamID.
            * **oldGroup** *(string)*: Previous group.
            * **newGroup** *(string)*: New group.
            * **source** *(string)*: Source identifier.

        ---

        ### Example

            ```lua
            -- Logs usergroup changes by SteamID.
            hook.Add("CAMI.SteamIDUsergroupChanged", "LogSIDChange", function(sid, old, new)
            print(sid .. " changed from " .. old .. " to " .. new)
            end)
            ```

        ## TooltipLayout

        **Realm:** Client

        **Description:**
            Customize tooltip sizing and layout before it appears.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Tooltip panel being laid out.

        ---

        ### Example

            ```lua
            -- Sets a fixed width for tooltips before layout.
            hook.Add("TooltipLayout", "FixedWidth", function(panel)
            panel:SetWide(200)
            end)
            ```

        ## TooltipPaint

        **Realm:** Client

        **Description:**
            Draw custom visuals on the tooltip, returning true skips default painting.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Tooltip panel.
            * **width** *(number)*: Panel width.
            * **height** *(number)*: Panel height.

        ---

        ### Example

            ```lua
            -- Adds a dark background and skips default paint.
            hook.Add("TooltipPaint", "BlurBackground", function(panel, w, h)
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, 0, w, h)
            return true
            end)
            ```

        ## TooltipInitialize

        **Realm:** Client

        **Description:**
            Runs when a tooltip is opened for a panel.
            

        ---

        ### Parameters

            * **panel** *(Panel)*: Tooltip panel.
            * **target** *(Panel)*: Target panel that opened the tooltip.

        ---

        ### Example

            ```lua
            -- Fades tooltips in when they are created.
            hook.Add("TooltipInitialize", "SetupFade", function(panel, target)
            panel:SetAlpha(0)
            panel:AlphaTo(255, 0.2, 0)
            end)
            ```

        ## PlayerLoadout

        **Realm:** Server

        **Description:**
            Runs when a player spawns and equips items.
            Allows modification of the default loadout.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player being loaded out.

        ---

        ### Example

            ```lua
            -- Gives players a crowbar on spawn.
            hook.Add("PlayerLoadout", "GiveCrowbar", function(ply)
            ply:Give("weapon_crowbar")
            end)
            ```

        ## PlayerShouldPermaKill

        **Realm:** Server

        **Description:**
            Determines if a player's death should permanently kill their character.
            Return true to mark the character for deletion.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player that died.
            * **inflictor** *(Entity)*: Damage inflictor.
            * **attacker** *(Entity)*: Damage attacker.

        ---

        ### Example

            ```lua
            -- Prevent permanent death from fall damage.
            hook.Add("PlayerShouldPermaKill", "NoFallPK", function(ply, inflictor)
            if inflictor == game.GetWorld() then return false end
            end)
            ```

        ## CanPlayerDropItem

        **Realm:** Server

        **Description:**
            Checks if a player may drop an item.
            Return false to block dropping.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting to drop.
            * **item** *(table)*: Item being dropped.

        ---

        ### Example

            ```lua
            -- Disallow dropping locked items.
            hook.Add("CanPlayerDropItem", "NoLockedDrop", function(ply, item)
            if item.locked then return false end
            end)
            ```

        ## CanPlayerTakeItem

        **Realm:** Server

        **Description:**
            Determines if a player can pick up an item.
            Return false to prevent taking.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting pickup.
            * **item** *(table)*: Item in question.

        ---

        ### Example

            ```lua
            -- Block taking admin items.
            hook.Add("CanPlayerTakeItem", "NoAdminPickup", function(ply, item)
            if item.adminOnly then return false end
            end)
            ```

        ## CanPlayerEquipItem

        **Realm:** Server

        **Description:**
            Queries if a player can equip an item.
            Returning false stops the equip action.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player equipping.
            * **item** *(table)*: Item to equip.

        ---

        ### Example

            ```lua
            -- Allow equipping only if level requirement met.
            hook.Add("CanPlayerEquipItem", "CheckLevel", function(ply, item)
            if item.minLevel and ply:getChar():getAttrib("level", 0) < item.minLevel then
            return false
            end
            end)
            ```

        ## CanPlayerUnequipItem

        **Realm:** Server

        **Description:**
            Called before an item is unequipped.
            Return false to keep the item equipped.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player unequipping.
            * **item** *(table)*: Item being unequipped.

        ---

        ### Example

            ```lua
            -- Prevent unequipping cursed gear.
            hook.Add("CanPlayerUnequipItem", "Cursed", function(ply, item)
            if item.cursed then return false end
            end)
            ```

        ## PostPlayerSay

        **Realm:** Server

        **Description:**
            Runs after chat messages are processed.
            Allows reacting to player chat.
            

        ---

        ### Parameters

            * **client** *(Player)*: Speaking player.
            * **message** *(string)*: Chat text.
            * **chatType** *(string)*: Chat channel.
            * **anonymous** *(boolean)*: Whether the message was anonymous.

        ---

        ### Example

            ```lua
            -- Log all OOC chat.
            hook.Add("PostPlayerSay", "LogOOC", function(ply, msg, chatType)
            if chatType == "ooc" then print("[OOC]", ply:Nick(), msg) end
            end)
            ```

        ## ShouldSpawnClientRagdoll

        **Realm:** Server

        **Description:**
            Decides if a corpse ragdoll should spawn for a player.
            Return false to skip ragdoll creation.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player that died.

        ---

        ### Example

            ```lua
            -- Disable ragdolls for bots.
            hook.Add("ShouldSpawnClientRagdoll", "NoBotRagdoll", function(ply)
            if ply:IsBot() then return false end
            end)
            ```

        ## SaveData

        **Realm:** Server

        **Description:**
            Called when the framework saves persistent data.
            Modules can store custom information here.
            

        ---

        ### Example

            ```lua
            -- Save a timestamp to file.
            hook.Add("SaveData", "RecordTime", function()
            file.Write("lastsave.txt", os.time())
            end)
            ```

        ## PersistenceSave

        **Realm:** Server

        **Description:**
            Fires when map persistence should be written to disk.
            Allows adding extra persistent entities.
            

        ---

        ### Example

            ```lua
            hook.Add("PersistenceSave", "Notice", function()
            print("Saving persistent entities")
            end)
            ```

        ## LoadData

        **Realm:** Server

        **Description:**
            Triggered when stored data should be loaded.
            Modules can restore custom information here.
            

        ---

        ### Example

            ```lua
            hook.Add("LoadData", "LoadExtras", function()
            print("Loading custom data")
            end)
            ```

        ## PostLoadData

        **Realm:** Server

        **Description:**
            Called after all persistent data has loaded.
            Useful for post-processing.
            

        ---

        ### Example

            ```lua
            hook.Add("PostLoadData", "Ready", function()
            print("Data fully loaded")
            end)
            ```

        ## ShouldDataBeSaved

        **Realm:** Server

        **Description:**
            Queries if data saving should occur during shutdown.
            Return false to cancel saving.
            

        ---

        ### Example

            ```lua
            -- Skip saving during quick restarts.
            hook.Add("ShouldDataBeSaved", "NoSave", function()
            return game.IsDedicated() and os.getenv("NOSAVE")
            end)
            ```

        ## OnCharDisconnect

        **Realm:** Server

        **Description:**
            Called when a player's character disconnects.
            Provides a last chance to handle data.
            

        ---

        ### Parameters

            * **client** *(Player)*: Disconnecting player.
            * **character** *(Character)*: Their character.

        ---

        ### Example

            ```lua
            hook.Add("OnCharDisconnect", "Goodbye", function(ply, char)
            print(char:getName(), "has left")
            end)
            ```

        ## SetupBotPlayer

        **Realm:** Server

        **Description:**
            Initializes a bot's character when it first joins.
            Allows custom bot setup.
            

        ---

        ### Parameters

            * **client** *(Player)*: Bot player.

        ---

        ### Example

            ```lua
            hook.Add("SetupBotPlayer", "WelcomeBot", function(bot)
            bot:ChatPrint("Beep boop!")
            end)
            ```

        ## PlayerLiliaDataLoaded

        **Realm:** Server

        **Description:**
            Fired after a player's personal data has loaded.
            Useful for syncing additional info.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player that loaded data.

        ---

        ### Example

            ```lua
            hook.Add("PlayerLiliaDataLoaded", "SendWelcome", function(ply)
            ply:ChatPrint("Data loaded")
            end)
            ```

        ## PostPlayerInitialSpawn

        **Realm:** Server

        **Description:**
            Runs after the player entity has spawned and data is ready.
            Allows post-initialization logic.
            

        ---

        ### Parameters

            * **client** *(Player)*: Newly spawned player.

        ---

        ### Example

            ```lua
            hook.Add("PostPlayerInitialSpawn", "Greet", function(ply)
            print("Hello", ply:Nick())
            end)
            ```

        ## FactionOnLoadout

        **Realm:** Server

        **Description:**
            Gives factions a chance to modify player loadouts.
            Runs before weapons are equipped.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player being equipped.

        ---

        ### Example

            ```lua
            hook.Add("FactionOnLoadout", "GiveRadio", function(ply)
            if ply:getChar():getFaction() == "police" then
            ply:Give("weapon_radio")
            end
            end)
            ```

        ## ClassOnLoadout

        **Realm:** Server

        **Description:**
            Allows classes to modify the player's starting gear.
            Executed prior to PostPlayerLoadout.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player being equipped.

        ---

        ### Example

            ```lua
            hook.Add("ClassOnLoadout", "MedicItems", function(ply)
            if ply:getChar():getClass() == "medic" then
            ply:Give("medkit")
            end
            end)
            ```

        ## PostPlayerLoadout

        **Realm:** Server

        **Description:**
            Called after the player has been equipped.
            Last chance to modify the loadout.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player loaded out.

        ---

        ### Example

            ```lua
            hook.Add("PostPlayerLoadout", "SetColor", function(ply)
            ply:SetPlayerColor(Vector(0,1,0))
            end)
            ```

        ## FactionPostLoadout

        **Realm:** Server

        **Description:**
            Runs after faction loadout logic completes.
            Allows post-loadout tweaks.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player affected.

        ---

        ### Example

            ```lua
            hook.Add("FactionPostLoadout", "Shout", function(ply)
            if ply:getChar():getFaction() == "soldier" then
            ply:EmitSound("npc/combine_soldier/gear6.wav")
            end
            end)
            ```

        ## ClassPostLoadout

        **Realm:** Server

        **Description:**
            Runs after class loadout logic completes.
            Allows post-loadout tweaks for classes.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player affected.

        ---

        ### Example

            ```lua
            hook.Add("ClassPostLoadout", "Pose", function(ply)
            ply:ConCommand("act muscle")
            end)
            ```

        ## GetDefaultInventoryType

        **Realm:** Server

        **Description:**
            Returns the inventory type used for new characters.
            Modules can override to provide custom types.
            

        ---

        ### Parameters

            * **character** *(Character)*: Character being created.

        ---

        ### Example

            ```lua
            hook.Add("GetDefaultInventoryType", "UseGrid", function()
            return "GridInv"
            end)
            ```

        ## ShouldDeleteSavedItems

        **Realm:** Server

        **Description:**
            Decides whether saved persistent items should be deleted on load.
            Return true to wipe them from the database.
            

        ---

        ### Example

            ```lua
            hook.Add("ShouldDeleteSavedItems", "ClearDrops", function()
            return false
            end)
            ```

        ## OnSavedItemLoaded

        **Realm:** Server

        **Description:**
            Called after map items have been loaded from storage.
            Provides the table of created items.
            

        ---

        ### Parameters

            * **items** *(table)*: Loaded item entities.

        ---

        ### Example

            ```lua
            hook.Add("OnSavedItemLoaded", "PrintCount", function(items)
            print("Loaded", #items, "items")
            end)
            ```

        ## ShouldDrawEntityInfo

        **Realm:** Client

        **Description:**
            Determines if world-space info should be rendered for an entity.
            Return false to hide the tooltip.
            

        ---

        ### Parameters

            * **entity** *(Entity)*: Entity being considered.

        ---

        ### Example

            ```lua
            hook.Add("ShouldDrawEntityInfo", "HideNPCs", function(ent)
            if ent:IsNPC() then return false end
            end)
            ```

        ## DrawEntityInfo

        **Realm:** Client

        **Description:**
            Allows custom drawing of entity information in the world.
            Drawn every frame while visible.
            

        ---

        ### Parameters

            * **entity** *(Entity)*: Entity to draw info for.
            * **alpha** *(number)*: Current alpha value.
            * **position** *(table)*: Screen position table.

        ---

        ### Example

            ```lua
            hook.Add("DrawEntityInfo", "LabelProps", function(ent, a, pos)
            draw.SimpleText(ent:GetClass(), "DermaDefault", pos.x, pos.y, Color(255,255,255,a))
            end)
            ```

        ## GetInjuredText

        **Realm:** Client

        **Description:**
            Provides the health status text and color for a player.
            Return a table with text and color values.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player to check.

        ---

        ### Example

            ```lua
            hook.Add("GetInjuredText", "SimpleHealth", function(ply)
            if ply:Health() <= 20 then return {"Critical", Color(255,0,0)} end
            end)
            ```

        ## ShouldDrawPlayerInfo

        **Realm:** Client

        **Description:**
            Determines if character info should draw above a player.
            Return false to suppress drawing.
            

        ---

        ### Parameters

            * **player** *(Player)*: Player being rendered.

        ---

        ### Example

            ```lua
            hook.Add("ShouldDrawPlayerInfo", "HideLocal", function(ply)
            if ply == LocalPlayer() then return false end
            end)
            ```

        ## DrawCharInfo

        **Realm:** Client

        **Description:**
            Allows modules to add lines to the character info display.
            Called when building the info table.
            

        ---

        ### Parameters

            * **player** *(Player)*: Player being displayed.
            * **character** *(Character)*: Their character data.
            * **info** *(table)*: Table to add lines to.

        ---

        ### Example

            ```lua
            hook.Add("DrawCharInfo", "JobTitle", function(ply, char, info)
            info[#info + 1] = {"Job: " .. (char:getClass() or "None")}
            end)
            ```

        ## ItemShowEntityMenu

        **Realm:** Client

        **Description:**
            Opens the context menu for a world item when used.
            Allows replacing the default menu.
            

        ---

        ### Parameters

            * **entity** *(Entity)*: Item entity clicked.

        ---

        ### Example

            ```lua
            hook.Add("ItemShowEntityMenu", "QuickTake", function(ent)
            print("Opening menu for", ent)
            end)
            ```

        ## PreLiliaLoaded

        **Realm:** Client

        **Description:**
            Fired just before the client finishes loading the framework.
            Useful for setup tasks.
            

        ---

        ### Example

            ```lua
            hook.Add("PreLiliaLoaded", "Prep", function()
            print("About to finish loading")
            end)
            ```

        ## LiliaLoaded

        **Realm:** Client

        **Description:**
            Indicates the client finished initializing the framework.
            Modules can start creating panels here.
            

        ---

        ### Example

            ```lua
            hook.Add("LiliaLoaded", "Ready", function()
            print("Lilia client ready")
            end)
            ```

        ## InventoryDataChanged

        **Realm:** Client

        **Description:**
            Notifies when inventory metadata changes.
            Provides old and new values.
            

        ---

        ### Parameters

            * **inventory** *(table)*: Inventory affected.
            * **key** *(string)*: Data key.
            * **oldValue** *(any)*: Previous value.
            * **value** *(any)*: New value.

        ---

        ### Example

            ```lua
            hook.Add("InventoryDataChanged", "TrackWeight", function(inv, k, old, new)
            if k == "weight" then print("Weight changed to", new) end
            end)
            ```

        ## ItemInitialized

        **Realm:** Client

        **Description:**
            Called when a new item instance is created clientside.
            Allows additional setup for the item.
            

        ---

        ### Parameters

            * **item** *(table)*: Item created.

        ---

        ### Example

            ```lua
            hook.Add("ItemInitialized", "PrintID", function(item)
            print("Created item", item.uniqueID)
            end)
            ```

        ## InventoryInitialized

        **Realm:** Client

        **Description:**
            Fired when an inventory instance finishes loading.
            Modules may modify it here.
            

        ---

        ### Parameters

            * **inventory** *(table)*: Inventory initialized.

        ---

        ### Example

            ```lua
            hook.Add("InventoryInitialized", "AnnounceInv", function(inv)
            print("Inventory", inv:getID(), "ready")
            end)
            ```

        ## InventoryItemAdded

        **Realm:** Client

        **Description:**
            Invoked when an item is placed into an inventory.
            Lets code react to the addition.
            

        ---

        ### Parameters

            * **inventory** *(table)*: Inventory receiving the item.
            * **item** *(table)*: Item added.

        ---

        ### Example

            ```lua
            hook.Add("InventoryItemAdded", "NotifyAdd", function(inv, item)
            print("Added", item.name)
            end)
            ```

        ## InventoryItemRemoved

        **Realm:** Client

        **Description:**
            Called when an item is removed from an inventory.
            Runs after the item table is updated.
            

        ---

        ### Parameters

            * **inventory** *(table)*: Inventory modified.
            * **item** *(table)*: Item removed.

        ---

        ### Example

            ```lua
            hook.Add("InventoryItemRemoved", "NotifyRemove", function(inv, item)
            print("Removed", item.name)
            end)
            ```

        ## InventoryDeleted

        **Realm:** Client

        **Description:**
            Signals that an inventory was deleted clientside.
            Allows cleanup of references.
            

        ---

        ### Parameters

            * **inventory** *(table)*: Deleted inventory.

        ---

        ### Example

            ```lua
            hook.Add("InventoryDeleted", "Clear", function(inv)
            print("Inventory", inv:getID(), "deleted")
            end)
            ```

        ## ItemDeleted

        **Realm:** Client

        **Description:**
            Fired when an item is removed entirely.
            Modules should clear any cached data.
            

        ---

        ### Parameters

            * **item** *(table)*: Item that was deleted.

        ---

        ### Example

            ```lua
            hook.Add("ItemDeleted", "Log", function(item)
            print("Item", item.uniqueID, "gone")
            end)
            ```

        ## OnCharVarChanged

        **Realm:** Client

        **Description:**
            Runs when a networked character variable changes.
            Gives both old and new values.
            

        ---

        ### Parameters

            * **character** *(Character)*: Affected character.
            * **key** *(string)*: Variable name.
            * **oldValue** *(any)*: Previous value.
            * **value** *(any)*: New value.

        ---

        ### Example

            ```lua
            hook.Add("OnCharVarChanged", "WatchMoney", function(char, k, old, new)
            if k == "money" then print("Money changed", new) end
            end)
            ```

        ## OnCharLocalVarChanged

        **Realm:** Client

        **Description:**
            Similar to OnCharVarChanged but for local-only variables.
            Called after the table updates.
            

        ---

        ### Parameters

            * **character** *(Character)*: Affected character.
            * **key** *(string)*: Variable name.
            * **oldVar** *(any)*: Old value.
            * **value** *(any)*: New value.

        ---

        ### Example

            ```lua
            hook.Add("OnCharLocalVarChanged", "WatchFlags", function(char, k, old, new)
            if k == "flags" then print("Flags changed") end
            end)
            ```

        ## ItemDataChanged

        **Realm:** Client

        **Description:**
            Called when item data values change clientside.
            Provides both the old and new values.
            

        ---

        ### Parameters

            * **item** *(table)*: Item modified.
            * **key** *(string)*: Key that changed.
            * **oldValue** *(any)*: Previous value.
            * **value** *(any)*: New value.

        ---

        ### Example

            ```lua
            hook.Add("ItemDataChanged", "TrackDurability", function(item, key)
            if key == "durability" then print("New durability", item.data[key]) end
            end)
            ```

        ## ItemQuantityChanged

        **Realm:** Client

        **Description:**
            Runs when an item's quantity value updates.
            Allows reacting to stack changes.
            

        ---

        ### Parameters

            * **item** *(table)*: Item affected.
            * **oldQuantity** *(number)*: Previous quantity.
            * **quantity** *(number)*: New quantity.

        ---

        ### Example

            ```lua
            hook.Add("ItemQuantityChanged", "CountStacks", function(item, old, new)
            print("Quantity now", new)
            end)
            ```

        ## KickedFromChar

        **Realm:** Client

        **Description:**
            Indicates that a character was forcefully removed.
            isCurrentChar denotes if it was the active one.
            

        ---

        ### Parameters

            * **id** *(number)*: Character identifier.
            * **isCurrentChar** *(boolean)*: Was this the active character?

        ---

        ### Example

            ```lua
            hook.Add("KickedFromChar", "Notify", function(id, current)
            print("Kicked from", id, current and "(current)" or "")
            end)
            ```

        ## HandleItemTransferRequest

        **Realm:** Server

        **Description:**
            Server receives a request to move an item.
            Modules can validate or modify the transfer.
            

        ---

        ### Parameters

            * **client** *(Player)*: Requesting player.
            * **itemID** *(number)*: Item identifier.
            * **x** *(number)*: X position.
            * **y** *(number)*: Y position.
            * **inventoryID** *(number|string)*: Target inventory ID.

        ---

        ### Example

            ```lua
            hook.Add("HandleItemTransferRequest", "LogMove", function(ply, itemID, x, y)
            print(ply, "moved item", itemID, "to", x, y)
            end)
            ```

        ## CharLoaded

        **Realm:** Shared

        **Description:**
            Fired when a character object is fully loaded.
            Receives the character ID.
            

        ---

        ### Parameters

            * **id** *(number)*: Character identifier.

        ---

        ### Example

            ```lua
            hook.Add("CharLoaded", "Notify", function(id)
            print("Character", id, "loaded")
            end)
            ```

        ## PreCharDelete

        **Realm:** Shared

        **Description:**
            Called before a character is removed.
            Return false to cancel deletion.
            

        ---

        ### Parameters

            * **id** *(number)*: Character identifier.

        ---

        ### Example

            ```lua
            hook.Add("PreCharDelete", "Protect", function(id)
            if id == 1 then return false end
            end)
            ```

        ## OnCharDelete

        **Realm:** Shared

        **Description:**
            Fired when a character is deleted.
            Provides the owning player if available.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player who deleted.
            * **id** *(number)*: Character identifier.

        ---

        ### Example

            ```lua
            hook.Add("OnCharDelete", "Announce", function(ply, id)
            print(ply, "deleted char", id)
            end)
            ```

        ## OnCharCreated

        **Realm:** Shared

        **Description:**
            Invoked after a new character is created.
            Supplies the character table and creation data.
            

        ---

        ### Parameters

            * **client** *(Player)*: Owner player.
            * **character** *(table)*: New character object.
            * **data** *(table)*: Raw creation info.

        ---

        ### Example

            ```lua
            hook.Add("OnCharCreated", "Welcome", function(ply, char)
            print("Created", char:getName())
            end)
            ```

        ## OnTransferred

        **Realm:** Shared

        **Description:**
            Runs when a player transfers to another server.
            Useful for cleanup.
            

        ---

        ### Parameters

            * **client** *(Player)*: Transferring player.

        ---

        ### Example

            ```lua
            hook.Add("OnTransferred", "Goodbye", function(ply)
            print(ply, "left the server")
            end)
            ```

        ## CharPreSave

        **Realm:** Shared

        **Description:**
            Executed before a character is saved to disk.
            Allows writing custom data.
            

        ---

        ### Parameters

            * **character** *(Character)*: Character being saved.

        ---

        ### Example

            ```lua
            hook.Add("CharPreSave", "Record", function(char)
            char:setData("lastSave", os.time())
            end)
            ```

        ## CharListLoaded

        **Realm:** Client

        **Description:**
            Called when the character selection list finishes loading.
            Provides the loaded list table.
            

        ---

        ### Parameters

            * **newCharList** *(table)*: Table of characters.

        ---

        ### Example

            ```lua
            hook.Add("CharListLoaded", "CountChars", function(list)
            print("Loaded", #list, "characters")
            end)
            ```

        ## CharListUpdated

        **Realm:** Client

        **Description:**
            Fires when the character list is refreshed.
            Gives both old and new tables.
            

        ---

        ### Parameters

            * **oldCharList** *(table)*: Previous list.
            * **newCharList** *(table)*: Updated list.

        ---

        ### Example

            ```lua
            hook.Add("CharListUpdated", "Diff", function(old, new)
            print("Characters updated")
            end)
            ```

        ## getCharMaxStamina

        **Realm:** Shared

        **Description:**
            Returns the maximum stamina for a character.
            Override to change stamina capacity.
            

        ---

        ### Parameters

            * **character** *(Character)*: Character queried.

        ---

        ### Example

            ```lua
            hook.Add("getCharMaxStamina", "Double", function(char)
            return 200
            end)
            ```

        ## AdjustStaminaOffsetRunning

        **Realm:** Shared

        **Description:**
            Alters the stamina offset applied each tick while sprinting.
            Return a new cost to modify how quickly stamina drains when running.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player that is sprinting.
            * **runCost** *(number)*: Proposed stamina cost.

        ---

        ### Returns

            * number – Modified stamina cost.

        ---

        ### Example

            ```lua
            hook.Add("AdjustStaminaOffsetRunning", "EnduranceBonus", function(ply, cost)
            return cost + ply:getChar():getAttrib("stamina", 0) * -0.01
            end)
            ```

        ## AdjustStaminaRegeneration

        **Realm:** Shared

        **Description:**
            Allows changing how quickly stamina regenerates when not sprinting.
            Return a new amount to modify regeneration speed.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player recovering stamina.
            * **regen** *(number)*: Default regeneration per tick.

        ---

        ### Returns

            * number – Modified regeneration amount.

        ---

        ### Example

            ```lua
            hook.Add("AdjustStaminaRegeneration", "RestAreaBoost", function(ply, amount)
            if ply:isInSafeZone() then
            return amount * 2
            end
            end)
            ```

        ## AdjustStaminaOffset

        **Realm:** Shared

        **Description:**
            Final hook for tweaking the calculated stamina offset.
            Return the modified offset value to apply each tick.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player whose stamina is updating.
            * **offset** *(number)*: Current offset after other adjustments.

        ---

        ### Returns

            * number – New offset to apply.

        ---

        ### Example

            ```lua
            hook.Add("AdjustStaminaOffset", "MinimumDrain", function(ply, off)
            return math.max(off, -1)
            end)
            ```

        ## PostLoadFonts

        **Realm:** Shared

        **Description:**
            Runs after all font files have loaded.
            Allows registering additional fonts.
            

        ---

        ### Parameters

            * ... – Extra arguments passed through.

        ---

        ### Example

            ```lua
            hook.Add("PostLoadFonts", "LogoFont", function()
            surface.CreateFont("Logo", {size = 32, font = "Tahoma"})
            end)
            ```

        ## AddBarField

        **Realm:** Client

        **Description:**
            Called when the F1 menu builds status bars so new fields can be added.
            

        ---

        ### Parameters

            * **sectionName** *(string)*: Section identifier.
            * **fieldName** *(string)*: Unique field name.
            * **labelText** *(string)*: Display label for the bar.
            * **minFunc** *(function)*: Returns the minimum value.
            * **maxFunc** *(function)*: Returns the maximum value.
            * **valueFunc** *(function)*: Returns the current value.

        ---

        ### Example

            ```lua
            -- Adds a custom thirst bar next to stamina.
            hook.Add("AddBarField", "AddThirstBar", function(section, id, label, min, max, value)
            lia.bar.add(value, Color(0, 150, 255), nil, id)
            end)
            ```

        ## AddSection

        **Realm:** Client

        **Description:**
            Fired when building the F1 menu so modules can insert additional sections.
            

        ---

        ### Parameters

            * **sectionName** *(string)*: Name of the section.
            * **color** *(Color)*: Display color.
            * **priority** *(number)*: Sort order priority.
            * **location** *(number)*: Column/location index.

        ---

        ### Example

            ```lua
            -- Add a custom "Settings" tab.
            hook.Add("AddSection", "AddSettingsSection", function(name, color, priority)
            if name == "settings" then
            color = Color(0, 128, 255)
            priority = 5
            end
            end)
            ```

        ## CanItemBeTransfered

        **Realm:** Server

        **Description:**
            Determines whether an item may move between inventories.
            

        ---

        ### Parameters

            * **item** *(Item)*: Item being transferred.
            * **oldInventory** *(Inventory)*: Source inventory.
            * **newInventory** *(Inventory)*: Destination inventory.
            * **client** *(Player)*: Owning player.

        ---

        ### Example

            ```lua
            -- Prevent quest items from being dropped.
            hook.Add("CanItemBeTransfered", "BlockQuestItemDrop", function(item, newInv, oldInv)
            if item.isQuest then return false, "Quest items cannot be moved" end
            end)
            ```

        ## CanOpenBagPanel

        **Realm:** Client

        **Description:**
            Called right before a bag inventory UI opens. Return false to block opening.
            

        ---

        ### Parameters

            * **item** *(Item)*: Bag item being opened.

        ---

        ### Returns

            * boolean – False to block opening.

        ---

        ### Example

            ```lua
            -- Disallow bag use while fighting.
            hook.Add("CanOpenBagPanel", "BlockBagInCombat", function(item)
            if LocalPlayer():getNetVar("inCombat") then return false end
            end)
            ```

        ## CanOutfitChangeModel

        **Realm:** Shared

        **Description:**
            Checks if an outfit is allowed to change the player model.
            

        ---

        ### Parameters

            * **item** *(Item)*: Outfit item attempting to change the model.

        ---

        ### Returns

            * boolean – False to block the change.

        ---

        ### Example

            ```lua
            -- Restrict model swaps for certain factions.
            hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
            if item.factionRestricted then return false end
            end)
            ```

        ## CanPerformVendorEdit

        **Realm:** Shared

        **Description:**
            Determines if a player can modify a vendor's settings.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting the edit.
            * **vendor** *(Entity)*: Vendor entity targeted.

        ---

        ### Returns

            * boolean – False to disallow editing.

        ---

        ### Example

            ```lua
            -- Allow only admins to edit vendors.
            hook.Add("CanPerformVendorEdit", "AdminVendorEdit", function(client)
            return client:IsAdmin()
            end)
            ```

        ## CanPickupMoney

        **Realm:** Shared

        **Description:**
            Called when a player attempts to pick up a money entity.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting to pick up the money.
            * **moneyEntity** *(Entity)*: The money entity.

        ---

        ### Returns

            * boolean – False to disallow pickup.

        ---

        ### Example

            ```lua
            -- Prevent money pickup while handcuffed.
            hook.Add("CanPickupMoney", "BlockWhileCuffed", function(client)
            if client:isHandcuffed() then return false end
            end)
            ```

        ## CanPlayerAccessDoor

        **Realm:** Shared

        **Description:**
            Determines if a player can open or lock a door entity.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting access.
            * **door** *(Entity)*: Door entity in question.
            * **access** *(number)*: Desired access level.

        ---

        ### Returns

            * boolean – False to deny access.

        ---

        ### Example

            ```lua
            -- Only police can unlock jail cells.
            hook.Add("CanPlayerAccessDoor", "PoliceDoors", function(client, door, access)
            if door.isJail and not client:isPolice() then return false end
            end)
            ```

        ## CanPlayerAccessVendor

        **Realm:** Server

        **Description:**
            Checks if a player is permitted to open a vendor menu.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player requesting access.
            * **vendor** *(Entity)*: Vendor entity.

        ---

        ### Returns

            * boolean – False to deny access.

        ---

        ### Example

            ```lua
            -- Block access unless the vendor allows the player's faction.
            hook.Add("CanPlayerAccessVendor", "CheckVendorFaction", function(client, vendor)
            if not vendor:isFactionAllowed(client:Team()) then return false end
            end)
            ```

        ## CanPlayerHoldObject

        **Realm:** Shared

        **Description:**
            Determines if the player can pick up an entity with the hands swep.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting to hold the entity.
            * **entity** *(Entity)*: Target entity.

        ---

        ### Returns

            * boolean – False to prevent holding.

        ---

        ### Example

            ```lua
            -- Prevent grabbing heavy physics objects.
            hook.Add("CanPlayerHoldObject", "WeightLimit", function(client, ent)
            if ent:GetMass() > 50 then return false end
            end)
            ```

        ## CanPlayerInteractItem

        **Realm:** Shared

        **Description:**
            Called when a player tries to use or drop an item.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player interacting with the item.
            * **action** *(string)*: Action name such as "use" or "drop".
            * **item** *(Item)*: Item being interacted with.

        ---

        ### Returns

            * boolean – False to block the action.

        ---

        ### Example

            ```lua
            -- Block medkit use inside safe zones.
            hook.Add("CanPlayerInteractItem", "SafeZoneBlock", function(client, action, item)
            if action == "use" and item.uniqueID == "medkit" and client:isInSafeZone() then
            return false
            end
            end)
            ```

        ## CanPlayerKnock

        **Realm:** Shared

        **Description:**
            Called when a player attempts to knock on a door.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player knocking.
            * **door** *(Entity)*: Door being knocked on.

        ---

        ### Returns

            * boolean – False to block knocking.

        ---

        ### Example

            ```lua
            -- Prevent knocking while disguised.
            hook.Add("CanPlayerKnock", "BlockDisguisedKnock", function(client, door)
            if client:getNetVar("disguised") then return false end
            end)
            ```

        ## CanPlayerSpawnStorage

        **Realm:** Server

        **Description:**
            Checks if the player is allowed to spawn a storage container.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player attempting to spawn.
            * **entity** *(Entity)*: Prop that will become storage.
            * **data** *(table)*: Storage definition data.

        ---

        ### Returns

            * boolean – False to deny spawning.

        ---

        ### Example

            ```lua
            -- Limit players to one storage crate.
            hook.Add("CanPlayerSpawnStorage", "LimitStorage", function(client, ent, data)
            if client.storageSpawned then return false end
            end)
            ```

        ## CanPlayerThrowPunch

        **Realm:** Shared

        **Description:**
            Called when the fists weapon tries to punch.
            

        ---

        ### Parameters

            * **client** *(Player)*: Player performing the punch.

        ---

        ### Returns

            * boolean – False to block punching.

        ---

        ### Example

            ```lua
            -- Prevent punching while restrained.
            hook.Add("CanPlayerThrowPunch", "NoPunchWhenTied", function(client)
            if client:IsFlagSet(FL_KNOCKED) then return false end
            end)
            ```

        ## CanPlayerTradeWithVendor

        **Realm:** Server

        **Description:**
            Checks whether a vendor trade is allowed.
            

        ---

        ### Example

            ```lua
            -- Block selling stolen goods.
            hook.Add("CanPlayerTradeWithVendor", "DisallowStolenItems", function(client, vendor, itemType, selling)
            if lia.stolen[itemType] then return false, "Stolen items" end
            end)
            ```

        ## CanPlayerViewInventory

        **Realm:** Client

        **Description:**
            Called before any inventory menu is shown.
            

        ---

        ### Example

            ```lua
            -- Prevent opening inventory while in a cutscene.
            hook.Add("CanPlayerViewInventory", "BlockDuringCutscene", function()
            return not LocalPlayer():getNetVar("cutscene")
            end)
            ```

        ## CanSaveData

        **Realm:** Server

        **Description:**
            Called before persistent storage saves.
            

        ---

        ### Example

            ```lua
            -- Disable saving during special events.
            hook.Add("CanSaveData", "NoEventSaves", function(entity, inv)
            if lia.eventActive then return false end
            end)
            ```

        ## CharHasFlags

        **Realm:** Shared

        **Description:**
            Allows custom checks for a character's permission flags.
            

        ---

        ### Example

            ```lua
            -- Grant extra access for characters owned by admins.
            hook.Add("CharHasFlags", "AdminExtraFlags", function(char, flags)
            local ply = char:getPlayer()
            if IsValid(ply) and ply:IsAdmin() and flags == "a" then
            return true
            end
            end)
            ```

        ## CharPostSave

        **Realm:** Shared

        **Description:**
            Runs after a character's data has been saved to the database.
            

        ---

        ### Example

            ```lua
            -- Log every time characters save data.
            hook.Add("CharPostSave", "LogCharSaves", function(char)
            print(char:getName() .. " saved")
            end)
            ```

        ## DatabaseConnected

        **Realm:** Shared

        **Description:**
            Fired after the database has been successfully connected.
            

        ---

        ### Example

            ```lua
            -- Prepare custom tables once the DB connects.
            hook.Add("DatabaseConnected", "CreateCustomTables", function()
            lia.db.query("CREATE TABLE IF NOT EXISTS extras(id INT)")
            end)
            ```

        ## DrawItemDescription

        **Realm:** Client

        **Description:**
            Called when an item entity draws its description text.
            

        ---

        ### Example

            ```lua
            -- Display remaining uses next to item name.
            hook.Add("DrawItemDescription", "AddUseCount", function(item, x, y, color, alpha)
            draw.SimpleText("Uses: " .. item:getData("uses", 0), "DermaDefault", x, y + 20, color)
            end)
            ```

        ## GetAttributeMax

        **Realm:** Shared

        **Description:**
            Returns the maximum value allowed for an attribute.
            

        ---

        ### Example

            ```lua
            -- Increase stamina cap for admins.
            hook.Add("GetAttributeMax", "AdminStamina", function(client, attrib)
            if attrib == "stamina" and client:IsAdmin() then
            return 150
            end
            end)
            ```

        ## GetDefaultInventorySize

        **Realm:** Server

        **Description:**
            Returns the default width and height for new inventories.
            

        ---

        ### Example

            ```lua
            -- Expand default bags for admins.
            hook.Add("GetDefaultInventorySize", "AdminBags", function(client)
            if client:IsAdmin() then
            return 6, 6
            end
            end)
            ```

        ## GetMoneyModel

        **Realm:** Shared

        **Description:**
            Allows overriding the entity model used for dropped money.
            

        ---

        ### Example

            ```lua
            -- Use a golden model for large sums.
            hook.Add("GetMoneyModel", "GoldMoneyModel", function(amount)
            if amount > 5000 then return "models/props_lab/box01a.mdl" end
            end)
            ```

        ## GetPlayerPunchDamage

        **Realm:** Shared

        **Description:**
            Lets addons modify how much damage the fists weapon deals.
            

        ---

        ### Example

            ```lua
            -- Scale punch damage by strength attribute.
            hook.Add("GetPlayerPunchDamage", "StrengthPunch", function(client, dmg, context)
            return dmg * (1 + client:getChar():getAttrib("str", 0) / 100)
            end)
            ```

        ## InterceptClickItemIcon

        **Realm:** Client

        **Description:**
            Allows overriding default clicks on inventory icons.
            

        ---

        ### Example

            ```lua
            -- Shift-click to quickly move items.
            hook.Add("InterceptClickItemIcon", "ShiftQuickMove", function(panel, icon, key)
            if key == KEY_LSHIFT then return true end
            end)
            ```

        ## ItemCombine

        **Realm:** Server

        **Description:**
            Called when attempting to combine one item with another.
            

        ---

        ### Example

            ```lua
            -- Combine two ammo boxes into one stack.
            hook.Add("ItemCombine", "StackAmmo", function(client, base, other)
            if base.uniqueID == "ammo" and other.uniqueID == "ammo" then
            base:setData("amount", base:getData("amount",0) + other:getData("amount",0))
            return true
            end
            end)
            ```

        ## ItemDraggedOutOfInventory

        **Realm:** Server

        **Description:**
            Called when an item icon is dragged completely out of an inventory.
            

        ---

        ### Example

            ```lua
            -- Drop the item into the world when removed.
            hook.Add("ItemDraggedOutOfInventory", "DropOnDragOut", function(invPanel, item)
            item:spawn(invPanel:LocalToWorld(item:getPosition()))
            end)
            ```

        ## ItemFunctionCalled

        **Realm:** Shared

        **Description:**
            Triggered whenever an item function is executed by a player.
            

        ---

        ### Example

            ```lua
            -- Log item function usage for analytics.
            hook.Add("ItemFunctionCalled", "TrackItemUse", function(item, action, client, entity, result)
            lia.log.add(client, "item_use", item.uniqueID, action)
            end)
            ```

        ## ItemTransfered

        **Realm:** Server

        **Description:**
            Runs after an item successfully moves between inventories.
            

        ---

        ### Example

            ```lua
            -- Notify the player about the transfer result.
            hook.Add("ItemTransfered", "NotifyTransfer", function(context)
            context.client:notify("Item moved!")
            end)
            ```

        ## OnCharAttribBoosted

        **Realm:** Shared

        **Description:**
            Fired when an attribute boost is added or removed.
            

        ---

        ### Example

            ```lua
            -- Notify the player when they gain a temporary bonus.
            hook.Add("OnCharAttribBoosted", "BoostNotice", function(client, char, key, id, amount)
            if amount ~= true then client:notify("Boosted " .. key .. " by " .. amount) end
            end)
            ```

        ## OnCharAttribUpdated

        **Realm:** Shared

        **Description:**
            Fired when a character attribute value is changed.
            

        ---

        ### Example

            ```lua
            -- Print the changed attribute on the local player's HUD.
            hook.Add("OnCharAttribUpdated", "PrintAttribChange", function(client, char, key, value)
            if client == LocalPlayer() then
            chat.AddText(key .. ": " .. value)
            end
            end)
            ```

        ## OnCharFallover

        **Realm:** Server

        **Description:**
            Called when a character ragdolls or is forced to fall over.
            

        ---

        ### Example

            ```lua
            -- Apply a stun effect when knocked down.
            hook.Add("OnCharFallover", "ApplyStun", function(client, _, forced)
            if forced then client:setAction("stunned", 3) end
            end)
            ```

        ## OnCharKick

        **Realm:** Shared

        **Description:**
            Called when a character is kicked from the server.
            

        ---

        ### Example

            ```lua
            -- Record the kick reason.
            hook.Add("OnCharKick", "LogKickReason", function(char, client)
            print(char:getName(), "was kicked")
            end)
            ```

        ## OnCharPermakilled

        **Realm:** Shared

        **Description:**
            Called when a character is permanently killed.
            

        ---

        ### Example

            ```lua
            -- Announce permadeath in chat.
            hook.Add('OnCharPermakilled', 'AnnouncePK', function(char, time)
            PrintMessage(HUD_PRINTTALK, char:getName() .. ' has met their end!')
            end)
            ```

        ## OnCharRecognized

        **Realm:** Client

        **Description:**
            Called clientside when your character recognizes another.
            

        ---

        ### Example

            ```lua
            -- Play a sound whenever someone becomes recognized.
            hook.Add('OnCharRecognized', 'PlayRecognizeSound', function(client)
            surface.PlaySound('buttons/button17.wav')
            end)
            ```

        ## OnCharTradeVendor

        **Realm:** Server

        **Description:**
            Called after a character buys from or sells to a vendor.
            

        ---

        ### Example

            ```lua
            -- Log vendor transactions to the console.
            hook.Add('OnCharTradeVendor', 'LogVendorTrade', function(client, vendor, item, selling)
            print(client:Nick(), selling and 'sold' or 'bought', item and item:getName() or 'unknown')
            end)
            ```

        ## OnCreatePlayerRagdoll

        **Realm:** Shared

        **Description:**
            Called when a ragdoll entity is created for a player.
            

        ---

        ### Example

            ```lua
            -- Tint death ragdolls red.
            hook.Add('OnCreatePlayerRagdoll', 'RedRagdoll', function(client, ent, dead)
            if dead then ent:SetColor(Color(255,0,0)) end
            end)
            ```

        ## OnCreateStoragePanel

        **Realm:** Client

        **Description:**
            Called when both the player's inventory and storage panels are created.
            

        ---

        ### Example

            ```lua
            -- Add a custom tab to storage windows.
            hook.Add('OnCreateStoragePanel', 'AddSortTab', function(localPanel, storagePanel, storage)
            storagePanel:AddTab('Sort', function() return vgui.Create('liaStorageSort') end)
            end)
            ```

        ## OnItemAdded

        **Realm:** Shared

        **Description:**
            Called when a new item instance is placed into an inventory.
            

        ---

        ### Example

            ```lua
            -- Play a sound when ammo is picked up.
            hook.Add('OnItemAdded', 'AmmoPickupSound', function(ply, item)
            if item.category == 'ammo' then
            ply:EmitSound('items/ammo_pickup.wav')
            end
            end)
            ```

        ## OnItemCreated

        **Realm:** Shared

        **Description:**
            Called when a new item instance table is initialized.
            

        ---

        ### Example

            ```lua
            -- Set custom data on freshly made items.
            hook.Add('OnItemCreated', 'InitCustomData', function(item)
            item:setData('born', os.time())
            end)
            ```

        ## OnItemSpawned

        **Realm:** Shared

        **Description:**
            Called when an item entity has been spawned in the world.
            

        ---

        ### Example

            ```lua
            -- Play a sound when rare items appear.
            hook.Add('OnItemSpawned', 'RareSpawnSound', function(itemEnt)
            if itemEnt.rare then itemEnt:EmitSound('items/ammo_pickup.wav') end
            end)
            ```

        ## OnOpenVendorMenu

        **Realm:** Client

        **Description:**
            Called when the vendor dialog panel is opened.
            

        ---

        ### Example

            ```lua
            -- Automatically switch to the buy tab.
            hook.Add('OnOpenVendorMenu', 'DefaultBuyTab', function(panel, vendor)
            panel:openTab('Buy')
            end)
            ```

        ## OnPickupMoney

        **Realm:** Shared

        **Description:**
            Called after a player picks up a money entity.
            

        ---

        ### Example

            ```lua
            -- Reward an achievement for looting money.
            hook.Add('OnPickupMoney', 'MoneyAchievement', function(client, ent)
            client:addProgress('rich', ent:getAmount())
            end)
            ```

        ## OnPlayerEnterSequence

        **Realm:** Shared

        **Description:**
            Fired when a scripted animation sequence begins.
            

        ---

        ### Example

            ```lua
            -- Freeze the player during the sequence.
            hook.Add('OnPlayerEnterSequence', 'FreezeDuringSeq', function(client, seq, callback, time, noFreeze)
            if not noFreeze then client:Freeze(true) end
            end)
            ```

        ## OnPlayerInteractItem

        **Realm:** Shared

        **Description:**
            Runs after a player has interacted with an item.
            

        ---

        ### Example

            ```lua
            -- Send analytics for item usage.
            hook.Add('OnPlayerInteractItem', 'Analytics', function(client, action, item, result, data)
            lia.analytics.log(client, action, item.uniqueID)
            end)
            ```

        ## OnPlayerJoinClass

        **Realm:** Shared

        **Description:**
            Called when a player changes to a new class.
            

        ---

        ### Example

            ```lua
            -- Give class specific weapons.
            hook.Add('OnPlayerJoinClass', 'ClassWeapons', function(client, class, oldClass)
            for _, wep in ipairs(class.weapons or {}) do client:Give(wep) end
            end)
            ```

        ## OnPlayerLeaveSequence

        **Realm:** Shared

        **Description:**
            Fired when a scripted animation sequence ends for a player.
            

        ---

        ### Example

            ```lua
            -- Unfreeze the player after the sequence.
            hook.Add('OnPlayerLeaveSequence', 'UnfreezeAfterSeq', function(client)
            client:Freeze(false)
            end)
            ```

        ## OnPlayerLostStackItem

        **Realm:** Shared

        **Description:**
            Called if a stackable item is removed unexpectedly.
            

        ---

        ### Example

            ```lua
            -- Warn players when their ammo stack disappears.
            hook.Add('OnPlayerLostStackItem', 'WarnLostAmmo', function(item)
            if item.category == 'ammo' then print('Ammo stack lost!') end
            end)
            ```

        ## OnPlayerSwitchClass

        **Realm:** Shared

        **Description:**
            Occurs right before a player's class changes.
            

        ---

        ### Example

            ```lua
            -- Prevent switching while in combat.
            hook.Add('OnPlayerSwitchClass', 'NoCombatSwap', function(client, class, oldClass)
            if client:getNetVar('inCombat') then return false end
            end)
            ```

        ## OnRequestItemTransfer

        **Realm:** Client

        **Description:**
            Called when the UI asks to move an item between inventories.
            

        ---

        ### Example

            ```lua
            -- Validate transfers before sending to the server.
            hook.Add('OnRequestItemTransfer', 'ValidateTransfer', function(panel, itemID, invID, x, y)
            return itemID ~= 0 -- block invalid ids
            end)
            ```

        ## PersistenceLoad

        **Realm:** Server

        **Description:**
            Called when map persistence data is loaded.
            

        ---

        ### Example

            ```lua
            -- Verify entities when the map reloads.
            hook.Add('PersistenceLoad', 'CheckPersistent', function(name)
            print('Loading persistence file', name)
            end)
            ```

        ## PlayerAccessVendor

        **Realm:** Shared

        **Description:**
            Occurs when a player successfully opens a vendor.
            

        ---

        ### Example

            ```lua
            -- Track how often players browse vendors.
            hook.Add('PlayerAccessVendor', 'VendorAnalytics', function(client, vendor)
            lia.log.add(client, 'vendor_open', vendor:GetClass())
            end)
            ```

        ## PlayerStaminaGained

        **Realm:** Shared

        **Description:**
            Called when a player regenerates stamina points.
            

        ---

        ### Example

            ```lua
            -- Print the player's stamina amount whenever it increases.
            hook.Add('PlayerStaminaGained', 'PrintStaminaGain', function(client)
            if client == LocalPlayer() then
            print('Stamina:', client:getLocalVar('stamina'))
            end
            end)
            ```

        ## PlayerStaminaLost

        **Realm:** Shared

        **Description:**
            Called when a player's stamina decreases.
            

        ---

        ### Example

            ```lua
            -- Play a sound when the player runs out of stamina.
            hook.Add('PlayerStaminaLost', 'TiredSound', function(client)
            if client:getLocalVar('stamina', 0) <= 0 then
            client:EmitSound('player/suit_denydevice.wav')
            end
            end)
            ```

        ## PlayerThrowPunch

        **Realm:** Shared

        **Description:**
            Fires when a player lands a punch with the fists weapon.
            

        ---

        ### Example

            ```lua
            -- Play a custom sound on punch.
            hook.Add('PlayerThrowPunch', 'PunchSound', function(client, trace)
            client:EmitSound('npc/vort/claw_swing1.wav')
            end)
            ```

        ## PostDrawInventory

        **Realm:** Client

        **Description:**
            Called each frame after the inventory panel draws.
            

        ---

        ### Example

            ```lua
            -- Draw a watermark over the inventory.
            hook.Add('PostDrawInventory', 'InventoryWatermark', function(panel)
            draw.SimpleText('MY SERVER', 'DermaLarge', panel:GetWide()-100, 8, color_white)
            end)
            ```

        ## PrePlayerInteractItem

        **Realm:** Shared

        **Description:**
            Called just before a player interacts with an item.
            

        ---

        ### Example

            ```lua
            -- Deny using keys on locked chests.
            hook.Add('PrePlayerInteractItem', 'BlockChestKeys', function(client, action, item)
            if action == 'use' and item.uniqueID == 'key' and client.lockedChest then return false end
            end)
            ```

        ## SetupBagInventoryAccessRules

        **Realm:** Shared

        **Description:**
            Allows modules to define who can access a bag inventory.
            

        ---

        ### Example

            ```lua
            -- Only the bag owner may open it.
            hook.Add('SetupBagInventoryAccessRules', 'OwnerOnlyBags', function(inv)
            inv:allowAccess('transfer', inv:getOwner())
            end)
            ```

        ## SetupDatabase

        **Realm:** Server

        **Description:**
            Runs before the gamemode initializes its database connection.
            

        ---

        ### Example

            ```lua
            -- Register additional tables.
            hook.Add('SetupDatabase', 'AddExtraTables', function()
            lia.db.query('CREATE TABLE IF NOT EXISTS mytable(id INT)')
            end)
            ```

        ## StorageCanTransferItem

        **Realm:** Server

        **Description:**
            Determines if an item can move in or out of a storage entity.
            

        ---

        ### Example

            ```lua
            -- Prevent weapons from being stored in car trunks.
            hook.Add('StorageCanTransferItem', 'NoWeaponsInCars', function(client, storage, item)
            if storage.isCar and item.category == 'weapons' then return false end
            end)
            ```

        ## StorageEntityRemoved

        **Realm:** Shared

        **Description:**
            Fired when a storage entity is removed from the world.
            

        ---

        ### Example

            ```lua
            -- Drop items when a crate is destroyed.
            hook.Add('StorageEntityRemoved', 'DropContents', function(entity, inv)
            inv:dropItems(entity:GetPos())
            end)
            ```

        ## StorageInventorySet

        **Realm:** Shared

        **Description:**
            Called when a storage entity is assigned an inventory.
            

        ---

        ### Example

            ```lua
            -- Send a notification when storage is initialized.
            hook.Add('StorageInventorySet', 'NotifyStorage', function(entity, inv, isCar)
            if isCar then print('Trunk inventory ready') end
            end)
            ```

        ## StorageOpen

        **Realm:** Client

        **Description:**
            Called clientside when a storage menu is opened.
            

        ---

        ### Example

            ```lua
            -- Display storage name in the chat.
            hook.Add('StorageOpen', 'AnnounceStorage', function(entity, isCar)
            chat.AddText('Opened storage:', entity:GetClass())
            end)
            ```

        ## StorageRestored

        **Realm:** Server

        **Description:**
            Called when a storage's contents are loaded from disk.
            

        ---

        ### Example

            ```lua
            -- Log how many items were restored.
            hook.Add('StorageRestored', 'PrintRestore', function(storage, inv)
            print('Storage restored with', #inv:getItems(), 'items')
            end)
            ```

        ## StorageUnlockPrompt

        **Realm:** Client

        **Description:**
            Called clientside when you must enter a storage password.
            

        ---

        ### Example

            ```lua
            -- Auto-fill a remembered password.
            hook.Add('StorageUnlockPrompt', 'AutoFill', function(entity)
            return '1234' -- automatically send this string
            end)
            ```

        ## VendorClassUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's allowed classes are updated.
            

        ---

        ### Example

            ```lua
            -- React to class access changes.
            hook.Add("VendorClassUpdated", "LogVendorClassChange", function(vendor, id, allowed)
            print("Vendor class", id, "now", allowed and "allowed" or "blocked")
            end)
            ```

        ## VendorEdited

        **Realm:** Client

        **Description:**
            Called after a delay when a vendor's data is edited.
            

        ---

        ### Example

            ```lua
            -- Log which key changed.
            hook.Add("VendorEdited", "PrintVendorEdit", function(vendor, key)
            print("Vendor", vendor:GetClass(), "edited key", key)
            end)
            ```

        ## VendorExited

        **Realm:** Client

        **Description:**
            Called when a player exits from interacting with a vendor.
            

        ---

        ### Example

            ```lua
            -- Notify the player when they leave a vendor.
            hook.Add("VendorExited", "PrintVendorExit", function()
            print("Stopped interacting with vendor")
            end)
            ```

        ## VendorFactionUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's allowed factions are updated.
            

        ---

        ### Example

            ```lua
            -- Print updated faction permissions.
            hook.Add("VendorFactionUpdated", "LogVendorFactionUpdate", function(vendor, id, allowed)
            print("Vendor faction", id, "now", allowed and "allowed" or "blocked")
            end)
            ```

        ## VendorItemMaxStockUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's item max stock value changes.
            

        ---

        ### Example

            ```lua
            -- Log stock limit changes.
            hook.Add("VendorItemMaxStockUpdated", "LogVendorStockLimits", function(vendor, itemType, value)
            print("Vendor stock limit for", itemType, "set to", value)
            end)
            ```

        ## VendorItemModeUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's item mode is changed.
            

        ---

        ### Example

            ```lua
            -- Print the new mode value.
            hook.Add("VendorItemModeUpdated", "PrintVendorMode", function(vendor, itemType, value)
            print("Vendor mode for", itemType, "changed to", value)
            end)
            ```

        ## VendorItemPriceUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's item price is changed.
            

        ---

        ### Example

            ```lua
            -- Print the new item price.
            hook.Add("VendorItemPriceUpdated", "LogVendorItemPrice", function(vendor, itemType, value)
            print("Vendor price for", itemType, "is now", value)
            end)
            ```

        ## VendorItemStockUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's item stock value changes.
            

        ---

        ### Example

            ```lua
            -- Log remaining stock for the item.
            hook.Add("VendorItemStockUpdated", "LogVendorItemStock", function(vendor, itemType, value)
            print("Vendor stock for", itemType, "is now", value)
            end)
            ```

        ## VendorMoneyUpdated

        **Realm:** Client

        **Description:**
            Called when a vendor's available money changes.
            

        ---

        ### Example

            ```lua
            -- Print the vendor's new money amount.
            hook.Add("VendorMoneyUpdated", "LogVendorMoney", function(vendor, money, oldMoney)
            print("Vendor money changed from", oldMoney, "to", money)
            end)
            ```

        ## VendorOpened

        **Realm:** Client

        **Description:**
            Called when a vendor menu is opened on the client.
            

        ---

        ### Example

            ```lua
            -- Print which vendor was opened.
            hook.Add("VendorOpened", "PrintVendorOpened", function(vendor)
            print("Opened vendor", vendor:GetClass())
            end)
            ```

        ## VendorSynchronized

        **Realm:** Client

        **Description:**
            Called when vendor synchronization data is received.
            

        ---

        ### Example

            ```lua
            -- Print a message when vendor data syncs.
            hook.Add("VendorSynchronized", "LogVendorSync", function(vendor)
            print("Vendor", vendor:GetClass(), "synchronized")
            end)
            ```

        ## VendorTradeEvent

        **Realm:** Server

        **Description:**
            Called when a player attempts to trade with a vendor.
            

        ---

        ### Example

            ```lua
            -- Log all vendor trades to the console.
            hook.Add("VendorTradeEvent", "LogVendorTrades", function(client, entity, uniqueID, isSellingToVendor)
            local action = isSellingToVendor and "sold" or "bought"
            print(client:Name() .. " " .. action .. " " .. uniqueID .. " with " .. entity:GetClass())
            end)
            ```

        ## getItemDropModel

        **Realm:** Server

        **Description:**
            Returns an alternate model path for a dropped item.
            

        ---

        ### Returns

            * string|nil – Alternate model path or nil for default.

        ---

        ### Example

            ```lua
            -- Replace drop model for weapons.
            hook.Add("getItemDropModel", "CustomDropModelForWeapons", function(itemTable, entity)
            if itemTable.category == "Weapon" then
            return "models/weapons/w_rif_ak47.mdl"
            end
            end)
            ```

        ## getPriceOverride

        **Realm:** Shared

        **Description:**
            Allows modules to override a vendor item's price dynamically.
            

        ---

        ### Returns

            * integer|nil – New price or nil for default.

        ---

        ### Example

            ```lua
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
            ```

        ## isCharFakeRecognized

        **Realm:** Shared

        **Description:**
            Checks if a character is fake recognized rather than truly known.
            

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            -- Flag suspicious characters as fake.
            hook.Add("isCharFakeRecognized", "DetectFakeCharacters", function(character, id)
            if character:getData("suspicious", false) then
            return true
            end
            end)
            ```

        ## isCharRecognized

        **Realm:** Shared

        **Description:**
            Determines whether one character recognizes another.
            

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            -- Only recognize characters from the same faction.
            hook.Add("isCharRecognized", "ValidateCharacterRecognition", function(character, id)
            return character:getFaction() == lia.char.loaded[id]:getFaction()
            end)
            ```

        ## isRecognizedChatType

        **Realm:** Shared

        **Description:**
            Determines if a chat type counts toward recognition.
            

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            -- Mark admin chat as recognized to reveal player names.
            hook.Add("isRecognizedChatType", "ValidateRecognitionChat", function(chatType)
            local recognized = {"admin", "system", "recognition"}
            return table.HasValue(recognized, chatType)
            end)
            ```

        ## isSuitableForTrunk

        **Realm:** Shared

        **Description:**
            Determines whether an entity can be used as trunk storage.
            

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            -- Only vehicles are valid trunk containers.
            hook.Add("isSuitableForTrunk", "AllowOnlyCars", function(entity)
            return entity:IsVehicle()
            end)
            ```

        ## CanPlayerEarnSalary

        **Realm:** Shared

        **Description:**
            Determines if a player is allowed to earn salary.
            

        ---

        ### Parameters

            * client (Player)
            * faction (table)
            * class (table)

        ---

        ### Returns

            * bool

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerEarnSalary", "RestrictSalaryToActivePlayers", function(client, faction, class)
            if not client:isActive() then
            return false -- Inactive players do not earn salary
            end
            return true
            end)
            ```

        ## CanPlayerJoinClass

        **Realm:** Shared

        **Description:**
            Determines whether a player can join a certain class. Return `false` to block.
            

        ---

        ### Parameters

            * client (Player)
            * class (number)
            * info (table)

        ---

        ### Returns

            * bool|nil: false to block, nil to allow.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerJoinClass", "RestrictEliteClass", function(client, class, info)
            if class == CLASS_ELITE and not client:hasPermission("join_elite") then
            return false
            end
            end)
            ```

        ## CanPlayerUseCommand

        **Realm:** Shared

        **Description:**
            Determines if a player can use a specific command. Return `false` to block usage.
            

        ---

        ### Parameters

            * client (Player)
            * command (string)

        ---

        ### Returns

            * bool|nil: false to block, nil to allow.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerUseCommand", "BlockSensitiveCommands", function(client, command)
            local blockedCommands = {"shutdown", "restart"}
            if table.HasValue(blockedCommands, command) and not client:isSuperAdmin() then
            return false
            end
            end)
            ```

        ## CanPlayerUseDoor

        **Realm:** Server

        **Description:**
            Determines if a player is allowed to use a door entity, such as opening, locking, or unlocking. Return `false` to prevent the action.
            

        ---

        ### Parameters

            * client (Player): The player attempting to use the door.
            * door (Entity): The door entity being used.
            * access (int): The type of access attempted (e.g., DOOR_LOCK).

        ---

        ### Returns

            * bool: false to block, nil or true to allow.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerUseDoor", "AllowOnlyOwners", function(client, door, access)
            if access == DOOR_LOCK and door:getOwner() ~= client then
            return false -- Only the owner can lock the door
            end
            return true
            end)
            ```

        ## CharRestored

        **Realm:** Server

        **Description:**
            Called after a character has been restored from the database. Useful for post-restoration logic such as awarding default items or setting up data.
            

        ---

        ### Example

            ```lua
            hook.Add("CharRestored", "AwardWelcomePackage", function(character)
            local welcomePackage = {"welcome_pack", "starter_weapon", "basic_armor"}
            for _, itemID in ipairs(welcomePackage) do
            character:getInv():addItem(itemID)
            end
            print("Welcome package awarded to:", character:getName())
            end)
            ```

        ## CreateDefaultInventory

        **Realm:** Server

        **Description:**
            Called when creating a default inventory for a character. Should return a [deferred](https://github.com/Be1zebub/luassert-deferred) (or similar promise) object that resolves with the new inventory.
            

        ---

        ### Example

            ```lua
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
            ```

        ## CreateInventoryPanel

        **Realm:** Client

        **Description:**
            Client-side call when creating the graphical representation of an inventory.
            

        ---

        ### Parameters

            * inventory
            * parent (Panel)

        ---

        ### Example

            ```lua
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
            ```

        ## CreateSalaryTimer

        **Realm:** Shared

        **Description:**
            Creates a timer to manage player salary.
            

        ---

        ### Parameters

            * client (Player)

        ---

        ### Example

            ```lua
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
            ```

        ## DoModuleIncludes

        **Realm:** Shared

        **Description:**
            Called when modules include submodules. Useful for advanced module handling or dependency management.
            

        ---

        ### Parameters

            * path (string)
            * module (table)

        ---

        ### Example

            ```lua
            hook.Add("DoModuleIncludes", "TrackModuleDependencies", function(path, module)
            print("Including submodule from path:", path)
            module.dependencies = module.dependencies or {}
            table.insert(module.dependencies, "base_module")
            end)
            ```

        ## GetDefaultCharDesc

        **Realm:** Server

        **Description:**
            Retrieves a default description for a character during creation. Return `(defaultDesc, overrideBool)`.
            

        ---

        ### Parameters

            * client (Player)
            * faction (number)

        ---

        ### Returns

            * string: The default description.
            * bool: Whether to override.

        ---

        ### Example

            ```lua
            hook.Add("GetDefaultCharDesc", "CitizenDefaultDesc", function(client, faction)
            if faction == FACTION_CITIZEN then
            return "A hardworking member of society.", true
            end
            end)
            ```

        ## GetDefaultCharName

        **Realm:** Server

        **Description:**
            Retrieves a default name for a character during creation. Return `(defaultName, overrideBool)`.
            

        ---

        ### Parameters

            * client (Player): The player creating the character.
            * faction (number): The faction index.
            * data (table): Additional creation data.

        ---

        ### Returns

            * string: The default name.
            * bool: Whether to override the user-provided name.

        ---

        ### Example

            ```lua
            hook.Add("GetDefaultCharName", "PoliceDefaultName", function(client, faction, data)
            if faction == FACTION_POLICE then
            return "Officer " .. data.lastName or "Smith", true
            end
            end)
            ```

        ## GetSalaryAmount

        **Realm:** Shared

        **Description:**
            Retrieves the amount of salary a player should receive.
            

        ---

        ### Parameters

            * client (Player)
            * faction (table)
            * class (table)

        ---

        ### Returns

            * any: The salary amount

        ---

        ### Example

            ```lua
            hook.Add("GetSalaryAmount", "CalculateDynamicSalary", function(client, faction, class)
            local baseSalary = faction.baseSalary or 1000
            local classBonus = class.salaryBonus or 0
            return baseSalary + classBonus
            end)
            ```

        ## GetSalaryLimit

        **Realm:** Shared

        **Description:**
            Retrieves the salary limit for a player.
            

        ---

        ### Parameters

            * client (Player)
            * faction (table)
            * class (table)

        ---

        ### Returns

            * any: The salary limit

        ---

        ### Example

            ```lua
            hook.Add("GetSalaryLimit", "SetSalaryLimitsBasedOnRole", function(client, faction, class)
            if faction.name == "Police" then
            return 5000 -- Police have a higher salary limit
            elseif faction.name == "Citizen" then
            return 2000
            end
            end)
            ```

        ## InitializedConfig

        **Realm:** Shared

        **Description:**
            Called when `lia.config` is fully initialized.
            

        ---

        ### Example

            ```lua
            function MODULE:InitializedConfig()
            if lia.config.enableSpecialFeatures then
            lia.features.enable()
            print("Special features have been enabled.")
            else
            print("Special features are disabled in the config.")
            end
            end
            ```

        ## InitializedItems

        **Realm:** Shared

        **Description:**
            Called once all item modules have been loaded from a directory.
            

        ---

        ### Example

            ```lua
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
            ```

        ## InitializedModules

        **Realm:** Shared

        **Description:**
            Called after all modules are fully initialized.
            

        ---

        ### Example

            ```lua
            hook.Add("InitializedModules", "FinalizeModuleSetup", function()
            lia.modules.finalizeSetup()
            print("All modules have been fully initialized.")
            end)
            ```

        ## InitializedOptions

        **Realm:** Client

        **Description:**
            Called when `lia.option` is fully initialized.
            

        ---

        ### Example

            ```lua
            function MODULE:InitializedOptions()
            LocalPlayer():ChatPrint("LOADED OPTIONS!")
            end
            ```

        ## InitializedSchema

        **Realm:** Shared

        **Description:**
            Called after the schema has finished initializing.
            

        ---

        ### Example

            ```lua
            hook.Add("InitializedSchema", "SchemaReadyNotification", function()
            print("Schema has been successfully initialized.")
            lia.notifications.broadcast("Welcome to the server! The schema is now active.")
            end)
            ```

        ## InterceptClickItemIcon

        **Realm:** Client

        **Description:**
            Called when a player clicks on an item icon.
            

        ---

        ### Parameters

            * self (panel)
            * itemIcon (panel)
            * keyCode (int)

        ---

        ### Example

            ```lua
            hook.Add("InterceptClickItemIcon", "HandleItemDoubleClick", function(self, itemIcon, keyCode)
            if keyCode == KEY_MOUSE2 then -- Right-click
            local item = itemIcon:getItem()
            lia.ui.openItemContextMenu(item, itemIcon:GetPos())
            print("Item context menu opened for:", item.name)
            end
            end)
            ```

        ## ItemCombine

        **Realm:** Server

        **Description:**
            Called when the system attempts to combine one item with another in an inventory.
            

        ---

        ### Parameters

            * client (Player)
            * item (Item)
            * targetItem (Item)

        ---

        ### Returns

            * bool: true if combination is valid and consumed, false otherwise.

        ---

        ### Example

            ```lua
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
            ```

        ## KeyLock

        **Realm:** Server

        **Description:**
            Called when a player attempts to lock a door.
            

        ---

        ### Parameters

            * owner (Player)
            * entity (Entity)
            * time (float)

        ---

        ### Example

            ```lua
            hook.Add("KeyLock", "LogDoorLock", function(owner, entity, time)
            entity:setLocked(true)
            lia.log.write("DoorLock", owner:Name() .. " locked door ID: " .. entity:EntIndex() .. " for " .. time .. " seconds.")
            print(owner:Name() .. " locked door ID:", entity:EntIndex(), "for", time, "seconds.")
            end)
            ```

        ## KeyUnlock

        **Realm:** Server

        **Description:**
            Called when a player attempts to unlock a door.
            

        ---

        ### Parameters

            * owner (Player)
            * entity (Entity)
            * time (float)

        ---

        ### Example

            ```lua
            hook.Add("KeyUnlock", "LogDoorUnlock", function(owner, entity, time)
            entity:setLocked(false)
            lia.log.write("DoorUnlock", owner:Name() .. " unlocked door ID: " .. entity:EntIndex() .. " after " .. time .. " seconds.")
            print(owner:Name() .. " unlocked door ID:", entity:EntIndex(), "after", time, "seconds.")
            end)
            ```

        ## LiliaTablesLoaded

        **Realm:** Server

        **Description:**
            Called after all essential DB tables have been loaded.
            

        ---

        ### Example

            ```lua
            hook.Add("LiliaTablesLoaded", "InitializeGameState", function()
            lia.gameState = lia.gameState or {}
            lia.gameState.activeEvents = {}
            print("All essential Lilia tables have been loaded. Game state initialized.")
            end)
            ```

        ## OnItemRegistered

        **Realm:** Shared

        **Description:**
            Called after an item has been registered. Useful for customizing item behavior or adding properties.
            

        ---

        ### Parameters

            * item (Item)

        ---

        ### Example

            ```lua
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
            ```

        ## OnLoadTables

        **Realm:** Shared

        **Description:**
            Called before the faction tables are loaded. Good spot for data setup prior to factions being processed.
            

        ---

        ### Example

            ```lua
            hook.Add("OnLoadTables", "SetupFactionDefaults", function()
            lia.factions = lia.factions or {}
            lia.factions.defaultPermissions = {canUseWeapons = true, canAccessBank = false}
            print("Faction defaults have been set up.")
            end)
            ```

        ## OnMySQLOOConnected

        **Realm:** Server

        **Description:**
            Called when MySQLOO successfully connects to the database. Use to register prepared statements or init DB logic.
            

        ---

        ### Example

            ```lua
            hook.Add("OnMySQLOOConnected", "PrepareDatabaseStatements", function()
            lia.db.prepare("insertPlayer", "INSERT INTO lia_players (_steamID, _steamName) VALUES (?, ?)", {MYSQLOO_STRING, MYSQLOO_STRING})
            lia.db.prepare("updatePlayerStats", "UPDATE lia_players SET kills = ?, deaths = ? WHERE _steamID = ?", {MYSQLOO_NUMBER, MYSQLOO_NUMBER, MYSQLOO_STRING})
            print("Prepared MySQLOO statements.")
            end)
            ```

        ## OnPlayerPurchaseDoor

        **Realm:** Server

        **Description:**
            Called when a player purchases or sells a door.
            

        ---

        ### Parameters

            * client (Player)
            * entity (Entity): The door
            * buying (bool): True if buying, false if selling
            * CallOnDoorChild (function)

        ---

        ### Example

            ```lua
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
            ```

        ## OnServerLog

        **Realm:** Server

        **Description:**
            Called whenever a new log message is added. Allows for custom logic or modifications to log handling.
            

        ---

        ### Parameters

            * client (Player)
            * logType (string)
            * logString (string)
            * category (string)
            * color (Color)

        ---

        ### Example

            ```lua
            hook.Add("OnServerLog", "AlertAdminsOnHighSeverity", function(client, logType, logString, category, color)
            if category == "error" then
            for _, admin in player.Iterator() do
            if admin:isAdmin() then
            lia.notifications.send(admin, "Error Log: " .. logString, color)
            end
            end
            end
            end)
            ```

        ## OnWipeTables

        **Realm:** Server

        **Description:**
            Called after wiping tables in the DB, typically after major resets/cleanups.
            

        ---

        ### Example

            ```lua
            hook.Add("OnWipeTables", "ReinitializeDefaults", function()
            lia.db.execute("INSERT INTO lia_factions (name, description) VALUES ('Citizen', 'Regular inhabitants.')")
            lia.db.execute("INSERT INTO lia_classes (name, faction) VALUES ('Warrior', 'Citizen')")
            print("Database tables wiped and defaults reinitialized.")
            end)
            ```

        ## PlayerMessageSend

        **Realm:** Shared

        **Description:**
            Called before a chat message is sent. Return `false` to cancel, or modify the message if returning a string.
            

        ---

        ### Parameters

            * speaker (Player)
            * chatType (string)
            * message (string)
            * anonymous (bool)

        ---

        ### Returns

            * bool|nil|modifiedString: false to cancel, or return a modified string to change the message.

        ---

        ### Example

            ```lua
            hook.Add("PlayerMessageSend", "FilterProfanity", function(speaker, chatType, message, anonymous)
            local filteredMessage = string.gsub(message, "badword", "****")
            if filteredMessage ~= message then
            return filteredMessage
            end
            end)
            ```

        ## PlayerModelChanged

        **Realm:** Shared

        **Description:**
            Called when a player's model changes.
            

        ---

        ### Parameters

            * client (Player): The player whose model changed.
            * model (string): The new model path.

        ---

        ### Example

            ```lua
            hook.Add("PlayerModelChanged", "UpdatePlayerAppearance", function(client, model)
            print(client:Name() .. " changed their model to " .. model)
            -- Update related appearance settings
            client:setBodygroup(1, 2) -- Example of setting a bodygroup based on the new model
            end)
            ```

        ## PlayerUseDoor

        **Realm:** Server

        **Description:**
            Called when a player attempts to use a door entity.
            

        ---

        ### Parameters

            * client (Player)
            * entity (Entity)

        ---

        ### Returns

            * bool|nil: false to disallow, true to allow, or nil to let other hooks decide.

        ---

        ### Example

            ```lua
            hook.Add("PlayerUseDoor", "LogDoorUsage", function(client, entity)
            print(client:Name() .. " is attempting to use door ID:", entity:EntIndex())
            -- Allow or disallow based on custom conditions
            if client:isBanned() then
            return false -- Disallow use if the player is banned
            end
            end)
            ```

        ## RegisterPreparedStatements

        **Realm:** Server

        **Description:**
            Called for registering DB prepared statements post-MySQLOO connection.
            

        ---

        ### Example

            ```lua
            ```

        ## ShouldBarDraw

        **Realm:** Client

        **Description:**
            Determines whether a specific HUD bar should be drawn.
            

        ---

        ### Parameters

            * barName (string): e.g. "health", "armor".

        ---

        ### Returns

            * bool|nil: false to hide, nil to allow.

        ---

        ### Example

            ```lua
            hook.Add("ShouldBarDraw", "HideArmorHUD", function(barName)
            if barName == "armor" then
            return false
            end
            end)
            ```

        ## ShouldDisableThirdperson

        **Realm:** Client

        **Description:**
            Checks if third-person view is allowed or disabled.
            

        ---

        ### Parameters

            * client (Player)

        ---

        ### Returns

            * bool (true if 3rd-person should be disabled)

        ---

        ### Example

            ```lua
            hook.Add("ShouldDisableThirdperson", "DisableForInvisibles", function(client)
            if client:isInvisible() then
            return true -- Disable third-person view when invisible
            end
            end)
            ```

        ## ShouldHideBars

        **Realm:** Client

        **Description:**
            Determines whether all HUD bars should be hidden.
            

        ---

        ### Returns

            * bool|nil: true to hide, nil to allow rendering.

        ---

        ### Example

            ```lua
            hook.Add("ShouldHideBars", "HideHUDInCinematic", function()
            if gui.IsInCinematicMode() then
            return true
            end
            end)
            ```

        ## thirdPersonToggled

        **Realm:** Client

        **Description:**
            Called when third-person mode is toggled on or off. Allows for custom handling of third-person mode changes.
            

        ---

        ### Parameters

            * state (bool): true if third-person is enabled, false if disabled.

        ---

        ### Example

            ```lua
            hook.Add("thirdPersonToggled", "NotifyThirdPersonChange", function(state)
            if state then
            chat.AddText(Color(0,255,0), "Third-person view enabled.")
            else
            chat.AddText(Color(255,0,0), "Third-person view disabled.")
            end
            print("Third-person mode toggled to:", state)
            end)
            ```

        ## AddTextField

        **Realm:** Client

        **Description:**
            Called when a text field is added to an F1 menu information section.
            Allows modules to modify or monitor the field being inserted.
            

        ---

        ### Parameters

            * sectionName (string)
            * fieldName (string)
            * labelText (string)
            * valueFunc (function)

        ---

        ### Example

            ```lua
            -- Change the money field label.
            hook.Add("AddTextField", "RenameMoneyField", function(section, name, label, value)
            if name == "money" then
            return section, name, "Credits", value
            end
            end)
            ```

        ## F1OnAddTextField

        **Realm:** Client

        **Description:**
            Fired after AddTextField so other modules can react to new fields.
            

        ---

        ### Parameters

            * sectionName (string)
            * fieldName (string)
            * labelText (string)
            * valueFunc (function)

        ---

        ### Example

            ```lua
            -- Log newly added fields.
            hook.Add("F1OnAddTextField", "LogFields", function(section, name)
            print("Added field", name, "to section", section)
            end)
            ```

        ## F1OnAddBarField

        **Realm:** Client

        **Description:**
            Triggered after AddBarField inserts a status bar into the F1 menu.
            

        ---

        ### Parameters

            * sectionName (string)
            * fieldName (string)
            * labelText (string)
            * minFunc (function)
            * maxFunc (function)
            * valueFunc (function)

        ---

        ### Example

            ```lua
            hook.Add("F1OnAddBarField", "TrackBars", function(section, name)
            print("Added bar", name)
            end)
            ```

        ## CreateInformationButtons

        **Realm:** Client

        **Description:**
            Called while building the F1 information menu to populate navigation buttons.
            

        ---

        ### Parameters

            * pages (table)

        ---

        ### Example

            ```lua
            hook.Add("CreateInformationButtons", "AddHelpPage", function(pages)
            table.insert(pages, {name = "Help", drawFunc = function(parent) end})
            end)
            ```

        ## PopulateConfigurationButtons

        **Realm:** Client

        **Description:**
            Invoked when the settings tab is constructed allowing new configuration pages.
            

        ---

        ### Parameters

            * pages (table)

        ---

        ### Example

            ```lua
            hook.Add("PopulateConfigurationButtons", "AddControlsPage", function(pages)
            table.insert(pages, {name = "Controls", drawFunc = function(p) end})
            end)
            ```

        ## InitializedKeybinds

        **Realm:** Client

        **Description:**
            Called after keybinds have been loaded from disk.
            

        ---

        ### Example

            ```lua
            hook.Add("InitializedKeybinds", "NotifyKeybinds", function()
            chat.AddText("Keybinds loaded")
            end)
            ```

        ## getOOCDelay

        **Realm:** Server

        **Description:**
            Allows modification of the cooldown delay between OOC messages.
            

        ---

        ### Parameters

            * client (Player)

        ---

        ### Returns

            * number|nil – Custom cooldown in seconds.

        ---

        ### Example

            ```lua
            hook.Add("getOOCDelay", "AdminOOC", function(ply)
            if ply:IsAdmin() then
            return 5
            end
            end)
            ```

        ## OnChatReceived

        **Realm:** Client

        **Description:**
            Runs on the client when chat text is received before display.
            Returning modified text will replace the message.
            

        ---

        ### Parameters

            * client (Player)
            * chatType (string)
            * text (string)
            * anonymous (boolean)

        ---

        ### Returns

            * string|nil – Replacement text.

        ---

        ### Example

            ```lua
            hook.Add("OnChatReceived", "CensorChat", function(ply, type, msg)
            return msg:gsub("badword", "****")
            end)
            ```

        ## getAdjustedPartData

        **Realm:** Client

        **Description:**
            Requests PAC3 part data after adjustments have been applied.
            

        ---

        ### Parameters

            * wearer (Entity)
            * id (string)

        ---

        ### Returns

            * table|nil – Adjusted part data.

        ---

        ### Example

            ```lua
            hook.Add("getAdjustedPartData", "DebugParts", function(ply, partID)
            print("Requesting part", partID)
            end)
            ```

        ## AdjustPACPartData

        **Realm:** Client

        **Description:**
            Allows modules to modify PAC3 part data before it is attached.
            

        ---

        ### Parameters

            * wearer (Entity)
            * id (string)
            * data (table)

        ---

        ### Returns

            * table|nil – Modified data table.

        ---

        ### Example

            ```lua
            hook.Add("AdjustPACPartData", "ColorParts", function(ply, partID, d)
            d.Color = Vector(1,0,0)
            return d
            end)
            ```

        ## attachPart

        **Realm:** Client

        **Description:**
            Called when a PAC3 part should be attached to a player.
            

        ---

        ### Parameters

            * client (Player)
            * id (string)

        ---

        ### Example

            ```lua
            hook.Add("attachPart", "AnnouncePart", function(ply, partID)
            print(ply, "received part", partID)
            end)
            ```

        ## removePart

        **Realm:** Client

        **Description:**
            Triggered when a PAC3 part is removed from a player.
            

        ---

        ### Parameters

            * client (Player)
            * id (string)

        ---

        ### Example

            ```lua
            hook.Add("removePart", "LogPartRemoval", function(ply, partID)
            print(partID, "removed from", ply)
            end)
            ```

        ## OnPAC3PartTransfered

        **Realm:** Client

        **Description:**
            Fired when a PAC3 outfit part transfers ownership to a ragdoll.
            

        ---

        ### Parameters

            * part (Entity)

        ---

        ### Example

            ```lua
            hook.Add("OnPAC3PartTransfered", "TrackTransfers", function(p)
            print("Part transferred", p)
            end)
            ```

        ## DrawPlayerRagdoll

        **Realm:** Client

        **Description:**
            Allows custom rendering of a player's ragdoll created by PAC3.
            

        ---

        ### Parameters

            * entity (Entity)

        ---

        ### Example

            ```lua
            hook.Add("DrawPlayerRagdoll", "TintRagdoll", function(ent)
            render.SetColorModulation(1,0,0)
            end)
            ```

        ## setupPACDataFromItems

        **Realm:** Client

        **Description:**
            Initializes PAC3 outfits from equipped items after modules load.
            

        ---

        ### Example

            ```lua
            hook.Add("setupPACDataFromItems", "InitPAC", function()
            print("Equipped PAC data loaded")
            end)
            ```

        ## TryViewModel

        **Realm:** Client

        **Description:**
            Allows PAC3 to swap the view model entity for event checks.
            

        ---

        ### Parameters

            * entity (Entity)

        ---

        ### Returns

            * Entity – Replacement entity.

        ---

        ### Example

            ```lua
            hook.Add("TryViewModel", "UsePlayerViewModel", function(ent)
            return ent == LocalPlayer():GetViewModel() and LocalPlayer() or ent
            end)
            ```

        ## WeaponCycleSound

        **Realm:** Client

        **Description:**
            Lets modules provide a custom sound when cycling weapons in the selector.
            

        ---

        ### Returns

            * string|nil – Sound path.
            * number|nil – Playback pitch.

        ---

        ### Example

            ```lua
            hook.Add("WeaponCycleSound", "SilentCycle", function()
            return "buttons/button15.wav", 100
            end)
            ```

        ## WeaponSelectSound

        **Realm:** Client

        **Description:**
            Similar to WeaponCycleSound but used when confirming a weapon choice.
            

        ---

        ### Returns

            * string|nil – Sound path.
            * number|nil – Playback pitch.

        ---

        ### Example

            ```lua
            hook.Add("WeaponSelectSound", "CustomSelectSound", function()
            return "buttons/button24.wav", 90
            end)
            ```

        ## ShouldDrawWepSelect

        **Realm:** Client

        **Description:**
            Determines if the weapon selection UI should be visible.
            

        ---

        ### Parameters

            * client (Player)

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            hook.Add("ShouldDrawWepSelect", "HideInVehicles", function(ply)
            return not ply:InVehicle()
            end)
            ```

        ## CanPlayerChooseWeapon

        **Realm:** Client

        **Description:**
            Checks whether the active weapon can be selected via the weapon wheel.
            

        ---

        ### Parameters

            * weapon (Weapon)

        ---

        ### Returns

            * boolean|nil – false to block selection.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerChooseWeapon", "BlockPhysgun", function(wep)
            if IsValid(wep) and wep:GetClass() == "weapon_physgun" then
            return false
            end
            end)
            ```

        ## OverrideSpawnTime

        **Realm:** Client

        **Description:**
            Allows modules to modify the respawn delay after death.
            

        ---

        ### Parameters

            * client (Player)
            * baseTime (number)

        ---

        ### Returns

            * number|nil – New respawn time.

        ---

        ### Example

            ```lua
            hook.Add("OverrideSpawnTime", "ShortRespawns", function(ply, time)
            if ply:IsAdmin() then return 2 end
            end)
            ```

        ## ShouldRespawnScreenAppear

        **Realm:** Client

        **Description:**
            Lets modules suppress the respawn HUD from showing.
            

        ---

        ### Returns

            * boolean|nil – false to hide.

        ---

        ### Example

            ```lua
            hook.Add("ShouldRespawnScreenAppear", "NoRespawnHUD", function()
            return false
            end)
            ```

        ## VoiceToggled

        **Realm:** Shared

        **Description:**
            Fired when voice chat is enabled or disabled via config.
            

        ---

        ### Parameters

            * enabled (boolean)

        ---

        ### Example

            ```lua
            hook.Add("VoiceToggled", "AnnounceVoice", function(state)
            print("Voice chat set to", state)
            end)
            ```

        ## RefreshFonts

        **Realm:** Client

        **Description:**
            Requests recreation of all registered UI fonts.
            

        ---

        ### Example

            ```lua
            hook.Add("RefreshFonts", "ReloadFonts", function()
            print("Fonts refreshed")
            end)
            ```

        ## AdjustCreationData

        **Realm:** Server

        **Description:**
            Allows modification of character creation data before the character is saved.
            

        ---

        ### Parameters

            * client (Player)
            * data (table)
            * newData (table)
            * originalData (table)

        ---

        ### Example

            ```lua
            hook.Add("AdjustCreationData", "EnforceName", function(ply, data, newData)
            if data.name == "" then newData.name = "Unnamed" end
            end)
            ```

        ## CanCharBeTransfered

        **Realm:** Server

        **Description:**
            Determines if a character may switch factions.
            

        ---

        ### Parameters

            * character (table)
            * newFaction (table)
            * oldFaction (number)

        ---

        ### Returns

            * bool|nil – false to block.

        ---

        ### Example

            ```lua
            hook.Add("CanCharBeTransfered", "BlockRestrictedFactions", function(char, faction)
            if faction.isRestricted then return false end
            end)
            ```

        ## CanPlayerUseChar

        **Realm:** Server

        **Description:**
            Called when a player attempts to load one of their characters.
            

        ---

        ### Parameters

            * client (Player)
            * character (table)

        ---

        ### Returns

            * bool|nil – false to deny.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerUseChar", "CheckBans", function(ply, char)
            if char:isBanned() then return false, "Character banned" end
            end)
            ```

        ## CanPlayerSwitchChar

        **Realm:** Server

        **Description:**
            Checks if a player can switch from their current character to another.
            

        ---

        ### Parameters

            * client (Player)
            * currentChar (table)
            * newChar (table)

        ---

        ### Returns

            * bool|nil – false to block the switch.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerSwitchChar", "NoSwitchInCombat", function(ply)
            if ply:isInCombat() then return false end
            end)
            ```

        ## CanPlayerLock

        **Realm:** Server

        **Description:**
            Determines whether the player may lock the given door or vehicle.
            

        ---

        ### Parameters

            * client (Player)
            * door (Entity)

        ---

        ### Returns

            * bool|nil – false to disallow.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerLock", "AdminsAlwaysLock", function(ply)
            if ply:IsAdmin() then return true end
            end)
            ```

        ## CanPlayerUnlock

        **Realm:** Server

        **Description:**
            Determines whether the player may unlock the given door or vehicle.
            

        ---

        ### Parameters

            * client (Player)
            * door (Entity)

        ---

        ### Returns

            * bool|nil – false to disallow.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerUnlock", "AdminsAlwaysUnlock", function(ply)
            if ply:IsAdmin() then return true end
            end)
            ```

        ## CanPlayerModifyConfig

        **Realm:** Server

        **Description:**
            Called when a player attempts to change a configuration value.
            

        ---

        ### Parameters

            * client (Player)
            * key (string)

        ---

        ### Returns

            * bool|nil – false to deny modification.

        ---

        ### Example

            ```lua
            hook.Add("CanPlayerModifyConfig", "RestrictConfig", function(ply, k)
            return ply:IsSuperAdmin()
            end)
            ```

        ## CharDeleted

        **Realm:** Server

        **Description:**
            Fired after a character is permanently removed.
            

        ---

        ### Parameters

            * client (Player)
            * character (table)

        ---

        ### Example

            ```lua
            hook.Add("CharDeleted", "LogDeletion", function(ply, char)
            print(ply:Name(), "deleted character", char:getName())
            end)
            ```

        ## CheckFactionLimitReached

        **Realm:** Shared

        **Description:**
            Allows custom logic for determining if a faction has reached its player limit.
            

        ---

        ### Parameters

            * faction (table)
            * character (table)
            * client (Player)

        ---

        ### Returns

            * boolean

        ---

        ### Example

            ```lua
            hook.Add("CheckFactionLimitReached", "IgnoreAdmins", function(faction, char, ply)
            if ply:IsAdmin() then
            return false
            end
            end)
            ```

        ## F1OnAddSection

        **Realm:** Client

        **Description:**
            Triggered after AddSection inserts a new information section.
            

        ---

        ### Parameters

            * sectionName (string)
            * color (Color)
            * priority (number)
            * location (number)

        ---

        ### Example

            ```lua
            hook.Add("F1OnAddSection", "PrintSection", function(name)
            print("Added section", name)
            end)
            ```

        ## GetWeaponName

        **Realm:** Client

        **Description:**
            Allows overriding of the displayed weapon name in the selector.
            

        ---

        ### Parameters

            * weapon (Weapon)

        ---

        ### Returns

            * string|nil – Replacement name.

        ---

        ### Example

            ```lua
            hook.Add("GetWeaponName", "UppercaseName", function(wep)
            return wep:GetClass():upper()
            end)
            ```

        ## OnCharGetup

        **Realm:** Server

        **Description:**
            Called when a ragdolled character finishes getting up.
            

        ---

        ### Parameters

            * client (Player)
            * **entity** *(Entity)*: Ragdoll entity.

        ---

        ### Example

            ```lua
            hook.Add("OnCharGetup", "NotifyGetup", function(ply)
            ply:ChatPrint("You stood up")
            end)
            ```

        ## OnLocalizationLoaded

        **Realm:** Shared

        **Description:**
            Fired once language files finish loading.
            

        ---

        ### Example

            ```lua
            hook.Add("OnLocalizationLoaded", "PrintLang", function()
            print("Localization ready")
            end)
            ```

        ## OnPlayerObserve

        **Realm:** Server

        **Description:**
            Called when a player's observe mode is toggled.
            

        ---

        ### Parameters

            * client (Player)
            * state (boolean)

        ---

        ### Example

            ```lua
            hook.Add("OnPlayerObserve", "AnnounceObserve", function(ply, s)
            print(ply, s and "entered" or "left", "observe mode")
            end)
            ```

        ## PlayerLoadedChar

        **Realm:** Server

        **Description:**
            Runs after a character has been loaded and set up for a player.
            

        ---

        ### Parameters

            * client (Player)
            * character (table)
            * previousChar (table|nil)

        ---

        ### Example

            ```lua
            hook.Add("PlayerLoadedChar", "WelcomeBack", function(ply, char)
            ply:ChatPrint("Welcome, " .. char:getName())
            end)
            ```

        ## PrePlayerLoadedChar

        **Realm:** Server

        **Description:**
            Fired right before a player switches to a new character.
            

        ---

        ### Parameters

            * client (Player)
            * newChar (table)
            * oldChar (table|nil)

        ---

        ### Example

            ```lua
            hook.Add("PrePlayerLoadedChar", "SaveStuff", function(ply, new, old)
            print("Switching characters")
            end)
            ```

        ## PostPlayerLoadedChar

        **Realm:** Server

        **Description:**
            Called after PlayerLoadedChar to allow post-load operations.
            

        ---

        ### Parameters

            * client (Player)
            * character (table)
            * previousChar (table|nil)

        ---

        ### Example

            ```lua
            hook.Add("PostPlayerLoadedChar", "GiveItems", function(ply, char)
            -- Give starter items here
            end)
            ```

        ## PlayerSay

        **Realm:** Server

        **Description:**
            Custom hook executed when a player sends a chat message server-side.
            

        ---

        ### Parameters

            * client (Player)
            * text (string)

        ---

        ### Example

            ```lua
            hook.Add("PlayerSay", "LogChat", function(ply, msg)
            print(ply:Name() .. ": " .. msg)
            end)
            ```

        ## PopulateAdminStick

        **Realm:** Client

        **Description:**
            Called after the admin stick menu is created so additional commands can be added.
            

        ---

        ### Parameters

            * menu (DermaPanel)
            * target (Entity)

        ---

        ### Example

            ```lua
            hook.Add("PopulateAdminStick", "AddCustomOption", function(menu, ent)
            menu:AddOption("Wave", function() RunConsoleCommand("act", "wave") end)
            end)
            ```

        ## TicketSystemClaim

        **Realm:** Server

        **Description:**
            Fired when a staff member claims a help ticket.
            

        ---

        ### Parameters

            * admin (Player)
            * requester (Player)

        ---

        ### Example

            ```lua
            hook.Add("TicketSystemClaim", "NotifyClaim", function(staff, ply)
            staff:ChatPrint("Claimed ticket from " .. ply:Name())
            end)
            ```

        ## liaOptionReceived

        **Realm:** Server

        **Description:**
            Triggered when a shared option value is changed.
            

        ---

        ### Parameters

            * client (Player|nil)
            * key (string)
            * value (any)

        ---

        ### Example

            ```lua
            hook.Add("liaOptionReceived", "PrintOptionChange", function(_, k, v)
            print("Option", k, "set to", v)
            end)
            ```

