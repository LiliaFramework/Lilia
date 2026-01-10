--[[
    Folder: Hooks
    File:  server.md
]]
--[[
    Server-Side Hooks

    Server-side hook system for the Lilia framework.
    These hooks run on the server and are used for server-side logic, data management, and game state handling.
]]
--[[
    Overview:
        Server-side hooks in the Lilia framework handle server-side logic, data persistence, permissions, character management, and other server-specific functionality. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
]]
--[[
    Purpose:
        Records a warning entry for a character and lets modules react to the new warning.

    When Called:
        Fired whenever a warning is issued via admin commands, anti-cheat triggers, or net requests.

    Parameters:
        charID (number|string)
            Character database identifier being warned.
        warned (string)
            Display name of the warned player.
        warnedSteamID (string)
            SteamID of the warned player.
        timestamp (number)
            Unix timestamp when the warning was created.
        message (string)
            Reason text for the warning.
        warner (string)
            Name of the admin or system issuing the warning.
        warnerSteamID (string)
            SteamID of the issuer.
        severity (string)
            Severity label such as Low/Medium/High.

    Returns:
        string
            Final severity value chosen (if modified) or nil.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("AddWarning", "LogWarning", function(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
                lia.log.add(warner, "warningIssued", warned, severity, message)
            end)
        ```
]]
function AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
end

--[[
    Purpose:
        Collect additional field definitions for door data.

    When Called:
        When retrieving default door values and field definitions.

    Parameters:
        extras (table)
            Table to populate with additional field definitions in the format {fieldName = {default = value, ...}}.

    Returns:
        nil
            Modify the extras table directly.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CollectDoorDataFields", "ExampleCollectDoorDataFields", function(extras)
                extras.customField = {default = false, type = "boolean"}
            end)
        ```
]]
function CollectDoorDataFields(extras)
end

--[[
    Purpose:
        Determines if an item move is allowed before completing a transfer between inventories.

    When Called:
        Checked whenever an item is about to be moved to another inventory (including vendors).

    Parameters:
        item (Item)
            Item instance being transferred.
        inventory (Inventory)
            Destination inventory.
        VendorInventoryMeasure (boolean)
            True when the transfer originates from a vendor panel.
        client (Player)
            Player requesting the transfer.

    Returns:
        boolean
            False to block the transfer; nil/true to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanItemBeTransfered", "LimitAmmoMoves", function(item, inventory, isVendor, client)
                if isVendor and item.isWeapon then return false end
            end)
        ```
]]
function CanItemBeTransfered(item, inventory, VendorInventoryMeasure, client)
end

--[[
    Purpose:
        Decides if an entity should be recorded in the persistence system.

    When Called:
        Invoked while scanning entities for persistence during map saves.

    Parameters:
        entity (Entity)
            The world entity being evaluated.

    Returns:
        boolean
            False to skip saving this entity; nil/true to include it.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPersistEntity", "IgnoreRagdolls", function(ent)
                if ent:IsRagdoll() then return false end
            end)
        ```
]]
function CanPersistEntity(entity)
end

--[[
    Purpose:
        Lets modules override door access checks before built-in permissions are evaluated.

    When Called:
        Queried whenever door access is validated in entity:checkDoorAccess.

    Parameters:
        client (Player)
            Player requesting access.
        door (Entity)
            Door entity being checked.
        access (number)
            Required access level (e.g., DOOR_OWNER, DOOR_TENANT, DOOR_GUEST).

    Returns:
        boolean
            True to grant access regardless of stored permissions; nil to fall back to defaults.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerAccessDoor", "StaffOverrideDoor", function(client, door)
                if client:isStaffOnDuty() then return true end
            end)
        ```
]]
function CanPlayerAccessDoor(client, door, access)
end

--[[
    Purpose:
        Allows or denies a player opening/using a vendor entity.

    When Called:
        Checked when a player attempts to access a vendor UI.

    Parameters:
        client (Player)
            Player interacting with the vendor.
        vendor (Entity)
            Vendor entity being accessed.

    Returns:
        boolean
            False to block interaction; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerAccessVendor", "FactionLockVendors", function(client, vendor)
                if not vendor:isFactionAllowed(client:Team()) then return false end
            end)
        ```
]]
function CanPlayerAccessVendor(client, vendor)
end

--[[
    Purpose:
        Controls whether a player may drop a specific item from their inventory.

    When Called:
        Triggered before an item drop is performed.

    Parameters:
        client (Player)
            Player attempting to drop the item.
        item (Item)
            Item instance being dropped.

    Returns:
        boolean
            False to block the drop; true/nil to permit.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerDropItem", "NoQuestItemDrops", function(client, item)
                if item.isQuestItem then return false end
            end)
        ```
]]
function CanPlayerDropItem(client, item)
end

--[[
    Purpose:
        Checks whether a player is eligible to receive their periodic salary.

    When Called:
        Evaluated each time salary is about to be granted.

    Parameters:
        client (Player)
            Player due to receive salary.

    Returns:
        boolean
            False to block salary payment; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerEarnSalary", "JailedNoSalary", function(client)
                if client:isJailed() then return false end
            end)
        ```
]]
function CanPlayerEarnSalary(client)
end

--[[
    Purpose:
        Decides if a player is allowed to equip a given item.

    When Called:
        Checked before the equip logic for any item runs.

    Parameters:
        client (Player)
            Player equipping the item.
        item (Item)
            Item instance being equipped.

    Returns:
        boolean
            False to prevent equipping; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerEquipItem", "RestrictHeavyArmor", function(client, item)
                if item.weight and item.weight > 20 then return false end
            end)
        ```
]]
function CanPlayerEquipItem(client, item)
end

--[[
    Purpose:
        Allows or blocks a player from picking up physics objects with their hands tool.

    When Called:
        Checked before a player grabs an entity with lia_hands.

    Parameters:
        client (Player)
            Player attempting to hold the object.
        entity (Entity)
            Target entity being picked up.

    Returns:
        boolean
            False to prevent picking up; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerHoldObject", "NoHoldingDoors", function(client, ent)
                if ent:isDoor() then return false end
            end)
        ```
]]
function CanPlayerHoldObject(client, entity)
end

--[[
    Purpose:
        Lets modules validate or modify player item interactions (use, drop, split, etc.).

    When Called:
        Fired before an inventory action runs on an item.

    Parameters:
        client (Player)
            Player performing the action.
        action (string)
            Interaction verb such as "drop", "combine", or a custom action ID.
        item (Item)
            Item instance being interacted with.
        data (table)
            Extra data supplied by the action (position, merge target, etc.).

    Returns:
        boolean, string
            False or false,reason to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerInteractItem", "StopHotbarDrop", function(client, action, item)
                if action == "drop" and item.noDrop then return false, L("cannotDrop") end
            end)
        ```
]]
function CanPlayerInteractItem(client, action, item, data)
end

--[[
    Purpose:
        Decides if a player may lock a door or vehicle using provided access rights.

    When Called:
        Evaluated before lock attempts are processed.

    Parameters:
        client (Player)
            Player performing the lock.
        door (Entity)
            Door or vehicle entity targeted.

    Returns:
        boolean
            False to prevent locking; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerLock", "OnlyOwnersLock", function(client, door)
                if not door:checkDoorAccess(client, DOOR_OWNER) then return false end
            end)
        ```
]]
function CanPlayerLock(client, door)
end

--[[
    Purpose:
        Controls visibility of specific log categories to a player.

    When Called:
        Checked before sending a log entry or opening the log viewer.

    Parameters:
        client (Player)
            Player requesting or receiving logs.
        category (string)
            Category identifier of the log.

    Returns:
        boolean
            False to hide the category; true/nil to show.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerSeeLogCategory", "HideAdminLogs", function(client, category)
                if category == "admin" and not client:isStaffOnDuty() then return false end
            end)
        ```
]]
function CanPlayerSeeLogCategory(client, category)
end

--[[
    Purpose:
        Determines whether a player is permitted to spawn a storage entity.

    When Called:
        Invoked when a storage deploy action is requested.

    Parameters:
        client (Player)
            Player spawning the storage.
        entity (Entity)
            Storage entity class about to be created.
        info (table)
            Context info such as item data or position.

    Returns:
        boolean
            False to block spawning; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerSpawnStorage", "LimitStoragePerPlayer", function(client, entity)
                if client:GetCount("lia_storage") >= 2 then return false end
            end)
        ```
]]
function CanPlayerSpawnStorage(client, entity, info)
end

--[[
    Purpose:
        Validates whether a player may switch from their current character to another.

    When Called:
        Checked when a player initiates a character switch.

    Parameters:
        client (Player)
            Player requesting the swap.
        currentCharacter (Character)
            Active character.
        newCharacter (Character)
            Target character to switch to.

    Returns:
        boolean
            False to deny the swap; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerSwitchChar", "BlockDuringCombat", function(client)
                if client:isInCombat() then return false end
            end)
        ```
]]
function CanPlayerSwitchChar(client, currentCharacter, newCharacter)
end

--[[
    Purpose:
        Checks if a player may take an item out of a container or ground entity.

    When Called:
        Fired before item pickup/move from a world/container inventory.

    Parameters:
        client (Player)
            Player attempting to take the item.
        item (Item)
            Item instance being taken.

    Returns:
        boolean
            False to block taking; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerTakeItem", "LockdownLooting", function(client, item)
                if lia.state.isLockdown() then return false end
            end)
        ```
]]
function CanPlayerTakeItem(client, item)
end

--[[
    Purpose:
        Approves or denies a vendor transaction before money/items exchange.

    When Called:
        Invoked when a player tries to buy from or sell to a vendor.

    Parameters:
        client (Player)
            Player trading with the vendor.
        vendor (Entity)
            Vendor entity.
        itemType (string)
            UniqueID of the item being traded.
        isSellingToVendor (boolean)
            True when the player sells an item to the vendor.

    Returns:
        boolean, string, any
            False,reason to cancel; true/nil to allow. Optional third param for formatted message data.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerTradeWithVendor", "RestrictRareItems", function(client, vendor, itemType)
                if lia.item.list[itemType].rarity == "legendary" and not client:isVIP() then
                    return false, L("vendorVIPOnly")
                end
            end)
        ```
]]
function CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Decides if a player may unequip an item currently worn/active.

    When Called:
        Checked before unequip logic runs.

    Parameters:
        client (Player)
            Player requesting to unequip.
        item (Item)
            Item being unequipped.

    Returns:
        boolean
            False to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerUnequipItem", "PreventCombatUnequip", function(client, item)
                if client:isInCombat() then return false end
            end)
        ```
]]
function CanPlayerUnequipItem(client, item)
end

