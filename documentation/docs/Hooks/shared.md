# Shared Hooks

Shared hook system for the Lilia framework.

---

Overview

Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.

---

### AdjustCreationData

#### 📋 Purpose
Let schemas modify validated character creation data before it is saved.

#### ⏰ When Called
After creation data is sanitized and validated in `liaCharCreate`, before the final table is merged and written.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `data` | **table** | Sanitized values for registered character variables. |
| `newData` | **table** | Table you can populate with overrides that will be merged into `data`. |
| `originalData` | **table** | Copy of the raw client payload prior to sanitation. |

#### ↩️ Returns
* nil
Mutate `data` or `newData`; return value is ignored.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("AdjustCreationData", "ForcePrefix", function(client, data, newData)
        if data.faction == FACTION_STAFF then newData.name = "[STAFF] " .. (newData.name or data.name) end
    end)

```

---

### AdjustPACPartData

#### 📋 Purpose
Allow items or modules to tweak PAC3 part data before it is attached.

#### ⏰ When Called
Client-side when PAC3 builds part data for an outfit id before `AttachPart` runs.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `wearer` | **Player** | Entity that will wear the PAC part. |
| `id` | **string** | Unique part identifier, usually an item uniqueID. |
| `data` | **table** | PAC3 data table that can be edited. |

#### ↩️ Returns
* table|nil
Return a replacement data table, or nil to keep the modified `data`.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("AdjustPACPartData", "TintPoliceVisors", function(wearer, id, data)
        if wearer:Team() == FACTION_POLICE and data.Material then data.Material = "models/shiny" end
    end)

```

---

### AdjustStaminaOffset

#### 📋 Purpose
Change the stamina delta applied on a tick.

#### ⏰ When Called
Each stamina update before the offset is clamped and written to the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose stamina is being processed. |
| `offset` | **number** | Positive regen or negative drain calculated from movement. |

#### ↩️ Returns
* number|nil
Override for the stamina offset; nil keeps the existing value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("AdjustStaminaOffset", "HeavyArmorTax", function(client, offset)
        if client:GetNWBool("HeavyArmor") then return offset - 1 end
    end)

```

---

### AdvDupe_FinishPasting

#### 📋 Purpose
React when an Advanced Dupe 2 paste finishes under BetterDupe.

#### ⏰ When Called
After AdvDupe2 completes the paste queue so compatibility state can be reset.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tbl` | **table** | Paste context provided by AdvDupe2 (first entry is the player). |

#### ↩️ Returns
* nil
Perform cleanup; return value is ignored.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("AdvDupe_FinishPasting", "ClearTempState", function(info)
        local ply = info[1] and info[1].Player
        if IsValid(ply) then ply.tempBetterDupe = nil end
    end)

```

---

### AttachPart

#### 📋 Purpose
Notify when a PAC3 part is attached to a player.

#### ⏰ When Called
Client-side after PAC3 part data is retrieved and before it is tracked locally.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player receiving the PAC part. |
| `id` | **string** | Identifier of the part or outfit. |

#### ↩️ Returns
* nil
Use for side effects such as bookkeeping.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("AttachPart", "TrackPACAttachment", function(client, id)
        lia.log.add(client, "pacAttach", id)
    end)

```

---

### BagInventoryReady

#### 📋 Purpose
Respond when a bag item finishes creating or loading its child inventory.

#### ⏰ When Called
After a bag instance allocates an inventory (on instancing or restore) and access rules are applied.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bagItem` | **Item** | The bag item that owns the inventory. |
| `inventory` | **Inventory** | Child inventory created for the bag. |

#### ↩️ Returns
* nil
Use for setup such as adding access rules or syncing UI.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("BagInventoryReady", "AutoLabelBag", function(bagItem, inventory)
        inventory:setData("bagName", bagItem:getName())
    end)

```

---

### BagInventoryRemoved

#### 📋 Purpose
React when a bag's inventory is being removed.

#### ⏰ When Called
Before a bag item deletes its child inventory (e.g., on item removal).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bagItem` | **Item** | Bag being removed. |
| `inventory` | **Inventory** | Child inventory scheduled for deletion. |

#### ↩️ Returns
* nil
Perform cleanup such as unloading items.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("BagInventoryRemoved", "DropBagContents", function(bagItem, inv)
        for _, item in pairs(inv:getItems()) do item:transfer(nil, nil, nil, nil, true) end
    end)

```

---

### CalcStaminaChange

#### 📋 Purpose
Calculate the stamina change for a player on a tick.

#### ⏰ When Called
From the stamina timer in the attributes module every 0.25s and on client prediction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player being processed. |

#### ↩️ Returns
* number
Positive regen or negative drain applied to the player's stamina pool.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    function MODULE:CalcStaminaChange(client)
        local offset = self.BaseClass.CalcStaminaChange(self, client)
        if client:IsAdmin() then offset = offset + 1 end
        return offset
    end

```

---

### CalcStaminaChange

#### 📋 Purpose
Calculate the stamina change for a player on a tick.

#### ⏰ When Called
From the stamina timer in the attributes module every 0.25s and on client prediction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player being processed. |

#### ↩️ Returns
* number
Positive regen or negative drain applied to the player's stamina pool.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    function MODULE:CalcStaminaChange(client)
        local offset = self.BaseClass.CalcStaminaChange(self, client)
        if client:IsAdmin() then offset = offset + 1 end
        return offset
    end

```

---

### CanCharBeTransfered

#### 📋 Purpose
Decide whether a character can be transferred to a new faction or class.

#### ⏰ When Called
Before character transfer commands/classes move a character to another faction/class.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tChar` | **Character** | Character being transferred. |
| `faction` | **number|string** | Target faction or class identifier. |
| `arg3` | **number|string** | Current faction or class being left. |

#### ↩️ Returns
* boolean, string|nil
Return false and an optional reason to block the transfer.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanCharBeTransfered", "PreventDuplicateFaction", function(char, factionID)
        if lia.faction.indices[factionID] and lia.faction.indices[factionID].oneCharOnly then
            for _, other in pairs(lia.char.getAll()) do
                if other.steamID == char.steamID and other:getFaction() == factionID then
                    return false, L("charAlreadyInFaction")
                end
            end
        end
    end)

```

---

### CanInviteToClass

#### 📋 Purpose
Control whether a player can invite another player into a class.

#### ⏰ When Called
Before sending a class invite through the team management menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player issuing the invite. |
| `target` | **Player** | Player being invited. |

#### ↩️ Returns
* boolean, string|nil
Return false (optionally with reason) to block the invite.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanInviteToClass", "RestrictByRank", function(client, target)
        if not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)

