# Client-Side Hooks

Client-side hook system for the Lilia framework.

---

Overview

Client-side hooks in the Lilia framework handle UI, rendering, input, and other client-specific functionality; they can be used to customize the user experience and can be overridden or extended by addons and modules.

---

### AddBarField

#### 📋 Purpose
Register a dynamic bar entry to show in the character information panel (e.g., stamina or custom stats).

#### ⏰ When Called
During character info build, before the F1 menu renders the bar sections.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sectionName` | **string** | Localized or raw section label to group the bar under. |
| `fieldName` | **string** | Unique key for the bar entry. |
| `labelText` | **string** | Text shown next to the bar. |
| `minFunc` | **function** | Callback returning the minimum numeric value. |
| `maxFunc` | **function** | Callback returning the maximum numeric value. |
| `valueFunc` | **function** | Callback returning the current numeric value to display. |

#### ↩️ Returns
* nil
Add the bar when valid; return nil to continue other hooks.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AddBarField", "ExampleAddBarField", function(...)
        -- add custom client-side behavior
    end)

```

---

### AddSection

#### 📋 Purpose
Ensure a character information section exists and optionally override its styling and position.

#### ⏰ When Called
When the F1 character info UI is initialized or refreshed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sectionName` | **string** | Localized or raw name of the section (e.g., “generalInfo”). |
| `color` | **Color** | Accent color used for the section header. |
| `priority` | **number** | Sort order; lower numbers appear first. |
| `location` | **number** | Column index in the character info layout. |

#### ↩️ Returns
* nil
Modify or create the section in-place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AddSection", "ExampleAddSection", function(...)
        -- add custom client-side behavior
    end)

```

---

### AddTextField

#### 📋 Purpose
Register a text field for the character information panel.

#### ⏰ When Called
While building character info just before the F1 menu renders.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sectionName` | **string** | Target section to append the field to. |
| `fieldName` | **string** | Unique identifier for the field. |
| `labelText` | **string** | Caption displayed before the value. |
| `valueFunc` | **function** | Callback that returns the string to render. |

#### ↩️ Returns
* nil
Appends the text field if the section exists.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AddTextField", "ExampleAddTextField", function(...)
        -- add custom client-side behavior
    end)

```

---

### AddToAdminStickHUD

#### 📋 Purpose
Add extra lines to the on-screen admin-stick HUD that appears while aiming with the admin stick.

#### ⏰ When Called
Each HUDPaint tick when the admin stick is active and a target is valid.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player using the admin stick. |
| `target` | **Entity** | Entity currently traced by the admin stick. |
| `information` | **table** | Table of strings; insert new lines to show additional info. |

#### ↩️ Returns
* nil
Mutate the information table in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AddToAdminStickHUD", "ExampleAddToAdminStickHUD", function(...)
        -- add custom client-side behavior
    end)

```

---

### AdminPrivilegesUpdated

#### 📋 Purpose
React to privilege list updates pushed from the server (used by the admin stick UI).

#### ⏰ When Called
After the server syncs admin privilege changes to the client.

#### ↩️ Returns
* nil
Perform any client-side refresh logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AdminPrivilegesUpdated", "ExampleAdminPrivilegesUpdated", function(...)
        -- add custom client-side behavior
    end)

```

---

### AdminStickAddModels

#### 📋 Purpose
Provide model and icon overrides for the admin stick spawn menu list.

#### ⏰ When Called
When the admin stick UI collects available models and props to display.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `allModList` | **table** | Table of model entries to be displayed; append or modify entries here. |
| `tgt` | **Entity** | Entity currently targeted by the admin stick. |

#### ↩️ Returns
* nil
Modify allModList in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("AdminStickAddModels", "ExampleAdminStickAddModels", function(...)
        -- add custom client-side behavior
    end)

```

---

### CanDeleteChar

#### 📋 Purpose
Decide whether a client is allowed to delete a specific character.

#### ⏰ When Called
When the delete character button is pressed in the character menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting the deletion. |
| `character` | **Character|table** | Character object slated for deletion. |

#### ↩️ Returns
* boolean
false to block deletion; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanDeleteChar", "ExampleCanDeleteChar", function(...)
        -- add custom client-side behavior
    end)

```

---

### CanDisplayCharInfo

#### 📋 Purpose
Control whether the name above a character can be shown to the local player.

#### ⏰ When Called
Before drawing a player’s overhead information.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The formatted name that would be displayed. |

#### ↩️ Returns
* boolean
false to hide the name; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanDisplayCharInfo", "ExampleCanDisplayCharInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### CanOpenBagPanel

#### 📋 Purpose
Allow or block opening the bag inventory panel for a specific item.

#### ⏰ When Called
When a bag or storage item icon is activated to open its contents.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | The bag item whose inventory is being opened. |

#### ↩️ Returns
* boolean
false to prevent opening; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanOpenBagPanel", "ExampleCanOpenBagPanel", function(...)
        -- add custom client-side behavior
    end)

```

---

### CanPlayerOpenScoreboard

#### 📋 Purpose
Decide whether the scoreboard should open for the requesting client.

#### ⏰ When Called
When the scoreboard key is pressed and before building the panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Player attempting to open the scoreboard. |

#### ↩️ Returns
* boolean
false to block; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerOpenScoreboard", "ExampleCanPlayerOpenScoreboard", function(...)
        -- add custom client-side behavior
    end)

```

---

### CanTakeEntity

#### 📋 Purpose
Determines if a player can take/convert an entity into an item.

#### ⏰ When Called
Before attempting to convert an entity into an item using the take entity keybind.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to take the entity. |
| `targetEntity` | **Entity** | The entity being targeted for conversion. |
| `itemUniqueID` | **string** | The unique ID of the item that would be created. |

#### ↩️ Returns
* boolean
False to prevent taking the entity; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanTakeEntity", "RestrictEntityTaking", function(client, targetEntity, itemUniqueID)
        if targetEntity:IsPlayer() then return false end
        return true
    end)

```

---

### CanPlayerViewInventory

#### 📋 Purpose
Determine if the local player can open their inventory UI.

#### ⏰ When Called
Before spawning any inventory window.

#### ↩️ Returns
* boolean
false to stop the inventory from opening; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerViewInventory", "ExampleCanPlayerViewInventory", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharListColumns

#### 📋 Purpose
Add or adjust columns in the character list panel.

#### ⏰ When Called
Right before the character selection table is rendered.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `columns` | **table** | Table of column definitions; modify in place to add/remove columns. |

#### ↩️ Returns
* nil
Mutate the provided columns table.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharListColumns", "ExampleCharListColumns", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharListEntry

#### 📋 Purpose
Modify how each character entry renders in the character list.

#### ⏰ When Called
For every row when the character list is constructed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entry` | **table** | Data for the character (id, name, faction, etc.). |
| `row` | **Panel** | The row panel being built. |

#### ↩️ Returns
* nil
Customize the row directly.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharListEntry", "ExampleCharListEntry", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharListLoaded

#### 📋 Purpose
Seed character info sections and fields after the client receives the character list.

#### ⏰ When Called
Once the client finishes downloading the character list from the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `newCharList` | **table** | Array of character summaries. |

#### ↩️ Returns
* nil
Perform setup; return false to stop default population.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharListLoaded", "ExampleCharListLoaded", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharListUpdated

#### 📋 Purpose
React to changes between the old and new character lists.

#### ⏰ When Called
After the server sends an updated character list (e.g., after delete/create).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `oldCharList` | **table** | Previous list snapshot. |
| `newCharList` | **table** | Updated list snapshot. |

#### ↩️ Returns
* nil
Handle syncing UI/state.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharListUpdated", "ExampleCharListUpdated", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharLoaded

#### 📋 Purpose
Handle local initialization once a character has fully loaded on the client.

#### ⏰ When Called
After the server confirms the character load and sets netvars.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character|number** | Character object or id that was loaded. |

#### ↩️ Returns
* nil
Perform client-side setup.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharLoaded", "ExampleCharLoaded", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharMenuClosed

#### 📋 Purpose
Cleanup or state changes when the character menu is closed.

#### ⏰ When Called
Right after the character menu panel is removed.

#### ↩️ Returns
* nil
Execute any shutdown logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharMenuClosed", "ExampleCharMenuClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharMenuOpened

#### 📋 Purpose
Perform setup each time the character menu is opened.

#### ⏰ When Called
Immediately after constructing the character menu panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charMenu` | **Panel** | The created menu panel. |

#### ↩️ Returns
* nil
Adjust the panel or block with false.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharMenuOpened", "ExampleCharMenuOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### CharRestored

#### 📋 Purpose
Handle client-side work after a character is restored from deletion.

#### ⏰ When Called
When the server finishes restoring a deleted character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character|number** | The restored character object or id. |

#### ↩️ Returns
* nil
Update UI or caches.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CharRestored", "ExampleCharRestored", function(...)
        -- add custom client-side behavior
    end)

```

---

### ChatAddText

#### 📋 Purpose
Override how chat text is appended to the chat box.

#### ⏰ When Called
Whenever chat text is about to be printed locally.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **any** | First argument passed to chat.AddText. |

#### ↩️ Returns
* nil
Return false to suppress default printing.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ChatAddText", "ExampleChatAddText", function(...)
        -- add custom client-side behavior
    end)

```

---

### ChatboxPanelCreated

#### 📋 Purpose
Adjust the chatbox panel right after it is created.

#### ⏰ When Called
Once the chat UI instance is built client-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Panel** | The chatbox panel instance. |

#### ↩️ Returns
* nil
Modify the panel as needed.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ChatboxPanelCreated", "ExampleChatboxPanelCreated", function(...)
        -- add custom client-side behavior
    end)

```

---

### ChatboxTextAdded

#### 📋 Purpose
Intercept a newly added chat line before it renders in the chatbox.

#### ⏰ When Called
After chat text is parsed but before it is drawn in the panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Panel** | Chat panel or message object being added. |

#### ↩️ Returns
* nil
Modify or cancel rendering by returning false.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ChatboxTextAdded", "ExampleChatboxTextAdded", function(...)
        -- add custom client-side behavior
    end)

```

---

### ChooseCharacter

#### 📋 Purpose
Respond to character selection from the list.

#### ⏰ When Called
When a user clicks the play button on a character slot.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The selected character’s id. |

#### ↩️ Returns
* nil
Proceed with default selection unless false is returned.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ChooseCharacter", "ExampleChooseCharacter", function(...)
        -- add custom client-side behavior
    end)

```

---

### CommandRan

#### 📋 Purpose
React after a command finishes executing client-side.

#### ⏰ When Called
Immediately after a console/chat command is processed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player who ran the command. |
| `command` | **string** | Command name. |
| `arg3` | **table|string** | Arguments or raw text passed. |
| `results` | **any** | Return data from the command handler, if any. |

#### ↩️ Returns
* nil
Use to display extra feedback or analytics.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CommandRan", "ExampleCommandRan", function(...)
        -- add custom client-side behavior
    end)

```

---

### ConfigureCharacterCreationSteps

#### 📋 Purpose
Reorder or add steps to the character creation wizard.

#### ⏰ When Called
When the creation UI is building its step list.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `creationPanel` | **Panel** | The root creation panel containing step definitions. |

#### ↩️ Returns
* nil
Modify the panel or return false to replace defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ConfigureCharacterCreationSteps", "ExampleConfigureCharacterCreationSteps", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateCharacter

#### 📋 Purpose
Validate or mutate character data immediately before it is submitted to the server.

#### ⏰ When Called
When the user presses the final create/submit button.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **table** | Character creation payload (name, model, faction, etc.). |

#### ↩️ Returns
* boolean
false to abort submission; nil/true to continue.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateCharacter", "ExampleCreateCharacter", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateChatboxPanel

#### 📋 Purpose
Called when the chatbox panel needs to be created or recreated.

#### ⏰ When Called
When the chatbox module initializes, when the chatbox panel is closed and needs to be reopened, or when certain chat-related events occur.

#### ↩️ Returns
* nil
The hook doesn't expect a return value but allows for custom chatbox panel setup.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateChatboxPanel", "ExampleCreateChatboxPanel", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateDefaultInventory

#### 📋 Purpose
Choose what inventory implementation to instantiate for a newly created character.

#### ⏰ When Called
After the client finishes character creation but before the inventory is built.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character** | The character being initialized. |

#### ↩️ Returns
* string
Inventory type id to create (e.g., “GridInv”).

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateDefaultInventory", "ExampleCreateDefaultInventory", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateInformationButtons

#### 📋 Purpose
Populate the list of buttons for the Information tab in the F1 menu.

#### ⏰ When Called
When the Information tab is created and ready to collect pages.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pages` | **table** | Table of page descriptors; insert entries with name/icon/build function. |

#### ↩️ Returns
* nil
Fill the pages table.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateInformationButtons", "ExampleCreateInformationButtons", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateInventoryPanel

#### 📋 Purpose
Build the root panel used for displaying an inventory instance.

#### ⏰ When Called
Each time an inventory needs a panel representation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **Inventory** | Inventory object to show. |
| `parent` | **Panel** | Parent UI element the panel should attach to. |

#### ↩️ Returns
* Panel
The created inventory panel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateInventoryPanel", "ExampleCreateInventoryPanel", function(...)
        -- add custom client-side behavior
    end)

```

---

### CreateMenuButtons

#### 📋 Purpose
Register custom tabs for the F1 menu.

#### ⏰ When Called
When the F1 menu initializes its tab definitions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tabs` | **table** | Table of tab constructors keyed by tab id; add new entries to inject tabs. |

#### ↩️ Returns
* nil
Mutate the tabs table.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("CreateMenuButtons", "ExampleCreateMenuButtons", function(...)
        -- add custom client-side behavior
    end)