--[[
    Purpose:
        Decides if a player can unlock a door or vehicle.

    When Called:
        Evaluated before unlock attempts are processed.

    Parameters:
        client (Player)
            Player performing the unlock.
        door (Entity)
            Door or vehicle entity targeted.

    Returns:
        boolean
            False to block unlocking; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerUnlock", "OnlyOwnersUnlock", function(client, door)
                if not door:checkDoorAccess(client, DOOR_OWNER) then return false end
            end)
        ```
]]
function CanPlayerUnlock(client, door)
end

--[[
    Purpose:
        Validates that a player can use/load a given character record.

    When Called:
        Checked before spawning the character into the world.

    Parameters:
        client (Player)
            Player requesting to use the character.
        character (Character)
            Character record being selected.

    Returns:
        boolean
            False to prevent selection; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerUseChar", "BanSpecificChar", function(client, character)
                if character:getData("locked") then return false end
            end)
        ```
]]
function CanPlayerUseChar(client, character)
end

--[[
    Purpose:
        Final gate before a player uses a door (open, interact).

    When Called:
        Fired when a player attempts to use a door entity.

    Parameters:
        client (Player)
            Player using the door.
        door (Entity)
            Door entity being used.

    Returns:
        boolean
            False to deny use; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanPlayerUseDoor", "LockdownUse", function(client, door)
                if lia.state.isLockdown() then return false end
            end)
        ```
]]
function CanPlayerUseDoor(client, door)
end

--[[
    Purpose:
        Decides if an entity's data should be included when saving persistent map state.

    When Called:
        During persistence save routines.

    Parameters:
        ent (Entity)
            Entity being evaluated for save.
        inventory (Inventory)
            Inventory attached to the entity (if any).

    Returns:
        boolean
            False to skip saving; true/nil to save.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CanSaveData", "SkipTempProps", function(ent)
                if ent.tempSpawned then return false end
            end)
        ```
]]
function CanSaveData(ent, inventory)
end

--[[
    Purpose:
        Called when salary timers need to be created or recreated.

    When Called:
        During server initialization and when salary timers need to be reset.

    Parameters:
        nil

    Returns:
        nil
            The hook doesn't expect a return value but allows for custom salary timer setup.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CreateSalaryTimers", "ExampleCreateSalaryTimers", function(...)
                -- add custom server-side behavior
            end)
        ```
]]
function CreateSalaryTimers()
end

--[[
    Purpose:
        Provides a cleanup hook when a character is fully removed from the server.

    When Called:
        After character deletion/cleanup logic runs.

    Parameters:
        character (Character)
            Character object being cleaned up.

    Returns:
        nil
            Use side effects only.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CharCleanUp", "RemoveCharTimers", function(character)
                timer.Remove("char_timer_" .. character:getID())
            end)
        ```
]]
function CharCleanUp(character)
end

--[[
    Purpose:
        Notifies that a character has been removed from the database and game.

    When Called:
        After a character is deleted by the player or admin.

    Parameters:
        client (Player)
            Player who owned the character (may be nil if offline).
        character (Character)
            The character that was deleted.

    Returns:
        nil
            Use for cleanup and logging.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CharDeleted", "LogDeletion", function(client, character)
                lia.log.add(client, "charDeleted", character:getName())
            end)
        ```
]]
function CharDeleted(client, character)
end

--[[
    Purpose:
        Adds extra per-character info to the character selection list entry.

    When Called:
        While building the char list shown to the client.

    Parameters:
        client (Player)
            Player viewing the list.
        entry (table)
            Table of character info to be sent.
        stored (table)
            Raw character data from storage.

    Returns:
        table
            Optionally return modified entry data.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CharListExtraDetails", "AddPlaytime", function(client, entry, stored)
                entry.playtime = stored.playtime or 0
                return entry
            end)
        ```
]]
function CharListExtraDetails(client, entry, stored)
end

--[[
    Purpose:
        Runs after a character has been saved to persistence.

    When Called:
        Immediately after character data write completes.

    Parameters:
        character (Character)
            Character that was saved.

    Returns:
        nil
            Use for follow-up actions or logging.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CharPostSave", "QueueBackup", function(character)
                lia.backup.queue(character:getID())
            end)
        ```
]]
function CharPostSave(character)
end

--[[
    Purpose:
        Pre-save hook for characters to sync state into the database payload.

    When Called:
        Right before character data is persisted.

    Parameters:
        character (Character)
            Character about to be saved.

    Returns:
        nil
            Use to modify character data or run side effects.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CharPreSave", "StoreTempAmmo", function(character)
                local client = character:getPlayer()
                if IsValid(client) then character:setData("ammo", client:GetAmmo()) end
            end)
        ```
]]
function CharPreSave(character)
end

--[[
    Purpose:
        Allows factions to enforce population limits before creation/join.

    When Called:
        Checked when a player attempts to create or switch to a faction.

    Parameters:
        faction (table)
            Faction definition table.
        character (Character)
            Character requesting the faction.
        client (Player)
            Player owning the character.

    Returns:
        boolean
            False to block joining; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("CheckFactionLimitReached", "CapCombine", function(faction)
                if faction.uniqueID == "combine" and faction:onlineCount() >= 10 then return false end
            end)
        ```
]]
function CheckFactionLimitReached(faction, character, client)
end

--[[
    Purpose:
        Signals that the database connection is established and ready.

    When Called:
        Once the SQL connection succeeds during initialization.

    Parameters:
        None.

    Returns:
        nil
            Perform setup tasks here.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DatabaseConnected", "InitPlugins", function()
                lia.plugin.loadAll()
            end)
        ```
]]
function DatabaseConnected()
end

--[[
    Purpose:
        Allows modules to intercept and modify Discord relay embeds before sending.

    When Called:
        Right before an embed is pushed to the Discord relay webhook.

    Parameters:
        embed (table)
            Table describing the Discord embed payload.

    Returns:
        table
            Optionally return a modified embed.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DiscordRelaySend", "AddFooter", function(embed)
                embed.footer = {text = "Lilia Relay"}
                return embed
            end)
        ```
]]
function DiscordRelaySend(embed)
end

--[[
    Purpose:
        Notifies the game that the Discord relay feature became unavailable.

    When Called:
        Triggered when the relay HTTP endpoint cannot be reached or is disabled.

    Parameters:
        None.

    Returns:
        nil
            Use for fallbacks or alerts.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DiscordRelayUnavailable", "AlertStaff", function()
                lia.log.add(nil, "discordRelayDown")
            end)
        ```
]]
function DiscordRelayUnavailable()
end

--[[
    Purpose:
        Fired after a Discord relay message has been successfully sent.

    When Called:
        Immediately after the relay HTTP request completes.

    Parameters:
        embed (table)
            Embed table that was sent.

    Returns:
        nil
            Use to log or chain notifications.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DiscordRelayed", "TrackRelayCount", function(embed)
                lia.metrics.bump("discordRelay")
            end)
        ```
]]
function DiscordRelayed(embed)
end

--[[
    Purpose:
        Signals that a door's enabled/disabled state has been toggled.

    When Called:
        After admin tools enable or disable door ownership/usage.

    Parameters:
        client (Player)
            Player who toggled the state.
        door (Entity)
            Door entity affected.
        newState (boolean)
            True when enabled, false when disabled.

    Returns:
        nil
            Use for syncing or logging.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorEnabledToggled", "AnnounceToggle", function(client, door, state)
                lia.log.add(client, "doorEnabledToggle", tostring(state))
            end)
        ```
]]
function DoorEnabledToggled(client, door, newState)
end

--[[
    Purpose:
        Signals that a door has been hidden or unhidden from ownership.

    When Called:
        After the hidden flag is toggled for a door entity.

    Parameters:
        client (Player)
            Player performing the change.
        entity (Entity)
            Door entity affected.
        newState (boolean)
            True when hidden, false when shown.

    Returns:
        nil
            Use for syncing or side effects.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorHiddenToggled", "MirrorToClients", function(_, door, state)
                net.Start("liaDoorHidden") net.WriteEntity(door) net.WriteBool(state) net.Broadcast()
            end)
        ```
]]
function DoorHiddenToggled(client, entity, newState)
end

--[[
    Purpose:
        Fired when a door lock state is toggled (locked/unlocked).

    When Called:
        After lock/unlock succeeds via key or command.

    Parameters:
        client (Player)
            Player who toggled the lock.
        door (Entity)
            Door entity.
        state (boolean)
            True if now locked.

    Returns:
        nil
            Use for logging or notifications.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorLockToggled", "SoundDoorLock", function(_, door, state)
                door:EmitSound(state and "doors/door_latch3.wav" or "doors/door_latch1.wav")
            end)
        ```
]]
function DoorLockToggled(client, door, state)
end

--[[
    Purpose:
        Signals that a door has been marked ownable or unownable.

    When Called:
        After toggling door ownership availability.

    Parameters:
        client (Player)
            Player performing the toggle.
        door (Entity)
            Door entity affected.
        newState (boolean)
            True when ownable.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorOwnableToggled", "SyncOwnableState", function(_, door, state)
                net.Start("liaDoorOwnable") net.WriteEntity(door) net.WriteBool(state) net.Broadcast()
            end)
        ```
]]
function DoorOwnableToggled(client, door, newState)
end

--[[
    Purpose:
        Fired when a door purchase price is changed.

    When Called:
        After a player sets a new door price via management tools.

    Parameters:
        client (Player)
            Player setting the price.
        door (Entity)
            Door entity.
        price (number)
            New purchase price.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorPriceSet", "LogDoorPrice", function(client, door, price)
                lia.log.add(client, "doorPriceSet", price)
            end)
        ```
]]
function DoorPriceSet(client, door, price)
end

--[[
    Purpose:
        Fired when a door's title/name is changed.

    When Called:
        After a player renames a door via the interface or command.

    Parameters:
        client (Player)
            Player setting the title.
        door (Entity)
            Door entity.
        name (string)
            New door title.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("DoorTitleSet", "SaveDoorTitle", function(client, door, name)
                door:setNetVar("doorTitle", name)
            end)
        ```
]]
function DoorTitleSet(client, door, name)
end

--[[
    Purpose:
        Requests the server spawn list; gives modules a chance to override or inject spawns.

    When Called:
        When spawn points are being loaded or refreshed.

    Parameters:
        None.

    Returns:
        table
            Custom spawn data table or nil to use defaults.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("FetchSpawns", "UseCustomSpawns", function()
                return lia.spawns.getCustom()
            end)
        ```
]]
function FetchSpawns()
end