```

---

### CanInviteToFaction

#### 📋 Purpose
Control whether a player can invite another player into their faction.

#### ⏰ When Called
When a player tries to invite someone to join their faction in the team menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player issuing the invite. |
| `target` | **Player** | Player being invited. |

#### ↩️ Returns
* boolean, string|nil
Return false to deny the invitation with an optional message.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanInviteToFaction", "BlockFullFaction", function(client, target)
        local faction = lia.faction.indices[client:Team()]
        if faction and faction.memberLimit and faction.memberLimit <= faction:countMembers() then
            return false, L("limitFaction")
        end
    end)

```

---

### CanOutfitChangeModel

#### 📋 Purpose
Decide whether an outfit item is allowed to change a player's model.

#### ⏰ When Called
Before an outfit applies its model change during equip or removal.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Outfit attempting to change the player's model. |

#### ↩️ Returns
* boolean
Return false to prevent the outfit from changing the model.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
        return not item.player:getNetVar("NoModelChange", false)
    end)

```

---

### CanPerformVendorEdit

#### 📋 Purpose
Determine if a player can edit a vendor's configuration.

#### ⏰ When Called
When opening the vendor editor or applying vendor changes through the UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player attempting to edit. |
| `vendor` | **Entity** | Vendor entity being edited. |

#### ↩️ Returns
* boolean, string|nil
Return false to block edits with an optional reason.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPerformVendorEdit", "AdminOnlyVendors", function(client, vendor)
        if not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)

```

---

### CanPickupMoney

#### 📋 Purpose
Allow or prevent a player from picking up a money entity.

#### ⏰ When Called
When a player uses a `lia_money` entity to collect currency.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `activator` | **Entity** | Entity attempting to pick up the money (usually a Player). |
| `moneyEntity` | **Entity** | Money entity being collected. |

#### ↩️ Returns
* boolean, string|nil
Return false to block pickup with an optional message.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPickupMoney", "RespectWantedStatus", function(client, money)
        if client:getNetVar("isWanted") then return false, L("cannotPickupWhileWanted") end
    end)

```

---

### CanPlayerChooseWeapon

#### 📋 Purpose
Filter which weapons appear as selectable in the weapon selector.

#### ⏰ When Called
When building the client weapon selection UI before allowing a weapon choice.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `weapon` | **Weapon** | Weapon entity being considered. |

#### ↩️ Returns
* boolean
Return false to hide or block selection of the weapon.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerChooseWeapon", "HideUnsafeWeapons", function(weapon)
        if weapon:GetClass():find("admin") then return false end
    end)

```

---

### CanPlayerCreateChar

#### 📋 Purpose
Allow schemas to veto or validate a character creation attempt.

#### ⏰ When Called
On the server when a player submits the creation form and before processing begins.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `data` | **table** | Raw creation data received from the client. |

#### ↩️ Returns
* boolean, string|nil
Return false and an optional message to deny creation.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerCreateChar", "LimitByPlaytime", function(client)
        if not client:playTimeGreaterThan(3600) then return false, L("needMorePlaytime") end
    end)

```

---

### CanPlayerJoinClass

#### 📋 Purpose
Decide if a player may join a given class.

#### ⏰ When Called
Before assigning a class in the class library and character selection.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting the class. |
| `class` | **number** | Target class index. |
| `info` | **table** | Class data table for convenience. |

#### ↩️ Returns
* boolean, string|nil
Return false to block the class switch with an optional reason.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerJoinClass", "WhitelistCheck", function(client, class, info)
        if info.requiresWhitelist and not client:getChar():getClasswhitelists()[class] then
            return false, L("noWhitelist")
        end
    end)

```

---

### CanPlayerKnock

#### 📋 Purpose
Control whether a player can knock on a door with their hands.

#### ⏰ When Called
When the hands SWEP secondary attack is used on a door entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Player attempting to knock. |
| `arg2` | **Entity** | Door entity being knocked on. |

#### ↩️ Returns
* boolean
Return false to prevent the knock action.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerKnock", "BlockPoliceDoors", function(client, door)
        if door.isPoliceDoor then return false end
    end)

```

---

### CanPlayerModifyConfig

#### 📋 Purpose
Gate whether a player can change a configuration variable.

#### ⏰ When Called
Client- and server-side when a config edit is attempted through the admin tools or config UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player attempting the change. |
| `key` | **string** | Config key being modified. |

#### ↩️ Returns
* boolean, string|nil
Return false to deny the modification with an optional message.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerModifyConfig", "SuperAdminOnly", function(client)
        if not client:IsSuperAdmin() then return false, L("insufficientPermissions") end
    end)

```

---

### CanPlayerRotateItem

#### 📋 Purpose
Determine if a player may rotate an item in an inventory grid.

#### ⏰ When Called
When handling the client drag/drop rotate action for an item slot.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting the rotation. |
| `item` | **Item** | Item instance being rotated. |

#### ↩️ Returns
* boolean, string|nil
Return false to block rotation with an optional error message.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerRotateItem", "LockQuestItems", function(client, item)
        if item:getData("questLocked") then return false, L("itemLocked") end
    end)

```

---

### CanPlayerThrowPunch

#### 📋 Purpose
Gate whether a player is allowed to throw a punch.

#### ⏰ When Called
Before the hands SWEP starts a punch, after playtime and stamina checks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player attempting to punch. |

#### ↩️ Returns
* boolean|string|nil
Return false to stop the punch; optionally return a reason string.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerThrowPunch", "DisallowTiedPlayers", function(client)
        if client:getNetVar("tied") then return false, L("cannotWhileTied") end
    end)

```

---

### CanPlayerUseCommand

#### 📋 Purpose
Decide if a player can execute a specific console/chat command.

#### ⏰ When Called
Each time a command is run through the command library before execution.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player running the command. |
| `command` | **table** | Command definition table. |

#### ↩️ Returns
* boolean, string|nil
Return false to block the command with an optional reason.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanPlayerUseCommand", "RestrictNonStaff", function(client, command)
        if command.adminOnly and not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)

```

---

### CanRunItemAction

#### 📋 Purpose
Control whether an item action should be available.

#### ⏰ When Called
While building item action menus both client-side (UI) and server-side (validation).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tempItem` | **Item** | Item being acted on. |
| `key` | **string** | Action identifier (e.g., "equip", "drop"). |

#### ↩️ Returns
* boolean
Return false to hide or block the action.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CanRunItemAction", "NoDropQuestItems", function(item, action)
        if action == "drop" and item:getData("questLocked") then return false end
    end)

