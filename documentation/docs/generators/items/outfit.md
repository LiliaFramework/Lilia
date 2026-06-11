# Outfit Item Generator

Create wearable clothing or armor that can change a character's model and apply protection values. Outfit items are useful for uniforms, armor tiers, disguises, event costumes, and equipment-based presentation.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/items/outfit/[item_id].lua
```

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
        <label for="replacement-model">Replacement Model:</label>
        <input type="text" id="replacement-model" placeholder="models/player/combine_super_soldier.mdl" value="models/player/combine_super_soldier.mdl" oninput="generateOutfitItem()">
        <small>Optional model path applied through the base replacement logic</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="armor-value">Armor Points:</label>
          <input type="number" id="armor-value" placeholder="0" min="0" value="50" oninput="generateOutfitItem()">
          <small>Additional armor given to the player</small>
        </div>

        <div class="input-group">
          <label for="outfit-category">Outfit Category:</label>
          <input type="text" id="outfit-category" placeholder="e.g., uniform" value="armor" oninput="generateOutfitItem()">
          <small>Only one equipped item per outfit category is allowed</small>
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
  const replacementModel = (document.getElementById('replacement-model').value || '').trim() || 'models/player/group01/male_01.mdl';
  const armorValue = document.getElementById('armor-value').value || '0';
  const outfitCategory = (document.getElementById('outfit-category').value || '').trim() || 'uniform';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    '    category = "outfit",',
    `    outfitCategory = ${JSON.stringify(outfitCategory)},`,
    `    replacement = ${JSON.stringify(replacementModel)}`
  ];

  if (width !== '1') properties.splice(3, 0, `    width = ${width},`);
  if (height !== '1') properties.splice(width !== '1' ? 4 : 3, 0, `    height = ${height},`);
  if (armorValue !== '0') properties.splice(properties.length - 1, 0, `    armor = ${armorValue},`);

  const lines = [
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
  document.getElementById('replacement-model').value = 'models/player/corpse1.mdl';
  document.getElementById('armor-value').value = '25';
  document.getElementById('outfit-category').value = 'hazmat';

  generateOutfitItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateOutfitItem();
});
</script>
