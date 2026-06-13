# Stackable Item Generator

Create items that stack together, such as currency-like objects, crafting resources, scraps, ammo bundles, or supplies. Stackable items are ideal for economies where quantity matters more than unique item state.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., metal_scrap" value="metal_scrap" oninput="generateStackableItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Metal Scrap" value="Industrial Metal Scrap" oninput="generateStackableItem()">
        </div>
      </div>

    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Model:</label>
        <input type="text" id="item-model" placeholder="models/props_junk/garbage_metalcan002a.mdl" value="models/props_junk/garbage_metalcan002a.mdl" oninput="generateStackableItem()">
        <small>3D model path for the stackable item</small>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="1" oninput="generateStackableItem()">
          <small>Inventory width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="1" oninput="generateStackableItem()">
          <small>Inventory height</small>
        </div>

        <div class="input-group">
          <label for="max-stacks">Max Quantity:</label>
          <input type="number" id="max-stacks" placeholder="16" min="1" value="10" oninput="generateStackableItem()">
          <small>Highest quantity allowed in one stack</small>
        </div>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="can-split" checked oninput="generateStackableItem()"> Allow Splitting
        </label>
        <small>Controls the base `canSplit` field</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateStackableItem()" class="generate-btn">Generate Stackable Item Code</button>
      <button onclick="fillExampleStackable()" class="generate-btn example-btn">Generate Example</button>
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
function generateStackableItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'stackable_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Stackable Item';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_junk/garbage_metalcan002a.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const maxQuantity = document.getElementById('max-stacks').value || '16';
  const canSplit = document.getElementById('can-split').checked;

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    model = ${JSON.stringify(model)},`,
    `    maxQuantity = ${maxQuantity}`
  ];

  if (width !== '1') properties.splice(3, 0, `    width = ${width},`);
  if (height !== '1') properties.splice(width !== '1' ? 4 : 3, 0, `    height = ${height},`);
  if (!canSplit) properties.push('    canSplit = false');

  const lines = [
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_stackable", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleStackable() {
  document.getElementById('item-id').value = 'copper_wire';
  document.getElementById('item-name').value = 'Copper Wiring';
  document.getElementById('item-model').value = 'models/props_lab/cactus.mdl'; // Example path
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('max-stacks').value = '20';
  document.getElementById('can-split').checked = true;

  generateStackableItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateStackableItem();
});
</script>
