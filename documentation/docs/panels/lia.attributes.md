# Attribute and Progress Panel Library

This page documents the attribute and progress display panel components for the Lilia framework.

---

## Overview

The attribute and progress panel library provides UI components for displaying character attributes, progress bars, and various progress indicators. These panels handle attribute visualization, progress tracking, and interactive attribute management.

---

### liaAttribBar

**Purpose**

Displays a single attribute with visual progress bar and interactive controls for modification.

**When Called**

This panel is called when:
- Individual character attributes need to be displayed
- Attribute modification with visual feedback is required
- Interactive attribute bars are needed

**Parameters**

* `attribute` (*table*): Attribute configuration data.
* `currentValue` (*number*): Current attribute value.
* `maxValue` (*number*): Maximum possible attribute value.
* `boostValue` (*number*): Temporary boost value to display.

**Returns**

* `panel` (*Panel*): The created attribute bar panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create attribute bar for strength
local strengthBar = vgui.Create("liaAttribBar")
strengthBar:setAttribute("strength", {
    name = "Strength",
    desc = "Physical strength attribute",
    max = 10
})
strengthBar:setValue(7)
strengthBar:setMax(10)

-- Add temporary boost indicator
strengthBar:setBoost(2)

-- Handle value changes
strengthBar:onChanged = function(newValue)
    print("Strength changed to: " .. newValue)
end
```

---

### liaDProgressBar

**Purpose**

Generic progress bar component for displaying progress, loading states, and timed operations.

**When Called**

This panel is called when:
- Progress indication is needed for operations
- Loading states need to be displayed
- Time-based progress tracking is required

**Parameters**

* `fraction` (*number*): Progress fraction (0.0 to 1.0).
* `startTime` (*number*): Start time for timed progress.
* `endTime` (*number*): End time for timed progress.
* `text` (*string*): Text to display on the progress bar.

**Returns**

* `panel` (*Panel*): The created progress bar panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create simple progress bar
local progressBar = vgui.Create("liaDProgressBar")
progressBar:setFraction(0.75) -- 75% complete
progressBar:setText("Loading...")

-- Create timed progress bar
local timedProgress = vgui.Create("liaDProgressBar")
timedProgress:setProgress(CurTime(), CurTime() + 10) -- 10 second timer
timedProgress:setText("Processing...")

-- Update progress
progressBar:setFraction(math.min(progress / maxProgress, 1.0))
```

---

### liaCharacterAttribs

**Purpose**

Container panel for managing multiple character attributes with point allocation system.

**When Called**

This panel is called when:
- Multiple character attributes need to be managed
- Point-based attribute allocation is required
- Character creation attribute selection is needed

**Parameters**

* `attributes` (*table*): Array of attribute configurations.
* `maxPoints` (*number*): Maximum points available for allocation.
* `currentPoints` (*number*): Currently allocated points.

**Returns**

* `panel` (*Panel*): The created character attributes panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create character attributes panel
local attribPanel = vgui.Create("liaCharacterAttribs")
attribPanel:setMaxPoints(30)

-- Add attributes
attribPanel:addAttribute("strength", strengthConfig)
attribPanel:addAttribute("agility", agilityConfig)
attribPanel:addAttribute("intelligence", intelligenceConfig)

-- Handle point allocation
attribPanel:onPointChange = function(attribute, delta)
    print("Changed " .. attribute .. " by " .. delta)
    return newValue -- Return new value or false to cancel
end
```

---

### liaCharacterAttribsRow

**Purpose**

Individual row component for attribute display and modification within attribute panels.

**When Called**

This panel is called when:
- Individual attribute rows need to be created
- Attribute modification controls are needed
- Attribute display within larger panels is required

**Parameters**

* `attribute` (*table*): Attribute configuration data.
* `currentValue` (*number*): Current attribute value.
* `minValue` (*number*): Minimum allowed value.
* `maxValue` (*number*): Maximum allowed value.

**Returns**

* `panel` (*Panel*): The created attribute row panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create attribute row
local attribRow = vgui.Create("liaCharacterAttribsRow")
attribRow:setAttribute("dexterity", {
    name = "Dexterity",
    desc = "Agility and precision",
    max = 10
})
attribRow:setValue(5)

-- Handle value changes
attribRow:delta = function(delta)
    local newValue = currentValue + delta
    if newValue >= minValue and newValue <= maxValue then
        return newValue
    end
    return false -- Cancel change
end
```
