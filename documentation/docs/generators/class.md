# Class Generator

Create sub-roles and specialized classes for your factions, such as 'Medic' or 'Officer'.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom class. Once generated, the code should be placed in a new file within your schema's classes directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/classes/[class_name].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-index">Class Index:</label>
          <input type="text" id="class-index" placeholder="e.g., CLASS_POLICEOFFICER">
          <small>The unique identifier for this class (e.g., CLASS_POLICEOFFICER)</small>
        </div>

        <div class="input-group">
          <label for="class-faction">Faction Index:</label>
          <input type="text" id="class-faction" placeholder="e.g., FACTION_POLICE">
          <small>The faction index this class belongs to (e.g., FACTION_POLICE)</small>
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
          <small>Joining requires an admin to grant access via /classwhitelist. Has no effect if Is Default is also set.</small>
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
          <small>Max concurrent players in this class. 0 = unlimited.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Model:</label>
        <div id="models-list" class="dynamic-list"></div>
        <button onclick="addModelRow()" class="add-btn">+ Add Model</button>
        <small>Model path(s). A single entry sets one model; multiple entries let players pick from the list.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-color">Color (R,G,B):</label>
          <input type="text" id="class-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
          <small>Comma-separated RGB values (0-255). Leave empty to use faction color.</small>
        </div>

        <div class="input-group">
          <label for="class-skin">Skin:</label>
          <input type="number" id="class-skin" placeholder="0" min="0">
          <small>Skin index applied to the class model preview. Default is 0.</small>
        </div>
      </div>

      <div class="input-group">
        <label>Bodygroup Overrides:</label>
        <div id="bodygroups-list" class="dynamic-list"></div>
        <button onclick="addBodygroupRow()" class="add-btn">+ Add Bodygroup</button>
        <small>Bodygroup overrides applied to the model preview. Each entry is an ID and value pair.</small>
      </div>

      <div class="input-group">
        <label>Sub-Material Overrides:</label>
        <div id="submaterials-list" class="dynamic-list"></div>
        <button onclick="addSubMaterialRow()" class="add-btn">+ Add Sub-Material</button>
        <small>Material path per slot (1-indexed). Each entry calls SetSubMaterial(slot - 1, mat) on the preview entity.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-logo">Logo:</label>
          <input type="text" id="class-logo" placeholder="materials/ui/class/police_logo.png">
          <small>Material path for the class logo displayed in the scoreboard.</small>
        </div>

        <div class="input-group">
          <label for="class-scale">Model Scale:</label>
          <input type="number" id="class-scale" placeholder="1.0" step="0.1" min="0.1">
          <small>Model scale multiplier. Also adjusts view offset proportionally. Default is 1.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-health">Health:</label>
          <input type="number" id="class-health" placeholder="" min="1">
          <small>Base health. Overrides faction value when set.</small>
        </div>

        <div class="input-group">
          <label for="class-armor">Armor:</label>
          <input type="number" id="class-armor" placeholder="" min="0">
          <small>Base armor. Overrides faction value when set.</small>
        </div>

        <div class="input-group">
          <label for="class-pay">Pay/Salary:</label>
          <input type="number" id="class-pay" placeholder="" min="0">
          <small>Salary amount per paycheck. Overrides faction pay when set.</small>
        </div>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-run-speed">Run Speed:</label>
          <input type="number" id="class-run-speed" placeholder="" min="1">
          <label><input type="checkbox" id="class-run-speed-multiplier"> Use as multiplier</label>
          <small>Overrides faction value. When multiplier is checked, multiplies against the config default.</small>
        </div>

        <div class="input-group">
          <label for="class-walk-speed">Walk Speed:</label>
          <input type="number" id="class-walk-speed" placeholder="" min="1">
          <label><input type="checkbox" id="class-walk-speed-multiplier"> Use as multiplier</label>
          <small>Overrides faction value. When multiplier is checked, multiplies against the config default.</small>
        </div>

        <div class="input-group">
          <label for="class-jump-power">Jump Power:</label>
          <input type="number" id="class-jump-power" placeholder="" min="1">
          <label><input type="checkbox" id="class-jump-power-multiplier"> Use as multiplier</label>
          <small>Overrides faction value. When multiplier is checked, multiplies against the player's current jump power.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Weapons:</label>
        <div id="weapons-list" class="dynamic-list"></div>
        <button onclick="addWeaponRow()" class="add-btn">+ Add Weapon</button>
        <small>Weapons given on spawn. Additive with faction weapons — both sets are given, this does not replace them.</small>
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
          <small>Players in this class can use the faction invite system without needing the Z privilege flag.</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="class-can-invite-class"> Can Invite to Class
          </label>
          <small>Players in this class can use the class invite system without needing the X privilege flag.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Team Tag:</label>
        <div id="team-list" class="dynamic-list"></div>
        <button onclick="addTeamRow()" class="add-btn">+ Set Team Tag</button>
        <small>Arbitrary group tag for door access. Classes sharing the same tag can open the same class-restricted doors.</small>
      </div>

      <div class="input-group">
        <label>NPC Relations:</label>
        <div id="npc-relations-list" class="dynamic-list"></div>
        <button onclick="addNPCRelationRow()" class="add-btn">+ Add NPC Relation</button>
        <small>When set, replaces all faction NPC relations entirely. Absent = all NPCs are hostile (D_HT) by default.</small>
      </div>

      <div class="input-group">
        <label>Commands:</label>
        <div id="commands-list" class="dynamic-list"></div>
        <button onclick="addCommandRow()" class="add-btn">+ Add Command</button>
        <small>Command names (registered via lia.command.add) that members of this class can execute, bypassing normal privilege checks.</small>
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
function addTeamRow(val='') { addTextRow('team-list', 'e.g., security', val); }

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
  <input type="text" placeholder="npc_combine_s" value="${npc}" class="npc-class">
  <select class="npc-disp">
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

