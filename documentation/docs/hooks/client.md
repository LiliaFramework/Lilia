# Lilia Framework - Client-Side Hooks

Client-side hook system for the Lilia framework.

---

## Overview

Client-side hooks in the Lilia framework handle UI, rendering, input, and other client-specific functionality; they can be used to customize the user experience and can be overridden or extended by addons and modules.

---

### AddBarField

**Purpose**

Adds a bar field to a character information section in the F1 menu

**When Called**

When you want to add a progress bar field to display character statistics

---

### AddSection

**Purpose**

Adds a new section to the character information panel in the F1 menu

**When Called**

When you want to create a new section for displaying character information

---

### AddTextField

**Purpose**

Adds a text field to a character information section in the F1 menu

**When Called**

When you want to add a text field to display character information

---

### AddToAdminStickHUD

**Purpose**

Adds information to the admin stick HUD display when looking at entities

**When Called**

When an admin uses the admin stick and looks at an entity

---

### AddWarning

**Purpose**

Adds a warning to a character's record in the administration system

**When Called**

When an admin issues a warning to a player

---

### AdjustCreationData

**Purpose**

Allows modification of character creation data before the character is created

**When Called**

During character creation process, before the character is saved to database

---

### AdjustPACPartData

**Purpose**

Allows modification of PAC3 part data before it's applied to a player

**When Called**

When PAC3 parts are being attached to a player, allowing customization

---

### AdjustStaminaOffset

**Purpose**

Allows modification of stamina regeneration/drain offset for a player

**When Called**

During stamina calculation, allowing custom stamina modifiers

**Parameters**

* `else` (*unknown*): - Drain

---

### AttachPart

**Purpose**

Attaches a PAC3 part to a player

**When Called**

When a PAC3 part needs to be attached to a player

---

### BagInventoryReady

**Purpose**

Called when a bag item's inventory is ready and accessible

**When Called**

When a bag item's inventory is created or restored from database

---

### BagInventoryRemoved

**Purpose**

Called when a bag item's inventory is removed or destroyed

**When Called**

When a bag item is deleted or its inventory is cleaned up

---

### CanBeTransfered

**Purpose**

Determines if a character can be transferred to a different faction

**When Called**

When attempting to transfer a character to another faction

---

### CanCharBeTransfered

**Purpose**

Determines if a character can be transferred (alias for CanBeTransfered)

**When Called**

When attempting to transfer a character to another faction

---

### CanDeleteChar

**Purpose**

Determines if a character can be deleted

**When Called**

When a player attempts to delete a character

---

### CanDisplayCharInfo

**Purpose**

Determines if character information should be displayed for a given name

**When Called**

When displaying character information in UI elements

---

### CanInviteToClass

**Purpose**

Called to check if a player can invite another to a class

**When Called**

When attempting to invite a player to a class

---

### CanInviteToFaction

**Purpose**

Called to check if a player can invite another to a faction

**When Called**

When attempting to invite a player to a faction

---

### CanItemBeTransfered

**Purpose**

Called to check if an item can be transferred between inventories

**When Called**

When attempting to move an item from one inventory to another

---

### CanOpenBagPanel

**Purpose**

Called to check if a bag panel can be opened

**When Called**

When attempting to open a bag's inventory panel

---

### CanOutfitChangeModel

**Purpose**

Called to check if an outfit can change model

**When Called**

When attempting to change a player's model via outfit

---

### CanPerformVendorEdit

**Purpose**

Called to check if a player can edit a vendor

**When Called**

When attempting to modify vendor settings

---

### CanPersistEntity

**Purpose**

Called to check if an entity can be persisted

**When Called**

When determining if an entity should be saved across map changes

---

### CanPickupMoney

**Purpose**

Called to check if money can be picked up

**When Called**

When a player attempts to pick up money

---

### CanPlayerAccessDoor

**Purpose**

Called to check if a player can access a door

**When Called**

When a player attempts to interact with a door

---

### CanPlayerAccessVendor

**Purpose**

Called to check if a player can access a vendor

**When Called**

When a player attempts to interact with a vendor

---

### CanPlayerChooseWeapon

**Purpose**

Called to check if a player can choose a weapon

**When Called**

When a player attempts to select a weapon

---

### CanPlayerCreateChar

**Purpose**

Determines if a player can create a new character

**When Called**

When a player attempts to create a new character

---

### CanPlayerDropItem

**Purpose**

Called to check if a player can drop an item

**When Called**

When a player attempts to drop an item

---

### CanPlayerEarnSalary

**Purpose**

Called to check if a player can earn salary

**When Called**

When salary payment is being processed

---

### CanPlayerEquipItem

**Purpose**

Called to check if a player can equip an item

**When Called**

When a player attempts to equip an item

---

### CanPlayerHoldObject

**Purpose**

Called to check if a player can hold an object

**When Called**

When a player attempts to pick up or hold an entity

---

### CanPlayerInteractItem

**Purpose**

Called to check if a player can interact with an item

**When Called**

When a player attempts to perform an action on an item

---

### CanPlayerJoinClass

**Purpose**

Called to check if a player can join a class

**When Called**

When a player attempts to join a specific class

---

### CanPlayerKnock

**Purpose**

Called to check if a player can knock on doors

**When Called**

When a player attempts to knock on a door

---

### CanPlayerLock

**Purpose**

Called to check if a player can lock a door

**When Called**

When a player attempts to lock a door

---

### CanPlayerModifyConfig

**Purpose**

Called to check if a player can modify configuration

**When Called**

When a player attempts to change a config value

---

### CanPlayerOpenScoreboard

**Purpose**

Called to check if a player can open the scoreboard

**When Called**

When a player attempts to open the scoreboard

---

### CanPlayerRotateItem

**Purpose**

Called to check if a player can rotate an item in inventory

**When Called**

When a player attempts to rotate an item

---

### CanPlayerSeeLogCategory

**Purpose**

Called to check if a player can see a log category

**When Called**

When determining which log categories a player can view

---

### CanPlayerSpawnStorage

**Purpose**

Called to check if a player can spawn storage entities

**When Called**

When a player attempts to spawn a storage container

---

### CanPlayerSwitchChar

**Purpose**

Called to check if a player can switch characters

**When Called**

When a player attempts to switch from one character to another

---

### CanPlayerTakeItem

**Purpose**

Called to check if a player can take an item

**When Called**

When a player attempts to take an item from the ground or another source

---

### CanPlayerThrowPunch

**Purpose**

Called to check if a player can throw a punch

**When Called**

When a player attempts to punch

---

### CanPlayerTradeWithVendor

**Purpose**

Called to check if a player can trade with a vendor

**When Called**

When a player attempts to buy/sell from a vendor

---

### CanPlayerUnequipItem

**Purpose**

Called to check if a player can unequip an item

**When Called**

When a player attempts to unequip an item

---

### CanPlayerUnlock

**Purpose**

Called to check if a player can unlock a door

**When Called**

When a player attempts to unlock a door

---

### CanPlayerUseChar

