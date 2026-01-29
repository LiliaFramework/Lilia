# Client-Side Hooks

Client-side hook system for the Lilia framework.

---

Overview

Client-side hooks in the Lilia framework handle UI, rendering, input, and other client-specific functionality; they can be used to customize the user experience and can be overridden or extended by addons and modules.

---

<details class="realm-client">
<summary><a id=AddBarField></a>AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)</summary>
<a id="addbarfield"></a>
<p>Register a dynamic bar entry to show in the character information panel (e.g., stamina or custom stats).</p>
<p>During character info build, before the F1 menu renders the bar sections.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">sectionName</span> Localized or raw section label to group the bar under.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fieldName</span> Unique key for the bar entry.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">labelText</span> Text shown next to the bar.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">minFunc</span> Callback returning the minimum numeric value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">maxFunc</span> Callback returning the maximum numeric value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">valueFunc</span> Callback returning the current numeric value to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AddBarField", "ExampleAddBarField", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AddSection></a>AddSection(sectionName, color, priority, location)</summary>
<a id="addsection"></a>
<p>Ensure a character information section exists and optionally override its styling and position.</p>
<p>When the F1 character info UI is initialized or refreshed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">sectionName</span> Localized or raw name of the section (e.g., “generalInfo”).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">color</span> Accent color used for the section header.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">priority</span> Sort order; lower numbers appear first.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">location</span> Column index in the character info layout.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AddSection", "ExampleAddSection", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AddTextField></a>AddTextField(sectionName, fieldName, labelText, valueFunc)</summary>
<a id="addtextfield"></a>
<p>Register a text field for the character information panel.</p>
<p>While building character info just before the F1 menu renders.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">sectionName</span> Target section to append the field to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">fieldName</span> Unique identifier for the field.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">labelText</span> Caption displayed before the value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">valueFunc</span> Callback that returns the string to render.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AddTextField", "ExampleAddTextField", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AddToAdminStickHUD></a>AddToAdminStickHUD(client, target, information)</summary>
<a id="addtoadminstickhud"></a>
<p>Add extra lines to the on-screen admin-stick HUD that appears while aiming with the admin stick.</p>
<p>Each HUDPaint tick when the admin stick is active and a target is valid.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player using the admin stick.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">target</span> Entity currently traced by the admin stick.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">information</span> Table of strings; insert new lines to show additional info.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AddToAdminStickHUD", "ExampleAddToAdminStickHUD", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AdminPrivilegesUpdated></a>AdminPrivilegesUpdated()</summary>
<a id="adminprivilegesupdated"></a>
<p>React to privilege list updates pushed from the server (used by the admin stick UI).</p>
<p>After the server syncs admin privilege changes to the client.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdminPrivilegesUpdated", "ExampleAdminPrivilegesUpdated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=AdminStickAddModels></a>AdminStickAddModels(allModList, tgt)</summary>
<a id="adminstickaddmodels"></a>
<p>Provide model and icon overrides for the admin stick spawn menu list.</p>
<p>When the admin stick UI collects available models and props to display.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">allModList</span> Table of model entries to be displayed; append or modify entries here.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">tgt</span> Entity currently targeted by the admin stick.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("AdminStickAddModels", "ExampleAdminStickAddModels", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanDeleteChar></a>CanDeleteChar(client, character)</summary>
<a id="candeletechar"></a>
<p>Decide whether a client is allowed to delete a specific character.</p>
<p>When the delete character button is pressed in the character menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting the deletion.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character|table</a></span> <span class="parameter">character</span> Character object slated for deletion.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to block deletion; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanDeleteChar", "ExampleCanDeleteChar", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanDisplayCharInfo></a>CanDisplayCharInfo(name)</summary>
<a id="candisplaycharinfo"></a>
<p>Control whether the name above a character can be shown to the local player.</p>
<p>Before drawing a player’s overhead information.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> The formatted name that would be displayed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide the name; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanDisplayCharInfo", "ExampleCanDisplayCharInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanOpenBagPanel></a>CanOpenBagPanel(item)</summary>
<a id="canopenbagpanel"></a>
<p>Allow or block opening the bag inventory panel for a specific item.</p>
<p>When a bag or storage item icon is activated to open its contents.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> The bag item whose inventory is being opened.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to prevent opening; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanOpenBagPanel", "ExampleCanOpenBagPanel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanPlayerOpenScoreboard></a>CanPlayerOpenScoreboard(arg1)</summary>
<a id="canplayeropenscoreboard"></a>
<p>Decide whether the scoreboard should open for the requesting client.</p>
<p>When the scoreboard key is pressed and before building the panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">arg1</span> Player attempting to open the scoreboard.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to block; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerOpenScoreboard", "ExampleCanPlayerOpenScoreboard", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanTakeEntity></a>CanTakeEntity(client, targetEntity, itemUniqueID)</summary>
<a id="cantakeentity"></a>
<p>Determines if a player can take/convert an entity into an item.</p>
<p>Before attempting to convert an entity into an item using the take entity keybind.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player attempting to take the entity.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">targetEntity</span> The entity being targeted for conversion.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">itemUniqueID</span> The unique ID of the item that would be created.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> False to prevent taking the entity; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanTakeEntity", "RestrictEntityTaking", function(client, targetEntity, itemUniqueID)
        if targetEntity:IsPlayer() then return false end
        return true
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CanPlayerViewInventory></a>CanPlayerViewInventory()</summary>
<a id="canplayerviewinventory"></a>
<p>Determine if the local player can open their inventory UI.</p>
<p>Before spawning any inventory window.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to stop the inventory from opening; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CanPlayerViewInventory", "ExampleCanPlayerViewInventory", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharListColumns></a>CharListColumns(columns)</summary>
<a id="charlistcolumns"></a>
<p>Add or adjust columns in the character list panel.</p>
<p>Right before the character selection table is rendered.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">columns</span> Table of column definitions; modify in place to add/remove columns.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharListColumns", "ExampleCharListColumns", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharListEntry></a>CharListEntry(entry, row)</summary>
<a id="charlistentry"></a>
<p>Modify how each character entry renders in the character list.</p>
<p>For every row when the character list is constructed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">entry</span> Data for the character (id, name, faction, etc.).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">row</span> The row panel being built.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharListEntry", "ExampleCharListEntry", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharListLoaded></a>CharListLoaded(newCharList)</summary>
<a id="charlistloaded"></a>
<p>Seed character info sections and fields after the client receives the character list.</p>
<p>Once the client finishes downloading the character list from the server.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">newCharList</span> Array of character summaries.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharListLoaded", "ExampleCharListLoaded", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharListUpdated></a>CharListUpdated(oldCharList, newCharList)</summary>
<a id="charlistupdated"></a>
<p>React to changes between the old and new character lists.</p>
<p>After the server sends an updated character list (e.g., after delete/create).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">oldCharList</span> Previous list snapshot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">newCharList</span> Updated list snapshot.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharListUpdated", "ExampleCharListUpdated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharLoaded></a>CharLoaded(character)</summary>
<a id="charloaded"></a>
<p>Handle local initialization once a character has fully loaded on the client.</p>
<p>After the server confirms the character load and sets netvars.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character|number</a></span> <span class="parameter">character</span> Character object or id that was loaded.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharLoaded", "ExampleCharLoaded", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharMenuClosed></a>CharMenuClosed()</summary>
<a id="charmenuclosed"></a>
<p>Cleanup or state changes when the character menu is closed.</p>
<p>Right after the character menu panel is removed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharMenuClosed", "ExampleCharMenuClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharMenuOpened></a>CharMenuOpened(charMenu)</summary>
<a id="charmenuopened"></a>
<p>Perform setup each time the character menu is opened.</p>
<p>Immediately after constructing the character menu panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">charMenu</span> The created menu panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharMenuOpened", "ExampleCharMenuOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CharRestored></a>CharRestored(character)</summary>
<a id="charrestored"></a>
<p>Handle client-side work after a character is restored from deletion.</p>
<p>When the server finishes restoring a deleted character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character|number</a></span> <span class="parameter">character</span> The restored character object or id.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CharRestored", "ExampleCharRestored", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ChatAddText></a>ChatAddText(text)</summary>
<a id="chataddtext"></a>
<p>Override how chat text is appended to the chat box.</p>
<p>Whenever chat text is about to be printed locally.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">text</span> First argument passed to chat.AddText.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ChatAddText", "ExampleChatAddText", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ChatboxPanelCreated></a>ChatboxPanelCreated(arg1)</summary>
<a id="chatboxpanelcreated"></a>
<p>Adjust the chatbox panel right after it is created.</p>
<p>Once the chat UI instance is built client-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">arg1</span> The chatbox panel instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ChatboxPanelCreated", "ExampleChatboxPanelCreated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ChatboxTextAdded></a>ChatboxTextAdded(arg1)</summary>
<a id="chatboxtextadded"></a>
<p>Intercept a newly added chat line before it renders in the chatbox.</p>
<p>After chat text is parsed but before it is drawn in the panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">arg1</span> Chat panel or message object being added.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ChatboxTextAdded", "ExampleChatboxTextAdded", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ChooseCharacter></a>ChooseCharacter(id)</summary>
<a id="choosecharacter"></a>
<p>Respond to character selection from the list.</p>
<p>When a user clicks the play button on a character slot.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> The selected character’s id.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ChooseCharacter", "ExampleChooseCharacter", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CommandRan></a>CommandRan(client, command, arg3, results)</summary>
<a id="commandran"></a>
<p>React after a command finishes executing client-side.</p>
<p>Immediately after a console/chat command is processed on the client.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player who ran the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Command name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">arg3</span> Arguments or raw text passed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">results</span> Return data from the command handler, if any.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CommandRan", "ExampleCommandRan", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ConfigureCharacterCreationSteps></a>ConfigureCharacterCreationSteps(creationPanel)</summary>
<a id="configurecharactercreationsteps"></a>
<p>Reorder or add steps to the character creation wizard.</p>
<p>When the creation UI is building its step list.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">creationPanel</span> The root creation panel containing step definitions.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ConfigureCharacterCreationSteps", "ExampleConfigureCharacterCreationSteps", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateCharacter></a>CreateCharacter(data)</summary>
<a id="createcharacter"></a>
<p>Validate or mutate character data immediately before it is submitted to the server.</p>
<p>When the user presses the final create/submit button.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Character creation payload (name, model, faction, etc.).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to abort submission; nil/true to continue.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateCharacter", "ExampleCreateCharacter", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateChatboxPanel></a>CreateChatboxPanel()</summary>
<a id="createchatboxpanel"></a>
<p>Called when the chatbox panel needs to be created or recreated.</p>
<p>When the chatbox module initializes, when the chatbox panel is closed and needs to be reopened, or when certain chat-related events occur.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateChatboxPanel", "ExampleCreateChatboxPanel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateDefaultInventory></a>CreateDefaultInventory(character)</summary>
<a id="createdefaultinventory"></a>
<p>Choose what inventory implementation to instantiate for a newly created character.</p>
<p>After the client finishes character creation but before the inventory is built.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> The character being initialized.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Inventory type id to create (e.g., “GridInv”).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateDefaultInventory", "ExampleCreateDefaultInventory", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateInformationButtons></a>CreateInformationButtons(pages)</summary>
<a id="createinformationbuttons"></a>
<p>Populate the list of buttons for the Information tab in the F1 menu.</p>
<p>When the Information tab is created and ready to collect pages.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">pages</span> Table of page descriptors; insert entries with name/icon/build function.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateInformationButtons", "ExampleCreateInformationButtons", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateInventoryPanel></a>CreateInventoryPanel(inventory, parent)</summary>
<a id="createinventorypanel"></a>
<p>Build the root panel used for displaying an inventory instance.</p>
<p>Each time an inventory needs a panel representation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory object to show.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">parent</span> Parent UI element the panel should attach to.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> The created inventory panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateInventoryPanel", "ExampleCreateInventoryPanel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=CreateMenuButtons></a>CreateMenuButtons(tabs)</summary>
<a id="createmenubuttons"></a>
<p>Register custom tabs for the F1 menu.</p>
<p>When the F1 menu initializes its tab definitions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tabs</span> Table of tab constructors keyed by tab id; add new entries to inject tabs.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("CreateMenuButtons", "ExampleCreateMenuButtons", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DeleteCharacter></a>DeleteCharacter(id)</summary>
<a id="deletecharacter"></a>
<p>Handle client-side removal of a character slot.</p>
<p>After a deletion request succeeds.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> ID of the character that was removed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DeleteCharacter", "ExampleDeleteCharacter", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DermaSkinChanged></a>DermaSkinChanged(newSkin)</summary>
<a id="dermaskinchanged"></a>
<p>React when the active Derma skin changes client-side.</p>
<p>Immediately after the skin is switched.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">newSkin</span> Name of the newly applied skin.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DermaSkinChanged", "ExampleDermaSkinChanged", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DisplayPlayerHUDInformation></a>DisplayPlayerHUDInformation(client, hudInfos)</summary>
<a id="displayplayerhudinformation"></a>
<p>Inject custom HUD info boxes into the player HUD.</p>
<p>Every HUDPaint frame while the player is alive and has a character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">hudInfos</span> Array to be filled with info tables (text, position, styling).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DisplayPlayerHUDInformation", "ExampleDisplayPlayerHUDInformation", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DoorDataReceived></a>DoorDataReceived(door, syncData)</summary>
<a id="doordatareceived"></a>
<p>Handle incoming door synchronization data from the server.</p>
<p>When the server sends door ownership or data updates.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">door</span> Door entity being updated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">syncData</span> Data payload containing door state/owners.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DoorDataReceived", "ExampleDoorDataReceived", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawCharInfo></a>DrawCharInfo(client, character, info)</summary>
<a id="drawcharinfo"></a>
<p>Add custom lines to the character info overlay drawn above players.</p>
<p>Right before drawing info for a player (name/description).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose info is being drawn.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> Character belonging to the player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">info</span> Array of `{text, color}` rows; append to extend display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawCharInfo", "ExampleDrawCharInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawEntityInfo></a>DrawEntityInfo(e, a, pos)</summary>
<a id="drawentityinfo"></a>
<p>Customize how entity information panels render in the world.</p>
<p>When an entity has been marked to display info and is being drawn.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">e</span> Target entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">a</span> Alpha value (0-255) for fade in/out.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|Vector</a></span> <span class="parameter">pos</span> Screen position for the info panel (optional).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawEntityInfo", "ExampleDrawEntityInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawItemEntityInfo></a>DrawItemEntityInfo(itemEntity, item, infoTable, alpha)</summary>
<a id="drawitementityinfo"></a>
<p>Adjust or add lines for dropped item entity info.</p>
<p>When hovering/aiming at a dropped item that is rendering its info.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">itemEntity</span> World entity representing the item.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item table attached to the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">infoTable</span> Lines describing the item; modify to add details.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alpha</span> Current alpha used for drawing.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawItemEntityInfo", "ExampleDrawItemEntityInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawLiliaModelView></a>DrawLiliaModelView(client, entity)</summary>
<a id="drawliliamodelview"></a>
<p>Draw extra elements in the character preview model (e.g., held weapon).</p>
<p>When the character model view panel paints.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player being previewed.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> The model panel entity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawLiliaModelView", "ExampleDrawLiliaModelView", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawPlayerRagdoll></a>DrawPlayerRagdoll(entity)</summary>
<a id="drawplayerragdoll"></a>
<p>Draw attachments or cosmetics on a player’s ragdoll entity.</p>
<p>During ragdoll RenderOverride when a player’s corpse is rendered.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> The ragdoll entity being drawn.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawPlayerRagdoll", "ExampleDrawPlayerRagdoll", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=F1MenuClosed></a>F1MenuClosed()</summary>
<a id="f1menuclosed"></a>
<p>React to the F1 menu closing.</p>
<p>Immediately after the F1 menu panel is removed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("F1MenuClosed", "ExampleF1MenuClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=F1MenuOpened></a>F1MenuOpened(f1MenuPanel)</summary>
<a id="f1menuopened"></a>
<p>Perform setup when the F1 menu opens.</p>
<p>Immediately after the F1 menu is created.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">f1MenuPanel</span> The opened menu panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("F1MenuOpened", "ExampleF1MenuOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=FilterCharModels></a>FilterCharModels(arg1)</summary>
<a id="filtercharmodels"></a>
<p>Whitelist or blacklist models shown in the character creation model list.</p>
<p>While building the selectable model list for character creation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arg1</span> Table of available model paths; mutate to filter.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("FilterCharModels", "ExampleFilterCharModels", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=FilterDoorInfo></a>FilterDoorInfo(entity, doorData, doorInfo)</summary>
<a id="filterdoorinfo"></a>
<p>Adjust door information before it is shown on the HUD.</p>
<p>After door data is prepared for display but before drawing text.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> The door being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">doorData</span> Raw door data (owners, title, etc.).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">doorInfo</span> Table of display lines; mutate to change output.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("FilterDoorInfo", "ExampleFilterDoorInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetAdjustedPartData></a>GetAdjustedPartData(wearer, id)</summary>
<a id="getadjustedpartdata"></a>
<p>Provide PAC part data overrides before parts attach to a player.</p>
<p>When a PAC part is requested for attachment.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">wearer</span> Player the part will attach to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> Identifier for the part/item.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Adjusted part data; return nil to use cached defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetAdjustedPartData", "ExampleGetAdjustedPartData", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterCreateButtonTooltip></a>GetCharacterCreateButtonTooltip(client, currentChars, maxChars)</summary>
<a id="getcharactercreatebuttontooltip"></a>
<p>Allows overriding the tooltip text for the character creation button.</p>
<p>When the character creation button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">currentChars</span> Number of characters the player currently has.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">maxChars</span> Maximum number of characters allowed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterCreateButtonTooltip", "ExampleGetCharacterCreateButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterDisconnectButtonTooltip></a>GetCharacterDisconnectButtonTooltip(client)</summary>
<a id="getcharacterdisconnectbuttontooltip"></a>
<p>Allows overriding the tooltip text for the character disconnect button.</p>
<p>When the character disconnect button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterDisconnectButtonTooltip", "ExampleGetCharacterDisconnectButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterDiscordButtonTooltip></a>GetCharacterDiscordButtonTooltip(client, discordURL)</summary>
<a id="getcharacterdiscordbuttontooltip"></a>
<p>Allows overriding the tooltip text for the Discord button.</p>
<p>When the Discord button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">discordURL</span> The Discord server URL.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterDiscordButtonTooltip", "ExampleGetCharacterDiscordButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterLoadButtonTooltip></a>GetCharacterLoadButtonTooltip(client)</summary>
<a id="getcharacterloadbuttontooltip"></a>
<p>Allows overriding the tooltip text for the character load button.</p>
<p>When the character load button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterLoadButtonTooltip", "ExampleGetCharacterLoadButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterLoadMainButtonTooltip></a>GetCharacterLoadMainButtonTooltip(client)</summary>
<a id="getcharacterloadmainbuttontooltip"></a>
<p>Allows overriding the tooltip text for the main character load button.</p>
<p>When the main character load button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterLoadMainButtonTooltip", "ExampleGetCharacterLoadMainButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterMountButtonTooltip></a>GetCharacterMountButtonTooltip(client)</summary>
<a id="getcharactermountbuttontooltip"></a>
<p>Allows overriding the tooltip text for the character mount button.</p>
<p>When the character mount button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterMountButtonTooltip", "ExampleGetCharacterMountButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterReturnButtonTooltip></a>GetCharacterReturnButtonTooltip(client)</summary>
<a id="getcharacterreturnbuttontooltip"></a>
<p>Allows overriding the tooltip text for the character return button.</p>
<p>When the character return button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterReturnButtonTooltip", "ExampleGetCharacterReturnButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterStaffButtonTooltip></a>GetCharacterStaffButtonTooltip(client, hasStaffChar)</summary>
<a id="getcharacterstaffbuttontooltip"></a>
<p>Allows overriding the tooltip text for the staff character button.</p>
<p>When the staff character button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">hasStaffChar</span> Whether the player has a staff character.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterStaffButtonTooltip", "ExampleGetCharacterStaffButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetCharacterWorkshopButtonTooltip></a>GetCharacterWorkshopButtonTooltip(client, workshopURL)</summary>
<a id="getcharacterworkshopbuttontooltip"></a>
<p>Allows overriding the tooltip text for the workshop button.</p>
<p>When the workshop button tooltip is being determined in the main menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player viewing the menu.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">workshopURL</span> The workshop URL.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Custom tooltip text, or nil to use default tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetCharacterWorkshopButtonTooltip", "ExampleGetCharacterWorkshopButtonTooltip", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetAdminESPTarget></a>GetAdminESPTarget(ent, client)</summary>
<a id="getadminesptarget"></a>
<p>Choose the entity that admin ESP should highlight.</p>
<p>When the admin ESP overlay evaluates the current trace target.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">ent</span> Entity under the admin’s crosshair.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Admin requesting the ESP target.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|nil</a></span> Replacement target entity, or nil to use the traced entity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetAdminESPTarget", "ExampleGetAdminESPTarget", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetAdminStickLists></a>GetAdminStickLists(tgt, lists)</summary>
<a id="getadminsticklists"></a>
<p>Contribute additional tab lists for the admin stick menu.</p>
<p>While compiling list definitions for the admin stick UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">tgt</span> Current admin stick target.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">lists</span> Table of list definitions; append your own entries.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetAdminStickLists", "ExampleGetAdminStickLists", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetDisplayedDescription></a>GetDisplayedDescription(client, isHUD)</summary>
<a id="getdisplayeddescription"></a>
<p>Override the description text shown for a player.</p>
<p>When building a player’s info panel for HUD or menus.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player being described.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">isHUD</span> True when drawing the 3D HUD info; false for menus.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Description to display; return nil to use default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDisplayedDescription", "ExampleGetDisplayedDescription", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetDoorInfo></a>GetDoorInfo(entity, doorData, doorInfo)</summary>
<a id="getdoorinfo"></a>
<p>Build or modify door info data before it is shown to players.</p>
<p>When a door is targeted and info lines are generated.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Door entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">doorData</span> Data about owners, titles, etc.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">doorInfo</span> Display lines; modify to add/remove fields.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDoorInfo", "ExampleGetDoorInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetDoorInfoForAdminStick></a>GetDoorInfoForAdminStick(target, extraInfo)</summary>
<a id="getdoorinfoforadminstick"></a>
<p>Supply extra admin-only door info shown in the admin stick UI.</p>
<p>When the admin stick inspects a door and builds its detail view.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">target</span> Door or entity being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">extraInfo</span> Table of strings to display; append data here.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetDoorInfoForAdminStick", "ExampleGetDoorInfoForAdminStick", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetInjuredText></a>GetInjuredText(c)</summary>
<a id="getinjuredtext"></a>
<p>Return the localized injury descriptor and color for a player.</p>
<p>When drawing player info overlays that show health status.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">c</span> Target player.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> `{text, color}` describing injury level, or nil to skip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetInjuredText", "ExampleGetInjuredText", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetMainCharacterID></a>GetMainCharacterID()</summary>
<a id="getmaincharacterid"></a>
<p>Decide which character ID should be treated as the “main” one for menus.</p>
<p>Before selecting or loading the default character in the main menu.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> Character ID to treat as primary, or nil for default logic.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetMainCharacterID", "ExampleGetMainCharacterID", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=GetMainMenuPosition></a>GetMainMenuPosition(character)</summary>
<a id="getmainmenuposition"></a>
<p>Provide camera position/angles for the 3D main menu scene.</p>
<p>Each time the main menu loads and needs a camera transform.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> Character to base the position on.</p>

<p><h3>Returns:</h3>
Vector, Angle Position and angle to use; return nils to use defaults.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("GetMainMenuPosition", "ExampleGetMainMenuPosition", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InteractionMenuClosed></a>InteractionMenuClosed()</summary>
<a id="interactionmenuclosed"></a>
<p>Handle logic when the interaction menu (context quick menu) closes.</p>
<p>Right after the interaction menu panel is removed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InteractionMenuClosed", "ExampleInteractionMenuClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InteractionMenuOpened></a>InteractionMenuOpened(frame)</summary>
<a id="interactionmenuopened"></a>
<p>Set up the interaction menu when it is created.</p>
<p>Immediately after the interaction menu frame is instantiated.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">frame</span> The interaction menu frame.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InteractionMenuOpened", "ExampleInteractionMenuOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InterceptClickItemIcon></a>InterceptClickItemIcon(inventoryPanel, itemIcon, keyCode)</summary>
<a id="interceptclickitemicon"></a>
<p>Intercept mouse/keyboard clicks on an inventory item icon.</p>
<p>Whenever an inventory icon receives an input event.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">inventoryPanel</span> Panel hosting the inventory grid.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">itemIcon</span> Icon that was clicked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">keyCode</span> Mouse or keyboard code that triggered the event.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true to consume the click and prevent default behavior.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InterceptClickItemIcon", "ExampleInterceptClickItemIcon", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InventoryClosed></a>InventoryClosed(inventoryPanel, inventory)</summary>
<a id="inventoryclosed"></a>
<p>React when an inventory window is closed.</p>
<p>Immediately after an inventory panel is removed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">inventoryPanel</span> The panel that was closed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory instance tied to the panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryClosed", "ExampleInventoryClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InventoryItemDataChanged></a>InventoryItemDataChanged(item, key, oldValue, newValue, inventory)</summary>
<a id="inventoryitemdatachanged"></a>
<p>Respond to item data changes that arrive on the client.</p>
<p>After an item’s data table updates (networked from the server).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> The item that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Data key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">newValue</span> New value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory containing the item.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryItemDataChanged", "ExampleInventoryItemDataChanged", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InventoryItemIconCreated></a>InventoryItemIconCreated(icon, item, inventoryPanel)</summary>
<a id="inventoryitemiconcreated"></a>
<p>Customize an inventory item icon immediately after it is created.</p>
<p>When a new icon panel is spawned for an item.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">icon</span> Icon panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item represented by the icon.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">inventoryPanel</span> Parent inventory panel.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryItemIconCreated", "ExampleInventoryItemIconCreated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InventoryOpened></a>InventoryOpened(panel, inventory)</summary>
<a id="inventoryopened"></a>
<p>Handle logic after an inventory panel is opened.</p>
<p>When an inventory is displayed on screen.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Inventory panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryOpened", "ExampleInventoryOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=InventoryPanelCreated></a>InventoryPanelCreated(panel, inventory, parent)</summary>
<a id="inventorypanelcreated"></a>
<p>Customize the inventory panel when it is created.</p>
<p>Immediately after constructing a panel for an inventory.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> The new inventory panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory</span> Inventory the panel represents.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">parent</span> Parent container.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("InventoryPanelCreated", "ExampleInventoryPanelCreated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ItemDraggedOutOfInventory></a>ItemDraggedOutOfInventory(client, item)</summary>
<a id="itemdraggedoutofinventory"></a>
<p>Handle dragging an item outside of an inventory grid.</p>
<p>When an item is released outside valid slots.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player performing the drag.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item being dragged.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemDraggedOutOfInventory", "ExampleItemDraggedOutOfInventory", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ItemPaintOver></a>ItemPaintOver(itemIcon, itemTable, w, h)</summary>
<a id="itempaintover"></a>
<p>Draw overlays on an item’s icon (e.g., status markers).</p>
<p>During icon paint for each inventory slot.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">itemIcon</span> Icon panel being drawn.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">itemTable</span> Item represented.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> Icon width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> Icon height.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemPaintOver", "ExampleItemPaintOver", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ItemShowEntityMenu></a>ItemShowEntityMenu(entity)</summary>
<a id="itemshowentitymenu"></a>
<p>Show a context menu for a world item entity.</p>
<p>When the use key/menu key is pressed on a dropped item with actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Item entity in the world.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ItemShowEntityMenu", "ExampleItemShowEntityMenu", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=LoadCharInformation></a>LoadCharInformation()</summary>
<a id="loadcharinformation"></a>
<p>Seed the character information sections for the F1 menu.</p>
<p>When the character info is about to be populated.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("LoadCharInformation", "ExampleLoadCharInformation", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=LoadMainCharacter></a>LoadMainCharacter()</summary>
<a id="loadmaincharacter"></a>
<p>Select and load the player’s main character when the menu opens.</p>
<p>During main menu initialization if a saved main character exists.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("LoadMainCharacter", "ExampleLoadMainCharacter", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=LoadMainMenuInformation></a>LoadMainMenuInformation(info, character)</summary>
<a id="loadmainmenuinformation"></a>
<p>Populate informational text and preview for the main menu character card.</p>
<p>When the main menu needs to show summary info for a character.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">info</span> Table to fill with display fields.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Character</a></span> <span class="parameter">character</span> Character being previewed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("LoadMainMenuInformation", "ExampleLoadMainMenuInformation", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ModifyScoreboardModel></a>ModifyScoreboardModel(arg1, ply)</summary>
<a id="modifyscoreboardmodel"></a>
<p>Adjust the 3D model used in the scoreboard (pose, skin, etc.).</p>
<p>When a scoreboard slot builds its player model preview.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">arg1</span> Model panel or data table for the slot.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player represented by the slot.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ModifyScoreboardModel", "ExampleModifyScoreboardModel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ModifyVoiceIndicatorText></a>ModifyVoiceIndicatorText(client, voiceText, voiceType)</summary>
<a id="modifyvoiceindicatortext"></a>
<p>Override the string shown in the voice indicator HUD.</p>
<p>Each frame the local player is speaking.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Speaking player (local).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">voiceText</span> Default text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">voiceType</span> Current voice range (“whispering”, “talking”, “yelling”).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Replacement text; return nil to keep default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ModifyVoiceIndicatorText", "ExampleModifyVoiceIndicatorText", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawPlayerInfoBackground></a>DrawPlayerInfoBackground()</summary>
<a id="drawplayerinfobackground"></a>
<p>Draw the background panel behind player info overlays.</p>
<p>Just before drawing wrapped player info text in the HUD.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Return false to suppress the default blurred background.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawPlayerInfoBackground", "ExampleDrawPlayerInfoBackground", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnAdminStickMenuClosed></a>OnAdminStickMenuClosed()</summary>
<a id="onadminstickmenuclosed"></a>
<p>Handle state cleanup when the admin stick menu closes.</p>
<p>When the admin stick UI window is removed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnAdminStickMenuClosed", "ExampleOnAdminStickMenuClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnChatReceived></a>OnChatReceived(client, chatType, text, anonymous)</summary>
<a id="onchatreceived"></a>
<p>React to chat messages received by the local client.</p>
<p>After a chat message is parsed and before it is displayed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Sender of the message.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Message content.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">anonymous</span> Whether the message should hide the sender.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnChatReceived", "ExampleOnChatReceived", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnCreateDualInventoryPanels></a>OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)</summary>
<a id="oncreatedualinventorypanels"></a>
<p>Customize paired inventory panels when two inventories are shown side by side.</p>
<p>Right after both inventory panels are created (e.g., player + storage).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel1</span> First inventory panel.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel2</span> Second inventory panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory1</span> Inventory bound to panel1.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Inventory</a></span> <span class="parameter">inventory2</span> Inventory bound to panel2.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnCreateDualInventoryPanels", "ExampleOnCreateDualInventoryPanels", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnCreateItemInteractionMenu></a>OnCreateItemInteractionMenu(itemIcon, menu, itemTable)</summary>
<a id="oncreateiteminteractionmenu"></a>
<p>Augment the context menu shown when right-clicking an inventory item icon.</p>
<p>Immediately after the interaction menu for an item icon is built.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">itemIcon</span> The icon being interacted with.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">menu</span> The context menu object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">itemTable</span> Item associated with the icon.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnCreateItemInteractionMenu", "ExampleOnCreateItemInteractionMenu", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnCreateStoragePanel></a>OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)</summary>
<a id="oncreatestoragepanel"></a>
<p>Customize the dual-inventory storage panel layout.</p>
<p>After the local and storage inventory panels are created for a storage entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">localInvPanel</span> Panel showing the player inventory.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">storageInvPanel</span> Panel showing the storage inventory.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">storage</span> Storage object or entity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnCreateStoragePanel", "ExampleOnCreateStoragePanel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnLocalVarSet></a>OnLocalVarSet(key, value)</summary>
<a id="onlocalvarset"></a>
<p>React to a local networked variable being set.</p>
<p>Whenever a net var assigned to the local player changes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Variable name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">value</span> New value.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnLocalVarSet", "ExampleOnLocalVarSet", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnOpenVendorMenu></a>OnOpenVendorMenu(vendorPanel, vendor)</summary>
<a id="onopenvendormenu"></a>
<p>Populate the vendor UI when it opens.</p>
<p>After the vendor panel is created client-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">vendorPanel</span> Panel used to display vendor goods.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">vendor</span> Vendor entity interacted with.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnOpenVendorMenu", "ExampleOnOpenVendorMenu", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnlineStaffDataReceived></a>OnlineStaffDataReceived(staffData)</summary>
<a id="onlinestaffdatareceived"></a>
<p>Handle the list of online staff received from the server.</p>
<p>When staff data is synchronized to the client.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">staffData</span> Array of staff entries (name, steamID, duty status).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnlineStaffDataReceived", "ExampleOnlineStaffDataReceived", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OpenAdminStickUI></a>OpenAdminStickUI(tgt)</summary>
<a id="openadminstickui"></a>
<p>Open the admin stick interface for a target entity or player.</p>
<p>When the admin stick weapon requests to show its UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">tgt</span> Target entity/player selected by the admin stick.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OpenAdminStickUI", "ExampleOpenAdminStickUI", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PaintItem></a>PaintItem(item)</summary>
<a id="paintitem"></a>
<p>Draw or tint an item icon before it is painted to the grid.</p>
<p>Prior to rendering each item icon surface.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Item</a></span> <span class="parameter">item</span> Item being drawn.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PaintItem", "ExamplePaintItem", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PopulateAdminStick></a>PopulateAdminStick(currentMenu, currentTarget, currentStores)</summary>
<a id="populateadminstick"></a>
<p>Add tabs and actions to the admin stick UI.</p>
<p>While constructing the admin stick menu for the current target.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">currentMenu</span> Root menu panel.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">currentTarget</span> Entity being acted upon.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">currentStores</span> Cached admin stick data (lists, categories).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PopulateAdminStick", "ExamplePopulateAdminStick", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PopulateAdminTabs></a>PopulateAdminTabs(pages)</summary>
<a id="populateadmintabs"></a>
<p>Register admin tabs for the F1 administration menu.</p>
<p>When building the admin tab list.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">pages</span> Table to append tab definitions `{name, icon, build=function}`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PopulateAdminTabs", "ExamplePopulateAdminTabs", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PopulateConfigurationButtons></a>PopulateConfigurationButtons(pages)</summary>
<a id="populateconfigurationbuttons"></a>
<p>Add configuration buttons for the options/configuration tab.</p>
<p>When creating the configuration pages in the menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">pages</span> Collection of page descriptors to populate.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PopulateConfigurationButtons", "ExamplePopulateConfigurationButtons", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PopulateFactionRosterOptions></a>PopulateFactionRosterOptions(list, members)</summary>
<a id="populatefactionrosteroptions"></a>
<p>Add custom menu options to the faction roster table.</p>
<p>When the faction roster UI is being populated with member data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">list</span> The liaTable panel that displays the roster. Use list:AddMenuOption() to add right-click menu options.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">members</span> Array of member data tables containing name, charID, steamID, and lastOnline fields.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PopulateFactionRosterOptions", "MyCustomRosterOptions", function(list, members)
        list:AddMenuOption("View Profile", function(rowData)
            if rowData and rowData.charID then
                print("Viewing profile for character ID:", rowData.charID)
            end
        end, "icon16/user.png")
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PopulateInventoryItems></a>PopulateInventoryItems(pnlContent, tree)</summary>
<a id="populateinventoryitems"></a>
<p>Populate the inventory items tree used in the admin menu.</p>
<p>When the inventory item browser is built.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">pnlContent</span> Content panel to fill.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">tree</span> Tree/list control to populate.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PopulateInventoryItems", "ExamplePopulateInventoryItems", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PostDrawInventory></a>PostDrawInventory(mainPanel, parentPanel)</summary>
<a id="postdrawinventory"></a>
<p>Draw additional UI after the main inventory panels are painted.</p>
<p>After inventory drawing completes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">mainPanel</span> Primary inventory panel.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">parentPanel</span> Parent container.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PostDrawInventory", "ExamplePostDrawInventory", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=PostLoadFonts></a>PostLoadFonts(mainFont, mainFont)</summary>
<a id="postloadfonts"></a>
<p>Adjust fonts after they are loaded.</p>
<p>Immediately after main fonts are initialized.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">mainFont</span> Primary font name (duplicate parameter kept for API compatibility).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">mainFont</span> Alias of the same font name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PostLoadFonts", "ExamplePostLoadFonts", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawPhysgunBeam></a>DrawPhysgunBeam()</summary>
<a id="drawphysgunbeam"></a>
<p>Decide whether to draw the physgun beam for the local player.</p>
<p>During physgun render.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to suppress the beam; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawPhysgunBeam", "ExampleDrawPhysgunBeam", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=RefreshFonts></a>RefreshFonts()</summary>
<a id="refreshfonts"></a>
<p>Recreate or refresh fonts when settings change.</p>
<p>After option changes that impact font sizes or faces.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("RefreshFonts", "ExampleRefreshFonts", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=RegisterAdminStickSubcategories></a>RegisterAdminStickSubcategories(categories)</summary>
<a id="registeradminsticksubcategories"></a>
<p>Register admin stick subcategories used to group commands.</p>
<p>When assembling the category tree for the admin stick.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">categories</span> Table of category -> subcategory mappings; modify in place.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("RegisterAdminStickSubcategories", "ExampleRegisterAdminStickSubcategories", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ResetCharacterPanel></a>ResetCharacterPanel()</summary>
<a id="resetcharacterpanel"></a>
<p>Reset the character panel to its initial state.</p>
<p>When the character menu needs to clear cached data/layout.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ResetCharacterPanel", "ExampleResetCharacterPanel", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=RunAdminSystemCommand></a>RunAdminSystemCommand(cmd, admin, victim, dur, reason)</summary>
<a id="runadminsystemcommand"></a>
<p>Execute an admin-system command initiated from the UI.</p>
<p>When the admin stick or admin menu triggers a command.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">cmd</span> Command identifier.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">admin</span> Admin issuing the command.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|Player</a></span> <span class="parameter">victim</span> Target of the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">dur</span> Duration parameter if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">reason</span> Optional reason text.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("RunAdminSystemCommand", "ExampleRunAdminSystemCommand", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ScoreboardClosed></a>ScoreboardClosed(scoreboardPanel)</summary>
<a id="scoreboardclosed"></a>
<p>Perform teardown when the scoreboard closes.</p>
<p>After the scoreboard panel is hidden or destroyed.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">scoreboardPanel</span> The scoreboard instance that was closed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ScoreboardClosed", "ExampleScoreboardClosed", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ScoreboardOpened></a>ScoreboardOpened(scoreboardPanel)</summary>
<a id="scoreboardopened"></a>
<p>Initialize the scoreboard after it is created.</p>
<p>Right after the scoreboard panel is shown.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">scoreboardPanel</span> The scoreboard instance that opened.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ScoreboardOpened", "ExampleScoreboardOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ScoreboardRowCreated></a>ScoreboardRowCreated(slot, ply)</summary>
<a id="scoreboardrowcreated"></a>
<p>Customize a newly created scoreboard row.</p>
<p>When a player slot is added to the scoreboard.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">slot</span> Scoreboard row panel.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player represented by the row.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ScoreboardRowCreated", "ExampleScoreboardRowCreated", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ScoreboardRowRemoved></a>ScoreboardRowRemoved(scoreboardPanel, ply)</summary>
<a id="scoreboardrowremoved"></a>
<p>React when a scoreboard row is removed.</p>
<p>When a player leaves or is otherwise removed from the scoreboard.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">scoreboardPanel</span> Scoreboard instance.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player whose row was removed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ScoreboardRowRemoved", "ExampleScoreboardRowRemoved", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetMainCharacter></a>SetMainCharacter(charID)</summary>
<a id="setmaincharacter"></a>
<p>Set the main character ID for future automatic selection.</p>
<p>When the player chooses a character to become their main.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> Chosen character ID.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("SetMainCharacter", "ExampleSetMainCharacter", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=SetupQuickMenu></a>SetupQuickMenu(quickMenuPanel)</summary>
<a id="setupquickmenu"></a>
<p>Build the quick access menu when the context menu opens.</p>
<p>After the quick menu panel is created.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">quickMenuPanel</span> Panel that holds quick actions.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("SetupQuickMenu", "ExampleSetupQuickMenu", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldAllowScoreboardOverride></a>ShouldAllowScoreboardOverride(client, var)</summary>
<a id="shouldallowscoreboardoverride"></a>
<p>Decide if a player is permitted to override the scoreboard UI.</p>
<p>Before applying any scoreboard override logic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting the override.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">any</a></span> <span class="parameter">var</span> Additional context or override data.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to deny override; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldAllowScoreboardOverride", "ExampleShouldAllowScoreboardOverride", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldBarDraw></a>ShouldBarDraw(bar)</summary>
<a id="shouldbardraw"></a>
<p>Determine whether a HUD bar should render.</p>
<p>When evaluating each registered bar before drawing.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">bar</span> Bar definition.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide the bar; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldBarDraw", "ExampleShouldBarDraw", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldDisableThirdperson></a>ShouldDisableThirdperson(client)</summary>
<a id="shoulddisablethirdperson"></a>
<p>Decide whether third-person mode should be forcibly disabled.</p>
<p>When the third-person toggle state changes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player toggling third person.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to block third-person; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldDisableThirdperson", "ExampleShouldDisableThirdperson", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldDrawAmmo></a>ShouldDrawAmmo(wpn)</summary>
<a id="shoulddrawammo"></a>
<p>Let modules veto drawing the ammo HUD for a weapon.</p>
<p>Each HUDPaint frame before ammo boxes render.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Weapon">Weapon</a></span> <span class="parameter">wpn</span> Active weapon.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide ammo; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldDrawAmmo", "ExampleShouldDrawAmmo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldDrawEntityInfo></a>ShouldDrawEntityInfo(e)</summary>
<a id="shoulddrawentityinfo"></a>
<p>Control whether an entity should display info when looked at.</p>
<p>When deciding if entity info overlays should be generated.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">e</span> Entity under consideration.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to prevent info; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldDrawEntityInfo", "ExampleShouldDrawEntityInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldDrawPlayerInfo></a>ShouldDrawPlayerInfo(e)</summary>
<a id="shoulddrawplayerinfo"></a>
<p>Decide whether player-specific info should be drawn for a target.</p>
<p>Before rendering the player info panel above a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">e</span> Player entity being drawn.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide info; nil/true to draw.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldDrawPlayerInfo", "ExampleShouldDrawPlayerInfo", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldDrawWepSelect></a>ShouldDrawWepSelect(client)</summary>
<a id="shoulddrawwepselect"></a>
<p>Decide if the custom weapon selector should draw for a player.</p>
<p>Each frame the selector evaluates visibility.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Local player.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide the selector; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldDrawWepSelect", "ExampleShouldDrawWepSelect", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldHideBars></a>ShouldHideBars()</summary>
<a id="shouldhidebars"></a>
<p>Hide all HUD bars based on external conditions.</p>
<p>Before drawing any bars on the HUD.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true to hide all bars; nil/false to render them.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldHideBars", "ExampleShouldHideBars", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldMenuButtonShow></a>ShouldMenuButtonShow(arg1)</summary>
<a id="shouldmenubuttonshow"></a>
<p>Decide whether a button should appear in the menu bar.</p>
<p>When building quick menu buttons.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|string</a></span> <span class="parameter">arg1</span> Button identifier or data.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldMenuButtonShow", "ExampleShouldMenuButtonShow", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldRespawnScreenAppear></a>ShouldRespawnScreenAppear()</summary>
<a id="shouldrespawnscreenappear"></a>
<p>Control whether the respawn screen should be displayed.</p>
<p>When the client dies and the respawn UI might show.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to suppress; nil/true to display.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldRespawnScreenAppear", "ExampleShouldRespawnScreenAppear", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldShowCharVarInCreation></a>ShouldShowCharVarInCreation(key)</summary>
<a id="shouldshowcharvarincreation"></a>
<p>Determine if a character variable should appear in the creation form.</p>
<p>While assembling the list of editable character variables.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">key</span> Character variable identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldShowCharVarInCreation", "ExampleShouldShowCharVarInCreation", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldShowClassOnScoreboard></a>ShouldShowClassOnScoreboard(clsData)</summary>
<a id="shouldshowclassonscoreboard"></a>
<p>Decide whether to display a player’s class on the scoreboard.</p>
<p>When rendering scoreboard rows that include class info.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">clsData</span> Class data table for the player.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide class; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldShowClassOnScoreboard", "ExampleShouldShowClassOnScoreboard", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldShowFactionOnScoreboard></a>ShouldShowFactionOnScoreboard(ply)</summary>
<a id="shouldshowfactiononscoreboard"></a>
<p>Decide whether to display a player’s faction on the scoreboard.</p>
<p>When rendering a scoreboard row.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player being displayed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to hide faction; nil/true to show.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldShowFactionOnScoreboard", "ExampleShouldShowFactionOnScoreboard", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldShowPlayerOnScoreboard></a>ShouldShowPlayerOnScoreboard(ply)</summary>
<a id="shouldshowplayeronscoreboard"></a>
<p>Decide whether a player should appear on the scoreboard at all.</p>
<p>Before adding a player row to the scoreboard.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> Player under consideration.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to omit the player; nil/true to include.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldShowPlayerOnScoreboard", "ExampleShouldShowPlayerOnScoreboard", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShouldShowQuickMenu></a>ShouldShowQuickMenu()</summary>
<a id="shouldshowquickmenu"></a>
<p>Control whether the quick menu should open when the context menu is toggled.</p>
<p>When the context menu is opened.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> false to prevent quick menu creation; nil/true to allow.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShouldShowQuickMenu", "ExampleShouldShowQuickMenu", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ShowPlayerOptions></a>ShowPlayerOptions(target, options)</summary>
<a id="showplayeroptions"></a>
<p>Populate the options menu for a specific player (e.g., mute, profile).</p>
<p>When opening a player interaction context menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">target</span> Player the options apply to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> Table of options to display; modify in place.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ShowPlayerOptions", "ExampleShowPlayerOptions", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=StorageOpen></a>StorageOpen(storage, isCar)</summary>
<a id="storageopen"></a>
<p>Handle the client opening a storage entity inventory.</p>
<p>When storage access is approved and panels are about to show.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">storage</span> Storage entity or custom storage table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">isCar</span> True if the storage is a vehicle trunk.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("StorageOpen", "ExampleStorageOpen", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=StorageUnlockPrompt></a>StorageUnlockPrompt(entity)</summary>
<a id="storageunlockprompt"></a>
<p>Prompt the player to unlock a locked storage entity.</p>
<p>When the client interacts with a locked storage container.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Storage entity requiring an unlock prompt.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("StorageUnlockPrompt", "ExampleStorageUnlockPrompt", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=ThirdPersonToggled></a>ThirdPersonToggled(arg1)</summary>
<a id="thirdpersontoggled"></a>
<p>React when the third-person toggle state changes.</p>
<p>After third-person mode is turned on or off.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">arg1</span> New third-person enabled state.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("ThirdPersonToggled", "ExampleThirdPersonToggled", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=TooltipInitialize></a>TooltipInitialize(var, panel)</summary>
<a id="tooltipinitialize"></a>
<p>Initialize tooltip contents and sizing for Lilia tooltips.</p>
<p>When a tooltip panel is created.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Source panel that spawned the tooltip.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("TooltipInitialize", "ExampleTooltipInitialize", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=TooltipLayout></a>TooltipLayout(var)</summary>
<a id="tooltiplayout"></a>
<p>Control tooltip layout; return true to keep the custom layout.</p>
<p>Each frame the tooltip is laid out.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if a custom layout was applied.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("TooltipLayout", "ExampleTooltipLayout", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=TooltipPaint></a>TooltipPaint(var, w, h)</summary>
<a id="tooltippaint"></a>
<p>Paint the custom tooltip background and contents.</p>
<p>When a tooltip panel is drawn.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">var</span> Tooltip panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> Width.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> Height.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the tooltip was fully painted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("TooltipPaint", "ExampleTooltipPaint", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=VendorExited></a>VendorExited()</summary>
<a id="vendorexited"></a>
<p>Handle logic when exiting a vendor menu.</p>
<p>After the vendor UI is closed.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("VendorExited", "ExampleVendorExited", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=VendorOpened></a>VendorOpened(vendor)</summary>
<a id="vendoropened"></a>
<p>Perform setup when a vendor menu opens.</p>
<p>Immediately after opening the vendor UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">vendor</span> Vendor being accessed.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("VendorOpened", "ExampleVendorOpened", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=VoiceToggled></a>VoiceToggled(enabled)</summary>
<a id="voicetoggled"></a>
<p>Respond to voice chat being toggled on or off.</p>
<p>When the client enables or disables in-game voice.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">enabled</span> New voice toggle state.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("VoiceToggled", "ExampleVoiceToggled", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=WeaponCycleSound></a>WeaponCycleSound()</summary>
<a id="weaponcyclesound"></a>
<p>Play a custom sound when cycling weapons.</p>
<p>When the weapon selector changes selection.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Sound path to play; nil to use default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("WeaponCycleSound", "ExampleWeaponCycleSound", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=WeaponSelectSound></a>WeaponSelectSound()</summary>
<a id="weaponselectsound"></a>
<p>Play a sound when confirming weapon selection.</p>
<p>When the weapon selector picks the highlighted weapon.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|nil</a></span> Sound path to play; nil for default.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("WeaponSelectSound", "ExampleWeaponSelectSound", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=WebImageDownloaded></a>WebImageDownloaded(n, arg2)</summary>
<a id="webimagedownloaded"></a>
<p>Handle a downloaded web image asset.</p>
<p>After a remote image finishes downloading.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">n</span> Image identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">arg2</span> Local path or URL of the image.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("WebImageDownloaded", "ExampleWebImageDownloaded", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=WebSoundDownloaded></a>WebSoundDownloaded(name, path)</summary>
<a id="websounddownloaded"></a>
<p>Handle a downloaded web sound asset.</p>
<p>After a remote sound file is fetched.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Sound identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">path</span> Local file path where the sound was saved.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("WebSoundDownloaded", "ExampleWebSoundDownloaded", function(...)
        -- add custom client-side behavior
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=DrawESPStyledText></a>DrawESPStyledText(text, x, y, espColor, font, fadeAlpha)</summary>
<a id="drawespstyledtext"></a>
<p>Draws a styled text box with a background and a colored accent bar at the bottom, typically used for ESP displays.</p>
<p>Whenever an ESP element or specialized screen text needs to be rendered with the Lilia signature style.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> The text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">x</span> The X-coordinate on the screen center.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">y</span> The Y-coordinate on the screen top.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">espColor</span> The color of the accent bar at the bottom.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">font</span> The font to use for the text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">fadeAlpha</span> The opacity scale (0 to 1) for the entire element.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> The total height (bh) of the drawn box, including padding.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("DrawESPStyledText", "ExampleESP", function(text, x, y, color, font, alpha)
        -- custom ESP drawing logic
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=OnModelPanelSetup></a>OnModelPanelSetup(self)</summary>
<a id="onmodelpanelsetup"></a>
<p>Called after a liaModelPanel has been initialized and its model has been set.</p>
<p>During the SetModel process of a liaModelPanel, after the entity is created and sequences are initialized.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">self</span> The liaModelPanel instance that was set up.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("OnModelPanelSetup", "CustomizeModelPanel", function(panel)
        panel:SetFOV(45)
    end)
</code></pre>
</details>

---

