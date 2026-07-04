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

# Notices

Notice helpers for sending, receiving, localizing, displaying, and routing Lilia notification messages.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The notices library centralizes notification delivery under `lia.notices`. Serverside calls send networked notices to one client or broadcast them to all players, while clientside calls build `liaNotice` panels, organize their screen positions, emit the notice sound, and print the message to the console. Localized helpers resolve language keys through `L` before using the normal notice pipeline.
</div>

---

<details class="realm-client" id="function-lianoticesreceivenotify">
<summary><span class="summary-main"><a id="lia.notices.receiveNotify"></a>lia.notices.receiveNotify()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L67" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesreceivenotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reads a networked notification payload and creates a clientside notice panel after running the notice override hook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  net.Receive("liaNotificationData", lia.notices.receiveNotify)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesreceivenotifyl">
<summary><span class="summary-main"><a id="lia.notices.receiveNotifyL"></a>lia.notices.receiveNotifyL()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L107" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesreceivenotifyl"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Reads a networked localized notification payload, resolves the language key, and creates a clientside notice panel after running the notice override hook.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  net.Receive("liaNotifyLocal", lia.notices.receiveNotifyL)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyinfolocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyInfoLocalized"></a>lia.notices.notifyInfoLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L161" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyinfolocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized info notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyInfoLocalized(nil, "noticeSaved")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifywarninglocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyWarningLocalized"></a>lia.notices.notifyWarningLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L190" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifywarninglocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized warning notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyWarningLocalized(nil, "noticeWarning")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyerrorlocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyErrorLocalized"></a>lia.notices.notifyErrorLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L219" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyerrorlocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized error notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyErrorLocalized(nil, "noticeError")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifysuccesslocalized">
<summary><span class="summary-main"><a id="lia.notices.notifySuccessLocalized"></a>lia.notices.notifySuccessLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L248" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifysuccesslocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized success notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifySuccessLocalized(nil, "noticeSuccess")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifymoneylocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyMoneyLocalized"></a>lia.notices.notifyMoneyLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L277" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifymoneylocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized money notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyMoneyLocalized(nil, "noticeMoney")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyadminlocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyAdminLocalized"></a>lia.notices.notifyAdminLocalized(client, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L306" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyadminlocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Displays a localized admin notice for the local client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Retained for API compatibility and passed through to the shared notice function.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyAdminLocalized(nil, "noticeAdmin")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianoticesnotifylocalized">
<summary><span class="summary-main"><a id="lia.notices.notifyLocalized"></a>lia.notices.notifyLocalized(client, key, notifType)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L377" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifylocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends or displays a localized notice using the provided notice type.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player|any</a></span> <span class="parameter">client</span> <span class="optional">optional</span> On the server, the target player to receive the notice. If nil, the notice is broadcast. If this value is not a Player, it is treated as the first localization argument and the notice is broadcast. On the client, this is retained for API compatibility.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key to resolve with `L`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">notifType</span> <span class="optional">optional</span> The notice type to send or display. Defaults to `default`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyLocalized(client, "noticeSaved", "success")
  lia.notices.notifyLocalized(nil, "noticeWarning", "warning", "Door")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianoticesnotify">
<summary><span class="summary-main"><a id="lia.notices.notify"></a>lia.notices.notify(client, message, notifType)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L429" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a plain notice from the server or displays one immediately on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> On the server, the target player to receive the notice. If nil, the notice is broadcast. On the client, this is retained for API compatibility.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The notice text to send or display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">notifType</span> <span class="optional">optional</span> The notice type to send or display. Defaults to `default`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notify(client, "Settings saved.", "success")
  lia.notices.notify(nil, "Server restart soon.", "warning")
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-client" id="function-lilianoticeoverride">
<summary><span class="summary-main"><a id="LiliaNoticeOverride"></a>LiliaNoticeOverride(message, noticeType)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/notice.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lilianoticeoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to intercept incoming networked notices before a clientside notice panel is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notices</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The notice text that would be displayed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">noticeType</span> The notice type used to style the notice.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|table|nil</a></span> Return true to block the notice. Return a table with `message` or `msg` and/or `type` to replace the notice data. Return nil or any other value to continue with the original notice.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LiliaNoticeOverride", "liaExampleLiliaNoticeOverride", function(message, noticeType)
      return {
          {name = "Example", value = 1}
      }
  end)
</code></pre>
</div>

</div>
</details>

---

