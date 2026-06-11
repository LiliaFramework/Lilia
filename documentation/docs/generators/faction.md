# Faction Generator

Define the major playable groups in your schema, such as civilians, police, staff, medical teams, military units, or custom setting-specific organizations. Factions are the top-level structure for character creation, whitelisting, models, limits, and default roleplay permissions.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_factions.lua
```

You can also add callback fields like `OnTransferred`, `OnSpawn`, `NameTemplate`, `GetDefaultName`, `GetDefaultDesc`, or any custom logic manually after generation. You can find those in [Faction Definitions](../definitions/faction.md).

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="input-group">
        <label for="faction-index">Faction Index:</label>
        <input type="text" id="faction-index" placeholder="e.g., FACTION_POLICE">
        <small>The constant name you want to assign to the registered faction index.</small>
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
          <label for="faction-color-picker">Color (R,G,B):</label>
          <div class="color-input-row">
            <input type="color" id="faction-color-picker" value="#000000">
            <input type="text" id="faction-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
          </div>
          <small>Use three numbers from 0 to 255.</small>
        </div>

        <div class="input-group">
          <label for="faction-logo">Logo:</label>
          <input type="text" id="faction-logo" placeholder="materials/ui/faction/police_logo.png">
          <small>Logo shown on the scoreboard. You can use a material path or a web URL. Leave empty for no logo.</small>
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
          <input type="number" id="faction-limit" placeholder="0" min="0" step="0.01">
          <small>0 = unlimited, decimals = percentage of server (e.g., 0.1 = 10%)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Models:</label>
        <div id="models-list" class="dynamic-list"></div>
        <button onclick="addModelRow()" class="add-btn">+ Add Model</button>
        <small>Add the player models this faction can use.</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label>
            <input type="checkbox" id="skin-allowed"> Allow Skin Selection
          </label>
          <small>Players in this faction can pick a skin for their character during character creation.</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="bodygroups-allowed"> Allow Bodygroup Selection
          </label>
          <small>Players in this faction can customize bodygroups for their character during character creation.</small>
        </div>
      </div>

      <div class="input-group">
        <label>Allowed Skins:</label>
        <div id="allowed-skins-list" class="dynamic-list"></div>
        <button onclick="addAllowedSkinRow()" class="add-btn">+ Add Skin</button>
        <small>Skin numbers players are allowed to choose. Leave empty to allow all skins.</small>
      </div>

      <div class="input-group">
        <label>Allowed Bodygroups:</label>
        <div id="allowed-bodygroups-list" class="dynamic-list"></div>
        <button onclick="addAllowedBodygroupRow()" class="add-btn">+ Add Bodygroup</button>
        <small>Allowed bodygroup values by bodygroup number. More advanced setups can be added manually later.</small>
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
          <label for="run-speed">Run Speed Multiplier:</label>
          <input type="number" id="run-speed" placeholder="1" min="0" step="0.01">
          <small>Always multiplies the configured run speed. Use <code>1</code> for default speed.</small>
        </div>

        <div class="input-group">
          <label for="walk-speed">Walk Speed Multiplier:</label>
          <input type="number" id="walk-speed" placeholder="1" min="0" step="0.01">
          <small>Always multiplies the configured walk speed. Use <code>1</code> for default speed.</small>
        </div>

        <div class="input-group">
          <label for="jump-power">Jump Power Multiplier:</label>
          <input type="number" id="jump-power" placeholder="1" min="0" step="0.01">
          <small>Always multiplies the player's base jump power. Use <code>1</code> for default jump.</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="pay">Pay/Salary:</label>
          <input type="number" id="pay" placeholder="0" min="0">
          <small>How much they get paid each paycheck.</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="faction-scale">Model Scale:</label>
          <input type="number" id="faction-scale" placeholder="1.0" step="0.1" min="0.1">
          <small>Character size. Leave empty for normal size.</small>
        </div>

        <div class="input-group">
          <label for="faction-bloodcolor">Blood Color:</label>
          <select id="faction-bloodcolor">
            <option value="">Default (BLOOD_COLOR_RED)</option>
            <option value="BLOOD_COLOR_RED">BLOOD_COLOR_RED</option>
            <option value="BLOOD_COLOR_YELLOW">BLOOD_COLOR_YELLOW</option>
            <option value="BLOOD_COLOR_GREEN">BLOOD_COLOR_GREEN</option>
            <option value="BLOOD_COLOR_MECH">BLOOD_COLOR_MECH</option>
            <option value="BLOOD_COLOR_ANTLION">BLOOD_COLOR_ANTLION</option>
            <option value="BLOOD_COLOR_ZOMBIE">BLOOD_COLOR_ZOMBIE</option>
          </select>
          <small>Blood color used for this faction. Leave default for normal human characters.</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Weapons:</label>
        <div id="weapons-list" class="dynamic-list"></div>
        <button onclick="addWeaponRow()" class="add-btn">+ Add Weapon</button>
        <small>Weapons this faction receives on spawn.</small>
      </div>

      <div class="input-group">
        <label>Starting Items:</label>
        <div id="items-list" class="dynamic-list"></div>
        <button onclick="addItemRow()" class="add-btn">+ Add Item</button>
        <small>Items new characters in this faction start with.</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>
          <input type="checkbox" id="recognizes-globally"> Recognizes Globally
        </label>
        <small>Members of this faction always recognize everyone.</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="globally-recognized"> Globally Recognized
        </label>
        <small>Everyone automatically recognizes members of this faction.</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="member-auto-recognition"> Member Auto-Recognition
        </label>
        <small>Members of this faction automatically recognize each other.</small>
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
        <small>Lower numbers show higher on the scoreboard.</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="scoreboard-classes-public"> Scoreboard Classes Public
        </label>
        <small>Everyone can see this faction's classes on the scoreboard.</small>
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="scoreboard-see-all-classes"> See All Classes on Scoreboard
        </label>
        <small>Members of this faction can see every faction's classes on the scoreboard.</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Custom Spawns:</label>
        <div id="spawns-list" class="dynamic-list"></div>
        <button onclick="addSpawnRow()" class="add-btn">+ Add Spawn Point</button>
        <small>Where this faction can spawn on each map.</small>
      </div>

      <div class="input-group">
        <label>Main Menu Position:</label>
        <div id="main-menu-list" class="dynamic-list"></div>
        <button onclick="addMainMenuRow()" class="add-btn">+ Add Main Menu Position</button>
        <small>Where this faction preview appears in the main menu.</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>NPC Relations:</label>
        <div id="npc-relations-list" class="dynamic-list"></div>
        <button onclick="addNPCRelationRow()" class="add-btn">+ Add NPC Relation</button>
        <small>How NPCs react to this faction.</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Commands:</label>
        <div id="commands-list" class="dynamic-list"></div>
        <button onclick="addCommandRow()" class="add-btn">+ Add Command</button>
        <small>Command names that members of this faction can execute.</small>
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
  <input type="text" value="${value}" placeholder="${placeholder}" class="list-input">
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

function addCommandRow(val='') { addTextRow('commands-list', 'kick', val); }

// Wrappers for specific lists
function addModelRow(val='') { addTextRow('models-list', 'models/player/...', val); }
function addWeaponRow(val='') { addTextRow('weapons-list', 'weapon_class', val); }
function addItemRow(val='') { addTextRow('items-list', 'item_unique_id', val); }
function addAllowedSkinRow(val='') { addTextRow('allowed-skins-list', '0', val); }

function addAllowedBodygroupRow(index='', values='') {
  const container = document.getElementById('allowed-bodygroups-list');
  const div = document.createElement('div');
  div.className = 'dynamic-row';
  div.innerHTML = `
  <input type="number" placeholder="Bodygroup index" value="${index}" min="0" class="abg-index small-input">
  <input type="text" placeholder="Allowed values (e.g. 0,1,2)" value="${values}" class="abg-values">
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
  return Array.from(document.querySelectorAll('#commands-list .list-input'))
  .map(input => input.value.trim())
  .filter(val => val !== '');
}

