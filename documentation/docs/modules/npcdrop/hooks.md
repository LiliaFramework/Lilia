# Hooks

This document describes the hooks available in the NPC Drop module for managing NPC item drop functionality.

---

## NPCDropCheck

**Purpose**

Called when an NPC drop check is performed.

**Parameters**

* `ent` (*Entity*): The NPC entity being checked for drops.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC is killed
- Before any drop table checks
- When the drop process begins

**Example Usage**

```lua
-- Track NPC drop checks
hook.Add("NPCDropCheck", "TrackNPCDropChecks", function(ent)
    -- Track check
    local checks = lia.data.get("npc_drop_checks", 0)
    lia.data.set("npc_drop_checks", checks + 1)
    
    lia.log.add(nil, "npcDropCheck", ent)
end)

-- Apply NPC drop check effects
hook.Add("NPCDropCheck", "NPCDropCheckEffects", function(ent)
    -- Create check effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play check sound
    ent:EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track NPC drop check statistics
hook.Add("NPCDropCheck", "TrackNPCDropCheckStats", function(ent)
    -- Track check frequency
    local checkFrequency = lia.data.get("npc_drop_check_frequency", 0)
    lia.data.set("npc_drop_check_frequency", checkFrequency + 1)
    
    -- Track check patterns
    local checkPatterns = lia.data.get("npc_drop_check_patterns", {})
    table.insert(checkPatterns, {
        class = ent:GetClass(),
        time = os.time()
    })
    lia.data.set("npc_drop_check_patterns", checkPatterns)
end)
```

---

## NPCDropFailed

**Purpose**

Called when an NPC drop attempt fails.

**Parameters**

* `ent` (*Entity*): The NPC entity that failed to drop items.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC drop attempt fails
- When no item is selected from the drop table
- After `NPCDropRoll` hook

**Example Usage**

```lua
-- Track NPC drop failures
hook.Add("NPCDropFailed", "TrackNPCDropFailures", function(ent)
    -- Track failure
    local failures = lia.data.get("npc_drop_failures", 0)
    lia.data.set("npc_drop_failures", failures + 1)
    
    lia.log.add(nil, "npcDropFailed", ent)
end)

-- Apply NPC drop failure effects
hook.Add("NPCDropFailed", "NPCDropFailureEffects", function(ent)
    -- Create failure effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play failure sound
    ent:EmitSound("buttons/button16.wav", 75, 100)
end)

-- Track NPC drop failure statistics
hook.Add("NPCDropFailed", "TrackNPCDropFailureStats", function(ent)
    -- Track failure frequency
    local failureFrequency = lia.data.get("npc_drop_failure_frequency", 0)
    lia.data.set("npc_drop_failure_frequency", failureFrequency + 1)
    
    -- Track failure patterns
    local failurePatterns = lia.data.get("npc_drop_failure_patterns", {})
    table.insert(failurePatterns, {
        class = ent:GetClass(),
        time = os.time()
    })
    lia.data.set("npc_drop_failure_patterns", failurePatterns)
end)
```

---

## NPCDropNoItems

**Purpose**

Called when an NPC has no items in its drop table.

**Parameters**

* `ent` (*Entity*): The NPC entity that has no items.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC has no items in its drop table
- When the total weight is 0 or less
- After `NPCDropNoTable` hook

**Example Usage**

```lua
-- Track NPC drop no items
hook.Add("NPCDropNoItems", "TrackNPCDropNoItems", function(ent)
    -- Track no items
    local noItems = lia.data.get("npc_drop_no_items", 0)
    lia.data.set("npc_drop_no_items", noItems + 1)
    
    lia.log.add(nil, "npcDropNoItems", ent)
end)

-- Apply NPC drop no items effects
hook.Add("NPCDropNoItems", "NPCDropNoItemsEffects", function(ent)
    -- Create no items effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play no items sound
    ent:EmitSound("buttons/button16.wav", 75, 100)
end)

-- Track NPC drop no items statistics
hook.Add("NPCDropNoItems", "TrackNPCDropNoItemsStats", function(ent)
    -- Track no items frequency
    local noItemsFrequency = lia.data.get("npc_drop_no_items_frequency", 0)
    lia.data.set("npc_drop_no_items_frequency", noItemsFrequency + 1)
    
    -- Track no items patterns
    local noItemsPatterns = lia.data.get("npc_drop_no_items_patterns", {})
    table.insert(noItemsPatterns, {
        class = ent:GetClass(),
        time = os.time()
    })
    lia.data.set("npc_drop_no_items_patterns", noItemsPatterns)
end)
```

---

## NPCDropNoTable

**Purpose**

Called when an NPC has no drop table.

**Parameters**

