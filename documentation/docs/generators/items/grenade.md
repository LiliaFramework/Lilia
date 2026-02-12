# Grenade Item Generator

Define explosive or utility throwable items for your server.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom grenade. Once generated, the code should be placed in a new file within your schema's items directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/items/[item_id].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., m67_grenade" value="m67_grenade" oninput="generateGrenadeItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., M67 Frag" value="M67 Fragmentation Grenade" oninput="generateGrenadeItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A standard fragmentation grenade" oninput="generateGrenadeItem()">A high-explosive fragmentation grenade used for clearing rooms and neutralizing hostile clusters.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-model">Model:</label>
          <input type="text" id="item-model" placeholder="models/weapons/w_np_grenade.mdl" value="models/weapons/w_np_grenade.mdl" oninput="generateGrenadeItem()">
          <small>3D model path for the grenade item</small>
        </div>

        <div class="input-group">
          <label for="weapon-class">Weapon Class:</label>
          <input type="text" id="weapon-class" placeholder="e.g., weapon_frag" value="weapon_frag" oninput="generateGrenadeItem()">
          <small>The weapon entity class that is given when equipped</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="1" oninput="generateGrenadeItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="1" oninput="generateGrenadeItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateGrenadeItem()" class="generate-btn">Generate Grenade Code</button>
      <button onclick="fillExampleGrenade()" class="generate-btn example-btn">Generate Example</button>
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
function generateGrenadeItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'grenade_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Grenade Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A throwable explosive';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/weapons/w_np_grenade.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const weaponClass = (document.getElementById('weapon-class').value || '').trim() || 'weapon_frag';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    class = ${JSON.stringify(weaponClass)}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_grenade", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleGrenade() {
  document.getElementById('item-id').value = 'flash_grenade';
  document.getElementById('item-name').value = 'M7 Flashbang';
  document.getElementById('item-desc').value = 'A non-lethal tactical grenade designed to temporarily disorient enemies with a blinding flash and deafening bang.';
  document.getElementById('item-model').value = 'models/weapons/w_eq_flashbang.mdl';
  document.getElementById('weapon-class').value = 'weapon_flashbang';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';

  generateGrenadeItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateGrenadeItem();
});
</script>

---
