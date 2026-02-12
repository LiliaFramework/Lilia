<style>
.input-group { margin-bottom: 16px !important; }
.generator-card .generator-section { margin-bottom: 24px !important; }
.input-group label { margin-bottom: 8px !important; }
</style>

# Ammo Item Generator

Create ammunition items for your server's weapons.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom ammo item. Once generated, the code should be placed in a new file within your schema's items directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/items/[item_id].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">

    <div class="generator-section">
      <div class="input-group">
        <label for="item-id">Unique ID:</label>
        <input type="text" id="item-id" placeholder="e.g., ammo_9mm" value="ammo_9mm" oninput="generateAmmoItem()">
        <small>Unique identifier for this item (no spaces, lowercase)</small>
      </div>

      <div class="input-group">
        <label for="item-name">Item Name:</label>
        <input type="text" id="item-name" placeholder="e.g., 9mm Ammo" value="9mm Ammo" oninput="generateAmmoItem()">
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., Standard 9mm pistol ammunition" oninput="generateAmmoItem()">A box containing 30 rounds of 9mm ammunition.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Model:</label>
        <input type="text" id="item-model" placeholder="models/items/boxsrounds.mdl" value="models/items/boxsrounds.mdl" oninput="generateAmmoItem()">
        <small>3D model path for the ammo box</small>
      </div>

      <div class="input-group">
        <label for="item-width">Width:</label>
        <input type="number" id="item-width" placeholder="1" min="1" value="1" oninput="generateAmmoItem()">
        <small>Inventory slot width</small>
      </div>

      <div class="input-group">
        <label for="item-height">Height:</label>
        <input type="number" id="item-height" placeholder="1" min="1" value="1" oninput="generateAmmoItem()">
        <small>Inventory slot height</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="ammo-type">Ammo Type:</label>
        <input type="text" id="ammo-type" placeholder="pistol" value="pistol" oninput="generateAmmoItem()">
        <small>Ammo type that gets given to players (e.g., pistol, smg1, buckshot)</small>
      </div>

      <div class="input-group">
        <label for="ammo-amount">Ammo Amount:</label>
        <input type="number" id="ammo-amount" placeholder="30" value="30" min="1" oninput="generateAmmoItem()">
        <small>Amount of ammo given to the player</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateAmmoItem()" class="generate-btn">Generate Ammo Item Code</button>
      <button onclick="fillExampleAmmoItem()" class="generate-btn example-btn">Generate Example</button>
    </div>
  </div>

  <!-- Output Column -->
  <div class="generator-card output-card">
    <div class="card-header">
      <h3>Generated Code</h3>
    </div>
    <textarea id="output-code" class="generator-code-output" readonly></textarea>
  </div>
</div>

<script>
function generateAmmoItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'ammo_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Ammo Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'Ammo item description';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/items/boxsrounds.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const ammoType = (document.getElementById('ammo-type').value || '').trim() || 'pistol';
  const ammoAmount = document.getElementById('ammo-amount').value || '30';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    ammo = ${JSON.stringify(ammoType)},`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_ammo", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleAmmoItem() {
  document.getElementById('item-id').value = 'ammo_357';
  document.getElementById('item-name').value = '.357 Magnum Ammo';
  document.getElementById('item-desc').value = 'A cylinder of six .357 magnum rounds, known for high penetration and damage.';
  document.getElementById('item-model').value = 'models/items/357ammo.mdl';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('ammo-type').value = '357';

  generateAmmoItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateAmmoItem();
});
</script>

---