**Purpose**

Called to check if a player can use a character

**When Called**

When a player attempts to load a character

---

### CanPlayerUseCommand

**Purpose**

Called to check if a player can use a command

**When Called**

When a player attempts to execute a command

---

### CanPlayerUseDoor

**Purpose**

Called to check if a player can use a door

**When Called**

When a player attempts to interact with a door

---

### CanPlayerViewInventory

**Purpose**

Called to check if a player can view inventories

**When Called**

When a player attempts to open any inventory

---

### CanRunItemAction

**Purpose**

Called to check if an item action can be run

**When Called**

When attempting to execute an item action

---

### CanSaveData

**Purpose**

Called to check if entity data can be saved

**When Called**

When attempting to save entity data to the database

---

### CharCleanUp

**Purpose**

Called when a character is cleaned up

**When Called**

When a character is being removed from memory

---

### CharDeleted

**Purpose**

Called when a character is deleted

**When Called**

When a character is successfully deleted

---

### CharForceRecognized

**Purpose**

Called to force character recognition

**When Called**

When a character is forced to be recognized

---

### CharHasFlags

**Purpose**

Called to check if a character has specific flags

**When Called**

When checking if a character has certain permissions

---

### CharListColumns

**Purpose**

Called to modify character list columns

**When Called**

When building the character list display

---

### CharListEntry

**Purpose**

Called to modify character list entries

**When Called**

When building each character list entry

---

### CharListExtraDetails

**Purpose**

Called to add extra details to character list entries

**When Called**

When building character list entries with additional information

---

### CharListLoaded

**Purpose**

Called when character list is loaded

**When Called**

When the character list data is successfully loaded

---

### CharListUpdated

**Purpose**

Called when character list is updated

**When Called**

When the character list data is modified

---

### CharLoaded

**Purpose**

Called when a character is loaded

**When Called**

When a character is successfully loaded from the database

---

### CharMenuClosed

**Purpose**

Called when the character menu is closed

**When Called**

When the character selection menu is closed

---

### CharMenuOpened

**Purpose**

Called when the character menu is opened

**When Called**

When the character selection menu is opened

---

### CharPostSave

**Purpose**

Called after a character is saved

**When Called**

After character data has been saved to the database

---

### CharPreSave

**Purpose**

Called before a character is saved

**When Called**

Before character data is saved to the database

---

### CharRestored

**Purpose**

Called when a character is restored

**When Called**

When a character is restored from backup or death

---

### ChatAddText

**Purpose**

Called to add text to the chat

**When Called**

When text is being added to the chatbox

---

### ChatParsed

**Purpose**

Called when chat is parsed

**When Called**

When a chat message is processed and parsed

---

### ChatboxPanelCreated

**Purpose**

Called when the chatbox panel is created

**When Called**

When the chatbox UI panel is initialized

---

### ChatboxTextAdded

**Purpose**

Called when text is added to the chatbox

**When Called**

When new text is displayed in the chatbox

---

### CheckFactionLimitReached

**Purpose**

Called to check if a faction limit has been reached

**When Called**

When checking if more players can join a faction

---

### ChooseCharacter

**Purpose**

Called when a character is chosen

**When Called**

When a player selects a character to play

---

### CommandAdded

**Purpose**

Called when a command is added

**When Called**

When a new command is registered to the framework

---

### CommandRan

**Purpose**

Called when a command is executed

**When Called**

After a command has been run by a player

---

### ConfigChanged

**Purpose**

Called when a configuration value changes

**When Called**

When a config option is modified

---

### ConfigUpdated

**Purpose**

Called when a configuration is updated

**When Called**

When a config value is synchronized or updated

---

### ConfigureCharacterCreationSteps

**Purpose**

Called to configure character creation steps

**When Called**

When setting up the character creation process

---

### CreateCharacter

**Purpose**

Called when creating a character

**When Called**

When a new character is being created

---

### CreateChat

**Purpose**

Called to create the chat interface

**When Called**

When the chat UI is being initialized

---

### CreateDefaultInventory

**Purpose**

Called to create a character's default inventory

**When Called**

When a new character needs an inventory created

---

### CreateInformationButtons

**Purpose**

Called to create information buttons in the F1 menu

**When Called**

When building the information panel buttons

---

### CreateInventoryPanel

**Purpose**

Called to create an inventory panel

**When Called**

When an inventory UI panel needs to be created

---

### CreateMenuButtons

**Purpose**

Called to create menu buttons

**When Called**

When building the main menu button tabs

---

### CreateSalaryTimers

**Purpose**

Called to create salary timers

**When Called**

When salary system is being initialized

---

### CustomClassValidation

**Purpose**

Called for custom class validation

**When Called**

When validating a player's class change

---

### CustomLogHandler

**Purpose**

Called for custom log handling

**When Called**

When a log message is being processed

---

### DatabaseConnected

**Purpose**

Called when database is connected

**When Called**

When the database connection is established

---

### DeleteCharacter

**Purpose**

Called when a character is deleted

**When Called**

When a character deletion is processed

---

### DermaSkinChanged

**Purpose**

Called when derma skin is changed

**When Called**

When the UI skin is changed

---

### DiscordRelaySend

**Purpose**

Called to send a Discord relay message

**When Called**

When sending a message to Discord

---

### DiscordRelayUnavailable

**Purpose**

Called when Discord relay is unavailable

**When Called**

When Discord relay connection fails

---

### DiscordRelayed

**Purpose**

Called when a message is relayed to Discord

**When Called**

After a message is successfully sent to Discord

---

### DoModuleIncludes

**Purpose**

Called when doing module includes

**When Called**

When a module is being loaded and files are being included

---

### DoorEnabledToggled

**Purpose**

Called when a door's enabled state is toggled

**When Called**

When a door is enabled or disabled

---

### DoorHiddenToggled

**Purpose**

Called when a door's hidden state is toggled

**When Called**

When a door is made hidden or visible

---

### DoorLockToggled

**Purpose**

Called when a door's lock state is toggled

**When Called**

When a door is locked or unlocked

---

### DoorOwnableToggled

**Purpose**

Called when a door's ownable status is toggled

**When Called**

When a door is set to be ownable or not ownable

---

### DoorPriceSet

**Purpose**

Called when a door's price is set

**When Called**

When a door's purchase/rent price is changed

---

### DoorTitleSet

**Purpose**

Called when a door's title is set

**When Called**

When a door's display name is changed

---

### DrawCharInfo

**Purpose**

Called to draw character information

**When Called**

When character information needs to be rendered

---

### DrawDoorInfoBox

**Purpose**

Called to draw door information box

**When Called**

When rendering door information UI

---

### DrawEntityInfo

**Purpose**

Called to draw entity information

**When Called**

When rendering entity information UI

---

### DrawLiliaModelView

**Purpose**

Called to draw Lilia model view

**When Called**

When rendering a model view panel

---

### DrawPlayerRagdoll

**Purpose**

Called to draw a player's ragdoll

**When Called**

When rendering a player ragdoll entity