```

---

### CharForceRecognized

#### 📋 Purpose
Force a character to recognize others within a range.

#### ⏰ When Called
When the recognition module sets recognition for every character around a player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player whose character will recognize others. |
| `range` | **string|number** | Range preset ("whisper", "normal", "yell") or numeric distance. |

#### ↩️ Returns
* nil
Perform side effects such as marking characters recognized.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CharForceRecognized", "AlwaysRecognizeStaff", function(ply)
        if ply:IsAdmin() then ply:getChar():giveAllRecognition() end
    end)

```

---

### CharHasFlags

#### 📋 Purpose
Override how character flag checks are evaluated.

#### ⏰ When Called
Whenever `playerMeta:hasFlags` is queried to determine character permissions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose character is being checked. |
| `flags` | **string** | Flag string to test. |

#### ↩️ Returns
* boolean
Return true to force pass, false to force fail, or nil to defer to default logic.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CharHasFlags", "HonorVIP", function(client, flags)
        if client:IsUserGroup("vip") and flags:find("V") then return true end
    end)

```

---

### ChatParsed

#### 📋 Purpose
Modify chat metadata before it is dispatched.

#### ⏰ When Called
After chat parsing but before the chat type and message are sent to recipients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Speaker. |
| `chatType` | **string** | Parsed chat command (ic, ooc, etc.). |
| `message` | **string** | Original chat text. |
| `anonymous` | **boolean** | Whether the message is anonymous. |

#### ↩️ Returns
* string, string, boolean|nil
Optionally return a replacement chatType, message, and anonymous flag.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ChatParsed", "AddOOCPrefix", function(client, chatType, message, anonymous)
        if chatType == "ooc" then return chatType, "[GLOBAL] " .. message, anonymous end
    end)

```

---

### CommandAdded

#### 📋 Purpose
React when a new chat/console command is registered.

#### ⏰ When Called
Immediately after a command is added to the command library.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | **string** | Command identifier. |
| `data` | **table** | Command definition table. |

#### ↩️ Returns
* nil
Use for bookkeeping or adding aliases.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("CommandAdded", "LogCommands", function(name, data)
        print("Command registered:", name, "adminOnly:", data.adminOnly)
    end)

```

---

### ConfigChanged

#### 📋 Purpose
Run logic after a configuration value changes.

#### ⏰ When Called
When a config entry is updated via admin tools or code on the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key that changed. |
| `value` | **any** | New value. |
| `oldValue` | **any** | Previous value. |
| `client` | **Player|nil** | Player who made the change, if any. |

#### ↩️ Returns
* nil
Use for reacting to config updates.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ConfigChanged", "BroadcastChange", function(key, value, old, client)
        if SERVER then lia.log.add(client, "configChanged", key, tostring(old), tostring(value)) end
    end)

```

---

### DoModuleIncludes

#### 📋 Purpose
Customize how module files are included.

#### ⏰ When Called
During module loading in the modularity library for each include path.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | Path of the file being included. |
| `MODULE` | **table** | Module table receiving the include. |

#### ↩️ Returns
* nil
Perform side effects; return value is ignored.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("DoModuleIncludes", "TrackModuleIncludes", function(path, MODULE)
        MODULE.loadedFiles = MODULE.loadedFiles or {}
        table.insert(MODULE.loadedFiles, path)
    end)

```

---

### ForceRecognizeRange

#### 📋 Purpose
Force a character to recognize everyone within a given chat range.

#### ⏰ When Called
By recognition commands to mark nearby characters as recognized.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player whose recognition list is being updated. |
| `range` | **string|number** | Range preset ("whisper", "normal", "yell") or numeric distance. |
| `fakeName` | **string|nil** | Optional fake name to record for recognition. |

#### ↩️ Returns
* nil
Perform side effects such as logging or extra notifications.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ForceRecognizeRange", "LogForcedRecognition", function(ply, range)
        lia.log.add(ply, "charRecognizeRange", tostring(range))
    end)

```

---

### GetAttributeMax

#### 📋 Purpose
Override the maximum level a character can reach for a given attribute.

#### ⏰ When Called
Whenever attribute caps are checked, such as when spending points or granting boosts.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose attribute cap is being queried. |
| `id` | **string** | Attribute identifier. |

#### ↩️ Returns
* number|nil
Maximum allowed level (defaults to infinity).

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetAttributeMax", "HardCapEndurance", function(client, id)
        if id == "end" then return 50 end
    end)

```

---

### GetAttributeStartingMax

#### 📋 Purpose
Define the maximum starting value for an attribute during character creation.

#### ⏰ When Called
While allocating starting attribute points to limit each stat.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `attribute` | **string** | Attribute identifier. |

#### ↩️ Returns
* number|nil
Maximum value allowed at creation; nil falls back to default limits.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetAttributeStartingMax", "LowStartForStrength", function(client, attribute)
        if attribute == "str" then return 5 end
    end)

```

---

### GetCharMaxStamina

#### 📋 Purpose
Specify a character's maximum stamina pool.

#### ⏰ When Called
Whenever stamina is clamped, restored, or initialized.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `char` | **Character** | Character whose stamina cap is being read. |

#### ↩️ Returns
* number|nil
Max stamina value; defaults to `DefaultStamina` config when nil.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetCharMaxStamina", "PerkBonus", function(char)
        if char:hasFlags("S") then return lia.config.get("DefaultStamina", 100) + 25 end
    end)

```

---

### GetDefaultCharDesc

#### 📋 Purpose
Provide a default character description for a faction.

#### ⏰ When Called
During creation validation and adjustment for the `desc` character variable.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `arg2` | **number** | Faction index being created. |
| `data` | **table** | Creation payload. |

#### ↩️ Returns
* string, boolean|nil
Description text and a flag indicating whether to override the player's input.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetDefaultCharDesc", "StaffDesc", function(client, faction)
        if faction == FACTION_STAFF then return L("staffCharacterDiscordSteamID", "n/a", client:SteamID()), true end
    end)

```

---

### GetDefaultCharName

#### 📋 Purpose
Provide a default character name for a faction.

#### ⏰ When Called
During creation validation and adjustment for the `name` character variable.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `faction` | **number** | Target faction index. |
| `data` | **table** | Creation payload. |

#### ↩️ Returns
* string, boolean|nil
Name text and a flag indicating whether to override the player's input.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetDefaultCharName", "StaffTemplate", function(client, faction, data)
        if faction == FACTION_STAFF then return "Staff - " .. client:SteamName(), true end
    end)

```

---

### GetDefaultInventorySize

#### 📋 Purpose
Override the default inventory dimensions a character starts with.

#### ⏰ When Called
During inventory setup on character creation and load.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player owning the character. |
| `char` | **Character** | Character whose inventory size is being set. |

#### ↩️ Returns
* number, number|nil
Inventory width and height; nil values fall back to config defaults.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetDefaultInventorySize", "LargeBagsForStaff", function(client, char)
        if client:IsAdmin() then return 8, 6 end
    end)

```

