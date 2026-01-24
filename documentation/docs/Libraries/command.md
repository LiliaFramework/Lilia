# Commands Library

Comprehensive command registration, parsing, and execution system for the Lilia framework.

---

Overview

The commands library provides comprehensive functionality for managing and executing commands in the Lilia framework. It handles command registration, argument parsing, access control, privilege management, and command execution across both server and client sides. The library supports complex argument types including players, booleans, strings, and tables, with automatic syntax generation and validation. It integrates with the administrator system for privilege-based access control and provides user interface elements for command discovery and argument prompting. The library ensures secure command execution with proper permission checks and logging capabilities.

---

<details class="realm-shared">
<summary><a id=lia.command.buildSyntaxFromArguments></a>lia.command.buildSyntaxFromArguments(args)</summary>
<a id="liacommandbuildsyntaxfromarguments"></a>
<p>Generate a human-readable syntax string from a list of argument definitions.</p>
<p>During command registration to populate data.syntax for menus and help text.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">args</span> Array of argument tables {name=, type=, optional=}.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Concatenated syntax tokens describing the command arguments.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local syntax = lia.command.buildSyntaxFromArguments({
        {name = "target", type = "player"},
        {name = "amount", type = "number", optional = true}
    })
    -- "[player target] [string amount optional]"
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.command.add></a>lia.command.add(command, data)</summary>
<a id="liacommandadd"></a>
<p>Register a command and normalize its metadata, syntax, privileges, aliases, and callbacks.</p>
<p>During schema or module initialization to expose new chat/console commands.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Unique command key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Command definition (arguments, desc, privilege, superAdminOnly, adminOnly, alias, onRun, onCheckAccess, etc.).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.command.add("bring", {
        desc = "Bring a player to you.",
        adminOnly = true,
        arguments = {
            {name = "target", type = "player"}
        },
        onRun = function(client, args)
            local target = lia.command.findPlayer(args[1])
            if IsValid(target) then target:SetPos(client:GetPos() + client:GetForward() * 50) end
        end
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.command.hasAccess></a>lia.command.hasAccess(client, command, data)</summary>
<a id="liacommandhasaccess"></a>
<p>Determine whether a client may run a command based on privileges, hooks, faction/class access, and custom checks.</p>
<p>Before executing a command or showing it in help menus.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player requesting access.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Command name to check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> <span class="optional">optional</span> Command definition; looked up from lia.command.list when nil.</p>

<p><h3>Returns:</h3>
boolean, string allowed result and privilege name for UI/feedback.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local canUse, priv = lia.command.hasAccess(ply, "bring")
    if not canUse then ply:notifyErrorLocalized("noPerm") end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.command.extractArgs></a>lia.command.extractArgs(text)</summary>
<a id="liacommandextractargs"></a>
<p>Split a raw command string into arguments while preserving quoted segments.</p>
<p>When parsing chat-entered commands before validation or prompting.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Raw command text excluding the leading slash.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of parsed arguments.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local args = lia.command.extractArgs("'John Doe' 250")
    -- {"John Doe", "250"}
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.command.run></a>lia.command.run(client, command, arguments)</summary>
<a id="liacommandrun"></a>
<p>Execute a registered command for a given client with arguments and emit post-run hooks.</p>
<p>After parsing chat input or console invocation server-side.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player that issued the command (nil when run from server console).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Command key to execute.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arguments</span> <span class="optional">optional</span> Parsed command arguments.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.command.run(ply, "bring", {targetSteamID})
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.command.parse></a>lia.command.parse(client, text, realCommand, arguments, Pre, Pre)</summary>
<a id="liacommandparse"></a>
<p>Parse chat text into a command invocation, prompt for missing args, and dispatch authorized commands.</p>
<p>On the server when a player sends chat starting with '/' or when manually dispatching a command.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose chat is being parsed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Full chat text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">realCommand</span> <span class="optional">optional</span> Command key when bypassing parsing (used by net/message dispatch).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">arguments</span> <span class="optional">optional</span> Pre-parsed arguments; when nil they are derived from text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Pre</span> parsed arguments; when nil they are derived from text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Pre</span> parsed arguments; when nil they are derived from text.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the text was handled as a command.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerSay", "liaChatCommands", function(ply, text)
        if lia.command.parse(ply, text) then return "" end
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.command.openArgumentPrompt></a>lia.command.openArgumentPrompt(cmdKey, missing, prefix)</summary>
<a id="liacommandopenargumentprompt"></a>
<p>Display a clientside UI prompt for missing command arguments and send the completed command back through chat.</p>
<p>After the server requests argument completion via the liaCmdArgPrompt net message.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">cmdKey</span> Command key being completed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">missing</span> Names of missing arguments.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">prefix</span> <span class="optional">optional</span> Prefilled argument values.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.command.openArgumentPrompt("pm", {"target", "message"}, {"steamid"})
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.command.send></a>lia.command.send(command)</summary>
<a id="liacommandsend"></a>
<p>Send a command invocation to the server via net as a clientside helper.</p>
<p>From UI elements or client logic instead of issuing chat/console commands directly.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">command</span> Command key to invoke.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.command.send("respawn", LocalPlayer():SteamID())
</code></pre>
</details>

---

