# URL Item Definition

URL items point at external web content. Use them when an item should open a website, hosted document, or another remote resource from inside the inventory.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/url/[item_id].lua` or `modules/[module]/items/url/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/url.lua` or `modules/[module]/items/base/url.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `model` | `string` | World and inventory model used by the item. |
| `url` | `string` | Remote URL opened or referenced by the item. |

## Normal Item File Example

```lua
ITEM.name = "Website Link"
ITEM.desc = "A link to an external website."
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.url = "https://example.com"

ITEM.functions.Open = {
    name = "open",
    tip = "useTip",
    icon = "icon16/world_link.png",
    onRun = function(item)
        gui.OpenURL(item.url)
        return false
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("website_link", "base_url", false, nil, true)

item.name = "Website Link"
item.desc = "A link to an external website."
item.model = "models/props_lab/clipboard.mdl"
item.url = "https://example.com"

item.functions.Open = {
    name = "open",
    tip = "useTip",
    icon = "icon16/world_link.png",
    onRun = function(itemInstance)
        gui.OpenURL(itemInstance.url)
        return false
    end
}
```