---

### ExitStorage

**Purpose**

Called when exiting storage

**When Called**

When a player closes a storage container

---

### F1MenuClosed

**Purpose**

Called when the F1 menu is closed

**When Called**

When the F1 character information menu is closed

---

### F1MenuOpened

**Purpose**

Called when the F1 menu is opened

**When Called**

When the F1 character information menu is opened

---

### FetchSpawns

**Purpose**

Called to fetch spawn points

**When Called**

When spawn points need to be loaded or refreshed

---

### FilterCharModels

**Purpose**

Called to filter character models

**When Called**

When character models need to be filtered or restricted

---

### FilterDoorInfo

**Purpose**

Called to filter door information

**When Called**

When door information is being displayed

---

### ForceRecognizeRange

**Purpose**

Called to force recognition range

**When Called**

When setting the recognition range for a player

---

### GetAdjustedPartData

**Purpose**

Called to get adjusted PAC part data

**When Called**

When retrieving PAC part data with adjustments applied

---

### GetAllCaseClaims

**Purpose**

Called to get all case claims

**When Called**

When retrieving all active case claims

---

### GetAttributeMax

**Purpose**

Called to get the maximum value for an attribute

**When Called**

When calculating attribute limits

---

### GetAttributeStartingMax

**Purpose**

Called to get the starting maximum for an attribute

**When Called**

When a character is created

---

### GetCharMaxStamina

**Purpose**

Gets the maximum stamina for a character

**When Called**

When calculating character stamina limits

---

### GetDamageScale

**Purpose**

Called to get damage scale for a hitgroup

**When Called**

When calculating damage to a player

---

### GetDefaultCharDesc

**Purpose**

Called to get default character description

**When Called**

When creating a new character

---

### GetDefaultCharName

**Purpose**

Called to get default character name

**When Called**

When creating a new character

---

### GetDefaultInventorySize

**Purpose**

Called to get default inventory size

**When Called**

When creating a character's inventory

---

### GetDefaultInventoryType

**Purpose**

Called to get default inventory type

**When Called**

When creating a character's inventory

---

### GetDisplayedDescription

**Purpose**

Called to get displayed description

**When Called**

When showing a player's description

---

### GetDisplayedName

**Purpose**

Called to get displayed name in chat

**When Called**

When showing a player's name in chat

---

### GetDoorInfo

**Purpose**

Called to get door information

**When Called**

When retrieving door data

---

### GetDoorInfoForAdminStick

**Purpose**

Called to get door information for admin stick

**When Called**

When displaying door information in the admin stick HUD

---

### GetEntitySaveData

**Purpose**

Called to get entity save data

**When Called**

When saving entity data to the database

---

### GetHandsAttackSpeed

**Purpose**

Called to get hands attack speed

**When Called**

When calculating unarmed attack speed for a player

---

### GetInjuredText

**Purpose**

Called to get injured text

**When Called**

When displaying injury status text

---

### GetItemDropModel

**Purpose**

Called to get item drop model

**When Called**

When determining the model for a dropped item

---

### GetItemStackKey

**Purpose**

Called to get item stack key

**When Called**

When determining how items should be stacked together

---

### GetItemStacks

**Purpose**

Called to get item stacks in an inventory

**When Called**

When retrieving stacked items from an inventory

---

### GetMainMenuPosition

**Purpose**

Called to get main menu position

**When Called**

When positioning the main menu UI

---

### GetMaxPlayerChar

**Purpose**

Called to get maximum character count for a player

**When Called**

When checking how many characters a player can have

---

### GetMaxSkillPoints

**Purpose**

Called to get maximum skill points for a player

**When Called**

When calculating skill point limits

---

### GetMaxStartingAttributePoints

**Purpose**

Called to get maximum starting attribute points

**When Called**

During character creation

---

### GetModelGender

**Purpose**

Called to get model gender

**When Called**

When determining a model's gender

---

### GetMoneyModel

**Purpose**

Called to get money model

**When Called**

When spawning money entity

---

### GetOOCDelay

**Purpose**

Called to get OOC chat delay

**When Called**

When checking OOC chat cooldown

---

### GetPlayTime

**Purpose**

Called to get player playtime

**When Called**

When retrieving player playtime

---

### GetPlayerDeathSound

**Purpose**

Called to get player death sound

**When Called**

When a player dies

---

### GetPlayerPainSound

**Purpose**

Called to get player pain sound

**When Called**

When a player takes damage

**Parameters**

* `else` (*unknown*): - Heavy damage

---

### GetPlayerPunchDamage

**Purpose**

Called to get player punch damage

**When Called**

When calculating unarmed punch damage for a player

---

### GetPlayerPunchRagdollTime

**Purpose**

Called to get player punch ragdoll time

**When Called**

When calculating how long a player stays ragdolled from a punch

---

### GetPriceOverride

**Purpose**

Called to get price override for items

**When Called**

When calculating item prices in vendors or trading

---

### GetRagdollTime

**Purpose**

Called to get ragdoll time

**When Called**

When calculating how long an entity stays ragdolled

---

### GetSalaryAmount

**Purpose**

Called to get salary amount for a player

**When Called**

When calculating salary payment for a player

---

### GetTicketsByRequester

**Purpose**

Called to get tickets by requester

**When Called**

When retrieving tickets created by a specific player

---

### GetVendorSaleScale

**Purpose**

Called to get vendor sale scale

**When Called**

When calculating the sale price multiplier for a vendor

---

### GetWarnings

**Purpose**

Called to get warnings for a character

**When Called**

When retrieving warnings for a specific character

---

### GetWarningsByIssuer

**Purpose**

Called to get warnings by issuer

**When Called**

When retrieving warnings issued by a specific player

---

### GetWeaponName

**Purpose**

Called to get weapon name

**When Called**

When displaying the name of a weapon

---

### HUDVisibilityChanged

**Purpose**

Called when HUD visibility changes

**When Called**

When the HUD is shown or hidden

---

### HandleItemTransferRequest

**Purpose**

Called to handle item transfer requests

**When Called**

When a player requests to transfer an item

---

### InitializeStorage

**Purpose**

Called to initialize storage

**When Called**

When a storage entity is being initialized

---

### InitializedConfig

**Purpose**

Called when configuration is initialized

**When Called**

When the configuration system has finished loading

---

### InitializedItems

**Purpose**

Called when items are initialized

**When Called**

When the item system has finished loading

---

### InitializedKeybinds

**Purpose**

Called when keybinds are initialized

**When Called**

When the keybind system has finished loading

---

### InitializedModules

**Purpose**

Called when modules are initialized

**When Called**

When the module system has finished loading

---

### InitializedOptions

**Purpose**

Called when options are initialized

**When Called**

When the option system has finished loading

---

### InitializedSchema

**Purpose**

Called when schema is initialized

**When Called**

When the schema system has finished loading

---

### InteractionMenuClosed

**Purpose**

Called when the interaction menu is closed

**When Called**

When the interaction menu UI is closed

---

### InteractionMenuOpened