---

### GetDisplayedName

#### 📋 Purpose
Decide what name is shown for a player in chat based on recognition.

#### ⏰ When Called
Client-side when rendering chat messages to resolve a display name.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Speaker whose name is being displayed. |
| `chatType` | **string** | Chat channel identifier. |

#### ↩️ Returns
* string|nil
Name to display; nil lets the default recognition logic run.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetDisplayedName", "ShowAliasInWhisper", function(client, chatType)
        if chatType == "w" then return client:getChar():getData("alias") end
    end)

```

---

### GetHandsAttackSpeed

#### 📋 Purpose
Adjust the delay between punches for the hands SWEP.

#### ⏰ When Called
Each time the fists are swung to determine the next attack delay.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Player punching. |
| `arg2` | **number** | Default delay before the next punch. |

#### ↩️ Returns
* number|nil
Replacement delay; nil keeps the default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetHandsAttackSpeed", "FasterCombatDrugs", function(client, defaultDelay)
        if client:getNetVar("combatStim") then return defaultDelay * 0.75 end
    end)

```

---

### GetItemDropModel

#### 📋 Purpose
Override the model used when an item spawns as a world entity.

#### ⏰ When Called
When an item entity is created server-side to set its model.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemTable` | **table** | Item definition table. |
| `itemEntity` | **Entity** | Spawned item entity. |

#### ↩️ Returns
* string|nil
Model path to use; nil keeps the item's configured model.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetItemDropModel", "IconicMoneyBag", function(itemTable)
        if itemTable.uniqueID == "moneycase" then return "models/props_c17/briefcase001a.mdl" end
    end)

```

---

### GetMaxPlayerChar

#### 📋 Purpose
Override the maximum number of characters a player may create.

#### ⏰ When Called
When rendering the character list and validating new character creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose limit is being checked. |

#### ↩️ Returns
* number|nil
Maximum character slots; nil falls back to `MaxCharacters` config.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetMaxPlayerChar", "VIPExtraSlot", function(client)
        if client:IsUserGroup("vip") then return (lia.config.get("MaxCharacters") or 5) + 1 end
    end)

```

---

### GetMaxStartingAttributePoints

#### 📋 Purpose
Set the total attribute points available during character creation.

#### ⏰ When Called
On the creation screen when allocating starting attributes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player creating the character. |
| `count` | **number** | Default maximum points. |

#### ↩️ Returns
* number|nil
Maximum points allowed; nil keeps the default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetMaxStartingAttributePoints", "PerkBonusPoints", function(client, count)
        if client:IsAdmin() then return count + 5 end
    end)

```

---

### GetModelGender

#### 📋 Purpose
Identify the gender classification for a player model.

#### ⏰ When Called
When entity meta needs to know if a model is treated as female for voice/animations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | Model path being inspected. |

#### ↩️ Returns
* string|nil
"female" to treat as female, or nil for default male handling.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetModelGender", "CustomFemaleModels", function(model)
        if model:find("female_custom") then return "female" end
    end)

```

---

### GetMoneyModel

#### 📋 Purpose
Pick the world model used by a money entity based on its amount.

#### ⏰ When Called
When a `lia_money` entity initializes and sets its model.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **number** | Amount of currency the entity holds. |

#### ↩️ Returns
* string|nil
Model path override; nil falls back to `MoneyModel` config.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetMoneyModel", "HighValueCash", function(amount)
        if amount >= 1000 then return "models/props_lab/box01a.mdl" end
    end)

```

---

### GetNPCDialogOptions

#### 📋 Purpose
Supply additional dialog options for an NPC conversation.

#### ⏰ When Called
When the client requests dialog options for an NPC and builds the menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Player interacting with the NPC. |
| `arg2` | **Entity** | NPC being talked to. |
| `arg3` | **boolean** | Whether the NPC supports customization options. |

#### ↩️ Returns
* table|nil
Extra dialog options keyed by unique id; nil keeps defaults only.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetNPCDialogOptions", "AddShopGreeting", function(client, npc)
        return {special = {name = "Ask about wares", callback = function() net.Start("npcShop") net.SendToServer() end}}
    end)

```

---

### GetPlayerPunchDamage

#### 📋 Purpose
Adjust fist damage output for a punch.

#### ⏰ When Called
Just before a punch trace applies damage in the hands SWEP.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Punching player. |
| `arg2` | **number** | Default damage. |
| `arg3` | **table** | Context table you may mutate (e.g., `context.damage`). |

#### ↩️ Returns
* number|nil
New damage value; nil uses `context.damage` or the original.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetPlayerPunchDamage", "StrengthAffectsPunch", function(client, damage, ctx)
        local char = client:getChar()
        if char then ctx.damage = ctx.damage + char:getAttrib("str", 0) * 0.2 end
    end)

```

---

### GetPlayerPunchRagdollTime

#### 📋 Purpose
Set how long a target is ragdolled when nonlethal punches knock them down.

#### ⏰ When Called
When a punch would kill a player while lethality is disabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | Attacker. |
| `arg2` | **Entity** | Target player being knocked out. |

#### ↩️ Returns
* number|nil
Ragdoll duration in seconds; nil uses `PunchRagdollTime` config.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetPlayerPunchRagdollTime", "ShorterKO", function(client, target)
        if target:IsAdmin() then return 5 end
    end)

```

---

### GetPriceOverride

#### 📋 Purpose
Override a vendor's buy/sell price for an item.

#### ⏰ When Called
When a vendor calculates price for buying from or selling to a player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vendor` | **Entity** | Vendor entity. |
| `uniqueID` | **string** | Item unique ID being priced. |
| `price` | **number** | Base price before modifiers. |
| `isSellingToVendor` | **boolean** | True if the player is selling an item to the vendor. |

#### ↩️ Returns
* number|nil
Replacement price; nil keeps the existing calculation.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetPriceOverride", "FactionDiscount", function(vendor, uniqueID, price, selling)
        if vendor.factionDiscount and not selling then return math.Round(price * vendor.factionDiscount) end
    end)

```

---

### GetRagdollTime

#### 📋 Purpose
Set the ragdoll duration when a player is knocked out.

#### ⏰ When Called
Whenever `playerMeta:setRagdolled` determines the ragdoll time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player being ragdolled. |
| `time` | **number** | Proposed ragdoll time. |

#### ↩️ Returns
* number|nil
Replacement time; nil keeps the proposed duration.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetRagdollTime", "ShorterStaffRagdoll", function(client, time)
        if client:IsAdmin() then return math.min(time, 5) end
    end)

```

---

### GetVendorSaleScale

