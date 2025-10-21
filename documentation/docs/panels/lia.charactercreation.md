# Character Creation Panel Library

This page documents the character creation and management panel components for the Lilia framework.

---

## Overview

The character creation panel library provides a comprehensive set of UI components for creating and managing character creation workflows. These panels handle the step-by-step process of character creation, including model selection, faction choice, attribute allocation, and biography input.

---

### liaCharacterCreation

**Purpose**

Manages the complete character creation workflow with multiple steps and validation.

**When Called**

This panel is called when:
- Players need to create new characters
- Character creation menu is opened
- Multi-step character setup is required
- Character validation and confirmation is needed

**Parameters**

* `context` (*table*): Character creation context data.
* `steps` (*table*): Array of creation step panels.

**Returns**

* `panel` (*Panel*): The created character creation panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Open character creation menu
local creation = vgui.Create("liaCharacterCreation")
creation:configureSteps()
creation:displayStep(1)

-- Create character creation with custom context
local customCreation = vgui.Create("liaCharacterCreation")
customCreation.context = {
    faction = 1,
    model = 1
}
customCreation:configureSteps()
```

---

### liaCharacterCreateStep

**Purpose**

Base panel class for individual character creation steps with navigation and validation.

**When Called**

This panel is called when:
- Creating individual steps in character creation
- Building custom character creation workflows
- Implementing step-based interfaces

**Parameters**

* `title` (*string*): Step title.
* `description` (*string*): Step description.

**Returns**

* `panel` (*Panel*): The created step panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a custom character creation step
local PANEL = {}
function PANEL:Init()
    self:addLabel("Custom Step")
    self:addDescription("This is a custom step")
end

function PANEL:onDisplay()
    -- Step display logic
end

vgui.Register("liaCustomStep", PANEL, "liaCharacterCreateStep")
```

---

### liaCharacterModel

**Purpose**

Displays and manages character model selection with visual preview and filtering.

**When Called**

This panel is called when:
- Players need to select character models
- Model preview and selection is required
- Faction-based model filtering is needed

**Parameters**

* `faction` (*number*): Faction index to filter models.
* `selectedModel` (*number*): Currently selected model index.

**Returns**

* `panel` (*Panel*): The created model selection panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create model selection step
local modelStep = vgui.Create("liaCharacterModel")
modelStep:setContext("faction", 1)
modelStep:onDisplay()

-- Get selected model
local selectedModel = modelStep:getContext("model")
```

---

### liaCharacterFaction

**Purpose**

Displays and manages faction selection for character creation.

**When Called**

This panel is called when:
- Players need to select a faction for their character
- Faction-based gameplay restrictions are in place
- Character faction assignment is required

**Parameters**

* `factions` (*table*): Available factions to display.
* `selectedFaction` (*number*): Currently selected faction index.

**Returns**

* `panel` (*Panel*): The created faction selection panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create faction selection step
local factionStep = vgui.Create("liaCharacterFaction")
factionStep:onDisplay()

-- Set available factions
factionStep:setFactions(availableFactions)
```

---

### liaCharacterBiography

**Purpose**

Provides text input for character biography and background information.

**When Called**

This panel is called when:
- Players need to enter character backstory
- Biography validation is required
- Character description input is needed

**Parameters**

* `maxLength` (*number*): Maximum biography length.
* `placeholder` (*string*): Placeholder text for the input.

**Returns**

* `panel` (*Panel*): The created biography panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create biography input step
local bioStep = vgui.Create("liaCharacterBiography")
bioStep:setMaxLength(500)
bioStep:setPlaceholder("Enter your character's backstory...")

-- Get entered biography
local biography = bioStep:getBiography()
```

---

### liaCharacterConfirm

**Purpose**

Displays character summary and confirmation before final creation.

**When Called**

This panel is called when:
- Character creation needs final confirmation
- Character summary display is required
- Final validation before character creation

**Parameters**

* `characterData` (*table*): Complete character data to display.
* `onConfirm` (*function*): Callback function when confirmed.

**Returns**

* `panel` (*Panel*): The created confirmation panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create confirmation dialog
local confirm = vgui.Create("liaCharacterConfirm")
confirm:setCharacterData(characterData)
confirm:setConfirmCallback(function()
    -- Character creation logic
    print("Character confirmed!")
end)
```