function generateClass() {
  const index = (document.getElementById('class-index').value || '').trim() || 'CLASS_NAME';
  const name = (document.getElementById('class-name').value || '').trim() || 'Class Name';
  const desc = (document.getElementById('class-desc').value || '').trim() || 'Class description';
  const faction = document.getElementById('class-faction').value || 'FACTION_NAME';
  // const model = document.getElementById('class-model').value.trim();
  const colorInput = document.getElementById('class-color').value.trim();
  const skin = document.getElementById('class-skin').value.trim();

  const isWhitelisted = document.getElementById('is-whitelisted').checked;
  const isDefault = document.getElementById('is-default').checked;
  const limit = document.getElementById('class-limit').value || '0';

  const health = document.getElementById('class-health').value.trim();
  const armor = document.getElementById('class-armor').value.trim();
  const pay = document.getElementById('class-pay').value.trim();
  const runSpeed = document.getElementById('class-run-speed').value.trim();
  const runSpeedMultiplier = document.getElementById('class-run-speed-multiplier').checked;
  const walkSpeed = document.getElementById('class-walk-speed').value.trim();
  const walkSpeedMultiplier = document.getElementById('class-walk-speed-multiplier').checked;
  const jumpPower = document.getElementById('class-jump-power').value.trim();
  const jumpPowerMultiplier = document.getElementById('class-jump-power-multiplier').checked;
  const scale = document.getElementById('class-scale').value.trim();
  const logo = document.getElementById('class-logo').value.trim();
  const scoreboardHidden = document.getElementById('class-scoreboard-hidden').checked;
  const canInviteFaction = document.getElementById('class-can-invite-faction').checked;
  const canInviteClass = document.getElementById('class-can-invite-class').checked;

  // Harvest dynamic lists
  const models = getListValues('models-list');
  const weapons = getListValues('weapons-list');
  const commands = getCommandValues();
  const teamValues = getListValues('team-list');
  const team = teamValues.length > 0 ? teamValues[0] : '';
  const bodyGroups = getBodygroupValues();
  const subMaterials = getSubMaterialValues();
  const npcRelations = getNPCRelationValues();

  const lines = [
  '-- Copy and paste this code into your class file',
  '-- Example: [schema folder]/classes/police_officer.lua',
  '',
  `CLASS.name = ${JSON.stringify(name)}`,
  `CLASS.desc = ${JSON.stringify(desc)}`,
  `CLASS.faction = ${faction}`
  ];

  if (isWhitelisted || isDefault || limit !== '0') {
  lines.push('', '-- Access Control');
  if (isWhitelisted) lines.push('CLASS.isWhitelisted = true');
  if (isDefault) lines.push('CLASS.isDefault = true');
  if (limit !== '0') lines.push(`CLASS.limit = ${limit}`);
  }

  if (models.length > 0 || colorInput || skin || logo || scale || bodyGroups.length > 0 || subMaterials.length > 0) {
  lines.push('', '-- Visual Properties');
  if (models.length === 1) {
  lines.push(`CLASS.model = ${JSON.stringify(models[0])}`);
  } else if (models.length > 1) {
  lines.push('CLASS.model = {');
  models.forEach(m => lines.push(` ${JSON.stringify(m)},`));
  lines.push('}');
  }
  if (colorInput) {
  lines.push(`CLASS.color = Color(${colorInput})`);
  }
  if (skin) lines.push(`CLASS.skin = ${skin}`);
  if (logo) lines.push(`CLASS.logo = ${JSON.stringify(logo)}`);
  if (scale) lines.push(`CLASS.scale = ${scale}`);
  if (bodyGroups.length > 0) {
  lines.push('CLASS.bodyGroups = {');
  bodyGroups.forEach(bg => lines.push(` {id = ${bg.id}, value = ${bg.value}},`));
  lines.push('}');
  }
  if (subMaterials.length > 0) {
  // Build a sparse array keyed by slot index (1-indexed)
  const maxSlot = Math.max(...subMaterials.map(s => s.slot));
  lines.push('CLASS.subMaterials = {');
  for (let i = 1; i <= maxSlot; i++) {
    const entry = subMaterials.find(s => s.slot === i);
    lines.push(` ${entry ? JSON.stringify(entry.mat) : 'nil'},`);
  }
  lines.push('}');
  }
  }

  if (health || armor || pay || runSpeed || walkSpeed || jumpPower) {
  lines.push('', '-- Gameplay Properties');
  if (health) lines.push(`CLASS.health = ${health}`);
  if (armor) lines.push(`CLASS.armor = ${armor}`);
  if (pay) lines.push(`CLASS.pay = ${pay}`);
  if (runSpeed) {
  lines.push(`CLASS.runSpeed = ${runSpeed}`);
  if (runSpeedMultiplier) lines.push('CLASS.runSpeedMultiplier = true');
  }
  if (walkSpeed) {
  lines.push(`CLASS.walkSpeed = ${walkSpeed}`);
  if (walkSpeedMultiplier) lines.push('CLASS.walkSpeedMultiplier = true');
  }
  if (jumpPower) {
  lines.push(`CLASS.jumpPower = ${jumpPower}`);
  if (jumpPowerMultiplier) lines.push('CLASS.jumpPowerMultiplier = true');
  }
  }

  if (weapons.length > 0) {
  lines.push('', '-- Weapons', 'CLASS.weapons = {');
  weapons.forEach(weapon => {
  lines.push(` ${JSON.stringify(weapon.trim())},`);
  });
  lines.push('}');
  }

  if (npcRelations.length > 0) {
  lines.push('', '-- NPC Relations', 'CLASS.NPCRelations = {');
  npcRelations.forEach(r => {
  lines.push(` [${JSON.stringify(r.npc)}] = ${r.disp},`);
  });
  lines.push('}');
  }

  if (scoreboardHidden || canInviteFaction || canInviteClass || team || commands.length > 0) {
  lines.push('', '-- UI & Advanced');
  if (scoreboardHidden) lines.push('CLASS.scoreboardHidden = true');
  if (canInviteFaction) lines.push('CLASS.canInviteToFaction = true');
  if (canInviteClass) lines.push('CLASS.canInviteToClass = true');
  if (team) lines.push(`CLASS.team = ${JSON.stringify(team)}`);

  if (commands.length > 0) {
  lines.push('CLASS.commands = {');
  commands.forEach(cmd => {
  lines.push(` ${JSON.stringify(cmd)},`);
  });
  lines.push('}');
  }
  }

  lines.push('', `${index} = CLASS.index`);

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
  document.getElementById('team-list').innerHTML = '';
  document.getElementById('npc-relations-list').innerHTML = '';
  document.getElementById('commands-list').innerHTML = '';

  addModelRow('models/player/police.mdl');
  addWeaponRow('weapon_pistol');
  addWeaponRow('weapon_stunstick');
  addCommandRow('kick');

  document.getElementById('class-color').value = '40, 100, 200';
  document.getElementById('class-skin').value = '1';
  document.getElementById('class-logo').value = 'materials/ui/class/mp_logo.png';
  document.getElementById('class-scale').value = '1.0';
  document.getElementById('class-health').value = '120';
  document.getElementById('class-armor').value = '50';
  document.getElementById('class-pay').value = '75';
  document.getElementById('class-run-speed').value = '280';
  document.getElementById('class-run-speed-multiplier').checked = false;
  document.getElementById('class-walk-speed').value = '150';
  document.getElementById('class-walk-speed-multiplier').checked = false;
  document.getElementById('class-jump-power').value = '200';
  document.getElementById('class-jump-power-multiplier').checked = false;
  document.getElementById('class-scoreboard-hidden').checked = false;
  document.getElementById('class-can-invite-faction').checked = true;
  document.getElementById('class-can-invite-class').checked = true;
  addTeamRow('security');

  generateClass();
}

// Initialize default rows
document.addEventListener('DOMContentLoaded', () => {
  addWeaponRow('weapon_pistol');
  addCommandRow('kick');
  generateClass();
});


</script>

---
