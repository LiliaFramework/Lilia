# Faction Generator

Interactive tool for generating Lilia faction definitions. Fill out the fields below and click "Generate Faction" to create your faction code.

---

## Faction Generator

<div id="faction-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="faction-name">Faction Name:</label>
            <input type="text" id="faction-name" placeholder="e.g., Police Department">
        </div>

        <div class="input-group">
            <label for="faction-desc">Description:</label>
            <textarea id="faction-desc" placeholder="e.g., Law enforcement officers responsible for maintaining order"></textarea>
        </div>

        <div class="input-group">
            <label for="faction-color">Color (R,G,B):</label>
            <input type="text" id="faction-color" placeholder="e.g., 0, 100, 255" pattern="\d{1,3},\s*\d{1,3},\s*\d{1,3}">
            <small>Comma-separated RGB values (0-255)</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Access Control</h3>
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

    <div class="generator-section">
        <h3>Models</h3>
        <div class="input-group">
            <label for="models">Models:</label>
            <textarea id="models" placeholder="models/player/police.mdl&#10;models/player/swat.mdl&#10;models/player/citizen_male.mdl" rows="4"></textarea>
            <small>One model path per line</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Gameplay Properties</h3>
        <div class="input-group">
            <label for="health">Health:</label>
            <input type="number" id="health" placeholder="100" min="1">
        </div>

        <div class="input-group">
            <label for="armor">Armor:</label>
            <input type="number" id="armor" placeholder="0" min="0">
        </div>

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

        <div class="input-group">
            <label for="pay">Pay/Salary:</label>
            <input type="number" id="pay" placeholder="0" min="0">
            <small>Currency amount per paycheck</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Weapons & Items</h3>
        <div class="input-group">
            <label for="weapons">Weapons:</label>
            <textarea id="weapons" placeholder="weapon_pistol&#10;weapon_stunstick" rows="3"></textarea>
            <small>One weapon class per line</small>
        </div>

        <div class="input-group">
            <label for="starting-items">Starting Items:</label>
            <textarea id="starting-items" placeholder="item_police_badge&#10;item_handcuffs" rows="3"></textarea>
            <small>One item uniqueID per line</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Special Features</h3>
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
    </div>


    <button onclick="generateFaction()" class="generate-btn">Generate Faction Code</button>
</div>

## Generated Code

```lua
-- Generated faction code will appear here after clicking "Generate Faction Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#faction-generator {
    max-width: 900px;
    margin: 0 auto;
    font-family: 'Noto Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
}

.generator-section {
    background: var(--md-default-fg-color--lightest);
    border: 1px solid var(--md-default-fg-color--lighter);
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 24px;
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
    margin: -6px -6px 20px -6px;
    padding: 16px 20px;
    background: linear-gradient(135deg, #009688 0%, #b39ddb 100%);
    color: white;
    border-radius: 8px 8px 0 0;
    font-weight: 500;
    font-size: 1.2em;
    letter-spacing: 0.02em;
}

[data-md-color-scheme="slate"] .generator-section h3 {
    background: linear-gradient(135deg, #26a69a 0%, #d1c4e9 100%);
}

.input-group {
    margin-bottom: 20px;
}

.input-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: var(--md-default-fg-color);
    font-size: 0.95em;
}

.input-group input[type="text"],
.input-group input[type="number"],
.input-group textarea {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid var(--md-default-fg-color--lighter);
    border-radius: 8px;
    font-family: 'Roboto Mono', 'Courier New', monospace;
    font-size: 14px;
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
    font-size: 0.85em;
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
    padding: 16px 32px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 600;
    display: block;
    width: 100%;
    margin: 24px 0;
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
    font-size: 13px !important;
    line-height: 1.5 !important;
}

/* Responsive design */
@media (max-width: 768px) {
    #faction-generator {
        margin: 0 16px;
    }

    .generator-section {
        padding: 16px;
        margin-bottom: 16px;
    }

    .generator-section h3 {
        font-size: 1.1em;
        padding: 12px 16px;
    }

    .generate-btn {
        padding: 14px 24px;
        font-size: 15px;
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
function generateFaction() {
    const name = document.getElementById('faction-name').value || 'Faction Name';
    const desc = document.getElementById('faction-desc').value || 'Faction description';
    const colorInput = document.getElementById('faction-color').value;
    const color = colorInput ? `Color(${colorInput})` : 'Color(100, 150, 200)';

    const isDefault = document.getElementById('is-default').checked;
    const oneCharOnly = document.getElementById('one-char-only').checked;
    const limit = document.getElementById('faction-limit').value || '0';

    // Models
    const models = document.getElementById('models').value.split('\n').filter(m => m.trim());

    // Gameplay properties
    const health = document.getElementById('health').value || '100';
    const armor = document.getElementById('armor').value || '0';
    const runSpeed = document.getElementById('run-speed').value || '280';
    const runSpeedMultiplier = document.getElementById('run-speed-multiplier').checked;
    const walkSpeed = document.getElementById('walk-speed').value || '150';
    const walkSpeedMultiplier = document.getElementById('walk-speed-multiplier').checked;
    const jumpPower = document.getElementById('jump-power').value || '200';
    const jumpPowerMultiplier = document.getElementById('jump-power-multiplier').checked;
    const pay = document.getElementById('pay').value || '0';

    // Weapons and items
    const weapons = document.getElementById('weapons').value.split('\n').filter(w => w.trim());
    const startingItems = document.getElementById('starting-items').value.split('\n').filter(i => i.trim());

    // Special features
    const recognizesGlobally = document.getElementById('recognizes-globally').checked;
    const globallyRecognized = document.getElementById('globally-recognized').checked;
    const memberAutoRecognition = document.getElementById('member-auto-recognition').checked;
    const scoreboardHidden = document.getElementById('scoreboard-hidden').checked;


    // Generate the code
    let code = `-- Copy and paste this code into your faction file
