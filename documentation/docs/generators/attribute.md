# Attribute Generator

Create persistent character attributes such as strength, endurance, intelligence, crafting skill, medical knowledge, or schema-specific progression stats. Attributes are best used for values that should follow a character over time and influence schema logic, item behavior, or roleplay progression.

Output Location:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_attributes.lua
```

You can also add callback fields like `OnSetup` or any custom logic manually after generation. You can find those in [Attribute Definitions](../definitions/attributes.md).

<div class="generator-grid">
  <!-- Input Column -->
  <div class="generator-card form-card">
    <div class="generator-section">
      <div class="input-group">
        <label for="attribute-id">Attribute ID:</label>
        <input type="text" id="attribute-id" placeholder="e.g., strength">
        <small>Unique ID used when registering the attribute. Leave empty to derive it from the name.</small>
      </div>

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
function toLuaIdentifier(value) {
  return (value || '')
  .trim()
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '_')
  .replace(/^_+|_+$/g, '') || 'attribute_name';
}

function generateAttribute() {
  const uniqueIDSource = (document.getElementById('attribute-id').value || '').trim();
  const name = (document.getElementById('attribute-name').value || '').trim() || 'Attribute Name';
  const desc = (document.getElementById('attribute-desc').value || '').trim() || 'Attribute description';
  const uniqueID = toLuaIdentifier(uniqueIDSource || name);
  const maxValue = document.getElementById('max-value').value.trim() || '100';
  const startingMax = document.getElementById('starting-max').value.trim();
  const noStartBonus = document.getElementById('no-start-bonus').checked;

  const lines = [
    `lia.attribs.register(${JSON.stringify(uniqueID)}, {`,
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`
  ];

  if (maxValue !== '100') {
    lines.push(`    maxValue = ${maxValue},`);
  }

  if (startingMax || noStartBonus) {
    lines.push('');
    if (startingMax) lines.push(`    startingMax = ${startingMax},`);
    if (noStartBonus) lines.push('    noStartBonus = true,');
  }

  lines.push('})');

  const code = `${lines.join('\n')}\n`;

  const outputBox = document.getElementById('output-code');
  if (outputBox) {
    outputBox.value = code;
  }
}

function fillExampleAttribute() {
  document.getElementById('attribute-id').value = 'endurance';
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