```

---

### DeleteCharacter

#### 📋 Purpose
Handle client-side removal of a character slot.

#### ⏰ When Called
After a deletion request succeeds.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | ID of the character that was removed. |

#### ↩️ Returns
* nil
Update UI accordingly.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DeleteCharacter", "ExampleDeleteCharacter", function(...)
        -- add custom client-side behavior
    end)

```

---

### DermaSkinChanged

#### 📋 Purpose
React when the active Derma skin changes client-side.

#### ⏰ When Called
Immediately after the skin is switched.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `newSkin` | **string** | Name of the newly applied skin. |

#### ↩️ Returns
* nil
Rebuild or refresh UI if needed.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DermaSkinChanged", "ExampleDermaSkinChanged", function(...)
        -- add custom client-side behavior
    end)

```

---

### DisplayPlayerHUDInformation

#### 📋 Purpose
Inject custom HUD info boxes into the player HUD.

#### ⏰ When Called
Every HUDPaint frame while the player is alive and has a character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player. |
| `hudInfos` | **table** | Array to be filled with info tables (text, position, styling). |

#### ↩️ Returns
* nil
Append to hudInfos; return false to suppress defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DisplayPlayerHUDInformation", "ExampleDisplayPlayerHUDInformation", function(...)
        -- add custom client-side behavior
    end)

```

---

### DoorDataReceived

#### 📋 Purpose
Handle incoming door synchronization data from the server.

#### ⏰ When Called
When the server sends door ownership or data updates.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** | Door entity being updated. |
| `syncData` | **table** | Data payload containing door state/owners. |

#### ↩️ Returns
* nil
Update local state; return false to block default apply.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DoorDataReceived", "ExampleDoorDataReceived", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawCharInfo

#### 📋 Purpose
Add custom lines to the character info overlay drawn above players.

#### ⏰ When Called
Right before drawing info for a player (name/description).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose info is being drawn. |
| `character` | **Character** | Character belonging to the player. |
| `info` | **table** | Array of `{text, color}` rows; append to extend display. |

#### ↩️ Returns
* nil
Modify info in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawCharInfo", "ExampleDrawCharInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawEntityInfo

#### 📋 Purpose
Customize how entity information panels render in the world.

#### ⏰ When Called
When an entity has been marked to display info and is being drawn.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `e` | **Entity** | Target entity. |
| `a` | **number** | Alpha value (0-255) for fade in/out. |
| `pos` | **table|Vector** | Screen position for the info panel (optional). |

#### ↩️ Returns
* nil
Draw your own panel; return true to suppress default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawEntityInfo", "ExampleDrawEntityInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawItemEntityInfo

#### 📋 Purpose
Adjust or add lines for dropped item entity info.

#### ⏰ When Called
When hovering/aiming at a dropped item that is rendering its info.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemEntity` | **Entity** | World entity representing the item. |
| `item` | **Item** | Item table attached to the entity. |
| `infoTable` | **table** | Lines describing the item; modify to add details. |
| `alpha` | **number** | Current alpha used for drawing. |

#### ↩️ Returns
* nil
Change infoTable contents.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawItemEntityInfo", "ExampleDrawItemEntityInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawLiliaModelView

#### 📋 Purpose
Draw extra elements in the character preview model (e.g., held weapon).

#### ⏰ When Called
When the character model view panel paints.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player being previewed. |
| `entity` | **Entity** | The model panel entity. |

#### ↩️ Returns
* nil
Add custom draws; return false to skip default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawLiliaModelView", "ExampleDrawLiliaModelView", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawPlayerRagdoll

#### 📋 Purpose
Draw attachments or cosmetics on a player’s ragdoll entity.

#### ⏰ When Called
During ragdoll RenderOverride when a player’s corpse is rendered.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The ragdoll entity being drawn. |

#### ↩️ Returns
* nil
Perform custom drawing; return false to skip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawPlayerRagdoll", "ExampleDrawPlayerRagdoll", function(...)
        -- add custom client-side behavior
    end)

```

---

### F1MenuClosed

#### 📋 Purpose
React to the F1 menu closing.

#### ⏰ When Called
Immediately after the F1 menu panel is removed.

