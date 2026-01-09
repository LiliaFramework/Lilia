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
            <label for="male-models">Male Models:</label>
            <textarea id="male-models" placeholder="models/player/police_male.mdl&#10;models/player/swat_male.mdl" rows="3"></textarea>
            <small>One model path per line</small>
        </div>

        <div class="input-group">
            <label for="female-models">Female Models:</label>
            <textarea id="female-models" placeholder="models/player/police_female.mdl&#10;models/player/swat_female.mdl" rows="3"></textarea>
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

    <div class="generator-section">
        <h3>Name Generation</h3>
        <div class="input-group">
            <label for="name-template">Name Template Function:</label>
            <textarea id="name-template" placeholder="function FACTION:NameTemplate(info, client)
    local badgeNumber = math.random(1000, 9999)
    return &quot;Officer &quot; .. badgeNumber
end" rows="4"></textarea>
            <small>Optional: Leave blank for default name generation</small>
        </div>
    </div>

    <button onclick="generateFaction()" class="generate-btn">Generate Faction Code</button>
</div>

## Generated Code

```lua
-- Copy and paste this code into your faction file
-- Example: gamemode/factions/police.lua

FACTION.name = "Police Department"
FACTION.desc = "Law enforcement officers responsible for maintaining order and protecting citizens"
FACTION.color = Color(0, 100, 255)

FACTION.isDefault = false
FACTION.oneCharOnly = true
FACTION.limit = 12

FACTION.models = {
    male = {
        "models/player/police_male.mdl",
        "models/player/swat_male.mdl"
    },
    female = {
        "models/player/police_female.mdl",
        "models/player/swat_female.mdl"
    }
}

FACTION.health = 120
FACTION.armor = 50
FACTION.runSpeed = 280
FACTION.walkSpeed = 150
FACTION.jumpPower = 200
FACTION.pay = 100

FACTION.weapons = {
    "weapon_pistol",
    "weapon_stunstick"
}

FACTION.items = {
    "item_police_badge",
    "item_handcuffs"
}

FACTION.RecognizesGlobally = true
FACTION.isGloballyRecognized = true
FACTION.MemberToMemberAutoRecognition = true
```

<style>
#faction-generator {
    max-width: 800px;
    margin: 0 auto;
    font-family: Arial, sans-serif;
}

.generator-section {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    background-color: #f9f9f9;
}

.generator-section h3 {
    margin-top: 0;
    color: #333;
    border-bottom: 2px solid #007acc;
    padding-bottom: 10px;
}

.input-group {
    margin-bottom: 15px;
}

.input-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
    color: #555;
}

.input-group input[type="text"],
.input-group input[type="number"],
.input-group textarea {
    width: 100%;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    font-size: 14px;
}

.input-group textarea {
    resize: vertical;
    min-height: 60px;
}

.input-group small {
    display: block;
    color: #666;
    font-style: italic;
    margin-top: 3px;
}

.input-group label input[type="checkbox"] {
    width: auto;
    margin-right: 8px;
}

.generate-btn {
    background-color: #007acc;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 16px;
    font-weight: bold;
    display: block;
    width: 100%;
    margin: 20px 0;
    transition: background-color 0.3s;
}

.generate-btn:hover {
    background-color: #005aa3;
}

.code-output {
    background-color: #f4f4f4;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 15px;
    font-family: 'Courier New', monospace;
    white-space: pre-wrap;
    margin-top: 20px;
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
    const maleModels = document.getElementById('male-models').value.split('\n').filter(m => m.trim());
    const femaleModels = document.getElementById('female-models').value.split('\n').filter(m => m.trim());

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

    // Name template
    const nameTemplate = document.getElementById('name-template').value.trim();

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
    if (maleModels.length > 0 || femaleModels.length > 0) {
        code += `-- Models
FACTION.models = {
`;
        if (maleModels.length > 0) {
            code += `    male = {\n`;
            maleModels.forEach(model => {
                code += `        "${model.trim()}",\n`;
            });
            code += `    },\n`;
        }
        if (femaleModels.length > 0) {
            code += `    female = {\n`;
            femaleModels.forEach(model => {
                code += `        "${model.trim()}",\n`;
            });
            code += `    },\n`;
        }
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

    // Name template
    if (nameTemplate) {
        code += `-- Name Generation
${nameTemplate}
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

// Auto-generate on page load with default values
document.addEventListener('DOMContentLoaded', function() {
    generateFaction();
});
</script>

---

## Usage Instructions

1. **Fill out the form fields** above with your faction's properties
2. **Click "Generate Faction Code"** to create the Lua code
3. **Copy the generated code** from the code block below
4. **Create a new file** in your `gamemode/factions/` directory (e.g., `police.lua`)
5. **Paste the code** into the file and save it
6. **The faction will be automatically loaded** when the server starts

## Tips

- **Models**: Use the exact model paths from your game's materials
- **Weapons**: Make sure the weapon classes exist on your server
- **Items**: Use the uniqueID of items defined in your item system
- **Limits**: Use 0 for unlimited, decimals for percentages (0.1 = 10% of server)
- **Colors**: RGB values should be between 0-255
- **Speeds**: Test these values to ensure balanced gameplay

## Advanced Customization

For more advanced faction features like custom callbacks, NPC relationships, or special spawn logic, refer to the [Faction Definitions documentation](./definitions/faction.md).