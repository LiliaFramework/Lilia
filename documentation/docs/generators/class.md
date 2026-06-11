# Class Generator

Create specialized battalions inside a faction, such as medics, officers, or other role-focused subgroups. Classes are the right layer for role-specific models, weapons, bodygroups, permissions, limits, and spawn behavior without changing character-specific data more than necessary.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_classes.lua
```

You can also add callback fields like `OnCanBe`, `OnSet`, `OnTransferred`, `OnLeave`, `OnSpawn`, or any custom logic manually after generation. You can find those in [Class Definitions](../definitions/class.md).

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-index">Class Index:</label>
          <input type="text" id="class-index" placeholder="e.g., CLASS_POLICEOFFICER">
          <small>The constant name you want to assign to the registered class index.</small>
        </div>

        <div class="input-group">
          <label for="class-faction">Faction Index:</label>
          <input type="text" id="class-faction" placeholder="e.g., FACTION_POLICE">
          <small>The faction this class belongs to.</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-name">Class Name:</label>
          <input type="text" id="class-name" placeholder="e.g., Police Officer">
        </div>

        <div class="input-group">
          <label for="class-desc">Description:</label>
          <textarea id="class-desc" placeholder="e.g., A law enforcement officer..."></textarea>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label>
            <input type="checkbox" id="is-whitelisted"> Whitelist Required
          </label>
          <small>Players need to be whitelisted before they can join this class.</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="is-default"> Is Default Class
          </label>
          <small>Automatically assigned to new characters in this faction. Only one class per faction should have this set.</small>
        </div>

        <div class="input-group">
          <label for="class-limit">Player Limit:</label>
          <input type="number" id="class-limit" placeholder="0" min="0">
          <small>How many players can be in this class at once. 0 means unlimited.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Model:</label>
        <div id="models-list" class="dynamic-list"></div>
        <button onclick="addModelRow()" class="add-btn">+ Add Model</button>
        <small>The model or models this class can use.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-color-picker">Color (R,G,B):</label>
          <div class="color-input-row">
            <input type="color" id="class-color-picker" value="#000000">
            <input type="text" id="class-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
          </div>
          <small>Use three numbers from 0 to 255. Leave empty to use the faction color.</small>
        </div>

        <div class="input-group">
          <label for="class-skin">Skin:</label>
          <input type="number" id="class-skin" placeholder="0" min="0">
          <small>Default skin number for this class.</small>
        </div>
      </div>

      <div class="input-group">
        <label>Default Bodygroups:</label>
        <div id="bodygroups-list" class="dynamic-list"></div>
        <button onclick="addBodygroupRow()" class="add-btn">+ Add Bodygroup</button>
        <small>Bodygroup values this class should use by default. You can retrieve these in-game with the `viewbodygroups` UI, which includes a copy option.</small>
      </div>

      <div class="input-group">
        <label>Default Sub-Materials:</label>
        <div id="submaterials-list" class="dynamic-list"></div>
        <button onclick="addSubMaterialRow()" class="add-btn">+ Add Sub-Material</button>
        <small>Material overrides this class should use by default.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-logo">Logo:</label>
          <input type="text" id="class-logo" placeholder="materials/ui/class/police_logo.png">
          <small>Logo shown for this class. You can use a material path or a web URL.</small>
        </div>

        <div class="input-group">
          <label for="class-scale">Model Scale:</label>
          <input type="number" id="class-scale" placeholder="1.0" step="0.1" min="0.1">
          <small>Character size. Leave empty for normal size.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-health">Health:</label>
          <input type="number" id="class-health" placeholder="" min="1">
          <small>Health for this class.</small>
        </div>

        <div class="input-group">
          <label for="class-armor">Armor:</label>
          <input type="number" id="class-armor" placeholder="" min="0">
          <small>Armor for this class.</small>
        </div>

        <div class="input-group">
          <label for="class-pay">Pay/Salary:</label>
          <input type="number" id="class-pay" placeholder="" min="0">
          <small>How much this class gets paid each paycheck.</small>
        </div>

        <div class="input-group">
          <label for="class-pay-timer">Pay Timer (seconds):</label>
          <input type="number" id="class-pay-timer" placeholder="" min="1">
          <small>How often this class gets paid. Leave empty to use the faction or server salary timer.</small>
        </div>

        <div class="input-group">
          <label for="class-bloodcolor">Blood Color:</label>
          <select id="class-bloodcolor">
            <option value="">Default (BLOOD_COLOR_RED)</option>
            <option value="BLOOD_COLOR_RED">BLOOD_COLOR_RED</option>
            <option value="BLOOD_COLOR_YELLOW">BLOOD_COLOR_YELLOW</option>
            <option value="BLOOD_COLOR_GREEN">BLOOD_COLOR_GREEN</option>
            <option value="BLOOD_COLOR_MECH">BLOOD_COLOR_MECH</option>
            <option value="BLOOD_COLOR_ANTLION">BLOOD_COLOR_ANTLION</option>
            <option value="BLOOD_COLOR_ZOMBIE">BLOOD_COLOR_ZOMBIE</option>
          </select>
          <small>Blood color used for this class. Leave default for normal human characters.</small>
        </div>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-run-speed">Run Speed Multiplier:</label>
          <input type="number" id="class-run-speed" placeholder="1" min="0" step="0.01">
          <small>Run speed multiplier. Use 1 for normal speed.</small>
        </div>

        <div class="input-group">
          <label for="class-walk-speed">Walk Speed Multiplier:</label>
          <input type="number" id="class-walk-speed" placeholder="1" min="0" step="0.01">
          <small>Walk speed multiplier. Use 1 for normal speed.</small>
        </div>

        <div class="input-group">
          <label for="class-jump-power">Jump Power Multiplier:</label>
          <input type="number" id="class-jump-power" placeholder="1" min="0" step="0.01">
          <small>Jump multiplier. Use 1 for normal jump height.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Weapons:</label>
        <div id="weapons-list" class="dynamic-list"></div>
        <button onclick="addWeaponRow()" class="add-btn">+ Add Weapon</button>
        <small>Weapons this class receives on spawn.</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>
          <input type="checkbox" id="class-scoreboard-hidden"> Hidden from Scoreboard
        </label>
        <small>If true, this class is not shown as a row in the scoreboard.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
        <label>
          <input type="checkbox" id="class-can-invite-faction"> Can Invite to Faction
        </label>
          <small>Members of this class can invite players to the faction.</small>
        </div>

        <div class="input-group">
        <label>
          <input type="checkbox" id="class-can-invite-class"> Can Invite to Class
        </label>
          <small>Members of this class can invite players to classes.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>NPC Relations:</label>
        <div id="npc-relations-list" class="dynamic-list"></div>
        <button onclick="addNPCRelationRow()" class="add-btn">+ Add NPC Relation</button>
        <small>How NPCs react to this class.</small>
      </div>

      <div class="input-group">
        <label>Commands:</label>
        <div id="commands-list" class="dynamic-list"></div>
        <button onclick="addCommandRow()" class="add-btn">+ Add Command</button>
        <small>Command names that members of this class can execute, bypassing normal privilege checks.</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateClass()" class="generate-btn">Generate Class Code</button>
      <button onclick="fillExampleClass()" class="generate-btn example-btn">Generate Example</button>
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
// Helper to create a generic text input row
function addTextRow(containerId, placeholder, value = '') {
  const container = document.getElementById(containerId);
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" value="${value}" placeholder="${placeholder}" class="list-input">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

function addCommandRow(val='') { addTextRow('commands-list', 'kick', val); }

function addWeaponRow(val='') { addTextRow('weapons-list', 'weapon_class', val); }
function addModelRow(val='') { addTextRow('models-list', 'models/player/...', val); }

function addBodygroupRow(id='', value='') {
  const container = document.getElementById('bodygroups-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="number" placeholder="ID" value="${id}" min="0" class="bg-id small-input">
  <input type="number" placeholder="Value" value="${value}" min="0" class="bg-value small-input">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

function addSubMaterialRow(slot='', mat='') {
  const container = document.getElementById('submaterials-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="number" placeholder="Slot (1-indexed)" value="${slot}" min="1" class="sm-slot small-input">
  <input type="text" placeholder="materials/..." value="${mat}" class="sm-mat">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

function addNPCRelationRow(npc='', disposition='D_HT') {
  const container = document.getElementById('npc-relations-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="npc_combine_s" value="${npc}" class="npc-class" style="flex:1; min-width:0;">
  <select class="npc-disp" style="width:auto; flex-shrink:0;">
    <option value="D_HT"${disposition==='D_HT'?' selected':''}>D_HT (Hostile)</option>
    <option value="D_LI"${disposition==='D_LI'?' selected':''}>D_LI (Like)</option>
    <option value="D_FR"${disposition==='D_FR'?' selected':''}>D_FR (Fear)</option>
    <option value="D_NU"${disposition==='D_NU'?' selected':''}>D_NU (Neutral)</option>
  </select>
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

function getBodygroupValues() {
  const rows = document.querySelectorAll('#bodygroups-list .dynamic-row');
  const groups = [];
  rows.forEach(row => {
    const id = row.querySelector('.bg-id').value.trim();
    const value = row.querySelector('.bg-value').value.trim();
    if (id !== '') groups.push({ id, value: value !== '' ? value : '0' });
  });
  return groups;
}

function getSubMaterialValues() {
  const rows = document.querySelectorAll('#submaterials-list .dynamic-row');
  const mats = [];
  rows.forEach(row => {
    const slot = row.querySelector('.sm-slot').value.trim();
    const mat = row.querySelector('.sm-mat').value.trim();
    if (slot && mat) mats.push({ slot: parseInt(slot, 10), mat });
  });
  return mats;
}

function getNPCRelationValues() {
  const rows = document.querySelectorAll('#npc-relations-list .dynamic-row');
  const relations = [];
  rows.forEach(row => {
    const npc = row.querySelector('.npc-class').value.trim();
    const disp = row.querySelector('.npc-disp').value;
    if (npc) relations.push({ npc, disp });
  });
  return relations;
}

function getListValues(containerId) {
  return Array.from(document.querySelectorAll(`#${containerId} .list-input`))
  .map(input => input.value.trim())
  .filter(val => val !== '');
}