#### ↩️ Returns
* nil
Run custom cleanup logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("F1MenuClosed", "ExampleF1MenuClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### F1MenuOpened

#### 📋 Purpose
Perform setup when the F1 menu opens.

#### ⏰ When Called
Immediately after the F1 menu is created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `f1MenuPanel` | **Panel** | The opened menu panel. |

#### ↩️ Returns
* nil
Initialize controls or return false to stop defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("F1MenuOpened", "ExampleF1MenuOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### FilterCharModels

#### 📋 Purpose
Whitelist or blacklist models shown in the character creation model list.

#### ⏰ When Called
While building the selectable model list for character creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table** | Table of available model paths; mutate to filter. |

#### ↩️ Returns
* nil
Modify the table; return false to block default filtering.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("FilterCharModels", "ExampleFilterCharModels", function(...)
        -- add custom client-side behavior
    end)

```

---

### FilterDoorInfo

#### 📋 Purpose
Adjust door information before it is shown on the HUD.

#### ⏰ When Called
After door data is prepared for display but before drawing text.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The door being inspected. |
| `doorData` | **table** | Raw door data (owners, title, etc.). |
| `doorInfo` | **table** | Table of display lines; mutate to change output. |

#### ↩️ Returns
* nil
Modify doorInfo in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("FilterDoorInfo", "ExampleFilterDoorInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetAdjustedPartData

#### 📋 Purpose
Provide PAC part data overrides before parts attach to a player.

#### ⏰ When Called
When a PAC part is requested for attachment.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wearer` | **Player** | Player the part will attach to. |
| `id` | **string** | Identifier for the part/item. |

#### ↩️ Returns
* table
Adjusted part data; return nil to use cached defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetAdjustedPartData", "ExampleGetAdjustedPartData", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterCreateButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the character creation button.

#### ⏰ When Called
When the character creation button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |
| `currentChars` | **number** | Number of characters the player currently has. |
| `maxChars` | **number** | Maximum number of characters allowed. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterCreateButtonTooltip", "ExampleGetCharacterCreateButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterDisconnectButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the character disconnect button.

#### ⏰ When Called
When the character disconnect button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterDisconnectButtonTooltip", "ExampleGetCharacterDisconnectButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterDiscordButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the Discord button.

#### ⏰ When Called
When the Discord button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |
| `discordURL` | **string** | The Discord server URL. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterDiscordButtonTooltip", "ExampleGetCharacterDiscordButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterLoadButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the character load button.

#### ⏰ When Called
When the character load button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterLoadButtonTooltip", "ExampleGetCharacterLoadButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterLoadMainButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the main character load button.

#### ⏰ When Called
When the main character load button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterLoadMainButtonTooltip", "ExampleGetCharacterLoadMainButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterMountButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the character mount button.

#### ⏰ When Called
When the character mount button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterMountButtonTooltip", "ExampleGetCharacterMountButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterReturnButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the character return button.

#### ⏰ When Called
When the character return button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterReturnButtonTooltip", "ExampleGetCharacterReturnButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterStaffButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the staff character button.

#### ⏰ When Called
When the staff character button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |
| `hasStaffChar` | **boolean** | Whether the player has a staff character. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterStaffButtonTooltip", "ExampleGetCharacterStaffButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetCharacterWorkshopButtonTooltip

#### 📋 Purpose
Allows overriding the tooltip text for the workshop button.

#### ⏰ When Called
When the workshop button tooltip is being determined in the main menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player viewing the menu. |
| `workshopURL` | **string** | The workshop URL. |

#### ↩️ Returns
* string|nil
Custom tooltip text, or nil to use default tooltip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetCharacterWorkshopButtonTooltip", "ExampleGetCharacterWorkshopButtonTooltip", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetAdminESPTarget

#### 📋 Purpose
Choose the entity that admin ESP should highlight.

#### ⏰ When Called
When the admin ESP overlay evaluates the current trace target.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | Entity under the admin’s crosshair. |
| `client` | **Player** | Admin requesting the ESP target. |

#### ↩️ Returns
* Entity|nil
Replacement target entity, or nil to use the traced entity.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetAdminESPTarget", "ExampleGetAdminESPTarget", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetAdminStickLists

#### 📋 Purpose
Contribute additional tab lists for the admin stick menu.

#### ⏰ When Called
While compiling list definitions for the admin stick UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tgt` | **Entity** | Current admin stick target. |
| `lists` | **table** | Table of list definitions; append your own entries. |

#### ↩️ Returns
* nil
Modify lists in place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetAdminStickLists", "ExampleGetAdminStickLists", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetDisplayedDescription

#### 📋 Purpose
Override the description text shown for a player.

#### ⏰ When Called
When building a player’s info panel for HUD or menus.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player being described. |
| `isHUD` | **boolean** | True when drawing the 3D HUD info; false for menus. |

#### ↩️ Returns
* string
Description to display; return nil to use default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetDisplayedDescription", "ExampleGetDisplayedDescription", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetDoorInfo

#### 📋 Purpose
Build or modify door info data before it is shown to players.

#### ⏰ When Called
When a door is targeted and info lines are generated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Door entity. |
| `doorData` | **table** | Data about owners, titles, etc. |
| `doorInfo` | **table** | Display lines; modify to add/remove fields. |

#### ↩️ Returns
* nil
Update doorInfo; return false to block defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetDoorInfo", "ExampleGetDoorInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetDoorInfoForAdminStick

#### 📋 Purpose
Supply extra admin-only door info shown in the admin stick UI.

#### ⏰ When Called
When the admin stick inspects a door and builds its detail view.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Entity** | Door or entity being inspected. |
| `extraInfo` | **table** | Table of strings to display; append data here. |

#### ↩️ Returns
* nil
Modify extraInfo.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetDoorInfoForAdminStick", "ExampleGetDoorInfoForAdminStick", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetInjuredText

#### 📋 Purpose
Return the localized injury descriptor and color for a player.

#### ⏰ When Called
When drawing player info overlays that show health status.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c` | **Player** | Target player. |

#### ↩️ Returns
* table
`{text, color}` describing injury level, or nil to skip.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetInjuredText", "ExampleGetInjuredText", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetMainCharacterID

#### 📋 Purpose
Decide which character ID should be treated as the “main” one for menus.

#### ⏰ When Called
Before selecting or loading the default character in the main menu.

#### ↩️ Returns
* number
Character ID to treat as primary, or nil for default logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetMainCharacterID", "ExampleGetMainCharacterID", function(...)
        -- add custom client-side behavior
    end)

```

---

### GetMainMenuPosition

#### 📋 Purpose
Provide camera position/angles for the 3D main menu scene.

#### ⏰ When Called
Each time the main menu loads and needs a camera transform.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character** | Character to base the position on. |

#### ↩️ Returns
* Vector, Angle
Position and angle to use; return nils to use defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("GetMainMenuPosition", "ExampleGetMainMenuPosition", function(...)
        -- add custom client-side behavior
    end)

```

---

### InteractionMenuClosed

#### 📋 Purpose
Handle logic when the interaction menu (context quick menu) closes.

#### ⏰ When Called
Right after the interaction menu panel is removed.

#### ↩️ Returns
* nil
Run cleanup logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InteractionMenuClosed", "ExampleInteractionMenuClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### InteractionMenuOpened

#### 📋 Purpose
Set up the interaction menu when it is created.

#### ⏰ When Called
Immediately after the interaction menu frame is instantiated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frame` | **Panel** | The interaction menu frame. |

#### ↩️ Returns
* nil
Customize the frame as needed.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InteractionMenuOpened", "ExampleInteractionMenuOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### InterceptClickItemIcon

#### 📋 Purpose
Intercept mouse/keyboard clicks on an inventory item icon.

#### ⏰ When Called
Whenever an inventory icon receives an input event.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventoryPanel` | **Panel** | Panel hosting the inventory grid. |
| `itemIcon` | **Panel** | Icon that was clicked. |
| `keyCode` | **number** | Mouse or keyboard code that triggered the event. |

#### ↩️ Returns
* boolean
true to consume the click and prevent default behavior.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InterceptClickItemIcon", "ExampleInterceptClickItemIcon", function(...)
        -- add custom client-side behavior
    end)

```

---

### InventoryClosed

#### 📋 Purpose
React when an inventory window is closed.

#### ⏰ When Called
Immediately after an inventory panel is removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventoryPanel` | **Panel** | The panel that was closed. |
| `inventory` | **Inventory** | Inventory instance tied to the panel. |

#### ↩️ Returns
* nil
Cleanup or save state.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InventoryClosed", "ExampleInventoryClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### InventoryItemDataChanged

#### 📋 Purpose
Respond to item data changes that arrive on the client.

#### ⏰ When Called
After an item’s data table updates (networked from the server).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | The item that changed. |
| `key` | **string** | Data key that changed. |
| `oldValue` | **any** | Previous value. |
| `newValue` | **any** | New value. |
| `inventory` | **Inventory** | Inventory containing the item. |

#### ↩️ Returns
* nil
Refresh UI or derived state.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InventoryItemDataChanged", "ExampleInventoryItemDataChanged", function(...)
        -- add custom client-side behavior
    end)

```

---

### InventoryItemIconCreated

#### 📋 Purpose
Customize an inventory item icon immediately after it is created.

#### ⏰ When Called
When a new icon panel is spawned for an item.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `icon` | **Panel** | Icon panel. |
| `item` | **Item** | Item represented by the icon. |
| `inventoryPanel` | **Panel** | Parent inventory panel. |

#### ↩️ Returns
* nil
Apply visual tweaks.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InventoryItemIconCreated", "ExampleInventoryItemIconCreated", function(...)
        -- add custom client-side behavior
    end)

```

