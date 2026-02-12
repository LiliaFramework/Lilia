# Weapon Item Generator

Create equippable weapons that players can carry in their inventory and use in combat.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom weapon item. Once generated, the code should be placed in a new file within your schema's items directory.</p>
  <p><strong>Note on Automatic Generation:</strong> Lilia automatically generates weapon items for any registered weapon entity that does not have a manual item definition. Using this generator to create a custom item will override that default behavior for the specified weapon class.</p>
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
          <input type="text" id="item-id" placeholder="e.g., ak47" value="ak47" oninput="generateWeaponItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., AK-47" value="AK-47 Rifle" oninput="generateWeaponItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A reliable Soviet assault rifle" oninput="generateWeaponItem()">A rugged and dependable gas-operated assault rifle, known for its stopping power and reliability in harsh conditions.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-model">Item Model (Inventory):</label>
          <input type="text" id="item-model" placeholder="models/weapons/w_rif_ak47.mdl" value="models/weapons/w_rif_ak47.mdl" oninput="generateWeaponItem()">
          <small>3D model path displayed in the inventory</small>
        </div>

        <div class="input-group">
          <label for="weapon-class">Weapon Class:</label>
          <input type="text" id="weapon-class" placeholder="e.g., weapon_ak47" value="weapon_ak47" oninput="generateWeaponItem()">
          <small>The weapon entity class that is given when equipped</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="4" oninput="generateWeaponItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="2" oninput="generateWeaponItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>
          <input type="checkbox" id="is-holsterable" checked oninput="generateWeaponItem()"> Holsterable
        </label>
        <small>Can the weapon be holstered/visible on the player's back?</small>
      </div>

      <div class="input-group">
        <label for="holster-slot">Holster Slot:</label>
        <select id="holster-slot" oninput="generateWeaponItem()">
          <option value="none">None</option>
          <option value="back" selected>Back (Primary)</option>
          <option value="side">Side (Sidearm)</option>
        </select>
        <small>Visual attachment point on the player model</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateWeaponItem()" class="generate-btn">Generate Weapon Code</button>
      <button onclick="fillExampleWeapon()" class="generate-btn example-btn">Generate Example</button>
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
function generateWeaponItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'weapon_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Weapon Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A combat weapon';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/weapons/w_rif_ak47.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const weaponClass = (document.getElementById('weapon-class').value || '').trim() || 'weapon_ak47';
  const holsterable = document.getElementById('is-holsterable').checked;
  const holsterSlot = document.getElementById('holster-slot').value;

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    class = ${JSON.stringify(weaponClass)},`,
    `    isHolsterable = ${holsterable},`,
    `    holsterSlot = ${JSON.stringify(holsterSlot)}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_weapons", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleWeapon() {
  document.getElementById('item-id').value = 'glock18';
  document.getElementById('item-name').value = 'Glock 18 Sidearm';
  document.getElementById('item-desc').value = 'A compact, selective-fire Austrian pistol. Extremely effective for close-quarters engagements.';
  document.getElementById('item-model').value = 'models/weapons/w_pist_glock18.mdl';
  document.getElementById('weapon-class').value = 'weapon_glock';
  document.getElementById('item-width').value = '2';
  document.getElementById('item-height').value = '1';
  document.getElementById('is-holsterable').checked = true;
  document.getElementById('holster-slot').value = 'side';

  generateWeaponItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateWeaponItem();
});
</script>

---
