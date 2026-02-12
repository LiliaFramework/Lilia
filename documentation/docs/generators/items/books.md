# Book & Note Item Generator

Create readable items like books, documents, or notes for your server.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom book or note. Once generated, the code should be placed in a new file within your schema's items directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/items/[item_id].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-id">Unique ID:</label>
          <input type="text" id="item-id" placeholder="e.g., city_guide" value="city_guide" oninput="generateBookItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., City Guide" value="Universal City Guide" oninput="generateBookItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A small book containing information about the city" oninput="generateBookItem()">A comprehensive guide detailing the laws, locations, and history of the local district.</textarea>
      </div>

    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="item-model">Model:</label>
        <input type="text" id="item-model" placeholder="models/props_lab/binderblue.mdl" value="models/props_lab/binderblue.mdl" oninput="generateBookItem()">
        <small>3D model path for the book item</small>
      </div>

      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-width">Width:</label>
          <input type="number" id="item-width" placeholder="1" min="1" value="1" oninput="generateBookItem()">
          <small>Inventory slot width</small>
        </div>

        <div class="input-group">
          <label for="item-height">Height:</label>
          <input type="number" id="item-height" placeholder="1" min="1" value="1" oninput="generateBookItem()">
          <small>Inventory slot height</small>
        </div>
      </div>
    </div>

    <div class="generator-section">
      <div class="input-group">
        <label for="book-title">In-Game Book Title:</label>
        <input type="text" id="book-title" placeholder="e.g., The Rules of Engagement" value="The Citizen's Handbook" oninput="generateBookItem()">
        <small>The title displayed when the book is opened in-game</small>
      </div>

      <div class="input-group">
        <label for="book-content">Book Content:</label>
        <textarea id="book-content" placeholder="e.g., Welcome to the city... (Supports \n for new lines)" oninput="generateBookItem()" style="height: 200px;">Section 1: Civil Conduct\nAll citizens must remain within their designated blocks during curfew hours...\n\nSection 2: Ration Distribution\nRation packets are distributed every 24 hours at the Central Hub.</textarea>
        <small>The text content of the book.</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateBookItem()" class="generate-btn">Generate Book Item Code</button>
      <button onclick="fillExampleBookItem()" class="generate-btn example-btn">Generate Example</button>
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
function generateBookItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'book_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Book Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A readable item';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_lab/binderblue.mdl';
  const width = document.getElementById('item-width').value || '1';
  const height = document.getElementById('item-height').value || '1';
  const bookTitle = (document.getElementById('book-title').value || '').trim() || 'Untitled Book';
  const bookContent = (document.getElementById('book-content').value || '').trim() || 'No content...';

  const properties = [
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    width = ${width},`,
    `    height = ${height},`,
    `    title = ${JSON.stringify(bookTitle)},`,
    `    text = ${JSON.stringify(bookContent)}`
  ];

  const lines = [
  '-- Copy and paste this code into any Lua file that loads during initialization',
  '-- Example: [schema folder]/schema/items.lua',
  '',
  `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_books", {`,
  ...properties,
  '})'
  ];

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleBookItem() {
  document.getElementById('item-id').value = 'secret_memo';
  document.getElementById('item-name').value = 'Encrypted Memo';
  document.getElementById('item-desc').value = 'A tattered piece of paper with scribbled notes that appear to be a secret code.';
  document.getElementById('item-model').value = 'models/props_lab/paper_count.mdl';
  document.getElementById('item-width').value = '1';
  document.getElementById('item-height').value = '1';
  document.getElementById('book-title').value = 'RECOVERED MEMO #42';
  document.getElementById('book-content').value = 'The package is buried behind the old warehouse at 0400. Bring the key designated as ALPHA-RHO. If the patrol arrives, terminate the operation immediately.\n\n- Zero';

  generateBookItem();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateBookItem();
});
</script>

---