---

### InventoryOpened

#### 📋 Purpose
Handle logic after an inventory panel is opened.

#### ⏰ When Called
When an inventory is displayed on screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Inventory panel. |
| `inventory` | **Inventory** | Inventory instance. |

#### ↩️ Returns
* nil
Perform additional setup.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InventoryOpened", "ExampleInventoryOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### InventoryPanelCreated

#### 📋 Purpose
Customize the inventory panel when it is created.

#### ⏰ When Called
Immediately after constructing a panel for an inventory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The new inventory panel. |
| `inventory` | **Inventory** | Inventory the panel represents. |
| `parent` | **Panel** | Parent container. |

#### ↩️ Returns
* nil
Adjust layout or styling.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("InventoryPanelCreated", "ExampleInventoryPanelCreated", function(...)
        -- add custom client-side behavior
    end)

```

---

### ItemDraggedOutOfInventory

#### 📋 Purpose
Handle dragging an item outside of an inventory grid.

#### ⏰ When Called
When an item is released outside valid slots.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player performing the drag. |
| `item` | **Item** | Item being dragged. |

#### ↩️ Returns
* nil
Decide what to do (drop, cancel, etc.).

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ItemDraggedOutOfInventory", "ExampleItemDraggedOutOfInventory", function(...)
        -- add custom client-side behavior
    end)

```

---

### ItemPaintOver

#### 📋 Purpose
Draw overlays on an item’s icon (e.g., status markers).

#### ⏰ When Called
During icon paint for each inventory slot.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemIcon` | **Panel** | Icon panel being drawn. |
| `itemTable` | **Item** | Item represented. |
| `w` | **number** | Icon width. |
| `h` | **number** | Icon height. |

#### ↩️ Returns
* nil
Perform custom painting.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ItemPaintOver", "ExampleItemPaintOver", function(...)
        -- add custom client-side behavior
    end)

```

---

### ItemShowEntityMenu

#### 📋 Purpose
Show a context menu for a world item entity.

#### ⏰ When Called
When the use key/menu key is pressed on a dropped item with actions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Item entity in the world. |

#### ↩️ Returns
* nil
Build and display the menu; return false to block default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ItemShowEntityMenu", "ExampleItemShowEntityMenu", function(...)
        -- add custom client-side behavior
    end)

```

---

### LoadCharInformation

#### 📋 Purpose
Seed the character information sections for the F1 menu.

#### ⏰ When Called
When the character info is about to be populated.

#### ↩️ Returns
* nil
Add sections/fields via AddSection/AddTextField hooks.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("LoadCharInformation", "ExampleLoadCharInformation", function(...)
        -- add custom client-side behavior
    end)

```

---

### LoadMainCharacter

#### 📋 Purpose
Select and load the player’s main character when the menu opens.

#### ⏰ When Called
During main menu initialization if a saved main character exists.

#### ↩️ Returns
* nil
Trigger loading routines.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("LoadMainCharacter", "ExampleLoadMainCharacter", function(...)
        -- add custom client-side behavior
    end)

```

---

### LoadMainMenuInformation

#### 📋 Purpose
Populate informational text and preview for the main menu character card.

#### ⏰ When Called
When the main menu needs to show summary info for a character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `info` | **table** | Table to fill with display fields. |
| `character` | **Character** | Character being previewed. |

#### ↩️ Returns
* nil
Mutate the info table.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("LoadMainMenuInformation", "ExampleLoadMainMenuInformation", function(...)
        -- add custom client-side behavior
    end)

```

---

### ModifyScoreboardModel

#### 📋 Purpose
Adjust the 3D model used in the scoreboard (pose, skin, etc.).

#### ⏰ When Called
When a scoreboard slot builds its player model preview.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Panel** | Model panel or data table for the slot. |
| `ply` | **Player** | Player represented by the slot. |

#### ↩️ Returns
* nil
Apply modifications directly.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ModifyScoreboardModel", "ExampleModifyScoreboardModel", function(...)
        -- add custom client-side behavior
    end)

```

---

### ModifyVoiceIndicatorText

#### 📋 Purpose
Override the string shown in the voice indicator HUD.

#### ⏰ When Called
Each frame the local player is speaking.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Speaking player (local). |
| `voiceText` | **string** | Default text to display. |
| `voiceType` | **string** | Current voice range (“whispering”, “talking”, “yelling”). |

#### ↩️ Returns
* string
Replacement text; return nil to keep default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ModifyVoiceIndicatorText", "ExampleModifyVoiceIndicatorText", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawPlayerInfoBackground

#### 📋 Purpose
Draw the background panel behind player info overlays.

#### ⏰ When Called
Just before drawing wrapped player info text in the HUD.

#### ↩️ Returns
* boolean
Return false to suppress the default blurred background.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawPlayerInfoBackground", "ExampleDrawPlayerInfoBackground", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnAdminStickMenuClosed

#### 📋 Purpose
Handle state cleanup when the admin stick menu closes.

#### ⏰ When Called
When the admin stick UI window is removed.

#### ↩️ Returns
* nil
Clear cached targets or flags.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnAdminStickMenuClosed", "ExampleOnAdminStickMenuClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnChatReceived

#### 📋 Purpose
React to chat messages received by the local client.

#### ⏰ When Called
After a chat message is parsed and before it is displayed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Sender of the message. |
| `chatType` | **string** | Chat channel identifier. |
| `text` | **string** | Message content. |
| `anonymous` | **boolean** | Whether the message should hide the sender. |

#### ↩️ Returns
* nil
Return false to suppress default handling.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnChatReceived", "ExampleOnChatReceived", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnCreateDualInventoryPanels

#### 📋 Purpose
Customize paired inventory panels when two inventories are shown side by side.

#### ⏰ When Called
Right after both inventory panels are created (e.g., player + storage).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel1` | **Panel** | First inventory panel. |
| `panel2` | **Panel** | Second inventory panel. |
| `inventory1` | **Inventory** | Inventory bound to panel1. |
| `inventory2` | **Inventory** | Inventory bound to panel2. |

#### ↩️ Returns
* nil
Adjust layout or behavior.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnCreateDualInventoryPanels", "ExampleOnCreateDualInventoryPanels", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnCreateItemInteractionMenu

#### 📋 Purpose
Augment the context menu shown when right-clicking an inventory item icon.