**Purpose**

Called when the interaction menu is opened

**When Called**

When the interaction menu UI is opened

---

### InterceptClickItemIcon

**Purpose**

Called when an item icon is clicked

**When Called**

When a player clicks on an item icon in inventory

---

### InventoryClosed

**Purpose**

Called when an inventory is closed

**When Called**

When a player closes an inventory panel

---

### InventoryDataChanged

**Purpose**

Called when inventory data changes

**When Called**

When an inventory's data is modified

---

### InventoryDeleted

**Purpose**

Called when an inventory is deleted

**When Called**

When an inventory is removed from the system

---

### InventoryInitialized

**Purpose**

Called when an inventory is initialized

**When Called**

When an inventory is first created and set up

---

### InventoryItemAdded

**Purpose**

Called when an item is added to an inventory

**When Called**

When an item is placed into an inventory

---

### InventoryItemDataChanged

**Purpose**

Called when an item's data changes in an inventory

**When Called**

When an item's data is modified while in an inventory

---

### InventoryItemIconCreated

**Purpose**

Called when an inventory item icon is created

**When Called**

When building the visual icon for an item in inventory

**Parameters**

* `quantityLabel:SetPos(icon:GetWide()` (*quantityLabel*): GetWide() - 5, 5)

---

### InventoryItemRemoved

**Purpose**

Called when an item is removed from an inventory

**When Called**

When an item is taken out of an inventory

---

### InventoryOpened

**Purpose**

Called when an inventory is opened

**When Called**

When a player opens an inventory panel

**Parameters**

* `title:SetText("Inventory` (*" .. char*): getName())

---

### InventoryPanelCreated

**Purpose**

Called when an inventory panel is created

**When Called**

When building an inventory UI panel

---

### IsCharFakeRecognized

**Purpose**

Called to check if a character is fake recognized

**When Called**

When checking if a character appears recognized but isn't truly

---

### IsCharRecognized

**Purpose**

Called to check if a character is recognized

**When Called**

When checking if one character recognizes another

---

### IsRecognizedChatType

**Purpose**

Called to check if a chat type requires recognition

**When Called**

When determining if players need to be recognized to see names in chat

---

### IsSuitableForTrunk

**Purpose**

Called to check if an entity is suitable for trunk storage

**When Called**

When determining if an entity can be used as a trunk/storage

---

### IsValid

**Purpose**

Called to validate an entity

**When Called**

When checking if an entity reference is valid

---

### ItemCombine

**Purpose**

Called when items are combined

**When Called**

When a player attempts to combine two items

---

### ItemDataChanged

**Purpose**

Called when an item's data changes

**When Called**

When an item's data is modified

---

### ItemDefaultFunctions

**Purpose**

Called to get default functions for an item

**When Called**

When building the default interaction functions for an item

---

### ItemDeleted

**Purpose**

Called when an item is deleted

**When Called**

When an item is removed from the system

---

### ItemDraggedOutOfInventory

**Purpose**

Called when an item is dragged out of inventory

**When Called**

When a player drags an item outside the inventory panel

---

### entity

**Purpose**

Called when an item function is called

**When Called**

When a player uses an item function

---

### ItemFunctionCalled

**Purpose**

Called when an item function is called

**When Called**

When a player uses an item function

---

### ItemInitialized

**Purpose**

Called when an item is initialized

**When Called**

When an item is first created and set up

---

### ItemPaintOver

**Purpose**

Called to paint over an item icon

**When Called**

When rendering additional graphics on an item icon

---

### ItemQuantityChanged

**Purpose**

Called when an item's quantity changes

**When Called**

When the stack size of an item is modified

---

### ItemShowEntityMenu

**Purpose**

Called to show entity menu for an item

**When Called**

When displaying the interaction menu for an item entity

---

### ItemTransfered

**Purpose**

Called when an item is transferred between inventories

**When Called**

When an item is successfully moved from one inventory to another

---

### KeyLock

**Purpose**

Called when a key locks an entity

**When Called**

When a key is used to lock a door or entity

---

### KeyUnlock

**Purpose**

Called when a key unlocks an entity

**When Called**

When a key is used to unlock a door or entity

---

### KeybindsLoaded

**Purpose**

Called when keybinds are loaded

**When Called**

After all keybinds have been initialized

---

### KickedFromChar

**Purpose**

Called when a player is kicked from a character

**When Called**

When a player is forcibly removed from their character

---

### LiliaLoaded

**Purpose**

Called when Lilia framework is fully loaded

**When Called**

After all Lilia systems are initialized

---

### LiliaTablesLoaded

**Purpose**

Called when Lilia database tables are loaded

**When Called**

After database tables are created/loaded

---

### LoadCharInformation

**Purpose**

Called to load character information

**When Called**

When character data needs to be loaded

---

### LoadData

**Purpose**

Called to load persistent data

**When Called**

When data needs to be loaded from storage

---

### LoadMainMenuInformation

**Purpose**

Called to load main menu information

**When Called**

When building the main menu character information

---

### ModifyCharacterModel

**Purpose**

Called to modify a character's model

**When Called**

When a character's model is being set

---

### ModifyScoreboardModel

**Purpose**

Called to modify a player's model on the scoreboard

**When Called**

When rendering a player's model in the scoreboard

---

### NetVarChanged

**Purpose**

Called when a network variable changes

**When Called**

When an entity's netvar is modified

---

### OnAdminStickMenuClosed

**Purpose**

Called when admin stick menu is closed

**When Called**

When the admin stick context menu is closed

---

### OnAdminSystemLoaded

**Purpose**

Called when admin system is loaded

**When Called**

After admin groups and privileges are initialized

---

### OnBackupCreated

**Purpose**

Called when a backup is created

**When Called**

After a data backup is successfully created

---

### OnCharAttribBoosted

**Purpose**

Called when a character attribute is boosted

**When Called**

When a character's attribute is increased

---

### OnCharAttribUpdated

**Purpose**

Called when a character attribute is updated

**When Called**

When a character's attribute value changes

---

### OnCharCreated

**Purpose**

Called when a character is created

**When Called**

When a new character is successfully created

---

### OnCharDelete

**Purpose**

Called when a character is deleted

**When Called**

When a character is successfully deleted

---

### OnCharDisconnect

**Purpose**

Called when a character disconnects

**When Called**

When a player disconnects while having a character loaded

---

### OnCharFallover

**Purpose**

Called when a character falls over

**When Called**

When a character is knocked down/ragdolled

---

### OnCharFlagsGiven

**Purpose**

Called when flags are given to a character

**When Called**

When a character receives new flags

---

### OnCharFlagsTaken

**Purpose**

Called when flags are taken from a character

**When Called**

When a character loses flags

---

### OnCharGetup

**Purpose**

Called when a character gets up from being unconscious

**When Called**

When a character regains consciousness or is revived

---

### OnCharKick

**Purpose**

Called when a character is kicked

**When Called**

When a character is kicked from the server

---

### OnCharNetVarChanged

**Purpose**

Called when a character's network variable changes

**When Called**

When a character's networked data is modified

---

### OnCharPermakilled

**Purpose**

Called when a character is permanently killed

**When Called**

When a character is permanently removed from the game

---

### OnCharRecognized

**Purpose**

Called when a character recognizes another character

**When Called**

When a character successfully identifies another character

---

### OnCharTradeVendor

**Purpose**

Called when a character trades with a vendor

**When Called**

When a character buys or sells items to/from a vendor

---

### OnCharVarChanged

**Purpose**

Called when a character's variable changes

**When Called**

When a character's data variable is modified

---

### OnCharacterCreated

**Purpose**

Called when a character is created

**When Called**

When a new character is successfully created

---

### OnCharacterDeath

**Purpose**

Called when a character dies

**When Called**

When a character's health reaches zero or they are killed

**Parameters**

* `character:setMoney(character:getMoney()` (*unknown*): moneyLoss)
* `character:setMoney(character:getMoney()` (*unknown*): moneyLoss)