#### 📋 Purpose
Apply a global sale/markup scale to vendor transactions.

#### ⏰ When Called
When vendors compute sale or purchase totals.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vendor` | **Entity** | Vendor entity performing the sale. |

#### ↩️ Returns
* number|nil
Multiplier applied to prices (e.g., 0.9 for 10% off); nil keeps vendor defaults.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetVendorSaleScale", "HappyHour", function(vendor)
        if vendor:GetNWBool("happyHour") then return 0.8 end
    end)

```

---

### GetWeaponName

#### 📋 Purpose
Override the display name derived from a weapon when creating an item or showing UI.

#### ⏰ When Called
When generating item data from a weapon or showing weapon names in selectors.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `weapon` | **Entity** | Weapon entity whose name is being resolved. |

#### ↩️ Returns
* string|nil
Custom weapon name; nil falls back to print name.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("GetWeaponName", "PrettySWEPNames", function(weapon)
        return language.GetPhrase(weapon:GetClass() .. "_friendly") or weapon:GetPrintName()
    end)

```

---

### InitializeStorage

#### 📋 Purpose
Initialize a storage entity's inventory rules or data.

#### ⏰ When Called
After a storage entity is created or loaded and before player interaction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Storage entity being prepared. |

#### ↩️ Returns
* nil
Perform setup such as assigning inventory IDs or access rules.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializeStorage", "SetTrunkOwner", function(ent)
        if ent:isVehicle() then ent:setNetVar("storageOwner", ent:GetNWString("owner")) end
    end)

```

---

### InitializedConfig

#### 📋 Purpose
Signal that configuration definitions have been loaded client-side.

#### ⏰ When Called
After the administration config UI finishes building available options.

#### ↩️ Returns
* nil
Use to populate UI or cache config data.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedConfig", "BuildConfigUI", function()
        lia.config.buildList()
    end)

```

---

### InitializedItems

#### 📋 Purpose
Notify that all items have been registered.

#### ⏰ When Called
After item scripts finish loading during initialization.

#### ↩️ Returns
* nil
Use to add global item behaviors or cache lookups.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedItems", "CacheItemIDs", function()
        lia.itemIDCache = table.GetKeys(lia.item.list)
    end)

```

---

### InitializedKeybinds

#### 📋 Purpose
Signal that keybind definitions are loaded.

#### ⏰ When Called
After keybinds are registered during initialization.

#### ↩️ Returns
* nil
Useful for binding post-load UI actions.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedKeybinds", "RegisterCustomBind", function()
        lia.key.addBind("ToggleHUD", KEY_F6, "Toggle HUD", function(client) hook.Run("ToggleHUD") end)
    end)

```

---

### InitializedModules

#### 📋 Purpose
Announce that all modules have finished loading.

#### ⏰ When Called
After module include phase completes, including reloads.

#### ↩️ Returns
* nil
Use to initialize systems that depend on all modules being present.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedModules", "WarmWorkshopCache", function()
        lia.workshop.cache = lia.workshop.gather()
    end)

```

---

### InitializedOptions

#### 📋 Purpose
Notify that all options have been registered and loaded.

#### ⏰ When Called
After the option library finishes loading saved values on the client.

#### ↩️ Returns
* nil
Use to refresh UI or apply option-driven settings.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedOptions", "ApplyThemeOption", function()
        hook.Run("OnThemeChanged", lia.option.get("Theme", "Teal"), false)
    end)

```

---

### InitializedSchema

#### 📋 Purpose
Fire once the schema finishes loading.

#### ⏰ When Called
After schema initialization completes; useful for schema-level setup.

#### ↩️ Returns
* nil
Use to perform final initialization dependent on the full schema.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InitializedSchema", "SetupSchemaData", function()
        lia.schema.setupComplete = true
    end)

```

---

### InventoryDataChanged

#### 📋 Purpose
React to inventory metadata changes.

#### ⏰ When Called
When an inventory's data key is updated and replicated to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `instance` | **Inventory** | Inventory whose data changed. |
| `key` | **string** | Data key. |
| `oldValue` | **any** | Previous value. |
| `value` | **any** | New value. |

#### ↩️ Returns
* nil
Use for UI updates or logic tied to inventory metadata.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InventoryDataChanged", "UpdateBagLabel", function(inv, key, old, new)
        if key == "bagName" then inv:getOwner():notify("Bag renamed to " .. tostring(new)) end
    end)

```

---

### InventoryInitialized

#### 📋 Purpose
Signal that an inventory has finished initializing on the client.

#### ⏰ When Called
After an inventory is created or received over the network.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `instance` | **Inventory** | Inventory that is ready. |

#### ↩️ Returns
* nil
Use to hook UI creation or caching.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InventoryInitialized", "ShowInventoryUI", function(inv)
        if inv:getOwner() == LocalPlayer() then lia.inventory.show(inv) end
    end)

```

---

### InventoryItemAdded

#### 📋 Purpose
React when an item is added to an inventory.

#### ⏰ When Called
After an item successfully enters an inventory, both server- and client-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **Inventory** | Inventory receiving the item. |
| `item` | **Item** | Item instance added. |

#### ↩️ Returns
* nil
Use for logging, UI refresh, or triggers.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InventoryItemAdded", "PlayPickupSound", function(inv, item)
        local owner = inv:getOwner()
        if IsValid(owner) then owner:EmitSound("items/ammocrate_open.wav", 60) end
    end)

```

---

### InventoryItemRemoved

#### 📋 Purpose
React when an item leaves an inventory.

#### ⏰ When Called
After an item is removed from an inventory, optionally preserving the instance.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **Inventory** | Inventory losing the item. |
| `instance` | **Item** | Item removed. |
| `preserveItem` | **boolean** | True if the item instance is kept alive (e.g., dropped) instead of deleted. |

#### ↩️ Returns
* nil
Use for cleanup, UI refresh, or logging.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("InventoryItemRemoved", "LogRemoval", function(inv, item, preserve)
        lia.log.add(inv:getOwner(), "itemRemoved", item.uniqueID, preserve and "preserved" or "deleted")
    end)

```

---

### IsCharFakeRecognized

#### 📋 Purpose
Decide if a character is recognized under a fake name.

#### ⏰ When Called
When checking recognition with fake names enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character** | Character performing the recognition check. |
| `id` | **number** | Target character ID. |

#### ↩️ Returns
* boolean
Return true if recognized via fake name, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("IsCharFakeRecognized", "AlwaysRecognizeSelf", function(character, id)
        if character.id == id then return true end
    end)

