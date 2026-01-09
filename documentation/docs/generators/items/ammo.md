<p align="center">
  <h2 style="text-align: center;">Ammo Item Generator</h2>
</p>

<div id="ammo-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="item-name">Item Name:</label>
            <input type="text" id="item-name" placeholder="e.g., 9mm Ammo">
        </div>

        <div class="input-group">
            <label for="item-desc">Description:</label>
            <textarea id="item-desc" placeholder="e.g., Standard 9mm pistol ammunition"></textarea>
        </div>

        <div class="input-group">
            <label for="item-category">Category:</label>
            <input type="text" id="item-category" placeholder="itemCatAmmunition" value="itemCatAmmunition">
            <small>Inventory category for organization</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Visual Properties</h3>
        <div class="input-group">
            <label for="item-model">Model:</label>
            <input type="text" id="item-model" placeholder="models/items/boxsrounds.mdl">
            <small>3D model path for the ammo box</small>
        </div>

        <div class="input-group">
            <label for="item-width">Width:</label>
            <input type="number" id="item-width" placeholder="1" min="1" value="1">
            <small>Inventory slot width</small>
        </div>

        <div class="input-group">
            <label for="item-height">Height:</label>
            <input type="number" id="item-height" placeholder="1" min="1" value="1">
            <small>Inventory slot height</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Ammo Properties</h3>
        <div class="input-group">
            <label for="ammo-type">Ammo Type:</label>
            <input type="text" id="ammo-type" placeholder="pistol">
            <small>Ammo type that gets given to players (e.g., pistol, smg1, buckshot)</small>
        </div>

        <div class="input-group">
            <label for="ammo-amount">Ammo Amount:</label>
            <input type="number" id="ammo-amount" placeholder="30" min="1" value="30">
            <small>Number of rounds given when used</small>
        </div>
    </div>

    <button onclick="generateAmmoItem()" class="generate-btn">Generate Ammo Item Code</button>
</div>

## Generated Code

```lua
-- Generated ammo item code will appear here after clicking "Generate Ammo Item Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#ammo-generator {
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
    #ammo-generator {
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
function generateAmmoItem() {
    const name = (document.getElementById('item-name').value || '').trim() || 'Ammo Item';
    const desc = (document.getElementById('item-desc').value || '').trim() || 'Ammo item description';
    const category = (document.getElementById('item-category').value || '').trim() || 'itemCatAmmunition';
    const model = (document.getElementById('item-model').value || '').trim() || 'models/items/boxsrounds.mdl';
    const width = document.getElementById('item-width').value || '1';
    const height = document.getElementById('item-height').value || '1';
    const ammoType = (document.getElementById('ammo-type').value || '').trim() || 'pistol';
    const ammoAmount = document.getElementById('ammo-amount').value || '30';

    const lines = [
        '-- Copy and paste this code into your ammo item file',
        '-- Example: gamemode/items/ammo/pistol_ammo.lua',
        '',
        `ITEM.name = ${JSON.stringify(name)}`,
        `ITEM.desc = ${JSON.stringify(desc)}`,
        `ITEM.category = ${JSON.stringify(category)}`,
        '',
        `ITEM.model = ${JSON.stringify(model)}`,
        `ITEM.width = ${width}`,
        `ITEM.height = ${height}`,
        '',
        `ITEM.ammo = ${JSON.stringify(ammoType)}`,
        `ITEM.ammoAmount = ${ammoAmount}`
    ];

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