--[[
    Purpose:
        Returns a list of all active support tickets claimed by staff.

    When Called:
        When the ticket system needs to display open claims.

    Parameters:
        None.

    Returns:
        table
            Array of ticket claim data.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetAllCaseClaims", "MirrorTickets", function()
                return lia.ticket.getClaims()
            end)
        ```
]]
function GetAllCaseClaims()
end

--[[
    Purpose:
        Provides the model to use for spawning a bot player given a faction.

    When Called:
        During bot setup when choosing a model.

    Parameters:
        client (Player)
            Bot player entity.
        faction (table)
            Faction data assigned to the bot.

    Returns:
        string
            Model path to use for the bot.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetBotModel", "RandomCitizenModel", function(client, faction)
                if faction.uniqueID == "citizen" then return "models/Humans/Group01/male_07.mdl" end
            end)
        ```
]]
function GetBotModel(client, faction)
end

--[[
    Purpose:
        Lets modules adjust the final damage scale applied to a hitgroup.

    When Called:
        During ScalePlayerDamage after base scaling has been calculated.

    Parameters:
        hitgroup (number)
            Hitgroup constant from the damage trace.
        dmgInfo (CTakeDamageInfo)
            Damage info object.
        damageScale (number)
            Current scale value about to be applied.

    Returns:
        number
            New scale value to apply or nil to keep current.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetDamageScale", "HelmetProtection", function(hitgroup, dmgInfo, scale)
                if hitgroup == HITGROUP_HEAD and dmgInfo:IsBulletDamage() then return scale * 0.5 end
            end)
        ```
]]
function GetDamageScale(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Specifies which inventory type to create for a character by default.

    When Called:
        During character creation and bot setup before inventories are instanced.

    Parameters:
        character (Character)
            Character being initialized (may be nil for bots).

    Returns:
        string
            Inventory type ID (e.g., "GridInv").

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetDefaultInventoryType", "UseListInventory", function(character)
                return "ListInv"
            end)
        ```
]]
function GetDefaultInventoryType(character)
end

--[[
    Purpose:
        Provides custom data to persist for an entity.

    When Called:
        While serializing entities for persistence saves.

    Parameters:
        ent (Entity)
            Entity being saved.

    Returns:
        table
            Data table to store or nil for none.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetEntitySaveData", "SaveHealth", function(ent)
                return {health = ent:Health()}
            end)
        ```
]]
function GetEntitySaveData(ent)
end

--[[
    Purpose:
        Allows modules to set or modify the OOC chat cooldown for a speaker.

    When Called:
        Each time an OOC message is about to be sent.

    Parameters:
        speaker (Player)
            Player sending the OOC message.

    Returns:
        number
            Cooldown in seconds, or nil to use config default.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetOOCDelay", "VIPShorterCooldown", function(speaker)
                if speaker:isVIP() then return 5 end
            end)
        ```
]]
function GetOOCDelay(speaker)
end

--[[
    Purpose:
        Override or calculate a player's tracked playtime value.

    When Called:
        When playtime is requested for display or logic.

    Parameters:
        client (Player)
            Player whose playtime is queried.

    Returns:
        number
            Seconds of playtime.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPlayTime", "CustomPlaytime", function(client)
                return client:getChar():getData("customPlaytime", 0)
            end)
        ```
]]
function GetPlayTime(client)
end

--[[
    Purpose:
        Supplies the death sound file to play for a player.

    When Called:
        During PlayerDeath when death sounds are enabled.

    Parameters:
        client (Player)
            Player who died.
        isFemale (boolean)
            Gender flag.

    Returns:
        string
            Sound path to emit.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPlayerDeathSound", "FactionDeathSounds", function(client)
                if client:Team() == FACTION_CP then return "npc/metropolice/pain1.wav" end
            end)
        ```
]]
function GetPlayerDeathSound(client, isFemale)
end

--[[
    Purpose:
        Provides the pain sound to play for a hurt entity.

    When Called:
        During damage processing when selecting pain sounds.

    Parameters:
        paintype (string)
            Pain type identifier ("hurt", etc.).
        isFemale (boolean)
            Gender flag.
        client (Entity)
            Entity that is hurt.

    Returns:
        string
            Sound path to emit, or nil to use default.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPlayerPainSound", "RobotPain", function(client, paintype)
                if client:IsPlayer() and client:IsCombine() then return "npc/combine_soldier/pain1.wav" end
            end)
        ```
]]
function GetPlayerPainSound(client, paintype, isFemale)
end

--[[
    Purpose:
        Selects where a player should respawn after death.

    When Called:
        During respawn processing to determine the spawn location.

    Parameters:
        client (Player)
            Player respawning.
        character (Character)
            Character data of the player.

    Returns:
        vector, angle
            Position and angle for the respawn; nil to use default.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPlayerRespawnLocation", "HospitalRespawn", function(client)
                return lia.spawns.getHospitalPos(), lia.spawns.getHospitalAng()
            end)
        ```
]]
function GetPlayerRespawnLocation(client, character)
end

--[[
    Purpose:
        Chooses the spawn location for a player when initially joining the server.

    When Called:
        During first spawn/character load to position the player.

    Parameters:
        client (Player)
            Player spawning.
        character (Character)
            Character data of the player.

    Returns:
        vector, angle
            Position and angle; nil to use map spawns.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPlayerSpawnLocation", "FactionSpawns", function(client, character)
                return lia.spawns.getFactionSpawn(character:getFaction())
            end)
        ```
]]
function GetPlayerSpawnLocation(client, character)
end

--[[
    Purpose:
        Allows adjusting the salary amount using a prestige bonus.

    When Called:
        Each time salary is calculated for a character.

    Parameters:
        client (Player)
            Player receiving salary.
        char (Character)
            Character data.
        pay (number)
            Current salary amount.
        faction (table)
            Faction definition.
        class (table)
            Class definition (if any).

    Returns:
        number
            Modified pay amount or nil to keep.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetPrestigePayBonus", "PrestigeScaling", function(client, char, pay)
                return pay + (char:getData("prestigeLevel", 0) * 50)
            end)
        ```
]]
function GetPrestigePayBonus(client, char, pay, faction, class)
end

--[[
    Purpose:
        Provides the base salary amount for a player based on faction/class.

    When Called:
        Whenever salary is being computed for payout.

    Parameters:
        client (Player)
            Player receiving salary.
        faction (table)
            Faction definition.
        class (table)
            Class definition (may be nil).

    Returns:
        number
            Salary amount.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetSalaryAmount", "VIPSalary", function(client, faction, class)
                if client:isVIP() then return 500 end
            end)
        ```
]]
function GetSalaryAmount(client, faction, class)
end

--[[
    Purpose:
        Retrieves all ticket entries made by a specific requester SteamID.

    When Called:
        During ticket queries filtered by requester.

    Parameters:
        steamID (string)
            SteamID64 or SteamID of the requester.

    Returns:
        table
            List of ticket rows.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetTicketsByRequester", "MaskRequester", function(steamID)
                return lia.tickets.byRequester(steamID)
            end)
        ```
]]
function GetTicketsByRequester(steamID)
end

--[[
    Purpose:
        Fetches all warnings stored for a character ID.

    When Called:
        When viewing a character's warning history.

    Parameters:
        charID (number|string)
            Character database identifier.

    Returns:
        table
            Array of warning rows.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetWarnings", "MirrorWarnings", function(charID)
                return lia.warn.get(charID)
            end)
        ```
]]
function GetWarnings(charID)
end

--[[
    Purpose:
        Retrieves warnings issued by a specific SteamID.

    When Called:
        When filtering warnings by issuing admin.

    Parameters:
        steamID (string)
            SteamID of the issuer.

    Returns:
        table
            Array of warning rows.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("GetWarningsByIssuer", "ListIssuerWarnings", function(steamID)
                return lia.warn.getByIssuer(steamID)
            end)
        ```
]]
function GetWarningsByIssuer(steamID)
end

--[[
    Purpose:
        Handles the server-side logic when a client requests to move an item.

    When Called:
        When the inventory UI sends a transfer request.

    Parameters:
        client (Player)
            Player requesting the transfer.
        itemID (number|string)
            Item instance identifier.
        x (number)
            Target X slot.
        y (number)
            Target Y slot.
        invID (number|string)
            Destination inventory ID.

    Returns:
        nil
            Perform transfer handling inside the hook.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("HandleItemTransferRequest", "LogTransfers", function(client, itemID, x, y, invID)
                lia.log.add(client, "itemMove", itemID, invID, x, y)
            end)
        ```
]]
function HandleItemTransferRequest(client, itemID, x, y, invID)
end

--[[
    Purpose:
        Notifies that an inventory has been removed or destroyed.

    When Called:
        After an inventory instance is deleted.

    Parameters:
        instance (Inventory)
            Inventory object that was removed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("InventoryDeleted", "CleanupInvCache", function(instance)
                lia.inventory.cache[instance:getID()] = nil
            end)
        ```
]]
function InventoryDeleted(instance)
end

--[[
    Purpose:
        Fired when a player combines an item with another (stacking or crafting).

    When Called:
        After the combine action has been requested.

    Parameters:
        client (Player)
            Player performing the combine.
        item (Item)
            Primary item.
        target (Item)
            Target item being combined into.

    Returns:
        boolean
            False to block the combine; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ItemCombine", "BlockCertainCombines", function(client, item, target)
                if target.noCombine then return false end
            end)
        ```
]]
function ItemCombine(client, item, target)
end

--[[
    Purpose:
        Notifies that an item instance has been deleted from storage.

    When Called:
        Immediately after an item is removed from persistence.

    Parameters:
        instance (Item)
            Item instance that was deleted.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ItemDeleted", "LogItemDelete", function(instance)
                lia.log.add(nil, "itemDeleted", instance.uniqueID)
            end)
        ```
]]
function ItemDeleted(instance)
end

