# PAC3 Item Generator

Create wearable PAC3 outfit items that attach PAC parts to the player when equipped.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for a custom PAC3 item. It targets <code>base_pacoutfit</code>, which equips a PAC part and removes it when unequipped.</p>
  <p><strong>Requirements:</strong> PAC3 must be installed and available on the server for these items to work correctly.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/items/pacoutfit/[item_id].lua</code>
</div>

---

<div class="generator-grid">
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., cool_glasses" value="cool_glasses" oninput="generatePac3Item()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Cool Glasses" value="Cool Glasses" oninput="generatePac3Item()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., Stylish glasses with a clean black frame." oninput="generatePac3Item()">Stylish tinted glasses that add a clean tactical look without taking up much inventory space.</textarea>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Inventory Model:</label>
        <input type="text" id="item-model" placeholder="models/props_junk/Shoe001a.mdl" value="models/props_junk/Shoe001a.mdl" oninput="generatePac3Item()">
        <small>3D model shown in the inventory</small>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="1" oninput="generatePac3Item()">
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="1" oninput="generatePac3Item()">
        </div>

        <div class="input-group">
          <label for="outfit-category">Outfit Category:</label>
          <input type="text" id="outfit-category" placeholder="e.g., hat" value="face" oninput="generatePac3Item()">
          <small>Items in the same category cannot be equipped together</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="pac-part-id">PAC Part Unique ID:</label>
          <input type="text" id="pac-part-id" placeholder="e.g., glasses_black" value="glasses_black" oninput="generatePac3Item()">
          <small>Unique ID used inside the PAC3 part data</small>
        </div>

        <div class="input-group">
          <label for="pac-bone">Attach Bone:</label>
          <input type="text" id="pac-bone" placeholder="e.g., head" value="head" oninput="generatePac3Item()">
          <small>Bone the PAC model should attach to</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="pac-model">PAC Model:</label>
          <input type="text" id="pac-model" placeholder="models/captainbigbutt/skeyler/accessories/glasses01.mdl" value="models/captainbigbutt/skeyler/accessories/glasses01.mdl" oninput="generatePac3Item()">
          <small>The model that PAC3 attaches to the player</small>
        </div>

        <div class="input-group">
          <label for="pac-size">PAC Size:</label>
          <input type="number" id="pac-size" placeholder="1" min="0.1" step="0.1" value="1" oninput="generatePac3Item()">
          <small>Scale multiplier for the attached PAC model</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="attrib-boosts">Attribute Boosts:</label>
        <textarea id="attrib-boosts" placeholder="Optional. One per line, format: strength=2" oninput="generatePac3Item()"></textarea>
        <small>Optional boosts added while the item is equipped, such as <code>strength=2</code> or <code>agility=1</code></small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generatePac3Item()" class="generate-btn">Generate PAC3 Item Code</button>
      <button onclick="fillExamplePac3Item()" class="generate-btn example-btn">Generate Example</button>
    </div>
  </div>

  <div class="generator-card output-card">
    <div class="card-header">
      <h3>Generated Code</h3>
    </div>
    <textarea id="output-code" class="generator-code-output" readonly></textarea>
  </div>
</div>

<script>
function parseAttributeBoosts() {
  const raw = (document.getElementById('attrib-boosts').value || '').trim();
  if (!raw) return [];

  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const separatorIndex = line.indexOf('=');
      if (separatorIndex === -1) return null;

      const key = line.slice(0, separatorIndex).trim();
      const value = line.slice(separatorIndex + 1).trim();
      if (!key || !value) return null;

      return {key, value};
    })
    .filter(Boolean);
}

function generatePac3Item() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'pac_item_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'PAC3 Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A wearable PAC3 item.';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_junk/Shoe001a.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const outfitCategory = (document.getElementById('outfit-category').value || '').trim() || 'accessory';
  const pacPartId = (document.getElementById('pac-part-id').value || '').trim() || `${uniqueId}_part`;
  const pacBone = (document.getElementById('pac-bone').value || '').trim() || 'head';
  const pacModel = (document.getElementById('pac-model').value || '').trim() || 'models/captainbigbutt/skeyler/accessories/glasses01.mdl';
  const pacSize = document.getElementById('pac-size').value || '1';
  const attribBoosts = parseAttributeBoosts();

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    category = "PAC3",`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    outfitCategory = ${JSON.stringify(outfitCategory)},`,
    '    pacData = {',
    '        [1] = {',
    '            children = {},',
    '            self = {',
    `                ClassName = "model",`,
    `                UniqueID = ${JSON.stringify(pacPartId)},`,
    `                Bone = ${JSON.stringify(pacBone)},`,
    `                Model = ${JSON.stringify(pacModel)},`,
    `                Size = ${pacSize}`,
    '            }',
    '        }',
    '    },'
  ];

  if (attribBoosts.length > 0) {
    properties.push('    attribBoosts = {');
    attribBoosts.forEach((entry, index) => {
      const suffix = index === attribBoosts.length - 1 ? '' : ',';
      properties.push(`        ${entry.key} = ${entry.value}${suffix}`);
    });
    properties.push('    }');
  }

  const lines = [
    '-- Copy and paste this code into a Lua file that loads during initialization',
    '-- Example: [schema folder]/schema/items/pacoutfit/[item_id].lua',
    '',
    `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_pacoutfit", {`,
    ...properties,
    '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExamplePac3Item() {
  document.getElementById('item-id').value = 'hazard_goggles';
  document.getElementById('item-name').value = 'Hazard Goggles';
  document.getElementById('item-desc').value = 'Industrial protective goggles fitted with a reinforced frame and dark anti-glare lenses.';
  document.getElementById('item-model').value = 'models/props_lab/huladoll.mdl';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('outfit-category').value = 'face';
  document.getElementById('pac-part-id').value = 'hazard_goggles_part';
  document.getElementById('pac-bone').value = 'head';
  document.getElementById('pac-model').value = 'models/captainbigbutt/skeyler/accessories/glasses01.mdl';
  document.getElementById('pac-size').value = '1';
  document.getElementById('attrib-boosts').value = 'perception=1\nstamina=5';

  generatePac3Item();
}

document.addEventListener('DOMContentLoaded', () => {
  generatePac3Item();
});
</script>

---
