# Faction Generator

Define the core groups and teams that players can join on your server.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom faction. Once generated, the code should be placed in a new file within your schema's factions directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/factions/[faction_name].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="input-group">
        <label for="faction-index">Faction Index:</label>
        <input type="text" id="faction-index" placeholder="e.g., FACTION_POLICE">
        <small>The unique identifier for this faction (e.g., FACTION_POLICE)</small>
      </div>

      <div class="input-group">
        <label for="faction-name">Faction Name:</label>
        <input type="text" id="faction-name" placeholder="e.g., Police Department">
      </div>

      <div class="input-group">
        <label for="faction-desc">Description:</label>
        <textarea id="faction-desc" placeholder="e.g., Law enforcement officers responsible for maintaining order"></textarea>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="faction-color">Color (R,G,B):</label>
          <input type="text" id="faction-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
          <small>Comma-separated RGB values (0-255)</small>
        </div>

        <div class="input-group">
          <label for="faction-logo">Logo:</label>
          <input type="text" id="faction-logo" placeholder="materials/ui/faction/police_logo.png">
          <small>Logo material path or URL for scoreboard (leave empty for no logo)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label>
            <input type="checkbox" id="is-default" checked> Is Default Faction
          </label>
          <small>Can new characters join this faction by default?</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="one-char-only"> One Character Only
          </label>
          <small>Players can only have one character in this faction?</small>
        </div>

        <div class="input-group">
          <label for="faction-limit">Player Limit:</label>
          <input type="number" id="faction-limit" placeholder="0" min="0">
          <small>0 = unlimited, decimals = percentage of server (e.g., 0.1 = 10%)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Models:</label>
        <div id="models-list" class="dynamic-list"></div>
        <button onclick="addModelRow()" class="add-btn">+ Add Model</button>
        <small>Add player model paths</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="health">Health:</label>
          <input type="number" id="health" placeholder="100" min="1">
        </div>

        <div class="input-group">
          <label for="armor">Armor:</label>
          <input type="number" id="armor" placeholder="0" min="0">
        </div>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="run-speed">Run Speed:</label>
          <input type="number" id="run-speed" placeholder="280" min="1">
          <label><input type="checkbox" id="run-speed-multiplier"> Use as multiplier</label>
        </div>

        <div class="input-group">
          <label for="walk-speed">Walk Speed:</label>
          <input type="number" id="walk-speed" placeholder="150" min="1">
          <label><input type="checkbox" id="walk-speed-multiplier"> Use as multiplier</label>
        </div>

        <div class="input-group">
          <label for="jump-power">Jump Power:</label>
          <input type="number" id="jump-power" placeholder="200" min="1">
          <label><input type="checkbox" id="jump-power-multiplier"> Use as multiplier</label>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="pay">Pay/Salary:</label>
          <input type="number" id="pay" placeholder="0" min="0">
          <small>Currency amount per paycheck</small>
        </div>

        <div class="input-group">
          <label for="pay-timer">Pay Timer (seconds):</label>
          <input type="number" id="pay-timer" placeholder="300" min="1">
          <small>Interval in seconds between paychecks (defaults to global salary interval if not set)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Weapons:</label>
        <div id="weapons-list" class="dynamic-list"></div>
        <button onclick="addWeaponRow()" class="add-btn">+ Add Weapon</button>
        <small>Add weapon classes</small>
      </div>

      <div class="input-group">
        <label>Starting Items:</label>
        <div id="items-list" class="dynamic-list"></div>
        <button onclick="addItemRow()" class="add-btn">+ Add Item</button>
        <small>Add item unique IDs</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>
          <input type="checkbox" id="recognizes-globally"> Recognizes Globally
        </label>
        <small>Members are always globally recognized</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="globally-recognized"> Globally Recognized
        </label>
        <small>Faction is globally recognizable to others</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="member-auto-recognition"> Member Auto-Recognition
        </label>
        <small>Members automatically recognize each other</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="scoreboard-hidden"> Hidden from Scoreboard
        </label>
        <small>Faction won't appear in scoreboard categories</small>
      </div>

      <div class="input-group">
        <label for="scoreboard-priority">Scoreboard Priority:</label>
        <input type="number" id="scoreboard-priority" placeholder="999" min="1">
        <small>Lower numbers appear first in scoreboard (default: 999)</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Custom Spawns:</label>
        <div id="spawns-list" class="dynamic-list"></div>
        <button onclick="addSpawnRow()" class="add-btn">+ Add Spawn Point</button>
        <small>Map Name, Position Vector, Angle</small>
      </div>

      <div class="input-group">
        <label>Main Menu Position:</label>
        <div id="main-menu-list" class="dynamic-list"></div>
        <button onclick="addMainMenuRow()" class="add-btn">+ Add Main Menu Position</button>
        <small>Map Name (leave empty for all), Position Vector, Angle</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Commands:</label>
        <div id="commands-list" class="dynamic-list"></div>
        <button onclick="addCommandRow()" class="add-btn">+ Add Command</button>
        <small>Command Name, Enabled</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateFaction()" class="generate-btn">Generate Faction Code</button>
      <button onclick="fillExampleFaction()" class="generate-btn example-btn">Generate Example</button>
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
  <input type="text" value="${value}" placeholder="${placeholder}">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

