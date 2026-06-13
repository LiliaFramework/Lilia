# Books Item Definition

Book and note items are readable inventory entries that hold long-form text. Use them for journals, manuals, notes, records, or any item that opens written content for the player.

## Placement

Register books and notes in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `model` | `string` | World and inventory model used by the item. |
| `contents` | `string` | Main readable text opened by the item. |

## Example

```lua
lia.item.registerItem("medical_journal", "base_books", {
    name = "Medical Journal",
    desc = "A journal containing treatment notes.",
    category = "books",
    model = "models/props_lab/binderblue.mdl",
    contents = [[
Entry 14:
The patient responded well to the second treatment cycle.
]]
})
```
