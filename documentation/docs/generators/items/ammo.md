# Ammo Item Generator

Create ammunition items that pair inventory objects with Garry's Mod ammo types. Ammo items help keep weapon supply, vendors, loot tables, and storage behavior visible inside Lilia's inventory system.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

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
        <label for="use-sound">Use Sound:</label>
        <input type="text" id="use-sound" placeholder="items/ammo_pickup.wav" value="" oninput="generateAmmoItem()">
        <small>Optional sound override used when the ammo item is loaded</small>
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
  const model = (document.getElementById('item-model').value || '').trim() || 'models/items/boxsrounds.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const ammoType = (document.getElementById('ammo-type').value || '').trim() || 'pistol';
  const useSound = (document.getElementById('use-sound').value || '').trim();

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    model = ${JSON.stringify(model)},`
  ];

  if (width !== '1') properties.push(`    width = ${width},`);
  if (height !== '1') properties.push(`    height = ${height},`);
  if (ammoType !== 'pistol') properties.push(`    ammo = ${JSON.stringify(ammoType)},`);
  if (useSound) properties.push(`    useSound = ${JSON.stringify(useSound)}`);

  const lines = [
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
  document.getElementById('item-model').value = 'models/items/357ammo.mdl';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('ammo-type').value = '357';
  document.getElementById('use-sound').value = 'items/ammo_pickup.wav';

  generateAmmoItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateAmmoItem();
});
</script>