---

### OnCharacterDeleted

**Purpose**

Called when a character is deleted

**When Called**

When a character is successfully deleted from the database

---

### OnCharacterFieldsUpdated

**Purpose**

Called when character fields are updated

**When Called**

When character field definitions are modified or updated

---

### OnCharacterLoaded

**Purpose**

Called when a character is loaded

**When Called**

When a character is successfully loaded for a player

---

### OnCharacterRevive

**Purpose**

Called when a character is revived

**When Called**

When a character is brought back to life from unconsciousness

---

### OnCharacterSchemaValidated

**Purpose**

Called when character schema validation is completed

**When Called**

When character schema validation finishes

---

### OnCharacterUpdated

**Purpose**

Called when a character is updated

**When Called**

When a character's data is modified and saved

---

### OnCharactersRestored

**Purpose**

Called when characters are restored from backup

**When Called**

When character data is restored from a backup

---

### OnChatReceived

**Purpose**

Called when a chat message is received

**When Called**

When a player receives a chat message

---

### OnCheaterCaught

**Purpose**

Called when a cheater is caught

**When Called**

When anti-cheat systems detect cheating behavior

**Parameters**

* `os.date("%Y` (*%m-%d %H*): %M:%S"), client:Name(), steamID, ip)

---

### OnCheaterStatusChanged

**Purpose**

Called when a cheater's status changes

**When Called**

When a player's cheater status is modified

---

### OnColumnAdded

**Purpose**

Called when a database column is added

**When Called**

When a new column is added to a database table

---

### OnColumnRemoved

**Purpose**

Called when a database column is removed

**When Called**

When a column is removed from a database table

---

### OnConfigUpdated

**Purpose**

Called when a configuration is updated

**When Called**

When a configuration value is changed

---

### OnCreateItemInteractionMenu

**Purpose**

Called when creating an item interaction menu

**When Called**

When building the context menu for an item

---

### OnCreatePlayerRagdoll

**Purpose**

Called when creating a player ragdoll

**When Called**

When a player ragdoll is being created

---

### OnCreateStoragePanel

**Purpose**

Called when creating a storage panel

**When Called**

When building the storage UI panel

---

### OnDataSet

**Purpose**

Called when data is set

**When Called**

When persistent data is being saved

---

### OnDatabaseConnected

**Purpose**

Called when database connection is established

**When Called**

When the database connection is successfully made

---

### OnDatabaseInitialized

**Purpose**

Called when the database is initialized

**When Called**

After the database connection is established and tables are created

---

### OnDatabaseLoaded

**Purpose**

Called when the database has finished loading all data

**When Called**

After all database operations and data loading is complete

---

### OnDatabaseReset

**Purpose**

Called when the database is reset

**When Called**

When the database is reset to default state

---

### OnDatabaseWiped

**Purpose**

Called when the database is completely wiped

**When Called**

When all database data is permanently deleted

---

### OnDeathSoundPlayed

**Purpose**

Called when a death sound is played

**When Called**

When a player death sound is triggered

---

### OnEntityLoaded

**Purpose**

Called when an entity is loaded from the database

**When Called**

When an entity is restored from saved data

---

### OnEntityPersistUpdated

**Purpose**

Called when an entity's persistent data is updated

**When Called**

When an entity's save data is modified

---

### OnEntityPersisted

**Purpose**

Called when an entity is persisted to the database

**When Called**

When an entity's data is saved to the database

---

### OnFontsRefreshed

**Purpose**

Called when fonts are refreshed

**When Called**

When the font system is reloaded or updated

---

### OnItemAdded

**Purpose**

Called when an item is added to an inventory

**When Called**

When an item is successfully added to any inventory

---

### OnItemCreated

**Purpose**

Called when an item instance is created

**When Called**

When a new item instance is created from an item table

---

### OnItemRegistered

**Purpose**

Called when an item is registered

**When Called**

When a new item is added to the item system

---

### OnItemSpawned

**Purpose**

Called when an item entity is spawned in the world

**When Called**

When an item is dropped or spawned as a world entity

---

### OnItemsTransferred

**Purpose**

Called after items have been successfully transferred between characters

**When Called**

After items are transferred from one character to another

---

### OnLoadTables

**Purpose**

Called when database tables are being loaded

**When Called**

During database initialization when tables are loaded

---

### OnLoaded

**Purpose**

Called when the framework has finished loading

**When Called**

After all framework components have been initialized

---

### OnModuleTableCreated

**Purpose**

Called when a module table is created

**When Called**

When a new module table is registered in the framework

---

### OnModuleTableRemoved

**Purpose**

Called when a module table is removed

**When Called**

When a module is unregistered from the framework

---

### OnOOCMessageSent

**Purpose**

Called when a player sends an OOC (Out of Character) message

**When Called**

When a player sends a message in OOC chat

---

### OnOpenVendorMenu

**Purpose**

Called when a vendor menu is opened

**When Called**

When a player opens a vendor's trading interface

---

### OnPAC3PartTransfered

**Purpose**

Called when a PAC3 part is transferred

**When Called**

When a PAC3 part is moved between players or inventories

---

### OnPainSoundPlayed

**Purpose**

Called when a pain sound is played

**When Called**

When a player pain sound is triggered

---

### OnPickupMoney

**Purpose**

Called when a player picks up money

**When Called**

When a player collects money from the ground

---

### OnPlayerDataSynced

**Purpose**

Called when player data is synchronized

**When Called**

When player data is synced between client and server

---

### OnPlayerDropWeapon

**Purpose**

Called when a player drops a weapon

**When Called**

When a player drops a weapon from their inventory

---

### OnPlayerEnterSequence

**Purpose**

Called when a player enters a sequence

**When Called**

When a player starts a sequence (animation)

---

### OnPlayerInteractItem

**Purpose**

Called when a player interacts with an item

**When Called**

When a player uses an item or performs an action on it

---

### OnPlayerJoinClass

**Purpose**

Called when a player joins a class

**When Called**

When a player successfully joins a new class

---

