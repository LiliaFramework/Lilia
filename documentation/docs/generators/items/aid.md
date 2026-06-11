# Aid Item Generator

Create consumable items that restore health, armor, stamina, or similar survival resources. Aid items are useful for medical systems, survival pacing, event supplies, and economy-controlled recovery.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/items/aid/[item_id].lua
```

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

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="heal-time">Heal Duration:</label>
          <input type="number" id="heal-time" placeholder="0" min="0" step="0.1" value="5" oninput="generateAidItem()">
          <small>Total seconds to spread health across. Use 0 for instant healing.</small>
        </div>

        <div class="input-group">
          <label for="heal-interval">Heal Interval:</label>
          <input type="number" id="heal-interval" placeholder="1" min="0.1" step="0.1" value="1" oninput="generateAidItem()">
          <small>Seconds between healing ticks when duration is above 0.</small>
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
  const healTimeAmount = document.getElementById('heal-time').value.trim();
  const healIntervalAmount = document.getElementById('heal-interval').value.trim();

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`
  ];

  if (width !== '1') properties.push(`    width = ${width},`);
  if (height !== '1') properties.push(`    height = ${height},`);
  if (healthAmount && healthAmount !== '0') properties.push(`    health = ${healthAmount},`);
  if (armorAmount && armorAmount !== '0') properties.push(`    armor = ${armorAmount},`);
  if (staminaAmount && staminaAmount !== '0') properties.push(`    stamina = ${staminaAmount},`);
  if (healTimeAmount && healTimeAmount !== '0') properties.push(`    healTime = ${healTimeAmount},`);
  if (healIntervalAmount && healIntervalAmount !== '1') properties.push(`    healInterval = ${healIntervalAmount}`);

  const lines = [
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
  document.getElementById('heal-time').value = '5';
  document.getElementById('heal-interval').value = '1';

  generateAidItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateAidItem();
});
</script>
