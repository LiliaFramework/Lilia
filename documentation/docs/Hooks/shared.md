# Shared Hooks

Shared hook system for the Lilia framework.

---

Overview

Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.

---

<details class="realm-shared">
<summary><a id=AdjustCreationData></a>AdjustCreationData(client, data, newData, originalData)</summary>
<a id="adjustcreationdata"></a>
<p>Let schemas modify validated character creation data before it is saved.</p>
<p>After creation data is sanitized and validated in `liaCharCreate`, before the final table is merged and written.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Sanitized values for registered character variables.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">newData</span> Table you can populate with overrides that will be merged into `data`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">originalData</span> Copy of the raw client payload prior to sanitation.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdjustCreationData", "ForcePrefix", function(client, data, newData)
        if data.faction == FACTION_STAFF then newData.name = "[STAFF] " .. (newData.name or data.name) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=AdjustPACPartData></a>AdjustPACPartData(wearer, id, data)</summary>
<a id="adjustpacpartdata"></a>
<p>Allow items or modules to tweak PAC3 part data before it is attached.</p>
<p>Client-side when PAC3 builds part data for an outfit id before `AttachPart` runs.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">wearer</span> Entity that will wear the PAC part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> Unique part identifier, usually an item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> PAC3 data table that can be edited.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Return a replacement data table, or nil to keep the modified `data`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdjustPACPartData", "TintPoliceVisors", function(wearer, id, data)
        if wearer:Team() == FACTION_POLICE and data.Material then data.Material = "models/shiny" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=AdjustStaminaOffset></a>AdjustStaminaOffset(client, offset)</summary>
<a id="adjuststaminaoffset"></a>
<p>Change the stamina delta applied on a tick.</p>
<p>Each stamina update before the offset is clamped and written to the player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose stamina is being processed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">offset</span> Positive regen or negative drain calculated from movement.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Override for the stamina offset; nil keeps the existing value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdjustStaminaOffset", "HeavyArmorTax", function(client, offset)
        if client:GetNWBool("HeavyArmor") then return offset - 1 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=AdvDupe_FinishPasting></a>AdvDupe_FinishPasting(tbl)</summary>
<a id="advdupe_finishpasting"></a>
<p>React when an Advanced Dupe 2 paste finishes under BetterDupe.</p>
<p>After AdvDupe2 completes the paste queue so compatibility state can be reset.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tbl</span> Paste context provided by AdvDupe2 (first entry is the player).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdvDupe_FinishPasting", "ClearTempState", function(info)
        local ply = info[1] and info[1].Player
        if IsValid(ply) then ply.tempBetterDupe = nil end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=AttachPart></a>AttachPart(client, id)</summary>
<a id="attachpart"></a>
<p>Notify when a PAC3 part is attached to a player.</p>
<p>Client-side after PAC3 part data is retrieved and before it is tracked locally.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player receiving the PAC part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> Identifier of the part or outfit.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AttachPart", "TrackPACAttachment", function(client, id)
        lia.log.add(client, "pacAttach", id)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=BagInventoryReady></a>BagInventoryReady(bagItem, inventory)</summary>
<a id="baginventoryready"></a>
<p>Respond when a bag item finishes creating or loading its child inventory.</p>
<p>After a bag instance allocates an inventory (on instancing or restore) and access rules are applied.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">bagItem</span> The bag item that owns the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Child inventory created for the bag.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("BagInventoryReady", "AutoLabelBag", function(bagItem, inventory)
        inventory:setData("bagName", bagItem:getName())
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=BagInventoryRemoved></a>BagInventoryRemoved(bagItem, inventory)</summary>
<a id="baginventoryremoved"></a>
<p>React when a bag's inventory is being removed.</p>
<p>Before a bag item deletes its child inventory (e.g., on item removal).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">bagItem</span> Bag being removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Child inventory scheduled for deletion.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("BagInventoryRemoved", "DropBagContents", function(bagItem, inv)
        for _, item in pairs(inv:getItems()) do item:transfer(nil, nil, nil, nil, true) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CalcStaminaChange></a>CalcStaminaChange(client)</summary>
<a id="calcstaminachange"></a>
<p>Calculate the stamina change for a player on a tick.</p>
<p>From the stamina timer in the attributes module every 0.25s and on client prediction.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player being processed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Positive regen or negative drain applied to the player's stamina pool.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function MODULE:CalcStaminaChange(client)
        local offset = self.BaseClass.CalcStaminaChange(self, client)
        if client:IsAdmin() then offset = offset + 1 end
        return offset
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CalcStaminaChange></a>CalcStaminaChange(client)</summary>
<a id="calcstaminachange"></a>
<p>Calculate the stamina change for a player on a tick.</p>
<p>From the stamina timer in the attributes module every 0.25s and on client prediction.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player being processed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Positive regen or negative drain applied to the player's stamina pool.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    function MODULE:CalcStaminaChange(client)
        local offset = self.BaseClass.CalcStaminaChange(self, client)
        if client:IsAdmin() then offset = offset + 1 end
        return offset
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanCharBeTransfered></a>CanCharBeTransfered(tChar, faction, arg3)</summary>
<a id="cancharbetransfered"></a>
<p>Decide whether a character can be transferred to a new faction or class.</p>
<p>Before character transfer commands/classes move a character to another faction/class.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">tChar</span> Character being transferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">faction</span> Target faction or class identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">arg3</span> Current faction or class being left.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false and an optional reason to block the transfer.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanCharBeTransfered", "PreventDuplicateFaction", function(char, factionID)
        if lia.faction.indices[factionID] and lia.faction.indices[factionID].oneCharOnly then
            for _, other in pairs(lia.char.getAll()) do
                if other.steamID == char.steamID and other:getFaction() == factionID then
                    return false, L("charAlreadyInFaction")
                end
            end
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanInviteToClass></a>CanInviteToClass(client, target)</summary>
<a id="caninvitetoclass"></a>
<p>Control whether a player can invite another player into a class.</p>
<p>Before sending a class invite through the team management menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player issuing the invite.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">target</span> Player being invited.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false (optionally with reason) to block the invite.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanInviteToClass", "RestrictByRank", function(client, target)
        if not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanInviteToFaction></a>CanInviteToFaction(client, target)</summary>