```

---

### IsCharRecognized

#### 📋 Purpose
Override whether one character recognizes another.

#### ⏰ When Called
Whenever recognition checks are performed for chat or display logic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **Character** | Character performing the check. |
| `arg2` | **number** | Target character ID. |

#### ↩️ Returns
* boolean
Return false to force unrecognized, true to force recognized, or nil to use default logic.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("IsCharRecognized", "FactionAutoRecognize", function(character, id)
        local other = lia.char.getCharacter(id, character:getPlayer())
        if other and other:getFaction() == character:getFaction() then return true end
    end)

```

---

### IsRecognizedChatType

#### 📋 Purpose
Declare which chat types should hide names when unrecognized.

#### ⏰ When Called
Client-side when choosing to display `[Unknown]` instead of a name.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `chatType` | **string** | Chat channel identifier. |

#### ↩️ Returns
* boolean
Return true to treat the chat type as requiring recognition.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("IsRecognizedChatType", "RecognizedEmote", function(chatType)
        if chatType == "me" then return true end
    end)

```

---

### IsSuitableForTrunk

#### 📋 Purpose
Check if an entity can host a storage trunk.

#### ⏰ When Called
Before creating or opening storage tied to an entity (e.g., vehicles).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | Entity being evaluated. |

#### ↩️ Returns
* boolean
Return false to disallow trunk storage on this entity.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("IsSuitableForTrunk", "AllowSpecificVehicles", function(vehicle)
        if vehicle:isSimfphysCar() then return true end
    end)

```

---

### ItemDataChanged

#### 📋 Purpose
React when persistent data on an item changes.

#### ⏰ When Called
When an item's data key is updated via networking and propagated to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item whose data changed. |
| `key` | **string** | Data key. |
| `oldValue` | **any** | Previous value. |
| `newValue` | **any** | Updated value. |

#### ↩️ Returns
* nil
Use to update UI or dependent state.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ItemDataChanged", "UpdateDurabilityUI", function(item, key, old, new)
        if key == "durability" then item:refreshPanels() end
    end)

```

---

### ItemDefaultFunctions

#### 📋 Purpose
Inject or modify the default function set applied to every item.

#### ⏰ When Called
During item registration when the base functions table is copied to a new item.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table** | Functions table for the item being registered. |

#### ↩️ Returns
* nil
Mutate the functions table directly.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ItemDefaultFunctions", "AddInspect", function(funcs)
        funcs.Inspect = {
            name = "inspect",
            onRun = function(item) item.player:notify(item:getDesc()) end
        }
    end)

```

---

### ItemInitialized

#### 📋 Purpose
Notify that an item instance has been initialized client-side.

#### ⏰ When Called
When item data is received over the network and the item is constructed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Newly initialized item instance. |

#### ↩️ Returns
* nil
Use for client-side setup such as caching icons.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ItemInitialized", "PrimeItemPanels", function(item)
        if item.panel then item.panel:Refresh() end
    end)

```

---

### ItemQuantityChanged

#### 📋 Purpose
React when an item's quantity changes.

#### ⏰ When Called
After quantity is updated and replicated to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **Item** | Item whose quantity changed. |
| `oldValue` | **number** | Previous quantity. |
| `quantity` | **number** | New quantity. |

#### ↩️ Returns
* nil
Use for UI refresh or logic tied to stack counts.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("ItemQuantityChanged", "UpdateStackLabel", function(item, old, new)
        if item.panel then item.panel:SetStack(new) end
    end)

```

---

### LiliaLoaded

#### 📋 Purpose
Signal that the Lilia client has finished loading.

#### ⏰ When Called
After pre-load hooks complete on the client startup sequence.

#### ↩️ Returns
* nil
Use to kick off client-only systems.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("LiliaLoaded", "OpenHUD", function()
        lia.hud.init()
    end)

```

---

### NetVarChanged

#### 📋 Purpose
Respond to networked variable changes on entities, players, or characters.

#### ⏰ When Called
Whenever a netVar is updated via `setNetVar` on players, entities, or characters.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Entity** | Entity whose netVar changed (player or entity). |
| `key` | **string** | NetVar key. |
| `oldValue` | **any** | Previous value. |
| `value` | **any** | New value. |

#### ↩️ Returns
* nil
Use for side effects or client updates.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("NetVarChanged", "TrackStamina", function(entity, key, old, new)
        if key == "stamina" and entity:IsPlayer() then entity.lastStamina = new end
    end)

```

---

### OnAdminSystemLoaded

#### 📋 Purpose
Signal that the admin system integration has loaded.

#### ⏰ When Called
After administration modules finish initializing and privileges are available.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table|nil** | Admin integration data, if provided. |
| `arg2` | **table|nil** | Additional metadata from the admin system. |

#### ↩️ Returns
* nil
Use to register custom permissions or UI once admin hooks exist.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnAdminSystemLoaded", "RegisterCustomPrivileges", function()
        lia.admin.addPrivilege("spawnVehicles", "Spawn Vehicles")
    end)

```

---

### OnCharGetup

#### 📋 Purpose
Notify when a ragdolled character finishes getting up.

#### ⏰ When Called
After a get-up action completes and the ragdoll entity is removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | Player whose character stood up. |
| `entity` | **Entity** | Ragdoll entity that was removed. |

#### ↩️ Returns
* nil
Use to restore state or apply effects after getting up.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnCharGetup", "ClearRagdollState", function(player, ragdoll)
        player:setLocalVar("brth", nil)
    end)

```

---

### OnCharVarChanged

#### 📋 Purpose
React whenever a character variable changes.

#### ⏰ When Called
After a char var setter updates a value and broadcasts it.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **Character** | Character whose variable changed. |
| `varName` | **string** | Variable key. |
| `oldVar` | **any** | Previous value. |
| `newVar` | **any** | New value. |

#### ↩️ Returns
* nil
Use for syncing dependent systems or logging.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnCharVarChanged", "FlagChangeNotice", function(char, key, old, new)
        if key == "flags" then lia.log.add(char:getPlayer(), "flagsChanged", tostring(old), tostring(new)) end
    end)

```

---

### OnConfigUpdated

#### 📋 Purpose
React on the client when a config value updates.

#### ⏰ When Called
Client-side after a config entry changes and is broadcast.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key. |
| `oldValue` | **any** | Previous value. |
| `value` | **any** | New value. |

#### ↩️ Returns
* nil
Use to refresh cached data or UI.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnConfigUpdated", "ReloadLanguage", function(key, old, new)
        if key == "Language" then lia.lang.clearCache() end
    end)

```

---

### OnItemAdded

#### 📋 Purpose
Handle server-side logic when an item is added to an inventory.

#### ⏰ When Called
After an item successfully enters an inventory on the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `owner` | **Player|nil** | Owner player of the inventory, if applicable. |
| `item` | **Item** | Item instance that was added. |

