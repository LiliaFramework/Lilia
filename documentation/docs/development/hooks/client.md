# Client

This page documents the functions and methods in the meta table.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
Client-side hooks in the Lilia framework handle UI, rendering, input, and other client-specific functionality; they can be used to customize the user experience and can be overridden or extended by addons and modules.
</div>

---

<details class="realm-client" id="function-addbarfield">
<summary><a id="AddBarField"></a>AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="addbarfield"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a dynamic bar entry to show in the character information panel (e.g., stamina or custom stats).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During character info build, before the F1 menu renders the bar sections.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">sectionName</span> Localized or raw section label to group the bar under.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fieldName</span> Unique key for the bar entry.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">labelText</span> Text shown next to the bar.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">minFunc</span> Callback returning the minimum numeric value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">maxFunc</span> Callback returning the maximum numeric value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">valueFunc</span> Callback returning the current numeric value to display.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AddBarField", "ExampleAddBarField", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-addsection">
<summary><a id="AddSection"></a>AddSection(sectionName, color, priority, location)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="addsection"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Ensure a character information section exists and optionally override its styling and position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the F1 character info UI is initialized or refreshed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">sectionName</span> Localized or raw name of the section (e.g., “generalInfo”).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Accent color used for the section header.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">priority</span> Sort order; lower numbers appear first.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">location</span> Column index in the character info layout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AddSection", "ExampleAddSection", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-addtextfield">
<summary><a id="AddTextField"></a>AddTextField(sectionName, fieldName, labelText, valueFunc)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="addtextfield"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a text field for the character information panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While building character info just before the F1 menu renders.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">sectionName</span> Target section to append the field to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fieldName</span> Unique identifier for the field.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">labelText</span> Caption displayed before the value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">valueFunc</span> Callback that returns the string to render.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AddTextField", "ExampleAddTextField", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-addtoadminstickhud">
<summary><a id="AddToAdminStickHUD"></a>AddToAdminStickHUD(client, target, information)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="addtoadminstickhud"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add extra lines to the on-screen admin-stick HUD that appears while aiming with the admin stick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each HUDPaint tick when the admin stick is active and a target is valid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player using the admin stick.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">target</span> Entity currently traced by the admin stick.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">information</span> Table of strings; insert new lines to show additional info.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AddToAdminStickHUD", "ExampleAddToAdminStickHUD", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-adminprivilegesupdated">
<summary><a id="AdminPrivilegesUpdated"></a>AdminPrivilegesUpdated()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adminprivilegesupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to privilege list updates pushed from the server (used by the admin stick UI).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the server syncs admin privilege changes to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdminPrivilegesUpdated", "ExampleAdminPrivilegesUpdated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-adminstickaddmodels">
<summary><a id="AdminStickAddModels"></a>AdminStickAddModels(allModList, tgt)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adminstickaddmodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide model and icon overrides for the admin stick spawn menu list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin stick UI collects available models and props to display.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">allModList</span> Table of model entries to be displayed; append or modify entries here.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">tgt</span> Entity currently targeted by the admin stick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdminStickAddModels", "ExampleAdminStickAddModels", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-candeletechar">
<summary><a id="CanDeleteChar"></a>CanDeleteChar(client, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="candeletechar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether a client is allowed to delete a specific character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the delete character button is pressed in the character menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the deletion.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character|table</a></span> <span class="parameter">character</span> Character object slated for deletion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to block deletion; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanDeleteChar", "ExampleCanDeleteChar", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-candisplaycharinfo">
<summary><a id="CanDisplayCharInfo"></a>CanDisplayCharInfo(name)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="candisplaycharinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether the name above a character can be shown to the local player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before drawing a player’s overhead information.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The formatted name that would be displayed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide the name; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanDisplayCharInfo", "ExampleCanDisplayCharInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-canopenbagpanel">
<summary><a id="CanOpenBagPanel"></a>CanOpenBagPanel(item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canopenbagpanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allow or block opening the bag inventory panel for a specific item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a bag or storage item icon is activated to open its contents.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> The bag item whose inventory is being opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to prevent opening; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanOpenBagPanel", "ExampleCanOpenBagPanel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-canplayeropenscoreboard">
<summary><a id="CanPlayerOpenScoreboard"></a>CanPlayerOpenScoreboard(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayeropenscoreboard"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether the scoreboard should open for the requesting client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the scoreboard key is pressed and before building the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Player attempting to open the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to block; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerOpenScoreboard", "ExampleCanPlayerOpenScoreboard", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-cantakeentity">
<summary><a id="CanTakeEntity"></a>CanTakeEntity(client, targetEntity, itemUniqueID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="cantakeentity"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines if a player can take/convert an entity into an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before attempting to convert an entity into an item using the take entity keybind.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to take the entity.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">targetEntity</span> The entity being targeted for conversion.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemUniqueID</span> The unique ID of the item that would be created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> False to prevent taking the entity; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanTakeEntity", "RestrictEntityTaking", function(client, targetEntity, itemUniqueID)
      if targetEntity:IsPlayer() then return false end
      return true
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-canplayerviewinventory">
<summary><a id="CanPlayerViewInventory"></a>CanPlayerViewInventory()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerviewinventory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine if the local player can open their inventory UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before spawning any inventory window.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to stop the inventory from opening; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerViewInventory", "ExampleCanPlayerViewInventory", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charlistcolumns">
<summary><a id="CharListColumns"></a>CharListColumns(columns)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charlistcolumns"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add or adjust columns in the character list panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before the character selection table is rendered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">columns</span> Table of column definitions; modify in place to add/remove columns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharListColumns", "ExampleCharListColumns", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charlistentry">
<summary><a id="CharListEntry"></a>CharListEntry(entry, row)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charlistentry"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Modify how each character entry renders in the character list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>For every row when the character list is constructed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">entry</span> Data for the character (id, name, faction, etc.).</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">row</span> The row panel being built.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharListEntry", "ExampleCharListEntry", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charlistloaded">
<summary><a id="CharListLoaded"></a>CharListLoaded(newCharList)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charlistloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Seed character info sections and fields after the client receives the character list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once the client finishes downloading the character list from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">newCharList</span> Array of character summaries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharListLoaded", "ExampleCharListLoaded", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charlistupdated">
<summary><a id="CharListUpdated"></a>CharListUpdated(oldCharList, newCharList)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charlistupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to changes between the old and new character lists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the server sends an updated character list (e.g., after delete/create).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">oldCharList</span> Previous list snapshot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">newCharList</span> Updated list snapshot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharListUpdated", "ExampleCharListUpdated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charloaded">
<summary><a id="CharLoaded"></a>CharLoaded(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle local initialization once a character has fully loaded on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the server confirms the character load and sets netvars.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character|number</a></span> <span class="parameter">character</span> Character object or id that was loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharLoaded", "ExampleCharLoaded", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charmenuclosed">
<summary><a id="CharMenuClosed"></a>CharMenuClosed()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charmenuclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Cleanup or state changes when the character menu is closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after the character menu panel is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharMenuClosed", "ExampleCharMenuClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charmenuopened">
<summary><a id="CharMenuOpened"></a>CharMenuOpened(charMenu)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charmenuopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Perform setup each time the character menu is opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after constructing the character menu panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">charMenu</span> The created menu panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharMenuOpened", "ExampleCharMenuOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-charrestored">
<summary><a id="CharRestored"></a>CharRestored(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charrestored"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle client-side work after a character is restored from deletion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the server finishes restoring a deleted character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character|number</a></span> <span class="parameter">character</span> The restored character object or id.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharRestored", "ExampleCharRestored", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-chataddtext">
<summary><a id="ChatAddText"></a>ChatAddText(text)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="chataddtext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override how chat text is appended to the chat box.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever chat text is about to be printed locally.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">text</span> First argument passed to chat.AddText.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ChatAddText", "ExampleChatAddText", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-chatboxpanelcreated">
<summary><a id="ChatboxPanelCreated"></a>ChatboxPanelCreated(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="chatboxpanelcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust the chatbox panel right after it is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once the chat UI instance is built client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">arg1</span> The chatbox panel instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ChatboxPanelCreated", "ExampleChatboxPanelCreated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-chatboxtextadded">
<summary><a id="ChatboxTextAdded"></a>ChatboxTextAdded(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="chatboxtextadded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Intercept a newly added chat line before it renders in the chatbox.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After chat text is parsed but before it is drawn in the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">arg1</span> Chat panel or message object being added.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ChatboxTextAdded", "ExampleChatboxTextAdded", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-choosecharacter">
<summary><a id="ChooseCharacter"></a>ChooseCharacter(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="choosecharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Respond to character selection from the list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a user clicks the play button on a character slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The selected character’s id.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ChooseCharacter", "ExampleChooseCharacter", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-commandran">
<summary><a id="CommandRan"></a>CommandRan(client, command, arg3, results)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="commandran"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React after a command finishes executing client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after a console/chat command is processed on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who ran the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Command name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">arg3</span> Arguments or raw text passed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">results</span> Return data from the command handler, if any.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CommandRan", "ExampleCommandRan", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-configurecharactercreationsteps">
<summary><a id="ConfigureCharacterCreationSteps"></a>ConfigureCharacterCreationSteps(creationPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="configurecharactercreationsteps"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reorder or add steps to the character creation wizard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the creation UI is building its step list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">creationPanel</span> The root creation panel containing step definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ConfigureCharacterCreationSteps", "ExampleConfigureCharacterCreationSteps", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createcharacter">
<summary><a id="CreateCharacter"></a>CreateCharacter(data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createcharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Validate or mutate character data immediately before it is submitted to the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the user presses the final create/submit button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Character creation payload (name, model, faction, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to abort submission; nil/true to continue.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateCharacter", "ExampleCreateCharacter", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createchatboxpanel">
<summary><a id="CreateChatboxPanel"></a>CreateChatboxPanel()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createchatboxpanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the chatbox panel needs to be created or recreated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the chatbox module initializes, when the chatbox panel is closed and needs to be reopened, or when certain chat-related events occur.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateChatboxPanel", "ExampleCreateChatboxPanel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createdefaultinventory">
<summary><a id="CreateDefaultInventory"></a>CreateDefaultInventory(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createdefaultinventory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Choose what inventory implementation to instantiate for a newly created character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the client finishes character creation but before the inventory is built.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> The character being initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Inventory type id to create (e.g., “GridInv”).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateDefaultInventory", "ExampleCreateDefaultInventory", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createinformationbuttons">
<summary><a id="CreateInformationButtons"></a>CreateInformationButtons(pages)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createinformationbuttons"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate the list of buttons for the Information tab in the F1 menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the Information tab is created and ready to collect pages.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">pages</span> Table of page descriptors; insert entries with name/icon/build function.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateInformationButtons", "ExampleCreateInformationButtons", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createinventorypanel">
<summary><a id="CreateInventoryPanel"></a>CreateInventoryPanel(inventory, parent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createinventorypanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build the root panel used for displaying an inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time an inventory needs a panel representation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory object to show.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">parent</span> Parent UI element the panel should attach to.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> The created inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateInventoryPanel", "ExampleCreateInventoryPanel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-createmenubuttons">
<summary><a id="CreateMenuButtons"></a>CreateMenuButtons(tabs)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createmenubuttons"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register custom tabs for the F1 menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the F1 menu initializes its tab definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tabs</span> Table of tab constructors keyed by tab id; add new entries to inject tabs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateMenuButtons", "ExampleCreateMenuButtons", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-deletecharacter">
<summary><a id="DeleteCharacter"></a>DeleteCharacter(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="deletecharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle client-side removal of a character slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a deletion request succeeds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> ID of the character that was removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DeleteCharacter", "ExampleDeleteCharacter", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-dermaskinchanged">
<summary><a id="DermaSkinChanged"></a>DermaSkinChanged(newSkin)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="dermaskinchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when the active Derma skin changes client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the skin is switched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">newSkin</span> Name of the newly applied skin.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DermaSkinChanged", "ExampleDermaSkinChanged", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-displayplayerhudinformation">
<summary><a id="DisplayPlayerHUDInformation"></a>DisplayPlayerHUDInformation(client, hudInfos)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="displayplayerhudinformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inject custom HUD info boxes into the player HUD.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Every HUDPaint frame while the player is alive and has a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">hudInfos</span> Array to be filled with info tables (text, position, styling).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DisplayPlayerHUDInformation", "ExampleDisplayPlayerHUDInformation", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-doordatareceived">
<summary><a id="DoorDataReceived"></a>DoorDataReceived(door, syncData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doordatareceived"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle incoming door synchronization data from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the server sends door ownership or data updates.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity being updated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">syncData</span> Data payload containing door state/owners.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoorDataReceived", "ExampleDoorDataReceived", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawcharinfo">
<summary><a id="DrawCharInfo"></a>DrawCharInfo(client, character, info)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawcharinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add custom lines to the character info overlay drawn above players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right before drawing info for a player (name/description).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose info is being drawn.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character belonging to the player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">info</span> Array of `{text, color}` rows; append to extend display.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawCharInfo", "ExampleDrawCharInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawentityinfo">
<summary><a id="DrawEntityInfo"></a>DrawEntityInfo(e, a, pos)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawentityinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize how entity information panels render in the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an entity has been marked to display info and is being drawn.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">e</span> Target entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">a</span> Alpha value (0-255) for fade in/out.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|Vector</a></span> <span class="parameter">pos</span> Screen position for the info panel (optional).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawEntityInfo", "ExampleDrawEntityInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawitementityinfo">
<summary><a id="DrawItemEntityInfo"></a>DrawItemEntityInfo(itemEntity, item, infoTable, alpha)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawitementityinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust or add lines for dropped item entity info.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When hovering/aiming at a dropped item that is rendering its info.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">itemEntity</span> World entity representing the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item table attached to the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">infoTable</span> Lines describing the item; modify to add details.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">alpha</span> Current alpha used for drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawItemEntityInfo", "ExampleDrawItemEntityInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawliliamodelview">
<summary><a id="DrawLiliaModelView"></a>DrawLiliaModelView(client, entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawliliamodelview"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw extra elements in the character preview model (e.g., held weapon).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character model view panel paints.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player being previewed.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The model panel entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawLiliaModelView", "ExampleDrawLiliaModelView", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawplayerragdoll">
<summary><a id="DrawPlayerRagdoll"></a>DrawPlayerRagdoll(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawplayerragdoll"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw attachments or cosmetics on a player’s ragdoll entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During ragdoll RenderOverride when a player’s corpse is rendered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The ragdoll entity being drawn.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawPlayerRagdoll", "ExampleDrawPlayerRagdoll", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-f1menuclosed">
<summary><a id="F1MenuClosed"></a>F1MenuClosed()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="f1menuclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to the F1 menu closing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the F1 menu panel is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("F1MenuClosed", "ExampleF1MenuClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-f1menuopened">
<summary><a id="F1MenuOpened"></a>F1MenuOpened(f1MenuPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="f1menuopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Perform setup when the F1 menu opens.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the F1 menu is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">f1MenuPanel</span> The opened menu panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("F1MenuOpened", "ExampleF1MenuOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-filtercharmodels">
<summary><a id="FilterCharModels"></a>FilterCharModels(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="filtercharmodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whitelist or blacklist models shown in the character creation model list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While building the selectable model list for character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> Table of available model paths; mutate to filter.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("FilterCharModels", "ExampleFilterCharModels", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-filterdoorinfo">
<summary><a id="FilterDoorInfo"></a>FilterDoorInfo(entity, doorData, doorInfo)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="filterdoorinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust door information before it is shown on the HUD.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After door data is prepared for display but before drawing text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The door being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> Raw door data (owners, title, etc.).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorInfo</span> Table of display lines; mutate to change output.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("FilterDoorInfo", "ExampleFilterDoorInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getadjustedpartdata">
<summary><a id="GetAdjustedPartData"></a>GetAdjustedPartData(wearer, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getadjustedpartdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide PAC part data overrides before parts attach to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a PAC part is requested for attachment.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">wearer</span> Player the part will attach to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Identifier for the part/item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Adjusted part data; return nil to use cached defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAdjustedPartData", "ExampleGetAdjustedPartData", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharactercreatebuttontooltip">
<summary><a id="GetCharacterCreateButtonTooltip"></a>GetCharacterCreateButtonTooltip(client, currentChars, maxChars)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharactercreatebuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the character creation button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character creation button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">currentChars</span> Number of characters the player currently has.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxChars</span> Maximum number of characters allowed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterCreateButtonTooltip", "ExampleGetCharacterCreateButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterdisconnectbuttontooltip">
<summary><a id="GetCharacterDisconnectButtonTooltip"></a>GetCharacterDisconnectButtonTooltip(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterdisconnectbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the character disconnect button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character disconnect button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterDisconnectButtonTooltip", "ExampleGetCharacterDisconnectButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterdiscordbuttontooltip">
<summary><a id="GetCharacterDiscordButtonTooltip"></a>GetCharacterDiscordButtonTooltip(client, discordURL)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterdiscordbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the Discord button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the Discord button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">discordURL</span> The Discord server URL.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterDiscordButtonTooltip", "ExampleGetCharacterDiscordButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterloadbuttontooltip">
<summary><a id="GetCharacterLoadButtonTooltip"></a>GetCharacterLoadButtonTooltip(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterloadbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the character load button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character load button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterLoadButtonTooltip", "ExampleGetCharacterLoadButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterloadmainbuttontooltip">
<summary><a id="GetCharacterLoadMainButtonTooltip"></a>GetCharacterLoadMainButtonTooltip(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterloadmainbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the main character load button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the main character load button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterLoadMainButtonTooltip", "ExampleGetCharacterLoadMainButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharactermountbuttontooltip">
<summary><a id="GetCharacterMountButtonTooltip"></a>GetCharacterMountButtonTooltip(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharactermountbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the character mount button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character mount button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterMountButtonTooltip", "ExampleGetCharacterMountButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterreturnbuttontooltip">
<summary><a id="GetCharacterReturnButtonTooltip"></a>GetCharacterReturnButtonTooltip(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterreturnbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the character return button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character return button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterReturnButtonTooltip", "ExampleGetCharacterReturnButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterstaffbuttontooltip">
<summary><a id="GetCharacterStaffButtonTooltip"></a>GetCharacterStaffButtonTooltip(client, hasStaffChar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterstaffbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the staff character button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the staff character button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">hasStaffChar</span> Whether the player has a staff character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterStaffButtonTooltip", "ExampleGetCharacterStaffButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getcharacterworkshopbuttontooltip">
<summary><a id="GetCharacterWorkshopButtonTooltip"></a>GetCharacterWorkshopButtonTooltip(client, workshopURL)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharacterworkshopbuttontooltip"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the tooltip text for the workshop button.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the workshop button tooltip is being determined in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">workshopURL</span> The workshop URL.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharacterWorkshopButtonTooltip", "ExampleGetCharacterWorkshopButtonTooltip", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getadminesptarget">
<summary><a id="GetAdminESPTarget"></a>GetAdminESPTarget(ent, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getadminesptarget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Choose the entity that admin ESP should highlight.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin ESP overlay evaluates the current trace target.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity under the admin’s crosshair.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Admin requesting the ESP target.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|nil</a></span> Replacement target entity, or nil to use the traced entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAdminESPTarget", "ExampleGetAdminESPTarget", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getadminsticklists">
<summary><a id="GetAdminStickLists"></a>GetAdminStickLists(tgt, lists)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getadminsticklists"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Contribute additional tab lists for the admin stick menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While compiling list definitions for the admin stick UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">tgt</span> Current admin stick target.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">lists</span> Table of list definitions; append your own entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAdminStickLists", "ExampleGetAdminStickLists", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getdisplayeddescription">
<summary><a id="GetDisplayedDescription"></a>GetDisplayedDescription(client, isHUD)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdisplayeddescription"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the description text shown for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When building a player’s info panel for HUD or menus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player being described.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isHUD</span> True when drawing the 3D HUD info; false for menus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Description to display; return nil to use default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDisplayedDescription", "ExampleGetDisplayedDescription", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getdoorinfo">
<summary><a id="GetDoorInfo"></a>GetDoorInfo(entity, doorData, doorInfo)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdoorinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build or modify door info data before it is shown to players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a door is targeted and info lines are generated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> Data about owners, titles, etc.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorInfo</span> Display lines; modify to add/remove fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDoorInfo", "ExampleGetDoorInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getdoorinfoforadminstick">
<summary><a id="GetDoorInfoForAdminStick"></a>GetDoorInfoForAdminStick(target, extraInfo)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdoorinfoforadminstick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Supply extra admin-only door info shown in the admin stick UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin stick inspects a door and builds its detail view.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">target</span> Door or entity being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">extraInfo</span> Table of strings to display; append data here.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDoorInfoForAdminStick", "ExampleGetDoorInfoForAdminStick", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getinjuredtext">
<summary><a id="GetInjuredText"></a>GetInjuredText(c)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getinjuredtext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Return the localized injury descriptor and color for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When drawing player info overlays that show health status.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">c</span> Target player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> `{text, color}` describing injury level, or nil to skip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetInjuredText", "ExampleGetInjuredText", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getmaincharacterid">
<summary><a id="GetMainCharacterID"></a>GetMainCharacterID()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmaincharacterid"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide which character ID should be treated as the “main” one for menus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before selecting or loading the default character in the main menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Character ID to treat as primary, or nil for default logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetMainCharacterID", "ExampleGetMainCharacterID", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getmainmenuposition">
<summary><a id="GetMainMenuPosition"></a>GetMainMenuPosition(character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmainmenuposition"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide camera position/angles for the 3D main menu scene.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time the main menu loads and needs a camera transform.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character to base the position on.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Vector, Angle Position and angle to use; return nils to use defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetMainMenuPosition", "ExampleGetMainMenuPosition", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-interactionmenuclosed">
<summary><a id="InteractionMenuClosed"></a>InteractionMenuClosed()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="interactionmenuclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle logic when the interaction menu (context quick menu) closes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after the interaction menu panel is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InteractionMenuClosed", "ExampleInteractionMenuClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-interactionmenuopened">
<summary><a id="InteractionMenuOpened"></a>InteractionMenuOpened(frame)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="interactionmenuopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set up the interaction menu when it is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the interaction menu frame is instantiated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">frame</span> The interaction menu frame.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InteractionMenuOpened", "ExampleInteractionMenuOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-interceptclickitemicon">
<summary><a id="InterceptClickItemIcon"></a>InterceptClickItemIcon(inventoryPanel, itemIcon, keyCode)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="interceptclickitemicon"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Intercept mouse/keyboard clicks on an inventory item icon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever an inventory icon receives an input event.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">inventoryPanel</span> Panel hosting the inventory grid.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">itemIcon</span> Icon that was clicked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">keyCode</span> Mouse or keyboard code that triggered the event.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true to consume the click and prevent default behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InterceptClickItemIcon", "ExampleInterceptClickItemIcon", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryclosed">
<summary><a id="InventoryClosed"></a>InventoryClosed(inventoryPanel, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an inventory window is closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after an inventory panel is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">inventoryPanel</span> The panel that was closed.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory instance tied to the panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryClosed", "ExampleInventoryClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryitemiconcreated">
<summary><a id="InventoryItemIconCreated"></a>InventoryItemIconCreated(icon, item, inventoryPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryitemiconcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize an inventory item icon immediately after it is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a new icon panel is spawned for an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">icon</span> Icon panel.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item represented by the icon.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">inventoryPanel</span> Parent inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryItemIconCreated", "ExampleInventoryItemIconCreated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryopened">
<summary><a id="InventoryOpened"></a>InventoryOpened(panel, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle logic after an inventory panel is opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an inventory is displayed on screen.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">panel</span> Inventory panel.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryOpened", "ExampleInventoryOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventorypanelcreated">
<summary><a id="InventoryPanelCreated"></a>InventoryPanelCreated(panel, inventory, parent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventorypanelcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize the inventory panel when it is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after constructing a panel for an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The new inventory panel.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory the panel represents.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">parent</span> Parent container.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryPanelCreated", "ExampleInventoryPanelCreated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-itemdraggedoutofinventory">
<summary><a id="ItemDraggedOutOfInventory"></a>ItemDraggedOutOfInventory(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemdraggedoutofinventory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle dragging an item outside of an inventory grid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an item is released outside valid slots.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player performing the drag.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item being dragged.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemDraggedOutOfInventory", "ExampleItemDraggedOutOfInventory", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-itempaintover">
<summary><a id="ItemPaintOver"></a>ItemPaintOver(itemIcon, itemTable, w, h)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itempaintover"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw overlays on an item’s icon (e.g., status markers).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During icon paint for each inventory slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">itemIcon</span> Icon panel being drawn.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">itemTable</span> Item represented.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> Icon width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> Icon height.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemPaintOver", "ExampleItemPaintOver", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-itemshowentitymenu">
<summary><a id="ItemShowEntityMenu"></a>ItemShowEntityMenu(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemshowentitymenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Show a context menu for a world item entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the use key/menu key is pressed on a dropped item with actions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Item entity in the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemShowEntityMenu", "ExampleItemShowEntityMenu", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-loadcharinformation">
<summary><a id="LoadCharInformation"></a>LoadCharInformation()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="loadcharinformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Seed the character information sections for the F1 menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character info is about to be populated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LoadCharInformation", "ExampleLoadCharInformation", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-loadmaincharacter">
<summary><a id="LoadMainCharacter"></a>LoadMainCharacter()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="loadmaincharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Select and load the player’s main character when the menu opens.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During main menu initialization if a saved main character exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LoadMainCharacter", "ExampleLoadMainCharacter", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-loadmainmenuinformation">
<summary><a id="LoadMainMenuInformation"></a>LoadMainMenuInformation(info, character)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="loadmainmenuinformation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate informational text and preview for the main menu character card.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the main menu needs to show summary info for a character.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">info</span> Table to fill with display fields.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character being previewed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LoadMainMenuInformation", "ExampleLoadMainMenuInformation", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-modifyscoreboardmodel">
<summary><a id="ModifyScoreboardModel"></a>ModifyScoreboardModel(arg1, ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="modifyscoreboardmodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust the 3D model used in the scoreboard (pose, skin, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a scoreboard slot builds its player model preview.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">arg1</span> Model panel or data table for the slot.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player represented by the slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ModifyScoreboardModel", "ExampleModifyScoreboardModel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-modifyvoiceindicatortext">
<summary><a id="ModifyVoiceIndicatorText"></a>ModifyVoiceIndicatorText(client, voiceText, voiceType)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="modifyvoiceindicatortext"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the string shown in the voice indicator HUD.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each frame the local player is speaking.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Speaking player (local).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">voiceText</span> Default text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">voiceType</span> Current voice range (“whispering”, “talking”, “yelling”).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Replacement text; return nil to keep default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ModifyVoiceIndicatorText", "ExampleModifyVoiceIndicatorText", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawplayerinfobackground">
<summary><a id="DrawPlayerInfoBackground"></a>DrawPlayerInfoBackground()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawplayerinfobackground"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw the background panel behind player info overlays.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Just before drawing wrapped player info text in the HUD.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to suppress the default blurred background.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawPlayerInfoBackground", "ExampleDrawPlayerInfoBackground", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onadminstickmenuclosed">
<summary><a id="OnAdminStickMenuClosed"></a>OnAdminStickMenuClosed()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onadminstickmenuclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle state cleanup when the admin stick menu closes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin stick UI window is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnAdminStickMenuClosed", "ExampleOnAdminStickMenuClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onchatreceived">
<summary><a id="OnChatReceived"></a>OnChatReceived(client, chatType, text, anonymous)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchatreceived"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to chat messages received by the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a chat message is parsed and before it is displayed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Sender of the message.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> Message content.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">anonymous</span> Whether the message should hide the sender.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnChatReceived", "ExampleOnChatReceived", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatedualinventorypanels">
<summary><a id="OnCreateDualInventoryPanels"></a>OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreatedualinventorypanels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize paired inventory panels when two inventories are shown side by side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after both inventory panels are created (e.g., player + storage).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">panel1</span> First inventory panel.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">panel2</span> Second inventory panel.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory1</span> Inventory bound to panel1.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory2</span> Inventory bound to panel2.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateDualInventoryPanels", "ExampleOnCreateDualInventoryPanels", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreateiteminteractionmenu">
<summary><a id="OnCreateItemInteractionMenu"></a>OnCreateItemInteractionMenu(itemIcon, menu, itemTable)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreateiteminteractionmenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Augment the context menu shown when right-clicking an inventory item icon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after the interaction menu for an item icon is built.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">itemIcon</span> The icon being interacted with.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">menu</span> The context menu object.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">itemTable</span> Item associated with the icon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateItemInteractionMenu", "ExampleOnCreateItemInteractionMenu", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatestoragepanel">
<summary><a id="OnCreateStoragePanel"></a>OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreatestoragepanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize the dual-inventory storage panel layout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the local and storage inventory panels are created for a storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">localInvPanel</span> Panel showing the player inventory.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">storageInvPanel</span> Panel showing the storage inventory.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|table</a></span> <span class="parameter">storage</span> Storage object or entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateStoragePanel", "ExampleOnCreateStoragePanel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onlocalvarset">
<summary><a id="OnLocalVarSet"></a>OnLocalVarSet(key, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onlocalvarset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to a local networked variable being set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever a net var assigned to the local player changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnLocalVarSet", "ExampleOnLocalVarSet", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onopenvendormenu">
<summary><a id="OnOpenVendorMenu"></a>OnOpenVendorMenu(vendorPanel, vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onopenvendormenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate the vendor UI when it opens.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the vendor panel is created client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">vendorPanel</span> Panel used to display vendor goods.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity interacted with.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnOpenVendorMenu", "ExampleOnOpenVendorMenu", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onlinestaffdatareceived">
<summary><a id="OnlineStaffDataReceived"></a>OnlineStaffDataReceived(staffData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onlinestaffdatareceived"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle the list of online staff received from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When staff data is synchronized to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">staffData</span> Array of staff entries (name, steamID, duty status).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnlineStaffDataReceived", "ExampleOnlineStaffDataReceived", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-openadminstickui">
<summary><a id="OpenAdminStickUI"></a>OpenAdminStickUI(tgt)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="openadminstickui"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Open the admin stick interface for a target entity or player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin stick weapon requests to show its UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">tgt</span> Target entity/player selected by the admin stick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OpenAdminStickUI", "ExampleOpenAdminStickUI", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-paintitem">
<summary><a id="PaintItem"></a>PaintItem(item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="paintitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw or tint an item icon before it is painted to the grid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prior to rendering each item icon surface.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item being drawn.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PaintItem", "ExamplePaintItem", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateadminstick">
<summary><a id="PopulateAdminStick"></a>PopulateAdminStick(currentMenu, currentTarget, currentStores)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateadminstick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add tabs and actions to the admin stick UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While constructing the admin stick menu for the current target.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">currentMenu</span> Root menu panel.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">currentTarget</span> Entity being acted upon.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">currentStores</span> Cached admin stick data (lists, categories).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateAdminStick", "ExamplePopulateAdminStick", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateadmintabs">
<summary><a id="PopulateAdminTabs"></a>PopulateAdminTabs(pages)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateadmintabs"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register admin tabs for the F1 administration menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When building the admin tab list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">pages</span> Table to append tab definitions `{name, icon, build=function}`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateAdminTabs", "ExamplePopulateAdminTabs", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateconfigurationbuttons">
<summary><a id="PopulateConfigurationButtons"></a>PopulateConfigurationButtons(pages)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateconfigurationbuttons"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add configuration buttons for the options/configuration tab.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When creating the configuration pages in the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">pages</span> Collection of page descriptors to populate.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateConfigurationButtons", "ExamplePopulateConfigurationButtons", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populatefactionrosteroptions">
<summary><a id="PopulateFactionRosterOptions"></a>PopulateFactionRosterOptions(list, members)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populatefactionrosteroptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add custom menu options to the faction roster table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the faction roster UI is being populated with member data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">list</span> The liaTable panel that displays the roster. Use list:AddMenuOption() to add right-click menu options.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">members</span> Array of member data tables containing name, charID, steamID, and lastOnline fields.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateFactionRosterOptions", "MyCustomRosterOptions", function(list, members)
      list:AddMenuOption("View Profile", function(rowData)
          if rowData and rowData.charID then
              print("Viewing profile for character ID:", rowData.charID)
          end
      end, "icon16/user.png")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateinventoryitems">
<summary><a id="PopulateInventoryItems"></a>PopulateInventoryItems(pnlContent, tree)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateinventoryitems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate the inventory items tree used in the admin menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the inventory item browser is built.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">pnlContent</span> Content panel to fill.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">tree</span> Tree/list control to populate.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateInventoryItems", "ExamplePopulateInventoryItems", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-postdrawinventory">
<summary><a id="PostDrawInventory"></a>PostDrawInventory(mainPanel, parentPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postdrawinventory"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Draw additional UI after the main inventory panels are painted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After inventory drawing completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">mainPanel</span> Primary inventory panel.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">parentPanel</span> Parent container.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostDrawInventory", "ExamplePostDrawInventory", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-postloadfonts">
<summary><a id="PostLoadFonts"></a>PostLoadFonts(mainFont, mainFont)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postloadfonts"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust fonts after they are loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after main fonts are initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">mainFont</span> Primary font name (duplicate parameter kept for API compatibility).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">mainFont</span> Alias of the same font name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PostLoadFonts", "ExamplePostLoadFonts", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-drawphysgunbeam">
<summary><a id="DrawPhysgunBeam"></a>DrawPhysgunBeam()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="drawphysgunbeam"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether to draw the physgun beam for the local player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During physgun render.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to suppress the beam; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DrawPhysgunBeam", "ExampleDrawPhysgunBeam", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-refreshfonts">
<summary><a id="RefreshFonts"></a>RefreshFonts()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="refreshfonts"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Recreate or refresh fonts when settings change.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After option changes that impact font sizes or faces.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RefreshFonts", "ExampleRefreshFonts", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-registeradminsticksubcategories">
<summary><a id="RegisterAdminStickSubcategories"></a>RegisterAdminStickSubcategories(categories)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="registeradminsticksubcategories"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register admin stick subcategories used to group commands.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When assembling the category tree for the admin stick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">categories</span> Table of category -> subcategory mappings; modify in place.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RegisterAdminStickSubcategories", "ExampleRegisterAdminStickSubcategories", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-resetcharacterpanel">
<summary><a id="ResetCharacterPanel"></a>ResetCharacterPanel()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="resetcharacterpanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reset the character panel to its initial state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the character menu needs to clear cached data/layout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ResetCharacterPanel", "ExampleResetCharacterPanel", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-runadminsystemcommand">
<summary><a id="RunAdminSystemCommand"></a>RunAdminSystemCommand(cmd, admin, victim, dur, reason)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="runadminsystemcommand"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Execute an admin-system command initiated from the UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the admin stick or admin menu triggers a command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">cmd</span> Command identifier.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">admin</span> Admin issuing the command.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|Player</a></span> <span class="parameter">victim</span> Target of the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">dur</span> Duration parameter if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">reason</span> Optional reason text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RunAdminSystemCommand", "ExampleRunAdminSystemCommand", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-scoreboardclosed">
<summary><a id="ScoreboardClosed"></a>ScoreboardClosed(scoreboardPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="scoreboardclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Perform teardown when the scoreboard closes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the scoreboard panel is hidden or destroyed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">scoreboardPanel</span> The scoreboard instance that was closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ScoreboardClosed", "ExampleScoreboardClosed", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-scoreboardopened">
<summary><a id="ScoreboardOpened"></a>ScoreboardOpened(scoreboardPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="scoreboardopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initialize the scoreboard after it is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Right after the scoreboard panel is shown.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">scoreboardPanel</span> The scoreboard instance that opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ScoreboardOpened", "ExampleScoreboardOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-scoreboardrowcreated">
<summary><a id="ScoreboardRowCreated"></a>ScoreboardRowCreated(slot, ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="scoreboardrowcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize a newly created scoreboard row.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player slot is added to the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">slot</span> Scoreboard row panel.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player represented by the row.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ScoreboardRowCreated", "ExampleScoreboardRowCreated", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-scoreboardrowremoved">
<summary><a id="ScoreboardRowRemoved"></a>ScoreboardRowRemoved(scoreboardPanel, ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="scoreboardrowremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a scoreboard row is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player leaves or is otherwise removed from the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">scoreboardPanel</span> Scoreboard instance.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player whose row was removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ScoreboardRowRemoved", "ExampleScoreboardRowRemoved", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setmaincharacter">
<summary><a id="SetMainCharacter"></a>SetMainCharacter(charID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setmaincharacter"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set the main character ID for future automatic selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the player chooses a character to become their main.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">charID</span> Chosen character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetMainCharacter", "ExampleSetMainCharacter", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setupquickmenu">
<summary><a id="SetupQuickMenu"></a>SetupQuickMenu(quickMenuPanel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupquickmenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build the quick access menu when the context menu opens.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the quick menu panel is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">quickMenuPanel</span> Panel that holds quick actions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupQuickMenu", "ExampleSetupQuickMenu", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldallowscoreboardoverride">
<summary><a id="ShouldAllowScoreboardOverride"></a>ShouldAllowScoreboardOverride(client, var)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldallowscoreboardoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a player is permitted to override the scoreboard UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before applying any scoreboard override logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">var</span> Additional context or override data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to deny override; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldAllowScoreboardOverride", "ExampleShouldAllowScoreboardOverride", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldbardraw">
<summary><a id="ShouldBarDraw"></a>ShouldBarDraw(bar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldbardraw"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine whether a HUD bar should render.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When evaluating each registered bar before drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">bar</span> Bar definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide the bar; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldBarDraw", "ExampleShouldBarDraw", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shoulddisablethirdperson">
<summary><a id="ShouldDisableThirdperson"></a>ShouldDisableThirdperson(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddisablethirdperson"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether third-person mode should be forcibly disabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the third-person toggle state changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player toggling third person.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to block third-person; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDisableThirdperson", "ExampleShouldDisableThirdperson", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shoulddrawammo">
<summary><a id="ShouldDrawAmmo"></a>ShouldDrawAmmo(wpn)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddrawammo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Let modules veto drawing the ammo HUD for a weapon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each HUDPaint frame before ammo boxes render.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Weapon">Weapon</a></span> <span class="parameter">wpn</span> Active weapon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide ammo; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDrawAmmo", "ExampleShouldDrawAmmo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shoulddrawentityinfo">
<summary><a id="ShouldDrawEntityInfo"></a>ShouldDrawEntityInfo(e)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddrawentityinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether an entity should display info when looked at.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When deciding if entity info overlays should be generated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">e</span> Entity under consideration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to prevent info; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDrawEntityInfo", "ExampleShouldDrawEntityInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shoulddrawplayerinfo">
<summary><a id="ShouldDrawPlayerInfo"></a>ShouldDrawPlayerInfo(e)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddrawplayerinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether player-specific info should be drawn for a target.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before rendering the player info panel above a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">e</span> Player entity being drawn.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide info; nil/true to draw.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDrawPlayerInfo", "ExampleShouldDrawPlayerInfo", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shoulddrawwepselect">
<summary><a id="ShouldDrawWepSelect"></a>ShouldDrawWepSelect(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shoulddrawwepselect"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if the custom weapon selector should draw for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each frame the selector evaluates visibility.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Local player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide the selector; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldDrawWepSelect", "ExampleShouldDrawWepSelect", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldhidebars">
<summary><a id="ShouldHideBars"></a>ShouldHideBars()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldhidebars"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Hide all HUD bars based on external conditions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before drawing any bars on the HUD.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true to hide all bars; nil/false to render them.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldHideBars", "ExampleShouldHideBars", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldmenubuttonshow">
<summary><a id="ShouldMenuButtonShow"></a>ShouldMenuButtonShow(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldmenubuttonshow"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether a button should appear in the menu bar.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When building quick menu buttons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|string</a></span> <span class="parameter">arg1</span> Button identifier or data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldMenuButtonShow", "ExampleShouldMenuButtonShow", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldrespawnscreenappear">
<summary><a id="ShouldRespawnScreenAppear"></a>ShouldRespawnScreenAppear()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldrespawnscreenappear"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether the respawn screen should be displayed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the client dies and the respawn UI might show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to suppress; nil/true to display.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldRespawnScreenAppear", "ExampleShouldRespawnScreenAppear", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldshowcharvarincreation">
<summary><a id="ShouldShowCharVarInCreation"></a>ShouldShowCharVarInCreation(key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldshowcharvarincreation"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine if a character variable should appear in the creation form.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While assembling the list of editable character variables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Character variable identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldShowCharVarInCreation", "ExampleShouldShowCharVarInCreation", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldshowclassonscoreboard">
<summary><a id="ShouldShowClassOnScoreboard"></a>ShouldShowClassOnScoreboard(clsData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldshowclassonscoreboard"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether to display a player’s class on the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When rendering scoreboard rows that include class info.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">clsData</span> Class data table for the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide class; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldShowClassOnScoreboard", "ExampleShouldShowClassOnScoreboard", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldshowfactiononscoreboard">
<summary><a id="ShouldShowFactionOnScoreboard"></a>ShouldShowFactionOnScoreboard(ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldshowfactiononscoreboard"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether to display a player’s faction on the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When rendering a scoreboard row.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player being displayed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to hide faction; nil/true to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldShowFactionOnScoreboard", "ExampleShouldShowFactionOnScoreboard", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldshowplayeronscoreboard">
<summary><a id="ShouldShowPlayerOnScoreboard"></a>ShouldShowPlayerOnScoreboard(ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldshowplayeronscoreboard"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether a player should appear on the scoreboard at all.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before adding a player row to the scoreboard.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player under consideration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to omit the player; nil/true to include.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldShowPlayerOnScoreboard", "ExampleShouldShowPlayerOnScoreboard", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-shouldshowquickmenu">
<summary><a id="ShouldShowQuickMenu"></a>ShouldShowQuickMenu()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="shouldshowquickmenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether the quick menu should open when the context menu is toggled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the context menu is opened.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> false to prevent quick menu creation; nil/true to allow.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShouldShowQuickMenu", "ExampleShouldShowQuickMenu", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-showplayeroptions">
<summary><a id="ShowPlayerOptions"></a>ShowPlayerOptions(target, options)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="showplayeroptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populate the options menu for a specific player (e.g., mute, profile).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When opening a player interaction context menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player the options apply to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> Table of options to display; modify in place.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ShowPlayerOptions", "ExampleShowPlayerOptions", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-storageopen">
<summary><a id="StorageOpen"></a>StorageOpen(storage, isCar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageopen"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle the client opening a storage entity inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When storage access is approved and panels are about to show.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|table</a></span> <span class="parameter">storage</span> Storage entity or custom storage table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isCar</span> True if the storage is a vehicle trunk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageOpen", "ExampleStorageOpen", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-storageunlockprompt">
<summary><a id="StorageUnlockPrompt"></a>StorageUnlockPrompt(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageunlockprompt"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prompt the player to unlock a locked storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the client interacts with a locked storage container.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Storage entity requiring an unlock prompt.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageUnlockPrompt", "ExampleStorageUnlockPrompt", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-thirdpersontoggled">
<summary><a id="ThirdPersonToggled"></a>ThirdPersonToggled(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="thirdpersontoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when the third-person toggle state changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After third-person mode is turned on or off.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">arg1</span> New third-person enabled state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ThirdPersonToggled", "ExampleThirdPersonToggled", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-tooltipinitialize">
<summary><a id="TooltipInitialize"></a>TooltipInitialize(var, panel)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="tooltipinitialize"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initialize tooltip contents and sizing for Lilia tooltips.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a tooltip panel is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">panel</span> Source panel that spawned the tooltip.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TooltipInitialize", "ExampleTooltipInitialize", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-tooltiplayout">
<summary><a id="TooltipLayout"></a>TooltipLayout(var)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="tooltiplayout"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control tooltip layout; return true to keep the custom layout.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each frame the tooltip is laid out.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true if a custom layout was applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TooltipLayout", "ExampleTooltipLayout", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-tooltippaint">
<summary><a id="TooltipPaint"></a>TooltipPaint(var, w, h)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="tooltippaint"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Paint the custom tooltip background and contents.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a tooltip panel is drawn.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">w</span> Width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">h</span> Height.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true if the tooltip was fully painted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TooltipPaint", "ExampleTooltipPaint", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorexited">
<summary><a id="VendorExited"></a>VendorExited()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorexited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle logic when exiting a vendor menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the vendor UI is closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorExited", "ExampleVendorExited", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoropened">
<summary><a id="VendorOpened"></a>VendorOpened(vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoropened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Perform setup when a vendor menu opens.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after opening the vendor UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|table</a></span> <span class="parameter">vendor</span> Vendor being accessed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VendorOpened", "ExampleVendorOpened", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-voicetoggled">
<summary><a id="VoiceToggled"></a>VoiceToggled(enabled)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="voicetoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Respond to voice chat being toggled on or off.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the client enables or disables in-game voice.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">enabled</span> New voice toggle state.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("VoiceToggled", "ExampleVoiceToggled", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-weaponcyclesound">
<summary><a id="WeaponCycleSound"></a>WeaponCycleSound()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="weaponcyclesound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Play a custom sound when cycling weapons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the weapon selector changes selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Sound path to play; nil to use default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WeaponCycleSound", "ExampleWeaponCycleSound", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-weaponselectsound">
<summary><a id="WeaponSelectSound"></a>WeaponSelectSound()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="weaponselectsound"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Play a sound when confirming weapon selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the weapon selector picks the highlighted weapon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Sound path to play; nil for default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WeaponSelectSound", "ExampleWeaponSelectSound", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-webimagedownloaded">
<summary><a id="WebImageDownloaded"></a>WebImageDownloaded(n, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="webimagedownloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle a downloaded web image asset.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a remote image finishes downloading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">n</span> Image identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">arg2</span> Local path or URL of the image.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WebImageDownloaded", "ExampleWebImageDownloaded", function(...)
      -- add custom client-side behavior
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-websounddownloaded">
<summary><a id="WebSoundDownloaded"></a>WebSoundDownloaded(name, path)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="websounddownloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle a downloaded web sound asset.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a remote sound file is fetched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Sound identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> Local file path where the sound was saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("WebSoundDownloaded", "ExampleWebSoundDownloaded", function(...)
      -- add custom client-side behavior
  end)
</div>
</details>

---

<details class="realm-client" id="function-onmodelpanelsetup">
<summary><a id="OnModelPanelSetup"></a>OnModelPanelSetup(self)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onmodelpanelsetup"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a liaModelPanel has been initialized and its model has been set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During the SetModel process of a liaModelPanel, after the entity is created and sequences are initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/panel/">Panel</a></span> <span class="parameter">self</span> The liaModelPanel instance that was set up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnModelPanelSetup", "CustomizeModelPanel", function(panel)
      panel:SetFOV(45)
  end)
</code></pre>
</div>

</div>
</details>

---

