# Notice

Player notification and messaging system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The notice library provides comprehensive functionality for displaying notifications and messages to players in the Lilia framework. It handles both server-side and client-side notification systems, supporting both direct text messages and localized messages with parameter substitution. The library operates across server and client realms, with the server sending notification data to clients via network messages, while the client handles the visual display of notifications using VGUI panels. It includes automatic organization of multiple notifications, sound effects, and console output for debugging purposes. The library also provides compatibility with Garry's Mod's legacy notification system.
</div>

---

<details class="realm-client" id="function-lianoticesreceivenotify">
<summary><a id="lia.notices.receiveNotify"></a>lia.notices.receiveNotify()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesreceivenotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Receives notification data from the server via network message, allows overriding behavior via a unified hook, and displays it to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically called when the client receives a "liaNotificationData" network message from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LiliaNoticeOverride", "CustomNoticeHandler", function(msg, ntype)
      if ntype == "error" then
          chat.AddText(Color(255, 0, 0), "[ERROR] " .. msg)
          return true
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesreceivenotifyl">
<summary><a id="lia.notices.receiveNotifyL"></a>lia.notices.receiveNotifyL()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesreceivenotifyl"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Receives localized notification data from the server, resolves it into a string, allows overriding via a unified hook, and displays it to the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically called when the client receives a "liaNotifyLocal" network message from the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LiliaNoticeOverride", "CustomLocalizedHandler", function(msg, ntype)
      if string.find(msg, "inventory") then
          return {
              message = "[Inventory] " .. msg,
              type = "warning"
          }
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyinfolocalized">
<summary><a id="lia.notices.notifyInfoLocalized"></a>lia.notices.notifyInfoLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyinfolocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends an informational notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send an info-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyInfoLocalized(player, "item.purchased", itemName, price)
  lia.notices.notifyInfoLocalized(nil, "server.restart", "5")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifywarninglocalized">
<summary><a id="lia.notices.notifyWarningLocalized"></a>lia.notices.notifyWarningLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifywarninglocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a warning notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send a warning-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyWarningLocalized(player, "inventory.full")
  lia.notices.notifyWarningLocalized(nil, "server.maintenance", "30")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyerrorlocalized">
<summary><a id="lia.notices.notifyErrorLocalized"></a>lia.notices.notifyErrorLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyerrorlocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends an error notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send an error-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyErrorLocalized(player, "command.noPermission")
  lia.notices.notifyErrorLocalized(nil, "server.error", errorCode)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifysuccesslocalized">
<summary><a id="lia.notices.notifySuccessLocalized"></a>lia.notices.notifySuccessLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifysuccesslocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a success notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send a success-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifySuccessLocalized(player, "quest.completed", questName)
  lia.notices.notifySuccessLocalized(nil, "server.update.complete")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifymoneylocalized">
<summary><a id="lia.notices.notifyMoneyLocalized"></a>lia.notices.notifyMoneyLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifymoneylocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a money-related notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send a money-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyMoneyLocalized(player, "money.earned", amount, reason)
  lia.notices.notifyMoneyLocalized(nil, "lottery.winner", winnerName, prize)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-lianoticesnotifyadminlocalized">
<summary><a id="lia.notices.notifyAdminLocalized"></a>lia.notices.notifyAdminLocalized(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifyadminlocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends an admin-related notification to a client using a localized message key with optional parameters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send an admin-type notification with localized text to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyAdminLocalized(player, "admin.kicked", reason)
  lia.notices.notifyAdminLocalized(nil, "admin.announcement", message)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianoticesnotifylocalized">
<summary><a id="lia.notices.notifyLocalized"></a>lia.notices.notifyLocalized(client, key, notifType)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotifylocalized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a localized notification to a client or all clients, handling both server-side networking and client-side display.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send a notification using a localization key with variable arguments to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player|string</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to, or the first argument if not a player. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The localization key for the message.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">notifType</span> The type of notification (e.g., "info", "warning", "error", "success").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notifyLocalized(player, "item.purchased", "success", itemName, price)
  lia.notices.notifyLocalized(nil, "server.restart", "warning", "5")
  lia.notices.notifyLocalized(nil, "ui.button.clicked", "info")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lianoticesnotify">
<summary><a id="lia.notices.notify"></a>lia.notices.notify(client, message, notifType)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lianoticesnotify"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends a text notification to a client or all clients, handling both server-side networking and client-side display with sound and visual effects.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when you want to send a notification with plain text (not localized) to a specific client or all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player to send the notification to. If nil, sends to all players.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The notification message text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">notifType</span> The type of notification (e.g., "default", "info", "warning", "error", "success", "money", "admin").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.notices.notify(player, "You have received 100 credits!", "money")
  lia.notices.notify(nil, "Server restarting in 5 minutes", "warning")
  lia.notices.notify(nil, "Welcome to the server!", "info")
</code></pre>
</div>

</div>
</details>

---

