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

# Administration - Tickets

This page documents hooks in the administration - tickets category.

---

<details class="realm-client" id="function-createticketframe">
<summary><span class="summary-main"><a id="CreateTicketFrame"></a>CreateTicketFrame(requester, message, claimed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="createticketframe"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates the clientside ticket popup frame for a submitted help ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">requester</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The submitted ticket text to display.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">claimed</span> The staff member currently assigned to the ticket, when one exists.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel|nil</a></span> The created ticket frame when the requester is valid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CreateTicketFrame", "liaExampleCreateTicketFrame", function(requester, message, claimed)
      if not IsValid(requester) or message == "" then return end
      print(string.format("[MyModule] %s: %s", requester:Name(), message))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-getallcaseclaims">
<summary><span class="summary-main"><a id="GetAllCaseClaims"></a>GetAllCaseClaims()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L203" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getallcaseclaims"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves aggregated ticket-claim statistics for staff members.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Deferred</a></span> Resolves with a table keyed by admin SteamID containing claim totals and last-claim data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAllCaseClaims", "liaExampleGetAllCaseClaims", function()
      print("[MyModule] handled GetAllCaseClaims")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketclaimed">
<summary><span class="summary-main"><a id="OnTicketClaimed"></a>OnTicketClaimed(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L36" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketclaimed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a staff member claims a ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The staff member who claimed the ticket.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">requester</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> The ticket text that was claimed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketClaimed", "liaExampleOnTicketClaimed", function(client, requester, ticketMessage)
      if not IsValid(client) or ticketMessage == "" then return end
      print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketclosed">
<summary><span class="summary-main"><a id="OnTicketClosed"></a>OnTicketClosed(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L70" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a staff member closes a ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The staff member who closed the ticket.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">requester</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> The ticket text that was closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketClosed", "liaExampleOnTicketClosed", function(client, requester, ticketMessage)
      if not IsValid(client) or ticketMessage == "" then return end
      print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onticketcreated">
<summary><span class="summary-main"><a id="OnTicketCreated"></a>OnTicketCreated(client, message)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L104" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onticketcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a player creates a new help ticket.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> The submitted ticket text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTicketCreated", "liaExampleOnTicketCreated", function(client, message)
      if not IsValid(client) or message == "" then return end
      print(string.format("[MyModule] %s: %s", client:Name(), message))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclaim">
<summary><span class="summary-main"><a id="TicketSystemClaim"></a>TicketSystemClaim(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L135" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ticketsystemclaim"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the ticket system processes a claim action and broadcasts the result.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The staff member claiming the ticket.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">requester</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> The ticket text being claimed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TicketSystemClaim", "liaExampleTicketSystemClaim", function(client, requester, ticketMessage)
      if not IsValid(client) or ticketMessage == "" then return end
      print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclose">
<summary><span class="summary-main"><a id="TicketSystemClose"></a>TicketSystemClose(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L169" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ticketsystemclose"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the ticket system processes a close action and broadcasts the result.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Administration - Tickets</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The staff member closing the ticket.</p>
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">requester</span> The player who opened the ticket.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">ticketMessage</span> The ticket text being closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TicketSystemClose", "liaExampleTicketSystemClose", function(client, requester, ticketMessage)
      if not IsValid(client) or ticketMessage == "" then return end
      print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
  end)
</code></pre>
</div>

</div>
</details>

---

