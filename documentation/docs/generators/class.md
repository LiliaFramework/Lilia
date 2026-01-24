<p align="center">
  <h2 style="text-align: center;">Class Generator</h2>
</p>

<div id="class-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="class-index">Class Index:</label>
            <input type="text" id="class-index" placeholder="e.g., CLASS_POLICEOFFICER">
            <small>The unique identifier for this class (e.g., CLASS_POLICEOFFICER)</small>
        </div>

        <div class="input-group">
            <label for="class-name">Class Name:</label>
            <input type="text" id="class-name" placeholder="e.g., Police Officer">
        </div>

        <div class="input-group">
            <label for="class-desc">Description:</label>
            <textarea id="class-desc" placeholder="e.g., A standard police officer responsible for law enforcement"></textarea>
        </div>

        <div class="input-group">
            <label for="class-faction">Faction Index:</label>
            <input type="text" id="class-faction" placeholder="e.g., FACTION_POLICE">
            <small>The faction index this class belongs to (e.g., FACTION_POLICE)</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Access Control</h3>
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

        <div class="input-group">
            <label for="class-requirements">Requirements:</label>
            <textarea id="class-requirements" placeholder='{"attribute": "strength", "value": 5}' rows="2"></textarea>
            <small>JSON format: e.g., {"attribute": "strength", "value": 5}</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Visual Properties</h3>
        <div class="input-group">
            <label for="class-model">Model:</label>
            <input type="text" id="class-model" placeholder="models/player/police.mdl">
            <small>Player model path (leave empty to inherit from faction)</small>
        </div>

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

    <div class="generator-section">
        <h3>Gameplay Properties</h3>
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

    <div class="generator-section">
        <h3>Weapons & Items</h3>
        <div class="input-group">
            <label for="class-weapons">Weapons:</label>
            <textarea id="class-weapons" placeholder="weapon_stunstick" rows="2"></textarea>
            <small>One weapon class per line (leave empty to inherit from faction)</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>UI & Display</h3>
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

    <div class="generator-section">
        <h3>Advanced</h3>
        <div class="input-group">
            <label for="class-team">Team:</label>
            <input type="text" id="class-team" placeholder="e.g., law, medical">
            <small>Groups related classes for door access (leave empty for no team)</small>
        </div>

        <div class="input-group">
            <label for="class-commands">Commands (JSON):</label>
            <textarea id="class-commands" placeholder='{"kick": true, "give": true}' rows="2"></textarea>
            <small>JSON format: e.g., {"kick": true, "give": true}</small>
        </div>
    </div>

    <button onclick="generateClass()" class="generate-btn">Generate Class Code</button>
</div>

## Generated Code

