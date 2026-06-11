# Attribute Definitions

Attributes define character stats such as strength, endurance, or medical skill. They control how high a stat can go, how much of it can be assigned during character creation, and what setup logic should run when the character's attribute values are applied.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in menus, tooltips, and attribute UI. |
| `desc` | `string` | Description text used anywhere the attribute is explained to the player. |
| `maxValue` | `number` | Maximum value this attribute can reach. |
| `startingMax` | `number` | Maximum value this attribute can have during character creation. |
| `noStartBonus` | `boolean` | Stops this attribute from appearing in character creation point allocation. |
| `OnSetup(client, value)` | `function` | Runs when the character's attribute state is being set up. |

## Example

```lua
ATTRIBUTE.name = "Strength"
ATTRIBUTE.desc = "Physical power and muscle strength."
ATTRIBUTE.maxValue = 50
ATTRIBUTE.startingMax = 20
ATTRIBUTE.noStartBonus = false

function ATTRIBUTE:OnSetup(client, value)
    local char = client:getChar()
    if not char then return end

    if value == 0 then
        char:setAttrib(self.uniqueID, 10)
    end
end
```

