# Player Meta

Player management system for the Lilia framework.

---

Overview

The player meta table provides comprehensive functionality for managing player data, interactions, and operations in the Lilia framework. It handles player character access, notification systems, permission checking, data management, interaction systems, and player-specific operations. The meta table operates on both server and client sides, with the server managing player data and validation while the client provides player interaction and display. It includes integration with the character system for character access, notification system for player messages, permission system for access control, data system for player persistence, and interaction system for player actions. The meta table ensures proper player data synchronization, permission validation, notification delivery, and comprehensive player management from connection to disconnection.

---

<details class="realm-shared">
<summary><a id=getChar></a>getChar()</summary>
<a id="getchar"></a>
<p>Returns the active character object associated with this player.</p>
<p>Use whenever you need the player's character state.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Character instance or nil if none is selected.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local char = ply:getChar()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=tostring></a>tostring()</summary>
<a id="tostring"></a>
<p>Builds a readable name for the player preferring character name.</p>
<p>Use for logging or UI when displaying player identity.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Character name if available, otherwise Steam name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    print(ply:tostring())
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=Name></a>Name()</summary>
<a id="name"></a>
<p>Returns the display name, falling back to Steam name if no character.</p>
<p>Use wherever Garry's Mod expects Name/Nick/GetName.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Character or Steam name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local name = ply:Name()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=doGesture></a>doGesture(a, b, c)</summary>
<a id="dogesture"></a>
<p>Restarts a gesture animation and replicates it.</p>
<p>Use to play a gesture on the player and sync to others.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">a</span> Gesture activity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">b</span> Layer or slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">c</span> Playback rate or weight.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:doGesture(ACT_GMOD_GESTURE_WAVE, 0, 1)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=setAction></a>setAction(text, time, callback)</summary>
<a id="setaction"></a>
<p>Shows an action bar for the player and runs a callback when done.</p>
<p>Use to gate actions behind a timed progress bar.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> <span class="optional">optional</span> Message to display; nil cancels the bar.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Duration in seconds.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked when the timer completes.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setAction("Lockpicking", 5, onFinish)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=doStaredAction></a>doStaredAction(entity, callback, time, onCancel, distance)</summary>
<a id="dostaredaction"></a>
<p>Runs a callback after the player stares at an entity for a duration.</p>
<p>Use for interactions requiring sustained aim on a target.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Target entity to watch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Function called after staring completes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Duration in seconds required.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">onCancel</span> <span class="optional">optional</span> Called if the stare is interrupted.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">distance</span> <span class="optional">optional</span> Max distance trace length.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:doStaredAction(door, onComplete, 3)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=stopAction></a>stopAction()</summary>
<a id="stopaction"></a>
<p>Cancels any active action or stare timers and hides the bar.</p>
<p>Use when an action is interrupted or completed early.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:stopAction()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasPrivilege></a>hasPrivilege(privilegeName)</summary>
<a id="hasprivilege"></a>
<p>Checks if the player has a specific admin privilege.</p>
<p>Use before allowing privileged actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">privilegeName</span> Permission to query.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the player has access.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:hasPrivilege("canBan") then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=removeRagdoll></a>removeRagdoll()</summary>
<a id="removeragdoll"></a>
<p>Deletes the player's ragdoll entity and clears the net var.</p>
<p>Use when respawning or cleaning up ragdolls.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:removeRagdoll()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItemWeapon></a>getItemWeapon()</summary>
<a id="getitemweapon"></a>
<p>Returns the active weapon and matching inventory item if equipped.</p>
<p>Use when syncing weapon state with inventory data.</p>
<p><h3>Returns:</h3>
Weapon|nil, Item|nil Active weapon entity and corresponding item, if found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local wep, itm = ply:getItemWeapon()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isFamilySharedAccount></a>isFamilySharedAccount()</summary>
<a id="isfamilysharedaccount"></a>
<p>Detects whether the account is being used via Steam Family Sharing.</p>
<p>Use for restrictions or messaging on shared accounts.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if OwnerSteamID64 differs from SteamID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:isFamilySharedAccount() then warn() end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItemDropPos></a>getItemDropPos()</summary>
<a id="getitemdroppos"></a>
<p>Calculates a suitable position in front of the player to drop items.</p>
<p>Use before spawning a world item.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> Drop position.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local pos = ply:getItemDropPos()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getItems></a>getItems()</summary>
<a id="getitems"></a>
<p>Retrieves the player's inventory items if a character exists.</p>
<p>Use when accessing a player's item list directly.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Items table or nil if no inventory.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local items = ply:getItems()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getTracedEntity></a>getTracedEntity(distance)</summary>
<a id="gettracedentity"></a>
<p>Returns the entity the player is aiming at within a distance.</p>
<p>Use for interaction traces.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">distance</span> Max trace length; default 96.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|nil</a></span> Hit entity or nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ent = ply:getTracedEntity(128)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notify></a>notify(message, notifType)</summary>
<a id="notify"></a>
<p>Sends a notification to this player (or locally on client).</p>
<p>Use to display a generic notice.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to show.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">notifType</span> Optional type key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notify("Hello")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyLocalized></a>notifyLocalized(message, notifType)</summary>
<a id="notifylocalized"></a>
<p>Sends a localized notification to this player or locally.</p>
<p>Use when the message is a localization token.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Localization key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">notifType</span> Optional type key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyLocalized("itemTaken", "apple")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyError></a>notifyError(message)</summary>
<a id="notifyerror"></a>
<p>Sends an error notification to this player or locally.</p>
<p>Use to display error messages in a consistent style.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Error text.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyError("Invalid action")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyWarning></a>notifyWarning(message)</summary>
<a id="notifywarning"></a>
<p>Sends a warning notification to this player or locally.</p>
<p>Use for cautionary messages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyWarning("Low health")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyInfo></a>notifyInfo(message)</summary>
<a id="notifyinfo"></a>
<p>Sends an info notification to this player or locally.</p>
<p>Use for neutral informational messages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyInfo("Quest updated")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifySuccess></a>notifySuccess(message)</summary>
<a id="notifysuccess"></a>
<p>Sends a success notification to this player or locally.</p>
<p>Use to indicate successful actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifySuccess("Saved")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyMoney></a>notifyMoney(message)</summary>
<a id="notifymoney"></a>
<p>Sends a money-themed notification to this player or locally.</p>
<p>Use for currency gain/spend messages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyMoney("+$50")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyAdmin></a>notifyAdmin(message)</summary>
<a id="notifyadmin"></a>
<p>Sends an admin-level notification to this player or locally.</p>
<p>Use for staff-oriented alerts.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span> Text to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyAdmin("Ticket opened")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyErrorLocalized></a>notifyErrorLocalized(key)</summary>
<a id="notifyerrorlocalized"></a>
<p>Sends a localized error notification to the player or locally.</p>
<p>Use for localized error tokens.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyErrorLocalized("invalidArg")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyWarningLocalized></a>notifyWarningLocalized(key)</summary>
<a id="notifywarninglocalized"></a>
<p>Sends a localized warning notification to the player or locally.</p>
<p>Use for localized warnings.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyWarningLocalized("lowHealth")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyInfoLocalized></a>notifyInfoLocalized(key)</summary>
<a id="notifyinfolocalized"></a>
<p>Sends a localized info notification to the player or locally.</p>
<p>Use for localized informational messages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyInfoLocalized("questUpdate")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifySuccessLocalized></a>notifySuccessLocalized(key)</summary>
<a id="notifysuccesslocalized"></a>
<p>Sends a localized success notification to the player or locally.</p>
<p>Use for localized success confirmations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifySuccessLocalized("saved")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyMoneyLocalized></a>notifyMoneyLocalized(key)</summary>
<a id="notifymoneylocalized"></a>
<p>Sends a localized money notification to the player or locally.</p>
<p>Use for localized currency messages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyMoneyLocalized("moneyGained", 50)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=notifyAdminLocalized></a>notifyAdminLocalized(key)</summary>
<a id="notifyadminlocalized"></a>
<p>Sends a localized admin notification to the player or locally.</p>
<p>Use for staff messages with localization.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Localization key.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:notifyAdminLocalized("ticketOpened")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=canEditVendor></a>canEditVendor(vendor)</summary>
<a id="caneditvendor"></a>
<p>Checks if the player can edit a vendor.</p>
<p>Use before opening vendor edit interfaces.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">vendor</span> Vendor entity to check.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if editing is permitted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:canEditVendor(vendor) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isStaff></a>isStaff()</summary>
<a id="isstaff"></a>
<p>Determines if the player's user group is marked as Staff.</p>
<p>Use for gating staff-only features.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if their usergroup includes the Staff type.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:isStaff() then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=isStaffOnDuty></a>isStaffOnDuty()</summary>
<a id="isstaffonduty"></a>
<p>Checks if the player is currently on the staff faction.</p>
<p>Use when features apply only to on-duty staff.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the player is in FACTION_STAFF.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:isStaffOnDuty() then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasWhitelist></a>hasWhitelist(faction)</summary>
<a id="haswhitelist"></a>
<p>Checks if the player has whitelist access to a faction.</p>
<p>Use before allowing faction selection.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">faction</span> Faction ID.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if default or whitelisted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:hasWhitelist(factionID) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getClassData></a>getClassData()</summary>
<a id="getclassdata"></a>
<p>Retrieves the class table for the player's current character.</p>
<p>Use when needing class metadata like limits or permissions.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Class definition or nil if unavailable.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local classData = ply:getClassData()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getDarkRPVar></a>getDarkRPVar(var)</summary>
<a id="getdarkrpvar"></a>
<p>Provides DarkRP compatibility for money queries.</p>
<p>Use when DarkRP expects getDarkRPVar("money").</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">var</span> Variable name, only "money" supported.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Character money or nil if unsupported var.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cash = ply:getDarkRPVar("money")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getMoney></a>getMoney()</summary>
<a id="getmoney"></a>
<p>Returns the character's money or zero if unavailable.</p>
<p>Use whenever reading player currency.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Current money amount.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cash = ply:getMoney()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=canAfford></a>canAfford(amount)</summary>
<a id="canafford"></a>
<p>Returns whether the player can afford a cost.</p>
<p>Use before charging the player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Cost to check.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the player has enough money.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:canAfford(100) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasSkillLevel></a>hasSkillLevel(skill, level)</summary>
<a id="hasskilllevel"></a>
<p>Checks if the player meets a specific skill level requirement.</p>
<p>Use for gating actions behind skills.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">skill</span> Attribute key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">level</span> Required level.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the player meets or exceeds the level.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:hasSkillLevel("lockpick", 3) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=meetsRequiredSkills></a>meetsRequiredSkills(requiredSkillLevels)</summary>
<a id="meetsrequiredskills"></a>
<p>Verifies all required skills meet their target levels.</p>
<p>Use when checking multiple skill prerequisites.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">requiredSkillLevels</span> Map of skill keys to required levels.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if all requirements pass.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:meetsRequiredSkills(reqs) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=forceSequence></a>forceSequence(sequenceName, callback, time, noFreeze)</summary>
<a id="forcesequence"></a>
<p>Forces the player to play a sequence and freezes movement if needed.</p>
<p>Use for scripted animations like sit or interact sequences.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">sequenceName</span> <span class="optional">optional</span> Sequence to play; nil clears the current sequence.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called when the sequence ends.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> <span class="optional">optional</span> Override duration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noFreeze</span> Prevent movement freeze when true.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|boolean|nil</a></span> Duration when started, false on failure, or nil when clearing.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:forceSequence("sit", nil, 5)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=leaveSequence></a>leaveSequence()</summary>
<a id="leavesequence"></a>
<p>Stops the forced sequence, unfreezes movement, and runs callbacks.</p>
<p>Use when a sequence finishes or must be cancelled.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:leaveSequence()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getFlags></a>getFlags()</summary>
<a id="getflags"></a>
<p>Returns the flag string from the player's character.</p>
<p>Use when checking player permissions.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Concatenated flags or empty string.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local flags = ply:getFlags()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=giveFlags></a>giveFlags(flags)</summary>
<a id="giveflags"></a>
<p>Grants one or more flags to the player's character.</p>
<p>Use when adding privileges.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Flags to give.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:giveFlags("z")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=takeFlags></a>takeFlags(flags)</summary>
<a id="takeflags"></a>
<p>Removes flags from the player's character.</p>
<p>Use when revoking privileges.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> Flags to remove.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:takeFlags("z")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=networkAnimation></a>networkAnimation(active, boneData)</summary>
<a id="networkanimation"></a>
<p>Synchronizes or applies a bone animation state across server/client.</p>
<p>Use when enabling or disabling custom bone angles.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">active</span> Whether the animation is active.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">boneData</span> Map of bone names to Angle values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:networkAnimation(true, bones)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getAllLiliaData></a>getAllLiliaData()</summary>
<a id="getallliliadata"></a>
<p>Returns the table storing Lilia-specific player data.</p>
<p>Use when reading or writing persistent player data.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Data table per realm.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = ply:getAllLiliaData()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=setWaypoint></a>setWaypoint(name, vector, logo, onReach)</summary>
<a id="setwaypoint"></a>
<p>Sets a waypoint for the player and draws HUD guidance clientside.</p>
<p>Use when directing a player to a position or objective.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Label shown on the HUD.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">vector</span> Target world position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">logo</span> <span class="optional">optional</span> Optional material path for the icon.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">onReach</span> <span class="optional">optional</span> Callback fired when the waypoint is reached.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setWaypoint("Stash", pos)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getLiliaData></a>getLiliaData(key, default)</summary>
<a id="getliliadata"></a>
<p>Reads stored Lilia player data, returning a default when missing.</p>
<p>Use for persistent per-player data such as settings or cooldowns.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key to fetch.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Value to return when unset.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local last = ply:getLiliaData("lastIP", "")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getMainCharacter></a>getMainCharacter()</summary>
<a id="getmaincharacter"></a>
<p>Returns the player's recorded main character ID, if set.</p>
<p>Use to highlight or auto-select the main character.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|nil</a></span> Character ID or nil when unset.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local main = ply:getMainCharacter()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=setMainCharacter></a>setMainCharacter(charID)</summary>
<a id="setmaincharacter"></a>
<p>Sets the player's main character, applying cooldown rules server-side.</p>
<p>Use when a player picks or clears their main character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> <span class="optional">optional</span> Character ID to set, or nil/0 to clear.</p>

