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

### AdjustPACPartData

**Purpose**

Allows modification of PAC3 part data before it's applied to a player

**When Called**

When PAC3 parts are being attached to a player, allowing customization

---

### AttachPart

**Purpose**

Attaches a PAC3 part to a player

**When Called**

When a PAC3 part needs to be attached to a player

---

### CanDisplayCharInfo

**Purpose**

Determines if character information should be displayed for a given name

**When Called**

When displaying character information in UI elements

---

### CanOpenBagPanel

**Purpose**

Called to check if a bag panel can be opened

**When Called**

When attempting to open a bag's inventory panel

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

### ChatAddText

**Purpose**

Called to add text to the chat

**When Called**

When text is being added to the chatbox

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

### ChooseCharacter

**Purpose**

Called when a character is chosen

**When Called**

When a player selects a character to play

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

### CreateChat

**Purpose**

Called to create the chat interface

**When Called**

When the chat UI is being initialized

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

### DermaSkinChanged

**Purpose**

Called when derma skin is changed

**When Called**

When the UI skin is changed

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

### GetAdjustedPartData

**Purpose**

Called to get adjusted PAC part data

**When Called**

When retrieving PAC part data with adjustments applied

---

### GetDoorInfoForAdminStick

**Purpose**

Called to get door information for admin stick

**When Called**

When displaying door information in the admin stick HUD

---

### GetInjuredText

**Purpose**

Called to get injured text

**When Called**

When displaying injury status text

---

### GetMainMenuPosition

**Purpose**

Called to get main menu position

**When Called**

When positioning the main menu UI

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

### InitializedKeybinds

**Purpose**

Called when keybinds are initialized

**When Called**

When the keybind system has finished loading

---

### InitializedOptions

**Purpose**

Called when options are initialized

**When Called**

When the option system has finished loading

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

### InventoryItemIconCreated

**Purpose**

Called when an inventory item icon is created

**When Called**

When building the visual icon for an item in inventory

**Parameters**

* `quantityLabel:SetPos(icon:GetWide()` (*quantityLabel*): GetWide() - 5, 5)

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

### ItemPaintOver

**Purpose**

Called to paint over an item icon

**When Called**

When rendering additional graphics on an item icon

---

### ItemShowEntityMenu

**Purpose**

Called to show entity menu for an item

**When Called**

When displaying the interaction menu for an item entity

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

### LoadCharInformation

**Purpose**

Called to load character information

**When Called**

When character data needs to be loaded

---

### LoadMainMenuInformation

**Purpose**

Called to load main menu information

**When Called**

When building the main menu character information

---

### ModifyScoreboardModel

**Purpose**

Called to modify a player's model on the scoreboard

**When Called**

When rendering a player's model in the scoreboard

---

### OnAdminStickMenuClosed

**Purpose**

Called when admin stick menu is closed

**When Called**

When the admin stick context menu is closed

---

### OnChatReceived

**Purpose**

Called when a chat message is received

**When Called**

When a player receives a chat message

---

### OnCreateItemInteractionMenu

**Purpose**

Called when creating an item interaction menu

**When Called**

When building the context menu for an item

---

### OnCreateStoragePanel

**Purpose**

Called when creating a storage panel

**When Called**

When building the storage UI panel

---

### OnDeathSoundPlayed

**Purpose**

Called when a death sound is played

**When Called**

When a player death sound is triggered

---

### OnFontsRefreshed

**Purpose**

Called when fonts are refreshed

**When Called**

When the font system is reloaded or updated

---

### OnOpenVendorMenu

**Purpose**

Called when a vendor menu is opened

**When Called**

When a player opens a vendor's trading interface

---

### OnPainSoundPlayed

**Purpose**

Called when a pain sound is played

**When Called**

When a player pain sound is triggered

---

### OnPlayerDataSynced

**Purpose**

Called when player data is synchronized

**When Called**

When player data is synced between client and server

---

### OnThemeChanged

**Purpose**

Called when the UI theme is changed

**When Called**

When the active theme is switched

---

### OpenAdminStickUI

**Purpose**

Called when the admin stick UI is opened

**When Called**

When an admin opens the admin stick interface

---

### PaintItem

**Purpose**

Called to paint/render an item

**When Called**

When an item needs custom rendering

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

### PostDrawInventory

**Purpose**

Called after drawing the inventory

**When Called**

After the inventory UI has been rendered

---

### PostLoadFonts

**Purpose**

Called after fonts are loaded

**When Called**

After the font system has been initialized

---

### PreDrawPhysgunBeam

**Purpose**

Called before drawing the physgun beam

**When Called**

Before the physgun beam is rendered

---

### RefreshFonts

**Purpose**

Called to refresh fonts

**When Called**

When the font system needs to be refreshed

---

### RemovePart

**Purpose**

Called when a PAC3 part is removed

**When Called**

When a PAC3 part is detached from a player

---

### ResetCharacterPanel

**Purpose**

Called to reset the character panel

**When Called**

When the character panel needs to be refreshed

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

### SetupPACDataFromItems

**Purpose**

Called to set up PAC3 data from items

**When Called**

When configuring PAC3 data based on equipped items

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

### StorageUnlockPrompt

**Purpose**

Called when storage unlock prompt is shown

**When Called**

When a player attempts to unlock a locked storage

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

### TryViewModel

**Purpose**

Called to try to view a model

**When Called**

When attempting to view an entity model

---

### UpdateScoreboardColors

**Purpose**

Called to update scoreboard colors

**When Called**

When scoreboard colors need to be updated

---

### VendorExited

**Purpose**

Called when a vendor is exited

**When Called**

When a player closes a vendor

---

### VendorSynchronized

**Purpose**

Called when a vendor is synchronized

**When Called**

When vendor data is synced between client and server

---

### VoiceToggled

**Purpose**

Called when voice chat is toggled

**When Called**

When voice chat is enabled or disabled

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