#### ⏰ When Called
Immediately after the interaction menu for an item icon is built.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemIcon` | **Panel** | The icon being interacted with. |
| `menu` | **Panel** | The context menu object. |
| `itemTable` | **Item** | Item associated with the icon. |

#### ↩️ Returns
* nil
Add menu options or return false to cancel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnCreateItemInteractionMenu", "ExampleOnCreateItemInteractionMenu", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnCreateStoragePanel

#### 📋 Purpose
Customize the dual-inventory storage panel layout.

#### ⏰ When Called
After the local and storage inventory panels are created for a storage entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `localInvPanel` | **Panel** | Panel showing the player inventory. |
| `storageInvPanel` | **Panel** | Panel showing the storage inventory. |
| `storage` | **Entity|table** | Storage object or entity. |

#### ↩️ Returns
* nil
Adjust panels; return false to block defaults.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnCreateStoragePanel", "ExampleOnCreateStoragePanel", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnLocalVarSet

#### 📋 Purpose
React to a local networked variable being set.

#### ⏰ When Called
Whenever a net var assigned to the local player changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Variable name. |
| `value` | **any** | New value. |

#### ↩️ Returns
* nil
Update client state or UI.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnLocalVarSet", "ExampleOnLocalVarSet", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnOpenVendorMenu

#### 📋 Purpose
Populate the vendor UI when it opens.

#### ⏰ When Called
After the vendor panel is created client-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vendorPanel` | **Panel** | Panel used to display vendor goods. |
| `vendor` | **Entity** | Vendor entity interacted with. |

#### ↩️ Returns
* nil
Modify the panel contents.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnOpenVendorMenu", "ExampleOnOpenVendorMenu", function(...)
        -- add custom client-side behavior
    end)

```

---

### OnlineStaffDataReceived

#### 📋 Purpose
Handle the list of online staff received from the server.

#### ⏰ When Called
When staff data is synchronized to the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `staffData` | **table** | Array of staff entries (name, steamID, duty status). |

#### ↩️ Returns
* nil
Update displays such as admin stick lists.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnlineStaffDataReceived", "ExampleOnlineStaffDataReceived", function(...)
        -- add custom client-side behavior
    end)

```

---

### OpenAdminStickUI

#### 📋 Purpose
Open the admin stick interface for a target entity or player.

#### ⏰ When Called
When the admin stick weapon requests to show its UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tgt` | **Entity** | Target entity/player selected by the admin stick. |

#### ↩️ Returns
* nil
Create the UI; return false to cancel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OpenAdminStickUI", "ExampleOpenAdminStickUI", function(...)
        -- add custom client-side behavior
    end)

```

---

### PaintItem

#### 📋 Purpose
Draw or tint an item icon before it is painted to the grid.

#### ⏰ When Called
Prior to rendering each item icon surface.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item being drawn. |

#### ↩️ Returns
* nil
Perform custom painting.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PaintItem", "ExamplePaintItem", function(...)
        -- add custom client-side behavior
    end)

```

---

### PopulateAdminStick

#### 📋 Purpose
Add tabs and actions to the admin stick UI.

#### ⏰ When Called
While constructing the admin stick menu for the current target.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `currentMenu` | **Panel** | Root menu panel. |
| `currentTarget` | **Entity** | Entity being acted upon. |
| `currentStores` | **table** | Cached admin stick data (lists, categories). |

#### ↩️ Returns
* nil
Populate menu sections.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PopulateAdminStick", "ExamplePopulateAdminStick", function(...)
        -- add custom client-side behavior
    end)

```

---

### PopulateAdminTabs

#### 📋 Purpose
Register admin tabs for the F1 administration menu.

#### ⏰ When Called
When building the admin tab list.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pages` | **table** | Table to append tab definitions `{name, icon, build=function}`. |

#### ↩️ Returns
* nil
Add or reorder tabs.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PopulateAdminTabs", "ExamplePopulateAdminTabs", function(...)
        -- add custom client-side behavior
    end)

```

---

### PopulateConfigurationButtons

#### 📋 Purpose
Add configuration buttons for the options/configuration tab.

#### ⏰ When Called
When creating the configuration pages in the menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pages` | **table** | Collection of page descriptors to populate. |

#### ↩️ Returns
* nil
Insert new pages/buttons.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PopulateConfigurationButtons", "ExamplePopulateConfigurationButtons", function(...)
        -- add custom client-side behavior
    end)

```

---

### PopulateInventoryItems

#### 📋 Purpose
Populate the inventory items tree used in the admin menu.

#### ⏰ When Called
When the inventory item browser is built.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pnlContent` | **Panel** | Content panel to fill. |
| `tree` | **Panel** | Tree/list control to populate. |

#### ↩️ Returns
* nil
Add nodes representing items.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PopulateInventoryItems", "ExamplePopulateInventoryItems", function(...)
        -- add custom client-side behavior
    end)

```

---

### PostDrawInventory

#### 📋 Purpose
Draw additional UI after the main inventory panels are painted.

#### ⏰ When Called
After inventory drawing completes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mainPanel` | **Panel** | Primary inventory panel. |
| `parentPanel` | **Panel** | Parent container. |

#### ↩️ Returns
* nil
Overlay custom elements.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PostDrawInventory", "ExamplePostDrawInventory", function(...)
        -- add custom client-side behavior
    end)

```

---

### PostLoadFonts

#### 📋 Purpose
Adjust fonts after they are loaded.

#### ⏰ When Called
Immediately after main fonts are initialized.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mainFont` | **string** | Primary font name (duplicate parameter kept for API compatibility). |
| `mainFont` | **string** | Alias of the same font name. |

#### ↩️ Returns
* nil
Rebuild derived fonts or sizes.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PostLoadFonts", "ExamplePostLoadFonts", function(...)
        -- add custom client-side behavior
    end)

```

---

### DrawPhysgunBeam

#### 📋 Purpose
Decide whether to draw the physgun beam for the local player.

#### ⏰ When Called
During physgun render.

#### ↩️ Returns
* boolean
false to suppress the beam; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("DrawPhysgunBeam", "ExampleDrawPhysgunBeam", function(...)
        -- add custom client-side behavior
    end)

```

---

### RefreshFonts

#### 📋 Purpose
Recreate or refresh fonts when settings change.

#### ⏰ When Called
After option changes that impact font sizes or faces.

#### ↩️ Returns
* nil
Rebuild font definitions.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("RefreshFonts", "ExampleRefreshFonts", function(...)
        -- add custom client-side behavior
    end)

```

---

### RegisterAdminStickSubcategories

#### 📋 Purpose
Register admin stick subcategories used to group commands.

#### ⏰ When Called
When assembling the category tree for the admin stick.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `categories` | **table** | Table of category -> subcategory mappings; modify in place. |

#### ↩️ Returns
* nil
Add or change subcategories.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("RegisterAdminStickSubcategories", "ExampleRegisterAdminStickSubcategories", function(...)
        -- add custom client-side behavior
    end)

```

---

### ResetCharacterPanel

#### 📋 Purpose
Reset the character panel to its initial state.

#### ⏰ When Called
When the character menu needs to clear cached data/layout.

#### ↩️ Returns
* nil
Perform reset logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ResetCharacterPanel", "ExampleResetCharacterPanel", function(...)
        -- add custom client-side behavior
    end)

```

---

### RunAdminSystemCommand

#### 📋 Purpose
Execute an admin-system command initiated from the UI.

