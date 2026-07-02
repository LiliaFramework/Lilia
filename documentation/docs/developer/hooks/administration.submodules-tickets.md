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

# Administration - Submodules/Tickets

This page documents the hooks defined by the submodules/tickets submodule in the administration module.

---

<details class="realm-server" id="function-onticketclaimed">
<summary><span class="summary-main"><a id="OnTicketClaimed"></a>OnTicketClaimed(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

</div>
</details>

---

<details class="realm-server" id="function-onticketclosed">
<summary><span class="summary-main"><a id="OnTicketClosed"></a>OnTicketClosed(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L27" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

</div>
</details>

---

<details class="realm-server" id="function-onticketcreated">
<summary><span class="summary-main"><a id="OnTicketCreated"></a>OnTicketCreated(client, message)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L53" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclaim">
<summary><span class="summary-main"><a id="TicketSystemClaim"></a>TicketSystemClaim(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L76" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

</div>
</details>

---

<details class="realm-server" id="function-ticketsystemclose">
<summary><span class="summary-main"><a id="TicketSystemClose"></a>TicketSystemClose(client, requester, ticketMessage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/tickets/module.lua#L102" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

</div>
</details>

---