function getCommandValues() {
  return Array.from(document.querySelectorAll('#commands-list .list-input'))
  .map(input => input.value.trim())
  .filter(val => val !== '');
}

function toLuaIdentifier(value, prefix) {
  return (value || '')
  .trim()
  .toLowerCase()
  .replace(new RegExp(`^${prefix}_`), '')
  .replace(/[^a-z0-9]+/g, '_')
  .replace(/^_+|_+$/g, '') || `${prefix.toLowerCase()}_name`;
}

function generateClass() {
  const DEFAULTS = {
    limit: '0',
    health: '100',
    armor: '0',
    pay: '0',
    payTimer: '0',
    runSpeed: '1',
    walkSpeed: '1',
    jumpPower: '1',
    scale: '1',
    scaleAlt: '1.0'
  };
  const index = (document.getElementById('class-index').value || '').trim() || 'CLASS_NAME';
  const name = (document.getElementById('class-name').value || '').trim() || 'Class Name';
  const desc = (document.getElementById('class-desc').value || '').trim() || 'Class description';
  const faction = document.getElementById('class-faction').value || 'FACTION_NAME';
  const uniqueIDSource = index && index !== 'CLASS_NAME' ? index : name;
  const uniqueID = toLuaIdentifier(uniqueIDSource, 'class');
  const colorInput = document.getElementById('class-color').value.trim();
  const skin = document.getElementById('class-skin').value.trim();

  const isWhitelisted = document.getElementById('is-whitelisted').checked;
  const isDefault = document.getElementById('is-default').checked;
  const limit = document.getElementById('class-limit').value || DEFAULTS.limit;

  const health = document.getElementById('class-health').value.trim();
  const armor = document.getElementById('class-armor').value.trim();
  const pay = document.getElementById('class-pay').value.trim();
  const payTimer = document.getElementById('class-pay-timer').value.trim();
  const runSpeed = document.getElementById('class-run-speed').value.trim();
  const walkSpeed = document.getElementById('class-walk-speed').value.trim();
  const jumpPower = document.getElementById('class-jump-power').value.trim();
  const scale = document.getElementById('class-scale').value.trim();
  const logo = document.getElementById('class-logo').value.trim();
  const bloodcolor = document.getElementById('class-bloodcolor').value;
  const scoreboardHidden = document.getElementById('class-scoreboard-hidden').checked;
  const canInviteFaction = document.getElementById('class-can-invite-faction').checked;
  const canInviteClass = document.getElementById('class-can-invite-class').checked;

  // Harvest dynamic lists
  const models = getListValues('models-list');
  const weapons = getListValues('weapons-list');
  const commands = getCommandValues();
  const bodyGroups = getBodygroupValues();
  const subMaterials = getSubMaterialValues();
  const npcRelations = getNPCRelationValues();

  const lines = [
  `${index} = lia.class.register(${JSON.stringify(uniqueID)}, {`,
  `    name = ${JSON.stringify(name)},`,
  `    desc = ${JSON.stringify(desc)},`,
  `    faction = ${faction},`
  ];

  const hasCustomScale = scale && scale !== DEFAULTS.scale && scale !== DEFAULTS.scaleAlt;

  if (isWhitelisted || isDefault || limit !== DEFAULTS.limit) {
  lines.push('');
  if (isWhitelisted) lines.push('    isWhitelisted = true,');
  if (isDefault) lines.push('    isDefault = true,');
  if (limit !== DEFAULTS.limit) lines.push(`    limit = ${limit},`);
  }

  if (models.length > 0 || colorInput || skin || logo || hasCustomScale || bodyGroups.length > 0 || subMaterials.length > 0) {
  lines.push('');
  if (models.length === 1) {
  lines.push(`    model = ${JSON.stringify(models[0])},`);
  } else if (models.length > 1) {
  lines.push('    models = {');
  models.forEach(m => lines.push(`        ${JSON.stringify(m)},`));
  lines.push('    },');
  }
  if (colorInput) {
  lines.push(`    color = Color(${colorInput}),`);
  }
  if (skin) lines.push(`    skin = ${skin},`);
  if (logo) lines.push(`    logo = ${JSON.stringify(logo)},`);
  if (hasCustomScale) lines.push(`    scale = ${scale},`);
  if (bodyGroups.length > 0) {
  lines.push('    bodyGroups = {');
  bodyGroups.forEach(bg => lines.push(`        {id = ${bg.id}, value = ${bg.value}},`));
  lines.push('    },');
  }
  if (subMaterials.length > 0) {
  // Build a sparse array keyed by slot index (1-indexed)
  const maxSlot = Math.max(...subMaterials.map(s => s.slot));
  lines.push('    subMaterials = {');
  for (let i = 1; i <= maxSlot; i++) {
    const entry = subMaterials.find(s => s.slot === i);
    lines.push(`        ${entry ? JSON.stringify(entry.mat) : 'nil'},`);
  }
  lines.push('    },');
  }
  }

  const hasCustomStats = (health && health !== DEFAULTS.health) ||
    (armor && armor !== DEFAULTS.armor) ||
    (pay && pay !== DEFAULTS.pay) ||
    (payTimer && payTimer !== DEFAULTS.payTimer) ||
    (runSpeed && runSpeed !== DEFAULTS.runSpeed) ||
    (walkSpeed && walkSpeed !== DEFAULTS.walkSpeed) ||
    (jumpPower && jumpPower !== DEFAULTS.jumpPower) ||
    bloodcolor;

  if (hasCustomStats) {
  lines.push('');
  if (health && health !== DEFAULTS.health) lines.push(`    health = ${health},`);
  if (armor && armor !== DEFAULTS.armor) lines.push(`    armor = ${armor},`);
  if (pay && pay !== DEFAULTS.pay) lines.push(`    pay = ${pay},`);
  if (payTimer && payTimer !== DEFAULTS.payTimer) lines.push(`    payTimer = ${payTimer},`);
  if (runSpeed && runSpeed !== DEFAULTS.runSpeed) lines.push(`    runSpeed = ${runSpeed},`);
  if (walkSpeed && walkSpeed !== DEFAULTS.walkSpeed) lines.push(`    walkSpeed = ${walkSpeed},`);
  if (jumpPower && jumpPower !== DEFAULTS.jumpPower) lines.push(`    jumpPower = ${jumpPower},`);
  if (bloodcolor) lines.push(`    bloodcolor = ${bloodcolor},`);
  }

  if (weapons.length > 0) {
  lines.push('', '    weapons = {');
  weapons.forEach(weapon => {
  lines.push(`        ${JSON.stringify(weapon.trim())},`);
  });
  lines.push('    },');
  }

  if (npcRelations.length > 0) {
  lines.push('', '    NPCRelations = {');
  npcRelations.forEach(r => {
  lines.push(`        [${JSON.stringify(r.npc)}] = ${r.disp},`);
  });
  lines.push('    },');
  }

  if (scoreboardHidden || canInviteFaction || canInviteClass || commands.length > 0) {
  lines.push('');
  if (scoreboardHidden) lines.push('    scoreboardHidden = true,');
  if (canInviteFaction) lines.push('    canInviteToFaction = true,');
  if (canInviteClass) lines.push('    canInviteToClass = true,');
  if (commands.length > 0) {
  lines.push('    commands = {');
  commands.forEach(cmd => {
  lines.push(`        ${JSON.stringify(cmd)},`);
  });
  lines.push('    },');
  }
  }

  lines.push('})');

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleClass() {
  document.getElementById('class-index').value = 'CLASS_MP_OFFICER';
  document.getElementById('class-name').value = 'MP Officer';
  document.getElementById('class-desc').value = 'A disciplined Military Police officer responsible for internal security and law enforcement within the military.';
  document.getElementById('class-faction').value = 'FACTION_MILITARY';
  document.getElementById('is-whitelisted').checked = true;
  document.getElementById('is-default').checked = false;
  document.getElementById('class-limit').value = '4';

  // Clear lists
  document.getElementById('models-list').innerHTML = '';
  document.getElementById('weapons-list').innerHTML = '';
  document.getElementById('bodygroups-list').innerHTML = '';
  document.getElementById('submaterials-list').innerHTML = '';
  document.getElementById('npc-relations-list').innerHTML = '';
  document.getElementById('commands-list').innerHTML = '';

  addModelRow('models/player/police.mdl');
  addWeaponRow('weapon_pistol');
  addWeaponRow('weapon_stunstick');
  addCommandRow('kick');

  document.getElementById('class-color').value = '40, 100, 200';
  document.getElementById('class-color-picker').value = rgbTextToHex('40, 100, 200');
  document.getElementById('class-skin').value = '1';
  document.getElementById('class-logo').value = 'materials/ui/class/mp_logo.png';
  document.getElementById('class-scale').value = '1.0';
  document.getElementById('class-health').value = '120';
  document.getElementById('class-armor').value = '50';
  document.getElementById('class-pay').value = '75';
  document.getElementById('class-pay-timer').value = '180';
  document.getElementById('class-run-speed').value = '1';
  document.getElementById('class-walk-speed').value = '1';
  document.getElementById('class-jump-power').value = '1';
  document.getElementById('class-scoreboard-hidden').checked = false;
  document.getElementById('class-can-invite-faction').checked = true;
  document.getElementById('class-can-invite-class').checked = true;

  generateClass();
}

function rgbTextToHex(text) {
  const parts = text.split(',').map(s => parseInt(s.trim(), 10));
  if (parts.length !== 3 || parts.some(isNaN)) return null;
  return '#' + parts.map(v => Math.max(0, Math.min(255, v)).toString(16).padStart(2, '0')).join('');
}

function hexToRgbText(hex) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `${r}, ${g}, ${b}`;
}

// Initialize default rows
document.addEventListener('DOMContentLoaded', () => {
  const picker = document.getElementById('class-color-picker');
  const text = document.getElementById('class-color');

  picker.addEventListener('input', () => {
    text.value = hexToRgbText(picker.value);
    generateClass();
  });

  text.addEventListener('input', () => {
    const hex = rgbTextToHex(text.value);
    if (hex) picker.value = hex;
    generateClass();
  });

  addWeaponRow('weapon_pistol');
  addCommandRow('kick');
  generateClass();
});


</script>