```lua
-- Generated class code will appear here after clicking "Generate Class Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#class-generator {
    max-width: 1100px;
    margin: 0 auto;
    font-family: 'Noto Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.75;
}

.generator-section {
    background: var(--md-default-fg-color--lightest);
    border: 1px solid var(--md-default-fg-color--lighter);
    border-radius: 14px;
    padding: 28px;
    margin-bottom: 28px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: box-shadow 0.3s ease;
}

[data-md-color-scheme="slate"] .generator-section {
    background: var(--md-default-fg-color--dark);
    border-color: var(--md-default-fg-color--light);
}

.generator-section:hover {
    box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.generator-section h3 {
    margin: -8px -8px 24px -8px;
    padding: 18px 24px;
    background: linear-gradient(135deg, #009688 0%, #b39ddb 100%);
    color: white;
    border-radius: 8px 8px 0 0;
    font-weight: 500;
    font-size: 1.6em;
    letter-spacing: 0.02em;
}

[data-md-color-scheme="slate"] .generator-section h3 {
    background: linear-gradient(135deg, #26a69a 0%, #d1c4e9 100%);
}

.input-group {
    margin-bottom: 22px;
}

.input-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: var(--md-default-fg-color);
    font-size: 1.15em;
}

.input-group input[type="text"],
.input-group input[type="number"],
.input-group textarea {
    width: 100%;
    padding: 14px 18px;
    border: 2px solid var(--md-default-fg-color--lighter);
    border-radius: 10px;
    font-family: 'Roboto Mono', 'Courier New', monospace;
    font-size: 19px;
    background: var(--md-default-fg-color--lightest);
    color: var(--md-default-fg-color);
    transition: border-color 0.3s ease, box-shadow 0.3s ease;
    box-sizing: border-box;
}

[data-md-color-scheme="slate"] .input-group input[type="text"],
[data-md-color-scheme="slate"] .input-group input[type="number"],
[data-md-color-scheme="slate"] .input-group textarea {
    background: var(--md-default-fg-color--dark);
    border-color: var(--md-default-fg-color--light);
    color: var(--md-default-fg-color--light);
}

.input-group input[type="text"]:focus,
.input-group input[type="number"]:focus,
.input-group textarea:focus {
    outline: none;
    border-color: #009688;
    box-shadow: 0 0 0 3px rgba(0, 150, 136, 0.1);
}

[data-md-color-scheme="slate"] .input-group input[type="text"]:focus,
[data-md-color-scheme="slate"] .input-group input[type="number"]:focus,
[data-md-color-scheme="slate"] .input-group textarea:focus {
    border-color: #26a69a;
    box-shadow: 0 0 0 3px rgba(38, 166, 154, 0.2);
}

.input-group textarea {
    resize: vertical;
    min-height: 80px;
    line-height: 1.4;
}

.input-group small {
    display: block;
    color: var(--md-default-fg-color--light);
    font-style: normal;
    margin-top: 6px;
    font-size: 1.05em;
}

[data-md-color-scheme="slate"] .input-group small {
    color: var(--md-default-fg-color--lighter);
}

.input-group label input[type="checkbox"] {
    width: auto;
    margin-right: 10px;
    accent-color: #009688;
}

[data-md-color-scheme="slate"] .input-group label input[type="checkbox"] {
    accent-color: #26a69a;
}

.generate-btn {
    background: linear-gradient(135deg, #009688 0%, #b39ddb 100%);
    color: white;
    border: none;
    padding: 18px 34px;
    border-radius: 10px;
    cursor: pointer;
    font-size: 20px;
    font-weight: 600;
    display: block;
    width: 100%;
    margin: 28px 0;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    box-shadow: 0 4px 12px rgba(0, 150, 136, 0.3);
}

[data-md-color-scheme="slate"] .generate-btn {
    background: linear-gradient(135deg, #26a69a 0%, #d1c4e9 100%);
    box-shadow: 0 4px 12px rgba(38, 166, 154, 0.3);
}

.generate-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 150, 136, 0.4);
}

[data-md-color-scheme="slate"] .generate-btn:hover {
    box-shadow: 0 6px 20px rgba(38, 166, 154, 0.4);
}

.generate-btn:active {
    transform: translateY(0);
}

/* Code output styling */
.hljs {
    background: var(--md-code-bg-color) !important;
    color: var(--md-code-fg-color) !important;
}

pre {
    background: var(--md-code-bg-color) !important;
    border: 1px solid var(--md-default-fg-color--lighter) !important;
    border-radius: 8px !important;
    padding: 20px !important;
    overflow-x: auto !important;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
}

code {
    font-family: 'Roboto Mono', 'Courier New', monospace !important;
    font-size: 16px !important;
    line-height: 1.5 !important;
}

/* Responsive design */
@media (max-width: 768px) {
    #class-generator {
        margin: 0 16px;
    }

    .generator-section {
        padding: 18px;
        margin-bottom: 18px;
    }

    .generator-section h3 {
        font-size: 1.4em;
        padding: 14px 18px;
    }

    .generate-btn {
        padding: 16px 26px;
        font-size: 19px;
    }
}

/* Material Design elevation */
.md-typeset .admonition {
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

[data-md-color-scheme="slate"] .md-typeset .admonition {
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>

<script>
function generateClass() {
    const index = (document.getElementById('class-index').value || '').trim() || 'CLASS_NAME';
    const name = (document.getElementById('class-name').value || '').trim() || 'Class Name';
    const desc = (document.getElementById('class-desc').value || '').trim() || 'Class description';
    const faction = document.getElementById('class-faction').value || 'FACTION_NAME';
    const model = document.getElementById('class-model').value.trim();
    const colorInput = document.getElementById('class-color').value.trim();
    const skin = document.getElementById('class-skin').value.trim();

    const isWhitelisted = document.getElementById('is-whitelisted').checked;
    const isDefault = document.getElementById('is-default').checked;
    const limit = document.getElementById('class-limit').value || '0';
    const requirements = document.getElementById('class-requirements').value.trim();

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
    const commands = document.getElementById('class-commands').value.trim();

    const weapons = document.getElementById('class-weapons').value.split('\n').filter(w => w.trim());

    const lines = [
        '-- Copy and paste this code into your class file',
        '-- Example: gamemode/classes/police_officer.lua',
        '',
        `CLASS.name = ${JSON.stringify(name)}`,
        `CLASS.desc = ${JSON.stringify(desc)}`,
        `CLASS.faction = ${faction}`
    ];

    if (isWhitelisted || isDefault || limit !== '0' || requirements) {
        lines.push('', '-- Access Control');
        if (isWhitelisted) lines.push('CLASS.isWhitelisted = true');
        if (isDefault) lines.push('CLASS.isDefault = true');
        if (limit !== '0') lines.push(`CLASS.limit = ${limit}`);
        if (requirements) {
            try {
                JSON.parse(requirements);
                lines.push(`CLASS.requirements = ${requirements}`);
            } catch (e) {
                lines.push(`-- CLASS.requirements = ${requirements} -- Invalid JSON format`);
            }
        }
    }

    if (model || colorInput || skin || logo || scale) {
        lines.push('', '-- Visual Properties');
        if (model) lines.push(`CLASS.model = ${JSON.stringify(model)}`);
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
            lines.push(`    ${JSON.stringify(weapon.trim())},`);
        });
        lines.push('}');
    }

    if (scoreboardHidden || scoreboardPriority !== '999' || canInviteFaction || canInviteClass || team || commands) {
        lines.push('', '-- UI & Advanced');
        if (scoreboardHidden) lines.push('CLASS.scoreboardHidden = true');
        if (scoreboardPriority && scoreboardPriority !== '999') lines.push(`CLASS.scoreboardPriority = ${scoreboardPriority}`);
        if (canInviteFaction) lines.push('CLASS.canInviteToFaction = true');
        if (canInviteClass) lines.push('CLASS.canInviteToClass = true');
        if (team) lines.push(`CLASS.team = ${JSON.stringify(team)}`);
        if (commands) {
            try {
                JSON.parse(commands);
                lines.push(`CLASS.commands = ${commands}`);
            } catch (e) {
                lines.push(`-- CLASS.commands = ${commands} -- Invalid JSON format`);
            }
        }
    }

    lines.push('', `${index} = CLASS.index`);

    const code = `${lines.join('\n')}\n`;

    const codeBlock = document.querySelector('code');
    if (codeBlock) {
        codeBlock.textContent = code;
    }

    const preElement = document.querySelector('pre');
    if (preElement) {
        preElement.innerHTML = `<code>${code.replace(/</g, '&lt;').replace(/>/g, '&gt;')}</code>`;
    }
}
</script>

---