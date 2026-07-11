--[[
    Hooks:
        OnPickupMoney(Player client, Entity moneyEntity)

    Purpose:
        Runs after a player successfully picks up a money entity so server systems can notify or log the transaction.

    Category:
        Economy

    Parameters:
        client (Player)
            The player who picked up the money.

        moneyEntity (Entity)
            The money entity that was consumed.

    Example Usage:
        ```lua
        hook.Add("OnPickupMoney", "liaExampleServerPickupMoney", function(client, moneyEntity)
            print(client:Nick(), moneyEntity:getAmount())
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PostPlayerInitialSpawn(client)

    Purpose:
        Runs after a player initially spawns so PAC part state can be synchronized to that client.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose PAC part state is being synchronized.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostPlayerInitialSpawn", "liaExamplePostPlayerInitialSpawnPAC", function(client)
            if client:hasPrivilege("canUsePAC3") then
                client:ChatPrint("PAC sync queued")
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanItemBeTransfered(Item item, Inventory curInv, Inventory inventory, Player|nil client)

    Purpose:
        Determines whether an item transfer between inventories should be allowed before the move is completed.

    Category:
        Inventory

    Parameters:
        item (Item)
            The item being transferred.

        curInv (Inventory)
            The source inventory that currently owns the item.

        inventory (Inventory)
            The destination inventory for the transfer.

        client (Player|nil)
            The player initiating the transfer, when available.

    Example Usage:
        ```lua
        hook.Add("CanItemBeTransfered", "liaExampleTransferCheck", function(item, curInv, inventory, client)
            if item and item.lockedToInventory then return false end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block the transfer. Returning nil allows the default behavior to continue.

    Realm:
        Server
]]
--[[
    Hooks:
        PreScaleDamage(number hitgroup, CTakeDamageInfo dmgInfo, number damageScale)

    Purpose:
        Runs immediately before scaled hitgroup damage is applied so modules can adjust the damage info or scale.

    Category:
        Combat

    Parameters:
        hitgroup (number)
            The hitgroup being processed.

        dmgInfo (CTakeDamageInfo)
            The mutable damage information object.

        damageScale (number)
            The scale that is about to be applied.

    Example Usage:
        ```lua
        hook.Add("PreScaleDamage", "liaExamplePreScaleDamage", function(hitgroup, dmgInfo, damageScale)
            if hitgroup == HITGROUP_HEAD then dmgInfo:ScaleDamage(0.9) end
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PostPlayerLoadout(Player client)

    Purpose:
        Runs after a player's loadout finishes so modules can perform final setup work.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose loadout just finished.

    Example Usage:
        ```lua
        hook.Add("PostPlayerLoadout", "liaExampleCorePostLoadout", function(client)
            print(client:Nick())
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        LoadData()

    Purpose:
        Runs when persistent gamemode data should be loaded from storage.

    Category:
        Persistence

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("LoadData", "liaExampleCoreLoadData", function()
            print("Loading saved world data")
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PostLoadData()

    Purpose:
        Runs after persistent gamemode data finishes loading so modules can perform post-load setup.

    Category:
        Persistence

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("PostLoadData", "liaExampleCorePostLoadData", function()
            print("Finished loading saved world data")
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        GetDefaultInventoryType(Character|nil character)

    Purpose:
        Allows modules to override which inventory type new characters should receive by default.

    Category:
        Inventory

    Parameters:
        character (Character|nil)
            The character being initialized, when available.

    Example Usage:
        ```lua
        hook.Add("GetDefaultInventoryType", "liaExampleInventoryType", function(character)
            return "GridInv"
        end)
        ```

    Returns:
        string|nil
            Return an inventory type identifier to override the default inventory type. Returning nil allows the default behavior to continue.

    Realm:
        Server
]]
--[[
    Hooks:
        GetEntitySaveData(Entity ent)

    Purpose:
        Allows modules to append extra data when a persistent entity is serialized.

    Category:
        Persistence

    Parameters:
        ent (Entity)
            The entity being serialized.

    Example Usage:
        ```lua
        hook.Add("GetEntitySaveData", "liaExampleCoreEntitySaveData", function(ent)
            if IsValid(ent) then return {customClass = ent:GetClass()} end
        end)
        ```

    Returns:
        table|nil
            Return a table of extra save data to merge into the entity record. Returning nil leaves the save payload unchanged.

    Realm:
        Server
]]
--[[
    Hooks:
        OnEntityLoaded(Entity ent, table data)

    Purpose:
        Runs after a persistent entity is recreated so modules can restore extra state from the saved data.

    Category:
        Persistence

    Parameters:
        ent (Entity)
            The entity that was loaded.

        data (table)
            The decoded save data for the entity.

    Example Usage:
        ```lua
        hook.Add("OnEntityLoaded", "liaExampleCoreEntityLoaded", function(ent, data)
            if IsValid(ent) and data.customClass then print(data.customClass) end
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldPlayDeathSound(Player client, string|nil deathSound)

    Purpose:
        Allows plugins or modules to block player death sound selection or the final death sound playback.

    Category:
        Voice

    Parameters:
        client (Player)
            The player whose death sound is being processed.

        deathSound (string|nil)
            The resolved sound that is about to be emitted. This is nil during the earlier selection check in `GetPlayerDeathSound`.

    Returns:
        boolean|nil
            Return false to stop the death sound flow at the current stage. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldPlayDeathSound", "liaExampleShouldPlayDeathSound", function(client, deathSound)
            if client:isStaffOnDuty() then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldPlayPainSound(Player client, string painContextOrSound)

    Purpose:
        Allows plugins or modules to block player pain sound selection or the final pain sound playback.

    Category:
        Voice

    Parameters:
        client (Player)
            The player whose pain sound is being processed.

        painContextOrSound (string)
            Either the requested pain context such as `hurt` or `drown`, or the resolved sound path that is about to be emitted.

    Returns:
        boolean|nil
            Return false to stop the pain sound flow at the current stage. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldPlayPainSound", "liaExampleShouldPlayPainSound", function(client, painContextOrSound)
            if painContextOrSound == "drown" then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CharPreSave(Character character)

    Purpose:
        Runs before a character row is written to the database so modules can update transient state or cancel the save.

    Category:
        Character

    Parameters:
        character (Character)
            The character that is about to be saved.

    Returns:
        boolean|nil
            Return false to stop the character save. Returning nil allows the save to continue.

    Example Usage:
        ```lua
        hook.Add("CharPreSave", "liaExampleCharPreSave", function(character)
            if character:getData("savingLocked") then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerInteractItem(Player client, string action, Item item, table|nil data)

    Purpose:
        Determines whether a player may run an item interaction through the standard item action flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting the item interaction.

        action (string)
            The lowercased action identifier such as `drop`, `take`, `equip`, `unequip`, or `combine`.

        item (Item)
            The item being interacted with.

        data (table|nil)
            Optional extra action data forwarded by the caller, such as combine context.

    Returns:
        boolean|string|nil
            Return false to block the interaction. A second return value may provide the failure reason used by callers. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerInteractItem", "liaExampleCanPlayerInteractItem", function(client, action, item, data)
            if action == "drop" and item.uniqueID == "radio" then
                return false, L("forbiddenActionStorage")
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerHoldObject(Player client, Entity entity)

    Purpose:
        Determines whether the hands weapon may pick up and hold a traced entity.

    Category:
        Interaction

    Parameters:
        client (Player)
            The player attempting to hold the entity.

        entity (Entity)
            The entity the player is trying to pick up.

    Returns:
        boolean|nil
            Return true to explicitly allow holding or false to block it. Returning nil allows the default class and holdable checks to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerHoldObject", "liaExampleCanPlayerHoldObject", function(client, entity)
            if entity:GetClass() == "prop_ragdoll" then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldDataBeSaved()

    Purpose:
        Determines whether the server shutdown routine should save Lilia data, config, characters, and admin state.

    Category:
        Persistence

    Parameters:
        None

    Returns:
        boolean|nil
            Return false to skip the shutdown save routine. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldDataBeSaved", "liaExampleShouldDataBeSaved", function()
            if lia.shuttingDown then
                return true
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        SetupBotPlayer(Player client)

    Purpose:
        Runs when a bot joins so modules can replace or extend the default bot character setup flow.

    Category:
        Character

    Parameters:
        client (Player)
            The bot player that is being initialized.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("SetupBotPlayer", "liaExampleSetupBotPlayer", function(client)
            print("Preparing bot:", client:Nick())
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldEntitySave(Entity entity)

    Purpose:
        Determines whether a persistent entity should be included in Lilia's persistence save, create, and update routines.

    Category:
        Persistence

    Parameters:
        entity (Entity)
            The live entity being evaluated for persistence.

    Returns:
        boolean|nil
            Return false to exclude the entity from persistence. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldEntitySave", "liaExampleShouldEntitySave", function(entity)
            if entity:GetClass() == "prop_ragdoll" then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldEntityLoad(table entityData)

    Purpose:
        Determines whether a persisted entity entry should be restored during data loading.

    Category:
        Persistence

    Parameters:
        entityData (table)
            The saved persistence row containing class, position, angles, model, and optional custom data.

    Returns:
        boolean|nil
            Return false to skip restoring that saved entity. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldEntityLoad", "liaExampleShouldEntityLoad", function(entityData)
            if entityData.class == "prop_ragdoll" then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldDeleteSavedItems()

    Purpose:
        Determines whether saved world items should be deleted from storage instead of being respawned during data loading.

    Category:
        Persistence

    Parameters:
        None

    Returns:
        boolean|nil
            Return true to delete the saved item records instead of restoring them. Returning nil or false allows normal item restoration.

    Example Usage:
        ```lua
        hook.Add("ShouldDeleteSavedItems", "liaExampleShouldDeleteSavedItems", function()
            return false
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        UpdateEntityPersistence(Entity entity)

    Purpose:
        Runs when a persistent entity should refresh its saved position, model, angles, and custom persistence data.

    Category:
        Persistence

    Parameters:
        entity (Entity)
            The live persistent entity whose saved record should be updated.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("UpdateEntityPersistence", "liaExampleUpdateEntityPersistence", function(entity)
            if entity.IsPersistent then
                print("Refreshing persistence for", entity:GetClass())
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldOverrideSalaryTimers()

    Purpose:
        Determines whether Lilia should skip creating its default salary interval timers.

    Category:
        Economy

    Parameters:
        None

    Returns:
        boolean|nil
            Return true to prevent the default salary timers from being created. Returning nil or false allows the normal timer setup.

    Example Usage:
        ```lua
        hook.Add("ShouldOverrideSalaryTimers", "liaExampleShouldOverrideSalaryTimers", function()
            return false
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        ShouldSpawnClientRagdoll(Player client)

    Purpose:
        Determines whether a player death should create the default client ragdoll.

    Category:
        Character

    Parameters:
        client (Player)
            The player who has just died.

    Returns:
        boolean|nil
            Return false to block ragdoll creation. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("ShouldSpawnClientRagdoll", "liaExampleShouldSpawnClientRagdoll", function(client)
            if client:isStaffOnDuty() then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetPlayerDeathSound(client, isFemale)

    Purpose:
        Allows plugins or modules to override the death sound selected for a player.

    Category:
        Voice

    Parameters:
        client (Player)
            The player whose death sound is being resolved.

        isFemale (boolean)
            Whether the player should use the female sound set.

    Returns:
        string|nil
            Return a sound path or sound object to override the death sound. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetPlayerDeathSound", "liaExampleGetPlayerDeathSound", function(client, isFemale)
            if client:isStaffOnDuty() then
                return "vo/npc/male01/pain07.wav"
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetPlayerPainSound(client, paintype, isFemale)

    Purpose:
        Allows plugins or modules to override the pain sound selected for a player.

    Category:
        Voice

    Parameters:
        client (Player)
            The player whose pain sound is being resolved.

        paintype (string)
            The pain context being resolved, such as `hurt` or `drown`.

        isFemale (boolean)
            Whether the player should use the female sound set.

    Returns:
        string|nil
            Return a sound path or sound object to override the pain sound. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetPlayerPainSound", "liaExampleGetPlayerPainSound", function(client, paintype, isFemale)
            if paintype == "drown" then
                return "player/pl_drown1.wav"
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetDamageScale(hitgroup, dmgInfo, damageScale)

    Purpose:
        Allows plugins or modules to override the damage multiplier before scaled damage is applied.

    Category:
        Combat

    Parameters:
        hitgroup (number)
            The Garry's Mod hitgroup being processed.

        dmgInfo (CTakeDamageInfo)
            The damage information object being scaled.

        damageScale (number)
            The current damage multiplier after Lilia's head and limb checks.

    Returns:
        number|nil
            Return a numeric multiplier to replace the current damage scale. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetDamageScale", "liaExampleGetDamageScale", function(hitgroup, dmgInfo, damageScale)
            if hitgroup == HITGROUP_HEAD then
                return damageScale * 0.75
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PostScaleDamage(hitgroup, dmgInfo, damageScale)

    Purpose:
        Runs after the current damage scale has been applied to the damage info object.

    Category:
        Combat

    Parameters:
        hitgroup (number)
            The Garry's Mod hitgroup that was processed.

        dmgInfo (CTakeDamageInfo)
            The scaled damage information object.

        damageScale (number)
            The multiplier that was applied to the damage.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostScaleDamage", "liaExamplePostScaleDamage", function(hitgroup, dmgInfo, damageScale)
            print("[Damage] Applied scale:", damageScale)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OverrideVoiceHearingStatus(listener, speaker, canHear)

    Purpose:
        Allows plugins or modules to override cached voice hearing checks for a listener and speaker pair.

    Category:
        Voice

    Parameters:
        listener (Player)
            The player whose hearing result is being computed.

        speaker (Player)
            The speaking player being checked.

        canHear (boolean)
            The current range-based hearing result.

    Returns:
        boolean|nil
            Return true or false to override whether the listener can hear the speaker. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("OverrideVoiceHearingStatus", "liaExampleOverrideVoiceHearingStatus", function(listener, speaker, canHear)
            if listener:isStaffOnDuty() then
                return true
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnDeathSoundPlayed(client, deathSound)

    Purpose:
        Runs after a death sound has been emitted for a player.

    Category:
        Voice

    Parameters:
        client (Player)
            The player who emitted the death sound.

        deathSound (string)
            The sound that was played.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnDeathSoundPlayed", "liaExampleOnDeathSoundPlayed", function(client, deathSound)
            lia.log.add(client, "deathSoundPlayed", deathSound)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PrePlayerLoadedChar(client)

    Purpose:
        Runs immediately before the player's bodygroups, skin, and movement state are reset for character loading.

    Category:
        Character

    Parameters:
        client (Player)
            The player who is about to load a character.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PrePlayerLoadedChar", "liaExamplePrePlayerLoadedChar", function(client)
            client:SetDSP(1, false)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerDropItem(client, item)

    Purpose:
        Determines whether a player may drop an item through the standard item interaction flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting to drop the item.

        item (Item)
            The item being dropped.

    Returns:
        boolean|nil
            Return false to block the drop action. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerDropItem", "liaExampleCanPlayerDropItem", function(client, item)
            if item.uniqueID == "radio" then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerTakeItem(client, item)

    Purpose:
        Determines whether a player may take an item through the standard item interaction flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting to take the item.

        item (Item)
            The item being taken.

    Returns:
        boolean|nil
            Return false to block the take action. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerTakeItem", "liaExampleCanPlayerTakeItem", function(client, item)
            if client:getNetVar("jailed") then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerEquipItem(client, item)

    Purpose:
        Determines whether a player may equip an item through the standard item interaction flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting to equip the item.

        item (Item)
            The item being equipped.

    Returns:
        boolean|nil
            Return false to block the equip action. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerEquipItem", "liaExampleCanPlayerEquipItem", function(client, item)
            if item.uniqueID == "heavyarmor" and client:Crouching() then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerUnequipItem(client, item)

    Purpose:
        Determines whether a player may unequip an item through the standard item interaction flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting to unequip the item.

        item (Item)
            The item being unequipped.

    Returns:
        boolean|nil
            Return false to block the unequip action. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerUnequipItem", "liaExampleCanPlayerUnequipItem", function(client, item)
            if client:getNetVar("restricted") then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerRotateItem(client, item)

    Purpose:
        Determines whether a player may rotate an item through the standard item interaction flow.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting to rotate the item.

        item (Item)
            The item being rotated.

    Returns:
        boolean|nil
            Return false to block item rotation. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerRotateItem", "liaExampleCanPlayerRotateItem", function(client, item)
            if item.isBag then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PostPlayerSay(client, message, chatType, anonymous)

    Purpose:
        Runs after the parsed chat message has been sent through the active chat class.

    Category:
        Chatbox

    Parameters:
        client (Player)
            The player who sent the message.

        message (string)
            The parsed message text that was sent.

        chatType (string)
            The resolved chat class identifier.

        anonymous (boolean)
            Whether the message was sent anonymously.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostPlayerSay", "liaExamplePostPlayerSay", function(client, message, chatType, anonymous)
            print(client:Nick(), chatType, message)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnPainSoundPlayed(entity, painSound)

    Purpose:
        Runs after a pain sound has been emitted for a player.

    Category:
        Voice

    Parameters:
        entity (Player)
            The player who emitted the pain sound.

        painSound (string)
            The sound that was played.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnPainSoundPlayed", "liaExampleOnPainSoundPlayed", function(entity, painSound)
            lia.log.add(entity, "painSoundPlayed", painSound)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetBotModel(client, faction)

    Purpose:
        Allows plugins or modules to override the model used when the framework creates a bot character.

    Category:
        Character

    Parameters:
        client (Player)
            The bot player being configured.

        faction (table)
            The default faction selected for the bot.

    Returns:
        string|nil
            Return a player model path to override the default bot model. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetBotModel", "liaExampleGetBotModel", function(client, faction)
            if faction and faction.uniqueID == "combine" then
                return "models/player/police.mdl"
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PostBotSetup(client, character, inventory)

    Purpose:
        Runs after a bot player, character, and inventory have been created and spawned.

    Category:
        Character

    Parameters:
        client (Player)
            The bot player that was configured.

        character (Character)
            The newly created bot character.

        inventory (Inventory)
            The bot's newly created inventory instance.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostBotSetup", "liaExamplePostBotSetup", function(client, character, inventory)
            character:giveMoney(500)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnEntityPersisted(ent, entData)

    Purpose:
        Runs after a persistent entity snapshot has been written into the persistence data set.

    Category:
        Persistence

    Parameters:
        ent (Entity)
            The entity that was saved.

        entData (table)
            The serialized persistence payload stored for the entity.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnEntityPersisted", "liaExampleOnEntityPersisted", function(ent, entData)
            print("[Persistence] Saved", entData.class)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnSavedItemLoaded(loadedItems)

    Purpose:
        Runs after saved world items have been restored from database rows.

    Category:
        Persistence

    Parameters:
        loadedItems (table)
            An array containing the restored item instances.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnSavedItemLoaded", "liaExampleOnSavedItemLoaded", function(loadedItems)
            print("[Persistence] Restored items:", #loadedItems)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnEntityPersistUpdated(ent, data)

    Purpose:
        Runs after an existing persistent entity entry has been updated in the saved persistence data.

    Category:
        Persistence

    Parameters:
        ent (Entity)
            The entity whose saved record was updated.

        data (table)
            The updated persistence data entry.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnEntityPersistUpdated", "liaExampleOnEntityPersistUpdated", function(ent, data)
            print("[Persistence] Updated", data.class)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerEarnSalary(client)

    Purpose:
        Determines whether a player should receive salary checks when the salary timers fire.

    Category:
        Salary

    Parameters:
        client (Player)
            The player being considered for salary payment.

    Returns:
        boolean|nil
            Return false to skip salary payment for the player. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerEarnSalary", "liaExampleCanPlayerEarnSalary", function(client)
            if client:getNetVar("jailed") then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetSalaryAmount(client, charFaction, class)

    Purpose:
        Allows plugins or modules to override the base salary amount before bonuses and final adjustments are applied.

    Category:
        Salary

    Parameters:
        client (Player)
            The player receiving salary.

        charFaction (table)
            The faction data for the player's character.

        class (table|nil)
            The class data for the player's character, if any.

    Returns:
        number|nil
            Return a numeric salary amount to override the base pay. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetSalaryAmount", "liaExampleGetSalaryAmount", function(client, charFaction, class)
            if class and class.uniqueID == "chief" then
                return 250
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnSalaryAdjust(client)

    Purpose:
        Allows plugins or modules to replace the current salary amount before prestige bonuses are applied.

    Category:
        Salary

    Parameters:
        client (Player)
            The player receiving salary.

    Returns:
        number|nil
            Return a numeric salary amount to replace the current pay value. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("OnSalaryAdjust", "liaExampleOnSalaryAdjust", function(client)
            if client:hasPrivilege("salaryBonus") then
                return 300
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetPrestigePayBonus(client, char, pay, charFaction, class)

    Purpose:
        Allows plugins or modules to add an extra prestige-style bonus on top of the current salary amount.

    Category:
        Salary

    Parameters:
        client (Player)
            The player receiving salary.

        char (Character)
            The player's current character.

        pay (number)
            The current salary value before the prestige bonus is added.

        charFaction (table)
            The faction data for the player's character.

        class (table|nil)
            The class data for the player's character, if any.

    Returns:
        number|nil
            Return a numeric bonus to add to the current pay. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetPrestigePayBonus", "liaExampleGetPrestigePayBonus", function(client, char, pay, charFaction, class)
            if char:getData("prestige", 0) > 0 then
                return 50
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PreSalaryGive(client, char, pay, charFaction, class)

    Purpose:
        Runs before the framework gives salary money to the character.

    Category:
        Salary

    Parameters:
        client (Player)
            The player receiving salary.

        char (Character)
            The player's current character.

        pay (number)
            The current salary amount.

        charFaction (table)
            The faction data for the player's character.

        class (table|nil)
            The class data for the player's character, if any.

    Returns:
        boolean|nil
            Return true to mark salary handling as fully handled and suppress the default payout. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("PreSalaryGive", "liaExamplePreSalaryGive", function(client, char, pay, charFaction, class)
            if pay <= 0 then
                return true
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnSalaryGiven(client, char, pay, charFaction, class)

    Purpose:
        Allows plugins or modules to override the final salary amount immediately before money is awarded.

    Category:
        Salary

    Parameters:
        client (Player)
            The player receiving salary.

        char (Character)
            The player's current character.

        pay (number)
            The current salary amount.

        charFaction (table)
            The faction data for the player's character.

        class (table|nil)
            The class data for the player's character, if any.

    Returns:
        number|nil
            Return a numeric value to replace the final salary payout. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("OnSalaryGiven", "liaExampleOnSalaryGiven", function(client, char, pay, charFaction, class)
            return math.max(pay, 25)
        end)
        ```

    Realm:
        Server
]]
local GM = GM or GAMEMODE
local VOICE_WHISPERING = "whispering"
local VOICE_TALKING = "talking"
local VOICE_YELLING = "yelling"
local LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}
local sounds = {
    male = {
        death = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav"),},
        hurt = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav"),},
    },
    female = {
        death = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav"),},
        hurt = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav"),},
    }
}

local function getGender(isFemale)
    return isFemale and "female" or "male"
end

function GM:GetPlayerDeathSound(client, isFemale)
    if hook.Run("ShouldPlayDeathSound", client) == false then return end
    local sndTab = sounds[getGender(isFemale)].death
    return sndTab[math.random(#sndTab)]
end

function GM:GetPlayerPainSound(client, paintype, isFemale)
    if hook.Run("ShouldPlayPainSound", client, paintype) == false then return end
    if paintype == "hurt" then
        local sndTab = sounds[getGender(isFemale)].hurt
        return sndTab[math.random(#sndTab)]
    end
end

function GM:GetFallDamage(client, speed)
    if not lia.config.get("FallDamageEnabled", true) then return 0 end
    return math.max(0, (speed - 580) * 100 / 444)
end

function GM:ScalePlayerDamage(client, hitgroup, dmgInfo)
    local damageScale = lia.config.get("DamageScale")
    hook.Run("PreScaleDamage", hitgroup, dmgInfo, damageScale)
    if hitgroup == HITGROUP_HEAD then
        damageScale = lia.config.get("HeadShotDamage")
    elseif table.HasValue(LimbHitgroups, hitgroup) then
        damageScale = lia.config.get("LimbDamage")
    end

    damageScale = hook.Run("GetDamageScale", hitgroup, dmgInfo, damageScale) or damageScale
    dmgInfo:ScaleDamage(damageScale)
    hook.Run("PostScaleDamage", hitgroup, dmgInfo, damageScale)
end

function GM:CharPreSave(character)
    local client = character:getPlayer()
    local loginTime = character:getLoginTime()
    if IsValid(client) and client:getChar() == character then
        if loginTime and loginTime > 0 then
            local total = character:getPlayTime()
            character:setPlayTime(total + os.time() - loginTime)
            character:setLoginTime(os.time())
        else
            character:setLoginTime(os.time())
        end
    end

    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.OnSave then v:call("OnSave", client) end
    end

    if IsValid(client) and client:getChar() == character then
        local ammoTable = {}
        for _, ammoType in pairs(game.GetAmmoTypes()) do
            if ammoType then
                local ammoCount = client:GetAmmoCount(ammoType)
                if isnumber(ammoCount) and ammoCount > 0 then ammoTable[ammoType] = ammoCount end
            end
        end

        character:setData("ammo", ammoTable)
    end
end

local function CacheVoiceHearing()
    if not lia.config.get("IsVoiceEnabled", true) then return end
    local speakerGaggedCache = {}
    for _, speaker in player.Iterator() do
        if IsValid(speaker) and speaker:getChar() and speaker:Alive() then speakerGaggedCache[speaker] = speaker:getLiliaData("liaGagged", false) end
    end

    for _, listener in player.Iterator() do
        if not IsValid(listener) or not listener:getChar() or not listener:Alive() then
            listener.liaVoiceHear = nil
            continue
        end

        listener.liaVoiceHear = listener.liaVoiceHear or {}
        for _, speaker in player.Iterator() do
            if not IsValid(speaker) or speaker == listener or not speaker:getChar() or not speaker:Alive() or speakerGaggedCache[speaker] then
                listener.liaVoiceHear[speaker] = nil
                continue
            end

            local voiceType = speaker:getLocalVar("VoiceType", VOICE_TALKING)
            local baseRange = voiceType == VOICE_WHISPERING and lia.config.get("WhisperRange", 70) or voiceType == VOICE_TALKING and lia.config.get("TalkRange", 280) or voiceType == VOICE_YELLING and lia.config.get("YellRange", 840) or lia.config.get("TalkRange", 280)
            local distance = listener:GetPos():Distance(speaker:GetPos())
            listener.liaVoiceHear[speaker] = distance <= baseRange
            local hookResult = hook.Run("OverrideVoiceHearingStatus", listener, speaker, listener.liaVoiceHear[speaker])
            if hookResult ~= nil then listener.liaVoiceHear[speaker] = hookResult end
        end
    end
end

--[[
    Hooks:
        PlayerShouldPermaKill(Player client, Entity inflictor, Entity attacker)

    Purpose:
        Determines whether a player death caused by another player should permanently kill the victim's character.

    Category:
        Character

    Parameters:
        client (Player)
            The player who died.

        inflictor (Entity)
            The inflictor responsible for the death.

        attacker (Entity)
            The attacker responsible for the death.

    Returns:
        boolean|nil
            Return true to permanently kill the victim's character. Returning nil or false allows the default death flow to continue without a perma-kill.

    Example Usage:
        ```lua
        hook.Add("PlayerShouldPermaKill", "liaExamplePlayerShouldPermaKill", function(client, inflictor, attacker)
            if IsValid(attacker) and attacker:IsPlayer() and attacker:isStaffOnDuty() then
                return true
            end
        end)
        ```

    Realm:
        Server
]]
function GM:PlayerDeath(client, inflictor, attacker)
    if lia.config.get("DeathSoundEnabled") then
        local deathSound = hook.Run("GetPlayerDeathSound", client, client:isFemale())
        if deathSound and hook.Run("ShouldPlayDeathSound", client, deathSound) ~= false then
            client:EmitSound(deathSound)
            hook.Run("OnDeathSoundPlayed", client, deathSound)
        end
    end

    local character = client:getChar()
    if not character then return end
    if IsValid(client:GetRagdollEntity()) then client:GetRagdollEntity():Remove() end
    local handsWeapon = client:GetActiveWeapon()
    if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
    local inventory = character:getInv()
    if inventory then
        for _, item in pairs(inventory:getItems()) do
            if item.isWeapon and item:getData("equip") then item:setData("ammo", nil) end
        end
    end

    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= client and hook.Run("PlayerShouldPermaKill", client, inflictor, attacker) then character:ban() end
    net.Start("liaRemoveFOne")
    net.Send(client)
    if hook.Run("ShouldSpawnClientRagdoll", client) ~= false then client:CreateRagdoll() end
end

function GM:PrePlayerLoadedChar(client)
    client:SetBodyGroups("000000000")
    client:SetSkin(0)
    client:ExitVehicle()
    client:Freeze(false)
end

function GM:PlayerLoadedChar(client, character)
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        lastJoinTime = timeStamp
    }, nil, "characters", "id = " .. character:getID())

    client:removeRagdoll()
    client:stopAction()
    character:setLoginTime(os.time())
    hook.Run("PlayerLoadout", client)
    if not timer.Exists("liaSalaryGlobal") then hook.Run("CreateSalaryTimers") end
    if not timer.Exists("liaVoiceUpdate") then timer.Create("liaVoiceUpdate", 0.5, 0, function() CacheVoiceHearing() end) end
    local ammoTable = character:getData("ammo")
    if character:getFaction() == FACTION_STAFF then
        local storedDiscord = client:getLiliaData("staffDiscord")
        if storedDiscord and storedDiscord ~= "" then
            local description = L("staffCharacterDiscordSteamID", storedDiscord, client:SteamID())
            character:setDesc(description)
        else
            if character:getDesc() == "" or character:getDesc():find(L("staffCharacter")) then
                timer.Simple(2, function()
                    if IsValid(client) and client:getChar() == character then
                        net.Start("liaStaffDiscordPrompt")
                        net.Send(client)
                    end
                end)
            end
        end
    end

    if istable(ammoTable) and not table.IsEmpty(ammoTable) then
        timer.Simple(0.25, function()
            if not IsValid(client) then return end
            for ammoType, ammoCount in pairs(ammoTable) do
                client:GiveAmmo(ammoCount, ammoType, true)
            end

            character:setData("ammo", nil)
        end)
    end

    local permaFlags = client:getLiliaData("permanentflags", "")
    if permaFlags and permaFlags ~= "" then
        local cleaned = permaFlags:gsub("%s", "")
        local toGive = ""
        for i = 1, #cleaned do
            local flag = cleaned:sub(i, i)
            if not character:hasFlags(flag) then toGive = toGive .. flag end
        end

        if toGive ~= "" then character:giveFlags(toGive) end
    end
end

function GM:OnPickupMoney(client, moneyEntity)
    if moneyEntity and IsValid(moneyEntity) then
        local amount = moneyEntity:getAmount()
        client:notifyMoneyLocalized("moneyTaken", lia.currency.get(amount))
        lia.log.add(client, "moneyPickedUp", amount)
    end
end

function GM:CanItemBeTransfered(item, curInv, inventory)
    if item.isBag and curInv ~= inventory and item.getInv and item:getInv() and table.Count(item:getInv():getItems()) > 0 then
        lia.char.getCharacter(curInv.client, nil, function(character) if character then character:getPlayer():notifyErrorLocalized("forbiddenActionStorage") end end)
        return false
    end

    if item.OnCanBeTransfered then
        local itemHook = item:OnCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

function GM:CanPlayerInteractItem(client, action, item)
    action = string.lower(action)
    local inventory = lia.inventory.instances[item.invID]
    if action == "equip" then print("[LILIA DEBUG][CanPlayerInteractItem]", "client=", IsValid(client) and client:Nick() or "nil", "item=", item and item.uniqueID or "nil", "invID=", item and item.invID or "nil", "inventoryType=", inventory and inventory.typeID or "nil", "isStorage=", inventory and tostring(inventory.isStorage) or "nil", "isExternalInventory=", inventory and tostring(inventory.isExternalInventory) or "nil", "isBag=", inventory and tostring(inventory.isBag) or "nil", "bagItemID=", inventory and tostring(inventory:getData("item")) or "nil", "char=", inventory and tostring(inventory:getData("char")) or "nil") end
    local hasNoItemCooldown = client:hasPrivilege("noItemCooldown")
    lia.debug("[Permissions]", "Permission Check for hook GM:CanPlayerInteractItem", "action=", tostring(action), "hasPrivilege(noItemCooldown)=", tostring(hasNoItemCooldown), "finalResult=", tostring(hasNoItemCooldown))
    if hasNoItemCooldown then return true end
    if not client:Alive() then return false, L("forbiddenActionStorage") end
    if IsValid(client:GetRagdollEntity()) then return false, L("forbiddenActionStorage") end
    if action == "drop" then
        if hook.Run("CanPlayerDropItem", client, item) ~= false then
            if not client.dropDelay then
                client.dropDelay = true
                timer.Create("DropDelay." .. client:SteamID64(), lia.config.get("DropDelay"), 1, function() if IsValid(client) then client.dropDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "take" then
        if hook.Run("CanPlayerTakeItem", client, item) ~= false then
            if not client.takeDelay then
                client.takeDelay = true
                timer.Create("TakeDelay." .. client:SteamID64(), lia.config.get("TakeDelay"), 1, function() if IsValid(client) then client.takeDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "equip" then
        if hook.Run("CanPlayerEquipItem", client, item) ~= false then
            if not client.equipDelay then
                client.equipDelay = true
                timer.Create("EquipDelay." .. client:SteamID64(), lia.config.get("EquipDelay"), 1, function() if IsValid(client) then client.equipDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "unequip" then
        if hook.Run("CanPlayerUnequipItem", client, item) ~= false then
            if not client.unequipDelay then
                client.unequipDelay = true
                timer.Create("UnequipDelay." .. client:SteamID64(), lia.config.get("UnequipDelay"), 1, function() if IsValid(client) then client.unequipDelay = nil end end)
                return true
            else
                client:notifyWarningLocalized("switchCooldown")
                return false
            end
        else
            return false
        end
    end

    if action == "rotate" then return hook.Run("CanPlayerRotateItem", client, item) ~= false end
end

function GM:CanPlayerEquipItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    local bagItemID = inventory and inventory:getData("item")
    local isBagInventory = inventory and (inventory.isBag or bagItemID ~= nil)
    print("[LILIA DEBUG][CanPlayerEquipItem]", "client=", IsValid(client) and client:Nick() or "nil", "item=", item and item.uniqueID or "nil", "invID=", item and item.invID or "nil", "inventoryType=", inventory and inventory.typeID or "nil", "isStorage=", inventory and tostring(inventory.isStorage) or "nil", "isExternalInventory=", inventory and tostring(inventory.isExternalInventory) or "nil", "isBag=", inventory and tostring(inventory.isBag) or "nil", "bagItemID=", tostring(bagItemID), "derivedBagInventory=", tostring(isBagInventory), "char=", inventory and tostring(inventory:getData("char")) or "nil")
    if client.equipDelay ~= nil then
        print("[LILIA DEBUG][CanPlayerEquipItem]", "blockedReason=", "equipDelay")
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif inventory and (isBagInventory or inventory.isExternalInventory or inventory.isStorage) then
        print("[LILIA DEBUG][CanPlayerEquipItem]", "blockedReason=", "forbiddenActionStorage")
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    end

    print("[LILIA DEBUG][CanPlayerEquipItem]", "result=", "allowed")
end

function GM:CanPlayerTakeItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.takeDelay ~= nil then
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    elseif client:isFamilySharedAccount() then
        client:notifyErrorLocalized("familySharedPickupDisabled")
        return false
    elseif IsValid(item.entity) then
        local character = client:getChar()
        if character and item.entity.liaCharID then
            if item.entity.liaCharID == 0 then return true end
            if item.entity.liaCharID == character:getID() then return true end
            return true
        end
    end
end

function GM:CanPlayerDropItem(client, item)
    local inventory = lia.inventory.instances[item.invID]
    if client.dropDelay ~= nil then
        client:notifyWarningLocalized("switchCooldown")
        return false
    elseif item.isBag and item:getInv() then
        local items = item:getInv():getItems()
        for _, otheritem in pairs(items) do
            if not otheritem.ignoreEquipCheck and otheritem:getData("equip", false) then
                client:notifyErrorLocalized("cantDropBagHasEquipped")
                return false
            end
        end
    elseif inventory and (inventory.isBag or inventory.isExternalInventory) then
        client:notifyErrorLocalized("forbiddenActionStorage")
        return false
    end
    return true
end

local logTypeMap = {
    ooc = "chatOOC",
    looc = "chatLOOC"
}

function GM:CheckPassword(steamID64, ipAddress, serverPassword, clientPassword, playerName)
    local steamID = util.SteamIDFrom64(steamID64)
    if serverPassword ~= "" and serverPassword ~= clientPassword then
        lia.log.add(nil, "failedPassword", steamID, playerName, serverPassword, clientPassword)
        lia.information(L("passwordsDoNotMatchFor") .. " " .. tostring(playerName) .. " (" .. tostring(steamID) .. ").")
        return false, L("passwordsDoNotMatch")
    end
end

function GM:PlayerSay(client, message)
    if not message then return "" end
    local chatType, parsedMessage, anonymous = lia.chat.parse(client, message, true)
    message = parsedMessage
    if chatType == "ic" and lia.command.parse(client, message) then return "" end
    if utf8.len(message) > lia.config.get("MaxChatLength") then
        client:notifyErrorLocalized("tooLongMessage")
        return ""
    end

    local logType = logTypeMap[chatType] or "chat"
    lia.chat.send(client, chatType, message, anonymous)
    if lia.chat.classes[chatType] then
        if logType == "chat" then
            lia.log.add(client, logType, chatType and chatType:upper() or "??", message)
        else
            lia.log.add(client, logType, message)
        end
    end

    hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    return ""
end

local allowedHoldableClasses = {
    ["prop_physics"] = true,
    ["prop_physics_override"] = true,
    ["prop_physics_multiplayer"] = true,
    ["prop_ragdoll"] = true
}

function GM:CanPlayerHoldObject(client, entity)
    return allowedHoldableClasses[entity:GetClass()] or entity.Holdable
end

function GM:EntityTakeDamage(entity, dmgInfo)
    if lia.config.get("PainSoundEnabled", true) and entity:IsPlayer() and entity:Health() > 0 then
        local painSound = hook.Run("GetPlayerPainSound", entity, "hurt", entity:isFemale())
        if entity:WaterLevel() >= 3 then painSound = hook.Run("GetPlayerPainSound", entity, "drown", entity:isFemale()) end
        if painSound and hook.Run("ShouldPlayPainSound", entity, painSound) ~= false and (entity.NextPain or 0) <= CurTime() then
            entity:EmitSound(painSound)
            hook.Run("OnPainSoundPlayed", entity, painSound)
            entity.NextPain = CurTime() + 0.33
        end
    end

    if entity:GetClass() == "prop_ragdoll" then
        local owner
        for _, ply in player.Iterator() do
            if ply:GetRagdollEntity() == entity then
                owner = ply
                break
            end
        end

        if not IsValid(owner) then return end
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
                entity.liaFallGrace = CurTime() + 0.5
            else
                return true
            end
        end

        local transfer = DamageInfo()
        transfer:SetDamage(dmgInfo:GetDamage())
        transfer:SetDamageType(dmgInfo:GetDamageType())
        transfer:SetAttacker(IsValid(dmgInfo:GetAttacker()) and dmgInfo:GetAttacker() or game.GetWorld())
        transfer:SetInflictor(IsValid(dmgInfo:GetInflictor()) and dmgInfo:GetInflictor() or game.GetWorld())
        transfer:SetDamageForce(dmgInfo:GetDamageForce())
        transfer:SetDamagePosition(dmgInfo:GetDamagePosition())
        transfer:SetReportedPosition(dmgInfo:GetReportedPosition())
        if dmgInfo.GetAmmoType then transfer:SetAmmoType(dmgInfo:GetAmmoType()) end
        owner:TakeDamageInfo(transfer)
        dmgInfo:SetDamage(0)
        return true
    end

    if not entity:IsPlayer() then return end
    local isStaffOnDuty = entity:isStaffOnDuty()
    local staffHasGodMode = lia.config.get("StaffHasGodMode", true)
    lia.debug("[Permissions]", "Permission Check for hook GM:EntityTakeDamage staff godmode", "isStaffOnDuty=", tostring(isStaffOnDuty), "StaffHasGodMode=", tostring(staffHasGodMode), "finalResult=", tostring(isStaffOnDuty and staffHasGodMode))
    if isStaffOnDuty and staffHasGodMode then return true end
    if entity:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if dmgInfo:IsDamageType(DMG_CRUSH) then
        if (entity.liaFallGrace or 0) < CurTime() then
            if dmgInfo:GetDamage() <= 10 then dmgInfo:SetDamage(0) end
            entity.liaFallGrace = CurTime() + 0.5
        else
            return true
        end
    end
end

function GM:KeyPress(client, key)
    if key == IN_JUMP then
        local traceStart = client:GetShootPos() + Vector(0, 0, 15)
        local traceEndHi = traceStart + client:GetAimVector() * 30
        local traceEndLo = traceStart + client:GetAimVector() * 30
        local trHi = util.TraceLine({
            start = traceStart,
            endpos = traceEndHi,
            filter = client
        })

        local trLo = util.TraceLine({
            start = client:GetShootPos(),
            endpos = traceEndLo,
            filter = client
        })

        if trLo.Hit and not trHi.Hit then
            local dist = math.abs(trHi.HitPos.z - client:GetPos().z)
            client:SetVelocity(Vector(0, 0, 50 + dist * 3))
        end

        local char = client:getChar()
        if char then
            local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
            local stamina = client:getLocalVar("stamina", maxStamina)
            local jumpReq = lia.config.get("JumpStaminaCost", 25)
            if stamina >= jumpReq and client:GetMoveType() ~= MOVETYPE_NOCLIP and not client:InVehicle() and client:Alive() and (client.liaNextJump or 0) <= CurTime() then
                client.liaNextJump = CurTime() + 0.1
                client:consumeStamina(jumpReq)
                local newStamina = client:getLocalVar("stamina", maxStamina)
                if newStamina <= 0 then
                    client:setLocalVar("brth", true)
                    client:ConCommand("-speed")
                end
            elseif stamina < jumpReq then
                client:SetVelocity(Vector(0, 0, 0))
                return false
            end
        end
    end

    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then
            wep:Pickup()
        elseif IsValid(client.Grabbed) then
            client:DropObject(client.Grabbed)
            client.Grabbed = NULL
        end
    end
end

function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartsWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

function GM:GetGameDescription()
    return istable(SCHEMA) and tostring(SCHEMA.name) or L("defaultGameDescription")
end

function GM:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    client:Give("lia_hands")
    client:SetupHands()
    local savedGroups = character:getBodygroups()
    lia.util.applyBodygroups(client, savedGroups)
    client:SetSkin(character:getSkin())
    client:setLocalVar("VoiceType", VOICE_TALKING)
end

function GM:DoPlayerDeath(client, attacker)
    client:AddDeaths(1)
    local existingRagdoll = client:GetRagdollEntity()
    if IsValid(existingRagdoll) then
        existingRagdoll.liaIsDeadRagdoll = true
        existingRagdoll.liaNoReset = true
        existingRagdoll:CallOnRemove("deadRagdoll", function() existingRagdoll.liaIgnoreDelete = true end)
        client.diedInRagdoll = true
    end

    timer.Simple(0, function()
        if not IsValid(client) then return end
        local deathRagdoll = client:GetRagdollEntity()
        if IsValid(deathRagdoll) then client:setNetVar("ragdoll", deathRagdoll) end
    end)

    if IsValid(attacker) and attacker:IsPlayer() then
        if client == attacker then
            attacker:AddFrags(-1)
        else
            attacker:AddFrags(1)
        end
    end

    client:SetDSP(31, false)
end

function GM:PlayerSpawn(client)
    client:stopAction()
    client:SetDSP(1, false)
    if not client.diedInRagdoll then
        client:removeRagdoll()
    else
        client.diedInRagdoll = nil
    end

    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        if IsValid(ent) and ent:getNetVar("player") == client then ent:Remove() end
    end

    if not client:getChar() then client:SetNoDraw(true) end
    hook.Run("PlayerLoadout", client)
end

function GM:PreCleanupMap()
    lia.shuttingDown = true
    hook.Run("SaveData")
    lia.config.save()
    hook.Run("PersistenceSave")
end

function GM:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    lia.config.save()
    for _, v in player.Iterator() do
        v:saveLiliaData()
        if v:getChar() then v:getChar():save() end
    end

    lia.admin.save(true)
end

function GM:PlayerAuthed(client, steamid)
    lia.db.selectOne({"userGroup"}, "players", "steamID = " .. lia.db.convertDataType(steamid)):next(function(data)
        if not IsValid(client) then return end
        local group = data and data.userGroup
        if not lia.admin.isValidGroup(group) then
            group = lia.admin.getDefaultUserGroup()
            lia.db.query(Format("UPDATE lia_players SET userGroup = '%s' WHERE steamID = %s", lia.db.escape(group), lia.db.convertDataType(steamid)))
        end

        lia.debug("[Permissions]", "PlayerAuthed applying stored usergroup", "player=", tostring(client:Nick()) .. " (" .. tostring(steamid) .. ")", "storedGroup=", tostring(group), "isDefaultGroup=", tostring(lia.admin.DefaultGroups and lia.admin.DefaultGroups[group] ~= nil), "groupExistsInLilia=", tostring(lia.admin.groups and lia.admin.groups[group] ~= nil))
        client:SetUserGroup(group)
        lia.db.selectOne({"reason"}, "bans", "playerSteamID = " .. lia.db.convertDataType(steamid)):next(function(banData)
            if not IsValid(client) or not banData then return end
            local reason = banData.reason
            client:Kick(L("banMessage", 0, reason or L("genericReason")))
        end)
    end)
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()
    if character then
        hook.Run("OnCharDisconnect", client, character)
        lia.char.unloadCharacter(character:getID())
    end

    client:removeRagdoll()
    lia.char.cleanUpForPlayer(client)
    client.liaVoiceHear = nil
    if lia.config.get("DeleteDroppedItemsOnLeave", false) then
        local droppedItems = lia.util.findPlayerItems(client)
        for _, item in ipairs(droppedItems) do
            if IsValid(item) and item:isItem() then
                item.liaIsSafe = true
                SafeRemoveEntity(item)
            end
        end
    end

    if lia.config.get("DeleteEntitiesOnLeave", true) then
        for _, entity in ents.Iterator() do
            if entity:GetCreator() == client and not string.StartsWith(entity:GetClass(), "lia_") then SafeRemoveEntity(entity) end
        end
    end
end

--[[
    Hooks:
        PlayerLiliaDataLoaded(Player client)

    Purpose:
        Runs after a player's stored Lilia data finishes loading so modules can continue initialization work that depends on that data.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose Lilia data has just finished loading.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PlayerLiliaDataLoaded", "liaExamplePlayerLiliaDataLoaded", function(client)
            if IsValid(client) then
                print("Loaded Lilia data for", client:Nick())
            end
        end)
        ```

    Realm:
        Server
]]
function GM:PlayerInitialSpawn(client)
    if client:IsBot() then
        hook.Run("SetupBotPlayer", client)
        return
    end

    client:SetNoDraw(true)
    lia.config.send(client)
    client.liaJoinTime = RealTime()
    lia.admin.sync(client)
    client:loadLiliaData(function(data)
        if not IsValid(client) then return end
        local address = client:IPAddress()
        client:setLiliaData("lastIP", address)
        lia.db.updateTable({
            lastIP = address
        }, nil, "players", "steamID = " .. lia.db.convertDataType(client:SteamID()))

        net.Start("liaDataSync")
        net.WriteTable(data)
        net.WriteType(client.firstJoin)
        net.WriteType(client.lastJoin)
        net.Send(client)
        for _, v in pairs(lia.item.instances) do
            if v.entity and v.invID == 0 then v:sync(client) end
        end

        timer.Simple(1, function() lia.playerinteract.sync(client) end)
        timer.Simple(2, function() lia.dialog.syncToClients(client) end)
        timer.Simple(3, function() if IsValid(client) then lia.doors.syncAllDoorsToClient(client) end end)
        timer.Simple(4, function()
            net.Start("liaWeaponOverrideSync")
            net.WriteBool(true)
            net.WriteTable(lia.item.WeaponOverrides)
            net.Send(client)
        end)

        timer.Simple(5, function()
            if not IsValid(client) then return end
            net.Start("liaWeaponRuntimeOverrideSync")
            net.WriteBool(true)
            net.WriteTable(lia.item.WeaponRuntimeOverrides)
            net.Send(client)
        end)

        hook.Run("PlayerLiliaDataLoaded", client)
        net.Start("liaAssureClientSideAssets")
        net.Send(client)
    end)

    hook.Run("PostPlayerInitialSpawn", client)
end

function GM:PlayerLoadout(client)
    local character = client:getChar()
    if client.liaSkipLoadout then
        client.liaSkipLoadout = nil
        return
    end

    if not character then return end
    client:SetNoDraw(false)
    client:SetWeaponColor(Vector(0.30, 0.80, 0.10))
    client:StripWeapons()
    client:SetModel(character:getModel())
    lia.flag.onSpawn(client)
    hook.Run("PostPlayerLoadout", client)
    client:SelectWeapon("lia_hands")
    timer.Simple(0.5, function()
        if IsValid(client) and client:getChar() == character then
            client:SetWalkSpeed(lia.config.get("WalkSpeed"))
            client:SetRunSpeed(lia.config.get("RunSpeed"))
            client:SetJumpPower(160)
        end
    end)
end

function GM:CreateDefaultInventory(character)
    local invType = hook.Run("GetDefaultInventoryType", character) or "GridInv"
    local charID = character:getID()
    return lia.inventory.instance(invType, {
        char = charID
    })
end

local botFactionRotationIndex = 0
local botClassRotationByFaction = {}
local function getBotEligibleFactions()
    local factions = {}
    for _, faction in pairs(lia.faction.indices) do
        if faction and faction.index and faction.uniqueID ~= "staff" then factions[#factions + 1] = faction end
    end

    table.sort(factions, function(a, b) return a.index < b.index end)
    return factions
end

local function getBotClassesForFaction(factionIndex)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class and class.index and class.faction == factionIndex then classes[#classes + 1] = class end
    end

    table.sort(classes, function(a, b) return a.index < b.index end)
    return classes
end

local function getNextBotFactionAndClass()
    local factions = getBotEligibleFactions()
    if #factions == 0 then return nil, nil end
    botFactionRotationIndex = (botFactionRotationIndex % #factions) + 1
    local faction = factions[botFactionRotationIndex]
    local classes = getBotClassesForFaction(faction.index)
    if #classes == 0 then return faction, nil end
    local nextClassIndex = (botClassRotationByFaction[faction.index] or 0) % #classes + 1
    botClassRotationByFaction[faction.index] = nextClassIndex
    return faction, classes[nextClassIndex]
end

function GM:SetupBotPlayer(client)
    local botID = os.time()
    local faction, selectedClass = getNextBotFactionAndClass()
    if not faction then return end
    local invType = hook.Run("GetDefaultInventoryType") or "GridInv"
    if not invType then return end
    local inventory = lia.inventory.new(invType)
    local model = hook.Run("GetBotModel", client, faction) or "models/player/phoenix.mdl"
    local character = lia.char.new({
        name = lia.util.generateRandomName(),
        faction = faction and faction.uniqueID or "unknown",
        desc = L("botDesc", botID),
        model = model,
    }, botID, client, client:SteamID())

    character.isBot = true
    character.vars.inv = {}
    inventory.id = "bot" .. character:getID()
    inventory.data = inventory.data or {}
    inventory.data.char = character:getID()
    character.vars.inv[1] = inventory
    lia.inventory.instances[inventory.id] = inventory
    lia.char.addCharacter(botID, character)
    client:setNetVar("char", botID)
    character:setup()
    if selectedClass then
        character:setClass(selectedClass.index)
    else
        local defaultClass = lia.faction.getDefaultClass(faction.index)
        if defaultClass then character:setClass(defaultClass.index) end
    end

    character:sync()
    local randomMoney = math.random(1000, 10000)
    character:setMoney(randomMoney)
    client:Spawn()
    timer.Simple(0.1, function() if IsValid(client) and client:IsBot() and client:getChar() then hook.Run("PlayerLoadedChar", client, client:getChar(), nil) end end)
    hook.Run("PostBotSetup", client, character, inventory)
end

function GM:PlayerShouldTakeDamage(client)
    return client:getChar() ~= nil
end

function GM:CanDrive()
    return false
end

function GM:PlayerDeathThink()
    return false
end

local function makeKey(ent)
    local class
    local pos
    if IsEntity(ent) then
        class = ent.class or ent:GetClass()
        pos = ent.pos or ent:GetPos()
    else
        class = ent.class
        if ent.pos then
            pos = lia.data.decode(ent.pos)
        elseif ent.GetPos then
            pos = ent:GetPos()
        end
    end

    if not (class and pos) then return "" end
    local tol = 1
    return string.format("%s_%.0f_%.0f_%.0f", class, pos.x / tol, pos.y / tol, pos.z / tol)
end

function GM:SaveData()
    local seen = {}
    local data = {}
    for _, ent in ents.Iterator() do
        if ent.IsPersistent and hook.Run("ShouldEntitySave", ent) ~= false then
            local key = makeKey(ent)
            if key ~= "" and not seen[key] then
                seen[key] = true
                local entPos = ent:GetPos()
                local entAng = ent:GetAngles()
                local entData = {
                    pos = entPos,
                    class = ent:GetClass(),
                    model = ent:GetModel(),
                    angles = entAng
                }

                local skin = ent:GetSkin()
                if skin and skin > 0 then entData.skin = skin end
                local bodygroups
                local bgCount = ent:GetNumBodyGroups() or 0
                for i = 0, bgCount - 1 do
                    local value = ent:GetBodygroup(i)
                    if value > 0 then
                        bodygroups = bodygroups or {}
                        bodygroups[i] = value
                    end
                end

                if bodygroups then entData.bodygroups = bodygroups end
                local extra = hook.Run("GetEntitySaveData", ent)
                if extra ~= nil then entData.data = extra end
                data[#data + 1] = entData
                hook.Run("OnEntityPersisted", ent, entData)
            end
        end
    end

    if #data > 0 then
        lia.data.savePersistence(data)
        lia.information(L("saved"))
    end
end

local function IsEntityNearby(pos, class)
    for _, ent in ipairs(ents.FindByClass(class)) do
        if ent:GetPos():DistToSqr(pos) <= 2500 then return true end
    end
    return false
end

local function restorePersistentEntityTransform(ent, pos, ang)
    if not IsValid(ent) or not isvector(pos) then return end
    ent:SetPos(pos)
    if isangle(ang) then ent:SetAngles(ang) end
    local physObj = ent:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:SetPos(pos)
        if isangle(ang) then physObj:SetAngles(ang) end
        physObj:Wake()
        physObj:Sleep()
    end
end

function GM:LoadData()
    lia.data.loadPersistenceData(function(entities)
        for _, ent in ipairs(entities) do
            if hook.Run("ShouldEntityLoad", ent) == false then continue end
            repeat
                local cls = ent.class
                if not isstring(cls) or cls == "" then
                    lia.error(L("invalidEntityClass"))
                    break
                end

                local decodedPos = lia.data.decode(ent.pos)
                local decodedAng = lia.data.decode(ent.angles)
                if not decodedPos then
                    lia.error(L("invalidEntityPosition", cls))
                    break
                end

                if IsEntityNearby(decodedPos, cls) then
                    lia.error(L("entityCreationAborted", cls, decodedPos.x, decodedPos.y, decodedPos.z))
                    break
                end

                local createdEnt = ents.Create(cls)
                if not IsValid(createdEnt) then
                    lia.error(L("failedEntityCreation", cls))
                    break
                end

                createdEnt:SetPos(decodedPos)
                if decodedAng then
                    if not isangle(decodedAng) then
                        if isvector(decodedAng) then
                            decodedAng = Angle(decodedAng.x, decodedAng.y, decodedAng.z)
                        elseif istable(decodedAng) then
                            local p = tonumber(decodedAng.p or decodedAng[1])
                            local yaw = tonumber(decodedAng.y or decodedAng[2])
                            local r = tonumber(decodedAng.r or decodedAng[3])
                            if p and yaw and r then
                                decodedAng = Angle(p, yaw, r)
                            else
                                decodedAng = angle_zero
                            end
                        else
                            decodedAng = angle_zero
                        end
                    end

                    if isangle(decodedAng) then
                        local ok, err = pcall(createdEnt.SetAngles, createdEnt, decodedAng)
                        if not ok then
                            lia.error(string.format("Failed to SetAngles for entity '%s' at %s. Angle: %s (%s) - %s", tostring(cls), tostring(decodedPos), tostring(decodedAng), type(decodedAng), err))
                            lia.error(debug.traceback())
                        end
                    else
                        lia.error(L("invalidAngleEntity", tostring(cls), tostring(decodedPos), tostring(decodedAng), type(decodedAng)))
                        lia.error(debug.traceback())
                    end
                end

                if ent.model then createdEnt:SetModel(ent.model) end
                createdEnt:Spawn()
                if ent.skin then createdEnt:SetSkin(tonumber(ent.skin) or 0) end
                if istable(ent.bodygroups) then lia.util.applyBodygroups(createdEnt, ent.bodygroups) end
                createdEnt:Activate()
                restorePersistentEntityTransform(createdEnt, decodedPos, decodedAng)
                local loadData = table.Copy(ent)
                if lia.dialog.isDialogNPCEntity(cls) and ent.data and istable(ent.data) then
                    if ent.data.uniqueID then loadData.uniqueID = ent.data.uniqueID end
                    if ent.data.npcName then loadData.npcName = ent.data.npcName end
                    loadData.data = {
                        customData = ent.data.customData
                    }
                elseif ent.data and istable(ent.data) and next(ent.data) then
                    for k, v in pairs(ent.data) do
                        loadData[k] = v
                    end
                end

                hook.Run("OnEntityLoaded", createdEnt, loadData)
                timer.Simple(0, function() restorePersistentEntityTransform(createdEnt, decodedPos, decodedAng) end)
            until true
        end
    end)

    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = lia.data.getEquivalencyMap(game.GetMap())
    local condition = "schema = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
    lia.db.select({"itemID", "pos", "angles"}, "saveditems", condition):next(function(res)
        local items = res.results or {}
        if #items > 0 then
            local idRange, positions, angles = {}, {}, {}
            for _, row in ipairs(items) do
                local id = tonumber(row.itemID)
                idRange[#idRange + 1] = id
                positions[id] = lia.data.decodeVector(row.pos)
                angles[id] = lia.data.decodeAngle(row.angles)
            end

            if #idRange > 0 then
                local range = "(" .. table.concat(idRange, ", ") .. ")"
                if hook.Run("ShouldDeleteSavedItems") == true then
                    lia.db.query("DELETE FROM lia_items WHERE itemID IN " .. range)
                    lia.information(L("serverDeletedItems"))
                else
                    lia.db.query("SELECT itemID, uniqueID, data FROM lia_items WHERE itemID IN " .. range, function(data)
                        if not data then return end
                        local loadedItems = {}
                        for _, row in ipairs(data) do
                            local itemID = tonumber(row.itemID)
                            local itemData = util.JSONToTable(row.data or "[]")
                            local uniqueID = row.uniqueID
                            local itemTable = lia.item.list[uniqueID]
                            local position = positions[itemID]
                            local ang = angles[itemID]
                            if itemTable and itemID and position then
                                if ang and not isangle(ang) then
                                    if isvector(ang) then
                                        ang = Angle(ang.x, ang.y, ang.z)
                                    elseif istable(ang) then
                                        local p = tonumber(ang.p or ang[1])
                                        local yaw = tonumber(ang.y or ang[2])
                                        local r = tonumber(ang.r or ang[3])
                                        if p and yaw and r then
                                            ang = Angle(p, yaw, r)
                                        else
                                            ang = angle_zero
                                        end
                                    else
                                        ang = angle_zero
                                    end
                                end

                                if not isangle(ang) then ang = angle_zero end
                                local itemCreated = lia.item.new(uniqueID, itemID)
                                itemCreated.data = itemData or {}
                                itemCreated:spawn(position, ang).liaItemID = itemID
                                itemCreated:onRestored()
                                itemCreated.invID = 0
                                loadedItems[#loadedItems + 1] = itemCreated
                            end
                        end

                        hook.Run("OnSavedItemLoaded", loadedItems)
                    end)
                end
            end
        end
    end)
end

function GM:OnEntityCreated(ent)
    if not IsValid(ent) or not ent.IsPersistent or hook.Run("ShouldEntitySave", ent) == false then return end
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        local saved = lia.data.getPersistence()
        local seen = {}
        for _, data in ipairs(saved) do
            seen[makeKey(data)] = true
        end

        local key = makeKey(ent)
        if seen[key] or hook.Run("ShouldEntitySave", ent) == false then return end
        local entData = {
            pos = ent:GetPos(),
            class = ent:GetClass(),
            model = ent:GetModel(),
            angles = ent:GetAngles()
        }

        local extra = hook.Run("GetEntitySaveData", ent)
        if extra ~= nil then entData.data = extra end
        saved[#saved + 1] = entData
        lia.data.savePersistence(saved)
        hook.Run("OnEntityPersisted", ent, entData)
    end)
end

function GM:UpdateEntityPersistence(ent)
    if not IsValid(ent) or not ent.IsPersistent or hook.Run("ShouldEntitySave", ent) == false then return end
    local saved = lia.data.getPersistence()
    local key = makeKey(ent)
    for _, data in ipairs(saved) do
        if makeKey(data) == key then
            data.pos = ent:GetPos()
            data.class = ent:GetClass()
            data.model = ent:GetModel()
            data.angles = ent:GetAngles()
            local extra = hook.Run("GetEntitySaveData", ent)
            if extra ~= nil then
                data.data = extra
            else
                data.data = nil
            end

            lia.data.savePersistence(saved)
            hook.Run("OnEntityPersistUpdated", ent, data)
            return
        end
    end
end

function GM:EntityRemoved(ent)
    if not IsValid(ent) or not ent.IsPersistent then return end
    local saved = lia.data.getPersistence()
    local key = makeKey(ent)
    for i, data in ipairs(saved) do
        if makeKey(data) == key then
            table.remove(saved, i)
            lia.data.savePersistence(saved)
            break
        end
    end
end

function GM:OnDatabaseLoaded()
    lia.db.addDatabaseFields()
    lia.data.loadTables()
    lia.data.loadPersistence()
    lia.admin.load()
    hook.Run("LoadData")
    hook.Run("PostLoadData")
    lia.faction.formatModelData()
    timer.Simple(2, function() lia.entityDataLoaded = true end)
end

function ClientAddText(client, ...)
    if not client or not IsValid(client) then
        lia.error(L("invalidClientChatAddText"))
        return
    end

    local args = {...}
    net.Start("liaServerChatAddText")
    net.WriteTable(args)
    net.Send(client)
end

function ClientAddTextShadowed(client, ...)
    if not client or not IsValid(client) then
        lia.error(L("invalidClientChatAddText"))
        return
    end

    local args = {...}
    net.Start("liaServerChatAddTextShadowed")
    net.WriteTable(args)
    net.Send(client)
end

function StaffAddTextShadowed(tagColor, tagText, messageColor, message, predicate)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    for _, staff in player.Iterator() do
        local isStaff = staff:isStaffOnDuty() or staff:hasPrivilege("canSeeLogs")
        lia.debug("[Permissions]", "Permission Check for function StaffAddTextShadowed", "targetStaff=", tostring(IsValid(staff) and staff:Name() or "unknown"), "isStaffOnDuty=", tostring(staff:isStaffOnDuty()), "hasPrivilege(canSeeLogs)=", tostring(staff:hasPrivilege("canSeeLogs")), "predicatePassed=", tostring(predicate and predicate(staff) or false), "finalResult=", tostring((predicate and predicate(staff)) or isStaff))
        if (predicate and predicate(staff)) or isStaff then ClientAddTextShadowed(staff, tagColor or Color(255, 255, 255), tagText or "", messageColor or Color(255, 255, 255), " | " .. timestamp .. " | " .. message) end
    end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
    if not IsValid(listener) or not IsValid(speaker) or listener == speaker then return false, false end
    if not lia.config.get("IsVoiceEnabled", true) then return false, false end
    local bCanHear = listener.liaVoiceHear and listener.liaVoiceHear[speaker]
    if not bCanHear then return false, false end
    local voiceType = speaker:getLocalVar("VoiceType", VOICE_TALKING)
    local is3D = voiceType ~= VOICE_YELLING
    return true, is3D
end

function GM:OnVoiceTypeChanged(client)
    if not IsValid(client) or not client:getChar() then return end
    CacheVoiceHearing()
end

function GM:CreateSalaryTimers()
    local defaultSalaryInterval = lia.config.get("SalaryInterval", 300)
    if hook.Run("ShouldOverrideSalaryTimers") == true then return end
    self.salaryTimerNames = self.salaryTimerNames or {}
    for _, timerName in ipairs(self.salaryTimerNames) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end

    self.salaryTimerNames = {}
    if timer.Exists("liaSalaryGlobal") then timer.Remove("liaSalaryGlobal") end
    local function getSalaryInterval(faction, class)
        local classInterval = class and class.payTimer
        if isnumber(classInterval) and classInterval > 0 then return classInterval end
        local factionInterval = faction and faction.payTimer
        if isnumber(factionInterval) and factionInterval > 0 then return factionInterval end
        return defaultSalaryInterval
    end

    local salaryIntervals = {}
    for uniqueID, faction in pairs(lia.faction.teams) do
        local legacyTimerName = "liaSalaryFaction_" .. uniqueID
        if timer.Exists(legacyTimerName) then timer.Remove(legacyTimerName) end
        local factionInterval = getSalaryInterval(faction)
        if isnumber(factionInterval) and factionInterval > 0 then salaryIntervals[factionInterval] = true end
    end

    for _, class in pairs(lia.class.list) do
        local faction = lia.faction.indices[class.faction]
        local classInterval = getSalaryInterval(faction, class)
        if isnumber(classInterval) and classInterval > 0 then salaryIntervals[classInterval] = true end
    end

    for interval in pairs(salaryIntervals) do
        local timerName = "liaSalaryInterval_" .. tostring(interval):gsub("[^%w]", "_")
        local salaryTimer = function()
            for _, client in player.Iterator() do
                if IsValid(client) and client:getChar() and hook.Run("CanPlayerEarnSalary", client) ~= false then
                    local char = client:getChar()
                    local charFaction = lia.faction.indices[char:getFaction()]
                    local class = lia.class.list[char:getClass()]
                    if charFaction and getSalaryInterval(charFaction, class) == interval then
                        local pay = hook.Run("GetSalaryAmount", client, charFaction, class)
                        pay = isnumber(pay) and pay or class and class.pay or charFaction and charFaction.pay or 0
                        local adjustedPay = hook.Run("OnSalaryAdjust", client)
                        if isnumber(adjustedPay) then pay = adjustedPay end
                        local prestigeBonus = hook.Run("GetPrestigePayBonus", client, char, pay, charFaction, class)
                        if isnumber(prestigeBonus) then pay = pay + prestigeBonus end
                        if pay > 0 then
                            local handled = hook.Run("PreSalaryGive", client, char, pay, charFaction, class)
                            if handled ~= true then
                                local finalPay = hook.Run("OnSalaryGiven", client, char, pay, charFaction, class)
                                if isnumber(finalPay) then pay = finalPay end
                                char:giveMoney(pay)
                                client:notifyMoneyLocalized("salary", lia.currency.get(pay), L("salaryWord"))
                            end
                        end
                    end
                end
            end
        end

        timer.Create(timerName, interval, 0, salaryTimer)
        self.salaryTimerNames[#self.salaryTimerNames + 1] = timerName
    end
end

function GM:ShowHelp()
    return false
end

function GM:PlayerSpray()
    return true
end

function GM:PlayerDeathSound()
    return true
end

function GM:CanPlayerSuicide()
    return false
end

function GM:AllowPlayerPickup()
    return false
end

local oldRunConsole = RunConsoleCommand
RunConsoleCommand = function(cmd, ...)
    if cmd == "lia_wipedb" or cmd == "lia_resetconfig" or cmd == "lia_wipe_sounds" or cmd == "lia_wipewebimages" or cmd == "lia_wipecharacters" or cmd == "lia_wipelogs" or cmd == "lia_wipebans" or cmd == "lia_wipepersistence" then return end
    return oldRunConsole(cmd, ...)
end

local oldGameConsoleCommand = game.ConsoleCommand
game.ConsoleCommand = function(cmd)
    if cmd:sub(1, #"lia_wipedb") == "lia_wipedb" or cmd:sub(1, #"lia_resetconfig") == "lia_resetconfig" or cmd:sub(1, #"lia_wipe_sounds") == "lia_wipe_sounds" or cmd:sub(1, #"lia_wipewebimages") == "lia_wipewebimages" or cmd:sub(1, #"lia_wipecharacters") == "lia_wipecharacters" or cmd:sub(1, #"lia_wipelogs") == "lia_wipelogs" or cmd:sub(1, #"lia_wipebans") == "lia_wipebans" or cmd:sub(1, #"lia_wipepersistence") == "lia_wipepersistence" then return end
    return oldGameConsoleCommand(cmd)
end

function GM:GetEntitySaveData(ent)
    if lia.dialog.isDialogNPCEntity(ent) then
        local saveData = {
            uniqueID = ent.uniqueID or "",
            npcName = ent.NPCName or ""
        }

        if ent.customData then saveData.customData = ent.customData end
        return saveData
    end
end

function GM:OnEntityLoaded(ent, data)
    if lia.dialog.isDialogNPCEntity(ent) and data and data.uniqueID and data.uniqueID ~= "" then
        ent.uniqueID = data.uniqueID
        ent.NPCName = data.npcName or "NPC"
        local npcData = lia.dialog.getNPCData(data.uniqueID)
        local hasCustomModel = data.data and data.data.customData and data.data.customData.model and data.data.customData.model ~= ""
        if npcData then
            if not hasCustomModel then ent:SetModel("models/Barney.mdl") end
            if npcData.BodyGroups and istable(npcData.BodyGroups) then lia.util.applyBodygroups(ent, npcData.BodyGroups) end
            if npcData.Skin then ent:SetSkin(npcData.Skin) end
        end

        if data.data and data.data.customData and istable(data.data.customData) then
            ent.customData = data.data.customData
            if data.data.customData.name and data.data.customData.name ~= "" then ent.NPCName = data.data.customData.name end
            if data.data.customData.model and data.data.customData.model ~= "" then ent:SetModel(data.data.customData.model) end
            if data.data.customData.skin then ent:SetSkin(tonumber(data.data.customData.skin) or 0) end
            if data.data.customData.bodygroups and istable(data.data.customData.bodygroups) then lia.util.applyBodygroups(ent, data.data.customData.bodygroups) end
        end

        if data.data and data.data.customData and data.data.customData.animation and data.data.customData.animation ~= "auto" then
            local sequenceIndex = ent:LookupSequence(data.data.customData.animation)
            if sequenceIndex >= 0 then
                ent.customAnimation = data.data.customData.animation
                ent:ResetSequence(sequenceIndex)
            else
                ent.customAnimation = nil
                data.data.customData.animation = "auto"
            end
        else
            ent.customAnimation = nil
        end

        ent:setNetVar("uniqueID", data.uniqueID)
        ent:setNetVar("NPCName", ent.NPCName)
        if not ent.NPCName or ent.NPCName == "" then ent.NPCName = ent:getNetVar("NPCName", "NPC") end
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetSolid(SOLID_OBB)
        ent:PhysicsInit(SOLID_OBB)
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        local physObj = ent:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        ent:setAnim()
    end
end

gameevent.Listen("server_addban")
gameevent.Listen("server_removeban")
hook.Add("server_addban", "LiliaLogServerBan", function(data)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("admin") .. "] ")
    MsgC(Color(255, 153, 0), L("banLogFormat", data.name, data.networkid, data.ban_length, data.ban_reason), "\n")
    lia.db.insertTable({
        player = data.name or "",
        playerSteamID = data.networkid,
        reason = data.ban_reason or "",
        bannerName = "",
        bannerSteamID = "",
        timestamp = os.time(),
        evidence = ""
    }, nil, "bans")
end)

hook.Add("server_removeban", "LiliaLogServerUnban", function(data)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("admin") .. "] ")
    MsgC(Color(255, 153, 0), L("unbanLogFormat", data.networkid), "\n")
    lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(data.networkid))
end)

function GM:CanEditVariable()
    return false
end

if timer.Exists("CheckHookTimes") then timer.Remove("CheckHookTimes") end
timer.Remove("HostnameThink")
