# URL Item Definition

URL items point at external web content. Use them when an item should open a website, hosted document, or another remote resource from inside the inventory.

## Placement

Register URL items in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `model` | `string` | World and inventory model used by the item. |
| `url` | `string` | Remote URL opened or referenced by the item. |

## Example

```lua
lia.item.registerItem("website_link", "base_url", {
    name = "Website Link",
    desc = "A link to an external website.",
    model = "models/props_lab/clipboard.mdl",
    url = "https://example.com"
})
```
