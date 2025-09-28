# Character Creation Panels Library

A comprehensive suite of panels for managing character creation, selection, and management within the Lilia framework.

---

## Overview

The character creation panel library provides all the necessary components for character management, from initial creation to ongoing character administration. These panels work together to create a seamless character creation flow, including biography input, faction selection, model selection, attribute distribution, and character management. All panels integrate with Lilia's character system and theming framework.

---

### liaCharacter

**Purpose**

Main panel of the character selection menu. Lists the player's characters with options to create, delete or load them.

**When Called**

This panel is called when:
- Displaying the character selection menu
- Managing existing characters
- Providing character overview and selection
- Handling character loading and deletion

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Character panel is automatically created by the framework
-- No manual creation needed - it's part of the character system

-- Access programmatically if needed
local charPanel = lia.gui.character
if IsValid(charPanel) then
    -- Refresh character list
    charPanel:RefreshCharacters()
end
```

---

### liaCharacterCreation

**Purpose**

Parent panel that hosts each character creation step such as biography, faction and model. It provides navigation buttons and validates input before advancing.

**When Called**

This panel is called when:
- Starting the character creation process
- Managing multi-step character creation flow
- Providing guided character setup experience
- Handling complex character creation workflows

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by the framework during character creation
-- No manual creation needed - it's part of the character system

-- Programmatic access for custom workflows
local creationPanel = lia.gui.characterCreation
if IsValid(creationPanel) then
    -- Navigate to specific step
    creationPanel:GoToStep("faction")
end
```

---

### liaCharacterCreateStep

**Purpose**

Scroll panel used as the foundation for each creation step. Provides helpers for saving user input and moving forward in the flow.

**When Called**

This panel is called when:
- Creating individual steps in character creation
- Building modular character creation interfaces
- Implementing reusable creation step components
- Managing step-by-step user input processes

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by the framework as part of character creation
-- No manual creation needed - it's part of the character system

-- Create custom step for advanced workflows
local customStep = vgui.Create("liaCharacterCreateStep")
customStep:SetSize(400, 300)
customStep:SetupStep("Custom Step", function()
    -- Custom step validation logic
    return true
end)
```

---

### liaCharacterConfirm

**Purpose**

Confirmation dialog used for dangerous actions like deleting a character. Inherits from `SemiTransparentDFrame` for a consistent overlay look.

**When Called**

This panel is called when:
- Confirming character deletion
- Validating destructive character operations
- Displaying confirmation dialogs for character actions
- Providing safety checks for character management

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by the framework for confirmation dialogs
-- No manual creation needed - it's part of the character system

-- Custom confirmation for advanced use cases
local confirmDialog = vgui.Create("liaCharacterConfirm")
confirmDialog:SetTitle("Delete Character")
confirmDialog:SetMessage("Are you sure you want to delete this character?")
confirmDialog:SetupButtons(function()
    print("Character deleted")
end, function()
    print("Deletion cancelled")
end)
```

---

### liaCharacterBiography

**Purpose**

Step where players input their character's name and optional backstory. These values are validated and stored for later steps.

**When Called**

This panel is called when:
- Collecting character name and description
- Gathering character backstory information
- Validating character naming requirements
- Managing character identity input

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created as part of character creation flow
-- No manual creation needed - it's part of the character system

-- Custom biography step for advanced character creation
local bioStep = vgui.Create("liaCharacterBiography")
bioStep:SetupFields({
    name = {
        label = "Character Name",
        maxLength = 32,
        required = true
    },
    description = {
        label = "Character Description",
        maxLength = 500,
        required = false
    }
})
```

---

### liaCharacterFaction

**Purpose**

Allows the player to choose from available factions. The selected faction updates the model panel and determines accessible classes.

**When Called**

This panel is called when:
- Selecting character faction during creation
- Displaying available faction options
- Managing faction selection interface
- Updating faction-dependent character options

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created as part of character creation flow
-- No manual creation needed - it's part of the character system

-- Custom faction selection for advanced workflows
local factionStep = vgui.Create("liaCharacterFaction")
factionStep:LoadFactions()
factionStep.OnFactionSelected = function(faction)
    print("Selected faction:", faction.name)
end
```

---

### liaCharacterModel

**Purpose**

Lets the player browse and select a player model appropriate for the chosen faction. Clicking an icon saves the choice and refreshes the preview.

**When Called**

This panel is called when:
- Selecting character model during creation
- Displaying model selection interface
- Managing faction-appropriate model choices
- Providing visual character customization

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created as part of character creation flow
-- No manual creation needed - it's part of the character system

-- Custom model selection for advanced character creation
local modelStep = vgui.Create("liaCharacterModel")
modelStep:LoadModelsForFaction(selectedFaction)
modelStep.OnModelSelected = function(model)
    print("Selected model:", model)
end
```

---

### liaCharBGMusic

**Purpose**

Small panel that plays ambient music when the main menu is open. It fades the track in and out as the menu is shown or closed.

**When Called**

This panel is called when:
- Playing background music in menus
- Managing audio ambiance for character screens
- Providing atmospheric sound design
- Creating immersive menu experiences

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Background music panel is automatically created by the framework
-- No manual creation needed - it's part of the menu system

-- Custom music management for advanced audio control
local musicPanel = vgui.Create("liaCharBGMusic")
musicPanel:PlayTrack("character_creation_theme")
musicPanel:SetVolume(0.5)
```

---

### liaCharacterAttribs

**Purpose**

Character creation step panel for distributing attribute points across stats.

**When Called**

This panel is called when:
- Distributing character attribute points
- Managing character stat allocation
- Providing attribute customization interface
- Handling point-based character development

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `updatePointsLeft()` – refreshes the remaining points label.
- `onDisplay()` – loads saved attribute values into the rows.
- `addAttribute(key, info)` – creates a `liaCharacterAttribsRow` for the attribute.
- `onPointChange(key, delta)` – validates and applies a point change request.

**Example Usage**

```lua
-- Usually created as part of character creation flow
-- No manual creation needed - it's part of the character system

-- Custom attribute distribution for advanced character creation
local attribPanel = vgui.Create("liaCharacterAttribs")
attribPanel:AddAttribute("strength", {
    name = "Strength",
    description = "Physical power and combat ability",
    max = 10,
    default = 5
})
attribPanel:UpdatePointsLeft()
```

---

### liaCharacterAttribsRow

**Purpose**

Represents a single attribute with its description and current points, including buttons for adjustment.

**When Called**

This panel is called when:
- Displaying individual character attributes
- Managing single attribute point allocation
- Providing detailed attribute controls
- Creating granular attribute management

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `setAttribute(key, info)` – sets which attribute the row represents and updates its tooltip.
- `delta(amount)` – requests a point change of `amount` from the parent panel.
- `addButton(symbol, delta)` – internal helper that creates the increment/decrement buttons.
- `updateQuantity()` – refreshes the displayed point total.

**Example Usage**

```lua
-- Usually created by liaCharacterAttribs panel
-- No manual creation needed - it's part of the attribute system

-- Custom attribute row for advanced attribute management
local attribRow = vgui.Create("liaCharacterAttribsRow")
attribRow:SetAttribute("strength", {
    name = "Strength",
    description = "Physical power and combat ability",
    max = 10,
    min = 1
})
```

---