--[[
    Purpose:
        Called whenever an item method is executed so modules can react or modify results.

    When Called:
        After an item function such as OnUse or custom actions is invoked.

    Parameters:
        item (Item)
            Item instance whose method was called.
        method (string)
            Name of the method invoked.
        client (Player)
            Player who triggered the call.
        entity (Entity)
            Entity representation if applicable.
        results (table)
            Return values from the method.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ItemFunctionCalled", "AuditItemUse", function(item, method, client)
                lia.log.add(client, "itemFunction", item.uniqueID, method)
            end)
        ```
]]
function ItemFunctionCalled(item, method, client, entity, results)
end

--[[
    Purpose:
        Fires after an item has been successfully transferred between inventories.

    When Called:
        Right after a transfer completes.

    Parameters:
        context (table)
            Transfer context containing client, item, from, and to inventories.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ItemTransfered", "NotifyTransfer", function(context)
                lia.log.add(context.client, "itemTransferred", context.item.uniqueID)
            end)
        ```
]]
function ItemTransfered(context)
end

--[[
    Purpose:
        Allows overriding the key lock timing or behavior when using key items.

    When Called:
        When a player uses a key to lock a door for a set duration.

    Parameters:
        client (Player)
            Player locking.
        door (Entity)
            Door entity.
        time (number)
            Duration of the lock action.

    Returns:
        nil
            Return false to stop the lock sequence.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("KeyLock", "InstantLock", function(client, door)
                door:Fire("lock")
                return false
            end)
        ```
]]
function KeyLock(client, door, time)
end

--[[
    Purpose:
        Allows overriding key-based unlock timing or behavior.

    When Called:
        When a player uses a key to unlock a door for a duration.

    Parameters:
        client (Player)
            Player unlocking.
        door (Entity)
            Door entity.
        time (number)
            Duration for unlock action.

    Returns:
        nil
            Return false to stop the unlock sequence.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("KeyUnlock", "InstantUnlock", function(client, door)
                door:Fire("unlock")
                return false
            end)
        ```
]]
function KeyUnlock(client, door, time)
end

--[[
    Purpose:
        Fired when a character is kicked from the session and forced to select another.

    When Called:
        After the character kick is processed.

    Parameters:
        characterID (number)
            ID of the character kicked.
        isCurrentChar (boolean)
            True if it was the active character at time of kick.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("KickedFromChar", "LogCharKick", function(characterID, wasCurrent)
                lia.log.add(nil, "charKicked", characterID, wasCurrent)
            end)
        ```
]]
function KickedFromChar(characterID, isCurrentChar)
end

--[[
    Purpose:
        Indicates that all Lilia database tables have been created/loaded.

    When Called:
        After tables are created during startup.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("LiliaTablesLoaded", "SeedDefaults", function()
                lia.seed.run()
            end)
        ```
]]
function LiliaTablesLoaded()
end

--[[
    Purpose:
        Allows modules to inject data when the gamemode performs a data load.

    When Called:
        During server startup after initial load begins.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("LoadData", "LoadCustomData", function()
                lia.data.loadCustom()
            end)
        ```
]]
function LoadData()
end

--[[
    Purpose:
        Lets modules change the model chosen for a character before it is set.

    When Called:
        During character creation or model updates.

    Parameters:
        arg1 (any)
            Context value (varies by caller).
        character (Character)
            Character being modified.

    Returns:
        string
            Model path override or nil to keep current.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ModifyCharacterModel", "ForceFactionModel", function(_, character)
                if character:getFaction() == FACTION_STAFF then return "models/player/police_fem.mdl" end
            end)
        ```
]]
function ModifyCharacterModel(arg1, character)
end

--[[
    Purpose:
        Notifies when an attribute boost is applied to a character.

    When Called:
        After lia.attrib has boosted an attribute.

    Parameters:
        client (Player)
            Player whose character was boosted.
        character (Character)
            Character receiving the boost.
        attribID (string|number)
            Attribute identifier.
        boostID (string)
            Boost source identifier.
        arg5 (any)
            Additional data supplied by the boost.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharAttribBoosted", "LogBoost", function(client, character, attribID, boostID)
                lia.log.add(client, "attribBoosted", attribID, boostID)
            end)
        ```
]]
function OnCharAttribBoosted(client, character, attribID, boostID, arg5)
end

--[[
    Purpose:
        Notifies that a character attribute value has been updated.

    When Called:
        After attribute points are changed.

    Parameters:
        client (Player)
            Player whose character changed.
        character (Character)
            Character object.
        key (string|number)
            Attribute identifier.
        arg4 (any)
            Old value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharAttribUpdated", "SyncAttrib", function(client, character, key, oldValue)
                lia.log.add(client, "attribUpdated", key, oldValue, character:getAttrib(key))
            end)
        ```
]]
function OnCharAttribUpdated(client, character, key, arg4)
end

--[[
    Purpose:
        Signals that a new character has been created.

    When Called:
        Immediately after character creation succeeds.

    Parameters:
        client (Player)
            Player who created the character.
        character (Character)
            New character object.
        originalData (table)
            Raw creation data submitted.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharCreated", "WelcomeMessage", function(client, character)
                client:notifyLocalized("charCreated", character:getName())
            end)
        ```
]]
function OnCharCreated(client, character, originalData)
end

--[[
    Purpose:
        Invoked just before a character is deleted from persistence.

    When Called:
        Right before deletion is executed.

    Parameters:
        client (Player)
            Player requesting deletion.
        id (number)
            Character ID to delete.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharDelete", "BackupChar", function(client, id)
                lia.backup.character(id)
            end)
        ```
]]
function OnCharDelete(client, id)
end

--[[
    Purpose:
        Called when a player disconnects while owning a character.

    When Called:
        Immediately after the player leaves the server.

    Parameters:
        client (Player)
            Player who disconnected.
        character (Character)
            Character they had active.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharDisconnect", "SaveOnLeave", function(client, character)
                character:save()
            end)
        ```
]]
function OnCharDisconnect(client, character)
end

--[[
    Purpose:
        Notifies that flags have been granted to a character.

    When Called:
        After permanent or session flags are added.

    Parameters:
        ply (Player)
            Player whose character received flags.
        character (Character)
            Character instance.
        addedFlags (string)
            Flags added.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharFlagsGiven", "LogFlagGrant", function(ply, character, addedFlags)
                lia.log.add(ply, "flagsGiven", addedFlags)
            end)
        ```
]]
function OnCharFlagsGiven(ply, character, addedFlags)
end

--[[
    Purpose:
        Notifies that flags have been removed from a character.

    When Called:
        After flag removal occurs.

    Parameters:
        ply (Player)
            Player whose character lost flags.
        character (Character)
            Character affected.
        removedFlags (string)
            Flags removed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharFlagsTaken", "LogFlagRemoval", function(ply, character, removedFlags)
                lia.log.add(ply, "flagsTaken", removedFlags)
            end)
        ```
]]
function OnCharFlagsTaken(ply, character, removedFlags)
end

--[[
    Purpose:
        Runs when a character is kicked out of the game or forced to menu.

    When Called:
        After kicking logic completes.

    Parameters:
        character (Character)
            Character that was kicked.
        client (Player)
            Player owning the character (may be nil).

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharKick", "LogCharKick", function(character, client)
                lia.log.add(client, "charKicked", character:getName())
            end)
        ```
]]
function OnCharKick(character, client)
end

--[[
    Purpose:
        Fired when a character networked variable changes.

    When Called:
        Whenever character:setNetVar updates a value.

    Parameters:
        character (Character)
            Character whose var changed.
        key (string)
            Net var key.
        oldVar (any)
            Previous value.
        value (any)
            New value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharNetVarChanged", "TrackWantedState", function(character, key, old, value)
                if key == "wanted" then lia.log.add(nil, "wantedToggle", character:getName(), value) end
            end)
        ```
]]
function OnCharNetVarChanged(character, key, oldVar, value)
end

--[[
    Purpose:
        Reports that a character has been permanently killed.

    When Called:
        After perma-kill logic marks the character as dead.

    Parameters:
        character (Character)
            Character that was permakilled.
        time (number)
            Timestamp of the perma-kill.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharPermakilled", "AnnouncePerma", function(character)
                lia.chat.send(nil, "event", L("permakilled", character:getName()))
            end)
        ```
]]
function OnCharPermakilled(character, time)
end

--[[
    Purpose:
        Notifies when a recognition check is performed between characters.

    When Called:
        When determining if one character recognizes another.

    Parameters:
        client (Player)
            Player performing the recognition.
        arg2 (any)
            Target data (player or character).

    Returns:
        boolean
            True if recognized; nil/false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharRecognized", "AlwaysRecognizeTeam", function(client, target)
                if target:getFaction() == client:Team() then return true end
            end)
        ```
]]
function OnCharRecognized(client, arg2)
end

--[[
    Purpose:
        Fired after a player completes a vendor trade interaction.

    When Called:
        After buy/sell attempt is processed, including failures.

    Parameters:
        client (Player)
            Player trading.
        vendor (Entity)
            Vendor entity.
        item (Item)
            Item instance if available.
        isSellingToVendor (boolean)
            True if player sold to vendor.
        character (Character)
            Player character.
        itemType (string)
            Item uniqueID.
        isFailed (boolean)
            True if the trade failed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCharTradeVendor", "TrackVendorTrade", function(client, vendor, item, selling)
                lia.log.add(client, selling and "vendorSell" or "vendorBuy", item and item.uniqueID or "unknown")
            end)
        ```
]]
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
end

--[[
    Purpose:
        Triggered when a player is flagged as a cheater by detection logic.

    When Called:
        After anti-cheat routines identify suspicious behavior.

    Parameters:
        client (Player)
            Player detected.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnCheaterCaught", "AutoKickCheaters", function(client)
                client:Kick("Cheating detected")
            end)
        ```
]]
function OnCheaterCaught(client)
end

--[[
    Purpose:
        Fires when lia.data.set writes a value so other modules can react.

    When Called:
        Immediately after a data key is set.

    Parameters:
        key (string)
            Data key.
        value (any)
            Value written.
        gamemode (string)
            Gamemode identifier (namespace).
        map (string)
            Map name associated with the data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnDataSet", "MirrorToCache", function(key, value)
                lia.cache.set(key, value)
            end)
        ```
]]
function OnDataSet(key, value, gamemode, map)
end