---

### liaCharacter

**Purpose**

Main character panel for displaying character information and management.

**When Called**

This panel is called when:
- Character selection interface is needed
- Character information display is required
- Character switching functionality is needed

**Parameters**

* `characters` (*table*): Array of available characters.
* `selectedCharacter` (*number*): Currently selected character index.

**Returns**

* `panel` (*Panel*): The created character panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create character selection interface
local charPanel = vgui.Create("liaCharacter")
charPanel:populateCharacters(playerCharacters)
charPanel:selectCharacter(1)

-- Handle character selection
charPanel.onCharacterSelected = function(charIndex, character)
    print("Selected character: " .. character.name)
end
```

---

### liaCharacterAttribs

**Purpose**

Manages character attribute allocation with visual progress bars and point distribution.

**When Called**

This panel is called when:
- Character attribute point allocation is needed
- Attribute modification during character creation
- Attribute display and management is required

**Parameters**

* `attributes` (*table*): Character attributes configuration.
* `maxPoints` (*number*): Maximum attribute points available.
* `currentPoints` (*number*): Currently allocated points.

**Returns**

* `panel` (*Panel*): The created attributes panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create attribute allocation panel
local attribPanel = vgui.Create("liaCharacterAttribs")
attribPanel:setMaxPoints(30)
attribPanel:onDisplay()

-- Get allocated attributes
local allocated = attribPanel:getAllocatedAttributes()
```

---

### liaCharacterAttribsRow

**Purpose**

Individual row component for attribute display and modification within the attributes panel.

**When Called**

This panel is called when:
- Individual attribute rows need to be created
- Attribute modification controls are needed
- Attribute display within a larger panel

**Parameters**

* `attribute` (*table*): Attribute configuration data.
* `currentValue` (*number*): Current attribute value.

**Returns**

* `panel` (*Panel*): The created attribute row panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create individual attribute row
local attribRow = vgui.Create("liaCharacterAttribsRow")
attribRow:setAttribute("strength", {
    name = "Strength",
    desc = "Physical strength attribute",
    max = 10
})
attribRow:setValue(5)
```

---

### liaCharInfo

**Purpose**

Displays character information including name, faction, and basic stats.

**When Called**

This panel is called when:
- Character information needs to be displayed
- Character summary cards are needed
- Character selection interfaces require info display

**Parameters**

* `character` (*table*): Character data to display.
* `showStats` (*boolean*): Whether to show character statistics.

**Returns**

* `panel` (*Panel*): The created character info panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create character info display
local charInfo = vgui.Create("liaCharInfo")
charInfo:setCharacter(characterData)
charInfo:showStats(true)

-- Update character information
charInfo:updateInfo(newCharacterData)
```

---

### liaCharBGMusic

**Purpose**

Manages background music selection for character creation and gameplay.

**When Called**

This panel is called when:
- Background music selection is needed
- Character-specific music preferences are set
- Audio customization during character creation

**Parameters**

* `musicOptions` (*table*): Available music tracks.
* `currentMusic` (*string*): Currently selected music.

**Returns**

* `panel` (*Panel*): The created music selection panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create music selection panel
local musicPanel = vgui.Create("liaCharBGMusic")
musicPanel:setMusicOptions(availableTracks)
musicPanel:setSelectedMusic("ambient1")

-- Get selected music
local selectedMusic = musicPanel:getSelectedMusic()
```

---

### liaClasses

**Purpose**

Displays and manages character classes with selection interface for character creation.

**When Called**

This panel is called when:
- Character class selection is required
- Class-based character creation is needed
- Class information and selection interface is required

**Parameters**

* `availableClasses` (*table*): Array of available character classes.
* `selectedClass` (*number*): Currently selected class index.
* `factionFilter` (*number*): Optional faction filter for class availability.

**Returns**

* `panel` (*Panel*): The created classes panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create class selection interface
local classesPanel = vgui.Create("liaClasses")
classesPanel:setAvailableClasses(lia.class.list)
classesPanel:setFactionFilter(playerFaction)

-- Handle class selection
classesPanel.onClassSelected = function(classIndex, classData)
    print("Selected class: " .. classData.name)
end

-- Refresh available classes
classesPanel:refreshClasses()
```