#### ⏰ When Called
When the admin stick or admin menu triggers a command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmd` | **string** | Command identifier. |
| `admin` | **Player** | Admin issuing the command. |
| `victim` | **Entity|Player** | Target of the command. |
| `dur` | **number|string** | Duration parameter if applicable. |
| `reason` | **string** | Optional reason text. |

#### ↩️ Returns
* nil
Allow custom handling; return false to cancel default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("RunAdminSystemCommand", "ExampleRunAdminSystemCommand", function(...)
        -- add custom client-side behavior
    end)

```

---

### ScoreboardClosed

#### 📋 Purpose
Perform teardown when the scoreboard closes.

#### ⏰ When Called
After the scoreboard panel is hidden or destroyed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `scoreboardPanel` | **Panel** | The scoreboard instance that was closed. |

#### ↩️ Returns
* nil
Clean up references or timers.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ScoreboardClosed", "ExampleScoreboardClosed", function(...)
        -- add custom client-side behavior
    end)

```

---

### ScoreboardOpened

#### 📋 Purpose
Initialize the scoreboard after it is created.

#### ⏰ When Called
Right after the scoreboard panel is shown.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `scoreboardPanel` | **Panel** | The scoreboard instance that opened. |

#### ↩️ Returns
* nil
Add extra columns or styling.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ScoreboardOpened", "ExampleScoreboardOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### ScoreboardRowCreated

#### 📋 Purpose
Customize a newly created scoreboard row.

#### ⏰ When Called
When a player slot is added to the scoreboard.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `slot` | **Panel** | Scoreboard row panel. |
| `ply` | **Player** | Player represented by the row. |

#### ↩️ Returns
* nil
Modify the row content.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ScoreboardRowCreated", "ExampleScoreboardRowCreated", function(...)
        -- add custom client-side behavior
    end)

```

---

### ScoreboardRowRemoved

#### 📋 Purpose
React when a scoreboard row is removed.

#### ⏰ When Called
When a player leaves or is otherwise removed from the scoreboard.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `scoreboardPanel` | **Panel** | Scoreboard instance. |
| `ply` | **Player** | Player whose row was removed. |

#### ↩️ Returns
* nil
Update any caches or counts.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ScoreboardRowRemoved", "ExampleScoreboardRowRemoved", function(...)
        -- add custom client-side behavior
    end)

```

---

### SetMainCharacter

#### 📋 Purpose
Set the main character ID for future automatic selection.

#### ⏰ When Called
When the player chooses a character to become their main.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Chosen character ID. |

#### ↩️ Returns
* nil
Persist the selection.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("SetMainCharacter", "ExampleSetMainCharacter", function(...)
        -- add custom client-side behavior
    end)

```

---

### SetupQuickMenu

#### 📋 Purpose
Build the quick access menu when the context menu opens.

#### ⏰ When Called
After the quick menu panel is created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `quickMenuPanel` | **Panel** | Panel that holds quick actions. |

#### ↩️ Returns
* nil
Populate with buttons or pages.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("SetupQuickMenu", "ExampleSetupQuickMenu", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldAllowScoreboardOverride

#### 📋 Purpose
Decide if a player is permitted to override the scoreboard UI.

#### ⏰ When Called
Before applying any scoreboard override logic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting the override. |
| `var` | **any** | Additional context or override data. |

#### ↩️ Returns
* boolean
false to deny override; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldAllowScoreboardOverride", "ExampleShouldAllowScoreboardOverride", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldBarDraw

#### 📋 Purpose
Determine whether a HUD bar should render.

#### ⏰ When Called
When evaluating each registered bar before drawing.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bar` | **table** | Bar definition. |

#### ↩️ Returns
* boolean
false to hide the bar; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldBarDraw", "ExampleShouldBarDraw", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldDisableThirdperson

#### 📋 Purpose
Decide whether third-person mode should be forcibly disabled.

#### ⏰ When Called
When the third-person toggle state changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player toggling third person. |

#### ↩️ Returns
* boolean
false to block third-person; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldDisableThirdperson", "ExampleShouldDisableThirdperson", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldDrawAmmo

#### 📋 Purpose
Let modules veto drawing the ammo HUD for a weapon.

#### ⏰ When Called
Each HUDPaint frame before ammo boxes render.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wpn` | **Weapon** | Active weapon. |

#### ↩️ Returns
* boolean
false to hide ammo; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldDrawAmmo", "ExampleShouldDrawAmmo", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldDrawEntityInfo

#### 📋 Purpose
Control whether an entity should display info when looked at.

#### ⏰ When Called
When deciding if entity info overlays should be generated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `e` | **Entity** | Entity under consideration. |

#### ↩️ Returns
* boolean
false to prevent info; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldDrawEntityInfo", "ExampleShouldDrawEntityInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldDrawPlayerInfo

#### 📋 Purpose
Decide whether player-specific info should be drawn for a target.

#### ⏰ When Called
Before rendering the player info panel above a player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `e` | **Player** | Player entity being drawn. |

#### ↩️ Returns
* boolean
false to hide info; nil/true to draw.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldDrawPlayerInfo", "ExampleShouldDrawPlayerInfo", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldDrawWepSelect

#### 📋 Purpose
Decide if the custom weapon selector should draw for a player.

#### ⏰ When Called
Each frame the selector evaluates visibility.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Local player. |

#### ↩️ Returns
* boolean
false to hide the selector; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldDrawWepSelect", "ExampleShouldDrawWepSelect", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldHideBars

#### 📋 Purpose
Hide all HUD bars based on external conditions.

#### ⏰ When Called
Before drawing any bars on the HUD.

#### ↩️ Returns
* boolean
true to hide all bars; nil/false to render them.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldHideBars", "ExampleShouldHideBars", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldMenuButtonShow

#### 📋 Purpose
Decide whether a button should appear in the menu bar.

#### ⏰ When Called
When building quick menu buttons.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table|string** | Button identifier or data. |

#### ↩️ Returns
* boolean
false to hide; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldMenuButtonShow", "ExampleShouldMenuButtonShow", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldRespawnScreenAppear

#### 📋 Purpose
Control whether the respawn screen should be displayed.

#### ⏰ When Called
When the client dies and the respawn UI might show.

#### ↩️ Returns
* boolean
false to suppress; nil/true to display.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldRespawnScreenAppear", "ExampleShouldRespawnScreenAppear", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldShowCharVarInCreation

#### 📋 Purpose
Determine if a character variable should appear in the creation form.

#### ⏰ When Called
While assembling the list of editable character variables.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Character variable identifier. |

#### ↩️ Returns
* boolean
false to hide; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldShowCharVarInCreation", "ExampleShouldShowCharVarInCreation", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldShowClassOnScoreboard

#### 📋 Purpose
Decide whether to display a player’s class on the scoreboard.

#### ⏰ When Called
When rendering scoreboard rows that include class info.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `clsData` | **table** | Class data table for the player. |

#### ↩️ Returns
* boolean
false to hide class; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldShowClassOnScoreboard", "ExampleShouldShowClassOnScoreboard", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldShowFactionOnScoreboard

#### 📋 Purpose
Decide whether to display a player’s faction on the scoreboard.

#### ⏰ When Called
When rendering a scoreboard row.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player being displayed. |

#### ↩️ Returns
* boolean
false to hide faction; nil/true to show.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldShowFactionOnScoreboard", "ExampleShouldShowFactionOnScoreboard", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldShowPlayerOnScoreboard

#### 📋 Purpose
Decide whether a player should appear on the scoreboard at all.

#### ⏰ When Called
Before adding a player row to the scoreboard.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player under consideration. |

#### ↩️ Returns
* boolean
false to omit the player; nil/true to include.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldShowPlayerOnScoreboard", "ExampleShouldShowPlayerOnScoreboard", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShouldShowQuickMenu

#### 📋 Purpose
Control whether the quick menu should open when the context menu is toggled.

#### ⏰ When Called
When the context menu is opened.

#### ↩️ Returns
* boolean
false to prevent quick menu creation; nil/true to allow.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShouldShowQuickMenu", "ExampleShouldShowQuickMenu", function(...)
        -- add custom client-side behavior
    end)

