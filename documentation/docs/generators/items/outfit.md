# Outfit Item Generator

Create wearable clothing or armor that can change a character's model and apply protection values. Outfit items are useful for uniforms, armor tiers, disguises, event costumes, and equipment-based presentation.

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
      <div class="form-grid-2">
        <div class="input-group">
          <label for="source-model">Source Model:</label>
          <input type="text" id="source-model" placeholder="Leave blank to use ITEM.replacement" value="" oninput="generateOutfitItem()">
          <small>If set, the generator outputs a keyed <code>ITEM.replacements[sourceModel]</code> entry.</small>
        </div>

        <div class="input-group">
          <label for="replacement-model">Replacement Model:</label>
          <input type="text" id="replacement-model" placeholder="models/player/combine_super_soldier.mdl" value="models/player/combine_super_soldier.mdl" oninput="generateOutfitItem()">
          <small>Model path applied by the outfit when equipped.</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="skin-value">Skin:</label>
          <input type="number" id="skin-value" placeholder="0" min="0" value="1" oninput="generateOutfitItem()">
          <small>Applied at the item level or inside the keyed replacement entry.</small>
        </div>

        <div class="input-group">
          <label>Bodygroups:</label>
          <div id="bodygroups-list" class="dynamic-list"></div>
          <button onclick="addBodygroupRow(); generateOutfitItem();" class="add-btn">+ Add Bodygroup</button>
          <small>Add one bodygroup entry at a time. Use numeric indexes like <code>1</code> or named keys like <code>helmet</code>.</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="bodygroups-field">Bodygroups Field:</label>
          <select id="bodygroups-field" oninput="generateOutfitItem()">
            <option value="bodygroups" selected>bodygroups</option>
            <option value="bodyGroups">bodyGroups</option>
          </select>
          <small>Both field names are supported by the outfit base.</small>
        </div>
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

      <div class="form-grid-2">
        <div class="input-group">
          <label>Attribute Boosts:</label>
          <div id="attrib-boosts-list" class="dynamic-list"></div>
          <button onclick="addAttribBoostRow(); generateOutfitItem();" class="add-btn">+ Add Attribute Boost</button>
          <small>Optional boosts applied while equipped, such as <code>strength = 2</code>.</small>
        </div>

        <div class="input-group">
          <label for="pac-data">PAC Data:</label>
          <textarea id="pac-data" placeholder='Optional raw Lua entries, e.g.&#10;[1] = {&#10;    children = {},&#10;    self = {ClassName = "model"}&#10;}' oninput="generateOutfitItem()"></textarea>
          <small>Optional raw <code>pacData</code> table contents for hybrid outfit items.</small>
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
function addBodygroupRow(key = '', value = '') {
  const container = document.getElementById('bodygroups-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="Bodygroup key (e.g. 1 or helmet)" value="${key}" class="bodygroup-key" oninput="generateOutfitItem()">
  <input type="number" placeholder="Value" value="${value}" min="0" class="bodygroup-value" oninput="generateOutfitItem()">
  <button onclick="this.parentElement.remove(); generateOutfitItem();" class="remove-btn" aria-label="Remove row">&times;</button>
  `;
  container.appendChild(div);
}

function getBodygroupEntries() {
  const rows = document.querySelectorAll('#bodygroups-list .dynamic-row');
  const entries = [];

  rows.forEach((row) => {
    const key = (row.querySelector('.bodygroup-key').value || '').trim();
    const value = (row.querySelector('.bodygroup-value').value || '').trim();
    if (!key || value === '') return;
    entries.push({key, value});
  });

  return entries;
}

function addAttribBoostRow(attribute = '', value = '') {
  const container = document.getElementById('attrib-boosts-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="Attribute key (e.g. strength)" value="${attribute}" class="attrib-boost-key" oninput="generateOutfitItem()">
  <input type="number" placeholder="Value" value="${value}" class="attrib-boost-value" oninput="generateOutfitItem()">
  <button onclick="this.parentElement.remove(); generateOutfitItem();" class="remove-btn" aria-label="Remove row">&times;</button>
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

function generateOutfitItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'outfit_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Outfit Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A wearable outfit';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_c17/SuitCase001a.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const sourceModel = (document.getElementById('source-model').value || '').trim();
  const replacementModel = (document.getElementById('replacement-model').value || '').trim() || 'models/player/group01/male_01.mdl';
  const skinValue = (document.getElementById('skin-value').value || '').trim();
  const bodygroupsValue = getBodygroupEntries();
  const bodygroupsField = document.getElementById('bodygroups-field').value || 'bodygroups';
  const armorValue = document.getElementById('armor-value').value || '0';
  const outfitCategory = (document.getElementById('outfit-category').value || '').trim() || 'uniform';
  const attribBoosts = parseAttributeBoosts();
  const pacData = (document.getElementById('pac-data').value || '').trim();

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    '    category = "outfit",',
    `    outfitCategory = ${JSON.stringify(outfitCategory)},`
  ];

  if (width !== '1') properties.splice(3, 0, `    width = ${width},`);
  if (height !== '1') properties.splice(width !== '1' ? 4 : 3, 0, `    height = ${height},`);
  if (armorValue !== '0') properties.push(`    armor = ${armorValue},`);
  if (attribBoosts.length > 0) {
    properties.push('    attribBoosts = {');
    attribBoosts.forEach((entry, index) => {
      const suffix = index === attribBoosts.length - 1 ? '' : ',';
      properties.push(`        ${entry.key} = ${entry.value}${suffix}`);
    });
    properties.push('    },');
  }
  if (pacData) {
    properties.push('    pacData = {');
    pacData.split('\n').forEach(line => {
      const trimmed = line.trim();
      if (trimmed) properties.push(`        ${trimmed}`);
    });
    properties.push('    },');
  }

  if (sourceModel) {
    properties.push('    replacements = {');
    properties.push(`        [${JSON.stringify(sourceModel)}] = {`);
    properties.push(`            replacement = ${JSON.stringify(replacementModel)},`);
    if (skinValue !== '') properties.push(`            skin = ${skinValue},`);
    if (bodygroupsValue.length > 0) {
      properties.push(`            ${bodygroupsField} = {`);
      bodygroupsValue.forEach((entry) => {
        const formattedKey = /^\d+$/.test(entry.key) ? `[${entry.key}]` : entry.key;
        properties.push(`                ${formattedKey} = ${entry.value},`);
      });
      properties.push('            }');
    }
    properties.push('        }');
    properties.push('    }');
  } else {
    properties.push(`    replacement = ${JSON.stringify(replacementModel)},`);
    if (skinValue !== '') properties.push(`    skin = ${skinValue},`);
    if (bodygroupsValue.length > 0) {
      properties.push(`    ${bodygroupsField} = {`);
      bodygroupsValue.forEach((entry) => {
        const formattedKey = /^\d+$/.test(entry.key) ? `[${entry.key}]` : entry.key;
        properties.push(`        ${formattedKey} = ${entry.value},`);
      });
      properties.push('    }');
    }
  }

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
  document.getElementById('source-model').value = 'models/player/group01/male_07.mdl';
  document.getElementById('replacement-model').value = 'models/player/corpse1.mdl';
  document.getElementById('skin-value').value = '2';
  document.getElementById('bodygroups-list').innerHTML = '';
  addBodygroupRow('1', '2');
  addBodygroupRow('helmet', '0');
  document.getElementById('bodygroups-field').value = 'bodyGroups';
  document.getElementById('armor-value').value = '25';
  document.getElementById('outfit-category').value = 'hazmat';
  document.getElementById('attrib-boosts-list').innerHTML = '';
  addAttribBoostRow('endurance', '3');
  addAttribBoostRow('strength', '1');
  document.getElementById('pac-data').value = '';

  generateOutfitItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  if (!document.querySelector('#attrib-boosts-list .dynamic-row')) {
    addAttribBoostRow('endurance', '3');
    addAttribBoostRow('strength', '1');
  }

  if (!document.querySelector('#bodygroups-list .dynamic-row')) {
    addBodygroupRow('1', '1');
    addBodygroupRow('helmet', '0');
  }

  generateOutfitItem();
});
</script>