* `ent` (*Entity*): The NPC entity that has no drop table.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC has no drop table
- When the drop table is not found
- After `NPCDropCheck` hook

**Example Usage**

```lua
-- Track NPC drop no table
hook.Add("NPCDropNoTable", "TrackNPCDropNoTable", function(ent)
    -- Track no table
    local noTable = lia.data.get("npc_drop_no_table", 0)
    lia.data.set("npc_drop_no_table", noTable + 1)
    
    lia.log.add(nil, "npcDropNoTable", ent)
end)

-- Apply NPC drop no table effects
hook.Add("NPCDropNoTable", "NPCDropNoTableEffects", function(ent)
    -- Create no table effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play no table sound
    ent:EmitSound("buttons/button16.wav", 75, 100)
end)

-- Track NPC drop no table statistics
hook.Add("NPCDropNoTable", "TrackNPCDropNoTableStats", function(ent)
    -- Track no table frequency
    local noTableFrequency = lia.data.get("npc_drop_no_table_frequency", 0)
    lia.data.set("npc_drop_no_table_frequency", noTableFrequency + 1)
    
    -- Track no table patterns
    local noTablePatterns = lia.data.get("npc_drop_no_table_patterns", {})
    table.insert(noTablePatterns, {
        class = ent:GetClass(),
        time = os.time()
    })
    lia.data.set("npc_drop_no_table_patterns", noTablePatterns)
end)
```

---

## NPCDroppedItem

**Purpose**

Called when an NPC drops an item.

**Parameters**

* `ent` (*Entity*): The NPC entity that dropped the item.
* `itemName` (*string*): The name of the item that was dropped.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC successfully drops an item
- After `NPCDropRoll` hook
- When the item is spawned

**Example Usage**

```lua
-- Track NPC dropped items
hook.Add("NPCDroppedItem", "TrackNPCDroppedItems", function(ent, itemName)
    -- Track dropped item
    local droppedItems = lia.data.get("npc_dropped_items", 0)
    lia.data.set("npc_dropped_items", droppedItems + 1)
    
    lia.log.add(nil, "npcDroppedItem", ent, itemName)
end)

-- Apply NPC dropped item effects
hook.Add("NPCDroppedItem", "NPCDroppedItemEffects", function(ent, itemName)
    -- Create dropped item effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play dropped item sound
    ent:EmitSound("buttons/button14.wav", 75, 100)
end)

-- Track NPC dropped item statistics
hook.Add("NPCDroppedItem", "TrackNPCDroppedItemStats", function(ent, itemName)
    -- Track dropped item frequency
    local droppedItemFrequency = lia.data.get("npc_dropped_item_frequency", 0)
    lia.data.set("npc_dropped_item_frequency", droppedItemFrequency + 1)
    
    -- Track dropped item patterns
    local droppedItemPatterns = lia.data.get("npc_dropped_item_patterns", {})
    table.insert(droppedItemPatterns, {
        class = ent:GetClass(),
        item = itemName,
        time = os.time()
    })
    lia.data.set("npc_dropped_item_patterns", droppedItemPatterns)
end)
```

---

## NPCDropRoll

**Purpose**

Called when an NPC drop roll is made.

**Parameters**

* `ent` (*Entity*): The NPC entity being rolled for drops.
* `choice` (*number*): The random choice value.
* `totalWeight` (*number*): The total weight of all items.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC drop roll is made
- After `NPCDropNoItems` hook
- Before `NPCDroppedItem` hook

**Example Usage**

```lua
-- Track NPC drop rolls
hook.Add("NPCDropRoll", "TrackNPCDropRolls", function(ent, choice, totalWeight)
    -- Track roll
    local rolls = lia.data.get("npc_drop_rolls", 0)
    lia.data.set("npc_drop_rolls", rolls + 1)
    
    lia.log.add(nil, "npcDropRoll", ent, choice, totalWeight)
end)

-- Apply NPC drop roll effects
hook.Add("NPCDropRoll", "NPCDropRollEffects", function(ent, choice, totalWeight)
    -- Create roll effect
    local effect = EffectData()
    effect:SetOrigin(ent:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play roll sound
    ent:EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track NPC drop roll statistics
hook.Add("NPCDropRoll", "TrackNPCDropRollStats", function(ent, choice, totalWeight)
    -- Track roll frequency
    local rollFrequency = lia.data.get("npc_drop_roll_frequency", 0)
    lia.data.set("npc_drop_roll_frequency", rollFrequency + 1)
    
    -- Track roll patterns
    local rollPatterns = lia.data.get("npc_drop_roll_patterns", {})
    table.insert(rollPatterns, {
        class = ent:GetClass(),
        choice = choice,
        totalWeight = totalWeight,
        time = os.time()
    })
    lia.data.set("npc_drop_roll_patterns", rollPatterns)
end)
```
