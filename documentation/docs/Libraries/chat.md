# Chatbox Library

Comprehensive chat system management with message routing and formatting for the Lilia framework.

---

Overview

The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework. It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing, distance-based hearing mechanics, and chat formatting. The library operates on both server and client sides, with the server managing message distribution and validation, while the client handles parsing and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based communication, and integration with the command system for chat-based commands.

---

<details class="realm-shared">
<summary><a id=lia.chat.timestamp></a>lia.chat.timestamp(ooc)</summary>
<a id="liachattimestamp"></a>
<p>Prepend a timestamp to chat messages based on option settings.</p>
<p>During chat display formatting (client) to show the time.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">ooc</span> Whether the chat is OOC (affects spacing).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Timestamp text or empty string.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    chat.AddText(lia.chat.timestamp(false), Color(255,255,255), message)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.chat.register></a>lia.chat.register(chatType, data)</summary>
<a id="liachatregister"></a>
<p>Register a chat class (IC/OOC/whisper/custom) with prefixes and rules.</p>
<p>On initialization to add new chat types and bind aliases/commands.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Fields: prefix, radius/onCanHear, onCanSay, format, color, arguments, etc.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.chat.register("yell", {
        prefix = {"/y", "/yell"},
        radius = 600,
        format = "chatYellFormat",
        arguments = {{name = "message", type = "string"}},
        onChatAdd = function(speaker, text) chat.AddText(Color(255,200,120), "[Y] ", speaker:Name(), ": ", text) end
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.chat.parse></a>lia.chat.parse(client, message, noSend)</summary>
<a id="liachatparse"></a>
<p>Parse a raw chat message to determine chat type, strip prefixes, and send.</p>
<p>On client (local send) and server (routing) before dispatching chat.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">message</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noSend</span> <span class="optional">optional</span> If true, do not forward to recipients (client-side parsing only).</p>

<p><h3>Returns:</h3>
string, string, boolean chatType, message, anonymous</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- client
    lia.chat.parse(LocalPlayer(), "/y Hello there!")
    -- server hook
    hook.Add("PlayerSay", "LiliaChatParse", function(ply, txt)
        if lia.chat.parse(ply, txt) then return "" end
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.chat.send></a>lia.chat.send(speaker, chatType, text, anonymous, receivers)</summary>
<a id="liachatsend"></a>
<p>Send a chat message to eligible listeners, honoring canHear/canSay rules.</p>
<p>Server-side after parsing chat or programmatic chat generation.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">speaker</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">chatType</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">anonymous</span></p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">receivers</span> <span class="optional">optional</span> Optional explicit receiver list.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.chat.send(ply, "ic", "Hello world", false)
</code></pre>
</details>

---

