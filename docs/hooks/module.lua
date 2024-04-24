--[[--
General Hooks.

These hooks are regular hooks that can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
They can be used for an assorted of reasons, depending on what you are trying to achieve.
]]
-- @hooks Module

--- Called after a player sends a chat message.
-- @realm server
-- @client client The player entity who sent the message.
-- @string message The message sent by the player.
-- @string chatType The type of chat message (e.g., "ic" for in-character, "ooc" for out-of-character).
-- @bool anonymous Whether the message was sent anonymously (true) or not (false).
function PostPlayerSay(client, message, chatType, anonymous)
end

--- Whether or not a player can trade with a vendor.
-- @realm server
-- @client client Player attempting to trade
-- @entity entity Vendor entity
-- @string uniqueID The uniqueID of the item being traded.
-- @bool isSellingToVendor If the client is selling to the vendor
-- @treturn bool Whether or not to allow the client to trade with the vendor
-- @usage function MODULE:CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
-- 	return false -- Disallow trading with vendors outright.
-- end
function CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
end

--- Whether or not a player can unequip an item.
-- @realm server
-- @client client Player attempting to unequip an item
-- @tab item Item being unequipped
-- @treturn bool Whether or not to allow the player to unequip the item
-- @see CanPlayerEquipItem
-- @usage function MODULE:CanPlayerUnequipItem(client, item)
-- 	return false -- Disallow unequipping items.
-- end
function CanPlayerUnequipItem(client, item)
end

--- Whether or not a player is allowed to drop the given `item`.
-- @realm server
-- @client client Player attempting to drop an item
-- @number item instance ID of the item being dropped
-- @treturn bool Whether or not to allow the player to drop the item
-- @usage function MODULE:CanPlayerDropItem(client, item)
-- 	return false -- Never allow dropping items.
-- end
function CanPlayerDropItem(client, item)
end

--- Whether or not a player is allowed to take an item and put it in their inventory.
-- @realm server
-- @client client Player attempting to take the item
-- @entity item Entity corresponding to the item
-- @treturn bool Whether or not to allow the player to take the item
-- @usage function MODULE:CanPlayerTakeItem(client, item)
-- 	return !(client:GetMoveType() == MOVETYPE_NOCLIP and !client:InVehicle()) -- Disallow players in observer taking items.
-- end
function CanPlayerTakeItem(client, item)
end

--- Whether or not a player can equip the given `item`. This is called for items with `outfit`, `pacoutfit`, or `weapons` as
-- their base. Schemas/modules can utilize this hook for their items.
-- @realm server
-- @client client Player attempting to equip the item
-- @tab item Item being equipped
-- @treturn bool Whether or not to allow the player to equip the item
-- @see CanPlayerUnequipItem
-- @usage function MODULE:CanPlayerEquipItem(client, item)
-- 	return client:IsAdmin() -- Restrict equipping items to admins only.
-- end
function CanPlayerEquipItem(client, item)
end

--- Whether or not a player is allowed to interact with an item via an inventory action (e.g picking up, dropping, transferring
-- inventories, etc). Note that this is for an item *table*, not an item *entity*. This is called after `CanPlayerDropItem`
-- and `CanPlayerTakeItem`.
-- @realm server
-- @client client Player attempting interaction
-- @string action The action being performed
-- @param item Item's instance ID or item table
-- @treturn bool Whether or not to allow the player to interact with the item
-- @usage function MODULE:CanPlayerInteractItem(client, action, item, data)
-- 	return false -- Disallow interacting with any item.
-- end
function CanPlayerInteractItem(client, action, item)
end

--- Displays the context menu for interacting with an item entity.
--- @realm client
--- @entity entity The item entity for which the context menu is displayed.
function ItemShowEntityMenu(entity)
end

--- Called when the third person mode is toggled.
--- @realm client
--- @bool state Indicates whether the third person mode is enabled (`true`) or disabled (`false`).
function thirdPersonToggled(state)
end

--- Called when a character trades with a vendor entity.
-- This function can be used to perform additional actions when a character trades
-- with a vendor entity.
-- @realm shared
-- @client client The player character trading with the vendor
-- @entity entity The vendor entity being traded with
-- @string uniqueID The unique identifier of the traded item
-- @bool isSellingToVendor Whether the trade involves selling to the vendor
-- @see VendorSellEvent
-- @see VendorBuyEvent
-- @usage function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
--     -- Perform additional actions when a character trades with the vendor
-- end
function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
end

