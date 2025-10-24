# Player

This page documents the functions and methods in the meta table.

---

### getChar

**Purpose**

Retrieves the player's current character object

**When Called**

When accessing the player's character data or performing character-related operations

---

### tostring

**Purpose**

Retrieves the player's current character object

**When Called**

When accessing the player's character data or performing character-related operations

---

### Name

**Purpose**

Converts the player to a string representation using character name or Steam name

**When Called**

When converting player to string for display, logging, or comparison purposes

---

### doGesture

**Purpose**

Makes the player perform a gesture animation and synchronizes it across clients

**When Called**

When triggering player animations for roleplay, emotes, or visual effects

---

### hasPrivilege

**Purpose**

Checks if the player has a specific administrative privilege

**When Called**

When validating player permissions for commands, features, or access control

---

### removeRagdoll

**Purpose**

Removes the player's ragdoll entity and clears associated blur effect

**When Called**

When cleaning up player ragdoll after respawn, revival, or state changes

---

### isStuck

**Purpose**

Checks if the player is stuck inside a solid object or wall

**When Called**

When detecting collision issues, implementing anti-stuck systems, or validating player position

---

### isNearPlayer

**Purpose**

Checks if the player is within a specified radius of another entity

**When Called**

When implementing proximity-based features, interaction systems, or distance validation

---

### entitiesNearPlayer

**Purpose**

Gets all entities within a specified radius of the player

**When Called**

When implementing area-of-effect systems, proximity detection, or entity scanning

---

### getItemWeapon

**Purpose**

Gets the weapon entity and corresponding item data for the player's active weapon

**When Called**

When accessing weapon properties, validating equipped items, or implementing weapon systems

---

### isRunning

**Purpose**

Checks if the player is currently running (moving faster than walk speed)

**When Called**

When implementing movement-based features, stamina systems, or speed validation

---

### isFamilySharedAccount

**Purpose**

Checks if the player is using a family shared Steam account

**When Called**

When implementing account validation, anti-cheat systems, or account restrictions

---

### getItemDropPos

**Purpose**

Calculates the position where items should be dropped in front of the player

**When Called**

When implementing item dropping, inventory management, or item placement systems

---

### getItems

**Purpose**

Gets all items from the player's character inventory

**When Called**

When accessing player inventory, implementing item systems, or inventory management

---

### getTracedEntity

**Purpose**

Gets the entity that the player is looking at within a specified distance

**When Called**

When implementing interaction systems, targeting, or line-of-sight detection

---

### getTrace

**Purpose**

Performs a hull trace from the player's position to detect collisions and surfaces

**When Called**

When implementing collision detection, surface analysis, or spatial queries

---

### getEyeEnt

**Purpose**

Gets the entity that the player is looking at within a specified distance using eye trace

**When Called**

When implementing precise targeting, interaction systems, or line-of-sight detection

---

### notify

**Purpose**

Sends a notification message to the player

**When Called**

When displaying messages, alerts, or status updates to the player

---

### notifyLocalized

**Purpose**

Sends a localized notification message to the player with string formatting

**When Called**

When displaying translated messages, alerts, or status updates to the player

---

### notifyError

**Purpose**

Sends an error notification message to the player

**When Called**

When displaying error messages, failures, or critical alerts to the player

---

### notifyWarning

**Purpose**

Sends a warning notification message to the player

**When Called**

When displaying warning messages, cautions, or important alerts to the player

---

### notifyInfo

**Purpose**

Sends an informational notification message to the player

**When Called**

When displaying informational messages, tips, or general updates to the player

---

### notifySuccess

**Purpose**

Sends a success notification message to the player

**When Called**

When displaying success messages, achievements, or positive feedback to the player

---

### notifyMoney

**Purpose**

Sends a money-related notification message to the player

**When Called**

When displaying financial transactions, currency changes, or economic updates to the player

---

### notifyAdmin

**Purpose**

Sends an admin notification message to the player

**When Called**

When displaying administrative messages, system alerts, or admin-specific information to the player

---

### notifyErrorLocalized

**Purpose**

Sends a localized error notification message to the player with string formatting

**When Called**

When displaying translated error messages, failures, or critical alerts to the player

---

### notifyWarningLocalized

**Purpose**

Sends a localized warning notification message to the player with string formatting

