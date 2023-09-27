
-- luacheck: ignore 111

--[[--
Global hooks for general use.

Plugin hooks are regular hooks that can be used in your schema with `Schema:HookName(args)`, in your plugin with
`PLUGIN:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
]]
-- @hooks Plugin

--- Adjusts the data used just before creating a new character.

-- @player client Player that is creating the character
-- @tab payload Table of data to be used for character creation
-- @tab newPayload Table of data be merged with the current payload
-- @usage function PLUGIN:AdjustCreationPayload(client, payload, newPayload)
-- 	newPayload.money = payload.attributes["stm"] -- Sets the characters initial money to the stamina attribute value.
-- end
function AdjustCreationPayload(client, payload, newPayload)
end

--- Adjusts a player's current stamina offset amount. This is called when the player's stamina is about to be changed; every
-- `0.25` seconds on the server, and every frame on the client.

-- @player client Player whose stamina is changing
-- @number baseOffset Amount the stamina is changing by. This can be a positive or negative number depending if they are
-- exhausting or regaining stamina
-- @treturn number New offset to use
-- @usage function PLUGIN:AdjustStaminaOffset(client, baseOffset)
-- 	return baseOffset * 2 -- Drain/Regain stamina twice as fast.
-- end
function AdjustStaminaOffset(client, baseOffset)
end

--- Creates the business panel in the tab menu.

-- @treturn bool Whether or not to create the business menu
-- @usage function PLUGIN:BuildBusinessMenu()
-- 	return LocalPlayer():IsAdmin() -- Only builds the business menu for admins.
-- end
function BuildBusinessMenu()
end

--- Whether or not a message can be auto formatted with punctuation and capitalization.

-- @player speaker Player that sent the message
-- @string chatType Chat type of the message. This will be something registered with `ix.chat.Register` - like `ic`, `ooc`, etc.
-- @string text Unformatted text of the message
-- @treturn bool Whether or not to allow auto formatting on the message
-- @usage function PLUGIN:CanAutoFormatMessage(speaker, chatType, text)
-- 	return false -- Disable auto formatting outright.
-- end
function CanAutoFormatMessage(speaker, chatType, text)
end

--- Whether or not certain information can be displayed in the character info panel in the tab menu.

-- @tab suppress Information to **NOT** display in the UI - modify this to change the behaviour. This is a table of the names of
-- some panels to avoid displaying. Valid names include:
--
-- - `time` - current in-game time
-- - `name` - name of the character
-- - `description` - description of the character
-- - `characterInfo` - entire panel showing a list of additional character info
-- - `faction` - faction name of the character
-- - `class` - name of the character's class if they're in one
-- - `money` - current money the character has
-- - `attributes` - attributes list for the character
--
-- Note that schemas/plugins can add additional character info panels.
-- @usage function PLUGIN:CanCreateCharacterInfo(suppress)
-- 	suppress.attributes = true -- Hides the attributes panel from the character info tab
-- end
function CanCreateCharacterInfo(suppress)
end

--- Whether or not the ammo HUD should be drawn.

-- @entity weapon Weapon the player currently is holding
-- @treturn bool Whether or not to draw the ammo hud
-- @usage function PLUGIN:CanDrawAmmoHUD(weapon)
-- 	if (weapon:GetClass() == "weapon_frag") then -- Hides the ammo hud when holding grenades.
-- 		return false
-- 	end
-- end
function CanDrawAmmoHUD(weapon)
end

--- Called when a player tries to use abilities on the door, such as locking.

-- @player client The client trying something on the door.
-- @entity door The door entity itself.
-- @number access The access level used when called.
-- @treturn bool Whether or not to allow the client access.
-- @usage function PLUGIN:CanPlayerAccessDoor(client, door, access)
-- 	return true -- Always allow access.
-- end
function CanPlayerAccessDoor(client, door, access)
end

--- Whether or not a player is allowed to combine an item `other` into the given `item`.

-- @player client Player attempting to combine an item into another
-- @number item instance ID of the item being dropped onto
-- @number other instance ID of the item being combined into the first item, this can be invalid due to it being from clientside
-- @treturn bool Whether or not to allow the player to combine the items
-- @usage function PLUGIN:CanPlayerCombineItem(client, item, other)
--		local otherItem = ix.item.instances[other]
--
--		if (otherItem and otherItem.uniqueID == "soda") then
--			return false -- disallow combining any item that has a uniqueID equal to `soda`
--		end
--	end
function CanPlayerCombineItem(client, item, other)
end

--- Whether or not a player is allowed to create a new character with the given payload.

-- @player client Player attempting to create a new character
-- @tab payload Data that is going to be used for creating the character
-- @treturn bool Whether or not the player is allowed to create the character. This function defaults to `true`, so you
-- should only ever return `false` if you're disallowing creation. Otherwise, don't return anything as you'll prevent any other
-- calls to this hook from running.
-- @treturn string Language phrase to use for the error message
-- @treturn ... Arguments to use for the language phrase
-- @usage function PLUGIN:CanPlayerCreateCharacter(client, payload)
-- 	if (!client:IsAdmin()) then
-- 		return false, "notNow" -- only allow admins to create a character
-- 	end
-- end
-- -- non-admins will see the message "You are not allowed to do this right now!"
function CanPlayerCreateCharacter(client, payload)
end

--- Whether or not a player is allowed to drop the given `item`.

-- @player client Player attempting to drop an item
-- @number item instance ID of the item being dropped
-- @treturn bool Whether or not to allow the player to drop the item
-- @usage function PLUGIN:CanPlayerDropItem(client, item)
-- 	return false -- Never allow dropping items.
-- end
function CanPlayerDropItem(client, item)
end

--- Whether or not a player can earn money at regular intervals. This hook runs only if the player's character faction has
-- a salary set - i.e `FACTION.pay` is set to something other than `0` for their faction.

-- @player client Player to give money to
-- @tab faction Faction of the player's character
-- @treturn bool Whether or not to allow the player to earn salary
-- @usage function PLUGIN:CanPlayerEarnSalary(client, faction)
-- 	return client:IsAdmin() -- Restricts earning salary to admins only.
-- end
function CanPlayerEarnSalary(client, faction)
end

--- Whether or not the player is allowed to enter observer mode. This is allowed only for admins by default and can be
-- customized by server owners if the server is using a CAMI-compliant admin mod.

-- @player client Player attempting to enter observer
-- @treturn bool Whether or not to allow the player to enter observer
-- @usage function PLUGIN:CanPlayerEnterObserver(client)
-- 	return true -- Always allow observer.
-- end
function CanPlayerEnterObserver(client)
end

--- Whether or not a player can equip the given `item`. This is called for items with `outfit`, `pacoutfit`, or `weapons` as
-- their base. Schemas/plugins can utilize this hook for their items.

-- @player client Player attempting to equip the item
-- @tab item Item being equipped
-- @treturn bool Whether or not to allow the player to equip the item
-- @usage function PLUGIN:CanPlayerEquipItem(client, item)
-- 	return client:IsAdmin() -- Restrict equipping items to admins only.
-- end
function CanPlayerEquipItem(client, item)
end

--- Whether or not a player is allowed to hold an entity with the hands SWEP.

-- @player client Player attempting to hold an entity
-- @entity entity Entity being held
-- @treturn bool Whether or not to allow the player to hold the entity
-- @usage function PLUGIN:CanPlayerHoldObject(client, entity)
-- 	return !(client:GetMoveType() == MOVETYPE_NOCLIP and !client:InVehicle()) -- Disallow players in observer holding objects.
-- end
function CanPlayerHoldObject(client, entity)
end

--- Whether or not a player is allowed to interact with an entity's interaction menu if it has one.

-- @player client Player attempting interaction
-- @entity entity Entity being interacted with
-- @string option Option selected by the player
-- @param data Any data passed with the interaction option
-- @treturn bool Whether or not to allow the player to interact with the entity
-- @usage function PLUGIN:CanPlayerInteractEntity(client, entity, option, data)
-- 	return false -- Disallow interacting with any entity.
-- end
function CanPlayerInteractEntity(client, entity, option, data)
end

--- Whether or not a player is allowed to interact with an item via an inventory action (e.g picking up, dropping, transferring
-- inventories, etc). Note that this is for an item *table*, not an item *entity*. This is called after `CanPlayerDropItem`
-- and `CanPlayerTakeItem`.

-- @player client Player attempting interaction
-- @string action The action being performed
-- @param item Item's instance ID or item table
-- @param data Any data passed with the action
-- @treturn bool Whether or not to allow the player to interact with the item
-- @usage function PLUGIN:CanPlayerInteractItem(client, action, item, data)
-- 	return false -- Disallow interacting with any item.
-- end
function CanPlayerInteractItem(client, action, item, data)
end

--- Whether or not a plyer is allowed to join a class.

-- @player client Player attempting to join
-- @number class ID of the class
-- @tab info The class table
-- @treturn bool Whether or not to allow the player to join the class
-- @usage function PLUGIN:CanPlayerJoinClass(client, class, info)
-- 	return client:IsAdmin() -- Restrict joining classes to admins only.
-- end
function CanPlayerJoinClass(client, class, info)
end

--- Whether or not a player can knock on the door with the hands SWEP.

-- @player client Player attempting to knock
-- @entity entity Door being knocked on
-- @treturn bool Whether or not to allow the player to knock on the door
-- @usage function PLUGIN:CanPlayerKnock(client, entity)
-- 	return false -- Disable knocking on doors outright.
-- end
function CanPlayerKnock(client, entity)
end

--- Whether or not a player can open a shipment spawned from the business menu.

-- @player client Player attempting to open the shipment
-- @entity entity Shipment entity
-- @treturn bool Whether or not to allow the player to open the shipment
-- @usage function PLUGIN:CanPlayerOpenShipment(client, entity)
-- 	return client:Team() == FACTION_BMD -- Restricts opening shipments to FACTION_BMD.
-- end
function CanPlayerOpenShipment(client, entity)
end

--- Whether or not a player is allowed to spawn a container entity.

-- @player client Player attempting to spawn a container
-- @string model Model of the container being spawned
-- @entity entity Container entity
-- @treturn bool Whether or not to allow the player to spawn the container
-- @usage function PLUGIN:CanPlayerSpawnContainer(client, model, entity)
-- 	return client:IsAdmin() -- Restrict spawning containers to admins.
-- end
function CanPlayerSpawnContainer(client, model, entity)
end

--- Whether or not a player is allowed to take an item and put it in their inventory.

-- @player client Player attempting to take the item
-- @entity item Entity corresponding to the item
-- @treturn bool Whether or not to allow the player to take the item
-- @usage function PLUGIN:CanPlayerTakeItem(client, item)
-- 	return !(client:GetMoveType() == MOVETYPE_NOCLIP and !client:InVehicle()) -- Disallow players in observer taking items.
-- end
function CanPlayerTakeItem(client, item)
end

--- Whether or not the player is allowed to punch with the hands SWEP.

-- @player client Player attempting throw a punch
-- @treturn bool Whether or not to allow the player to punch
-- @usage function PLUGIN:CanPlayerThrowPunch(client)
-- 	return client:GetCharacter():GetAttribute("str", 0) > 0 -- Only allow players with strength to punch.
-- end
function CanPlayerThrowPunch(client)
end

--- Whether or not a player can trade with a vendor.

-- @player client Player attempting to trade
-- @entity entity Vendor entity
-- @string uniqueID The uniqueID of the item being traded.
-- @bool isSellingToVendor If the client is selling to the vendor
-- @treturn bool Whether or not to allow the client to trade with the vendor
-- @usage function PLUGIN:CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
-- 	return false -- Disallow trading with vendors outright.
-- end
function CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
end

--- Whether or not a player can unequip an item.

-- @player client Player attempting to unequip an item
-- @tab item Item being unequipped
-- @treturn bool Whether or not to allow the player to unequip the item
-- @usage function PLUGIN:CanPlayerUnequipItem(client, item)
-- 	return false -- Disallow unequipping items.
-- end
function CanPlayerUnequipItem(client, item)
end


function CanPlayerUseBusiness(client, uniqueID)
end


function CanPlayerUseCharacter(client, character)
end


function CanPlayerUseDoor(client, entity)
end


function CanPlayerUseVendor(activator)
end


function CanPlayerViewInventory()
end


function CanSaveContainer(entity, inventory)
end


function CanTransferItem(item, currentInv, oldInv)
end


function CharacterAttributeBoosted(client, character, attribID, boostID, boostAmount)
end


function CharacterAttributeUpdated(client, self, key, value)
end


function CharacterDeleted(client, id, isCurrentChar)
end


function CharacterHasFlags(self, flags)
end


function CharacterLoaded(character)
end


function CharacterPostSave(character)
end


function CharacterPreSave(character)
end


function CharacterRecognized()
end


function CharacterRestored(character)
end


function CharacterVarChanged(character, key, oldVar, value)
end


function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
end


function ChatboxCreated()
end


function ChatboxPositionChanged(x, y, width, height)
end


function ColorSchemeChanged(color)
end


function ContainerRemoved(container, inventory)
end


function CreateCharacterInfo(panel)
end


function CreateCharacterInfoCategory(panel)
end


function CreateItemInteractionMenu(icon, menu, itemTable)
end


function CreateMenuButtons(tabs)
end


function CreateShipment(client, entity)
end


function DatabaseConnected()
end


function DatabaseConnectionFailed(error)
end


function DoPluginIncludes(path, pluginTable)
end


function DrawCharacterOverview()
end


function DrawHelixModelView(panel, entity)
end


function DrawPlayerRagdoll(entity)
end


function GetCharacterDescription(client)
end


function GetCharacterName(speaker, chatType)
end


function GetChatPrefixInfo(text)
end


function GetCrosshairAlpha(curAlpha)
end


function GetDefaultAttributePoints(client, count)
end


function GetDefaultCharacterName(client, faction)
end


function GetMaxPlayerCharacter(client)
end

--- Returns the sound to emit from the player upon death. If nothing is returned then it will use the default male/female death
-- sounds.

-- @player client Player that died
-- @treturn[1] string Sound to play
-- @treturn[2] bool `false` if a sound shouldn't be played at all
-- @usage function PLUGIN:GetPlayerDeathSound(client)
-- 	-- play impact sound every time someone dies
-- 	return "physics/body/body_medium_impact_hard1.wav"
-- end
-- @usage function PLUGIN:GetPlayerDeathSound(client)
-- 	-- don't play a sound at all
-- 	return false
-- end
function GetPlayerDeathSound(client)
end


function GetPlayerEntityMenu(client, options)
end


function GetPlayerIcon(speaker)
end


function GetPlayerPainSound(client)
end


function GetPlayerPunchDamage(client, damage, context)
end


function GetSalaryAmount(client, faction)
end


function GetTypingIndicator(character, text)
end

--- Registers chat classes after the core framework chat classes have been registered. You should usually create your chat
-- classes in this hook - especially if you want to reference the properties of a framework chat class.

-- @usage function PLUGIN:InitializedChatClasses()
-- 	-- let's say you wanted to reference an existing chat class's color
-- 	ix.chat.Register("myclass", {
-- 		format = "%s says \"%s\"",
-- 		GetColor = function(self, speaker, text)
-- 			-- make the chat class slightly brighter than the "ic" chat class
-- 			local color = ix.chat.classes.ic:GetColor(speaker, text)
--
-- 			return Color(color.r + 35, color.g + 35, color.b + 35)
-- 		end,
-- 		-- etc.
-- 	})
-- end

function InitializedChatClasses()
end


function InitializedConfig()
end


function InitializedPlugins()
end


function InitializedSchema()
end


function InventoryItemAdded(oldInv, inventory, item)
end


function InventoryItemRemoved(inventory, item)
end


function IsCharacterRecognized(character, id)
end


function IsPlayerRecognized(client)
end


function IsRecognizedChatType(chatType)
end


function LoadData()
end


function LoadFonts(font, genericFont)
end


function LoadIntro()
end


function MenuSubpanelCreated(subpanelName, panel)
end


function MessageReceived(client, info)
end


function OnAreaChanged(oldID, newID)
end


function OnCharacterCreated(client, character)
end


function OnCharacterDisconnect(client, character)
end


function OnCharacterFallover(client, entity, bFallenOver)
end

--- Called when a character has gotten up from the ground.

-- @player client Player that has gotten up
-- @entity ragdoll Ragdoll used to represent the player
function OnCharacterGetup(client, ragdoll)
end


function OnCharacterMenuCreated(panel)
end

--- Called whenever an item entity has spawned in the world. You can access the entity's item table with
-- `entity:GetItemTable()`.

-- @entity entity Spawned item entity
-- @usage function PLUGIN:OnItemSpawned(entity)
-- 	local item = entity:GetItemTable()
-- 	-- do something with the item here
-- end
function OnItemSpawned(entity)
end


function OnItemTransferred(item, curInv, inventory)
end


function OnLocalVarSet(key, var)
end


function OnPAC3PartTransferred(part)
end


function OnPickupMoney(client, self)
end


function OnPlayerAreaChanged(client, oldID, newID)
end


function OnPlayerObserve(client, state)
end


function OnPlayerOptionSelected(client, callingClient, option)
end


function OnPlayerPurchaseDoor(client, entity, bBuying, bCallOnDoorChild)
end


function OnPlayerRestricted(client)
end


function OnPlayerUnRestricted(client)
end


function OnSavedItemLoaded(loadedItems)
end


function OnWipeTables()
end


function PlayerEnterSequence(client, sequence, callback, time, bNoFreeze)
end


function PlayerInteractEntity(client, entity, option, data)
end


function PlayerInteractItem(client, action, item)
end


function PlayerJoinedClass(client, class, oldClass)
end


function PlayerLeaveSequence(entity)
end


function PlayerLoadedCharacter(client, character, currentChar)
end


function PlayerLockedDoor(client, door, partner)
end


function PlayerLockedVehicle(client, vehicle)
end


function PlayerMessageSend(speaker, chatType, text, anonymous, receivers, rawText)
end


function PlayerModelChanged(client, model)
end


function PlayerStaminaGained(client)
end


function PlayerStaminaLost(client)
end


function PlayerThrowPunch(client, trace)
end


function PlayerUnlockedDoor(client, door, partner)
end


function PlayerUnlockedVehicle(client, door)
end


function PlayerUse(client, entity)
end


function PlayerUseDoor(client, entity)
end


function PlayerWeaponChanged(client, weapon)
end


function PluginLoaded(uniqueID, pluginTable)
end


function PluginShouldLoad(uniqueID)
end


function PluginUnloaded(uniqueID)
end


function PopulateCharacterInfo(client, character, tooltip)
end


function PopulateEntityInfo(entity, tooltip)
end


function PopulateHelpMenu(categories)
end


function PopulateImportantCharacterInfo(entity, character, tooltip)
end


function PopulateItemTooltip(tooltip, item)
end


function PopulatePlayerTooltip(client, tooltip)
end


function PopulateScoreboardPlayerMenu(client, menu)
end


function PostChatboxDraw(width, height, alpha)
end


function PostDrawHelixModelView(panel, entity)
end


function PostDrawInventory(panel)
end


function PostLoadData()
end


function PostPlayerLoadout(client)
end


function PostPlayerSay(client, chatType, message, anonymous)
end


function PostSetupActs()
end


function PreCharacterDeleted(client, character)
end


function PrePlayerLoadedCharacter(client, character, currentChar)
end

--- Called before a message sent by a player is processed to be sent to other players - i.e this is ran as early as possible
-- and before things like the auto chat formatting. Can be used to prevent the message from being sent at all.

-- @player client Player sending the message
-- @string chatType Chat class of the message
-- @string message Contents of the message
-- @bool bAnonymous Whether or not the player is sending the message anonymously
-- @treturn bool Whether or not to prevent the message from being sent
-- @usage function PLUGIN:PrePlayerMessageSend(client, chatType, message, bAnonymous)
-- 	if (!client:IsAdmin()) then
-- 		return false -- only allow admins to talk in chat
-- 	end
-- end
function PrePlayerMessageSend(client, chatType, message, bAnonymous)
end


function SaveData()
end


function ScreenResolutionChanged(width, height)
end


function SetupActs()
end


function SetupAreaProperties()
end


function ShipmentItemTaken(client, uniqueID, amount)
end


function ShouldBarDraw(bar)
end


function ShouldDeleteSavedItems()
end


function ShouldDisplayArea(newID)
end


function ShouldDrawCrosshair(client, weapon)
end


function ShouldDrawItemSize(item)
end


function ShouldHideBars()
end

--- Whether or not a character should be permakilled upon death. This is only called if the `permakill` server config is
-- enabled.

-- @player client Player to permakill
-- @char character Player's current character
-- @entity inflictor Entity that inflicted the killing blow
-- @entity attacker Other player or entity that killed the player
-- @treturn bool `false` if the player should not be permakilled
-- @usage function PLUGIN:ShouldPermakillCharacter(client, character, inflictor, attacker)
-- 		if (client:IsAdmin()) then
-- 			return false -- all non-admin players will have their character permakilled
-- 		end
-- 	end
function ShouldPermakillCharacter(client, character, inflictor, attacker)
end


function ShouldPlayerDrowned(v)
end


function ShouldRemoveRagdollOnDeath(client)
end


function ShouldRestoreInventory(characterID, inventoryID, inventoryType)
end


function ShouldShowPlayerOnScoreboard(client)
end


function ShouldSpawnClientRagdoll(client)
end


function ShowEntityMenu(entity)
end


function ThirdPersonToggled(oldValue, value)
end


function UpdateCharacterInfo(panel, character)
end


function UpdateCharacterInfoCategory(panel, character)
end


function VoiceDistanceChanged(newValue)
end


function WeaponCycleSound()
end


function WeaponSelectSound(weapon)
end