<a id="caninvitetofaction"></a>
<p>Control whether a player can invite another player into their faction.</p>
<p>When a player tries to invite someone to join their faction in the team menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player issuing the invite.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">target</span> Player being invited.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to deny the invitation with an optional message.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanInviteToFaction", "BlockFullFaction", function(client, target)
        local faction = lia.faction.indices[client:Team()]
        if faction and faction.memberLimit and faction.memberLimit &lt;= faction:countMembers() then
            return false, L("limitFaction")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanOutfitChangeModel></a>CanOutfitChangeModel(item)</summary>
<a id="canoutfitchangemodel"></a>
<p>Decide whether an outfit item is allowed to change a player's model.</p>
<p>Before an outfit applies its model change during equip or removal.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Outfit attempting to change the player's model.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to prevent the outfit from changing the model.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
        return not item.player:getNetVar("NoModelChange", false)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPerformVendorEdit></a>CanPerformVendorEdit(client, vendor)</summary>
<a id="canperformvendoredit"></a>
<p>Determine if a player can edit a vendor's configuration.</p>
<p>When opening the vendor editor or applying vendor changes through the UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player attempting to edit.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">vendor</span> Vendor entity being edited.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to block edits with an optional reason.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPerformVendorEdit", "AdminOnlyVendors", function(client, vendor)
        if not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPickupMoney></a>CanPickupMoney(activator, moneyEntity)</summary>
<a id="canpickupmoney"></a>
<p>Allow or prevent a player from picking up a money entity.</p>
<p>When a player uses a `lia_money` entity to collect currency.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">activator</span> Entity attempting to pick up the money (usually a Player).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">moneyEntity</span> Money entity being collected.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to block pickup with an optional message.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPickupMoney", "RespectWantedStatus", function(client, money)
        if client:getNetVar("isWanted") then return false, L("cannotPickupWhileWanted") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerChooseWeapon></a>CanPlayerChooseWeapon(weapon)</summary>
<a id="canplayerchooseweapon"></a>
<p>Filter which weapons appear as selectable in the weapon selector.</p>
<p>When building the client weapon selection UI before allowing a weapon choice.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Weapon">Weapon</a></span> <span class="parameter">weapon</span> Weapon entity being considered.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to hide or block selection of the weapon.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerChooseWeapon", "HideUnsafeWeapons", function(weapon)
        if weapon:GetClass():find("admin") then return false end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerCreateChar></a>CanPlayerCreateChar(client, data)</summary>
<a id="canplayercreatechar"></a>
<p>Allow schemas to veto or validate a character creation attempt.</p>
<p>On the server when a player submits the creation form and before processing begins.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Raw creation data received from the client.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false and an optional message to deny creation.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerCreateChar", "LimitByPlaytime", function(client)
        if not client:playTimeGreaterThan(3600) then return false, L("needMorePlaytime") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerJoinClass></a>CanPlayerJoinClass(client, class, info)</summary>
<a id="canplayerjoinclass"></a>
<p>Decide if a player may join a given class.</p>
<p>Before assigning a class in the class library and character selection.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting the class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">class</span> Target class index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">info</span> Class data table for convenience.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to block the class switch with an optional reason.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerJoinClass", "WhitelistCheck", function(client, class, info)
        if info.requiresWhitelist and not client:getChar():getClasswhitelists()[class] then
            return false, L("noWhitelist")
        end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerKnock></a>CanPlayerKnock(arg1, arg2)</summary>
<a id="canplayerknock"></a>
<p>Control whether a player can knock on a door with their hands.</p>
<p>When the hands SWEP secondary attack is used on a door entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Player attempting to knock.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">arg2</span> Door entity being knocked on.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to prevent the knock action.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerKnock", "BlockPoliceDoors", function(client, door)
        if door.isPoliceDoor then return false end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerModifyConfig></a>CanPlayerModifyConfig(client, key)</summary>
<a id="canplayermodifyconfig"></a>
<p>Gate whether a player can change a configuration variable.</p>
<p>Client- and server-side when a config edit is attempted through the admin tools or config UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player attempting the change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key being modified.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to deny the modification with an optional message.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerModifyConfig", "SuperAdminOnly", function(client)
        if not client:IsSuperAdmin() then return false, L("insufficientPermissions") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerRotateItem></a>CanPlayerRotateItem(client, item)</summary>
<a id="canplayerrotateitem"></a>
<p>Determine if a player may rotate an item in an inventory grid.</p>
<p>When handling the client drag/drop rotate action for an item slot.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting the rotation.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance being rotated.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to block rotation with an optional error message.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerRotateItem", "LockQuestItems", function(client, item)
        if item:getData("questLocked") then return false, L("itemLocked") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerThrowPunch></a>CanPlayerThrowPunch(client)</summary>
<a id="canplayerthrowpunch"></a>
<p>Gate whether a player is allowed to throw a punch.</p>
<p>Before the hands SWEP starts a punch, after playtime and stamina checks.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player attempting to punch.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean|string|nil</a></span> Return false to stop the punch; optionally return a reason string.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerThrowPunch", "DisallowTiedPlayers", function(client)
        if client:getNetVar("tied") then return false, L("cannotWhileTied") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanPlayerUseCommand></a>CanPlayerUseCommand(client, command)</summary>
<a id="canplayerusecommand"></a>
<p>Decide if a player can execute a specific console/chat command.</p>
<p>Each time a command is run through the command library before execution.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player running the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">command</span> Command definition table.</p>

<p><h3>Returns:</h3>
boolean, string|nil Return false to block the command with an optional reason.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerUseCommand", "RestrictNonStaff", function(client, command)
        if command.adminOnly and not client:IsAdmin() then return false, L("insufficientPermissions") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CanRunItemAction></a>CanRunItemAction(tempItem, key)</summary>
<a id="canrunitemaction"></a>
<p>Control whether an item action should be available.</p>
<p>While building item action menus both client-side (UI) and server-side (validation).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">tempItem</span> Item being acted on.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Action identifier (e.g., "equip", "drop").</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to hide or block the action.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanRunItemAction", "NoDropQuestItems", function(item, action)
        if action == "drop" and item:getData("questLocked") then return false end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CharForceRecognized></a>CharForceRecognized(ply, range)</summary>