--- Called when a player interacts with a vendor entity.
-- This function adds the player to the vendor's receivers list and notifies the player
-- about accessing the vendor.
-- @client client The player accessing the vendor
-- @entity entity The vendor
-- @usage function PlayerAccessVendor(client, entity)
--     -- Add the player to the vendor's receivers list
--     entity.receivers[#entity.receivers + 1] = client
--
--     -- Notify the player about accessing the vendor
--     if entity.messages[VENDOR_WELCOME] then
--         client:notify(entity:getNetVar("name") .. ": " .. entity.messages[VENDOR_WELCOME])
--     end
-- end
--- @realm shared
--- @treturn bool True if the player can access the vendor.
function PlayerAccessVendor(client, entity)
end

--- Called when a player sells an item to a vendor.
-- @realm shared
-- This function handles the event where a player sells an item to a vendor.
-- @client client The player selling the item
-- @entity vendor The vendor entity
-- @string itemType The uniqueID of item being sold
-- @bool isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @character character The character of the player selling the item
-- @int price The price at which the item is sold
-- @see VendorBuyEvent
function VendorSellEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Called when a player successfully buys an item from a vendor.
-- This function is called when a player successfully completes a purchase from a vendor.
-- @client client The player who made the purchase
-- @entity vendor The vendor entity from which the item was bought
-- @string itemType The uniqueID of item being sold
-- @bool isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @character character The character of the player involved in the trade
-- @int price The price of the item being bought
-- @realm shared
-- @see VendorSellEvent
function VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Called to determine whether data should be saved before shutting down the server.
-- This function is called to determine whether data should be saved before the server shuts down.
-- @treturn boolean True if data should be saved, false otherwise
-- @realm server
function ShouldDataBeSaved()
end

--- Called when a player picks up money.
-- This function is called when a player picks up money from the ground.
-- @client client The player who picked up the money
-- @entity moneyEntity The entity representing the money being picked up
-- @realm server
function OnPickupMoney(client, moneyEntity)
end
--- Determines whether an item can be transferred between inventories.
-- @realm shared
-- This hook allows custom logic to be implemented to determine if an item can be transferred
-- from one inventory to another. It can be used to impose restrictions on item transfers.
-- @param item The item being transferred
-- @param currentInv The current inventory from which the item is being transferred
-- @param oldInv The old inventory to which the item belonged
-- @treturn boolean|string Whether the item can be transferred, or false and a reason if not
function CanItemBeTransfered(item, currentInv, oldInv)
end


--- Whether or not a player is allowed to create a new character.
-- @realm server
-- @client client Player attempting to create a new character
-- @treturn bool Whether or not the player is allowed to create the character. This function defaults to `true`, so you
-- should only ever return `false` if you're disallowing creation. Otherwise, don't return anything as you'll prevent any other
-- calls to this hook from running.
-- @treturn string Language phrase to use for the error message
-- @treturn ... Arguments to use for the language phrase
-- @usage function MODULE:CanPlayerCreateCharacter(client)
-- 	if (!client:IsAdmin()) then
-- 		return false, "notNow" -- only allow admins to create a character
-- 	end
-- end
-- -- non-admins will see the message "You are not allowed to do this right now!"
function CanPlayerCreateCharacter(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function PostCharDelete(client, character)
end

--- Called after a player's loadout is applied.
-- @realm server
-- @client client The player entity.
function PostPlayerLoadout(client)
end

--- Retrieves the maximum number of characters a player can have.
--- @client client The player for whom to retrieve the maximum number of characters.
--- @treturn int The maximum number of characters the player can have.
--- @realm shared
function GetMaxPlayerCharacter(client)
end

--- Called after all of the player's loadout hooks are executed (PlayerLoadout, FactionOnLoadout, ClassOnLoadout).
-- This hook is called after a player's loadout has been fully applied, including faction and class loadouts.
-- @client client The player entity for whom the loadout was applied.
-- @realm server
function PostPlayerLoadout(client)
end

--- Called after PlayerLoadout is executed.
-- This hook is called after a player's faction loadout has been applied.
-- @client client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionOnLoadout(client)
end

--- Called after FactionOnLoadout is executed.
-- This hook is called after a player's class loadout has been applied.
-- @client client The player entity for whom the class loadout was applied.
-- @realm server
function ClassOnLoadout(client)
end

--- Called after PostPlayerLoadout is executed.
-- This hook is called after additional actions related to a player's faction loadout have been performed.
-- @client client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionPostLoadout(client)
end

--- Called after FactionPostLoadout is executed.
-- This hook is called after additional actions related to a player's class loadout have been performed.
-- @client client The player entity for whom the class loadout was applied.
-- @realm server
function ClassPostLoadout(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function CharDeleted(client, character)
end

--- Called before a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PrePlayerLoadedChar(client, character, currentChar)
end

--- Called when a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PlayerLoadedChar(client, character, currentChar)
end

--- Called after a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PostPlayerLoadedChar(client, character, currentChar)
end

--- Determines whether a client should drown.
-- @realm server
-- @client client The player entity.
-- @treturn boolean True if the client should drown, false otherwise.
function ShouldClientDrown(client)
end

--- Called when a player tries to use abilities on the door, such as locking.
-- @realm shared
-- @client client The client trying something on the door.
-- @entity door The door entity itself.
-- @number access The access level used when called.
-- @treturn bool Whether or not to allow the client access.
-- @usage function MODULE:CanPlayerAccessDoor(client, door, access)
--     return true -- Always allow access.
-- end
function CanPlayerAccessDoor(client, door, access)
end

--- Whether or not a player is allowed to join a class.
-- @realm shared
-- @client client Player attempting to join
-- @number class ID of the class
-- @tab info The class table
-- @treturn bool Whether or not to allow the player to join the class
-- @usage function MODULE:CanPlayerJoinClass(client, class, info)
-- 	return client:IsAdmin() -- Restrict joining classes to admins only.
-- end
function CanPlayerJoinClass(client, class, info)
end

--- Whether or not a player can earn money at regular intervals. This hook runs only if the player's character faction has
-- a salary set i.e `FACTION.pay` is set to something other than `0` for their faction.
-- @realm server
-- @client client Player to give money to
-- @tab faction Faction of the player's character
-- @tab class Class of the player's character
-- @treturn bool Whether or not to allow the player to earn salary
-- @usage function MODULE:CanPlayerEarnSalary(client, faction)
-- 	return client:IsAdmin() -- Restricts earning salary to admins only.
-- end
function CanPlayerEarnSalary(client, faction, class)
end

--- Whether or not the player is allowed to punch with the hands SWEP.
-- @realm shared
-- @client client Player attempting throw a punch
-- @treturn bool Whether or not to allow the player to punch
-- @usage function MODULE:CanPlayerThrowPunch(client)
-- 	return client:GetCharacter():GetAttribute("str", 0) > 0 -- Only allow players with strength to punch.
-- end
function CanPlayerThrowPunch(client)
end

--- Determines whether a player is allowed to use a specific character.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a particular character.
-- @realm shared
-- @client client The player attempting to use the character
-- @character character The character being considered for use
-- @treturn boolean Whether the player is allowed to use the character
-- @treturn string|nil If disallowed, a reason for the disallowance; otherwise, nil
function CanPlayerUseChar(client, character)
end

--- Determines whether a player is allowed to use a door entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a specific door entity.
-- @realm server
-- @client client The player attempting to use the door
-- @entity entity The door entity being considered for use
-- @treturn boolean Whether the player is allowed to use the door
function CanPlayerUseDoor(client, entity)
end

--- Determines whether a player is allowed to access a vendor entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to access a specific vendor entity.
-- @realm server
-- @client client The player attempting to access the vendor
function CanPlayerAccessVendor(client)
end

--- Called when a character is loaded.
-- This function is called after a character has been successfully loaded.
-- @character character The character that has been loaded
-- @realm shared
function CharLoaded(character)
end

--- Called after a character has been saved.
-- This function is called after a character has been successfully saved.
-- @character character The character that has been saved
-- @realm server
function CharPostSave(character)
end

--- Called before a character is saved.
-- This function is called before a character is about to be saved.
-- @character character The character about to be saved
-- @realm shared
function CharPreSave(character)
end

--- Called whenever an item entity has spawned in the world. You can access the entity's item table with
-- `entity:getItemTable()`.
-- @realm server
-- @entity entity Spawned item entity
-- @usage function MODULE:OnItemSpawned(entity)
-- 	local item = entity:getItemTable()
-- 	-- do something with the item here
-- end
function OnItemSpawned(entity)
end

--- Whether or not the ammo HUD should be drawn.
-- @realm client
-- @entity weapon Weapon the player currently is holding
-- @treturn bool Whether or not to draw the ammo hud
-- @usage function MODULE:ShouldDrawAmmoHUD(weapon)
-- 	if (weapon:GetClass() == "weapon_frag") then
-- 		return false
-- 	end
-- end
function ShouldDrawAmmoHUD(weapon)
end

--- Determines whether a bar should be drawn.
-- @realm client
-- @tab bar The bar object.
-- @treturn boolean True if the bar should be drawn, false otherwise.
function ShouldBarDraw(bar)
end

--- Determines whether the crosshair should be drawn for a specific client and weapon.
--- @realm client
--- @client client The player entity.
--- @string weapon The weapon entity.
--- @treturn boolean True if the crosshair should be drawn, false otherwise.
function ShouldDrawCrosshair(client, weapon)
end

--- Determines whether bars should be hidden.
--- @realm client
--- @treturn boolean True if bars should be hidden, false otherwise.
function ShouldHideBars()
end

--- Called when the screen resolution changes.
-- @realm client
-- @int width number The new width of the screen.
-- @int height number The new height of the screen.
function ScreenResolutionChanged(width, height)
end

--- Determines whether a player should be shown on the scoreboard.
--- @realm client
--- @client client The player entity to be evaluated.
--- @treturn bool True if the player should be shown on the scoreboard, false otherwise.
function ShouldShowPlayerOnScoreboard(client)
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory.
function PostDrawInventory(panel)
end

-- This function determines whether certain information can be displayed in the character info panel in the F1 menu.
-- @realm client
-- @table Information to **NOT** display in the UI. This is a table of the names of some panels to avoid displaying. Valid names include:
-- `name` name of the character
-- `desc` description of the character
-- `faction` faction name of the character
-- `money` current money the character has
-- `class` name of the character's class if they're in one
-- Note that schemas/modules can add additional character info panels.
-- @usage function MODULE:CanDisplayCharacterInfo(suppress)
-- 	suppress.faction = true
-- end
function CanDisplayCharacterInfo(suppress)
end

--- Determines whether a player is allowed to view their inventory.
-- @realm client
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to view their inventory.
-- @treturn boolean Whether the player is allowed to view their inventory
function CanPlayerViewInventory()
end


--- Checks if a character is recognized.
--- @character character The character to check.
--- @int id Identifier for the character.
-- @realm shared
function isCharRecognized(character, id)

end

--- Checks if a character is fake recognized.
--- @character character The character to check.
--- @int id Identifier for the character.
-- @realm shared
function isCharFakeRecognized(character, id)
end

--- Checks if a fake name exists in the given character name list.
-- @realm shared
--- @string name The name to check.
--- @tab nameList A list of character names.
--- @treturn True if the name exists in the list, false otherwise.
function isFakeNameExistant(name, nameList)
end

--- Called when a character is recognized.
--- @client client The client whose character is recognized.
--- @int id Identifier for the recognized character.
--- @realm client
function OnCharRecognized(client, id)
end

--- Initiates character recognition process.
--- @int level The recognition level.
--- @realm client
--- @string name The name of the character to be recognized.
function CharRecognize(level, name)
end

--- Creates menu buttons for the F1 menu.
--- @tab tabs A table to store the created buttons.
--- @realm client
function CreateMenuButtons(tabs)
end

--- Called when lia.config has been initialized.
--- @realm shared
function InitializedConfig()
end

--- Called when all the modules have been initialized.
--- @realm shared
function InitializedModules()
end

--- Called when the schema has been initialized.
--- @realm shared
function InitializedSchema()
end

--- Loads custom fonts for the client.
--- @string font The path to the font file.
--- @string genericFont The path to the generic font file.
--- @realm client
function LoadFonts(font, genericFont)
end

--- Loads Core Lilia fonts for the client.
--- @string font The path to the font file.
--- @string genericFont The path to the generic font file.
--- @realm client
-- @internal
function LoadLiliaFonts(font, genericFont)
end

--- Creates a timer to manage player salary.
--- @client client The player for whom the salary timer is created.
--- @realm shared
function CreateSalaryTimer(client)
end

--- Determines if a player is allowed to earn salary.
--- @client client The player whose eligibility for salary is being checked.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn True if the player is allowed to earn salary, false otherwise.
--- @realm shared
function CanPlayerEarnSalary(client, faction, class)
end

--- Called when a module has finished loading.
--- @realm shared
function ModuleLoaded()
end

--- Retrieves the salary limit for a player.
--- @client client The player for whom to retrieve the salary limit.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn The salary limit for the player.
--- @realm shared
function GetSalaryLimit(client, faction, class)
end

--- Retrieves the amount of salary a player should receive.
--- @client client The player receiving the salary.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn The amount of salary the player should receive.
--- @realm shared
function GetSalaryAmount(client, faction, class)
end

--- Called to draw additional content within the model view panel.
--- @panel panel The panel containing the model view.
--- @entity entity The entity being drawn.
--- @realm client
function DrawLiliaModelView(panel, entity)
end

--- Whether or not a player is allowed to spawn a container entity.
-- @client client The player attempting to spawn a container.
-- @entity entity The container entity being spawned.
-- @tab data Additional data related to the container being spawned.
-- @treturn bool Whether or not to allow the player to spawn the container.
-- @realm server
-- @usage function MODULE:CanPlayerSpawnStorage(client, entity, data)
--     return client:IsAdmin() -- Restrict spawning containers to admins.
-- end
function CanPlayerSpawnStorage(client, entity, data)
end
--- Determines if a player can throw a punch with a weapon.
--- @client client The player attempting to throw a punch.
--- @tab trace The trace result.
--- @treturn True if the player can throw a punch, false otherwise.
--- @realm shared
function CanPlayerThrowPunch(client, trace)
end

--- Called when a player purchases a door.
--- @client client The player who purchased the door.
--- @entity entity The door entity that was purchased.
--- @bool buying True if the player is buying the door, false if selling.
--- @func CallOnDoorChild A function to call on door children.
--- @realm server
function OnPlayerPurchaseDoor(client, entity, buying, CallOnDoorChild)
end
--- Called when a character's attribute is updated.
--- @client client The client associated with the character.
--- @character character The character whose attribute is updated.
--- @string attribID The ID of the attribute being updated.
--- @string boostID The ID of the boost being applied to the attribute.
--- @int boostAmount The amount of boost being applied to the attribute.
--- @realm shared
function OnCharAttribUpdated(client, character, attribID, boostID, boostAmount)
end

--- Called when a character's attribute is updated.
--- @client client The client associated with the character.
--- @character character The character whose attribute is updated.
--- @string key The key of the attribute being updated.
--- @int value The new value of the attribute.
--- @realm shared
function OnCharAttribUpdated(client, character, key, value)
end
--- Called when a player's model is changed.
--- @client client The client whose model is changed.
--- @string model The new model path.
--- @realm shared
function PlayerModelChanged(client, model)
end
--- Determines if a character has the given flag(s).
--- @character character The character to check for flags.
--- @string flags The flag(s) to check access for.
--- @treturn bool Whether or not this character has access to the given flag(s).
--- @realm shared
function CharHasFlags(character, flags)
end

--- Called when a player gains stamina.
--- @client client The player who gained stamina.
--- @realm server
function PlayerStaminaGained(client)
end

--- Called when a player loses stamina.
--- @client client The player who lost stamina.
--- @realm server
function PlayerStaminaLost(client)
end

--- Saves the server data.
-- @realm server
function SaveData()
end

--- Loads the server data.
-- @realm server
function LoadData()
end

--- Called after data has been loaded.
-- @realm server
function PostLoadData()
end

--- Called when the database has been successfully connected.
--- @realm server
-- @internal
function DatabaseConnected()
end

--- Called after wiping tables.
--- @realm server
-- @internal
function OnWipeTables()
end

--- Sets up the database.
--- @realm server
-- @internal
function SetupDatabase()
end