function getAllowedSkinsValues() {
  return Array.from(document.querySelectorAll('#allowed-skins-list input[type="text"]'))
  .map(input => parseInt(input.value.trim(), 10))
  .filter(v => !isNaN(v));
}

function getAllowedBodygroupsValues() {
  const rows = document.querySelectorAll('#allowed-bodygroups-list .dynamic-row');
  const result = {};
  rows.forEach(row => {
    const idx = row.querySelector('.abg-index').value.trim();
    const vals = row.querySelector('.abg-values').value.trim();
    if (idx !== '' && vals !== '') {
      result[parseInt(idx, 10)] = vals.split(',').map(v => parseInt(v.trim(), 10)).filter(v => !isNaN(v));
    }
  });
  return result;
}

function toLuaIdentifier(value, prefix) {
  return (value || '')
  .trim()
  .toLowerCase()
  .replace(new RegExp(`^${prefix}_`), '')
  .replace(/[^a-z0-9]+/g, '_')
  .replace(/^_+|_+$/g, '') || `${prefix.toLowerCase()}_name`;
}

function generateFaction() {
  const DEFAULTS = {
    limit: '0',
    health: '100',
    armor: '0',
    pay: '0',
    runSpeed: '1',
    walkSpeed: '1',
    jumpPower: '1',
    scale: '1',
    scaleAlt: '1.0',
    scoreboardPriority: '999'
  };
  const index = (document.getElementById('faction-index').value || '').trim() || 'FACTION_NAME';
  const name = (document.getElementById('faction-name').value || '').trim() || 'Faction Name';
  const desc = (document.getElementById('faction-desc').value || '').trim() || 'Faction description';
  const uniqueIDSource = index && index !== 'FACTION_NAME' ? index : name;
  const uniqueID = toLuaIdentifier(uniqueIDSource, 'faction');
  const colorInput = document.getElementById('faction-color').value.trim();
  const logo = document.getElementById('faction-logo').value.trim();

  const isDefault = document.getElementById('is-default').checked;
  const oneCharOnly = document.getElementById('one-char-only').checked;
  const limit = document.getElementById('faction-limit').value || DEFAULTS.limit;

  // Harvest dynamic lists
  const models = getListValues('models-list');
  const weapons = getListValues('weapons-list');
  const startingItems = getListValues('items-list');
  const spawns = getSpawnValues();
  const mainMenuPos = getMainMenuValues();
  const commands = getCommandValues();
  const npcRelations = getNPCRelationValues();

  const skinAllowed = document.getElementById('skin-allowed').checked;
  const bodygroupsAllowed = document.getElementById('bodygroups-allowed').checked;
  const scale = document.getElementById('faction-scale').value.trim();
  const bloodcolor = document.getElementById('faction-bloodcolor').value;
  const allowedSkins = getAllowedSkinsValues();
  const allowedBodygroups = getAllowedBodygroupsValues();

  const health = document.getElementById('health').value.trim();
  const armor = document.getElementById('armor').value.trim();
  const runSpeed = document.getElementById('run-speed').value.trim();
  const walkSpeed = document.getElementById('walk-speed').value.trim();
  const jumpPower = document.getElementById('jump-power').value.trim();
  const pay = document.getElementById('pay').value.trim();

  const recognizesGlobally = document.getElementById('recognizes-globally').checked;
  const globallyRecognized = document.getElementById('globally-recognized').checked;
  const memberAutoRecognition = document.getElementById('member-auto-recognition').checked;
  const scoreboardHidden = document.getElementById('scoreboard-hidden').checked;
  const scoreboardPriority = document.getElementById('scoreboard-priority').value.trim();
  const scoreboardClassesPublic = document.getElementById('scoreboard-classes-public').checked;
  const scoreboardSeeAllClasses = document.getElementById('scoreboard-see-all-classes').checked;

  const lines = [];
  const pushField = (key, value) => {
    lines.push(`    ${key} = ${value},`);
  };
  const pushTableStart = key => {
    lines.push(`    ${key} = {`);
  };

  lines.push(index !== 'FACTION_NAME' ? `${index} = lia.faction.register(${JSON.stringify(uniqueID)}, {` : `lia.faction.register(${JSON.stringify(uniqueID)}, {`);
  pushField('name', JSON.stringify(name));
  pushField('desc', JSON.stringify(desc));

  if (!isDefault || oneCharOnly || limit !== DEFAULTS.limit) {
    lines.push('');
    if (!isDefault) pushField('isDefault', 'false');
    if (oneCharOnly) pushField('oneCharOnly', 'true');
    if (limit !== DEFAULTS.limit) pushField('limit', limit);
  }

  const hasCustomScale = scale && scale !== DEFAULTS.scale && scale !== DEFAULTS.scaleAlt;

  if (models.length > 0 || colorInput || logo || hasCustomScale || skinAllowed || bodygroupsAllowed || allowedSkins.length > 0 || Object.keys(allowedBodygroups).length > 0) {
    lines.push('');
    if (models.length > 0) {
      pushTableStart('models');
      models.forEach(model => lines.push(`        ${JSON.stringify(model)},`));
      lines.push('    },');
    }
    if (colorInput) pushField('color', `Color(${colorInput})`);
    if (logo) pushField('logo', JSON.stringify(logo));
    if (hasCustomScale) pushField('scale', scale);
    if (skinAllowed) pushField('skinAllowed', 'true');
    if (bodygroupsAllowed) pushField('bodygroupsAllowed', 'true');
    if (allowedSkins.length > 0) {
      pushTableStart('allowedSkins');
      allowedSkins.forEach(skin => lines.push(`        ${skin},`));
      lines.push('    },');
    }
    if (Object.keys(allowedBodygroups).length > 0) {
      pushTableStart('allowedBodygroups');
      Object.entries(allowedBodygroups).forEach(([bodygroupIndex, values]) => {
        lines.push(`        [${bodygroupIndex}] = { ${values.join(', ')} },`);
      });
      lines.push('    },');
    }
  }

  const hasCustomStats = (health && health !== DEFAULTS.health) ||
    (armor && armor !== DEFAULTS.armor) ||
    (pay && pay !== DEFAULTS.pay) ||
    (runSpeed && runSpeed !== DEFAULTS.runSpeed) ||
    (walkSpeed && walkSpeed !== DEFAULTS.walkSpeed) ||
    (jumpPower && jumpPower !== DEFAULTS.jumpPower) ||
    bloodcolor;

  if (hasCustomStats) {
    lines.push('');
    if (health && health !== DEFAULTS.health) pushField('health', health);
    if (armor && armor !== DEFAULTS.armor) pushField('armor', armor);
    if (pay && pay !== DEFAULTS.pay) pushField('pay', pay);
    if (runSpeed && runSpeed !== DEFAULTS.runSpeed) pushField('runSpeed', runSpeed);
    if (walkSpeed && walkSpeed !== DEFAULTS.walkSpeed) pushField('walkSpeed', walkSpeed);
    if (jumpPower && jumpPower !== DEFAULTS.jumpPower) pushField('jumpPower', jumpPower);
    if (bloodcolor) pushField('bloodcolor', bloodcolor);
  }

  if (weapons.length > 0) {
    lines.push('');
    pushTableStart('weapons');
    weapons.forEach(weapon => lines.push(`        ${JSON.stringify(weapon)},`));
    lines.push('    },');
  }

  if (startingItems.length > 0) {
    lines.push('');
    pushTableStart('items');
    startingItems.forEach(item => lines.push(`        ${JSON.stringify(item)},`));
    lines.push('    },');
  }

  if (npcRelations.length > 0) {
    lines.push('');
    pushTableStart('NPCRelations');
    npcRelations.forEach(relation => {
      lines.push(`        [${JSON.stringify(relation.npc)}] = ${relation.disp},`);
    });
    lines.push('    },');
  }

  if (recognizesGlobally || globallyRecognized || memberAutoRecognition || scoreboardHidden || scoreboardClassesPublic || scoreboardSeeAllClasses || (scoreboardPriority && scoreboardPriority !== DEFAULTS.scoreboardPriority) || commands.length > 0) {
    lines.push('');
    if (recognizesGlobally) pushField('RecognizesGlobally', 'true');
    if (globallyRecognized) pushField('isGloballyRecognized', 'true');
    if (memberAutoRecognition) pushField('MemberToMemberAutoRecognition', 'true');
    if (scoreboardHidden) pushField('scoreboardHidden', 'true');
    if (scoreboardPriority && scoreboardPriority !== DEFAULTS.scoreboardPriority) pushField('scoreboardPriority', scoreboardPriority);
    if (scoreboardClassesPublic) pushField('scoreboardClassesPublic', 'true');
    if (scoreboardSeeAllClasses) pushField('scoreboardSeeAllClasses', 'true');
    if (commands.length > 0) {
      pushTableStart('commands');
      commands.forEach(cmd => lines.push(`        ${JSON.stringify(cmd)},`));
      lines.push('    },');
    }
  }

  const mapKeys = Object.keys(spawns);
  const menuKeys = Object.keys(mainMenuPos);
  if (mapKeys.length > 0 || menuKeys.length > 0) {
    lines.push('');
    if (mapKeys.length > 0) {
      pushTableStart('spawns');
      mapKeys.forEach(map => {
        lines.push(`        ["${map}"] = {`);
        spawns[map].forEach(spawn => {
          lines.push(`            {position = ${spawn.position}, angles = ${spawn.angle}},`);
        });
        lines.push('        },');
      });
      lines.push('    },');
    }

    if (menuKeys.length > 0) {
      if (menuKeys.length === 1 && menuKeys[0] === 'default') {
        const menuEntry = mainMenuPos.default;
        pushTableStart('mainMenuPosition');
        lines.push(`        position = ${menuEntry.position},`);
        lines.push(`        angles = ${menuEntry.angles}`);
        lines.push('    },');
      } else {
        pushTableStart('mainMenuPosition');
        menuKeys.forEach(map => {
          const menuEntry = mainMenuPos[map];
          lines.push(`        ["${map}"] = {`);
          lines.push(`            position = ${menuEntry.position},`);
          lines.push(`            angles = ${menuEntry.angles}`);
          lines.push('        },');
        });
        lines.push('    },');
      }
    }
  }

  lines.push('})');

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
  document.getElementById('faction-color-picker').value = rgbTextToHex('255, 200, 50');
  document.getElementById('is-default').checked = true;
  document.getElementById('one-char-only').checked = false;
  document.getElementById('faction-limit').value = '0';

  // Clear lists
  document.getElementById('models-list').innerHTML = '';
  document.getElementById('weapons-list').innerHTML = '';
  document.getElementById('items-list').innerHTML = '';
  document.getElementById('spawns-list').innerHTML = '';
  document.getElementById('main-menu-list').innerHTML = '';
  document.getElementById('npc-relations-list').innerHTML = '';
  document.getElementById('commands-list').innerHTML = '';
  document.getElementById('allowed-skins-list').innerHTML = '';
  document.getElementById('allowed-bodygroups-list').innerHTML = '';
  document.getElementById('faction-scale').value = '';
  document.getElementById('faction-bloodcolor').value = '';

  addModelRow('models/player/group01/male_01.mdl');
  addModelRow('models/player/group01/female_01.mdl');

  addWeaponRow('weapon_crowbar');

  addItemRow('cid_card');
  addItemRow('water_bottle');

  addSpawnRow('gm_construct', 'Vector(0, 0, 0)', 'Angle(0, 0, 0)');

  document.getElementById('health').value = '100';
  document.getElementById('armor').value = '0';
  document.getElementById('run-speed').value = '1';
  document.getElementById('walk-speed').value = '1';
  document.getElementById('jump-power').value = '1';
  document.getElementById('pay').value = '20';

  document.getElementById('skin-allowed').checked = false;
  document.getElementById('bodygroups-allowed').checked = false;
  document.getElementById('recognizes-globally').checked = false;
  document.getElementById('globally-recognized').checked = false;
  document.getElementById('member-auto-recognition').checked = false;
  document.getElementById('scoreboard-hidden').checked = false;
  document.getElementById('scoreboard-priority').value = '100';
  document.getElementById('scoreboard-classes-public').checked = false;
  document.getElementById('scoreboard-see-all-classes').checked = false;
  document.getElementById('faction-logo').value = 'materials/ui/faction/citizen_logo.png';

  generateFaction();
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

// Prefill some defaults
document.addEventListener('DOMContentLoaded', () => {
  const picker = document.getElementById('faction-color-picker');
  const text = document.getElementById('faction-color');

  picker.addEventListener('input', () => {
    text.value = hexToRgbText(picker.value);
    generateFaction();
  });

  text.addEventListener('input', () => {
    const hex = rgbTextToHex(text.value);
    if (hex) picker.value = hex;
    generateFaction();
  });

  addModelRow('models/player/police.mdl');
  addWeaponRow('weapon_pistol');
  addNPCRelationRow('npc_combine_s', 'D_HT');
  addCommandRow('kick');

  generateFaction();
});

</script>
