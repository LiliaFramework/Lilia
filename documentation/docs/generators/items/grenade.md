<p align="center">
  <h2 style="text-align: center;">Grenade Item Generator</h2>
</p>

<div id="grenade-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="item-name">Item Name:</label>
            <input type="text" id="item-name" placeholder="e.g., Frag Grenade">
        </div>

        <div class="input-group">
            <label for="item-desc">Description:</label>
            <textarea id="item-desc" placeholder="e.g., A fragmentation grenade that explodes on impact"></textarea>
        </div>

        <div class="input-group">
            <label for="item-category">Category:</label>
            <input type="text" id="item-category" placeholder="explosives" value="explosives">
            <small>Inventory category for organization</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Visual Properties</h3>
        <div class="input-group">
            <label for="item-model">Model:</label>
            <input type="text" id="item-model" placeholder="models/weapons/w_grenade.mdl">
            <small>3D model path for the grenade</small>
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
        <h3>Grenade Properties</h3>
        <div class="input-group">
            <label for="throw-force">Throw Force:</label>
            <input type="number" id="throw-force" placeholder="1000" min="1" value="1000">
            <small>Force applied when throwing the grenade</small>
        </div>

        <div class="input-group">
            <label for="throw-sound">Throw Sound:</label>
            <input type="text" id="throw-sound" placeholder="weapons/grenade_throw.wav">
            <small>Sound played when throwing (optional)</small>
        </div>
    </div>

    <button onclick="generateGrenadeItem()" class="generate-btn">Generate Grenade Item Code</button>
</div>

## Generated Code

```lua
-- Generated grenade item code will appear here after clicking "Generate Grenade Item Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#grenade-generator {
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
    font-size: 1.4em;
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
    font-size: 1.1em;
}

.input-group input[type="text"],
.input-group input[type="number"],
.input-group textarea {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid var(--md-default-fg-color--lighter);
    border-radius: 8px;
    font-family: 'Roboto Mono', 'Courier New', monospace;
    font-size: 18px;
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
    font-size: 1.0em;
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
    font-size: 18px;
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
    font-size: 15px !important;
    line-height: 1.5 !important;
}

/* Responsive design */
@media (max-width: 768px) {
    #grenade-generator {
        margin: 0 16px;
    }

    .generator-section {
        padding: 16px;
        margin-bottom: 16px;
    }

    .generator-section h3 {
        font-size: 1.3em;
        padding: 12px 16px;
    }

    .generate-btn {
        padding: 14px 24px;
        font-size: 17px;
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
function generateGrenadeItem() {
    const name = document.getElementById('item-name').value || 'Grenade Item';
    const desc = document.getElementById('item-desc').value || 'An explosive grenade item';
    const category = document.getElementById('item-category').value || 'explosives';
    const model = document.getElementById('item-model').value || 'models/weapons/w_grenade.mdl';
    const width = document.getElementById('item-width').value || '1';
    const height = document.getElementById('item-height').value || '1';
    const throwForce = document.getElementById('throw-force').value || '1000';
    const throwSound = document.getElementById('throw-sound').value.trim();

    // Generate the code
    let code = `-- Copy and paste this code into your grenade item file
-- Example: gamemode/items/grenade/frag_grenade.lua

ITEM.name = "${name}"
ITEM.desc = "${desc}"
ITEM.category = "${category}"

ITEM.model = "${model}"
ITEM.width = ${width}
ITEM.height = ${height}

ITEM.throwForce = ${throwForce}

`;

    if (throwSound) {
        code += `ITEM.throwSound = "${throwSound}"
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