### OnPlayerLeaveSequence

**Purpose**

Called when a player leaves a sequence

**When Called**

When a player finishes or exits a sequence

---

### OnPlayerLevelUp

**Purpose**

Called when a player levels up

**When Called**

When a player's level increases

---

### OnPlayerLostStackItem

**Purpose**

Called when a player loses a stack item

**When Called**

When a player's stack item is removed or lost

---

### OnPlayerObserve

**Purpose**

Called when a player enters or exits observer mode

**When Called**

When a player starts or stops observing

---

### OnPlayerPurchaseDoor

**Purpose**

Called when a player purchases a door

**When Called**

When a player successfully buys a door

---

### OnPlayerRagdollCreated

**Purpose**

Called when a player ragdoll is created

**When Called**

When a player's ragdoll is spawned (usually on death)

---

### OnPlayerStatsTableCreated

**Purpose**

Called when the player stats table is created

**When Called**

When the player statistics table is initialized

---

### OnPlayerSwitchClass

**Purpose**

Called when a player switches classes

**When Called**

When a player successfully changes their class

---

### OnPlayerXPGain

**Purpose**

Called when a player gains experience points

**When Called**

When a player earns XP from any source

---

### OnPrivilegeRegistered

**Purpose**

Called when a new privilege is registered

**When Called**

When a privilege is added to the system

---

### OnPrivilegeUnregistered

**Purpose**

Called when a privilege is unregistered

**When Called**

When a privilege is removed from the system

---

### OnQuestItemLoaded

**Purpose**

Called when a quest item is loaded

**When Called**

When a quest-related item is loaded into the game

---

### OnRecordUpserted

**Purpose**

Called when a database record is inserted or updated

**When Called**

When a record is upserted in the database

---

### OnRequestItemTransfer

**Purpose**

Called when an item transfer is requested

**When Called**

When a request is made to transfer an item to another inventory

---

### OnRestoreCompleted

**Purpose**

Called when a restore operation completes successfully

**When Called**

After a successful database restore operation

---

### OnRestoreFailed

**Purpose**

Called when a restore operation fails

**When Called**

After a failed database restore operation

---

### OnSalaryAdjust

**Purpose**

Called when a player's salary is adjusted

**When Called**

When a player's salary amount is modified

---

### OnSalaryGiven

**Purpose**

Called when a player receives their salary

**When Called**

When salary is paid to a player

---

### OnSavedItemLoaded

**Purpose**

Called when saved items are loaded

**When Called**

When items are loaded from the database

---

### OnServerLog

**Purpose**

Called when a server log entry is created

**When Called**

When a log message is written to the server log

**Parameters**

* `http.Post("https://logging` (*unknown*): service.com/api/log", {

---

### OnSkillsChanged

**Purpose**

Called when a character's skills are changed

**When Called**

When a character's skill values are modified

---

### OnTableBackedUp

**Purpose**

Called when a database table is backed up

**When Called**

After a database table backup is created

---

### OnTableRemoved

**Purpose**

Called when a database table is removed

**When Called**

After a database table is deleted

---

### OnTableRestored

**Purpose**

Called when a database table is restored

**When Called**

After a database table is restored from a backup

---

### OnTablesReady

**Purpose**

Called when all database tables are ready

**When Called**

After all database tables have been initialized and are ready for use

---

### OnThemeChanged

**Purpose**

Called when the UI theme is changed

**When Called**

When the active theme is switched

---

### OnTicketClaimed

**Purpose**

Called when a support ticket is claimed by an admin

**When Called**

When an admin claims a support ticket

---

### OnTicketClosed

**Purpose**

Called when a support ticket is closed

**When Called**

When a support ticket is resolved and closed

---

### OnTicketCreated

**Purpose**

Called when a new support ticket is created

**When Called**

When a player creates a support ticket

---

### OnTransferFailed

**Purpose**

Called when an item transfer fails

**When Called**

When an attempt to transfer items between characters fails

---

### OnTransferred

**Purpose**

Called when a player is transferred

**When Called**

When a player is successfully transferred

---

### OnUsergroupCreated

**Purpose**

Called when a new usergroup is created

**When Called**

When a usergroup is added to the system

---

### OnUsergroupPermissionsChanged

**Purpose**

Called when usergroup permissions are changed

**When Called**

When a usergroup's permissions are modified

---

### OnUsergroupRemoved

**Purpose**

Called when a usergroup is removed

**When Called**

When a usergroup is deleted from the system

---

### OnUsergroupRenamed

**Purpose**

Called when a usergroup is renamed

**When Called**

When a usergroup's name is changed

---

### OnVendorEdited

**Purpose**

Called when a vendor is edited

**When Called**

When a vendor's properties are modified

---

### OnlineStaffDataReceived

**Purpose**

Called when online staff data is received

**When Called**

When the server receives updated staff information

---

### OpenAdminStickUI

**Purpose**

Called when the admin stick UI is opened

**When Called**

When an admin opens the admin stick interface

---

### OptionChanged

**Purpose**

Called when a configuration option is changed

**When Called**

When a configuration value is modified

---

### OptionReceived

**Purpose**

Called when a client option is received

**When Called**

When the server receives an option setting from a client

---

### OverrideFactionDesc

**Purpose**

Called to override a faction's description

**When Called**

When a faction description needs to be modified

---

### OverrideFactionModels

**Purpose**

Called to override a faction's models

**When Called**

When a faction's available models need to be modified

---

### OverrideFactionName

**Purpose**

Called to override a faction's name

**When Called**

When a faction name needs to be modified

---

### OverrideSpawnTime

**Purpose**

Called to override a player's respawn time

**When Called**

When a player's respawn time needs to be modified

---

### PaintItem

**Purpose**

Called to paint/render an item

**When Called**

When an item needs custom rendering

---

### PlayerAccessVendor

**Purpose**

Called when a player accesses a vendor

**When Called**

When a player interacts with a vendor entity

---

### PlayerCheatDetected

**Purpose**

Called when a player is detected cheating

**When Called**

When anti-cheat systems detect suspicious behavior

---

### PlayerDisconnect

**Purpose**

Called when a player disconnects

**When Called**

When a player leaves the server

---

### PlayerGagged

**Purpose**

Called when a player is gagged

**When Called**

When a player's voice chat is disabled

---

### PlayerLiliaDataLoaded

**Purpose**

Called when a player's Lilia data is loaded

**When Called**

When a player's framework data has been loaded from the database

---

### PlayerLoadedChar

**Purpose**

Called when a player loads a character

**When Called**

When a player successfully loads a character

---

### PlayerMessageSend

**Purpose**

Called when a player sends a message

**When Called**

When a chat message is being sent

---

### PlayerModelChanged

**Purpose**

Called when a player's model changes

**When Called**

When a player's character model is changed

---

### PlayerMuted

**Purpose**

Called when a player is muted

**When Called**

When a player's chat is disabled

---

### PlayerShouldAct

**Purpose**

Called to check if a player should perform an action

**When Called**

When validating player actions

---