--[[
    Purpose:
        Indicates that the database has finished loading queued data.

    When Called:
        After tables/data are loaded on startup.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnDatabaseLoaded", "StartSalaryTimers", function()
                hook.Run("CreateSalaryTimers")
            end)
        ```
]]
function OnDatabaseLoaded()
end

--[[
    Purpose:
        Notifies that a death sound has been played for a player.

    When Called:
        After emitting the death sound in PlayerDeath.

    Parameters:
        client (Player)
            Player who died.
        deathSound (string)
            Sound path played.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnDeathSoundPlayed", "BroadcastDeathSound", function(client, sound)
                lia.log.add(client, "deathSound", sound)
            end)
        ```
]]
function OnDeathSoundPlayed(client, deathSound)
end

--[[
    Purpose:
        Called when an entity is loaded from persistence with its saved data.

    When Called:
        After entity creation during map load and persistence restore.

    Parameters:
        ent (Entity)
            Entity loaded.
        data (table)
            Saved data applied.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnEntityLoaded", "RestoreHealth", function(ent, data)
                if data.health then ent:SetHealth(data.health) end
            end)
        ```
]]
function OnEntityLoaded(ent, data)
end

--[[
    Purpose:
        Notifies that persistent data for an entity has been updated.

    When Called:
        After persistence storage for an entity is rewritten.

    Parameters:
        ent (Entity)
            Entity whose data changed.
        data (table)
            New persistence data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnEntityPersistUpdated", "RefreshDataCache", function(ent, data)
                ent.cachedPersist = data
            end)
        ```
]]
function OnEntityPersistUpdated(ent, data)
end

--[[
    Purpose:
        Called when an entity is first persisted to storage.

    When Called:
        At the moment entity data is captured for saving.

    Parameters:
        ent (Entity)
            Entity being persisted.
        entData (table)
            Data collected for saving.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnEntityPersisted", "AddOwnerData", function(ent, data)
                if ent:GetNWString("owner") then data.owner = ent:GetNWString("owner") end
            end)
        ```
]]
function OnEntityPersisted(ent, entData)
end

--[[
    Purpose:
        Fired when an item entity spawns into the world.

    When Called:
        After an item entity is created (drop or spawn).

    Parameters:
        itemEntity (Entity)
            Item entity instance.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnItemSpawned", "ApplyItemGlow", function(itemEntity)
                itemEntity:SetRenderFX(kRenderFxGlowShell)
            end)
        ```
]]
function OnItemSpawned(itemEntity)
end

--[[
    Purpose:
        Signals that data tables for the gamemode have been loaded.

    When Called:
        After loading tables during startup.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnLoadTables", "InitVendors", function()
                lia.vendor.loadAll()
            end)
        ```
]]
function OnLoadTables()
end

--[[
    Purpose:
        Allows overriding the NPC type assignment for an NPC entity.

    When Called:
        When setting an NPC's type using management tools.

    Parameters:
        client (Player)
            Player setting the type.
        npc (Entity)
            NPC entity.
        npcID (string)
            Target NPC type ID.
        filteredData (table)
            Data prepared for the NPC.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnNPCTypeSet", "LogNPCType", function(client, npc, npcID)
                lia.log.add(client, "npcTypeSet", npcID)
            end)
        ```
]]
function OnNPCTypeSet(client, npc, npcID, filteredData)
end

--[[
    Purpose:
        Fired when an OOC chat message is sent to the server.

    When Called:
        After an OOC message passes cooldown checks.

    Parameters:
        client (Player)
            Speaker.
        message (string)
            Message text.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnOOCMessageSent", "RelayToDiscord", function(client, message)
                lia.discord.send("OOC", client:Name(), message)
            end)
        ```
]]
function OnOOCMessageSent(client, message)
end

--[[
    Purpose:
        Notifies that a pain sound has been played for an entity.

    When Called:
        After a pain sound is emitted.

    Parameters:
        entity (Entity)
            Entity that made the sound.
        painSound (string)
            Sound path.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPainSoundPlayed", "CountPainSounds", function(entity, sound)
                lia.metrics.bump("painSounds")
            end)
        ```
]]
function OnPainSoundPlayed(entity, painSound)
end

--[[
    Purpose:
        Fired when a player picks up a money entity from the world.

    When Called:
        After money is collected.

    Parameters:
        activator (Player)
            Player who picked up the money.
        moneyEntity (Entity)
            Money entity removed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPickupMoney", "LogMoneyPickup", function(ply, moneyEnt)
                lia.log.add(ply, "moneyPickup", moneyEnt:getAmount())
            end)
        ```
]]
function OnPickupMoney(activator, moneyEntity)
end

--[[
    Purpose:
        Called when a player starts an animated sequence (e.g., sit or custom act).

    When Called:
        When sequence playback is initiated through player sequences.

    Parameters:
        client (Player)
            Player entering the sequence.
        sequenceName (string)
            Sequence identifier.
        callback (function)
            Function to call when sequence ends.
        time (number)
            Duration of the sequence.
        noFreeze (boolean)
            Whether player movement is frozen.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerEnterSequence", "SequenceLog", function(client, sequenceName)
                lia.log.add(client, "sequenceStart", sequenceName)
            end)
        ```
]]
function OnPlayerEnterSequence(client, sequenceName, callback, time, noFreeze)
end

--[[
    Purpose:
        Runs after a player interacts with an item and receives a result.

    When Called:
        After item interaction logic completes.

    Parameters:
        client (Player)
            Player performing the action.
        action (string)
            Action identifier.
        item (Item)
            Item involved.
        result (boolean|string|table)
            Result of the action.
        data (table)
            Additional action data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerInteractItem", "NotifyUse", function(client, action, item, result)
                if result then client:notifyLocalized("itemAction", action, item:getName()) end
            end)
        ```
]]
function OnPlayerInteractItem(client, action, item, result, data)
end

--[[
    Purpose:
        Triggered when a player joins a class or team variant.

    When Called:
        After the class change is applied.

    Parameters:
        target (Player)
            Player who changed class.
        arg2 (any)
            New class data/index.
        oldClass (any)
            Previous class data/index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerJoinClass", "ClassLog", function(client, newClass, oldClass)
                lia.log.add(client, "classJoined", tostring(newClass))
            end)
        ```
]]
function OnPlayerJoinClass(target, arg2, oldClass)
end

--[[
    Purpose:
        Fired when a player exits an animated sequence.

    When Called:
        When the sequence finishes or is cancelled.

    Parameters:
        client (Player)
            Player leaving the sequence.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerLeaveSequence", "SequenceEndLog", function(client)
                lia.log.add(client, "sequenceEnd")
            end)
        ```
]]
function OnPlayerLeaveSequence(client)
end

--[[
    Purpose:
        Notifies when a player loses a stackable item (stack count reaches zero).

    When Called:
        After stack removal logic.

    Parameters:
        itemTypeOrItem (string|Item)
            Item uniqueID or item instance removed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerLostStackItem", "RevokeBuff", function(itemTypeOrItem)
                if itemTypeOrItem == "medkit" then lia.buff.remove("healing") end
            end)
        ```
]]
function OnPlayerLostStackItem(itemTypeOrItem)
end

--[[
    Purpose:
        Notifies when a player toggles observer mode (freecam/third person).

    When Called:
        When observation state changes via admin commands or mechanics.

    Parameters:
        client (Player)
            Player entering or exiting observe.
        state (boolean)
            True when entering observe mode.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerObserve", "HideHUD", function(client, state)
                client:setNetVar("hideHUD", state)
            end)
        ```
]]
function OnPlayerObserve(client, state)
end

--[[
    Purpose:
        Fired when a player is ragdolled (knocked out, physics ragdoll).

    When Called:
        Immediately after the ragdoll is created.

    Parameters:
        client (Player)
            Player ragdolled.
        ragdoll (Entity)
            Ragdoll entity created.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerRagdolled", "TrackRagdoll", function(client, ragdoll)
                ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
            end)
        ```
]]
function OnPlayerRagdolled(client, ragdoll)
end

--[[
    Purpose:
        Notifies that a player switched to a different class.

    When Called:
        After the class transition is applied.

    Parameters:
        client (Player)
            Player switching class.
        class (table|number)
            New class identifier or data.
        oldClass (table|number)
            Previous class identifier or data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnPlayerSwitchClass", "RefreshLoadout", function(client, class, oldClass)
                lia.loadout.give(client)
            end)
        ```
]]
function OnPlayerSwitchClass(client, class, oldClass)
end

--[[
    Purpose:
        Allows modules to override item transfer requests before processing.

    When Called:
        When an inventory panel asks to move an item to another inventory.

    Parameters:
        inventoryPanel (Panel)
            UI panel requesting transfer.
        itemID (number|string)
            Item instance ID.
        targetInventoryID (number|string)
            Destination inventory.
        x (number)
            X slot.
        y (number)
            Y slot.

    Returns:
        nil
            Return false to block.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnRequestItemTransfer", "BlockDuringTrade", function(_, _, targetInv)
                if lia.trade.isActive(targetInv) then return false end
            end)
        ```
]]
function OnRequestItemTransfer(inventoryPanel, itemID, targetInventoryID, x, y)
end

--[[
    Purpose:
        Allows adjusting salary amount just before payment.

    When Called:
        During salary payout calculation.

    Parameters:
        client (Player)
            Player receiving pay.

    Returns:
        number
            Modified salary value.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnSalaryAdjust", "TaxSalary", function(client)
                return client:isTaxed() and -50 or 0
            end)
        ```
]]
function OnSalaryAdjust(client)
end

--[[
    Purpose:
        Fired when salary is granted to a player.

    When Called:
        After salary is deposited into the character.

    Parameters:
        client (Player)
            Player receiving salary.
        char (Character)
            Character object.
        pay (number)
            Amount paid.
        faction (table)
            Faction data.
        class (table)
            Class data (if any).

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnSalaryGiven", "LogSalary", function(client, char, pay)
                lia.log.add(client, "salaryGiven", pay)
            end)
        ```
]]
function OnSalaryGiven(client, char, pay, faction, class)
end

--[[
    Purpose:
        Called when a player's usergroup is changed.

    When Called:
        After a player's usergroup has been successfully changed.

    Parameters:
        sid (string)
            Steam ID of the player whose usergroup changed.
        new (string)
            New usergroup name.
        source (string)
            Source of the change (e.g., "Lilia").
        ply (Player)
            Player entity whose usergroup changed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnSetUsergroup", "LogUsergroupChange", function(sid, new, source, ply)
                print(string.format("Usergroup changed for %s to %s by %s", sid, new, source))
            end)
        ```
]]
function OnSetUsergroup(sid, new, source, ply)
end

--[[
    Purpose:
        Notifies that saved item instances have been loaded from storage.

    When Called:
        After loading saved items on startup.

    Parameters:
        loadedItems (table)
            Table of item instances.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnSavedItemLoaded", "IndexCustomData", function(loadedItems)
                lia.items.buildCache(loadedItems)
            end)
        ```
]]
function OnSavedItemLoaded(loadedItems)
end

