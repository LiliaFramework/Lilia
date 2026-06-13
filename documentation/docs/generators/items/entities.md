# Entity Item Generator

Create inventory items that place scripted entities or deployable objects into the world when used.

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
          <input type="text" id="item-id" placeholder="e.g., chair" value="chair" oninput="generateEntityItem()">
          <small>Unique identifier for this item (no spaces, lowercase)</small>
        </div>

        <div class="input-group">
          <label for="item-name">Item Name:</label>
          <input type="text" id="item-name" placeholder="e.g., Chair" value="Chair" oninput="generateEntityItem()">
        </div>
      </div>

      <div class="input-group">
        <label for="item-desc">Description:</label>
        <textarea id="item-desc" placeholder="e.g., A placeable chair" oninput="generateEntityItem()">A placeable prop that can be deployed into the world.</textarea>
      </div>
    </div>

    <div class="generator-section">
      <div class="form-grid-2">
        <div class="input-group">
          <label for="item-model">Item Model:</label>
          <input type="text" id="item-model" placeholder="models/props_c17/FurnitureChair001a.mdl" value="models/props_c17/FurnitureChair001a.mdl" oninput="generateEntityItem()">
        </div>

        <div class="input-group">
          <label for="entity-id">Entity Class:</label>
          <input type="text" id="entity-id" placeholder="e.g., prop_physics" value="prop_physics" oninput="generateEntityItem()">
          <small>The scripted entity class created when the item is placed</small>
        </div>
      </div>
    </div>

    <div class="button-group">
      <button onclick="generateEntityItem()" class="generate-btn">Generate Entity Item Code</button>
      <button onclick="fillExampleEntityItem()" class="generate-btn example-btn">Generate Example</button>
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
function generateEntityItem() {
  const uniqueId = (document.getElementById('item-id').value || '').trim() || 'entity_example';
  const name = (document.getElementById('item-name').value || '').trim() || 'Entity Item';
  const desc = (document.getElementById('item-desc').value || '').trim() || 'A placeable entity item';
  const model = (document.getElementById('item-model').value || '').trim() || 'models/props_c17/FurnitureChair001a.mdl';
  const entityId = (document.getElementById('entity-id').value || '').trim() || 'prop_physics';

  const lines = [
    `lia.item.registerItem(${JSON.stringify(uniqueId)}, "base_entities", {`,
    `    name = ${JSON.stringify(name)},`,
    `    desc = ${JSON.stringify(desc)},`,
    `    model = ${JSON.stringify(model)},`,
    `    entityid = ${JSON.stringify(entityId)},`,
    '})'
  ];

  const outputBox = document.getElementById('output-code');
  if (outputBox) outputBox.value = `${lines.join('\n')}\n`;
}

function fillExampleEntityItem() {
  document.getElementById('item-id').value = 'barricade';
  document.getElementById('item-name').value = 'Portable Barricade';
  document.getElementById('item-desc').value = 'A collapsible barricade that can be deployed to block a hallway or doorway.';
  document.getElementById('item-model').value = 'models/props_c17/FurnitureShelf001a.mdl';
  document.getElementById('entity-id').value = 'prop_physics';

  generateEntityItem();
}

document.addEventListener('DOMContentLoaded', () => {
  generateEntityItem();
});
</script>