#### ↩️ Returns
* nil
Use for logging, analytics, or triggers.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnItemAdded", "NotifyPickup", function(owner, item)
        if IsValid(owner) then owner:notifyLocalized("itemAdded", item:getName()) end
    end)

```

---

### OnItemCreated

#### 📋 Purpose
React when an item entity is spawned into the world.

#### ⏰ When Called
When `lia_item` entities are created for dropped or spawned items.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemTable` | **table** | Static item definition. |
| `itemEntity` | **Entity** | Spawned entity representing the item. |

#### ↩️ Returns
* nil
Use for modifying the entity (physics, model, etc.).

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnItemCreated", "EnableGlow", function(itemTable, entity)
        if itemTable.rare then entity:SetRenderFX(kRenderFxHologram) end
    end)

```

---

### OnItemOverridden

#### 📋 Purpose
Inspect or modify item override data during registration.

#### ⏰ When Called
When overrides are applied to an item definition at load time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | **table** | Item definition being overridden. |
| `overrides` | **table** | Table of override values. |

#### ↩️ Returns
* nil
Adjust fields directly in `item` or `overrides`.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnItemOverridden", "EnsureCategory", function(item, overrides)
        if overrides.category == nil then overrides.category = "misc" end
    end)

```

---

### OnItemRegistered

#### 📋 Purpose
Run logic immediately after an item type is registered.

#### ⏰ When Called
At the end of `lia.item.register` once the item table is stored.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ITEM` | **table** | Registered item definition. |

#### ↩️ Returns
* nil
Use for post-registration setup such as caching or localization.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnItemRegistered", "CollectWeaponItems", function(item)
        if item.isWeapon then lia.weaponItems = lia.weaponItems or {} table.insert(lia.weaponItems, item.uniqueID) end
    end)

```

---

### OnLocalizationLoaded

#### 📋 Purpose
Notify that localization files have finished loading.

#### ⏰ When Called
After language files and cached phrases are loaded/cleared.

#### ↩️ Returns
* nil
Use to refresh UI text or reload cached translations.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnLocalizationLoaded", "RefreshLanguageDependentUI", function()
        if IsValid(lia.menu.panel) then lia.menu.panel:InvalidateLayout(true) end
    end)

```

---

### OnPAC3PartTransfered

#### 📋 Purpose
Handle PAC3 parts being reassigned to a ragdoll.

#### ⏰ When Called
When a player's PAC parts transfer to their ragdoll entity during rendering.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | **Entity|table** | PAC3 part being transferred. |

#### ↩️ Returns
* nil
Use for cleanup or tracking.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPAC3PartTransfered", "DisableRagdollPAC", function(part)
        part:SetNoDraw(true)
    end)

```

---

### OnPlayerPurchaseDoor

#### 📋 Purpose
React when a player purchases or sells a door.

#### ⏰ When Called
During door buy/sell commands after payment/ownership changes are processed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player performing the transaction. |
| `door` | **Entity** | Door entity involved. |
| `arg3` | **boolean** | True if selling/refunding, false if buying. |

#### ↩️ Returns
* nil
Use for logging or custom ownership logic.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPlayerPurchaseDoor", "LogDoorSale", function(client, door, selling)
        lia.log.add(client, selling and "doorSold" or "doorBought", tostring(door))
    end)

```

---

### OnPlayerDroppedItem

#### 📋 Purpose
Called when a player drops an item from their inventory.

#### ⏰ When Called
After an item has been successfully dropped from a player's inventory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who dropped the item. |
| `spawnedItem` | **Entity** | The spawned item entity that was created. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPlayerDroppedItem", "LogItemDrop", function(client, spawnedItem)
        print(client:Name() .. " dropped an item")
    end)

```

---

### OnPlayerRotateItem

#### 📋 Purpose
Called when a player rotates an item in their inventory.

#### ⏰ When Called
After an item has been successfully rotated in a player's inventory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **Player** | The player who rotated the item. |
| `item` | **Item** | The item that was rotated. |
| `newRot` | **number** | The new rotation value. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPlayerRotateItem", "LogItemRotation", function(client, item, newRot)
        print(client:Name() .. " rotated " .. item:getName() .. " to " .. newRot)
    end)

```

---

### OnPlayerTakeItem

#### 📋 Purpose
Called when a player takes an item into their inventory.

#### ⏰ When Called
After an item has been successfully taken into a player's inventory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who took the item. |
| `item` | **Item** | The item that was taken. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPlayerTakeItem", "LogItemPickup", function(client, item)
        print(client:Name() .. " took " .. item:getName())
    end)

```

---

### OnPrivilegeRegistered

#### 📋 Purpose
React when an admin privilege is registered.

#### ⏰ When Called
When CAMI/compatibility layers add a new privilege.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table** | CAMI privilege table or simplified privilege data. |
| `arg2` | **any** | Optional extra data from the source integration. |
| `arg3` | **any** | Optional extra data from the source integration. |
| `arg4` | **any** | Optional extra data from the source integration. |

#### ↩️ Returns
* nil
Use to mirror privileges into other systems.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPrivilegeRegistered", "SyncPrivileges", function(priv)
        print("Privilege added:", priv.Name or priv.name)
    end)

```

---

### OnPrivilegeUnregistered

#### 📋 Purpose
React when an admin privilege is removed.

#### ⏰ When Called
When CAMI/compatibility layers unregister a privilege.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg1` | **table** | Privilege data being removed. |
| `arg2` | **any** | Optional extra data. |

#### ↩️ Returns
* nil
Use for cleanup or UI updates.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnPrivilegeUnregistered", "CleanupPrivilegeCache", function(priv)
        lia.admin.cache[priv.Name] = nil
    end)

```

---

### OnThemeChanged

#### 📋 Purpose
Notify clients that the active UI theme changed.

#### ⏰ When Called
After a theme is applied or a transition completes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `themeName` | **string** | Name of the theme applied. |
| `useTransition` | **boolean** | True if the theme is transitioning over time. |

#### ↩️ Returns
* nil
Update UI elements to match the new theme.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnThemeChanged", "RefreshPanels", function(name)
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do if panel.RefreshTheme then panel:RefreshTheme() end end
    end)

```

---

### OnTransferred

#### 📋 Purpose
Respond after a character is transferred between factions or classes.

#### ⏰ When Called
Immediately after transfer logic completes in team management.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | Player whose character was transferred. |

#### ↩️ Returns
* nil
Use for notifications or cleanup.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnTransferred", "StripOldClassWeapons", function(client)
        client:StripWeapons()
    end)