**When Called**

When displaying translated warning messages, cautions, or important alerts to the player

---

### notifyInfoLocalized

**Purpose**

Sends a localized informational notification message to the player with string formatting

**When Called**

When displaying translated informational messages, tips, or general updates to the player

---

### notifySuccessLocalized

**Purpose**

Sends a localized success notification message to the player with string formatting

**When Called**

When displaying translated success messages, achievements, or positive feedback to the player

---

### notifyMoneyLocalized

**Purpose**

Sends a localized money-related notification message to the player with string formatting

**When Called**

When displaying translated financial transactions, currency changes, or economic updates to the player

---

### notifyAdminLocalized

**Purpose**

Sends a localized admin notification message to the player with string formatting

**When Called**

When displaying translated administrative messages, system alerts, or admin-specific information to the player

---

### canEditVendor

**Purpose**

Checks if the player can edit a specific vendor entity

**When Called**

When validating vendor editing permissions, implementing vendor management systems, or access control

---

### isStaff

**Purpose**

Checks if the player is a staff member based on their user group

**When Called**

When validating staff permissions, implementing staff-only features, or access control systems

---

### isVIP

**Purpose**

Checks if the player is a VIP member based on their user group

**When Called**

When validating VIP permissions, implementing VIP-only features, or access control systems

---

### isStaffOnDuty

**Purpose**

Checks if the player is currently on duty as staff (in staff faction)

**When Called**

When validating active staff status, implementing duty-based features, or staff management systems

---

### hasWhitelist

**Purpose**

Checks if the player has whitelist access to a specific faction

**When Called**

When validating faction access, implementing whitelist systems, or character creation restrictions

---

### getClassData

**Purpose**

Gets the class data for the player's current character class

**When Called**

When accessing character class information, implementing class-based features, or character management

---

### getDarkRPVar

**Purpose**

Gets DarkRP-compatible variable values for the player (currently only supports money)

**When Called**

When implementing DarkRP compatibility, accessing player money, or legacy system integration

---

### getMoney

**Purpose**

Gets the player's current money amount from their character

**When Called**

When accessing player money, implementing economic systems, or financial transactions

---

### canAfford

**Purpose**

Checks if the player can afford a specific amount of money

**When Called**

When validating purchases, implementing economic systems, or checking financial capacity

---

### hasSkillLevel

**Purpose**

Checks if the player has a specific skill level or higher

**When Called**

When validating skill requirements, implementing skill-based features, or character progression systems

---

### meetsRequiredSkills

**Purpose**

Checks if the player meets all required skill levels for a task or feature

**When Called**

When validating complex skill requirements, implementing multi-skill features, or character progression systems

---

### forceSequence

**Purpose**

Forces the player to play a specific animation sequence with optional callback

**When Called**

When implementing cutscenes, animations, or scripted sequences for the player

---

### leaveSequence

**Purpose**

Makes the player leave their current animation sequence and restore normal movement

**When Called**

When ending cutscenes, animations, or scripted sequences for the player

---

### getFlags

**Purpose**

Gets the player's character flags string

**When Called**

When accessing character flags, implementing flag-based features, or character management

---

### giveFlags

**Purpose**

Gives flags to the player's character

**When Called**

When granting character flags, implementing flag-based permissions, or character management

---

### takeFlags

**Purpose**

Takes flags from the player's character

**When Called**

When removing character flags, implementing flag-based permissions, or character management

---

### networkAnimation

**Purpose**

Networks bone animation data to all clients for the player

**When Called**

When implementing custom animations, bone manipulation, or visual effects for the player

---

### getAllLiliaData

**Purpose**

Gets all Lilia data for the player (server-side) or local data (client-side)

**When Called**

When accessing player data storage, implementing data management, or debugging systems

---

### setWaypoint

**Purpose**

Sets a waypoint for the player to navigate to

**When Called**

When implementing navigation systems, quest objectives, or location guidance for the player

---

### getLiliaData

**Purpose**

Gets a specific Lilia data value for the player with optional default

**When Called**

When accessing player data storage, implementing data management, or retrieving stored values

---

### hasFlags

**Purpose**

Checks if the player has any of the specified flags

**When Called**

When validating flag-based permissions, implementing access control, or character management

---

### playTimeGreaterThan

**Purpose**

