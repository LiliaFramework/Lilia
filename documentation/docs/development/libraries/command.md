# Commands

Comprehensive command registration, parsing, and execution system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The commands library provides comprehensive functionality for managing and executing commands in the Lilia framework. It handles command registration, argument parsing, access control, privilege management, and command execution across both server and client sides. The library supports complex argument types including players, booleans, strings, and tables, with automatic syntax generation and validation. It integrates with the administrator system for privilege-based access control and provides user interface elements for command discovery and argument prompting. The library ensures secure command execution with proper permission checks and logging capabilities.
</div>

---

<details class="realm-shared" id="function-liacommandbuildsyntaxfromarguments">
<summary><a id="lia.command.buildSyntaxFromArguments"></a>lia.command.buildSyntaxFromArguments(args)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandbuildsyntaxfromarguments"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Generate a human-readable syntax string from a list of argument definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During command registration to populate data.syntax for menus and help text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">args</span> Array of argument tables {name=, type=, optional=}.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> Concatenated syntax tokens describing the command arguments.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local syntax = lia.command.buildSyntaxFromArguments({
      {name = "target", type = "player"},
      {name = "amount", type = "number", optional = true}
  })
  -- "[player target] [string amount optional]"
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liacommandadd">
<summary><a id="lia.command.add"></a>lia.command.add(command, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a command and normalize its metadata, syntax, privileges, aliases, and callbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During schema or module initialization to expose new chat/console commands.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Unique command key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Command definition (arguments, desc, privilege, superAdminOnly, adminOnly, alias, onRun, onCheckAccess, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.command.add("bring", {
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
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liacommandhasaccess">
<summary><a id="lia.command.hasAccess"></a>lia.command.hasAccess(client, command, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandhasaccess"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine whether a client may run a command based on privileges, hooks, faction/class access, and custom checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before executing a command or showing it in help menus.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting access.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Command name to check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> <span class="optional">optional</span> Command definition; looked up from lia.command.list when nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string allowed result and privilege name for UI/feedback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local canUse, priv = lia.command.hasAccess(ply, "bring")
  if not canUse then ply:notifyErrorLocalized("noPerm") end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liacommandextractargs">
<summary><a id="lia.command.extractArgs"></a>lia.command.extractArgs(text)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandextractargs"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Split a raw command string into arguments while preserving quoted segments.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When parsing chat-entered commands before validation or prompting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> Raw command text excluding the leading slash.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Array of parsed arguments.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local args = lia.command.extractArgs("'John Doe' 250")
  -- {"John Doe", "250"}
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liacommandrun">
<summary><a id="lia.command.run"></a>lia.command.run(client, command, arguments)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandrun"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Execute a registered command for a given client with arguments and emit post-run hooks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After parsing chat input or console invocation server-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player that issued the command (nil when run from server console).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Command key to execute.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arguments</span> <span class="optional">optional</span> Parsed command arguments.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.command.run(ply, "bring", {targetSteamID})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liacommandparse">
<summary><a id="lia.command.parse"></a>lia.command.parse(client, text, realCommand, arguments, Pre, Pre)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandparse"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Parse chat text into a command invocation, prompt for missing args, and dispatch authorized commands.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On the server when a player sends chat starting with '/' or when manually dispatching a command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose chat is being parsed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">text</span> Full chat text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">realCommand</span> <span class="optional">optional</span> Command key when bypassing parsing (used by net/message dispatch).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arguments</span> <span class="optional">optional</span> Pre-parsed arguments; when nil they are derived from text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Pre</span> parsed arguments; when nil they are derived from text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Pre</span> parsed arguments; when nil they are derived from text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true if the text was handled as a command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerSay", "liaChatCommands", function(ply, text)
      if lia.command.parse(ply, text) then return "" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacommandopenargumentprompt">
<summary><a id="lia.command.openArgumentPrompt"></a>lia.command.openArgumentPrompt(cmdKey, missing, prefix)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandopenargumentprompt"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Display a clientside UI prompt for missing command arguments and send the completed command back through chat.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the server requests argument completion via the liaCmdArgPrompt net message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">cmdKey</span> Command key being completed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">missing</span> Names of missing arguments.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">prefix</span> <span class="optional">optional</span> Prefilled argument values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.command.openArgumentPrompt("pm", {"target", "message"}, {"steamid"})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liacommandsend">
<summary><a id="lia.command.send"></a>lia.command.send(command)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacommandsend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Send a command invocation to the server via net as a clientside helper.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From UI elements or client logic instead of issuing chat/console commands directly.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Command key to invoke.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.command.send("respawn", LocalPlayer():SteamID())
</code></pre>
</div>

</div>
</details>

---