// Helper to create a spawn row (Map, Pos, Ang)
function addSpawnRow(map='', pos='', ang='') {
  const container = document.getElementById('spawns-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="Map Name (e.g. gm_construct)" value="${map}" class="spawn-map small-input">
  <input type="text" placeholder="Vector(0,0,0)" value="${pos}" class="spawn-pos">
  <input type="text" placeholder="Angle(0,0,0)" value="${ang}" class="spawn-ang">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

// Helper to create a main menu position row (Map, Pos, Ang)
function addMainMenuRow(map='', pos='', ang='') {
  const container = document.getElementById('main-menu-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="text" placeholder="Map (Blank for all)" value="${map}" class="mm-map small-input">
  <input type="text" placeholder="Vector(0,0,0)" value="${pos}" class="mm-pos">
  <input type="text" placeholder="Angle(0,0,0)" value="${ang}" class="mm-ang">
  <button onclick="this.parentElement.remove()" class="remove-btn">×</button>
  `;
  container.appendChild(div);
}

function addCommandRow(val='') { addTextRow('commands-list', 'lia_faction_chat', val); }

// Wrappers for specific lists
function addModelRow(val='') { addTextRow('models-list', 'models/player/...', val); }
function addWeaponRow(val='') { addTextRow('weapons-list', 'weapon_class', val); }
function addItemRow(val='') { addTextRow('items-list', 'item_unique_id', val); }

function getListValues(containerId) {
  return Array.from(document.querySelectorAll(`#${containerId} input[type="text"]`))
  .map(input => input.value.trim())
  .filter(val => val !== '');
}

function getSpawnValues() {
  const rows = document.querySelectorAll('#spawns-list .dynamic-row');
  const spawns = {};

  rows.forEach(row => {
  const map = row.querySelector('.spawn-map').value.trim();
  const pos = row.querySelector('.spawn-pos').value.trim();
  const ang = row.querySelector('.spawn-ang').value.trim();

  if (map && pos) {
  if (!spawns[map]) spawns[map] = [];
  spawns[map].push({ position: pos, angle: ang || 'Angle(0,0,0)' });
  }
  });

  return spawns;
}

function getMainMenuValues() {
  const rows = document.querySelectorAll('#main-menu-list .dynamic-row');
  const data = {};

  rows.forEach(row => {
  const map = row.querySelector('.mm-map').value.trim();
  const pos = row.querySelector('.mm-pos').value.trim();
  const ang = row.querySelector('.mm-ang').value.trim();

  if (pos) {
  if (map) {
  data[map] = { position: pos, angles: ang || 'Angle(0,0,0)' };
  } else {
  // No map means global vector/angle or just single entry
  // For structure, we might stick to map keys, but if map is empty, maybe store as specific key or handle as default?
  // Lilia usually expects a table of maps, or a single vector?
  // The placeholder showed `{"gm_construct": ...}`.
  // Let's assume map is required for the table format.
  // But wait, the previous placeholder said "or simple Vector for all maps".
  // If only one row and no map, return just the object?
  // Let's stick to Map keys for consistency.
  if(!data['default']) data['default'] = { position: pos, angles: ang || 'Angle(0,0,0)' };
  }
  }
  });

  // If data has only 'default' and no map was specified, maybe return just that?
  // Let's return the object map.
  return data;
}

function getCommandValues() {
  return Array.from(document.querySelectorAll('#commands-list input[type="text"]'))
  .map(input => input.value.trim())
  .filter(val => val !== '');
}

function generateFaction() {
  const index = (document.getElementById('faction-index').value || '').trim() || 'FACTION_NAME';
  const name = (document.getElementById('faction-name').value || '').trim() || 'Faction Name';
  const desc = (document.getElementById('faction-desc').value || '').trim() || 'Faction description';
  const colorInput = document.getElementById('faction-color').value;
  const color = colorInput ? `Color(${colorInput})` : 'Color(100, 150, 200)';

  const isDefault = document.getElementById('is-default').checked;
  const oneCharOnly = document.getElementById('one-char-only').checked;
  const limit = document.getElementById('faction-limit').value || '0';

  // Harvest dynamic lists
  const models = getListValues('models-list');
  const weapons = getListValues('weapons-list');
  const startingItems = getListValues('items-list');
  const spawns = getSpawnValues();
  const mainMenuPos = getMainMenuValues();
  const commands = getCommandValues();

  const health = document.getElementById('health').value || '100';
  const armor = document.getElementById('armor').value || '0';
  const runSpeed = document.getElementById('run-speed').value || '280';
  const runSpeedMultiplier = document.getElementById('run-speed-multiplier').checked;
  const walkSpeed = document.getElementById('walk-speed').value || '150';
  const walkSpeedMultiplier = document.getElementById('walk-speed-multiplier').checked;
  const jumpPower = document.getElementById('jump-power').value || '200';
  const jumpPowerMultiplier = document.getElementById('jump-power-multiplier').checked;
  const pay = document.getElementById('pay').value || '0';
  const payTimer = document.getElementById('pay-timer').value || '';

  const recognizesGlobally = document.getElementById('recognizes-globally').checked;
  const globallyRecognized = document.getElementById('globally-recognized').checked;
  const memberAutoRecognition = document.getElementById('member-auto-recognition').checked;
  const scoreboardHidden = document.getElementById('scoreboard-hidden').checked;
  const scoreboardPriority = document.getElementById('scoreboard-priority').value.trim();
  const logo = document.getElementById('faction-logo').value.trim();

  const lines = [
  '-- Copy and paste this code into your faction file',
  `-- Example: [schema folder]/factions/${name.toLowerCase().replace(/[^a-z0-9]/g, '')}.lua`,
  '',
  `FACTION.name = ${JSON.stringify(name)}`,
  `FACTION.desc = ${JSON.stringify(desc)}`,
  `FACTION.color = ${color}`,
  '',
  '-- Access Control',
  `FACTION.isDefault = ${isDefault}`,
  `FACTION.oneCharOnly = ${oneCharOnly}`,
  `FACTION.limit = ${limit}`
  ];

  if (models.length > 0) {
  lines.push('', '-- Models', 'FACTION.models = {');
  models.forEach(model => {
  lines.push(` ${JSON.stringify(model)},`);
  });
  lines.push('}');
  }

  lines.push(
  '',
  '-- Gameplay Properties',
  `FACTION.health = ${health}`,
  `FACTION.armor = ${armor}`,
  `FACTION.runSpeed = ${runSpeed}`,
  `FACTION.walkSpeed = ${walkSpeed}`,
  `FACTION.jumpPower = ${jumpPower}`
  );

  if (runSpeedMultiplier) lines.push('FACTION.runSpeedMultiplier = true');
  if (walkSpeedMultiplier) lines.push('FACTION.walkSpeedMultiplier = true');
  if (jumpPowerMultiplier) lines.push('FACTION.jumpPowerMultiplier = true');

  lines.push(`FACTION.pay = ${pay}`);
  if (payTimer) {
  lines.push(`FACTION.payTimer = ${payTimer}`);
  }

  if (weapons.length > 0) {
  lines.push('', '-- Weapons', 'FACTION.weapons = {');
  weapons.forEach(weapon => {
  lines.push(` ${JSON.stringify(weapon)},`);
  });
  lines.push('}');
  }

  if (startingItems.length > 0) {
  lines.push('', '-- Starting Items', 'FACTION.items = {');
  startingItems.forEach(item => {
  lines.push(` ${JSON.stringify(item)},`);
  });
  lines.push('}');
  }

  if (logo) {
  lines.push('', '-- Visual', `FACTION.logo = ${JSON.stringify(logo)}`);
  }

  if (recognizesGlobally || globallyRecognized || memberAutoRecognition || scoreboardHidden || (scoreboardPriority && scoreboardPriority !== '999')) {
  lines.push('', '-- Special Features');
  if (recognizesGlobally) lines.push('FACTION.RecognizesGlobally = true');
  if (globallyRecognized) lines.push('FACTION.isGloballyRecognized = true');
  if (memberAutoRecognition) lines.push('FACTION.MemberToMemberAutoRecognition = true');
  if (scoreboardHidden) lines.push('FACTION.scoreboardHidden = true');
  if (scoreboardPriority && scoreboardPriority !== '999') lines.push(`FACTION.scoreboardPriority = ${scoreboardPriority}`);
  }

  // Spawns
  const mapKeys = Object.keys(spawns);
  if (mapKeys.length > 0) {
  lines.push('', '-- Custom Spawns', 'FACTION.spawns = {');
  mapKeys.forEach(map => {
  lines.push(` ["${map}"] = {`);
  spawns[map].forEach(s => {
  lines.push(` {position = ${s.position}, angles = ${s.angle}},`);
  });
  lines.push(` },`);
  });
  lines.push('}');
  }

  // Main Menu Position
  const menuKeys = Object.keys(mainMenuPos);
  if (menuKeys.length > 0) {
  lines.push('', '-- Main Menu Position');
  // Check if there's only 'default' (no map specified case) - simplistic handling
  if (menuKeys.length === 1 && menuKeys[0] === 'default') {
  // Handle simple vector case if needed, but for now we follow table structure or assume dictionary
  lines.push('FACTION.mainMenuPosition = {');
  // Not putting default key
  const v = mainMenuPos['default'];
  lines.push(` position = ${v.position},`);
  lines.push(` angles = ${v.angles}`);
  lines.push('}');
  } else {
  lines.push('FACTION.mainMenuPosition = {');
  menuKeys.forEach(map => {
  const v = mainMenuPos[map];
  lines.push(` ["${map}"] = {`);
  lines.push(` position = ${v.position},`);
  lines.push(` angles = ${v.angles}`);
  lines.push(` },`);
  });
  lines.push('}');
  }
  }

  // Commands
  if (commands.length > 0) {
  lines.push('', '-- Commands', 'FACTION.commands = {');
  commands.forEach(cmd => {
  lines.push(` ${JSON.stringify(cmd)},`);
  });
  lines.push('}');
  }

  lines.push('', `${index} = FACTION.index`);

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleFaction() {
  document.getElementById('faction-index').value = 'FACTION_CITIZEN';
  document.getElementById('faction-name').value = 'Citizen';
  document.getElementById('faction-desc').value = 'A regular inhabitant of the city. Trying to make a living and avoid trouble.';
  document.getElementById('faction-color').value = '255, 200, 50';
  document.getElementById('is-default').checked = true;
  document.getElementById('one-char-only').checked = false;
  document.getElementById('faction-limit').value = '0';

  // Clear lists
  document.getElementById('models-list').innerHTML = '';
  document.getElementById('weapons-list').innerHTML = '';
  document.getElementById('items-list').innerHTML = '';
  document.getElementById('spawns-list').innerHTML = '';
  document.getElementById('main-menu-list').innerHTML = '';
  document.getElementById('commands-list').innerHTML = '';

  addModelRow('models/player/group01/male_01.mdl');
  addModelRow('models/player/group01/female_01.mdl');

  addWeaponRow('weapon_crowbar');

  addItemRow('cid_card');
  addItemRow('water_bottle');

  addSpawnRow('gm_construct', 'Vector(0, 0, 0)', 'Angle(0, 0, 0)');

  document.getElementById('health').value = '100';
  document.getElementById('armor').value = '0';
  document.getElementById('run-speed').value = '250';
  document.getElementById('run-speed-multiplier').checked = false;
  document.getElementById('walk-speed').value = '150';
  document.getElementById('walk-speed-multiplier').checked = false;
  document.getElementById('jump-power').value = '200';
  document.getElementById('jump-power-multiplier').checked = false;
  document.getElementById('pay').value = '20';
  document.getElementById('pay-timer').value = '300';

  document.getElementById('recognizes-globally').checked = false;
  document.getElementById('globally-recognized').checked = false;
  document.getElementById('member-auto-recognition').checked = false;
  document.getElementById('scoreboard-hidden').checked = false;
  document.getElementById('scoreboard-priority').value = '100';
  document.getElementById('faction-logo').value = 'materials/ui/faction/citizen_logo.png';

  generateFaction();
}

// Prefill some defaults
document.addEventListener('DOMContentLoaded', () => {
  addModelRow('models/player/police.mdl');
  addWeaponRow('weapon_pistol');
  addCommandRow('kick');

  generateFaction();
});

</script>

---