--[[
    Purpose:
        Central logging hook for server log entries.

    When Called:
        Whenever lia.log.add writes to the server log.

    Parameters:
        client (Player)
            Player associated with the log (may be nil).
        logType (string)
            Log type identifier.
        logString (string)
            Formatted log message.
        category (string)
            Log category.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnServerLog", "ForwardToDiscord", function(client, logType, text, category)
                lia.discord.send(category, logType, text)
            end)
        ```
]]
function OnServerLog(client, logType, logString, category)
end

--[[
    Purpose:
        Fired when a staff member claims a support ticket.

    When Called:
        After claim assignment succeeds.

    Parameters:
        client (Player)
            Staff claiming the ticket.
        requester (string)
            SteamID of the requester.
        ticketMessage (string)
            Ticket text.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnTicketClaimed", "AnnounceClaim", function(client, requester)
                client:notifyLocalized("ticketClaimed", requester)
            end)
        ```
]]
function OnTicketClaimed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Fired when a support ticket is closed.

    When Called:
        After the ticket is marked closed and responders notified.

    Parameters:
        client (Player)
            Staff closing the ticket.
        requester (string)
            SteamID of the requester.
        ticketMessage (string)
            Original ticket text.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnTicketClosed", "LogTicketClose", function(client, requester)
                lia.log.add(client, "ticketClosed", requester)
            end)
        ```
]]
function OnTicketClosed(client, requester, ticketMessage)
end

--[[
    Purpose:
        Fired when a support ticket is created.

    When Called:
        Right after a player submits a ticket.

    Parameters:
        noob (Player)
            Player submitting the ticket.
        message (string)
            Ticket text.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnTicketCreated", "NotifyStaff", function(noob, message)
                lia.staff.notifyAll(noob:Nick() .. ": " .. message)
            end)
        ```
]]
function OnTicketCreated(noob, message)
end

--[[
    Purpose:
        Notifies that usergroup permissions have changed.

    When Called:
        After a usergroup permission update occurs.

    Parameters:
        groupName (string)
            Usergroup name.
        arg2 (table)
            New permission data.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnUsergroupPermissionsChanged", "RefreshCachedPerms", function(groupName)
                lia.permissions.refresh(groupName)
            end)
        ```
]]
function OnUsergroupPermissionsChanged(groupName, arg2)
end

--[[
    Purpose:
        Fired when a vendor entity is edited via the vendor interface.

    When Called:
        After vendor key/value is changed.

    Parameters:
        client (Player)
            Player editing.
        vendor (Entity)
            Vendor entity.
        key (string)
            Property key edited.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnVendorEdited", "SyncVendorEdits", function(client, vendor, key)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function OnVendorEdited(client, vendor, key)
end

--[[
    Purpose:
        Signals that a player's voice chat style has changed (whisper/talk/yell).

    When Called:
        After a player updates their voice type.

    Parameters:
        client (Player)
            Player whose voice type changed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OnVoiceTypeChanged", "UpdateVoiceRadius", function(client)
                lia.voice.updateHearTables()
            end)
        ```
]]
function OnVoiceTypeChanged(client)
end

--[[
    Purpose:
        Called when a networked option value is received or changed.

    When Called:
        When lia.option.set broadcasts an option that should network.

    Parameters:
        arg1 (Player|nil)
            Player who triggered the change (nil when server initiated).
        key (string)
            Option key.
        value (any)
            New value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("OptionReceived", "ApplyOption", function(_, key, value)
                if key == "TalkRange" then lia.config.set("TalkRange", value) end
            end)
        ```
]]
function OptionReceived(arg1, key, value)
end

--[[
    Purpose:
        Checks if a player is permitted to access vendor management.

    When Called:
        When a player attempts to open vendor edit controls.

    Parameters:
        client (Player)
            Player requesting access.
        vendor (Entity)
            Vendor entity.

    Returns:
        boolean
            False to block, true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerAccessVendor", "AdminOnlyVendorEdit", function(client)
                if not client:IsAdmin() then return false end
            end)
        ```
]]
function PlayerAccessVendor(client, vendor)
end

--[[
    Purpose:
        Triggered when cheat detection flags a player.

    When Called:
        After the cheat system confirms suspicious behavior.

    Parameters:
        client (Player)
            Player detected.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerCheatDetected", "AutoBan", function(client)
                lia.bans.add(client:SteamID(), "Cheat detected", 0)
            end)
        ```
]]
function PlayerCheatDetected(client)
end

--[[
    Purpose:
        Fired when a player is gagged (voice chat disabled).

    When Called:
        After gag state toggles to true.

    Parameters:
        target (Player)
            Player gagged.
        admin (Player)
            Admin who issued the gag.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerGagged", "LogGag", function(target, admin)
                lia.log.add(admin, "playerGagged", target:Name())
            end)
        ```
]]
function PlayerGagged(target, admin)
end

--[[
    Purpose:
        Notifies that Lilia player data has finished loading for a client.

    When Called:
        After lia data, items, doors, and panels are synced to the client.

    Parameters:
        client (Player)
            Player whose data is loaded.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerLiliaDataLoaded", "SendWelcome", function(client)
                client:notifyLocalized("welcomeBack")
            end)
        ```
]]
function PlayerLiliaDataLoaded(client)
end

--[[
    Purpose:
        Fired after a player's character has been fully loaded.

    When Called:
        Once character variables are applied and the player is spawned.

    Parameters:
        client (Player)
            Player whose character loaded.
        character (Character)
            Active character.
        currentChar (number)
            Character ID index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerLoadedChar", "ApplyLoadout", function(client, character)
                lia.loadout.give(client)
            end)
        ```
]]
function PlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Allows modifying chat text before it is sent to listeners.

    When Called:
        During chat send for all chat types.

    Parameters:
        speaker (Player)
            Player speaking.
        chatType (string)
            Chat class identifier.
        text (string)
            Raw message text.
        anonymous (boolean)
            Whether the message is anonymous.
        receivers (table)
            List of recipients (optional).

    Returns:
        string
            Replacement message text, or nil to keep.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerMessageSend", "CensorCurseWords", function(_, _, text)
                return text:gsub("badword", "****")
            end)
        ```
]]
function PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
end

--[[
    Purpose:
        Triggered when a player's model changes.

    When Called:
        After a new model is set on the player.

    Parameters:
        client (Player)
            Player whose model changed.
        value (string)
            New model path.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerModelChanged", "ReapplyBodygroups", function(client)
                lia.models.applyBodygroups(client)
            end)
        ```
]]
function PlayerModelChanged(client, value)
end

--[[
    Purpose:
        Fired when a player is muted (text chat disabled).

    When Called:
        After muting is applied.

    Parameters:
        target (Player)
            Player muted.
        admin (Player)
            Admin who muted.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerMuted", "LogMute", function(target, admin)
                lia.log.add(admin, "playerMuted", target:Name())
            end)
        ```
]]
function PlayerMuted(target, admin)
end

--[[
    Purpose:
        Determines if a death should result in a permanent character kill.

    When Called:
        During PlayerDeath when checking perma-kill conditions.

    Parameters:
        client (Player)
            Player who died.
        inflictor (Entity)
            Entity inflicting damage.
        attacker (Entity)
            Attacker entity.

    Returns:
        boolean
            True to perma-kill, false/nil to avoid.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerShouldPermaKill", "HardcoreMode", function(client)
                return lia.config.get("HardcoreMode", false)
            end)
        ```
]]
function PlayerShouldPermaKill(client, inflictor, attacker)
end

--[[
    Purpose:
        Allows overriding the spawn point chosen for a player.

    When Called:
        When selecting a specific spawn point entity/position.

    Parameters:
        client (Player)
            Player spawning.
        pos (Vector)
            Proposed position.
        ang (Angle)
            Proposed angle.

    Returns:
        vector, angle
            Replacement spawn location or nil to keep.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerSpawnPointSelected", "SpawnInZone", function(client)
                return lia.spawns.pickSafe(), Angle(0, 0, 0)
            end)
        ```
]]
function PlayerSpawnPointSelected(client, pos, ang)
end

--[[
    Purpose:
        Notifies that stamina has been gained by a player.

    When Called:
        After stamina increase is applied.

    Parameters:
        client (Player)
            Player gaining stamina.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerStaminaGained", "RewardRecovery", function(client)
                client:notifyLocalized("staminaRestored")
            end)
        ```
]]
function PlayerStaminaGained(client)
end

--[[
    Purpose:
        Notifies that stamina has been reduced for a player.

    When Called:
        After stamina drain is applied.

    Parameters:
        client (Player)
            Player losing stamina.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerStaminaLost", "WarnLowStamina", function(client)
                if client:getLocalVar("stm", 100) < 10 then client:notifyLocalized("lowStamina") end
            end)
        ```
]]
function PlayerStaminaLost(client)
end

--[[
    Purpose:
        Fired when a gag on a player is removed.

    When Called:
        After gag state switches to false.

    Parameters:
        target (Player)
            Player ungagged.
        admin (Player)
            Admin lifting the gag.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerUngagged", "LogUngag", function(target, admin)
                lia.log.add(admin, "playerUngagged", target:Name())
            end)
        ```
]]
function PlayerUngagged(target, admin)
end

--[[
    Purpose:
        Fired when a mute on a player is removed.

    When Called:
        After muting state switches to false.

    Parameters:
        target (Player)
            Player unmuted.
        admin (Player)
            Admin lifting the mute.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerUnmuted", "LogUnmute", function(target, admin)
                lia.log.add(admin, "playerUnmuted", target:Name())
            end)
        ```
]]
function PlayerUnmuted(target, admin)
end

--[[
    Purpose:
        Final permission check before a player uses a door entity.

    When Called:
        When a use input is received on a door.

    Parameters:
        client (Player)
            Player using the door.
        door (Entity)
            Door entity.

    Returns:
        boolean
            False to block use; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerUseDoor", "RaidLockdown", function(client)
                if lia.state.isRaid() then return false end
            end)
        ```
]]
function PlayerUseDoor(client, door)
end