<a id="charforcerecognized"></a>
<p>Force a character to recognize others within a range.</p>
<p>When the recognition module sets recognition for every character around a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player whose character will recognize others.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> <span class="parameter">range</span> Range preset ("whisper", "normal", "yell") or numeric distance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharForceRecognized", "AlwaysRecognizeStaff", function(ply)
        if ply:IsAdmin() then ply:getChar():giveAllRecognition() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CharHasFlags></a>CharHasFlags(client, flags)</summary>
<a id="charhasflags"></a>
<p>Override how character flag checks are evaluated.</p>
<p>Whenever `playerMeta:hasFlags` is queried to determine character permissions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose character is being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Flag string to test.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return true to force pass, false to force fail, or nil to defer to default logic.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharHasFlags", "HonorVIP", function(client, flags)
        if client:IsUserGroup("vip") and flags:find("V") then return true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ChatParsed></a>ChatParsed(client, chatType, message, anonymous)</summary>
<a id="chatparsed"></a>
<p>Modify chat metadata before it is dispatched.</p>
<p>After chat parsing but before the chat type and message are sent to recipients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Speaker.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span> Parsed chat command (ic, ooc, etc.).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Original chat text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">anonymous</span> Whether the message is anonymous.</p>

<p><h3>Returns:</h3>
string, string, boolean|nil Optionally return a replacement chatType, message, and anonymous flag.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ChatParsed", "AddOOCPrefix", function(client, chatType, message, anonymous)
        if chatType == "ooc" then return chatType, "[GLOBAL] " .. message, anonymous end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=CommandAdded></a>CommandAdded(command, data)</summary>
<a id="commandadded"></a>
<p>React when a new chat/console command is registered.</p>
<p>Immediately after a command is added to the command library.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Command identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Command definition table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CommandAdded", "LogCommands", function(name, data)
        print("Command registered:", name, "adminOnly:", data.adminOnly)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ConfigChanged></a>ConfigChanged(key, value, oldValue, client)</summary>
<a id="configchanged"></a>
<p>Run logic after a configuration value changes.</p>
<p>When a config entry is updated via admin tools or code on the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player who made the change, if any.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ConfigChanged", "BroadcastChange", function(key, value, old, client)
        if SERVER then lia.log.add(client, "configChanged", key, tostring(old), tostring(value)) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=DoModuleIncludes></a>DoModuleIncludes(path, MODULE)</summary>
<a id="domoduleincludes"></a>
<p>Customize how module files are included.</p>
<p>During module loading in the modularity library for each include path.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> Path of the file being included.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">MODULE</span> Module table receiving the include.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DoModuleIncludes", "TrackModuleIncludes", function(path, MODULE)
        MODULE.loadedFiles = MODULE.loadedFiles or {}
        table.insert(MODULE.loadedFiles, path)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ForceRecognizeRange></a>ForceRecognizeRange(ply, range, fakeName)</summary>
<a id="forcerecognizerange"></a>
<p>Force a character to recognize everyone within a given chat range.</p>
<p>By recognition commands to mark nearby characters as recognized.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player whose recognition list is being updated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> <span class="parameter">range</span> Range preset ("whisper", "normal", "yell") or numeric distance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fakeName</span> <span class="optional">optional</span> Optional fake name to record for recognition.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ForceRecognizeRange", "LogForcedRecognition", function(ply, range)
        lia.log.add(ply, "charRecognizeRange", tostring(range))
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetAttributeMax></a>GetAttributeMax(client, id)</summary>
<a id="getattributemax"></a>
<p>Override the maximum level a character can reach for a given attribute.</p>
<p>Whenever attribute caps are checked, such as when spending points or granting boosts.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose attribute cap is being queried.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> Attribute identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Maximum allowed level (defaults to infinity).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetAttributeMax", "HardCapEndurance", function(client, id)
        if id == "end" then return 50 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetAttributeStartingMax></a>GetAttributeStartingMax(client, attribute)</summary>
<a id="getattributestartingmax"></a>
<p>Define the maximum starting value for an attribute during character creation.</p>
<p>While allocating starting attribute points to limit each stat.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">attribute</span> Attribute identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Maximum value allowed at creation; nil falls back to default limits.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetAttributeStartingMax", "LowStartForStrength", function(client, attribute)
        if attribute == "str" then return 5 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetCharMaxStamina></a>GetCharMaxStamina(char)</summary>
<a id="getcharmaxstamina"></a>
<p>Specify a character's maximum stamina pool.</p>
<p>Whenever stamina is clamped, restored, or initialized.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">char</span> Character whose stamina cap is being read.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Max stamina value; defaults to `DefaultStamina` config when nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharMaxStamina", "PerkBonus", function(char)
        if char:hasFlags("S") then return lia.config.get("DefaultStamina", 100) + 25 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetDefaultCharDesc></a>GetDefaultCharDesc(client, arg2, data)</summary>
<a id="getdefaultchardesc"></a>
<p>Provide a default character description for a faction.</p>
<p>During creation validation and adjustment for the `desc` character variable.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">arg2</span> Faction index being created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Creation payload.</p>

<p><h3>Returns:</h3>
string, boolean|nil Description text and a flag indicating whether to override the player's input.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDefaultCharDesc", "StaffDesc", function(client, faction)
        if faction == FACTION_STAFF then return L("staffCharacterDiscordSteamID", "n/a", client:SteamID()), true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetDefaultCharName></a>GetDefaultCharName(client, faction, data)</summary>
<a id="getdefaultcharname"></a>
<p>Provide a default character name for a faction.</p>
<p>During creation validation and adjustment for the `name` character variable.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">faction</span> Target faction index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Creation payload.</p>

<p><h3>Returns:</h3>
string, boolean|nil Name text and a flag indicating whether to override the player's input.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDefaultCharName", "StaffTemplate", function(client, faction, data)
        if faction == FACTION_STAFF then return "Staff - " .. client:SteamName(), true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetDefaultInventorySize></a>GetDefaultInventorySize(client, char)</summary>