-- Example: gamemode/factions/${name.toLowerCase().replace(/[^a-z0-9]/g, '')}.lua

FACTION.name = "${name}"
FACTION.desc = "${desc}"
FACTION.color = ${color}

-- Access Control
FACTION.isDefault = ${isDefault}
FACTION.oneCharOnly = ${oneCharOnly}
FACTION.limit = ${limit}

`;

    // Models section
    if (models.length > 0) {
        code += `-- Models
FACTION.models = {
`;
        models.forEach(model => {
            code += `    "${model.trim()}",\n`;
        });
        code += `}

`;
    }

    // Gameplay properties
    code += `-- Gameplay Properties
FACTION.health = ${health}
FACTION.armor = ${armor}
FACTION.runSpeed = ${runSpeed}
FACTION.walkSpeed = ${walkSpeed}
FACTION.jumpPower = ${jumpPower}
`;

    if (runSpeedMultiplier) code += `FACTION.runSpeedMultiplier = true
`;
    if (walkSpeedMultiplier) code += `FACTION.walkSpeedMultiplier = true
`;
    if (jumpPowerMultiplier) code += `FACTION.jumpPowerMultiplier = true
`;

    code += `FACTION.pay = ${pay}

`;

    // Weapons
    if (weapons.length > 0) {
        code += `-- Weapons
FACTION.weapons = {
`;
        weapons.forEach(weapon => {
            code += `    "${weapon.trim()}",\n`;
        });
        code += `}

`;
    }

    // Starting items
    if (startingItems.length > 0) {
        code += `-- Starting Items
FACTION.items = {
`;
        startingItems.forEach(item => {
            code += `    "${item.trim()}",\n`;
        });
        code += `}

`;
    }

    // Special features
    if (recognizesGlobally || globallyRecognized || memberAutoRecognition || scoreboardHidden) {
        code += `-- Special Features
`;
        if (recognizesGlobally) code += `FACTION.RecognizesGlobally = true
`;
        if (globallyRecognized) code += `FACTION.isGloballyRecognized = true
`;
        if (memberAutoRecognition) code += `FACTION.MemberToMemberAutoRecognition = true
`;
        if (scoreboardHidden) code += `FACTION.scoreboardHidden = true
`;
        code += `
`;
    }


    // Update the code block
    const codeBlock = document.querySelector('code');
    if (codeBlock) {
        codeBlock.textContent = code;
    }

    // Also update the pre element that contains the code
    const preElement = document.querySelector('pre');
    if (preElement) {
        preElement.innerHTML = `<code>${code.replace(/</g, '&lt;').replace(/>/g, '&gt;')}</code>`;
    }
}

</script>

---