Checks if the player's play time is greater than a specified amount

**When Called**

When implementing time-based features, veteran rewards, or play time validation

---

### requestOptions

**Purpose**

Requests the player to select from a list of options via a UI dialog

**When Called**

When implementing interactive menus, choice systems, or user input dialogs for the player

---

### requestString

**Purpose**

Requests the player to input a string via a UI dialog

**When Called**

When implementing text input systems, name entry, or string-based user input for the player

---

### requestArguments

**Purpose**

Requests the player to input multiple arguments via a UI dialog

**When Called**

When implementing complex input systems, command interfaces, or multi-parameter user input for the player

---

### binaryQuestion

**Purpose**

Presents a binary question to the player with two options

**When Called**

When implementing yes/no dialogs, confirmation prompts, or binary choice systems for the player

---

### requestButtons

**Purpose**

Presents a custom button dialog to the player with multiple action buttons

**When Called**

When implementing custom action menus, button interfaces, or interactive dialogs for the player

---

### requestDropdown

**Purpose**

Presents a dropdown selection dialog to the player

**When Called**

When implementing selection menus, choice systems, or dropdown interfaces for the player

---

### restoreStamina

**Purpose**

Restores stamina to the player's character

**When Called**

When implementing stamina recovery, rest systems, or character healing for the player

---

### consumeStamina

**Purpose**

Consumes stamina from the player's character

**When Called**

When implementing stamina usage, movement costs, or action requirements for the player

---

### addMoney

**Purpose**

Adds money to the player's character

**When Called**

When implementing economic systems, rewards, or financial transactions for the player

---

### takeMoney

**Purpose**

Takes money from the player's character

**When Called**

When implementing economic systems, penalties, or financial transactions for the player

---

### loadLiliaData

**Purpose**

Loads Lilia data for the player from the database

**When Called**

When initializing player data, loading saved information, or database operations for the player

---

### saveLiliaData

**Purpose**

Saves Lilia data for the player to the database

**When Called**

When saving player data, updating database information, or data persistence for the player

---

### setLiliaData

**Purpose**

Sets a Lilia data value for the player with optional networking and saving control

**When Called**

When storing player data, implementing data management, or updating player information

---

### banPlayer

**Purpose**

Bans the player from the server with a reason and duration

**When Called**

When implementing administrative actions, moderation systems, or player punishment for the player

---

### setAction

**Purpose**

Sets an action for the player with optional duration and callback

**When Called**

When implementing player actions, progress bars, or timed activities for the player

---

### doStaredAction

**Purpose**

Makes the player perform an action by staring at an entity for a specified duration

**When Called**

When implementing interaction systems, examination mechanics, or focused actions for the player

---

### stopAction

**Purpose**

Stops the player's current action and clears action timers

**When Called**

When interrupting player actions, implementing action cancellation, or cleaning up player state

---

### getPlayTime

**Purpose**

Gets the player's total play time in seconds

**When Called**

When calculating play time, implementing time-based features, or displaying player statistics

---

### getSessionTime

**Purpose**

Gets the player's current session time in seconds

**When Called**

When calculating session duration, implementing session-based features, or displaying current session statistics

---

### createRagdoll

**Purpose**

Creates a ragdoll entity for the player with their current appearance and state

**When Called**

When implementing death systems, ragdoll creation, or player state changes

---

### setRagdolled

**Purpose**

Sets the player's ragdoll state (knocked down or standing up)

**When Called**

When implementing knockdown systems, unconsciousness, or player state management

---

### syncVars

**Purpose**

Synchronizes network variables to the player client

**When Called**

When initializing player connection, updating network state, or ensuring client-server synchronization

---

### setNetVar

**Purpose**

Sets a network variable for the player that synchronizes to the client

**When Called**

When updating player state, implementing networked properties, or client-server communication

---

### canOverrideView

**Purpose**

Checks if the player can override their view (third person mode)

**When Called**

When implementing camera systems, view controls, or third person functionality for the player

---

### isInThirdPerson

**Purpose**

Checks if the player is currently in third person mode

**When Called**

When implementing camera systems, view controls, or third person functionality for the player

---

### getPlayTime

**Purpose**

Gets the player's total play time in seconds (client-side version)

**When Called**

When calculating play time, implementing time-based features, or displaying player statistics

---

