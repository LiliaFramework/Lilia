# Attribute Generator

Quickly create custom character attributes like Strength, Endurance, or Intelligence.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Use this tool to generate the Lua structure for your custom attribute. Once generated, the code should be placed in a new file within your schema's attributes directory.</p>
  <p><strong>Recommended Placement:</strong></p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/schema/attributes/[attribute_name].lua</code>
</div>

---

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
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
      <div class="form-grid-2">
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
      </div>

      <div class="input-group">
        <label>
          <input type="checkbox" id="no-start-bonus"> No Starting Bonus
        </label>
        <small>Disable automatic attribute points at character creation</small>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateAttribute()" class="generate-btn">Generate Attribute Code</button>
      <button onclick="fillExampleAttribute()" class="generate-btn example-btn">Generate Example</button>
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
function generateAttribute() {
  const name = (document.getElementById('attribute-name').value || '').trim() || 'Attribute Name';
  const desc = (document.getElementById('attribute-desc').value || '').trim() || 'Attribute description';
  const maxValue = document.getElementById('max-value').value || '100';
  const startingMax = document.getElementById('starting-max').value.trim();
  const noStartBonus = document.getElementById('no-start-bonus').checked;

  const lines = [
    '-- Copy and paste this code into your attribute file',
    '-- Example: [schema folder]/attributes/strength.lua',
    '',
    `ATTRIBUTE.name = ${JSON.stringify(name)}`,
    `ATTRIBUTE.desc = ${JSON.stringify(desc)}`,
    `ATTRIBUTE.maxValue = ${maxValue}`
  ];

  if (startingMax) lines.push(`ATTRIBUTE.startingMax = ${startingMax}`);
  lines.push(`ATTRIBUTE.noStartBonus = ${noStartBonus ? 'true' : 'false'}`);

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleAttribute() {
  document.getElementById('attribute-name').value = 'Endurance';
  document.getElementById('attribute-desc').value = 'Physical stamina and resilience. Affects maximum health and sprint duration.';
  document.getElementById('max-value').value = '100';
  document.getElementById('starting-max').value = '25';
  document.getElementById('no-start-bonus').checked = false;

  generateAttribute();
}

// Initial generation
document.addEventListener('DOMContentLoaded', () => {
  generateAttribute();
});
</script>

---