--[[
    Purpose:
        Runs after door data has been loaded from persistence.

    When Called:
        After door ownership/vars are applied on map load.

    Parameters:
        ent (Entity)
            Door entity.
        doorData (table)
            Data restored for the door.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostDoorDataLoad", "ApplyDoorSkin", function(ent, data)
                if data.skin then ent:SetSkin(data.skin) end
            end)
        ```
]]
function PostDoorDataLoad(ent, doorData)
end

--[[
    Purpose:
        Called after all gamemode data loading is complete.

    When Called:
        At the end of server initialization once stored data is in memory.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostLoadData", "WarmCache", function()
                lia.cache.preload()
            end)
        ```
]]
function PostLoadData()
end

--[[
    Purpose:
        Runs after the player's initial spawn setup finishes.

    When Called:
        Right after PlayerInitialSpawn processing completes.

    Parameters:
        client (Player)
            Newly spawned player.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostPlayerInitialSpawn", "SendMOTD", function(client)
                lia.motd.send(client)
            end)
        ```
]]
function PostPlayerInitialSpawn(client)
end

--[[
    Purpose:
        Runs after a player's character and inventories have been loaded.

    When Called:
        Immediately after PlayerLoadedChar finishes syncing.

    Parameters:
        client (Player)
            Player.
        character (Character)
            Loaded character.
        currentChar (number)
            Character index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostPlayerLoadedChar", "GiveStarterItems", function(client, character)
                lia.items.giveStarter(character)
            end)
        ```
]]
function PostPlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Fired after PlayerLoadout has finished giving items and weapons.

    When Called:
        After the default loadout logic completes.

    Parameters:
        client (Player)
            Player who spawned.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostPlayerLoadout", "AddExtraGear", function(client)
                client:Give("weapon_crowbar")
            end)
        ```
]]
function PostPlayerLoadout(client)
end

--[[
    Purpose:
        Allows modules to modify chat behavior after PlayerSay builds recipients.

    When Called:
        After chat data is prepared but before sending to clients.

    Parameters:
        client (Player)
            Speaker.
        message (string)
            Message text.
        chatType (string)
            Chat class.
        anonymous (boolean)
            Whether the message is anonymous.

    Returns:
        string, boolean
            Optionally return modified text and anonymity.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostPlayerSay", "AddOOCPrefix", function(client, message, chatType, anonymous)
                if chatType == "ooc" then return "[OOC] " .. message, anonymous end
            end)
        ```
]]
function PostPlayerSay(client, message, chatType, anonymous)
end

--[[
    Purpose:
        Fired after damage scaling is applied to a hitgroup.

    When Called:
        At the end of ScalePlayerDamage.

    Parameters:
        hitgroup (number)
            Hitgroup hit.
        dmgInfo (CTakeDamageInfo)
            Damage info object.
        damageScale (number)
            Scale that was applied.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PostScaleDamage", "TrackDamage", function(hitgroup, dmgInfo, scale)
                lia.metrics.bump("damage", dmgInfo:GetDamage() * scale)
            end)
        ```
]]
function PostScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Pre-deletion hook for characters to run cleanup logic.

    When Called:
        Just before a character is removed from the database.

    Parameters:
        id (number)
            Character ID to delete.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PreCharDelete", "ArchiveChar", function(id)
                lia.backup.character(id)
            end)
        ```
]]
function PreCharDelete(id)
end

--[[
    Purpose:
        Allows adding extra data before door data is saved to persistence.

    When Called:
        During door save routines.

    Parameters:
        door (Entity)
            Door entity.
        doorData (table)
            Data about to be saved.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PreDoorDataSave", "SaveDoorSkin", function(door, data)
                data.skin = door:GetSkin()
            end)
        ```
]]
function PreDoorDataSave(door, doorData)
end

--[[
    Purpose:
        Lets modules validate an item interaction before it runs.

    When Called:
        Prior to executing an item action.

    Parameters:
        client (Player)
            Player performing the action.
        action (string)
            Action identifier.
        item (Item)
            Item being interacted with.

    Returns:
        boolean
            False to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PrePlayerInteractItem", "BlockWhileBusy", function(client)
                if client:isBusy() then return false end
            end)
        ```
]]
function PrePlayerInteractItem(client, action, item)
end

--[[
    Purpose:
        Runs before character data is fully loaded into a player.

    When Called:
        Prior to PlayerLoadedChar logic.

    Parameters:
        client (Player)
            Player about to load a character.
        character (Character)
            Character object.
        currentChar (number)
            Character index.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PrePlayerLoadedChar", "ResetRagdoll", function(client)
                client:removeRagdoll()
            end)
        ```
]]
function PrePlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        Allows modification of salary payout before it is given.

    When Called:
        During salary calculation loop, before pay is issued.

    Parameters:
        client (Player)
            Player due for salary.
        char (Character)
            Character.
        pay (number)
            Current calculated pay.
        faction (table)
            Faction data.
        class (table)
            Class data.

    Returns:
        number
            Adjusted pay or nil to keep.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PreSalaryGive", "ApplyTax", function(client, char, pay)
                return pay * 0.9
            end)
        ```
]]
function PreSalaryGive(client, char, pay, faction, class)
end

--[[
    Purpose:
        Called before damage scaling is calculated.

    When Called:
        At the start of ScalePlayerDamage.

    Parameters:
        hitgroup (number)
            Hitgroup hit.
        dmgInfo (CTakeDamageInfo)
            Damage info object.
        damageScale (number)
            Starting scale value.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PreScaleDamage", "ArmorPiercing", function(hitgroup, dmgInfo, scale)
                if dmgInfo:IsExplosionDamage() then dmgInfo:ScaleDamage(scale * 1.2) end
            end)
        ```
]]
function PreScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        Removes a warning entry for a character and informs listeners.

    When Called:
        When an admin deletes a warning record.

    Parameters:
        charID (number|string)
            Character database ID.
        index (number)
            Position of the warning in the list to remove.

    Returns:
        deferred|table
            Deferred resolving to removed warning row or nil.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("RemoveWarning", "MirrorWarningRemoval", function(charID, index)
                print("Warning removed", charID, index)
            end)
        ```
]]
function RemoveWarning(charID, index)
end

--[[
    Purpose:
        Performs a full save of gamemode persistence (entities, data, etc.).

    When Called:
        When persistence save is triggered manually or automatically.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SaveData", "ExtraSave", function()
                lia.custom.saveAll()
            end)
        ```
]]
function SaveData()
end

--[[
    Purpose:
        Displays a popup notification to a player with custom text.

    When Called:
        Whenever the server wants to send a popup dialog.

    Parameters:
        noob (Player)
            Player receiving the popup.
        message (string)
            Text to show.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SendPopup", "PopupExample", function(client, message)
                client:notifyLocalized(message)
            end)
        ```
]]
function SendPopup(noob, message)
end

--[[
    Purpose:
        Builds and spawns a bot player with default character data.

    When Called:
        When the server requests creation of a bot player.

    Parameters:
        client (Player)
            Bot player entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SetupBotPlayer", "BotWelcome", function(client)
                print("Bot setup complete", client)
            end)
        ```
]]
function SetupBotPlayer(client)
end

--[[
    Purpose:
        Sets up database tables, indexes, and initial schema.

    When Called:
        During gamemode initialization after database connection is established.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SetupDatabase", "InitCustomTables", function()
                lia.db.query("CREATE TABLE IF NOT EXISTS custom(id INT)")
            end)
        ```
]]
function SetupDatabase()
end

--[[
    Purpose:
        Configure a player model entity after it has been created.

    When Called:
        When spawning a playable model entity for preview or vendors.

    Parameters:
        modelEntity (Entity)
            The spawned model entity.
        character (Character)
            Character data used for appearance.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SetupPlayerModel", "ApplyCharSkin", function(modelEntity, character)
                modelEntity:SetSkin(character:getSkin() or 0)
            end)
        ```
]]
function SetupPlayerModel(modelEntity, character)
end

--[[
    Purpose:
        Determines if persistence data should be saved at this time.

    When Called:
        Before performing a save cycle.

    Parameters:
        None.

    Returns:
        boolean
            False to skip saving; true/nil to proceed.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldDataBeSaved", "OnlyDuringGrace", function()
                return not lia.state.isCombatPhase()
            end)
        ```
]]
function ShouldDataBeSaved()
end

--[[
    Purpose:
        Determines if the default salary timer creation should be overridden.

    When Called:
        Before creating salary timers to allow custom salary systems.

    Parameters:
        nil

    Returns:
        boolean
            True to prevent default salary timer creation; false/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldOverrideSalaryTimers", "CustomSalarySystem", function()
                return true -- Prevent default timers, handle salary elsewhere
            end)
        ```
]]
function ShouldOverrideSalaryTimers()
end

--[[
    Purpose:
        Decides whether saved item data should be deleted on map cleanup.

    When Called:
        Before removing saved items.

    Parameters:
        None.

    Returns:
        boolean
            False to keep saved items; true/nil to delete.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldDeleteSavedItems", "KeepForTesting", function()
                return false
            end)
        ```
]]
function ShouldDeleteSavedItems()
end

--[[
    Purpose:
        Decide if a death sound should play for a player.

    When Called:
        Right before emitting the death sound.

    Parameters:
        client (Player)
            Player who died.
        deathSound (string)
            Sound that would be played.

    Returns:
        boolean
            False to suppress; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldPlayDeathSound", "MuteStaff", function(client)
                if client:Team() == FACTION_STAFF then return false end
            end)
        ```
]]
function ShouldPlayDeathSound(client, deathSound)
end

--[[
    Purpose:
        Decide if a pain sound should play for an entity.

    When Called:
        When choosing whether to emit pain audio.

    Parameters:
        entity (Entity)
            Entity that would play the sound.
        painSound (string)
            Sound path.

    Returns:
        boolean
            False to suppress; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldPlayPainSound", "MuteRobots", function(entity)
                if entity:IsPlayer() and entity:IsCombine() then return false end
            end)
        ```
]]
function ShouldPlayPainSound(entity, painSound)
end