<a id="getdefaultinventorysize"></a>
<p>Override the default inventory dimensions a character starts with.</p>
<p>During inventory setup on character creation and load.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player owning the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">char</span> Character whose inventory size is being set.</p>

<p><h3>Returns:</h3>
number, number|nil Inventory width and height; nil values fall back to config defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDefaultInventorySize", "LargeBagsForStaff", function(client, char)
        if client:IsAdmin() then return 8, 6 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetDisplayedName></a>GetDisplayedName(client, chatType)</summary>
<a id="getdisplayedname"></a>
<p>Decide what name is shown for a player in chat based on recognition.</p>
<p>Client-side when rendering chat messages to resolve a display name.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Speaker whose name is being displayed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Name to display; nil lets the default recognition logic run.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDisplayedName", "ShowAliasInWhisper", function(client, chatType)
        if chatType == "w" then return client:getChar():getData("alias") end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetHandsAttackSpeed></a>GetHandsAttackSpeed(arg1, arg2)</summary>
<a id="gethandsattackspeed"></a>
<p>Adjust the delay between punches for the hands SWEP.</p>
<p>Each time the fists are swung to determine the next attack delay.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Player punching.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">arg2</span> Default delay before the next punch.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Replacement delay; nil keeps the default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetHandsAttackSpeed", "FasterCombatDrugs", function(client, defaultDelay)
        if client:getNetVar("combatStim") then return defaultDelay * 0.75 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetItemDropModel></a>GetItemDropModel(itemTable, itemEntity)</summary>
<a id="getitemdropmodel"></a>
<p>Override the model used when an item spawns as a world entity.</p>
<p>When an item entity is created server-side to set its model.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">itemTable</span> Item definition table.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">itemEntity</span> Spawned item entity.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Model path to use; nil keeps the item's configured model.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetItemDropModel", "IconicMoneyBag", function(itemTable)
        if itemTable.uniqueID == "moneycase" then return "models/props_c17/briefcase001a.mdl" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetMaxPlayerChar></a>GetMaxPlayerChar(client)</summary>
<a id="getmaxplayerchar"></a>
<p>Override the maximum number of characters a player may create.</p>
<p>When rendering the character list and validating new character creation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose limit is being checked.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Maximum character slots; nil falls back to `MaxCharacters` config.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetMaxPlayerChar", "VIPExtraSlot", function(client)
        if client:IsUserGroup("vip") then return (lia.config.get("MaxCharacters") or 5) + 1 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetMaxStartingAttributePoints></a>GetMaxStartingAttributePoints(client, count)</summary>
<a id="getmaxstartingattributepoints"></a>
<p>Set the total attribute points available during character creation.</p>
<p>On the creation screen when allocating starting attributes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">count</span> Default maximum points.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Maximum points allowed; nil keeps the default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetMaxStartingAttributePoints", "PerkBonusPoints", function(client, count)
        if client:IsAdmin() then return count + 5 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetModelGender></a>GetModelGender(model)</summary>
<a id="getmodelgender"></a>
<p>Identify the gender classification for a player model.</p>
<p>When entity meta needs to know if a model is treated as female for voice/animations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">model</span> Model path being inspected.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> "female" to treat as female, or nil for default male handling.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetModelGender", "CustomFemaleModels", function(model)
        if model:find("female_custom") then return "female" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetMoneyModel></a>GetMoneyModel(arg1)</summary>
<a id="getmoneymodel"></a>
<p>Pick the world model used by a money entity based on its amount.</p>
<p>When a `lia_money` entity initializes and sets its model.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">arg1</span> Amount of currency the entity holds.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Model path override; nil falls back to `MoneyModel` config.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetMoneyModel", "HighValueCash", function(amount)
        if amount &gt;= 1000 then return "models/props_lab/box01a.mdl" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetNPCDialogOptions></a>GetNPCDialogOptions(arg1, arg2, arg3)</summary>
<a id="getnpcdialogoptions"></a>
<p>Supply additional dialog options for an NPC conversation.</p>
<p>When the client requests dialog options for an NPC and builds the menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Player interacting with the NPC.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">arg2</span> NPC being talked to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">arg3</span> Whether the NPC supports customization options.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Extra dialog options keyed by unique id; nil keeps defaults only.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetNPCDialogOptions", "AddShopGreeting", function(client, npc)
        return {special = {name = "Ask about wares", callback = function() net.Start("npcShop") net.SendToServer() end}}
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetPlayerPunchDamage></a>GetPlayerPunchDamage(arg1, arg2, arg3)</summary>
<a id="getplayerpunchdamage"></a>
<p>Adjust fist damage output for a punch.</p>
<p>Just before a punch trace applies damage in the hands SWEP.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Punching player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">arg2</span> Default damage.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg3</span> Context table you may mutate (e.g., `context.damage`).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> New damage value; nil uses `context.damage` or the original.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetPlayerPunchDamage", "StrengthAffectsPunch", function(client, damage, ctx)
        local char = client:getChar()
        if char then ctx.damage = ctx.damage + char:getAttrib("str", 0) * 0.2 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetPlayerPunchRagdollTime></a>GetPlayerPunchRagdollTime(arg1, arg2)</summary>
<a id="getplayerpunchragdolltime"></a>
<p>Set how long a target is ragdolled when nonlethal punches knock them down.</p>
<p>When a punch would kill a player while lethality is disabled.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Attacker.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">arg2</span> Target player being knocked out.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Ragdoll duration in seconds; nil uses `PunchRagdollTime` config.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetPlayerPunchRagdollTime", "ShorterKO", function(client, target)
        if target:IsAdmin() then return 5 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetPriceOverride></a>GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)</summary>
<a id="getpriceoverride"></a>
<p>Override a vendor's buy/sell price for an item.</p>
<p>When a vendor calculates price for buying from or selling to a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Item unique ID being priced.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">price</span> Base price before modifiers.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">isSellingToVendor</span> True if the player is selling an item to the vendor.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Replacement price; nil keeps the existing calculation.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetPriceOverride", "FactionDiscount", function(vendor, uniqueID, price, selling)
        if vendor.factionDiscount and not selling then return math.Round(price * vendor.factionDiscount) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetRagdollTime></a>GetRagdollTime(client, time)</summary>
