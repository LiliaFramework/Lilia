<p align="center">
  <h2 style="text-align: center;">Attribute Generator</h2>
</p>

<div id="attribute-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="attribute-name">Attribute Name:</label>
            <input type="text" id="attribute-name" placeholder="e.g., Strength">
        </div>

        <div class="input-group">
            <label for="attribute-desc">Description:</label>
            <textarea id="attribute-desc" placeholder="e.g., Physical power and muscle strength. Affects melee damage and carrying capacity."></textarea>
        </div>
    </div>

    <div class="generator-section">
        <h3>Attribute Settings</h3>
        <div class="input-group">
            <label for="max-value">Maximum Value:</label>
            <input type="number" id="max-value" placeholder="100" min="1">
            <small>The highest value this attribute can reach</small>
        </div>

        <div class="input-group">
            <label for="starting-max">Starting Maximum:</label>
            <input type="number" id="starting-max" placeholder="30" min="0">
            <small>The maximum value available at character creation (leave empty for no limit)</small>
        </div>

        <div class="input-group">
            <label>
                <input type="checkbox" id="no-start-bonus"> No Starting Bonus
            </label>
            <small>Disable automatic attribute points at character creation</small>
        </div>
    </div>

    <button onclick="generateAttribute()" class="generate-btn">Generate Attribute Code</button>
</div>

## Generated Code

```lua
-- Generated attribute code will appear here after clicking "Generate Attribute Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#attribute-generator {
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
    #attribute-generator {
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
function generateAttribute() {
    const name = (document.getElementById('attribute-name').value || '').trim() || 'Attribute Name';
    const desc = (document.getElementById('attribute-desc').value || '').trim() || 'Attribute description';
    const maxValue = document.getElementById('max-value').value || '100';
    const startingMax = document.getElementById('starting-max').value.trim();
    const noStartBonus = document.getElementById('no-start-bonus').checked;

    const lines = [
        '-- Copy and paste this code into your attribute file',
        '-- Example: gamemode/attributes/strength.lua',
        '',
        `ATTRIBUTE.name = ${JSON.stringify(name)}`,
        `ATTRIBUTE.desc = ${JSON.stringify(desc)}`,
        `ATTRIBUTE.maxValue = ${maxValue}`
    ];

    if (startingMax) lines.push(`ATTRIBUTE.startingMax = ${startingMax}`);
    lines.push(`ATTRIBUTE.noStartBonus = ${noStartBonus ? 'true' : 'false'}`);

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