<p><h3>Returns:</h3>
boolean, string|nil True on success, or false with a reason.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setMainCharacter(charID)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=hasFlags></a>hasFlags(flags)</summary>
<a id="hasflags"></a>
<p>Checks if the player (via their character) has any of the given flags.</p>
<p>Use when gating actions behind flag permissions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">flags</span> One or more flag characters to test.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if at least one flag is present.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:hasFlags("z") then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=playTimeGreaterThan></a>playTimeGreaterThan(time)</summary>
<a id="playtimegreaterthan"></a>
<p>Returns true if the player's recorded playtime exceeds a value.</p>
<p>Use for requirements based on time played.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Threshold in seconds.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if playtime is greater than the threshold.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if ply:playTimeGreaterThan(3600) then ...
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestOptions></a>requestOptions(title, subTitle, options, limit, callback)</summary>
<a id="requestoptions"></a>
<p>Presents a list of options to the player and returns selected values.</p>
<p>Use for multi-choice prompts that may return multiple selections.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> Dialog title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">subTitle</span> Subtitle/description.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> Array of option labels.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">limit</span> Max selections allowed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Called with selections when chosen.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|nil</a></span> Promise when callback omitted, otherwise nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestOptions("Pick", "Choose one", {"A","B"}, 1, cb)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestString></a>requestString(title, subTitle, callback, default)</summary>
<a id="requeststring"></a>
<p>Prompts the player for a string value and returns it.</p>
<p>Use when collecting free-form text input.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">subTitle</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Receives the string result; optional if using deferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">default</span> <span class="optional">optional</span> Prefilled value.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|nil</a></span> Promise when callback omitted, otherwise nil.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestString("Name", "Enter name", onDone)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestArguments></a>requestArguments(title, argTypes, callback)</summary>
<a id="requestarguments"></a>
<p>Requests typed arguments from the player based on a specification.</p>
<p>Use for admin commands requiring typed input.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> Dialog title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">argTypes</span> Schema describing required arguments.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Receives parsed values; optional if using deferred.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">deferred|nil</a></span> Promise when callback omitted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestArguments("Teleport", spec, cb)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestBinaryQuestion></a>requestBinaryQuestion(question, option1, option2, manualDismiss, callback)</summary>
<a id="requestbinaryquestion"></a>
<p>Shows a binary (two-button) question to the player and returns choice.</p>
<p>Use for yes/no confirmations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">question</span> Prompt text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">option1</span> Label for first option.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">option2</span> Label for second option.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">manualDismiss</span> Require manual close; optional.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Receives 0/1 result.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestBinaryQuestion("Proceed?", "Yes", "No", false, cb)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestPopupQuestion></a>requestPopupQuestion(question, buttons)</summary>
<a id="requestpopupquestion"></a>
<p>Displays a popup question with arbitrary buttons and handles responses.</p>
<p>Use for multi-button confirmations or admin prompts.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">question</span> Prompt text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">buttons</span> Array of strings or {label, callback} pairs.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestPopupQuestion("Choose", {{"A", cbA}, {"B", cbB}})
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestButtons></a>requestButtons(title, buttons)</summary>
<a id="requestbuttons"></a>
<p>Sends a button list prompt to the player and routes callbacks.</p>
<p>Use when a simple list of actions is needed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> Dialog title.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">buttons</span> Array of {text=, callback=} entries.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestButtons("Actions", {{text="A", callback=cb}})
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=requestDropdown></a>requestDropdown(title, subTitle, options, callback)</summary>
<a id="requestdropdown"></a>
<p>Presents a dropdown selection dialog to the player.</p>
<p>Use for single-choice option selection.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">subTitle</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> Available options.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> Invoked with chosen option.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:requestDropdown("Pick class", "Choose", opts, cb)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=restoreStamina></a>restoreStamina(amount)</summary>
<a id="restorestamina"></a>
<p>Restores stamina by an amount, clamping to the character's maximum.</p>
<p>Use when giving the player stamina back (e.g., resting or items).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Stamina to add.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:restoreStamina(10)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=consumeStamina></a>consumeStamina(amount)</summary>
<a id="consumestamina"></a>
<p>Reduces stamina by an amount and handles exhaustion state.</p>
<p>Use when sprinting or performing actions that consume stamina.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Stamina to subtract.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:consumeStamina(5)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addMoney></a>addMoney(amount)</summary>
<a id="addmoney"></a>
<p>Adds money to the player's character and logs the change.</p>
<p>Use when rewarding currency server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Amount to add (can be negative via takeMoney).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> False if no character exists.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:addMoney(50)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=takeMoney></a>takeMoney(amount)</summary>
<a id="takemoney"></a>
<p>Removes money from the player's character by delegating to giveMoney.</p>
<p>Use when charging the player server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> Amount to deduct.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:takeMoney(20)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=loadLiliaData></a>loadLiliaData(callback)</summary>
<a id="loadliliadata"></a>
<p>Loads persistent Lilia player data from the database.</p>
<p>Use during player initial spawn to hydrate data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with loaded data table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:loadLiliaData()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=saveLiliaData></a>saveLiliaData()</summary>
<a id="saveliliadata"></a>
<p>Persists the player's Lilia data back to the database.</p>
<p>Use on disconnect or after updating persistent data.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:saveLiliaData()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setLiliaData></a>setLiliaData(key, value, noNetworking, noSave)</summary>
<a id="setliliadata"></a>
<p>Sets a key in the player's Lilia data, optionally syncing and saving.</p>
<p>Use when updating persistent player-specific values.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noNetworking</span> Skip net sync when true.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noSave</span> Skip immediate DB save when true.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setLiliaData("lastIP", ip)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=banPlayer></a>banPlayer(reason, duration, banner)</summary>
<a id="banplayer"></a>
<p>Records a ban entry and kicks the player with a ban message.</p>
<p>Use when banning a player via scripts.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">reason</span> Ban reason.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">duration</span> Duration in minutes; 0 or nil for perm.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">banner</span> <span class="optional">optional</span> Staff issuing the ban.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:banPlayer("RDM", 60, admin)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=getPlayTime></a>getPlayTime()</summary>
<a id="getplaytime"></a>
<p>Returns the player's total playtime in seconds (server calculation).</p>
<p>Use for server-side playtime checks.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Playtime in seconds.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local t = ply:getPlayTime()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setRagdolled></a>setRagdolled(state, baseTime, getUpGrace, getUpMessage)</summary>
<a id="setragdolled"></a>
<p>Toggles ragdoll state for the player, handling weapons, timers, and get-up.</p>
<p>Use when knocking out or reviving a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">state</span> True to ragdoll, false to restore.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">baseTime</span> <span class="optional">optional</span> Duration to stay ragdolled.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">getUpGrace</span> <span class="optional">optional</span> Additional grace time before getting up.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">getUpMessage</span> <span class="optional">optional</span> Action bar text while ragdolled.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setRagdolled(true, 10)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=syncVars></a>syncVars()</summary>
<a id="syncvars"></a>
<p>Sends all known net variables to this player.</p>
<p>Use when a player joins or needs a full resync.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:syncVars()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setNetVar></a>setNetVar(key, value)</summary>
<a id="setnetvar"></a>
<p>Sets a networked variable for this player and broadcasts it.</p>
<p>Use when updating shared player state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setNetVar("hasKey", true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=setLocalVar></a>setLocalVar(key, value)</summary>
<a id="setlocalvar"></a>
<p>Sets a server-local variable for this player and sends it only to them.</p>
<p>Use for per-player state that should not broadcast.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> Value to store.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:setLocalVar("stamina", 80)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=getLocalVar></a>getLocalVar(key, default)</summary>
<a id="getlocalvar"></a>
<p>Reads a server-local variable for this player.</p>
<p>Use when accessing non-networked state.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Fallback when unset.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local stamina = ply:getLocalVar("stamina", 100)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=getLocalVar></a>getLocalVar(key, default)</summary>
<a id="getlocalvar"></a>
<p>Reads a networked variable for this player on the client.</p>
<p>Use clientside when accessing shared netvars.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">default</span> Fallback when unset.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> Stored value or default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local val = ply:getLocalVar("stamina", 0)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=getPlayTime></a>getPlayTime()</summary>
<a id="getplaytime"></a>
<p>Returns the player's playtime (client-calculated fallback).</p>
<p>Use on the client when server data is unavailable.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Playtime in seconds.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local t = ply:getPlayTime()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=getParts></a>getParts()</summary>
<a id="getparts"></a>
<p>Returns the player's active PAC parts.</p>
<p>Use to check which PAC parts are currently equipped on the player.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Table of active PAC part IDs.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local parts = ply:getParts()
    if parts["helmet"] then
        print("Player has helmet equipped")
    end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=syncParts></a>syncParts()</summary>
<a id="syncparts"></a>
<p>Synchronizes the player's PAC parts with the client.</p>
<p>Use to ensure the client has the correct PAC parts data.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None.</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:syncParts()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=addPart></a>addPart(partID)</summary>
<a id="addpart"></a>
<p>Adds a PAC part to the player.</p>
<p>Use when equipping PAC parts on a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">partID</span> The unique ID of the PAC part to add.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None.</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:addPart("helmet_model")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=removePart></a>removePart(partID)</summary>
<a id="removepart"></a>
<p>Removes a PAC part from the player.</p>
<p>Use when unequipping PAC parts from a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">partID</span> The unique ID of the PAC part to remove.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None.</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:removePart("helmet_model")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=resetParts></a>resetParts()</summary>
<a id="resetparts"></a>
<p>Removes all PAC parts from the player.</p>
<p>Use to clear all equipped PAC parts from a player.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None.</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:resetParts()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=IsAvailable></a>IsAvailable()</summary>
<a id="isavailable"></a>
<p>Removes all PAC parts from the player.</p>
<p>Use to clear all equipped PAC parts from a player.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">None.</a></span></p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    ply:resetParts()
</code></pre>
</details>

---

