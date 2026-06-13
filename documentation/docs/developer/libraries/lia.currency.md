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

# Currency

Currency helpers for formatting in-game money values and spawning physical money entities.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The currency library centralizes how Lilia formats money text and keeps the configured singular name, plural name, and symbol in sync with framework config updates. On the server it also provides the helper used to spawn <code>lia_money</code> entities in the world.
</div>

---

<details class="realm-shared" id="function-liacurrencyget">
<summary>
    <span class="summary-main">
        <a id="lia.currency.get"></a>lia.currency.get(amount)
    </span>
    <a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/currency.lua#L40" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a>
</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacurrencyget"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Formats a numeric amount into the active in-game currency string.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> The amount of money to format.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> The formatted currency string using the configured symbol and singular or plural name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">client:notifyInfo(lia.currency.get(250))
print(lia.currency.get(1))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liacurrencyspawn">
<summary>
    <span class="summary-main">
        <a id="lia.currency.spawn"></a>lia.currency.spawn(pos, amount, angle)
    </span>
    <a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/currency.lua#L72" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a>
</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liacurrencyspawn"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Spawns a physical <code>lia_money</code> entity at the given position.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The world position where the money entity should be created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">amount</span> The money amount stored on the spawned entity. Negative values are rejected.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Angle">Angle</a></span> <span class="parameter">angle</span> <span class="optional">optional</span> Optional spawn angle for the money entity. Defaults to <code>angle_zero</code>.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|nil</a></span> The spawned <code>lia_money</code> entity, or <code>nil</code> when the input is invalid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">local money = lia.currency.spawn(client:getItemDropPos(), 100)
if IsValid(money) then
    money.client = client
end
</code></pre>
</div>

</div>
</details>

---