# Books Item Definition

Book and note items are readable inventory entries that hold long-form text. Use them for journals, manuals, notes, records, or any item that opens written content for the player.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/books/[item_id].lua` or `modules/[module]/items/books/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/books.lua` or `modules/[module]/items/base/books.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `model` | `string` | World and inventory model used by the item. |
| `contents` | `string` | Main readable text opened by the item. |

## Normal Item File Example

```lua
ITEM.name = "Medical Journal"
ITEM.desc = "A journal containing treatment notes."
ITEM.category = "books"
ITEM.model = "models/props_lab/binderblue.mdl"
ITEM.contents = [[
Entry 14:
The patient responded well to the second treatment cycle.
]]

ITEM.functions.Read = {
    name = "read",
    tip = "readTip",
    icon = "icon16/book_open.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            client:requestString("Reading", item.name, function() end, item.contents)
        end

        return false
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("medical_journal", "base_books", false, nil, true)

item.name = "Medical Journal"
item.desc = "A journal containing treatment notes."
item.category = "books"
item.model = "models/props_lab/binderblue.mdl"
item.contents = [[
Entry 14:
The patient responded well to the second treatment cycle.
]]

item.functions.Read = {
    name = "read",
    tip = "readTip",
    icon = "icon16/book_open.png",
    onRun = function(itemInstance)
        local client = itemInstance.player
        if IsValid(client) then
            client:requestString("Reading", itemInstance.name, function() end, itemInstance.contents)
        end

        return false
    end
}
```