### PlayerShouldPermaKill

**Purpose**

Called to check if a player should be permakilled

**When Called**

When a player dies and permakill is being considered

---

### PlayerSpawnPointSelected

**Purpose**

Called when a player spawn point is selected

**When Called**

When determining where a player should spawn

---

### PlayerStaminaDepleted

**Purpose**

Called when player stamina is depleted

**When Called**

When a player runs out of stamina

---

### PlayerStaminaGained

**Purpose**

Called when player gains stamina

**When Called**

When a player's stamina increases

---

### PlayerStaminaLost

**Purpose**

Called when player loses stamina

**When Called**

When a player's stamina decreases

---

### PlayerThrowPunch

**Purpose**

Called when a player throws a punch

**When Called**

When a player uses their fists to attack

---

### PlayerUngagged

**Purpose**

Called when a player is ungagged

**When Called**

When a player's voice chat is re-enabled

---

### PlayerUnmuted

**Purpose**

Called when a player is unmuted

**When Called**

When a player's chat is re-enabled

---

### PlayerUseDoor

**Purpose**

Called when a player uses a door

**When Called**

When a player interacts with a door entity

---

### PopulateAdminStick

**Purpose**

Called to populate the admin stick menu

**When Called**

When building the admin stick context menu

---

### PopulateAdminTabs

**Purpose**

Called to populate admin tabs

**When Called**

When building the admin panel tabs

---

### PopulateConfigurationButtons

**Purpose**

Called to populate configuration buttons

**When Called**

When building the configuration menu

---

### PopulateInventoryItems

**Purpose**

Called to populate inventory items

**When Called**

When building the inventory item list

---

### PostDoorDataLoad

**Purpose**

Called after door data is loaded

**When Called**

After door configuration data is loaded from the database

---

### PostDrawInventory

**Purpose**

Called after drawing the inventory

**When Called**

After the inventory UI has been rendered

---

### PostLoadData

**Purpose**

Called after data is loaded

**When Called**

After all persistent data has been loaded

**Parameters**

* `print("Post` (*unknown*): load initialization completed")

---

### PostLoadFonts

**Purpose**

Called after fonts are loaded

**When Called**

After the font system has been initialized

---

### PostPlayerInitialSpawn

**Purpose**

Called after a player's initial spawn

**When Called**

After a player has fully spawned for the first time

---

### PostPlayerLoadedChar

**Purpose**

Called after a player has loaded a character

**When Called**

After a character has been fully loaded for a player

---

### PostPlayerLoadout

**Purpose**

Called after a player's loadout is given

**When Called**

After a player has received their weapons/equipment

---

### PostPlayerSay

**Purpose**

Called after a player says something in chat

**When Called**

After a chat message has been processed and sent

---

### PostScaleDamage

**Purpose**

Called after damage scaling is calculated

**When Called**

After damage has been scaled but before it's applied

---

### PreCharDelete

**Purpose**

Called before a character is deleted

**When Called**

Before a character deletion is processed

---

### PreDoorDataSave

**Purpose**

Called before door data is saved

**When Called**

Before door configuration data is saved to database

---

### PreDrawPhysgunBeam

**Purpose**

Called before drawing the physgun beam

**When Called**

Before the physgun beam is rendered

---

### PreLiliaLoaded

**Purpose**

Called before Lilia framework is loaded

**When Called**

Before Lilia systems are initialized

---

### PrePlayerInteractItem

**Purpose**

Called before a player interacts with an item

**When Called**

Before an item interaction is processed

---

### PrePlayerLoadedChar

**Purpose**

Called before a player loads a character

**When Called**

Before a character is loaded for a player

---

### PreSalaryGive

**Purpose**

Called before salary is given to a player

**When Called**

Before salary payment is processed

---

### PreScaleDamage

**Purpose**

Called before damage scaling is calculated

**When Called**

Before damage is scaled

---

### RefreshFonts

**Purpose**

Called to refresh fonts

**When Called**

When the font system needs to be refreshed

---

### RegisterPreparedStatements

**Purpose**

Called to register prepared SQL statements

**When Called**

When setting up database prepared statements

---

### RemovePart

**Purpose**

Called when a PAC3 part is removed

**When Called**

When a PAC3 part is detached from a player

---

### RemoveWarning

**Purpose**

Called when a warning is removed

**When Called**

When a character warning is deleted

---

### ResetCharacterPanel

**Purpose**

Called to reset the character panel

**When Called**

When the character panel needs to be refreshed

---

### RunAdminSystemCommand

**Purpose**

Called when an admin system command is run

**When Called**

When an admin command is executed

---

### SaveData

**Purpose**

Called to save persistent data

**When Called**

When data needs to be saved to storage

---

### ScoreboardClosed

**Purpose**

Called when the scoreboard is closed

**When Called**

When the scoreboard UI is closed

---

### ScoreboardOpened

**Purpose**

Called when the scoreboard is opened

**When Called**

When the scoreboard UI is displayed

---

### ScoreboardRowCreated

**Purpose**

Called when a scoreboard row is created

**When Called**

When a player row is added to the scoreboard

---

### ScoreboardRowRemoved

**Purpose**

Called when a scoreboard row is removed

**When Called**

When a player row is removed from the scoreboard

---

### SendPopup

**Purpose**

Called to send a popup message

**When Called**

When displaying a popup to a player

---

### SetupBagInventoryAccessRules

**Purpose**

Called to set up bag inventory access rules

**When Called**

When configuring access rules for a bag inventory

---

### SetupBotPlayer

**Purpose**

Called to set up a bot player

**When Called**

When initializing a bot player

---

### SetupDatabase

**Purpose**

Called to set up the database

**When Called**

When initializing database connections and tables

---

### SetupPACDataFromItems

**Purpose**

Called to set up PAC3 data from items

**When Called**

When configuring PAC3 data based on equipped items

---

### SetupPlayerModel

**Purpose**

Called to set up a player's model

**When Called**

When configuring a player's character model

---

### SetupQuickMenu

**Purpose**

Called to set up the quick menu

**When Called**

When initializing the quick access menu

---

### ShouldAllowScoreboardOverride

**Purpose**

Called to check if scoreboard override should be allowed

**When Called**

When determining if a player can override scoreboard behavior

---

### ShouldBarDraw

**Purpose**

Called to check if a bar should be drawn

**When Called**

When determining if a UI bar should be rendered

---

### ShouldDataBeSaved

**Purpose**

Called to check if data should be saved

**When Called**

When determining if current data should be persisted

---

### ShouldDeleteSavedItems

**Purpose**

Called to check if saved items should be deleted

**When Called**

When determining if old saved items should be cleaned up

---

### ShouldDisableThirdperson

**Purpose**

Called to check if thirdperson should be disabled

**When Called**

When determining if thirdperson view should be blocked

---

### ShouldDrawAmmo

**Purpose**

Called to check if ammo should be drawn

**When Called**

When determining if weapon ammo should be displayed

---

### ShouldDrawEntityInfo

**Purpose**

