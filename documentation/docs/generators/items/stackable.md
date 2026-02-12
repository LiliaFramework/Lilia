# Stackable Item Generator

Create items that can be stacked together to save space, like currency, resources, or scraps.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom stackable item. Once generated, the code should be placed in a new file within your schema's items directory.</p>
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
          <input type="text" id="item-id" placeholder="e.g., metal_scrap" value="metal_scrap" oninput="generateStackableItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Metal Scrap" value="Industrial Metal Scrap" oninput="generateStackableItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., Raw metal scraps that can be used for crafting" oninput="generateStackableItem()">Torn fragments of industrial-grade steel and iron, often salvaged from abandoned structures.</textarea>
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
          <label for="max-stacks">Max Stacks:</label>
          <input type="number" id="max-stacks" placeholder="16" min="1" value="10" oninput="generateStackableItem()">
          <small>Highest stack count</small>
        </div>
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
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A stackable item';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_junk/garbage_metalcan002a.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const maxStacks = document.getElementById('max-stacks').value || '16';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    maxStacks = ${maxStacks}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
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
  document.getElementById('item-desc').value = 'Exposed copper wires salvaged from electronic components. A vital resource for electrical maintenance and crafting.';
  document.getElementById('item-model').value = 'models/props_lab/cactus.mdl'; // Example path
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('max-stacks').value = '20';

  generateStackableItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateStackableItem();
});
</script>

---
