# Aid Item Generator

Create consumable items that restore health, armor, or stamina.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom aid item. Once generated, the code should be placed in a new file within your schema's items directory.</p>
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
          <input type="text" id="item-id" placeholder="e.g., health_kit" value="medkit" oninput="generateAidItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Health Kit" value="Medical Kit" oninput="generateAidItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A standard medical kit that restores health" oninput="generateAidItem()">A professional medical kit containing various surgical tools and high-grade bandages.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Model:</label>
        <input type="text" id="item-model" placeholder="models/items/healthkit.mdl" value="models/items/healthkit.mdl" oninput="generateAidItem()">
        <small>3D model path for the aid item</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="2" oninput="generateAidItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="2" oninput="generateAidItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label for="health-amount">Health Amount:</label>
          <input type="number" id="health-amount" placeholder="25" min="0" value="50" oninput="generateAidItem()">
          <small>Amount of health restored (leave empty for no health restoration)</small>
        </div>

        <div class="input-group">
          <label for="armor-amount">Armor Amount:</label>
          <input type="number" id="armor-amount" placeholder="0" min="0" value="0" oninput="generateAidItem()">
          <small>Amount of armor restored (leave empty for no armor restoration)</small>
        </div>

        <div class="input-group">
          <label for="stamina-amount">Stamina Amount:</label>
          <input type="number" id="stamina-amount" placeholder="0" min="0" value="20" oninput="generateAidItem()">
          <small>Amount of stamina restored (leave empty for no stamina restoration)</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateAidItem()" class="generate-btn">Generate Aid Item Code</button>
      <button onclick="fillExampleAidItem()" class="generate-btn example-btn">Generate Example</button>
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
function generateAidItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'aid_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Aid Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'An aid item that provides healing';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/items/healthkit.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const healthAmount = document.getElementById('health-amount').value.trim();
  const armorAmount = document.getElementById('armor-amount').value.trim();
  const staminaAmount = document.getElementById('stamina-amount').value.trim();

  const healthValue = healthAmount || '0';
  const armorValue = armorAmount || '0';
  const staminaValue = staminaAmount || '0';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    health = ${healthValue},`,
    `    armor = ${armorValue},`,
    `    stamina = ${staminaValue}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_aid", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleAidItem() {
  document.getElementById('item-id').value = 'combat_stim';
  document.getElementById('item-name').value = 'Combat Stimulant';
  document.getElementById('item-desc').value = 'An experimental stimulant that provides immediate pain relief and a temporary surge of energy.';
  document.getElementById('item-model').value = 'models/healthvial.mdl';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('health-amount').value = '25';
  document.getElementById('armor-amount').value = '10';
  document.getElementById('stamina-amount').value = '50';

  generateAidItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateAidItem();
});
</script>

---