```

---

### OnUsergroupCreated

#### 📋 Purpose
React when a new usergroup is created in the admin system.

#### ⏰ When Called
When an admin integration registers a new group.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the new group. |
| `arg2` | **any** | Optional extra data (e.g., privilege list). |

#### ↩️ Returns
* nil
Use to sync UI or caches.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnUsergroupCreated", "CacheNewGroup", function(name)
        lia.admin.refreshGroupCache(name)
    end)

```

---

### OnUsergroupRemoved

#### 📋 Purpose
React when a usergroup is removed.

#### ⏰ When Called
When an admin integration deletes a group.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the removed group. |

#### ↩️ Returns
* nil
Use to clear caches or revoke permissions.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnUsergroupRemoved", "PurgeRemovedGroup", function(name)
        lia.admin.groups[name] = nil
    end)

```

---

### OnUsergroupRenamed

#### 📋 Purpose
React when a usergroup is renamed.

#### ⏰ When Called
After the admin system renames an existing group.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `oldName` | **string** | Previous group name. |
| `newName` | **string** | Updated group name. |

#### ↩️ Returns
* nil
Use to migrate references or update UI.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnUsergroupRenamed", "UpdateGroupCache", function(oldName, newName)
        lia.admin.groups[newName] = lia.admin.groups[oldName]
        lia.admin.groups[oldName] = nil
    end)

```

---

### OptionAdded

#### 📋 Purpose
Notify that a new option has been registered.

#### ⏰ When Called
Immediately after `lia.option.add` stores an option.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Option key. |
| `name` | **table** | Stored option table (name is the localized display name). |
| `option` | **table** | Option metadata table. |

#### ↩️ Returns
* nil
Use for UI updates or caching quick options.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OptionAdded", "InvalidateQuickOptions", function(key, opt)
        if opt.isQuick or (opt.data and opt.data.isQuick) then lia.option.invalidateCache() end
    end)

```

---

### OptionChanged

#### 📋 Purpose
Handle updates to option values.

#### ⏰ When Called
After `lia.option.set` changes a value (client or server).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Option key. |
| `old` | **any** | Previous value. |
| `value` | **any** | New value. |

#### ↩️ Returns
* nil
Use for reacting to option changes.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OptionChanged", "ApplyHUDScale", function(key, old, new)
        if key == "HUDScale" then lia.hud.setScale(new) end
    end)

```

---

### OverrideFactionDesc

#### 📋 Purpose
Override the description shown for a faction.

#### ⏰ When Called
During faction registration/loading while assembling faction data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Faction unique identifier. |
| `arg2` | **string** | Current description. |

#### ↩️ Returns
* string|nil
Replacement description; nil keeps the existing text.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OverrideFactionDesc", "CustomStaffDesc", function(id, desc)
        if id == "staff" then return "Lilia staff team" end
    end)

```

---

### OverrideFactionModels

#### 📋 Purpose
Override the model list for a faction.

#### ⏰ When Called
During faction registration/loading while choosing models.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Faction identifier. |
| `arg2` | **table** | Default models table. |

#### ↩️ Returns
* table|nil
Replacement models table; nil keeps defaults.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OverrideFactionModels", "SwapCitizenModels", function(id, models)
        if id == "citizen" then return {"models/player/alyx.mdl"} end
    end)

```

---

### OverrideFactionName

#### 📋 Purpose
Override the display name for a faction.

#### ⏰ When Called
During faction registration/loading before teams are created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Faction identifier. |
| `arg2` | **string** | Default faction name. |

#### ↩️ Returns
* string|nil
Replacement name; nil keeps the default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OverrideFactionName", "RenameCombine", function(id, name)
        if id == "combine" then return "Civil Protection" end
    end)

```

---

### OverrideSpawnTime

#### 📋 Purpose
Adjust the respawn timer for a player.

#### ⏰ When Called
When calculating respawn delay on client and server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player that will respawn. |
| `baseTime` | **number** | Base respawn time in seconds. |

#### ↩️ Returns
* number|nil
New respawn time; nil keeps the base value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OverrideSpawnTime", "VIPFastRespawn", function(ply, base)
        if ply:IsUserGroup("vip") then return math.max(base * 0.5, 1) end
    end)

```

---

### PlayerThrowPunch

#### 📋 Purpose
Perform post-punch logic such as stamina consumption.

#### ⏰ When Called
After a punch trace completes in the hands SWEP.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player who just punched. |

#### ↩️ Returns
* nil
Use for additional effects like cooldowns or logging.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("PlayerThrowPunch", "TrackPunches", function(client)
        client.punchesThrown = (client.punchesThrown or 0) + 1
    end)

```

---

### PreLiliaLoaded

#### 📋 Purpose
Run right before the client finishes loading Lilia.

#### ⏰ When Called
At the start of the client load sequence before `LiliaLoaded`.

#### ↩️ Returns
* nil
Use to prepare resources needed immediately after load.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("PreLiliaLoaded", "SetupFonts", function()
        lia.util.createFont("liaBig", 32)
    end)

```

---

### RemovePart

#### 📋 Purpose
Notify when a PAC3 part should be removed from a player.

#### ⏰ When Called
Client-side when a part id is marked for removal from a player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player losing the part. |
| `id` | **string** | Identifier of the part to remove. |

#### ↩️ Returns
* nil
Use for cleanup or bookkeeping.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("RemovePart", "ClearCachedPart", function(client, id)
        if client.liaPACParts then client.liaPACParts[id] = nil end
    end)

```

---

### SetupBagInventoryAccessRules

#### 📋 Purpose
Apply standard access rules to a bag's child inventory.

#### ⏰ When Called
Immediately after a bag inventory is created or loaded.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **Inventory** | Bag inventory being configured. |

#### ↩️ Returns
* nil
Mutate the inventory by adding access rules.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("SetupBagInventoryAccessRules", "CustomBagRule", function(inventory)
        inventory:addAccessRule(function(_, action) if action == "transfer" then return true end end, 2)
    end)

```

---

### SetupPACDataFromItems

#### 📋 Purpose
Build PAC3 data from equipped items and push it to clients.

#### ⏰ When Called
Shortly after PAC compatibility initializes to rebuild outfit data.

#### ↩️ Returns
* nil
Use to extend or replace the default PAC data build pipeline.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("SetupPACDataFromItems", "AddCustomPAC", function()
        for _, client in player.Iterator() do client:syncParts() end
    end)

```

---

### TryViewModel

#### 📋 Purpose
Allows overriding the view model entity for PAC compatibility.

#### ⏰ When Called
When determining the view model entity for PAC events.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The potential view model entity. |

#### ↩️ Returns
* Entity
The corrected view model entity, or the original if no correction needed.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("TryViewModel", "PACViewModelFix", function(entity)
        if entity == pac.LocalPlayer:GetViewModel() then
            return pac.LocalPlayer
        end
        return entity
    end)

```

---

