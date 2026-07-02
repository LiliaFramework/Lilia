<style>
details > summary {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 70px;
    padding-right: 180px;
}

details > summary .summary-main {
    min-width: 0;
}

details > summary .source-link-button--summary {
    position: absolute;
    right: 56px;
    top: 50%;
    transform: translateY(-50%);
    white-space: nowrap;
    z-index: 2;
}
</style>

# Recognition

This page documents the hooks defined by the recognition module.

---

<details class="realm-server" id="function-charforcerecognized">
<summary><span class="summary-main"><a id="CharForceRecognized"></a>CharForceRecognized(ply, range)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/recognition/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charforcerecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after the recognition system force-recognizes nearby players for a speaker.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Recognition</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">ply</span> The player who triggered forced recognition.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">range</span> The recognition range key that was used, such as `whisper`, `normal`, `talk`, or `yell`.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-isrecognizedchattype">
<summary><span class="summary-main"><a id="IsRecognizedChatType"></a>IsRecognizedChatType(chatType)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/recognition/module.lua#L24" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="isrecognizedchattype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets code mark additional chat types as recognized chat for unknown-name masking.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Recognition</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> The chat class unique ID being checked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return true to treat the chat type as recognition-sensitive.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-oncharrecognized">
<summary><span class="summary-main"><a id="OnCharRecognized"></a>OnCharRecognized(ply)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/recognition/module.lua#L45" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharrecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a player recognizes another character through the recognition system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Recognition</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client / Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">ply</span> The player whose recognition data was updated.</p>
</div>

</div>
</details>

---