<a id="getragdolltime"></a>
<p>Set the ragdoll duration when a player is knocked out.</p>
<p>Whenever `playerMeta:setRagdolled` determines the ragdoll time.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player being ragdolled.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Proposed ragdoll time.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Replacement time; nil keeps the proposed duration.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetRagdollTime", "ShorterStaffRagdoll", function(client, time)
        if client:IsAdmin() then return math.min(time, 5) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetVendorSaleScale></a>GetVendorSaleScale(vendor)</summary>
<a id="getvendorsalescale"></a>
<p>Apply a global sale/markup scale to vendor transactions.</p>
<p>When vendors compute sale or purchase totals.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">vendor</span> Vendor entity performing the sale.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Multiplier applied to prices (e.g., 0.9 for 10% off); nil keeps vendor defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetVendorSaleScale", "HappyHour", function(vendor)
        if vendor:GetNWBool("happyHour") then return 0.8 end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=GetWeaponName></a>GetWeaponName(weapon)</summary>
<a id="getweaponname"></a>
<p>Override the display name derived from a weapon when creating an item or showing UI.</p>
<p>When generating item data from a weapon or showing weapon names in selectors.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">weapon</span> Weapon entity whose name is being resolved.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom weapon name; nil falls back to print name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetWeaponName", "PrettySWEPNames", function(weapon)
        return language.GetPhrase(weapon:GetClass() .. "_friendly") or weapon:GetPrintName()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializeStorage></a>InitializeStorage(entity)</summary>
<a id="initializestorage"></a>
<p>Initialize a storage entity's inventory rules or data.</p>
<p>After a storage entity is created or loaded and before player interaction.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Storage entity being prepared.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializeStorage", "SetTrunkOwner", function(ent)
        if ent:isVehicle() then ent:setNetVar("storageOwner", ent:GetNWString("owner")) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedConfig></a>InitializedConfig()</summary>
<a id="initializedconfig"></a>
<p>Signal that configuration definitions have been loaded client-side.</p>
<p>After the administration config UI finishes building available options.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedConfig", "BuildConfigUI", function()
        lia.config.buildList()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedItems></a>InitializedItems()</summary>
<a id="initializeditems"></a>
<p>Notify that all items have been registered.</p>
<p>After item scripts finish loading during initialization.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedItems", "CacheItemIDs", function()
        lia.itemIDCache = table.GetKeys(lia.item.list)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedKeybinds></a>InitializedKeybinds()</summary>
<a id="initializedkeybinds"></a>
<p>Signal that keybind definitions are loaded.</p>
<p>After keybinds are registered during initialization.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedKeybinds", "RegisterCustomBind", function()
        lia.key.addBind("ToggleHUD", KEY_F6, "Toggle HUD", function(client) hook.Run("ToggleHUD") end)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedModules></a>InitializedModules()</summary>
<a id="initializedmodules"></a>
<p>Announce that all modules have finished loading.</p>
<p>After module include phase completes, including reloads.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedModules", "WarmWorkshopCache", function()
        lia.workshop.cache = lia.workshop.gather()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedOptions></a>InitializedOptions()</summary>
<a id="initializedoptions"></a>
<p>Notify that all options have been registered and loaded.</p>
<p>After the option library finishes loading saved values on the client.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedOptions", "ApplyThemeOption", function()
        hook.Run("OnThemeChanged", lia.option.get("Theme", "Teal"), false)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InitializedSchema></a>InitializedSchema()</summary>
<a id="initializedschema"></a>
<p>Fire once the schema finishes loading.</p>
<p>After schema initialization completes; useful for schema-level setup.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InitializedSchema", "SetupSchemaData", function()
        lia.schema.setupComplete = true
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InventoryDataChanged></a>InventoryDataChanged(instance, key, oldValue, value)</summary>
<a id="inventorydatachanged"></a>
<p>React to inventory metadata changes.</p>
<p>When an inventory's data key is updated and replicated to clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">instance</span> Inventory whose data changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryDataChanged", "UpdateBagLabel", function(inv, key, old, new)
        if key == "bagName" then inv:getOwner():notify("Bag renamed to " .. tostring(new)) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InventoryInitialized></a>InventoryInitialized(instance)</summary>
<a id="inventoryinitialized"></a>
<p>Signal that an inventory has finished initializing on the client.</p>
<p>After an inventory is created or received over the network.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">instance</span> Inventory that is ready.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryInitialized", "ShowInventoryUI", function(inv)
        if inv:getOwner() == LocalPlayer() then lia.inventory.show(inv) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InventoryItemAdded></a>InventoryItemAdded(inventory, item)</summary>
<a id="inventoryitemadded"></a>
<p>React when an item is added to an inventory.</p>
<p>After an item successfully enters an inventory, both server- and client-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory receiving the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance added.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryItemAdded", "PlayPickupSound", function(inv, item)
        local owner = inv:getOwner()
        if IsValid(owner) then owner:EmitSound("items/ammocrate_open.wav", 60) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=InventoryItemRemoved></a>InventoryItemRemoved(inventory, instance, preserveItem)</summary>
<a id="inventoryitemremoved"></a>
<p>React when an item leaves an inventory.</p>
<p>After an item is removed from an inventory, optionally preserving the instance.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory losing the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">instance</span> Item removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">preserveItem</span> True if the item instance is kept alive (e.g., dropped) instead of deleted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryItemRemoved", "LogRemoval", function(inv, item, preserve)
        lia.log.add(inv:getOwner(), "itemRemoved", item.uniqueID, preserve and "preserved" or "deleted")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=IsCharFakeRecognized></a>IsCharFakeRecognized(character, id)</summary>