--[[
    Purpose:
        Controls whether a client ragdoll should be spawned on death.

    When Called:
        During PlayerDeath ragdoll handling.

    Parameters:
        client (Player)
            Player who died.

    Returns:
        boolean
            False to prevent ragdoll; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ShouldSpawnClientRagdoll", "NoRagdollInVehicles", function(client)
                return not client:InVehicle()
            end)
        ```
]]
function ShouldSpawnClientRagdoll(client)
end

--[[
    Purpose:
        Validates whether an item can be transferred to/from storage inventories.

    When Called:
        When an item move involving storage is requested.

    Parameters:
        client (Player)
            Player performing the move.
        storage (Entity|table)
            Storage entity or inventory table.
        item (Item)
            Item being moved.

    Returns:
        boolean
            False to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StorageCanTransferItem", "LimitWeapons", function(client, storage, item)
                if item.isWeapon then return false end
            end)
        ```
]]
function StorageCanTransferItem(client, storage, item)
end

--[[
    Purpose:
        Fired when a storage entity is removed from the world.

    When Called:
        On removal/deletion of the storage entity.

    Parameters:
        storageEntity (Entity)
            Storage entity removed.
        inventory (Inventory)
            Inventory associated.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StorageEntityRemoved", "SaveStorage", function(storageEntity, inventory)
                lia.storage.saveInventory(inventory)
            end)
        ```
]]
function StorageEntityRemoved(storageEntity, inventory)
end

--[[
    Purpose:
        Fired when a storage inventory is assigned to an entity.

    When Called:
        After inventory is set on a storage entity.

    Parameters:
        entity (Entity)
            Entity receiving the inventory.
        inventory (Inventory)
            Inventory assigned.
        isCar (boolean)
            True if the storage is a vehicle trunk.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StorageInventorySet", "TrackStorage", function(ent, inv)
                lia.log.add(nil, "storageSet", inv:getID())
            end)
        ```
]]
function StorageInventorySet(entity, inventory, isCar)
end

--[[
    Purpose:
        Notifies that an item was removed from a storage inventory.

    When Called:
        After removal occurs.

    Parameters:
        None explicitly (context provided via global variables).

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StorageItemRemoved", "RecountStorage", function()
                lia.storage.updateCapacity()
            end)
        ```
]]
function StorageItemRemoved()
end

--[[
    Purpose:
        Fired when a storage inventory is restored from disk.

    When Called:
        During storage load routines.

    Parameters:
        ent (Entity)
            Storage entity.
        inventory (Inventory)
            Inventory object restored.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StorageRestored", "SyncRestoredStorage", function(ent, inventory)
                inventory:sync(ent)
            end)
        ```
]]
function StorageRestored(ent, inventory)
end

--[[
    Purpose:
        Persists the current spawn positions to storage.

    When Called:
        When spawns are being saved.

    Parameters:
        spawns (table)
            Spawn data to store.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("StoreSpawns", "CustomSpawnStore", function(spawns)
                file.Write("lilia/spawns.json", util.TableToJSON(spawns))
            end)
        ```
]]
function StoreSpawns(spawns)
end

--[[
    Purpose:
        Syncs the character list data to a specific client.

    When Called:
        When a player requests an updated character list.

    Parameters:
        client (Player)
            Player receiving the list.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("SyncCharList", "AddExtraFields", function(client)
                lia.char.sync(client)
            end)
        ```
]]
function SyncCharList(client)
end

--[[
    Purpose:
        Allows custom validation when a player attempts to claim a support ticket.

    When Called:
        When a claim request is made for a ticket.

    Parameters:
        client (Player)
            Player claiming the ticket.
        requester (Player|string)
            Ticket requester or their SteamID.
        ticketMessage (string)
            Ticket description.

    Returns:
        boolean
            False to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("TicketSystemClaim", "AllowStaffOnlyClaims", function(client)
                if not client:isStaffOnDuty() then return false end
            end)
        ```
]]
function TicketSystemClaim(client, requester, ticketMessage)
end

--[[
    Purpose:
        Allows custom validation when a player attempts to close a support ticket.

    When Called:
        When a close request is made for a ticket.

    Parameters:
        client (Player)
            Player closing the ticket.
        requester (Player|string)
            Ticket requester or SteamID.
        ticketMessage (string)
            Ticket description.

    Returns:
        boolean
            False to block; true/nil to allow.

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("TicketSystemClose", "OnlyOwnerOrStaff", function(client, requester)
                if client ~= requester and not client:isStaffOnDuty() then return false end
            end)
        ```
]]
function TicketSystemClose(client, requester, ticketMessage)
end

--[[
    Purpose:
        Signals that a door lock state was toggled.

    When Called:
        After a lock/unlock action completes.

    Parameters:
        client (Player)
            Player toggling.
        door (Entity)
            Door entity.
        state (boolean)
            True if locked after toggle.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("ToggleLock", "LogToggleLock", function(client, door, state)
                lia.log.add(client, "toggleLock", tostring(state))
            end)
        ```
]]
function ToggleLock(client, door, state)
end

--[[
    Purpose:
        Writes updated persistence data for an entity (commonly vendors).

    When Called:
        After data changes that must be persisted.

    Parameters:
        vendor (Entity)
            Entity whose persistence should be updated.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("UpdateEntityPersistence", "SaveVendorChanges", function(vendor)
                lia.entity.save(vendor)
            end)
        ```
]]
function UpdateEntityPersistence(vendor)
end

--[[
    Purpose:
        Fired when a vendor's class allow list changes.

    When Called:
        After toggling a class for vendor access.

    Parameters:
        vendor (Entity)
            Vendor entity.
        id (number|string)
            Class identifier.
        allowed (boolean)
            Whether the class is allowed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorClassUpdated", "SyncVendorClassUpdate", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorClassUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        General notification that a vendor property was edited.

    When Called:
        Whenever vendor data is modified through the editor.

    Parameters:
        liaVendorEnt (Entity)
            Vendor entity.
        key (string)
            Property key changed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorEdited", "ResyncOnEdit", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorEdited(liaVendorEnt, key)
end

--[[
    Purpose:
        Notifies that a vendor's faction-specific buy multiplier was updated.

    When Called:
        After setting faction buy scale.

    Parameters:
        vendor (Entity)
            Vendor entity.
        factionID (number|string)
            Faction identifier.
        scale (number)
            New buy scale.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorFactionBuyScaleUpdated", "SyncFactionBuyScale", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorFactionBuyScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        Notifies that a vendor's faction-specific sell multiplier was updated.

    When Called:
        After setting faction sell scale.

    Parameters:
        vendor (Entity)
            Vendor entity.
        factionID (number|string)
            Faction identifier.
        scale (number)
            New sell scale.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorFactionSellScaleUpdated", "SyncFactionSellScale", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorFactionSellScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        Fired when a vendor's faction allow/deny list is changed.

    When Called:
        After toggling faction access.

    Parameters:
        vendor (Entity)
            Vendor entity.
        id (number|string)
            Faction identifier.
        allowed (boolean)
            Whether the faction is allowed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorFactionUpdated", "SyncFactionAccess", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorFactionUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        Fired when the maximum stock for a vendor item is updated.

    When Called:
        After editing item stock limits.

    Parameters:
        vendor (Entity)
            Vendor entity.
        itemType (string)
            Item uniqueID.
        value (number)
            New max stock.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorItemMaxStockUpdated", "SyncMaxStockChange", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Fired when a vendor item's trade mode changes (buy/sell/both).

    When Called:
        After updating item mode.

    Parameters:
        vendor (Entity)
            Vendor entity.
        itemType (string)
            Item uniqueID.
        value (number)
            Mode constant.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorItemModeUpdated", "SyncItemModeChange", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorItemModeUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Fired when a vendor item's price is changed.

    When Called:
        After setting a new price for an item.

    Parameters:
        vendor (Entity)
            Vendor entity.
        itemType (string)
            Item uniqueID.
        value (number)
            New price.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorItemPriceUpdated", "SyncPriceChange", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorItemPriceUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Fired when a vendor item's current stock value changes.

    When Called:
        After stock is set manually.

    Parameters:
        vendor (Entity)
            Vendor entity.
        itemType (string)
            Item uniqueID.
        value (number)
            New stock.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorItemStockUpdated", "SyncStockChange", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorItemStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        Fired when vendor dialogue/messages are updated.

    When Called:
        After editing vendor message strings.

    Parameters:
        vendor (Entity)
            Vendor entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorMessagesUpdated", "SyncVendorMsgs", function(vendor)
                lia.vendor.sync(vendor)
            end)
        ```
]]
function VendorMessagesUpdated(vendor)
end

--[[
    Purpose:
        Notifies that vendor data has been synchronized to clients.

    When Called:
        After vendor network sync completes.

    Parameters:
        vendor (Entity)
            Vendor entity.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorSynchronized", "AfterVendorSync", function(vendor)
                print("Vendor synced", vendor)
            end)
        ```
]]
function VendorSynchronized(vendor)
end

--[[
    Purpose:
        Generic hook for vendor trade events (buying or selling).

    When Called:
        After a vendor transaction completes.

    Parameters:
        client (Player)
            Player trading.
        vendor (Entity)
            Vendor entity.
        itemType (string)
            Item uniqueID.
        isSellingToVendor (boolean)
            True if player sold to vendor.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("VendorTradeEvent", "TrackTrade", function(client, vendor, itemType, selling)
                lia.log.add(client, selling and "vendorSell" or "vendorBuy", itemType)
            end)
        ```
]]
function VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        Fired when a warning is issued to a player.

    When Called:
        Immediately after creating a warning record.

    Parameters:
        client (Player)
            Admin issuing the warning.
        target (Player)
            Player receiving the warning.
        reason (string)
            Warning reason.
        severity (string)
            Severity level.
        count (number)
            Total warnings after issuance.
        warnerSteamID (string)
            Issuer SteamID.
        targetSteamID (string)
            Target SteamID.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("WarningIssued", "RelayToDiscord", function(client, target, reason, severity)
                lia.discord.send("warnings", client:Name(), reason .. " (" .. severity .. ")")
            end)
        ```
]]
function WarningIssued(client, target, reason, severity, count, warnerSteamID, targetSteamID)
end

--[[
    Purpose:
        Fired when a warning is removed from a player.

    When Called:
        After the warning record is deleted.

    Parameters:
        client (Player)
            Admin removing the warning.
        targetClient (Player)
            Player whose warning was removed.
        arg3 (table)
            Warning data table.
        arg4 (any)
            Additional context.
        arg5 (any)
            Additional context.
        arg6 (any)
            Additional context.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("WarningRemoved", "NotifyRemoval", function(client, targetClient, data)
                targetClient:notifyLocalized("warningRemovedNotify", client:Name())
            end)
        ```
]]
function WarningRemoved(client, targetClient, arg3, arg4, arg5, arg6)
end
