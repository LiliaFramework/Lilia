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
          <small>Players need to be whitelisted to join this class</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="is-default"> Is Default Class
          </label>
          <small>This is the default class for the faction</small>
        </div>

        <div class="input-group">
          <label for="class-limit">Player Limit:</label>
          <input type="number" id="class-limit" placeholder="0" min="0">
          <small>0 = unlimited, decimals = percentage of faction (e.g., 0.5 = 50%)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Model:</label>
        <div id="models-list" class="dynamic-list"></div>
        <button onclick="addModelRow()" class="add-btn">+ Add Model</button>
        <small>Player model path(s) (leave empty to inherit from faction)</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-color">Color (R,G,B):</label>
          <input type="text" id="class-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
          <small>Comma-separated RGB values (0-255), leave empty to inherit from faction</small>
        </div>

        <div class="input-group">
          <label for="class-skin">Skin:</label>
          <input type="number" id="class-skin" placeholder="0" min="0">
          <small>Model skin index (leave empty to inherit from faction)</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="class-logo">Logo:</label>
          <input type="text" id="class-logo" placeholder="materials/ui/class/police_logo.png">
          <small>Logo material path or URL for scoreboard (leave empty for no logo)</small>
        </div>

        <div class="input-group">
          <label for="class-scale">Model Scale:</label>
          <input type="number" id="class-scale" placeholder="1.0" step="0.1" min="0.1">
          <small>Model scale multiplier (1.0 = normal size)</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-health">Health:</label>
          <input type="number" id="class-health" placeholder="" min="1">
          <small>Leave empty to inherit from faction</small>
        </div>

        <div class="input-group">
          <label for="class-armor">Armor:</label>
          <input type="number" id="class-armor" placeholder="" min="0">
          <small>Leave empty to inherit from faction</small>
        </div>

        <div class="input-group">
          <label for="class-pay">Pay/Salary:</label>
          <input type="number" id="class-pay" placeholder="" min="0">
          <small>Currency amount per paycheck (leave empty to inherit from faction)</small>
        </div>
      </div>

      <div class="form-grid-3">
        <div class="input-group">
          <label for="class-run-speed">Run Speed:</label>
          <input type="number" id="class-run-speed" placeholder="" min="1">
          <label><input type="checkbox" id="class-run-speed-multiplier"> Use as multiplier</label>
          <small>Leave empty to inherit from faction</small>
        </div>

        <div class="input-group">
          <label for="class-walk-speed">Walk Speed:</label>
          <input type="number" id="class-walk-speed" placeholder="" min="1">
          <label><input type="checkbox" id="class-walk-speed-multiplier"> Use as multiplier</label>
          <small>Leave empty to inherit from faction</small>
        </div>

        <div class="input-group">
          <label for="class-jump-power">Jump Power:</label>
          <input type="number" id="class-jump-power" placeholder="" min="1">
          <label><input type="checkbox" id="class-jump-power-multiplier"> Use as multiplier</label>
          <small>Leave empty to inherit from faction</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label>Weapons:</label>
        <div id="weapons-list" class="dynamic-list"></div>
        <button onclick="addWeaponRow()" class="add-btn">+ Add Weapon</button>
        <small>Leave empty to inherit from faction</small>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label>
            <input type="checkbox" id="class-scoreboard-hidden"> Hidden from Scoreboard
          </label>
          <small>Class won't appear in scoreboard categories</small>
        </div>

        <div class="input-group">
          <label for="class-scoreboard-priority">Scoreboard Priority:</label>
          <input type="number" id="class-scoreboard-priority" placeholder="999" min="1">
          <small>Lower numbers appear first in scoreboard (default: 999)</small>
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label>
            <input type="checkbox" id="class-can-invite-faction"> Can Invite to Faction
          </label>
          <small>Allows this class to invite players into the faction</small>
        </div>

        <div class="input-group">
          <label>
            <input type="checkbox" id="class-can-invite-class"> Can Invite to Class
          </label>
          <small>Allows this class to invite players into the same class</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="class-team">Team:</label>
        <input type="text" id="class-team" placeholder="e.g., law, medical">
        <small>Groups related classes for door access (leave empty for no team)</small>
      </div>

      <div class="input-group">
        <label>Commands:</label>
        <div id="commands-list" class="dynamic-list"></div>
        <button onclick="addCommandRow()" class="add-btn">+ Add Command</button>
        <small>Command permissions</small>
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
  const scoreboardPriority = document.getElementById('class-scoreboard-priority').value.trim();
  const canInviteFaction = document.getElementById('class-can-invite-faction').checked;
  const canInviteClass = document.getElementById('class-can-invite-class').checked;
  const team = document.getElementById('class-team').value.trim();

  // Harvest dynamic lists
  const models = getListValues('models-list');
  const weapons = getListValues('weapons-list');
  const commands = getCommandValues();

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

  if (models.length > 0 || colorInput || skin || logo || scale) {
  lines.push('', '-- Visual Properties');
  if (models.length === 1) {
  lines.push(`CLASS.model = ${JSON.stringify(models[0])}`);
  } else if (models.length > 1) {
  lines.push('CLASS.model = {');
  models.forEach(m => lines.push(` ${JSON.stringify(m)},`));
  lines.push('}');
  }
  if (colorInput) {
  const color = colorInput ? `Color(${colorInput})` : null;
  if (color) lines.push(`CLASS.color = ${color}`);
  if (color) lines.push(`CLASS.Color = ${color}`);
  }
  if (skin) lines.push(`CLASS.skin = ${skin}`);
  if (logo) lines.push(`CLASS.logo = ${JSON.stringify(logo)}`);
  if (scale) lines.push(`CLASS.scale = ${scale}`);
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

  if (scoreboardHidden || scoreboardPriority !== '999' || canInviteFaction || canInviteClass || team || commands.length > 0) {
  lines.push('', '-- UI & Advanced');
  if (scoreboardHidden) lines.push('CLASS.scoreboardHidden = true');
  if (scoreboardPriority && scoreboardPriority !== '999') lines.push(`CLASS.scoreboardPriority = ${scoreboardPriority}`);
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
  document.getElementById('class-scoreboard-priority').value = '10';
  document.getElementById('class-can-invite-faction').checked = true;
  document.getElementById('class-can-invite-class').checked = true;
  document.getElementById('class-team').value = 'security';

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
