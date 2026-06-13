# PAC3 Item Generator

Create wearable PAC3 outfit items that attach PAC parts to the player when equipped. PAC3 outfits are useful for small visual accessories, faction markers, event props, and cosmetic progression that should live inside Lilia's inventory rules.

PAC3 must be installed on the server for these items to work. Generated items target `base_pacoutfit`, which applies the PAC part on equip and removes it on unequip.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

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
        <label>Attribute Boosts:</label>
        <div id="attrib-boosts-list" class="dynamic-list"></div>
        <button onclick="addAttribBoostRow(); generatePac3Item();" class="add-btn">+ Add Attribute Boost</button>
        <small>Optional boosts added while the item is equipped, such as <code>strength = 2</code> or <code>agility = 1</code>.</small>
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
function addAttribBoostRow(attribute = '', value = '') {
  const container = document.getElementById('attrib-boosts-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="Attribute key (e.g. strength)" value="${attribute}" class="attrib-boost-key" oninput="generatePac3Item()">
  <input type="number" placeholder="Value" value="${value}" class="attrib-boost-value" oninput="generatePac3Item()">
  <button onclick="this.parentElement.remove(); generatePac3Item();" class="remove-btn" aria-label="Remove row">&times;</button>
  `;
  container.appendChild(div);
}

function parseAttributeBoosts() {
  const rows = document.querySelectorAll('#attrib-boosts-list .dynamic-row');
  const entries = [];

  rows.forEach((row) => {
    const key = (row.querySelector('.attrib-boost-key').value || '').trim();
    const value = (row.querySelector('.attrib-boost-value').value || '').trim();
    if (!key || value === '') return;
    entries.push({key, value});
  });

  return entries;
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
    `    category = "outfit",`,
    `    model = ${JSON.stringify(model)},`,
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

  if (width !== '1') properties.splice(4, 0, `    width = ${width},`);
  if (height !== '1') properties.splice(width !== '1' ? 5 : 4, 0, `    height = ${height},`);

  if (attribBoosts.length > 0) {
    properties.push('    attribBoosts = {');
    attribBoosts.forEach((entry, index) => {
      const suffix = index === attribBoosts.length - 1 ? '' : ',';
      properties.push(`        ${entry.key} = ${entry.value}${suffix}`);
    });
    properties.push('    }');
  }

  const lines = [
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
  document.getElementById('attrib-boosts-list').innerHTML = '';
  addAttribBoostRow('perception', '1');
  addAttribBoostRow('stamina', '5');

  generatePac3Item();
}

document.addEventListener('DOMContentLoaded', () => {
  if (!document.querySelector('#attrib-boosts-list .dynamic-row')) {
    addAttribBoostRow('perception', '1');
    addAttribBoostRow('stamina', '5');
  }

  generatePac3Item();
});
</script>
