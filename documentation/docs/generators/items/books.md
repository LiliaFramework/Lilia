<p align="center">
  <h2 style="text-align: center;">Books Item Generator</h2>
</p>

<div id="books-generator">
    <div class="generator-section">
        <h3>Basic Information</h3>
        <div class="input-group">
            <label for="item-name">Item Name:</label>
            <input type="text" id="item-name" placeholder="e.g., Skill Book: Guns">
        </div>

        <div class="input-group">
            <label for="item-desc">Description:</label>
            <textarea id="item-desc" placeholder="e.g., A training manual that teaches firearm proficiency"></textarea>
        </div>

        <div class="input-group">
            <label for="item-category">Category:</label>
            <input type="text" id="item-category" placeholder="books" value="books">
            <small>Inventory category for organization</small>
        </div>
    </div>

    <div class="generator-section">
        <h3>Visual Properties</h3>
        <div class="input-group">
            <label for="item-model">Model:</label>
            <input type="text" id="item-model" placeholder="models/props_lab/binderblue.mdl">
            <small>3D model path for the book</small>
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
        <h3>Book Properties</h3>
        <div class="input-group">
            <label for="skill-required">Required Skill:</label>
            <input type="text" id="skill-required" placeholder="intelligence">
            <small>Skill required to read this book (optional)</small>
        </div>

        <div class="input-group">
            <label for="skill-value">Required Skill Value:</label>
            <input type="number" id="skill-value" placeholder="3" min="1">
            <small>Minimum skill level required (leave empty if no requirement)</small>
        </div>

        <div class="input-group">
            <label for="read-time">Read Time:</label>
            <input type="number" id="read-time" placeholder="30" min="1" value="30">
            <small>Time in seconds to read the book</small>
        </div>

        <div class="input-group">
            <label>
                <input type="checkbox" id="single-use"> Single Use
            </label>
            <small>Book is consumed after reading</small>
        </div>
    </div>

    <button onclick="generateBooksItem()" class="generate-btn">Generate Books Item Code</button>
</div>

## Generated Code

```lua
-- Generated books item code will appear here after clicking "Generate Books Item Code"
```

<style>
/* Material Design inspired styling for Lilia theme */
#books-generator {
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
    #books-generator {
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
function generateBooksItem() {
    const name = document.getElementById('item-name').value || 'Book Item';
    const desc = document.getElementById('item-desc').value || 'A readable book item';
    const category = document.getElementById('item-category').value || 'books';
    const model = document.getElementById('item-model').value || 'models/props_lab/binderblue.mdl';
    const width = document.getElementById('item-width').value || '1';
    const height = document.getElementById('item-height').value || '1';
    const skillRequired = document.getElementById('skill-required').value.trim();
    const skillValue = document.getElementById('skill-value').value.trim();
    const readTime = document.getElementById('read-time').value || '30';
    const singleUse = document.getElementById('single-use').checked;

    // Generate the code
    let code = `-- Copy and paste this code into your books item file
-- Example: gamemode/items/books/skill_book_guns.lua

ITEM.name = "${name}"
ITEM.desc = "${desc}"
ITEM.category = "${category}"

ITEM.model = "${model}"
ITEM.width = ${width}
ITEM.height = ${height}

ITEM.readTime = ${readTime}

`;

    if (skillRequired && skillValue) {
        code += `ITEM.skillRequired = "${skillRequired}"
ITEM.skillValue = ${skillValue}
`;
    }

    if (singleUse) {
        code += `ITEM.singleUse = true
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