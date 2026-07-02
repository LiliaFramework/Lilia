# URL Item Generator

Create items that open external websites, documents, or other remote resources from the inventory.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

<div class="generator-grid">
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., website_link" value="website_link" oninput="generateURLItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Website Link" value="Website Link" oninput="generateURLItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A link to an external website" oninput="generateURLItem()">A quick-access link to an external resource.</textarea>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-model">Item Model:</label>
          <input type="text" id="item-model" placeholder="models/props_lab/clipboard.mdl" value="models/props_lab/clipboard.mdl" oninput="generateURLItem()">
        </div>

        <div class="input-group">
          <label for="item-url">URL:</label>
          <input type="text" id="item-url" placeholder="https://example.com" value="https://example.com" oninput="generateURLItem()">
          <small>The remote URL opened by the item</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Inventory Width:</label>
          <input type="number" id="item-width" min="1" step="1" value="1" oninput="generateURLItem()">
        </div>

        <div class="input-group">
          <label for="item-height">Inventory Height:</label>
          <input type="number" id="item-height" min="1" step="1" value="1" oninput="generateURLItem()">
        </div>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-frame-width">Browser Width:</label>
          <input type="number" id="item-frame-width" min="480" step="1" value="1100" oninput="generateURLItem()">
          <small>Maximum window width before screen-based clamping</small>
        </div>

        <div class="input-group">
          <label for="item-frame-tall">Browser Tall:</label>
          <input type="number" id="item-frame-tall" min="360" step="1" value="800" oninput="generateURLItem()">
          <small>Maximum window height before screen-based clamping</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateURLItem()" class="generate-btn">Generate URL Item Code</button>
      <button onclick="fillExampleURLItem()" class="generate-btn example-btn">Generate Example</button>
    </div>
  </div>

  <div class="generator-card output-card">
    <div class="card-header">
      <h3>Generated Code</h3>
    </div>
    <textarea id="output-code" class="generator-code-output" readonly></textarea>
  </div>
</div>

<script>
function generateURLItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'url_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'URL Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'An item that opens a URL';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_lab/clipboard.mdl';
  const url = (document.getElementById('item-url').value || '').trim() || 'https://example.com';
  const width = Math.max(1, parseInt(document.getElementById('item-width').value, 10) || 1);
  const height = Math.max(1, parseInt(document.getElementById('item-height').value, 10) || 1);
  const frameWidth = Math.max(480, parseInt(document.getElementById('item-frame-width').value, 10) || 1100);
  const frameTall = Math.max(360, parseInt(document.getElementById('item-frame-tall').value, 10) || 800);

  const lines = [
    `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_url", {`,
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    url = ${JSON.stringify(url)},`,
    `    frameWidth = ${frameWidth},`,
    `    frameTall = ${frameTall},`,
    '})'
  ];

  const outputBox = document.getElementById('output-code');
  if (outputBox) outputBox.value = `${lines.join('\n')}\n`;
}

function fillExampleURLItem() {
  document.getElementById('item-id').value = 'rules_portal';
  document.getElementById('item-name').value = 'Rules Portal';
  document.getElementById('item-desc').value = 'Opens the server rules and onboarding page in the Steam overlay browser.';
  document.getElementById('item-model').value = 'models/props_lab/binderblue.mdl';
  document.getElementById('item-url').value = 'https://example.com/rules';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('item-frame-width').value = '1100';
  document.getElementById('item-frame-tall').value = '800';

  generateURLItem();
}

document.addEventListener('DOMContentLoaded', () => {
  generateURLItem();
});
</script>
