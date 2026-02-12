# Outfit Item Generator

Create wearable clothing and armor that changes the player's model and adds protection.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom outfit. Once generated, the code should be placed in a new file within your schema's items directory.</p>
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
          <input type="text" id="item-id" placeholder="e.g., kevlar_vest" value="heavy_armor" oninput="generateOutfitItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Kevlar Vest" value="Heavy Tactical Armor" oninput="generateOutfitItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A heavy ballistic vest providing high protection" oninput="generateOutfitItem()">Reinforced tactical plating designed to withstand high-caliber impacts at the cost of mobility.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Item Model (Inventory):</label>
        <input type="text" id="item-model" placeholder="models/items/hevsuit.mdl" value="models/props_c17/SuitCase001a.mdl" oninput="generateOutfitItem()">
        <small>3D model path displayed in the inventory</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="2" oninput="generateOutfitItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="3" oninput="generateOutfitItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="outfit-model">Wearable Model:</label>
        <input type="text" id="outfit-model" placeholder="models/player/combine_super_soldier.mdl" value="models/player/combine_super_soldier.mdl" oninput="generateOutfitItem()">
        <small>The player model that is applied when this outfit is worn</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="armor-value">Armor Points:</label>
          <input type="number" id="armor-value" placeholder="0" min="0" value="50" oninput="generateOutfitItem()">
          <small>Additional armor given to the player</small>
        </div>

        <div class="input-group">
          <label for="speed-reduction">Speed Multiplier:</label>
          <input type="number" id="speed-reduction" placeholder="1.0" min="0" step="0.1" value="0.9" oninput="generateOutfitItem()">
          <small>1.0 = normal speed, 0.5 = half speed</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateOutfitItem()" class="generate-btn">Generate Outfit Code</button>
      <button onclick="fillExampleOutfit()" class="generate-btn example-btn">Generate Example</button>
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
function generateOutfitItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'outfit_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Outfit Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A wearable outfit';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_c17/SuitCase001a.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const outfitModel = (document.getElementById('outfit-model').value || '').trim() || 'models/player/group01/male_01.mdl';
  const armorValue = document.getElementById('armor-value').value || '0';
  const speedMult = document.getElementById('speed-reduction').value || '1.0';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    '    category = "Outfits",',
    `    armor = ${armorValue},`,
    `    speed = ${speedMult},`,
    `    outfitModel = ${JSON.stringify(outfitModel)}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_outfit", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleOutfit() {
  document.getElementById('item-id').value = 'hazmat_suit';
  document.getElementById('item-name').value = 'CBRN Hazmat Suit';
  document.getElementById('item-desc').value = 'Heavy-duty chemical and biological protection suit. Offers complete environmental protection at the cost of significant movement restriction.';
  document.getElementById('item-model').value = 'models/props_junk/metalgascan.mdl';
  document.getElementById('item-width').value = '2';
  document.getElementById('item-height').value = '2';
  document.getElementById('outfit-model').value = 'models/player/corpse1.mdl'; // Example path
  document.getElementById('armor-value').value = '25';
  document.getElementById('speed-reduction').value = '0.7';

  generateOutfitItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateOutfitItem();
});
</script>

---