<a id="ischarfakerecognized"></a>
<p>Decide if a character is recognized under a fake name.</p>
<p>When checking recognition with fake names enabled.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> Character performing the recognition check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> Target character ID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return true if recognized via fake name, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("IsCharFakeRecognized", "AlwaysRecognizeSelf", function(character, id)
        if character.id == id then return true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=IsCharRecognized></a>IsCharRecognized(a, arg2)</summary>
<a id="ischarrecognized"></a>
<p>Override whether one character recognizes another.</p>
<p>Whenever recognition checks are performed for chat or display logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">a</span> Character performing the check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">arg2</span> Target character ID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to force unrecognized, true to force recognized, or nil to use default logic.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("IsCharRecognized", "FactionAutoRecognize", function(character, id)
        local other = lia.char.getCharacter(id, character:getPlayer())
        if other and other:getFaction() == character:getFaction() then return true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=IsRecognizedChatType></a>IsRecognizedChatType(chatType)</summary>
<a id="isrecognizedchattype"></a>
<p>Declare which chat types should hide names when unrecognized.</p>
<p>Client-side when choosing to display `[Unknown]` instead of a name.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return true to treat the chat type as requiring recognition.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("IsRecognizedChatType", "RecognizedEmote", function(chatType)
        if chatType == "me" then return true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=IsSuitableForTrunk></a>IsSuitableForTrunk(ent)</summary>
<a id="issuitablefortrunk"></a>
<p>Check if an entity can host a storage trunk.</p>
<p>Before creating or opening storage tied to an entity (e.g., vehicles).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">ent</span> Entity being evaluated.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to disallow trunk storage on this entity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("IsSuitableForTrunk", "AllowSpecificVehicles", function(vehicle)
        if vehicle:isSimfphysCar() then return true end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ItemDataChanged></a>ItemDataChanged(item, key, oldValue, newValue)</summary>
<a id="itemdatachanged"></a>
<p>React when persistent data on an item changes.</p>
<p>When an item's data key is updated via networking and propagated to clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item whose data changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">newValue</span> Updated value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemDataChanged", "UpdateDurabilityUI", function(item, key, old, new)
        if key == "durability" then item:refreshPanels() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ItemDefaultFunctions></a>ItemDefaultFunctions(arg1)</summary>
<a id="itemdefaultfunctions"></a>
<p>Inject or modify the default function set applied to every item.</p>
<p>During item registration when the base functions table is copied to a new item.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg1</span> Functions table for the item being registered.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemDefaultFunctions", "AddInspect", function(funcs)
        funcs.Inspect = {
            name = "inspect",
            onRun = function(item) item.player:notify(item:getDesc()) end
        }
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ItemInitialized></a>ItemInitialized(item)</summary>
<a id="iteminitialized"></a>
<p>Notify that an item instance has been initialized client-side.</p>
<p>When item data is received over the network and the item is constructed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Newly initialized item instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemInitialized", "PrimeItemPanels", function(item)
        if item.panel then item.panel:Refresh() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=ItemQuantityChanged></a>ItemQuantityChanged(item, oldValue, quantity)</summary>
<a id="itemquantitychanged"></a>
<p>React when an item's quantity changes.</p>
<p>After quantity is updated and replicated to clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item whose quantity changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">oldValue</span> Previous quantity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">quantity</span> New quantity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemQuantityChanged", "UpdateStackLabel", function(item, old, new)
        if item.panel then item.panel:SetStack(new) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=LiliaLoaded></a>LiliaLoaded()</summary>
<a id="lilialoaded"></a>
<p>Signal that the Lilia client has finished loading.</p>
<p>After pre-load hooks complete on the client startup sequence.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("LiliaLoaded", "OpenHUD", function()
        lia.hud.init()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=NetVarChanged></a>NetVarChanged(client, key, oldValue, value)</summary>
<a id="netvarchanged"></a>
<p>Respond to networked variable changes on entities, players, or characters.</p>
<p>Whenever a netVar is updated via `setNetVar` on players, entities, or characters.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">client</span> Entity whose netVar changed (player or entity).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> NetVar key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("NetVarChanged", "TrackStamina", function(entity, key, old, new)
        if key == "stamina" and entity:IsPlayer() then entity.lastStamina = new end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnAdminSystemLoaded></a>OnAdminSystemLoaded(arg1, arg2)</summary>
<a id="onadminsystemloaded"></a>
<p>Signal that the admin system integration has loaded.</p>
<p>After administration modules finish initializing and privileges are available.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg1</span> <span class="optional">optional</span> Admin integration data, if provided.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg2</span> <span class="optional">optional</span> Additional metadata from the admin system.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnAdminSystemLoaded", "RegisterCustomPrivileges", function()
        lia.admin.addPrivilege("spawnVehicles", "Spawn Vehicles")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnCharGetup></a>OnCharGetup(target, entity)</summary>
<a id="onchargetup"></a>
<p>Notify when a ragdolled character finishes getting up.</p>
<p>After a get-up action completes and the ragdoll entity is removed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">target</span> Player whose character stood up.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Ragdoll entity that was removed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnCharGetup", "ClearRagdollState", function(player, ragdoll)
        player:setLocalVar("brth", nil)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnCharVarChanged></a>OnCharVarChanged(character, varName, oldVar, newVar)</summary>
<a id="oncharvarchanged"></a>
<p>React whenever a character variable changes.</p>
<p>After a char var setter updates a value and broadcasts it.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> Character whose variable changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">varName</span> Variable key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldVar</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">newVar</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnCharVarChanged", "FlagChangeNotice", function(char, key, old, new)
        if key == "flags" then lia.log.add(char:getPlayer(), "flagsChanged", tostring(old), tostring(new)) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnConfigUpdated></a>OnConfigUpdated(key, oldValue, value)</summary>
<a id="onconfigupdated"></a>
<p>React on the client when a config value updates.</p>
<p>Client-side after a config entry changes and is broadcast.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Config key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnConfigUpdated", "ReloadLanguage", function(key, old, new)
        if key == "Language" then lia.lang.clearCache() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnItemAdded></a>OnItemAdded(owner, item)</summary>
<a id="onitemadded"></a>
<p>Handle server-side logic when an item is added to an inventory.</p>
<p>After an item successfully enters an inventory on the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">owner</span> <span class="optional">optional</span> Owner player of the inventory, if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item instance that was added.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnItemAdded", "NotifyPickup", function(owner, item)
        if IsValid(owner) then owner:notifyLocalized("itemAdded", item:getName()) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnItemCreated></a>OnItemCreated(itemTable, itemEntity)</summary>
<a id="onitemcreated"></a>
<p>React when an item entity is spawned into the world.</p>
<p>When `lia_item` entities are created for dropped or spawned items.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">itemTable</span> Static item definition.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">itemEntity</span> Spawned entity representing the item.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnItemCreated", "EnableGlow", function(itemTable, entity)
        if itemTable.rare then entity:SetRenderFX(kRenderFxHologram) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnItemOverridden></a>OnItemOverridden(item, overrides)</summary>
<a id="onitemoverridden"></a>
<p>Inspect or modify item override data during registration.</p>
<p>When overrides are applied to an item definition at load time.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">item</span> Item definition being overridden.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">overrides</span> Table of override values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnItemOverridden", "EnsureCategory", function(item, overrides)
        if overrides.category == nil then overrides.category = "misc" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnItemRegistered></a>OnItemRegistered(ITEM)</summary>
<a id="onitemregistered"></a>
<p>Run logic immediately after an item type is registered.</p>
<p>At the end of `lia.item.register` once the item table is stored.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">ITEM</span> Registered item definition.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnItemRegistered", "CollectWeaponItems", function(item)
        if item.isWeapon then lia.weaponItems = lia.weaponItems or {} table.insert(lia.weaponItems, item.uniqueID) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnLocalizationLoaded></a>OnLocalizationLoaded()</summary>
<a id="onlocalizationloaded"></a>
<p>Notify that localization files have finished loading.</p>
<p>After language files and cached phrases are loaded/cleared.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnLocalizationLoaded", "RefreshLanguageDependentUI", function()
        if IsValid(lia.menu.panel) then lia.menu.panel:InvalidateLayout(true) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPAC3PartTransfered></a>OnPAC3PartTransfered(part)</summary>
<a id="onpac3parttransfered"></a>
<p>Handle PAC3 parts being reassigned to a ragdoll.</p>
<p>When a player's PAC parts transfer to their ragdoll entity during rendering.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">part</span> PAC3 part being transferred.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPAC3PartTransfered", "DisableRagdollPAC", function(part)
        part:SetNoDraw(true)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPlayerPurchaseDoor></a>OnPlayerPurchaseDoor(client, door, arg3)</summary>
<a id="onplayerpurchasedoor"></a>
<p>React when a player purchases or sells a door.</p>
<p>During door buy/sell commands after payment/ownership changes are processed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player performing the transaction.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span> Door entity involved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">arg3</span> True if selling/refunding, false if buying.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPlayerPurchaseDoor", "LogDoorSale", function(client, door, selling)
        lia.log.add(client, selling and "doorSold" or "doorBought", tostring(door))
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPlayerDroppedItem></a>OnPlayerDroppedItem(client, spawnedItem)</summary>
<a id="onplayerdroppeditem"></a>
<p>Called when a player drops an item from their inventory.</p>
<p>After an item has been successfully dropped from a player's inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player who dropped the item.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">spawnedItem</span> The spawned item entity that was created.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPlayerDroppedItem", "LogItemDrop", function(client, spawnedItem)
        print(client:Name() .. " dropped an item")
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPlayerRotateItem></a>OnPlayerRotateItem(arg1, item, newRot)</summary>
<a id="onplayerrotateitem"></a>
<p>Called when a player rotates an item in their inventory.</p>
<p>After an item has been successfully rotated in a player's inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> The player who rotated the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> The item that was rotated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">newRot</span> The new rotation value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPlayerRotateItem", "LogItemRotation", function(client, item, newRot)
        print(client:Name() .. " rotated " .. item:getName() .. " to " .. newRot)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPlayerTakeItem></a>OnPlayerTakeItem(client, item)</summary>
<a id="onplayertakeitem"></a>
<p>Called when a player takes an item into their inventory.</p>
<p>After an item has been successfully taken into a player's inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player who took the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> The item that was taken.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPlayerTakeItem", "LogItemPickup", function(client, item)
        print(client:Name() .. " took " .. item:getName())
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPrivilegeRegistered></a>OnPrivilegeRegistered(arg1, arg2, arg3, arg4)</summary>
<a id="onprivilegeregistered"></a>
<p>React when an admin privilege is registered.</p>
<p>When CAMI/compatibility layers add a new privilege.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg1</span> CAMI privilege table or simplified privilege data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">arg2</span> Optional extra data from the source integration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">arg3</span> Optional extra data from the source integration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">arg4</span> Optional extra data from the source integration.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPrivilegeRegistered", "SyncPrivileges", function(priv)
        print("Privilege added:", priv.Name or priv.name)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnPrivilegeUnregistered></a>OnPrivilegeUnregistered(arg1, arg2)</summary>
<a id="onprivilegeunregistered"></a>
<p>React when an admin privilege is removed.</p>
<p>When CAMI/compatibility layers unregister a privilege.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg1</span> Privilege data being removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">arg2</span> Optional extra data.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnPrivilegeUnregistered", "CleanupPrivilegeCache", function(priv)
        lia.admin.cache[priv.Name] = nil
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnThemeChanged></a>OnThemeChanged(themeName, useTransition)</summary>
<a id="onthemechanged"></a>
<p>Notify clients that the active UI theme changed.</p>
<p>After a theme is applied or a transition completes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">themeName</span> Name of the theme applied.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">useTransition</span> True if the theme is transitioning over time.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnThemeChanged", "RefreshPanels", function(name)
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do if panel.RefreshTheme then panel:RefreshTheme() end end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnTransferred></a>OnTransferred(target)</summary>
<a id="ontransferred"></a>
<p>Respond after a character is transferred between factions or classes.</p>
<p>Immediately after transfer logic completes in team management.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">target</span> Player whose character was transferred.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnTransferred", "StripOldClassWeapons", function(client)
        client:StripWeapons()
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnUsergroupCreated></a>OnUsergroupCreated(groupName, arg2)</summary>
<a id="onusergroupcreated"></a>
<p>React when a new usergroup is created in the admin system.</p>
<p>When an admin integration registers a new group.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> Name of the new group.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">arg2</span> Optional extra data (e.g., privilege list).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnUsergroupCreated", "CacheNewGroup", function(name)
        lia.admin.refreshGroupCache(name)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnUsergroupRemoved></a>OnUsergroupRemoved(groupName)</summary>
<a id="onusergroupremoved"></a>
<p>React when a usergroup is removed.</p>
<p>When an admin integration deletes a group.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> Name of the removed group.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnUsergroupRemoved", "PurgeRemovedGroup", function(name)
        lia.admin.groups[name] = nil
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OnUsergroupRenamed></a>OnUsergroupRenamed(oldName, newName)</summary>
<a id="onusergrouprenamed"></a>
<p>React when a usergroup is renamed.</p>
<p>After the admin system renames an existing group.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">oldName</span> Previous group name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">newName</span> Updated group name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnUsergroupRenamed", "UpdateGroupCache", function(oldName, newName)
        lia.admin.groups[newName] = lia.admin.groups[oldName]
        lia.admin.groups[oldName] = nil
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OptionAdded></a>OptionAdded(key, name, option)</summary>
<a id="optionadded"></a>
<p>Notify that a new option has been registered.</p>
<p>Immediately after `lia.option.add` stores an option.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Option key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">name</span> Stored option table (name is the localized display name).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">option</span> Option metadata table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OptionAdded", "InvalidateQuickOptions", function(key, opt)
        if opt.isQuick or (opt.data and opt.data.isQuick) then lia.option.invalidateCache() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OptionChanged></a>OptionChanged(key, old, value)</summary>
<a id="optionchanged"></a>
<p>Handle updates to option values.</p>
<p>After `lia.option.set` changes a value (client or server).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Option key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">old</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OptionChanged", "ApplyHUDScale", function(key, old, new)
        if key == "HUDScale" then lia.hud.setScale(new) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OverrideFactionDesc></a>OverrideFactionDesc(uniqueID, arg2)</summary>
<a id="overridefactiondesc"></a>
<p>Override the description shown for a faction.</p>
<p>During faction registration/loading while assembling faction data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Faction unique identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">arg2</span> Current description.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Replacement description; nil keeps the existing text.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OverrideFactionDesc", "CustomStaffDesc", function(id, desc)
        if id == "staff" then return "Lilia staff team" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OverrideFactionModels></a>OverrideFactionModels(uniqueID, arg2)</summary>
<a id="overridefactionmodels"></a>
<p>Override the model list for a faction.</p>
<p>During faction registration/loading while choosing models.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg2</span> Default models table.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Replacement models table; nil keeps defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OverrideFactionModels", "SwapCitizenModels", function(id, models)
        if id == "citizen" then return {"models/player/alyx.mdl"} end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OverrideFactionName></a>OverrideFactionName(uniqueID, arg2)</summary>
<a id="overridefactionname"></a>
<p>Override the display name for a faction.</p>
<p>During faction registration/loading before teams are created.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">arg2</span> Default faction name.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Replacement name; nil keeps the default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OverrideFactionName", "RenameCombine", function(id, name)
        if id == "combine" then return "Civil Protection" end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=OverrideSpawnTime></a>OverrideSpawnTime(ply, baseTime)</summary>
<a id="overridespawntime"></a>
<p>Adjust the respawn timer for a player.</p>
<p>When calculating respawn delay on client and server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player that will respawn.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">baseTime</span> Base respawn time in seconds.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> New respawn time; nil keeps the base value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OverrideSpawnTime", "VIPFastRespawn", function(ply, base)
        if ply:IsUserGroup("vip") then return math.max(base * 0.5, 1) end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=PlayerThrowPunch></a>PlayerThrowPunch(client)</summary>
<a id="playerthrowpunch"></a>
<p>Perform post-punch logic such as stamina consumption.</p>
<p>After a punch trace completes in the hands SWEP.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player who just punched.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerThrowPunch", "TrackPunches", function(client)
        client.punchesThrown = (client.punchesThrown or 0) + 1
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=PreLiliaLoaded></a>PreLiliaLoaded()</summary>
<a id="prelilialoaded"></a>
<p>Run right before the client finishes loading Lilia.</p>
<p>At the start of the client load sequence before `LiliaLoaded`.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PreLiliaLoaded", "SetupFonts", function()
        lia.util.createFont("liaBig", 32)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=RemovePart></a>RemovePart(client, id)</summary>
<a id="removepart"></a>
<p>Notify when a PAC3 part should be removed from a player.</p>
<p>Client-side when a part id is marked for removal from a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player losing the part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> Identifier of the part to remove.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("RemovePart", "ClearCachedPart", function(client, id)
        if client.liaPACParts then client.liaPACParts[id] = nil end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=SetupBagInventoryAccessRules></a>SetupBagInventoryAccessRules(inventory)</summary>
<a id="setupbaginventoryaccessrules"></a>
<p>Apply standard access rules to a bag's child inventory.</p>
<p>Immediately after a bag inventory is created or loaded.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Bag inventory being configured.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("SetupBagInventoryAccessRules", "CustomBagRule", function(inventory)
        inventory:addAccessRule(function(_, action) if action == "transfer" then return true end end, 2)
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=SetupPACDataFromItems></a>SetupPACDataFromItems()</summary>
<a id="setuppacdatafromitems"></a>
<p>Build PAC3 data from equipped items and push it to clients.</p>
<p>Shortly after PAC compatibility initializes to rebuild outfit data.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("SetupPACDataFromItems", "AddCustomPAC", function()
        for _, client in player.Iterator() do client:syncParts() end
    end)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=TryViewModel></a>TryViewModel(entity)</summary>
<a id="tryviewmodel"></a>
<p>Allows overriding the view model entity for PAC compatibility.</p>
<p>When determining the view model entity for PAC events.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> The potential view model entity.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> The corrected view model entity, or the original if no correction needed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("TryViewModel", "PACViewModelFix", function(entity)
        if entity == pac.LocalPlayer:GetViewModel() then
            return pac.LocalPlayer
        end
        return entity
    end)
</code></pre>
</details>

---

