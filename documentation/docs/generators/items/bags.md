<style>
.input-group { margin-bottom: 16px !important; }
.generator-card .generator-section { margin-bottom: 24px !important; }
.input-group label { margin-bottom: 8px !important; }
</style>

# Bag Item Generator

Create storage bags that open their own inventory. Use this generator to define bags with a custom size and appearance.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for a custom bag item. Once generated, place the code in a new item file inside your schema's items directory.</p>
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
          <input type="text" id="item-id" placeholder="e.g., backpack_small" value="backpack_small" oninput="generateBagItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Small Backpack" value="Small Backpack" oninput="generateBagItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A compact backpack for carrying extra supplies." oninput="generateBagItem()">A compact backpack for carrying extra supplies.</textarea>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Model:</label>
        <input type="text" id="item-model" placeholder="models/props_junk/garbage_bag001a.mdl" value="models/props_junk/garbage_bag001a.mdl" oninput="generateBagItem()">
        <small>3D model path for the bag</small>
      </div>

      <div class="input-group">
        <label for="bag-weight">Bag Weight:</label>
        <input type="number" id="bag-weight" placeholder="-6" value="" oninput="generateBagItem()">
        <small>Optional negative weight for weight-based bags. Leave blank to generate a grid-based bag using width and height.</small>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="inv-width">Inventory Width:</label>
          <input type="number" id="inv-width" placeholder="2" min="1" value="2" oninput="generateBagItem()">
          <small>Bag inventory width</small>
        </div>

        <div class="input-group">
          <label for="inv-height">Inventory Height:</label>
          <input type="number" id="inv-height" placeholder="2" min="1" value="2" oninput="generateBagItem()">
          <small>Bag inventory height</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateBagItem()" class="generate-btn">Generate Bag Item Code</button>
      <button onclick="fillExampleBagItem()" class="generate-btn example-btn">Generate Example</button>
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
function generateBagItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'bag_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Bag Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A storage bag item.';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_junk/garbage_bag001a.mdl';
  const bagWeight = (document.getElementById('bag-weight').value || '').trim();
  const invWidth = document.getElementById('inv-width').value || '2';
  const invHeight = document.getElementById('inv-height').value || '2';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`
  ];

  if (bagWeight !== '') {
    const normalizedWeight = bagWeight.startsWith('-') ? bagWeight : `-${bagWeight}`;
    properties.push(`    weight = ${normalizedWeight}`);
  } else {
    properties.push(`    invWidth = ${invWidth},`);
    properties.push(`    invHeight = ${invHeight}`);
  }

  const lines = [
    '-- Copy and paste this code into any Lua file that loads during initialization',
    '-- Example: [schema folder]/schema/items.lua',
    '',
    `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_bags", {`,
    ...properties,
    '})'
  ];

  const code = `${lines.join('\n')}\n`;
  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleBagItem() {
  document.getElementById('item-id').value = 'backpack_small';
  document.getElementById('item-name').value = 'Small Backpack';
  document.getElementById('item-desc').value = 'A compact backpack for carrying extra supplies.';
  document.getElementById('item-model').value = 'models/props_junk/garbage_bag001a.mdl';
  document.getElementById('bag-weight').value = '';
  document.getElementById('inv-width').value = '3';
  document.getElementById('inv-height').value = '2';
  generateBagItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateBagItem();
});
</script>

---
