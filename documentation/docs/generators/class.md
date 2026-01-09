# Class Generator

Interactive tool for generating Lilia class definitions. Fill out the fields below and click "Generate Class Code" to create your class code.

---

## Class Generator

<div id="class-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="class-name">Class Name:</label>
            <input type="text" id="class-name" placeholder="e.g., Police Officer">
        </div>

        <div class="input-group">
            <label for="class-desc">Description:</label>
            <textarea id="class-desc" placeholder="e.g., A standard police officer responsible for law enforcement"></textarea>
        </div>

        <div class="input-group">
            <label for="class-faction">Faction (uniqueID):</label>
            <input type="text" id="class-faction" placeholder="e.g., police">
            <small>The faction this class belongs to</small>
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
    </div>

    <div class="generator-section">
        <h3>Weapons & Items</h3>
        <div class="input-group">
            <label for="class-weapons">Weapons:</label>
            <textarea id="class-weapons" placeholder="weapon_stunstick" rows="2"></textarea>
            <small>One weapon class per line (leave empty to inherit from faction)</small>
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
    min-height: 60px;
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
    #class-generator {
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
function generateClass() {
    const name = document.getElementById('class-name').value || 'Class Name';
    const desc = document.getElementById('class-desc').value || 'Class description';
    const faction = document.getElementById('class-faction').value || 'faction_name';
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

    const weapons = document.getElementById('class-weapons').value.split('\n').filter(w => w.trim());

    // Generate the code
    let code = `-- Copy and paste this code into your class file
-- Example: gamemode/classes/police_officer.lua

CLASS.name = "${name}"
CLASS.desc = "${desc}"
CLASS.faction = ${faction}

`;

    // Access Control
    if (isWhitelisted || isDefault || limit !== '0' || requirements) {
        code += `-- Access Control
`;
        if (isWhitelisted) code += `CLASS.isWhitelisted = true
`;
        if (isDefault) code += `CLASS.isDefault = true
`;
        if (limit !== '0') code += `CLASS.limit = ${limit}
`;
        if (requirements) {
            try {
                JSON.parse(requirements);
                code += `CLASS.requirements = ${requirements}
`;
            } catch (e) {
                code += `-- CLASS.requirements = ${requirements} -- Invalid JSON format
`;
            }
        }
        code += `
`;
    }

    // Visual Properties
    if (model || colorInput || skin) {
        code += `-- Visual Properties
`;
        if (model) code += `CLASS.model = "${model}"
`;
        if (colorInput) {
            const color = colorInput ? `Color(${colorInput})` : null;
            if (color) code += `CLASS.color = ${color}
`;
        }
        if (skin) code += `CLASS.skin = ${skin}
`;
        code += `
`;
    }

    // Gameplay Properties
    if (health || armor || pay) {
        code += `-- Gameplay Properties
`;
        if (health) code += `CLASS.health = ${health}
`;
        if (armor) code += `CLASS.armor = ${armor}
`;
        if (pay) code += `CLASS.pay = ${pay}
`;
        code += `
`;
    }

    // Weapons
    if (weapons.length > 0) {
        code += `-- Weapons
CLASS.weapons = {
`;
        weapons.forEach(weapon => {
            code += `    "${weapon.trim()}",\n`;
        });
        code += `}
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