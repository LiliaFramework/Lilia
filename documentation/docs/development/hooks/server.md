# Server

This page documents the functions and methods in the meta table.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
Server-side hooks in the Lilia framework handle server-side logic, data persistence, permissions, character management, and other server-specific functionality. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
</div>

---

<details class="realm-server" id="function-addwarning">
<summary><a id="AddWarning"></a>AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="addwarning"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Records a warning entry for a character and lets modules react to the new warning.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired whenever a warning is issued via admin commands, anti-cheat triggers, or net requests.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">charID</span> Character database identifier being warned.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">warned</span> Display name of the warned player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">warnedSteamID</span> SteamID of the warned player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">timestamp</span> Unix timestamp when the warning was created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Reason text for the warning.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">warner</span> Name of the admin or system issuing the warning.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">warnerSteamID</span> SteamID of the issuer.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">severity</span> Severity label such as Low/Medium/High.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Final severity value chosen (if modified) or nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AddWarning", "LogWarning", function(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
      lia.log.add(warner, "warningIssued", warned, severity, message)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-collectdoordatafields">
<summary><a id="CollectDoorDataFields"></a>CollectDoorDataFields(extras)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="collectdoordatafields"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Collect additional field definitions for door data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When retrieving default door values and field definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">extras</span> Table to populate with additional field definitions in the format {fieldName = {default = value, ...}}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CollectDoorDataFields", "ExampleCollectDoorDataFields", function(extras)
      extras.customField = {default = false, type = "boolean"}
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canitembetransfered">
<summary><a id="CanItemBeTransfered"></a>CanItemBeTransfered(item, inventory, VendorInventoryMeasure, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canitembetransfered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines if an item move is allowed before completing a transfer between inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked whenever an item is about to be moved to another inventory (including vendors).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being transferred.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Destination inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">VendorInventoryMeasure</span> True when the transfer originates from a vendor panel.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the transfer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block the transfer; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanItemBeTransfered", "LimitAmmoMoves", function(item, inventory, isVendor, client)
      if isVendor and item.isWeapon then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canpersistentity">
<summary><a id="CanPersistEntity"></a>CanPersistEntity(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canpersistentity"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if an entity should be recorded in the persistence system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Invoked while scanning entities for persistence during map saves.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The world entity being evaluated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to skip saving this entity; nil/true to include it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPersistEntity", "IgnoreRagdolls", function(ent)
      if ent:IsRagdoll() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayeraccessdoor">
<summary><a id="CanPlayerAccessDoor"></a>CanPlayerAccessDoor(client, door, access)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayeraccessdoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets modules override door access checks before built-in permissions are evaluated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Queried whenever door access is validated in entity:checkDoorAccess.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting access.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">access</span> Required access level (e.g., DOOR_OWNER, DOOR_TENANT, DOOR_GUEST).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True to grant access regardless of stored permissions; nil to fall back to defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerAccessDoor", "StaffOverrideDoor", function(client, door)
      if client:isStaffOnDuty() then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayeraccessvendor">
<summary><a id="CanPlayerAccessVendor"></a>CanPlayerAccessVendor(client, vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayeraccessvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows or denies a player opening/using a vendor entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked when a player attempts to access a vendor UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player interacting with the vendor.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity being accessed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block interaction; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerAccessVendor", "FactionLockVendors", function(client, vendor)
      if not vendor:isFactionAllowed(client:Team()) then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerdropitem">
<summary><a id="CanPlayerDropItem"></a>CanPlayerDropItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerdropitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Controls whether a player may drop a specific item from their inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered before an item drop is performed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting to drop the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being dropped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block the drop; true/nil to permit.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerDropItem", "NoQuestItemDrops", function(client, item)
      if item.isQuestItem then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerearnsalary">
<summary><a id="CanPlayerEarnSalary"></a>CanPlayerEarnSalary(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerearnsalary"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a player is eligible to receive their periodic salary.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Evaluated each time salary is about to be granted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player due to receive salary.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block salary payment; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerEarnSalary", "JailedNoSalary", function(client)
      if client:isJailed() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerequipitem">
<summary><a id="CanPlayerEquipItem"></a>CanPlayerEquipItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerequipitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if a player is allowed to equip a given item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked before the equip logic for any item runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player equipping the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being equipped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent equipping; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerEquipItem", "RestrictHeavyArmor", function(client, item)
      if item.weight and item.weight &gt; 20 then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerholdobject">
<summary><a id="CanPlayerHoldObject"></a>CanPlayerHoldObject(client, entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerholdobject"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows or blocks a player from picking up physics objects with their hands tool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked before a player grabs an entity with lia_hands.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting to hold the object.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Target entity being picked up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent picking up; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerHoldObject", "NoHoldingDoors", function(client, ent)
      if ent:isDoor() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerinteractitem">
<summary><a id="CanPlayerInteractItem"></a>CanPlayerInteractItem(client, action, item, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerinteractitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets modules validate or modify player item interactions (use, drop, split, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired before an inventory action runs on an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the action.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">action</span> Interaction verb such as "drop", "combine", or a custom action ID.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being interacted with.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Extra data supplied by the action (position, merge target, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string False or false,reason to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerInteractItem", "StopHotbarDrop", function(client, action, item)
      if action == "drop" and item.noDrop then return false, L("cannotDrop") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerlock">
<summary><a id="CanPlayerLock"></a>CanPlayerLock(client, door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if a player may lock a door or vehicle using provided access rights.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Evaluated before lock attempts are processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the lock.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door or vehicle entity targeted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent locking; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerLock", "OnlyOwnersLock", function(client, door)
      if not door:checkDoorAccess(client, DOOR_OWNER) then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerseelogcategory">
<summary><a id="CanPlayerSeeLogCategory"></a>CanPlayerSeeLogCategory(client, category)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerseelogcategory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Controls visibility of specific log categories to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked before sending a log entry or opening the log viewer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting or receiving logs.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">category</span> Category identifier of the log.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to hide the category; true/nil to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerSeeLogCategory", "HideAdminLogs", function(client, category)
      if category == "admin" and not client:isStaffOnDuty() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerspawnstorage">
<summary><a id="CanPlayerSpawnStorage"></a>CanPlayerSpawnStorage(client, entity, info)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerspawnstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player is permitted to spawn a storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Invoked when a storage deploy action is requested.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player spawning the storage.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Storage entity class about to be created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">info</span> Context info such as item data or position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block spawning; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerSpawnStorage", "LimitStoragePerPlayer", function(client, entity)
      if client:GetCount("lia_storage") &gt;= 2 then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerswitchchar">
<summary><a id="CanPlayerSwitchChar"></a>CanPlayerSwitchChar(client, currentCharacter, newCharacter)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerswitchchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validates whether a player may switch from their current character to another.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked when a player initiates a character switch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the swap.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">currentCharacter</span> Active character.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">newCharacter</span> Target character to switch to.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to deny the swap; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerSwitchChar", "BlockDuringCombat", function(client)
      if client:isInCombat() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayertakeitem">
<summary><a id="CanPlayerTakeItem"></a>CanPlayerTakeItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayertakeitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a player may take an item out of a container or ground entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired before item pickup/move from a world/container inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting to take the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being taken.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block taking; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerTakeItem", "LockdownLooting", function(client, item)
      if lia.state.isLockdown() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayertradewithvendor">
<summary><a id="CanPlayerTradeWithVendor"></a>CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayertradewithvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Approves or denies a vendor transaction before money/items exchange.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Invoked when a player tries to buy from or sell to a vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player trading with the vendor.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> UniqueID of the item being traded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> True when the player sells an item to the vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string, any False,reason to cancel; true/nil to allow. Optional third param for formatted message data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerTradeWithVendor", "RestrictRareItems", function(client, vendor, itemType)
      if lia.item.list[itemType].rarity == "legendary" and not client:isVIP() then
          return false, L("vendorVIPOnly")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerunequipitem">
<summary><a id="CanPlayerUnequipItem"></a>CanPlayerUnequipItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerunequipitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if a player may unequip an item currently worn/active.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked before unequip logic runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting to unequip.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item being unequipped.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerUnequipItem", "PreventCombatUnequip", function(client, item)
      if client:isInCombat() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerunlock">
<summary><a id="CanPlayerUnlock"></a>CanPlayerUnlock(client, door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerunlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if a player can unlock a door or vehicle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Evaluated before unlock attempts are processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the unlock.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door or vehicle entity targeted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block unlocking; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerUnlock", "OnlyOwnersUnlock", function(client, door)
      if not door:checkDoorAccess(client, DOOR_OWNER) then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerusechar">
<summary><a id="CanPlayerUseChar"></a>CanPlayerUseChar(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerusechar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validates that a player can use/load a given character record.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked before spawning the character into the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting to use the character.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character record being selected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent selection; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerUseChar", "BanSpecificChar", function(client, character)
      if character:getData("locked") then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerusedoor">
<summary><a id="CanPlayerUseDoor"></a>CanPlayerUseDoor(client, door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerusedoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Final gate before a player uses a door (open, interact).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player attempts to use a door entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player using the door.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity being used.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to deny use; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerUseDoor", "LockdownUse", function(client, door)
      if lia.state.isLockdown() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-cansavedata">
<summary><a id="CanSaveData"></a>CanSaveData(ent, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="cansavedata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides if an entity's data should be included when saving persistent map state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During persistence save routines.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity being evaluated for save.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory attached to the entity (if any).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to skip saving; true/nil to save.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanSaveData", "SkipTempProps", function(ent)
      if ent.tempSpawned then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-createsalarytimers">
<summary><a id="CreateSalaryTimers"></a>CreateSalaryTimers()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createsalarytimers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when salary timers need to be created or recreated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During server initialization and when salary timers need to be reset.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateSalaryTimers", "ExampleCreateSalaryTimers", function(...)
      -- add custom server-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-charcleanup">
<summary><a id="CharCleanUp"></a>CharCleanUp(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charcleanup"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides a cleanup hook when a character is fully removed from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After character deletion/cleanup logic runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character object being cleaned up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharCleanUp", "RemoveCharTimers", function(character)
      timer.Remove("char_timer_" .. character:getID())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-chardeleted">
<summary><a id="CharDeleted"></a>CharDeleted(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="chardeleted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a character has been removed from the database and game.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a character is deleted by the player or admin.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who owned the character (may be nil if offline).</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> The character that was deleted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharDeleted", "LogDeletion", function(client, character)
      lia.log.add(client, "charDeleted", character:getName())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-charlistextradetails">
<summary><a id="CharListExtraDetails"></a>CharListExtraDetails(client, entry, stored)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charlistextradetails"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds extra per-character info to the character selection list entry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While building the char list shown to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player viewing the list.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entry</span> Table of character info to be sent.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">stored</span> Raw character data from storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Optionally return modified entry data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharListExtraDetails", "AddPlaytime", function(client, entry, stored)
      entry.playtime = stored.playtime or 0
      return entry
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-charpostsave">
<summary><a id="CharPostSave"></a>CharPostSave(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charpostsave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a character has been saved to persistence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after character data write completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character that was saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharPostSave", "QueueBackup", function(character)
      lia.backup.queue(character:getID())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-charpresave">
<summary><a id="CharPreSave"></a>CharPreSave(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charpresave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Pre-save hook for characters to sync state into the database payload.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before character data is persisted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character about to be saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharPreSave", "StoreTempAmmo", function(character)
      local client = character:getPlayer()
      if IsValid(client) then character:setData("ammo", client:GetAmmo()) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-checkfactionlimitreached">
<summary><a id="CheckFactionLimitReached"></a>CheckFactionLimitReached(faction, character, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="checkfactionlimitreached"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows factions to enforce population limits before creation/join.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checked when a player attempts to create or switch to a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction definition table.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character requesting the faction.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player owning the character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block joining; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CheckFactionLimitReached", "CapCombine", function(faction)
      if faction.uniqueID == "combine" and faction:onlineCount() &gt;= 10 then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-databaseconnected">
<summary><a id="DatabaseConnected"></a>DatabaseConnected()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="databaseconnected"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that the database connection is established and ready.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once the SQL connection succeeds during initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DatabaseConnected", "InitPlugins", function()
      lia.plugin.loadAll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-discordrelaysend">
<summary><a id="DiscordRelaySend"></a>DiscordRelaySend(embed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelaysend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to intercept and modify Discord relay embeds before sending.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before an embed is pushed to the Discord relay webhook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">embed</span> Table describing the Discord embed payload.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Optionally return a modified embed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DiscordRelaySend", "AddFooter", function(embed)
      embed.footer = {text = "Lilia Relay"}
      return embed
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-discordrelayunavailable">
<summary><a id="DiscordRelayUnavailable"></a>DiscordRelayUnavailable()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelayunavailable"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies the game that the Discord relay feature became unavailable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered when the relay HTTP endpoint cannot be reached or is disabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DiscordRelayUnavailable", "AlertStaff", function()
      lia.log.add(nil, "discordRelayDown")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-discordrelayed">
<summary><a id="DiscordRelayed"></a>DiscordRelayed(embed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="discordrelayed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired after a Discord relay message has been successfully sent.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the relay HTTP request completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">embed</span> Embed table that was sent.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DiscordRelayed", "TrackRelayCount", function(embed)
      lia.metrics.bump("discordRelay")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorenabledtoggled">
<summary><a id="DoorEnabledToggled"></a>DoorEnabledToggled(client, door, newState)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorenabledtoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a door's enabled/disabled state has been toggled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After admin tools enable or disable door ownership/usage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who toggled the state.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity affected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">newState</span> True when enabled, false when disabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorEnabledToggled", "AnnounceToggle", function(client, door, state)
      lia.log.add(client, "doorEnabledToggle", tostring(state))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorhiddentoggled">
<summary><a id="DoorHiddenToggled"></a>DoorHiddenToggled(client, entity, newState)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorhiddentoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a door has been hidden or unhidden from ownership.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the hidden flag is toggled for a door entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the change.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Door entity affected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">newState</span> True when hidden, false when shown.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorHiddenToggled", "MirrorToClients", function(_, door, state)
      net.Start("liaDoorHidden") net.WriteEntity(door) net.WriteBool(state) net.Broadcast()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorlocktoggled">
<summary><a id="DoorLockToggled"></a>DoorLockToggled(client, door, state)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorlocktoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a door lock state is toggled (locked/unlocked).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After lock/unlock succeeds via key or command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who toggled the lock.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">state</span> True if now locked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorLockToggled", "SoundDoorLock", function(_, door, state)
      door:EmitSound(state and "doors/door_latch3.wav" or "doors/door_latch1.wav")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorownabletoggled">
<summary><a id="DoorOwnableToggled"></a>DoorOwnableToggled(client, door, newState)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorownabletoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a door has been marked ownable or unownable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After toggling door ownership availability.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the toggle.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity affected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">newState</span> True when ownable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorOwnableToggled", "SyncOwnableState", function(_, door, state)
      net.Start("liaDoorOwnable") net.WriteEntity(door) net.WriteBool(state) net.Broadcast()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorpriceset">
<summary><a id="DoorPriceSet"></a>DoorPriceSet(client, door, price)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorpriceset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a door purchase price is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a player sets a new door price via management tools.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player setting the price.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">price</span> New purchase price.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorPriceSet", "LogDoorPrice", function(client, door, price)
      lia.log.add(client, "doorPriceSet", price)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doortitleset">
<summary><a id="DoorTitleSet"></a>DoorTitleSet(client, door, name)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doortitleset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a door's title/name is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a player renames a door via the interface or command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player setting the title.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> New door title.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorTitleSet", "SaveDoorTitle", function(client, door, name)
      door:setNetVar("doorTitle", name)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-fetchspawns">
<summary><a id="FetchSpawns"></a>FetchSpawns()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="fetchspawns"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Requests the server spawn list; gives modules a chance to override or inject spawns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When spawn points are being loaded or refreshed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Custom spawn data table or nil to use defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("FetchSpawns", "UseCustomSpawns", function()
      return lia.spawns.getCustom()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getallcaseclaims">
<summary><a id="GetAllCaseClaims"></a>GetAllCaseClaims()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getallcaseclaims"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns a list of all active support tickets claimed by staff.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the ticket system needs to display open claims.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Array of ticket claim data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAllCaseClaims", "MirrorTickets", function()
      return lia.ticket.getClaims()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getbotmodel">
<summary><a id="GetBotModel"></a>GetBotModel(client, faction)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getbotmodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides the model to use for spawning a bot player given a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During bot setup when choosing a model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Bot player entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction data assigned to the bot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Model path to use for the bot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetBotModel", "RandomCitizenModel", function(client, faction)
      if faction.uniqueID == "citizen" then return "models/Humans/Group01/male_07.mdl" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getdamagescale">
<summary><a id="GetDamageScale"></a>GetDamageScale(hitgroup, dmgInfo, damageScale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdamagescale"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets modules adjust the final damage scale applied to a hitgroup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During ScalePlayerDamage after base scaling has been calculated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> Hitgroup constant from the damage trace.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> Damage info object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> Current scale value about to be applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> New scale value to apply or nil to keep current.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDamageScale", "HelmetProtection", function(hitgroup, dmgInfo, scale)
      if hitgroup == HITGROUP_HEAD and dmgInfo:IsBulletDamage() then return scale * 0.5 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getdefaultinventorytype">
<summary><a id="GetDefaultInventoryType"></a>GetDefaultInventoryType(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdefaultinventorytype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Specifies which inventory type to create for a character by default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During character creation and bot setup before inventories are instanced.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character being initialized (may be nil for bots).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Inventory type ID (e.g., "GridInv").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDefaultInventoryType", "UseListInventory", function(character)
      return "ListInv"
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getentitysavedata">
<summary><a id="GetEntitySaveData"></a>GetEntitySaveData(ent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getentitysavedata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides custom data to persist for an entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While serializing entities for persistence saves.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity being saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Data table to store or nil for none.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetEntitySaveData", "SaveHealth", function(ent)
      return {health = ent:Health()}
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getoocdelay">
<summary><a id="GetOOCDelay"></a>GetOOCDelay(speaker)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getoocdelay"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to set or modify the OOC chat cooldown for a speaker.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time an OOC message is about to be sent.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">speaker</span> Player sending the OOC message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Cooldown in seconds, or nil to use config default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetOOCDelay", "VIPShorterCooldown", function(speaker)
      if speaker:isVIP() then return 5 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getplaytime">
<summary><a id="GetPlayTime"></a>GetPlayTime(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplaytime"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override or calculate a player's tracked playtime value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When playtime is requested for display or logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose playtime is queried.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Seconds of playtime.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayTime", "CustomPlaytime", function(client)
      return client:getChar():getData("customPlaytime", 0)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getplayerdeathsound">
<summary><a id="GetPlayerDeathSound"></a>GetPlayerDeathSound(client, isFemale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerdeathsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Supplies the death sound file to play for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During PlayerDeath when death sounds are enabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who died.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isFemale</span> Gender flag.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Sound path to emit.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerDeathSound", "FactionDeathSounds", function(client)
      if client:Team() == FACTION_CP then return "npc/metropolice/pain1.wav" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getplayerpainsound">
<summary><a id="GetPlayerPainSound"></a>GetPlayerPainSound(paintype, isFemale, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerpainsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides the pain sound to play for a hurt entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During damage processing when selecting pain sounds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">paintype</span> Pain type identifier ("hurt", etc.).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isFemale</span> Gender flag.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">client</span> Entity that is hurt.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Sound path to emit, or nil to use default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerPainSound", "RobotPain", function(client, paintype)
      if client:IsPlayer() and client:IsCombine() then return "npc/combine_soldier/pain1.wav" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getplayerrespawnlocation">
<summary><a id="GetPlayerRespawnLocation"></a>GetPlayerRespawnLocation(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerrespawnlocation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Selects where a player should respawn after death.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During respawn processing to determine the spawn location.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player respawning.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character data of the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>vector, angle Position and angle for the respawn; nil to use default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerRespawnLocation", "HospitalRespawn", function(client)
      return lia.spawns.getHospitalPos(), lia.spawns.getHospitalAng()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getplayerspawnlocation">
<summary><a id="GetPlayerSpawnLocation"></a>GetPlayerSpawnLocation(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerspawnlocation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Chooses the spawn location for a player when initially joining the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During first spawn/character load to position the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player spawning.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character data of the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>vector, angle Position and angle; nil to use map spawns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerSpawnLocation", "FactionSpawns", function(client, character)
      return lia.spawns.getFactionSpawn(character:getFaction())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getprestigepaybonus">
<summary><a id="GetPrestigePayBonus"></a>GetPrestigePayBonus(client, char, pay, faction, class)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getprestigepaybonus"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows adjusting the salary amount using a prestige bonus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time salary is calculated for a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving salary.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">char</span> Character data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">pay</span> Current salary amount.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction definition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">class</span> Class definition (if any).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Modified pay amount or nil to keep.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPrestigePayBonus", "PrestigeScaling", function(client, char, pay)
      return pay + (char:getData("prestigeLevel", 0) * 50)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getsalaryamount">
<summary><a id="GetSalaryAmount"></a>GetSalaryAmount(client, faction, class)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getsalaryamount"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provides the base salary amount for a player based on faction/class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever salary is being computed for payout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving salary.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction definition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">class</span> Class definition (may be nil).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Salary amount.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetSalaryAmount", "VIPSalary", function(client, faction, class)
      if client:isVIP() then return 500 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getticketsbyrequester">
<summary><a id="GetTicketsByRequester"></a>GetTicketsByRequester(steamID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getticketsbyrequester"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves all ticket entries made by a specific requester SteamID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During ticket queries filtered by requester.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">steamID</span> SteamID64 or SteamID of the requester.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> List of ticket rows.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetTicketsByRequester", "MaskRequester", function(steamID)
      return lia.tickets.byRequester(steamID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getwarnings">
<summary><a id="GetWarnings"></a>GetWarnings(charID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getwarnings"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fetches all warnings stored for a character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When viewing a character's warning history.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">charID</span> Character database identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Array of warning rows.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetWarnings", "MirrorWarnings", function(charID)
      return lia.warn.get(charID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getwarningsbyissuer">
<summary><a id="GetWarningsByIssuer"></a>GetWarningsByIssuer(steamID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getwarningsbyissuer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves warnings issued by a specific SteamID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When filtering warnings by issuing admin.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">steamID</span> SteamID of the issuer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Array of warning rows.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetWarningsByIssuer", "ListIssuerWarnings", function(steamID)
      return lia.warn.getByIssuer(steamID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-handleitemtransferrequest">
<summary><a id="HandleItemTransferRequest"></a>HandleItemTransferRequest(client, itemID, x, y, invID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="handleitemtransferrequest"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handles the server-side logic when a client requests to move an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the inventory UI sends a transfer request.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the transfer.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">itemID</span> Item instance identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> Target X slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> Target Y slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">invID</span> Destination inventory ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("HandleItemTransferRequest", "LogTransfers", function(client, itemID, x, y, invID)
      lia.log.add(client, "itemMove", itemID, invID, x, y)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-inventorydeleted">
<summary><a id="InventoryDeleted"></a>InventoryDeleted(instance)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventorydeleted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that an inventory has been removed or destroyed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an inventory instance is deleted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">instance</span> Inventory object that was removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryDeleted", "CleanupInvCache", function(instance)
      lia.inventory.cache[instance:getID()] = nil
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemcombine">
<summary><a id="ItemCombine"></a>ItemCombine(client, item, target)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemcombine"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player combines an item with another (stacking or crafting).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the combine action has been requested.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the combine.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Primary item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">target</span> Target item being combined into.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block the combine; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemCombine", "BlockCertainCombines", function(client, item, target)
      if target.noCombine then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemdeleted">
<summary><a id="ItemDeleted"></a>ItemDeleted(instance)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemdeleted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that an item instance has been deleted from storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after an item is removed from persistence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">instance</span> Item instance that was deleted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemDeleted", "LogItemDelete", function(instance)
      lia.log.add(nil, "itemDeleted", instance.uniqueID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemfunctioncalled">
<summary><a id="ItemFunctionCalled"></a>ItemFunctionCalled(item, method, client, entity, results)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemfunctioncalled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called whenever an item method is executed so modules can react or modify results.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item function such as OnUse or custom actions is invoked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance whose method was called.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">method</span> Name of the method invoked.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who triggered the call.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Entity representation if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">results</span> Return values from the method.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemFunctionCalled", "AuditItemUse", function(item, method, client)
      lia.log.add(client, "itemFunction", item.uniqueID, method)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemtransfered">
<summary><a id="ItemTransfered"></a>ItemTransfered(context)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemtransfered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fires after an item has been successfully transferred between inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after a transfer completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">context</span> Transfer context containing client, item, from, and to inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemTransfered", "NotifyTransfer", function(context)
      lia.log.add(context.client, "itemTransferred", context.item.uniqueID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-keylock">
<summary><a id="KeyLock"></a>KeyLock(client, door, time)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="keylock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the key lock timing or behavior when using key items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player uses a key to lock a door for a set duration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player locking.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> Duration of the lock action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("KeyLock", "InstantLock", function(client, door)
      door:Fire("lock")
      return false
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-keyunlock">
<summary><a id="KeyUnlock"></a>KeyUnlock(client, door, time)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="keyunlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding key-based unlock timing or behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player uses a key to unlock a door for a duration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player unlocking.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> Duration for unlock action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("KeyUnlock", "InstantUnlock", function(client, door)
      door:Fire("unlock")
      return false
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-kickedfromchar">
<summary><a id="KickedFromChar"></a>KickedFromChar(characterID, isCurrentChar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="kickedfromchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a character is kicked from the session and forced to select another.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the character kick is processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">characterID</span> ID of the character kicked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isCurrentChar</span> True if it was the active character at time of kick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("KickedFromChar", "LogCharKick", function(characterID, wasCurrent)
      lia.log.add(nil, "charKicked", characterID, wasCurrent)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liliatablesloaded">
<summary><a id="LiliaTablesLoaded"></a>LiliaTablesLoaded()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liliatablesloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Indicates that all Lilia database tables have been created/loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After tables are created during startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LiliaTablesLoaded", "SeedDefaults", function()
      lia.seed.run()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-loaddata">
<summary><a id="LoadData"></a>LoadData()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="loaddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to inject data when the gamemode performs a data load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During server startup after initial load begins.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LoadData", "LoadCustomData", function()
      lia.data.loadCustom()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-modifycharactermodel">
<summary><a id="ModifyCharacterModel"></a>ModifyCharacterModel(arg1, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="modifycharactermodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets modules change the model chosen for a character before it is set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During character creation or model updates.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg1</span> Context value (varies by caller).</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character being modified.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Model path override or nil to keep current.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ModifyCharacterModel", "ForceFactionModel", function(_, character)
      if character:getFaction() == FACTION_STAFF then return "models/player/police_fem.mdl" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharattribboosted">
<summary><a id="OnCharAttribBoosted"></a>OnCharAttribBoosted(client, character, attribID, boostID, arg5)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharattribboosted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies when an attribute boost is applied to a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After lia.attrib has boosted an attribute.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose character was boosted.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character receiving the boost.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">attribID</span> Attribute identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">boostID</span> Boost source identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg5</span> Additional data supplied by the boost.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharAttribBoosted", "LogBoost", function(client, character, attribID, boostID)
      lia.log.add(client, "attribBoosted", attribID, boostID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharattribupdated">
<summary><a id="OnCharAttribUpdated"></a>OnCharAttribUpdated(client, character, key, arg4)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharattribupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a character attribute value has been updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After attribute points are changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose character changed.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">key</span> Attribute identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg4</span> Old value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharAttribUpdated", "SyncAttrib", function(client, character, key, oldValue)
      lia.log.add(client, "attribUpdated", key, oldValue, character:getAttrib(key))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharcreated">
<summary><a id="OnCharCreated"></a>OnCharCreated(client, character, originalData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a new character has been created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after character creation succeeds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who created the character.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> New character object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">originalData</span> Raw creation data submitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharCreated", "WelcomeMessage", function(client, character)
      client:notifyLocalized("charCreated", character:getName())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onchardelete">
<summary><a id="OnCharDelete"></a>OnCharDelete(client, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchardelete"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Invoked just before a character is deleted from persistence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before deletion is executed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting deletion.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Character ID to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharDelete", "BackupChar", function(client, id)
      lia.backup.character(id)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onchardisconnect">
<summary><a id="OnCharDisconnect"></a>OnCharDisconnect(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchardisconnect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player disconnects while owning a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the player leaves the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who disconnected.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character they had active.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharDisconnect", "SaveOnLeave", function(client, character)
      character:save()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharflagsgiven">
<summary><a id="OnCharFlagsGiven"></a>OnCharFlagsGiven(ply, character, addedFlags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharflagsgiven"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that flags have been granted to a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After permanent or session flags are added.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player whose character received flags.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character instance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">addedFlags</span> Flags added.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharFlagsGiven", "LogFlagGrant", function(ply, character, addedFlags)
      lia.log.add(ply, "flagsGiven", addedFlags)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharflagstaken">
<summary><a id="OnCharFlagsTaken"></a>OnCharFlagsTaken(ply, character, removedFlags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharflagstaken"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that flags have been removed from a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After flag removal occurs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player whose character lost flags.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character affected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">removedFlags</span> Flags removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharFlagsTaken", "LogFlagRemoval", function(ply, character, removedFlags)
      lia.log.add(ply, "flagsTaken", removedFlags)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharkick">
<summary><a id="OnCharKick"></a>OnCharKick(character, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharkick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs when a character is kicked out of the game or forced to menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After kicking logic completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character that was kicked.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player owning the character (may be nil).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharKick", "LogCharKick", function(character, client)
      lia.log.add(client, "charKicked", character:getName())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharnetvarchanged">
<summary><a id="OnCharNetVarChanged"></a>OnCharNetVarChanged(character, key, oldVar, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharnetvarchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a character networked variable changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever character:setNetVar updates a value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character whose var changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Net var key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldVar</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharNetVarChanged", "TrackWantedState", function(character, key, old, value)
      if key == "wanted" then lia.log.add(nil, "wantedToggle", character:getName(), value) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharpermakilled">
<summary><a id="OnCharPermakilled"></a>OnCharPermakilled(character, time)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharpermakilled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reports that a character has been permanently killed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After perma-kill logic marks the character as dead.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character that was permakilled.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> Timestamp of the perma-kill.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharPermakilled", "AnnouncePerma", function(character)
      lia.chat.send(nil, "event", L("permakilled", character:getName()))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncharrecognized">
<summary><a id="OnCharRecognized"></a>OnCharRecognized(client, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharrecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies when a recognition check is performed between characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When determining if one character recognizes another.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the recognition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg2</span> Target data (player or character).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if recognized; nil/false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharRecognized", "AlwaysRecognizeTeam", function(client, target)
      if target:getFaction() == client:Team() then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onchartradevendor">
<summary><a id="OnCharTradeVendor"></a>OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchartradevendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired after a player completes a vendor trade interaction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After buy/sell attempt is processed, including failures.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player trading.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance if available.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> True if player sold to vendor.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Player character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isFailed</span> True if the trade failed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharTradeVendor", "TrackVendorTrade", function(client, vendor, item, selling)
      lia.log.add(client, selling and "vendorSell" or "vendorBuy", item and item.uniqueID or "unknown")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-oncheatercaught">
<summary><a id="OnCheaterCaught"></a>OnCheaterCaught(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncheatercaught"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered when a player is flagged as a cheater by detection logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After anti-cheat routines identify suspicious behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player detected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCheaterCaught", "AutoKickCheaters", function(client)
      client:Kick("Cheating detected")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ondataset">
<summary><a id="OnDataSet"></a>OnDataSet(key, value, gamemode, map)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ondataset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fires when lia.data.set writes a value so other modules can react.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after a data key is set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> Value written.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">gamemode</span> Gamemode identifier (namespace).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">map</span> Map name associated with the data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnDataSet", "MirrorToCache", function(key, value)
      lia.cache.set(key, value)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ondatabaseloaded">
<summary><a id="OnDatabaseLoaded"></a>OnDatabaseLoaded()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ondatabaseloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Indicates that the database has finished loading queued data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After tables/data are loaded on startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnDatabaseLoaded", "StartSalaryTimers", function()
      hook.Run("CreateSalaryTimers")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ondeathsoundplayed">
<summary><a id="OnDeathSoundPlayed"></a>OnDeathSoundPlayed(client, deathSound)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ondeathsoundplayed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a death sound has been played for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After emitting the death sound in PlayerDeath.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who died.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">deathSound</span> Sound path played.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnDeathSoundPlayed", "BroadcastDeathSound", function(client, sound)
      lia.log.add(client, "deathSound", sound)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onentityloaded">
<summary><a id="OnEntityLoaded"></a>OnEntityLoaded(ent, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onentityloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when an entity is loaded from persistence with its saved data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After entity creation during map load and persistence restore.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity loaded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Saved data applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnEntityLoaded", "RestoreHealth", function(ent, data)
      if data.health then ent:SetHealth(data.health) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onentitypersistupdated">
<summary><a id="OnEntityPersistUpdated"></a>OnEntityPersistUpdated(ent, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onentitypersistupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that persistent data for an entity has been updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After persistence storage for an entity is rewritten.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity whose data changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> New persistence data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnEntityPersistUpdated", "RefreshDataCache", function(ent, data)
      ent.cachedPersist = data
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onentitypersisted">
<summary><a id="OnEntityPersisted"></a>OnEntityPersisted(ent, entData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onentitypersisted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when an entity is first persisted to storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the moment entity data is captured for saving.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity being persisted.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entData</span> Data collected for saving.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnEntityPersisted", "AddOwnerData", function(ent, data)
      if ent:GetNWString("owner") then data.owner = ent:GetNWString("owner") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onitemspawned">
<summary><a id="OnItemSpawned"></a>OnItemSpawned(itemEntity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemspawned"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when an item entity spawns into the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item entity is created (drop or spawn).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">itemEntity</span> Item entity instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnItemSpawned", "ApplyItemGlow", function(itemEntity)
      itemEntity:SetRenderFX(kRenderFxGlowShell)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onloadtables">
<summary><a id="OnLoadTables"></a>OnLoadTables()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onloadtables"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that data tables for the gamemode have been loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After loading tables during startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnLoadTables", "InitVendors", function()
      lia.vendor.loadAll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onnpctypeset">
<summary><a id="OnNPCTypeSet"></a>OnNPCTypeSet(client, npc, npcID, filteredData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onnpctypeset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the NPC type assignment for an NPC entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When setting an NPC's type using management tools.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player setting the type.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> NPC entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> Target NPC type ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">filteredData</span> Data prepared for the NPC.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnNPCTypeSet", "LogNPCType", function(client, npc, npcID)
      lia.log.add(client, "npcTypeSet", npcID)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onoocmessagesent">
<summary><a id="OnOOCMessageSent"></a>OnOOCMessageSent(client, message)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onoocmessagesent"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when an OOC chat message is sent to the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an OOC message passes cooldown checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Speaker.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Message text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnOOCMessageSent", "RelayToDiscord", function(client, message)
      lia.discord.send("OOC", client:Name(), message)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onpainsoundplayed">
<summary><a id="OnPainSoundPlayed"></a>OnPainSoundPlayed(entity, painSound)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onpainsoundplayed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a pain sound has been played for an entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a pain sound is emitted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Entity that made the sound.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">painSound</span> Sound path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPainSoundPlayed", "CountPainSounds", function(entity, sound)
      lia.metrics.bump("painSounds")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onpickupmoney">
<summary><a id="OnPickupMoney"></a>OnPickupMoney(activator, moneyEntity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onpickupmoney"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player picks up a money entity from the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After money is collected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">activator</span> Player who picked up the money.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">moneyEntity</span> Money entity removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPickupMoney", "LogMoneyPickup", function(ply, moneyEnt)
      lia.log.add(ply, "moneyPickup", moneyEnt:getAmount())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerentersequence">
<summary><a id="OnPlayerEnterSequence"></a>OnPlayerEnterSequence(client, sequenceName, callback, time, noFreeze)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerentersequence"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player starts an animated sequence (e.g., sit or custom act).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When sequence playback is initiated through player sequences.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player entering the sequence.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">sequenceName</span> Sequence identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">callback</span> Function to call when sequence ends.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> Duration of the sequence.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">noFreeze</span> Whether player movement is frozen.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerEnterSequence", "SequenceLog", function(client, sequenceName)
      lia.log.add(client, "sequenceStart", sequenceName)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerinteractitem">
<summary><a id="OnPlayerInteractItem"></a>OnPlayerInteractItem(client, action, item, result, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerinteractitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a player interacts with an item and receives a result.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After item interaction logic completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the action.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">action</span> Action identifier.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item involved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|string|table</a></span> <span class="parameter">result</span> Result of the action.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Additional action data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerInteractItem", "NotifyUse", function(client, action, item, result)
      if result then client:notifyLocalized("itemAction", action, item:getName()) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerjoinclass">
<summary><a id="OnPlayerJoinClass"></a>OnPlayerJoinClass(target, arg2, oldClass)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerjoinclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered when a player joins a class or team variant.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the class change is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player who changed class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg2</span> New class data/index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldClass</span> Previous class data/index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerJoinClass", "ClassLog", function(client, newClass, oldClass)
      lia.log.add(client, "classJoined", tostring(newClass))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerleavesequence">
<summary><a id="OnPlayerLeaveSequence"></a>OnPlayerLeaveSequence(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerleavesequence"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player exits an animated sequence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the sequence finishes or is cancelled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player leaving the sequence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerLeaveSequence", "SequenceEndLog", function(client)
      lia.log.add(client, "sequenceEnd")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerloststackitem">
<summary><a id="OnPlayerLostStackItem"></a>OnPlayerLostStackItem(itemTypeOrItem)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerloststackitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies when a player loses a stackable item (stack count reaches zero).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After stack removal logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|Item</a></span> <span class="parameter">itemTypeOrItem</span> Item uniqueID or item instance removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerLostStackItem", "RevokeBuff", function(itemTypeOrItem)
      if itemTypeOrItem == "medkit" then lia.buff.remove("healing") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerobserve">
<summary><a id="OnPlayerObserve"></a>OnPlayerObserve(client, state)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerobserve"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies when a player toggles observer mode (freecam/third person).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When observation state changes via admin commands or mechanics.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player entering or exiting observe.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">state</span> True when entering observe mode.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerObserve", "HideHUD", function(client, state)
      client:setNetVar("hideHUD", state)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerragdolled">
<summary><a id="OnPlayerRagdolled"></a>OnPlayerRagdolled(client, ragdoll)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerragdolled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player is ragdolled (knocked out, physics ragdoll).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the ragdoll is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player ragdolled.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ragdoll</span> Ragdoll entity created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerRagdolled", "TrackRagdoll", function(client, ragdoll)
      ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerswitchclass">
<summary><a id="OnPlayerSwitchClass"></a>OnPlayerSwitchClass(client, class, oldClass)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerswitchclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a player switched to a different class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the class transition is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player switching class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|number</a></span> <span class="parameter">class</span> New class identifier or data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|number</a></span> <span class="parameter">oldClass</span> Previous class identifier or data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerSwitchClass", "RefreshLoadout", function(client, class, oldClass)
      lia.loadout.give(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onrequestitemtransfer">
<summary><a id="OnRequestItemTransfer"></a>OnRequestItemTransfer(inventoryPanel, itemID, targetInventoryID, x, y)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onrequestitemtransfer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to override item transfer requests before processing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an inventory panel asks to move an item to another inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">inventoryPanel</span> UI panel requesting transfer.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">itemID</span> Item instance ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">targetInventoryID</span> Destination inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> X slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> Y slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnRequestItemTransfer", "BlockDuringTrade", function(_, _, targetInv)
      if lia.trade.isActive(targetInv) then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onsalaryadjust">
<summary><a id="OnSalaryAdjust"></a>OnSalaryAdjust(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onsalaryadjust"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows adjusting salary amount just before payment.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During salary payout calculation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving pay.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Modified salary value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnSalaryAdjust", "TaxSalary", function(client)
      return client:isTaxed() and -50 or 0
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onsalarygiven">
<summary><a id="OnSalaryGiven"></a>OnSalaryGiven(client, char, pay, faction, class)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onsalarygiven"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when salary is granted to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After salary is deposited into the character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving salary.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">char</span> Character object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">pay</span> Amount paid.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">class</span> Class data (if any).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnSalaryGiven", "LogSalary", function(client, char, pay)
      lia.log.add(client, "salaryGiven", pay)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onsetusergroup">
<summary><a id="OnSetUsergroup"></a>OnSetUsergroup(sid, new, source, ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onsetusergroup"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player's usergroup is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a player's usergroup has been successfully changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">sid</span> Steam ID of the player whose usergroup changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">new</span> New usergroup name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">source</span> Source of the change (e.g., "Lilia").</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player entity whose usergroup changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnSetUsergroup", "LogUsergroupChange", function(sid, new, source, ply)
      print(string.format("Usergroup changed for %s to %s by %s", sid, new, source))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onsaveditemloaded">
<summary><a id="OnSavedItemLoaded"></a>OnSavedItemLoaded(loadedItems)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onsaveditemloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that saved item instances have been loaded from storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After loading saved items on startup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">loadedItems</span> Table of item instances.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnSavedItemLoaded", "IndexCustomData", function(loadedItems)
      lia.items.buildCache(loadedItems)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onserverlog">
<summary><a id="OnServerLog"></a>OnServerLog(client, logType, logString, category)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onserverlog"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Central logging hook for server log entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever lia.log.add writes to the server log.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player associated with the log (may be nil).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">logType</span> Log type identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">logString</span> Formatted log message.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">category</span> Log category.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnServerLog", "ForwardToDiscord", function(client, logType, text, category)
      lia.discord.send(category, logType, text)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketclaimed">
<summary><a id="OnTicketClaimed"></a>OnTicketClaimed(client, requester, ticketMessage)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketclaimed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a staff member claims a support ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After claim assignment succeeds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Staff claiming the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">requester</span> SteamID of the requester.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> Ticket text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketClaimed", "AnnounceClaim", function(client, requester)
      client:notifyLocalized("ticketClaimed", requester)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketclosed">
<summary><a id="OnTicketClosed"></a>OnTicketClosed(client, requester, ticketMessage)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a support ticket is closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the ticket is marked closed and responders notified.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Staff closing the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">requester</span> SteamID of the requester.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> Original ticket text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketClosed", "LogTicketClose", function(client, requester)
      lia.log.add(client, "ticketClosed", requester)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketcreated">
<summary><a id="OnTicketCreated"></a>OnTicketCreated(noob, message)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a support ticket is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after a player submits a ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">noob</span> Player submitting the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Ticket text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketCreated", "NotifyStaff", function(noob, message)
      lia.staff.notifyAll(noob:Nick() .. ": " .. message)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onusergrouppermissionschanged">
<summary><a id="OnUsergroupPermissionsChanged"></a>OnUsergroupPermissionsChanged(groupName, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onusergrouppermissionschanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that usergroup permissions have changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a usergroup permission update occurs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">groupName</span> Usergroup name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg2</span> New permission data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnUsergroupPermissionsChanged", "RefreshCachedPerms", function(groupName)
      lia.permissions.refresh(groupName)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onvendoredited">
<summary><a id="OnVendorEdited"></a>OnVendorEdited(client, vendor, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onvendoredited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor entity is edited via the vendor interface.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After vendor key/value is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player editing.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Property key edited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnVendorEdited", "SyncVendorEdits", function(client, vendor, key)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onvoicetypechanged">
<summary><a id="OnVoiceTypeChanged"></a>OnVoiceTypeChanged(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onvoicetypechanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a player's voice chat style has changed (whisper/talk/yell).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a player updates their voice type.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose voice type changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnVoiceTypeChanged", "UpdateVoiceRadius", function(client)
      lia.voice.updateHearTables()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-optionreceived">
<summary><a id="OptionReceived"></a>OptionReceived(arg1, key, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="optionreceived"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a networked option value is received or changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When lia.option.set broadcasts an option that should network.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> <span class="optional">optional</span> Player who triggered the change (nil when server initiated).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Option key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OptionReceived", "ApplyOption", function(_, key, value)
      if key == "TalkRange" then lia.config.set("TalkRange", value) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playeraccessvendor">
<summary><a id="PlayerAccessVendor"></a>PlayerAccessVendor(client, vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playeraccessvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks if a player is permitted to access vendor management.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player attempts to open vendor edit controls.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting access.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block, true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerAccessVendor", "AdminOnlyVendorEdit", function(client)
      if not client:IsAdmin() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playercheatdetected">
<summary><a id="PlayerCheatDetected"></a>PlayerCheatDetected(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playercheatdetected"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered when cheat detection flags a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the cheat system confirms suspicious behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player detected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerCheatDetected", "AutoBan", function(client)
      lia.bans.add(client:SteamID(), "Cheat detected", 0)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playergagged">
<summary><a id="PlayerGagged"></a>PlayerGagged(target, admin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playergagged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player is gagged (voice chat disabled).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After gag state toggles to true.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player gagged.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">admin</span> Admin who issued the gag.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerGagged", "LogGag", function(target, admin)
      lia.log.add(admin, "playerGagged", target:Name())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerliliadataloaded">
<summary><a id="PlayerLiliaDataLoaded"></a>PlayerLiliaDataLoaded(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerliliadataloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that Lilia player data has finished loading for a client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After lia data, items, doors, and panels are synced to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose data is loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerLiliaDataLoaded", "SendWelcome", function(client)
      client:notifyLocalized("welcomeBack")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerloadedchar">
<summary><a id="PlayerLoadedChar"></a>PlayerLoadedChar(client, character, currentChar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerloadedchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired after a player's character has been fully loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once character variables are applied and the player is spawned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose character loaded.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Active character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">currentChar</span> Character ID index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerLoadedChar", "ApplyLoadout", function(client, character)
      lia.loadout.give(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playermessagesend">
<summary><a id="PlayerMessageSend"></a>PlayerMessageSend(speaker, chatType, text, anonymous, receivers)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playermessagesend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modifying chat text before it is sent to listeners.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During chat send for all chat types.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">speaker</span> Player speaking.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Chat class identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> Raw message text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">anonymous</span> Whether the message is anonymous.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">receivers</span> List of recipients (optional).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Replacement message text, or nil to keep.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerMessageSend", "CensorCurseWords", function(_, _, text)
      return text:gsub("badword", "****")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playermodelchanged">
<summary><a id="PlayerModelChanged"></a>PlayerModelChanged(client, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playermodelchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Triggered when a player's model changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a new model is set on the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose model changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">value</span> New model path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerModelChanged", "ReapplyBodygroups", function(client)
      lia.models.applyBodygroups(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playermuted">
<summary><a id="PlayerMuted"></a>PlayerMuted(target, admin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playermuted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a player is muted (text chat disabled).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After muting is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player muted.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">admin</span> Admin who muted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerMuted", "LogMute", function(target, admin)
      lia.log.add(admin, "playerMuted", target:Name())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playershouldpermakill">
<summary><a id="PlayerShouldPermaKill"></a>PlayerShouldPermaKill(client, inflictor, attacker)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playershouldpermakill"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines if a death should result in a permanent character kill.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During PlayerDeath when checking perma-kill conditions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who died.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">inflictor</span> Entity inflicting damage.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">attacker</span> Attacker entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True to perma-kill, false/nil to avoid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerShouldPermaKill", "HardcoreMode", function(client)
      return lia.config.get("HardcoreMode", false)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerspawnpointselected">
<summary><a id="PlayerSpawnPointSelected"></a>PlayerSpawnPointSelected(client, pos, ang)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerspawnpointselected"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the spawn point chosen for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When selecting a specific spawn point entity/position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player spawning.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> Proposed position.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle</a></span> <span class="parameter">ang</span> Proposed angle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>vector, angle Replacement spawn location or nil to keep.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerSpawnPointSelected", "SpawnInZone", function(client)
      return lia.spawns.pickSafe(), Angle(0, 0, 0)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerstaminagained">
<summary><a id="PlayerStaminaGained"></a>PlayerStaminaGained(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerstaminagained"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that stamina has been gained by a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After stamina increase is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player gaining stamina.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerStaminaGained", "RewardRecovery", function(client)
      client:notifyLocalized("staminaRestored")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerstaminalost">
<summary><a id="PlayerStaminaLost"></a>PlayerStaminaLost(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerstaminalost"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that stamina has been reduced for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After stamina drain is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player losing stamina.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerStaminaLost", "WarnLowStamina", function(client)
      if client:getLocalVar("stm", 100) &lt; 10 then client:notifyLocalized("lowStamina") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerungagged">
<summary><a id="PlayerUngagged"></a>PlayerUngagged(target, admin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerungagged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a gag on a player is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After gag state switches to false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player ungagged.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">admin</span> Admin lifting the gag.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerUngagged", "LogUngag", function(target, admin)
      lia.log.add(admin, "playerUngagged", target:Name())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerunmuted">
<summary><a id="PlayerUnmuted"></a>PlayerUnmuted(target, admin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerunmuted"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a mute on a player is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After muting state switches to false.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player unmuted.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">admin</span> Admin lifting the mute.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerUnmuted", "LogUnmute", function(target, admin)
      lia.log.add(admin, "playerUnmuted", target:Name())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerusedoor">
<summary><a id="PlayerUseDoor"></a>PlayerUseDoor(client, door)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerusedoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Final permission check before a player uses a door entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a use input is received on a door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player using the door.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block use; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerUseDoor", "RaidLockdown", function(client)
      if lia.state.isRaid() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postdoordataload">
<summary><a id="PostDoorDataLoad"></a>PostDoorDataLoad(ent, doorData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postdoordataload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after door data has been loaded from persistence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After door ownership/vars are applied on map load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> Data restored for the door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostDoorDataLoad", "ApplyDoorSkin", function(ent, data)
      if data.skin then ent:SetSkin(data.skin) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postloaddata">
<summary><a id="PostLoadData"></a>PostLoadData()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postloaddata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after all gamemode data loading is complete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the end of server initialization once stored data is in memory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostLoadData", "WarmCache", function()
      lia.cache.preload()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postplayerinitialspawn">
<summary><a id="PostPlayerInitialSpawn"></a>PostPlayerInitialSpawn(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postplayerinitialspawn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the player's initial spawn setup finishes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after PlayerInitialSpawn processing completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Newly spawned player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostPlayerInitialSpawn", "SendMOTD", function(client)
      lia.motd.send(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postplayerloadedchar">
<summary><a id="PostPlayerLoadedChar"></a>PostPlayerLoadedChar(client, character, currentChar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postplayerloadedchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after a player's character and inventories have been loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after PlayerLoadedChar finishes syncing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Loaded character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">currentChar</span> Character index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostPlayerLoadedChar", "GiveStarterItems", function(client, character)
      lia.items.giveStarter(character)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postplayerloadout">
<summary><a id="PostPlayerLoadout"></a>PostPlayerLoadout(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postplayerloadout"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired after PlayerLoadout has finished giving items and weapons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the default loadout logic completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who spawned.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostPlayerLoadout", "AddExtraGear", function(client)
      client:Give("weapon_crowbar")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postplayersay">
<summary><a id="PostPlayerSay"></a>PostPlayerSay(client, message, chatType, anonymous)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postplayersay"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to modify chat behavior after PlayerSay builds recipients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After chat data is prepared but before sending to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Speaker.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Message text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Chat class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">anonymous</span> Whether the message is anonymous.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string, boolean Optionally return modified text and anonymity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostPlayerSay", "AddOOCPrefix", function(client, message, chatType, anonymous)
      if chatType == "ooc" then return "[OOC] " .. message, anonymous end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postscaledamage">
<summary><a id="PostScaleDamage"></a>PostScaleDamage(hitgroup, dmgInfo, damageScale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postscaledamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired after damage scaling is applied to a hitgroup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the end of ScalePlayerDamage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> Hitgroup hit.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> Damage info object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> Scale that was applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostScaleDamage", "TrackDamage", function(hitgroup, dmgInfo, scale)
      lia.metrics.bump("damage", dmgInfo:GetDamage() * scale)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-prechardelete">
<summary><a id="PreCharDelete"></a>PreCharDelete(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="prechardelete"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Pre-deletion hook for characters to run cleanup logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Just before a character is removed from the database.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Character ID to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreCharDelete", "ArchiveChar", function(id)
      lia.backup.character(id)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-predoordatasave">
<summary><a id="PreDoorDataSave"></a>PreDoorDataSave(door, doorData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="predoordatasave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows adding extra data before door data is saved to persistence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During door save routines.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> Data about to be saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreDoorDataSave", "SaveDoorSkin", function(door, data)
      data.skin = door:GetSkin()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-preplayerinteractitem">
<summary><a id="PrePlayerInteractItem"></a>PrePlayerInteractItem(client, action, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="preplayerinteractitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets modules validate an item interaction before it runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prior to executing an item action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the action.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">action</span> Action identifier.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item being interacted with.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PrePlayerInteractItem", "BlockWhileBusy", function(client)
      if client:isBusy() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-preplayerloadedchar">
<summary><a id="PrePlayerLoadedChar"></a>PrePlayerLoadedChar(client, character, currentChar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="preplayerloadedchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs before character data is fully loaded into a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prior to PlayerLoadedChar logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player about to load a character.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">currentChar</span> Character index.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PrePlayerLoadedChar", "ResetRagdoll", function(client)
      client:removeRagdoll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-presalarygive">
<summary><a id="PreSalaryGive"></a>PreSalaryGive(client, char, pay, faction, class)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="presalarygive"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modification of salary payout before it is given.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During salary calculation loop, before pay is issued.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player due for salary.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">char</span> Character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">pay</span> Current calculated pay.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">faction</span> Faction data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">class</span> Class data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Adjusted pay or nil to keep.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreSalaryGive", "ApplyTax", function(client, char, pay)
      return pay * 0.9
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-prescaledamage">
<summary><a id="PreScaleDamage"></a>PreScaleDamage(hitgroup, dmgInfo, damageScale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="prescaledamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called before damage scaling is calculated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the start of ScalePlayerDamage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">hitgroup</span> Hitgroup hit.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/CTakeDamageInfo">CTakeDamageInfo</a></span> <span class="parameter">dmgInfo</span> Damage info object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">damageScale</span> Starting scale value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreScaleDamage", "ArmorPiercing", function(hitgroup, dmgInfo, scale)
      if dmgInfo:IsExplosionDamage() then dmgInfo:ScaleDamage(scale * 1.2) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-removewarning">
<summary><a id="RemoveWarning"></a>RemoveWarning(charID, index)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="removewarning"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Removes a warning entry for a character and informs listeners.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an admin deletes a warning record.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">charID</span> Character database ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">index</span> Position of the warning in the list to remove.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|table</a></span> Deferred resolving to removed warning row or nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RemoveWarning", "MirrorWarningRemoval", function(charID, index)
      print("Warning removed", charID, index)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-savedata">
<summary><a id="SaveData"></a>SaveData()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="savedata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Performs a full save of gamemode persistence (entities, data, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When persistence save is triggered manually or automatically.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SaveData", "ExtraSave", function()
      lia.custom.saveAll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-sendpopup">
<summary><a id="SendPopup"></a>SendPopup(noob, message)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="sendpopup"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a popup notification to a player with custom text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever the server wants to send a popup dialog.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">noob</span> Player receiving the popup.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Text to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SendPopup", "PopupExample", function(client, message)
      client:notifyLocalized(message)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupbotplayer">
<summary><a id="SetupBotPlayer"></a>SetupBotPlayer(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupbotplayer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Builds and spawns a bot player with default character data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the server requests creation of a bot player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Bot player entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupBotPlayer", "BotWelcome", function(client)
      print("Bot setup complete", client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupdatabase">
<summary><a id="SetupDatabase"></a>SetupDatabase()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupdatabase"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sets up database tables, indexes, and initial schema.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During gamemode initialization after database connection is established.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupDatabase", "InitCustomTables", function()
      lia.db.query("CREATE TABLE IF NOT EXISTS custom(id INT)")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupplayermodel">
<summary><a id="SetupPlayerModel"></a>SetupPlayerModel(modelEntity, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupplayermodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Configure a player model entity after it has been created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When spawning a playable model entity for preview or vendors.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">modelEntity</span> The spawned model entity.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character data used for appearance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupPlayerModel", "ApplyCharSkin", function(modelEntity, character)
      modelEntity:SetSkin(character:getSkin() or 0)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shoulddatabesaved">
<summary><a id="ShouldDataBeSaved"></a>ShouldDataBeSaved()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddatabesaved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines if persistence data should be saved at this time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before performing a save cycle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to skip saving; true/nil to proceed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDataBeSaved", "OnlyDuringGrace", function()
      return not lia.state.isCombatPhase()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shouldoverridesalarytimers">
<summary><a id="ShouldOverrideSalaryTimers"></a>ShouldOverrideSalaryTimers()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldoverridesalarytimers"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines if the default salary timer creation should be overridden.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before creating salary timers to allow custom salary systems.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True to prevent default salary timer creation; false/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldOverrideSalaryTimers", "CustomSalarySystem", function()
      return true -- Prevent default timers, handle salary elsewhere
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shoulddeletesaveditems">
<summary><a id="ShouldDeleteSavedItems"></a>ShouldDeleteSavedItems()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddeletesaveditems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decides whether saved item data should be deleted on map cleanup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before removing saved items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to keep saved items; true/nil to delete.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDeleteSavedItems", "KeepForTesting", function()
      return false
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shouldplaydeathsound">
<summary><a id="ShouldPlayDeathSound"></a>ShouldPlayDeathSound(client, deathSound)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldplaydeathsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a death sound should play for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before emitting the death sound.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who died.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">deathSound</span> Sound that would be played.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to suppress; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldPlayDeathSound", "MuteStaff", function(client)
      if client:Team() == FACTION_STAFF then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shouldplaypainsound">
<summary><a id="ShouldPlayPainSound"></a>ShouldPlayPainSound(entity, painSound)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldplaypainsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a pain sound should play for an entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When choosing whether to emit pain audio.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Entity that would play the sound.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">painSound</span> Sound path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to suppress; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldPlayPainSound", "MuteRobots", function(entity)
      if entity:IsPlayer() and entity:IsCombine() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-shouldspawnclientragdoll">
<summary><a id="ShouldSpawnClientRagdoll"></a>ShouldSpawnClientRagdoll(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldspawnclientragdoll"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Controls whether a client ragdoll should be spawned on death.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During PlayerDeath ragdoll handling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who died.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent ragdoll; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldSpawnClientRagdoll", "NoRagdollInVehicles", function(client)
      return not client:InVehicle()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storagecantransferitem">
<summary><a id="StorageCanTransferItem"></a>StorageCanTransferItem(client, storage, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storagecantransferitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validates whether an item can be transferred to/from storage inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an item move involving storage is requested.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the move.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|table</a></span> <span class="parameter">storage</span> Storage entity or inventory table.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item being moved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageCanTransferItem", "LimitWeapons", function(client, storage, item)
      if item.isWeapon then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storageentityremoved">
<summary><a id="StorageEntityRemoved"></a>StorageEntityRemoved(storageEntity, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageentityremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a storage entity is removed from the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On removal/deletion of the storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">storageEntity</span> Storage entity removed.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory associated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageEntityRemoved", "SaveStorage", function(storageEntity, inventory)
      lia.storage.saveInventory(inventory)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storageinventoryset">
<summary><a id="StorageInventorySet"></a>StorageInventorySet(entity, inventory, isCar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageinventoryset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a storage inventory is assigned to an entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After inventory is set on a storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Entity receiving the inventory.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory assigned.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isCar</span> True if the storage is a vehicle trunk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageInventorySet", "TrackStorage", function(ent, inv)
      lia.log.add(nil, "storageSet", inv:getID())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storageitemremoved">
<summary><a id="StorageItemRemoved"></a>StorageItemRemoved()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageitemremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that an item was removed from a storage inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After removal occurs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageItemRemoved", "RecountStorage", function()
      lia.storage.updateCapacity()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storagerestored">
<summary><a id="StorageRestored"></a>StorageRestored(ent, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storagerestored"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a storage inventory is restored from disk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During storage load routines.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Storage entity.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory object restored.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageRestored", "SyncRestoredStorage", function(ent, inventory)
      inventory:sync(ent)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storespawns">
<summary><a id="StoreSpawns"></a>StoreSpawns(spawns)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storespawns"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Persists the current spawn positions to storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When spawns are being saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">spawns</span> Spawn data to store.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StoreSpawns", "CustomSpawnStore", function(spawns)
      file.Write("lilia/spawns.json", util.TableToJSON(spawns))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-synccharlist">
<summary><a id="SyncCharList"></a>SyncCharList(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="synccharlist"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Syncs the character list data to a specific client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player requests an updated character list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving the list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SyncCharList", "AddExtraFields", function(client)
      lia.char.sync(client)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclaim">
<summary><a id="TicketSystemClaim"></a>TicketSystemClaim(client, requester, ticketMessage)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ticketsystemclaim"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows custom validation when a player attempts to claim a support ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a claim request is made for a ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player claiming the ticket.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player|string</a></span> <span class="parameter">requester</span> Ticket requester or their SteamID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> Ticket description.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TicketSystemClaim", "AllowStaffOnlyClaims", function(client)
      if not client:isStaffOnDuty() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclose">
<summary><a id="TicketSystemClose"></a>TicketSystemClose(client, requester, ticketMessage)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ticketsystemclose"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows custom validation when a player attempts to close a support ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a close request is made for a ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player closing the ticket.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player|string</a></span> <span class="parameter">requester</span> Ticket requester or SteamID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> Ticket description.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to block; true/nil to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TicketSystemClose", "OnlyOwnerOrStaff", function(client, requester)
      if client ~= requester and not client:isStaffOnDuty() then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-togglelock">
<summary><a id="ToggleLock"></a>ToggleLock(client, door, state)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="togglelock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signals that a door lock state was toggled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a lock/unlock action completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player toggling.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">state</span> True if locked after toggle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ToggleLock", "LogToggleLock", function(client, door, state)
      lia.log.add(client, "toggleLock", tostring(state))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-updateentitypersistence">
<summary><a id="UpdateEntityPersistence"></a>UpdateEntityPersistence(vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="updateentitypersistence"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Writes updated persistence data for an entity (commonly vendors).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After data changes that must be persisted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Entity whose persistence should be updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("UpdateEntityPersistence", "SaveVendorChanges", function(vendor)
      lia.entity.save(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendorclassupdated">
<summary><a id="VendorClassUpdated"></a>VendorClassUpdated(vendor, id, allowed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorclassupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor's class allow list changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After toggling a class for vendor access.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">id</span> Class identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">allowed</span> Whether the class is allowed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorClassUpdated", "SyncVendorClassUpdate", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendoredited">
<summary><a id="VendorEdited"></a>VendorEdited(liaVendorEnt, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoredited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>General notification that a vendor property was edited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever vendor data is modified through the editor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">liaVendorEnt</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Property key changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorEdited", "ResyncOnEdit", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendorfactionbuyscaleupdated">
<summary><a id="VendorFactionBuyScaleUpdated"></a>VendorFactionBuyScaleUpdated(vendor, factionID, scale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionbuyscaleupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a vendor's faction-specific buy multiplier was updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After setting faction buy scale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">factionID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">scale</span> New buy scale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorFactionBuyScaleUpdated", "SyncFactionBuyScale", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendorfactionsellscaleupdated">
<summary><a id="VendorFactionSellScaleUpdated"></a>VendorFactionSellScaleUpdated(vendor, factionID, scale)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionsellscaleupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that a vendor's faction-specific sell multiplier was updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After setting faction sell scale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">factionID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">scale</span> New sell scale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorFactionSellScaleUpdated", "SyncFactionSellScale", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendorfactionupdated">
<summary><a id="VendorFactionUpdated"></a>VendorFactionUpdated(vendor, id, allowed)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor's faction allow/deny list is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After toggling faction access.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">id</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">allowed</span> Whether the faction is allowed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorFactionUpdated", "SyncFactionAccess", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendoritemmaxstockupdated">
<summary><a id="VendorItemMaxStockUpdated"></a>VendorItemMaxStockUpdated(vendor, itemType, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemmaxstockupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when the maximum stock for a vendor item is updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After editing item stock limits.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> New max stock.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorItemMaxStockUpdated", "SyncMaxStockChange", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendoritemmodeupdated">
<summary><a id="VendorItemModeUpdated"></a>VendorItemModeUpdated(vendor, itemType, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemmodeupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor item's trade mode changes (buy/sell/both).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After updating item mode.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> Mode constant.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorItemModeUpdated", "SyncItemModeChange", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendoritempriceupdated">
<summary><a id="VendorItemPriceUpdated"></a>VendorItemPriceUpdated(vendor, itemType, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritempriceupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor item's price is changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After setting a new price for an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> New price.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorItemPriceUpdated", "SyncPriceChange", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendoritemstockupdated">
<summary><a id="VendorItemStockUpdated"></a>VendorItemStockUpdated(vendor, itemType, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemstockupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a vendor item's current stock value changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After stock is set manually.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> New stock.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorItemStockUpdated", "SyncStockChange", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendormessagesupdated">
<summary><a id="VendorMessagesUpdated"></a>VendorMessagesUpdated(vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendormessagesupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when vendor dialogue/messages are updated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After editing vendor message strings.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorMessagesUpdated", "SyncVendorMsgs", function(vendor)
      lia.vendor.sync(vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendorsynchronized">
<summary><a id="VendorSynchronized"></a>VendorSynchronized(vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorsynchronized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notifies that vendor data has been synchronized to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After vendor network sync completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorSynchronized", "AfterVendorSync", function(vendor)
      print("Vendor synced", vendor)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendortradeevent">
<summary><a id="VendorTradeEvent"></a>VendorTradeEvent(client, vendor, itemType, isSellingToVendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendortradeevent"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Generic hook for vendor trade events (buying or selling).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a vendor transaction completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player trading.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> Item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> True if player sold to vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorTradeEvent", "TrackTrade", function(client, vendor, itemType, selling)
      lia.log.add(client, selling and "vendorSell" or "vendorBuy", itemType)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-warningissued">
<summary><a id="WarningIssued"></a>WarningIssued(client, target, reason, severity, count, warnerSteamID, targetSteamID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="warningissued"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a warning is issued to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after creating a warning record.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Admin issuing the warning.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player receiving the warning.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">reason</span> Warning reason.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">severity</span> Severity level.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">count</span> Total warnings after issuance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">warnerSteamID</span> Issuer SteamID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">targetSteamID</span> Target SteamID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WarningIssued", "RelayToDiscord", function(client, target, reason, severity)
      lia.discord.send("warnings", client:Name(), reason .. " (" .. severity .. ")")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-warningremoved">
<summary><a id="WarningRemoved"></a>WarningRemoved(client, targetClient, arg3, arg4, arg5, arg6)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="warningremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fired when a warning is removed from a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the warning record is deleted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Admin removing the warning.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">targetClient</span> Player whose warning was removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg3</span> Warning data table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg4</span> Additional context.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg5</span> Additional context.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg6</span> Additional context.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WarningRemoved", "NotifyRemoval", function(client, targetClient, data)
      targetClient:notifyLocalized("warningRemovedNotify", client:Name())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-overridevoicehearingstatus">
<summary><a id="OverrideVoiceHearingStatus"></a>OverrideVoiceHearingStatus(listener, speaker, baseCanHear)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridevoicehearingstatus"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding whether a listener can hear a speaker's voice, overriding the default distance-based calculation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During voice hearing calculations, after the base distance check is performed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">listener</span> Player who would be listening to the voice.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">speaker</span> Player who is speaking.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">baseCanHear</span> The default hearing status based on distance and voice type (whisper/talk/yell ranges).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return true to force the listener to hear the speaker, false to block hearing, or nil to use the default baseCanHear value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OverrideVoiceHearingStatus", "BlockDTVoice", function(listener, speaker, baseCanHear)
      if speaker:getNetVar("dtScramblerEnabled", false) and listener:Team() ~= FACTION_DT then
          return false
      end
  end)
</code></pre>
</div>

</div>
</details>

---

