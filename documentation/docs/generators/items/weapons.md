# Weapon Item Generator

Create equippable weapon items that players can carry in their inventory and use in combat. Use this generator when a weapon should be visible to Lilia's inventory, vendor, storage, and balancing systems.

Lilia can automatically generate weapon items for registered weapon entities that do not have manual item definitions. Use this generator when you want to override that default behavior for a specific weapon class.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/items/weapons/[item_id].lua
```

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., ak47" value="ak47" oninput="generateWeaponItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., AK-47" value="AK-47 Rifle" oninput="generateWeaponItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A reliable Soviet assault rifle" oninput="generateWeaponItem()">A rugged and dependable gas-operated assault rifle, known for its stopping power and reliability in harsh conditions.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-model">Item Model (Inventory):</label>
          <input type="text" id="item-model" placeholder="models/weapons/w_rif_ak47.mdl" value="models/weapons/w_rif_ak47.mdl" oninput="generateWeaponItem()">
          <small>3D model path displayed in the inventory</small>
        </div>

        <div class="input-group">
          <label for="weapon-class">Weapon Class:</label>
          <input type="text" id="weapon-class" placeholder="e.g., weapon_ak47" value="weapon_ak47" oninput="generateWeaponItem()">
          <small>The weapon entity class that is given when equipped</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="4" oninput="generateWeaponItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="2" oninput="generateWeaponItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="weapon-category">Weapon Category:</label>
          <input type="text" id="weapon-category" placeholder="e.g., primary" value="" oninput="generateWeaponItem()">
          <small>Optional category key used to prevent equipping another weapon in the same slot</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="drop-on-death" checked oninput="generateWeaponItem()"> Drop On Death
          </label>
          <small>Controls the base `DropOnDeath` field</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="equip-sound">Equip Sound:</label>
          <input type="text" id="equip-sound" placeholder="items/ammo_pickup.wav" value="" oninput="generateWeaponItem()">
          <small>Optional sound override played when equipping</small>
        </div>

        <div class="input-group">
          <label for="unequip-sound">Unequip Sound:</label>
          <input type="text" id="unequip-sound" placeholder="items/ammo_pickup.wav" value="" oninput="generateWeaponItem()">
          <small>Optional sound override played when unequipping</small>
        </div>
      </div>

      <div class="input-group">
        <label for="required-skills">Required Skill Levels:</label>
        <textarea id="required-skills" placeholder="Optional. One per line, format: guns=5" oninput="generateWeaponItem()"></textarea>
        <small>Optional skill requirements written as <code>skill=value</code>, one per line</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateWeaponItem()" class="generate-btn">Generate Weapon Code</button>
      <button onclick="fillExampleWeapon()" class="generate-btn example-btn">Generate Example</button>
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
function parseRequiredSkills() {
  const raw = (document.getElementById('required-skills').value || '').trim();
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

function generateWeaponItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'weapon_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Weapon Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A combat weapon';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/weapons/w_rif_ak47.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const weaponClass = (document.getElementById('weapon-class').value || '').trim() || 'weapon_ak47';
  const weaponCategory = (document.getElementById('weapon-category').value || '').trim();
  const dropOnDeath = document.getElementById('drop-on-death').checked;
  const equipSound = (document.getElementById('equip-sound').value || '').trim();
  const unequipSound = (document.getElementById('unequip-sound').value || '').trim();
  const requiredSkills = parseRequiredSkills();

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    class = ${JSON.stringify(weaponClass)},`
  ];

  if (width !== '2') properties.splice(3, 0, `    width = ${width},`);
  if (height !== '2') properties.splice(width !== '2' ? 4 : 3, 0, `    height = ${height},`);
  if (weaponCategory) properties.push(`    weaponCategory = ${JSON.stringify(weaponCategory)},`);
  if (!dropOnDeath) properties.push('    DropOnDeath = false,');
  if (equipSound) properties.push(`    equipSound = ${JSON.stringify(equipSound)},`);
  if (unequipSound) properties.push(`    unequipSound = ${JSON.stringify(unequipSound)},`);
  if (requiredSkills.length > 0) {
    properties.push('    RequiredSkillLevels = {');
    requiredSkills.forEach((entry, index) => {
      const suffix = index === requiredSkills.length - 1 ? '' : ',';
      properties.push(`        ${entry.key} = ${entry.value}${suffix}`);
    });
    properties.push('    }');
  }

  const lines = [
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_weapons", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleWeapon() {
  document.getElementById('item-id').value = 'glock18';
  document.getElementById('item-name').value = 'Glock 18 Sidearm';
  document.getElementById('item-desc').value = 'A compact, selective-fire Austrian pistol. Extremely effective for close-quarters engagements.';
  document.getElementById('item-model').value = 'models/weapons/w_pist_glock18.mdl';
  document.getElementById('weapon-class').value = 'weapon_glock';
  document.getElementById('item-width').value = '2';
  document.getElementById('item-height').value = '1';
  document.getElementById('weapon-category').value = 'sidearm';
  document.getElementById('drop-on-death').checked = true;
  document.getElementById('equip-sound').value = 'items/ammo_pickup.wav';
  document.getElementById('unequip-sound').value = 'items/ammo_pickup.wav';
  document.getElementById('required-skills').value = 'guns=3';

  generateWeaponItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateWeaponItem();
});
</script>