Called to check if entity info should be drawn

**When Called**

When determining if entity information should be displayed

---

### ShouldDrawPlayerInfo

**Purpose**

Determines if player information should be drawn

**When Called**

When deciding whether to draw player info above a player

---

### ShouldDrawWepSelect

**Purpose**

Called to determine if weapon selection should be drawn

**When Called**

When the system checks if weapon selection UI should be displayed

---

### ShouldHideBars

**Purpose**

Determines if all bars should be hidden

**When Called**

When the bar system is about to render

---

### ShouldMenuButtonShow

**Purpose**

Called to check if a menu button should be shown

**When Called**

When displaying menu buttons

---

### ShouldPlayDeathSound

**Purpose**

Called to check if a death sound should be played

**When Called**

When a player dies

---

### ShouldPlayPainSound

**Purpose**

Called to check if a pain sound should be played

**When Called**

When a player takes damage

---

### ShouldRespawnScreenAppear

**Purpose**

Called to check if the respawn screen should appear

**When Called**

When a player dies

---

### ShouldShowClassOnScoreboard

**Purpose**

Called to check if a class should be shown on the scoreboard

**When Called**

When displaying the scoreboard

---

### ShouldShowFactionOnScoreboard

**Purpose**

Called to check if a faction should be shown on the scoreboard

**When Called**

When displaying the scoreboard

---

### ShouldShowPlayerOnScoreboard

**Purpose**

Called to check if a player should be shown on the scoreboard

**When Called**

When displaying the scoreboard

---

### ShouldSpawnClientRagdoll

**Purpose**

Called to check if a client ragdoll should be spawned

**When Called**

When a player dies

---

### ShowPlayerOptions

**Purpose**

Called to show player options menu

**When Called**

When displaying player options

---

### StorageCanTransferItem

**Purpose**

Called to check if an item can be transferred to storage

**When Called**

When attempting to transfer an item to storage

---

### StorageEntityRemoved

**Purpose**

Called when a storage entity is removed

**When Called**

When a storage entity is deleted or removed

---

### StorageInventorySet

**Purpose**

Called when a storage inventory is set

**When Called**

When a storage entity gets its inventory assigned

---

### StorageItemRemoved

**Purpose**

Called when an item is removed from storage

**When Called**

When an item is removed from a storage inventory

---

### StorageOpen

**Purpose**

Called when storage is opened

**When Called**

When a player opens a storage entity

---

### StorageRestored

**Purpose**

Called when storage is restored

**When Called**

When a storage entity is restored from save data

---

### StorageUnlockPrompt

**Purpose**

Called when storage unlock prompt is shown

**When Called**

When a player attempts to unlock a locked storage

---

### StoreSpawns

**Purpose**

Called to store spawn points

**When Called**

When spawn points are being stored

---

### SyncCharList

**Purpose**

Called to sync character list with client

**When Called**

When character list needs to be synchronized

---

### ThirdPersonToggled

**Purpose**

Called when third person is toggled

**When Called**

When third person view is enabled or disabled

---

### TicketFrame

**Purpose**

Called to create a ticket frame

**When Called**

When displaying a support ticket

---

### TicketSystemClaim

**Purpose**

Called when a ticket is claimed

**When Called**

When a support ticket is claimed by an admin

---

### TicketSystemClose

**Purpose**

Called when a ticket is closed

**When Called**

When a support ticket is closed

---

### TicketSystemCreated

**Purpose**

Called when a ticket is created

**When Called**

When a player creates a support ticket

---

### ToggleLock

**Purpose**

Called when a door lock is toggled

**When Called**

When a door is locked or unlocked

---

### TooltipInitialize

**Purpose**

Called to initialize a tooltip

**When Called**

When a tooltip is being created

---

### TooltipLayout

**Purpose**

Called to layout a tooltip

**When Called**

When a tooltip needs to be laid out

---

### TooltipPaint

**Purpose**

Called to paint a tooltip

**When Called**

When a tooltip is being painted

---

### TransferItem

**Purpose**

Called to transfer an item

**When Called**

When an item is being transferred

---

### TryViewModel

**Purpose**

Called to try to view a model

**When Called**

When attempting to view an entity model

---

### UpdateEntityPersistence

**Purpose**

Called to update entity persistence

**When Called**

When an entity's persistence data needs to be updated

---

### UpdateScoreboardColors

**Purpose**

Called to update scoreboard colors

**When Called**

When scoreboard colors need to be updated

---

### VendorClassUpdated

**Purpose**

Called when a vendor class is updated

**When Called**

When a vendor's allowed classes are modified

---

### VendorEdited

**Purpose**

Called when a vendor is edited

**When Called**

When a vendor's properties are modified

---

### VendorExited

**Purpose**

Called when a vendor is exited

**When Called**

When a player closes a vendor

---

### VendorFactionUpdated

**Purpose**

Called when a vendor faction is updated

**When Called**

When a vendor's allowed factions are modified

---

### VendorItemMaxStockUpdated

**Purpose**

Called when a vendor item max stock is updated

**When Called**

When a vendor item's maximum stock is modified

---

### VendorItemModeUpdated

**Purpose**

Called when a vendor item mode is updated

**When Called**

When a vendor item's mode is modified

---

### VendorItemPriceUpdated

**Purpose**

Called when a vendor item price is updated

**When Called**

When a vendor item's price is modified

---

### VendorItemStockUpdated

**Purpose**

Called when a vendor item stock is updated

**When Called**

When a vendor item's stock is modified

---

### VendorOpened

**Purpose**

Called when a vendor is opened by a player

**When Called**

When a player successfully opens a vendor

---

### VendorSynchronized

**Purpose**

Called when a vendor is synchronized

**When Called**

When vendor data is synced between client and server

---

### VendorTradeEvent

**Purpose**

Called when a vendor trade event occurs

**When Called**

When a player trades with a vendor

---

### VoiceToggled

**Purpose**

Called when voice chat is toggled

**When Called**

When voice chat is enabled or disabled

---

### WarningIssued

**Purpose**

Called when a warning is issued

**When Called**

When a player receives a warning

---

### WarningRemoved

**Purpose**

Called when a warning is removed

**When Called**

When a warning is removed from a player

---

### WeaponCycleSound

**Purpose**

Called to get the weapon cycle sound

**When Called**

When cycling through weapons

---

### WeaponSelectSound

**Purpose**

Called to get the weapon select sound

**When Called**

When selecting a weapon

---

### WebImageDownloaded

**Purpose**

Called when a web image is downloaded

**When Called**

When an image from a URL is successfully downloaded

---

### WebSoundDownloaded

**Purpose**

Called when a web sound is downloaded

**When Called**

When a sound from a URL is successfully downloaded

---

### calcStaminaChange

**Purpose**

Called to calculate stamina change

**When Called**

When calculating how much stamina should change

---

### getData

**Purpose**

Called to get persistent data

**When Called**

When retrieving stored data

---

### setData

**Purpose**

Called to set persistent data

**When Called**

When setting global or character-specific data

---