```

---

### ShowPlayerOptions

#### 📋 Purpose
Populate the options menu for a specific player (e.g., mute, profile).

#### ⏰ When Called
When opening a player interaction context menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | Player the options apply to. |
| `options` | **table** | Table of options to display; modify in place. |

#### ↩️ Returns
* nil
Add or remove entries.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ShowPlayerOptions", "ExampleShowPlayerOptions", function(...)
        -- add custom client-side behavior
    end)

```

---

### StorageOpen

#### 📋 Purpose
Handle the client opening a storage entity inventory.

#### ⏰ When Called
When storage access is approved and panels are about to show.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `storage` | **Entity|table** | Storage entity or custom storage table. |
| `isCar` | **boolean** | True if the storage is a vehicle trunk. |

#### ↩️ Returns
* nil
Build storage panels.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("StorageOpen", "ExampleStorageOpen", function(...)
        -- add custom client-side behavior
    end)

```

---

### StorageUnlockPrompt

#### 📋 Purpose
Prompt the player to unlock a locked storage entity.

#### ⏰ When Called
When the client interacts with a locked storage container.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Storage entity requiring an unlock prompt. |

#### ↩️ Returns
* nil
Show prompt UI; return false to suppress.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("StorageUnlockPrompt", "ExampleStorageUnlockPrompt", function(...)
        -- add custom client-side behavior
    end)

```

---

### ThirdPersonToggled

#### 📋 Purpose
React when the third-person toggle state changes.

#### ⏰ When Called
After third-person mode is turned on or off.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **boolean** | New third-person enabled state. |

#### ↩️ Returns
* nil
Apply additional camera logic.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("ThirdPersonToggled", "ExampleThirdPersonToggled", function(...)
        -- add custom client-side behavior
    end)

```

---

### TooltipInitialize

#### 📋 Purpose
Initialize tooltip contents and sizing for Lilia tooltips.

#### ⏰ When Called
When a tooltip panel is created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `var` | **Panel** | Tooltip panel. |
| `panel` | **Panel** | Source panel that spawned the tooltip. |

#### ↩️ Returns
* nil
Configure markup, padding, and size.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("TooltipInitialize", "ExampleTooltipInitialize", function(...)
        -- add custom client-side behavior
    end)

```

---

### TooltipLayout

#### 📋 Purpose
Control tooltip layout; return true to keep the custom layout.

#### ⏰ When Called
Each frame the tooltip is laid out.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `var` | **Panel** | Tooltip panel. |

#### ↩️ Returns
* boolean
true if a custom layout was applied.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("TooltipLayout", "ExampleTooltipLayout", function(...)
        -- add custom client-side behavior
    end)

```

---

### TooltipPaint

#### 📋 Purpose
Paint the custom tooltip background and contents.

#### ⏰ When Called
When a tooltip panel is drawn.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `var` | **Panel** | Tooltip panel. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |

#### ↩️ Returns
* boolean
true if the tooltip was fully painted.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("TooltipPaint", "ExampleTooltipPaint", function(...)
        -- add custom client-side behavior
    end)

```

---

### VendorExited

#### 📋 Purpose
Handle logic when exiting a vendor menu.

#### ⏰ When Called
After the vendor UI is closed.

#### ↩️ Returns
* nil
Run cleanup tasks.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("VendorExited", "ExampleVendorExited", function(...)
        -- add custom client-side behavior
    end)

```

---

### VendorOpened

#### 📋 Purpose
Perform setup when a vendor menu opens.

#### ⏰ When Called
Immediately after opening the vendor UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vendor` | **Entity|table** | Vendor being accessed. |

#### ↩️ Returns
* nil
Populate panels or return false to abort.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("VendorOpened", "ExampleVendorOpened", function(...)
        -- add custom client-side behavior
    end)

```

---

### VoiceToggled

#### 📋 Purpose
Respond to voice chat being toggled on or off.

#### ⏰ When Called
When the client enables or disables in-game voice.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | **boolean** | New voice toggle state. |

#### ↩️ Returns
* nil
Update voice panels or clean up.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("VoiceToggled", "ExampleVoiceToggled", function(...)
        -- add custom client-side behavior
    end)

```

---

### WeaponCycleSound

#### 📋 Purpose
Play a custom sound when cycling weapons.

#### ⏰ When Called
When the weapon selector changes selection.

#### ↩️ Returns
* string|nil
Sound path to play; nil to use default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("WeaponCycleSound", "ExampleWeaponCycleSound", function(...)
        -- add custom client-side behavior
    end)

```

---

### WeaponSelectSound

#### 📋 Purpose
Play a sound when confirming weapon selection.

#### ⏰ When Called
When the weapon selector picks the highlighted weapon.

#### ↩️ Returns
* string|nil
Sound path to play; nil for default.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("WeaponSelectSound", "ExampleWeaponSelectSound", function(...)
        -- add custom client-side behavior
    end)

```

---

### WebImageDownloaded

#### 📋 Purpose
Handle a downloaded web image asset.

#### ⏰ When Called
After a remote image finishes downloading.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `n` | **string** | Image identifier. |
| `arg2` | **string** | Local path or URL of the image. |

#### ↩️ Returns
* nil
Use the image or cache it.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("WebImageDownloaded", "ExampleWebImageDownloaded", function(...)
        -- add custom client-side behavior
    end)

```

---

### WebSoundDownloaded

#### 📋 Purpose
Handle a downloaded web sound asset.

#### ⏰ When Called
After a remote sound file is fetched.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Sound identifier. |
| `path` | **string** | Local file path where the sound was saved. |

#### ↩️ Returns
* nil
Cache or play the sound as needed.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("WebSoundDownloaded", "ExampleWebSoundDownloaded", function(...)
        -- add custom client-side behavior
    end)

```

---

