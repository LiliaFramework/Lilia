# Derma Library

This page documents the functions for creating and managing Derma UI elements in the Lilia framework.

---

## Overview

The derma library (`lia.derma`) provides a comprehensive collection of pre-built UI components and utilities for creating consistent, theme-aware user interfaces in the Lilia framework. This library offers a wide range of specialized UI elements including buttons, panels, frames, input controls, and selection dialogs that automatically integrate with the framework's theming system. The components are designed to provide a cohesive visual experience across all interface elements while maintaining flexibility for customization. The library includes advanced UI creation tools with automatic theme integration, responsive design capabilities, and built-in animation support that enables developers to create polished, professional-looking interfaces with minimal effort. Additionally, the system features robust input validation, accessibility support, and performance optimization to ensure smooth user interactions across different screen sizes and input methods.

---

### attribBar

**Purpose**

Creates an attribute bar component for displaying character attributes with a progress indicator.

**Parameters**

* `parent` (*Panel*): The parent panel to add the attribute bar to.
* `text` (*string*, optional): The text label to display on the bar.
* `maxValue` (*number*, optional): The maximum value for the progress bar.

**Returns**

* `bar` (*liaAttribBar*): The created attribute bar panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic attribute bar
local healthBar = lia.derma.attribBar(parentPanel, "Health", 100)

-- Create an attribute bar with custom max value
local manaBar = lia.derma.attribBar(parentPanel, "Mana", 200)
manaBar:setValue(150)

-- Use in character creation
local strengthBar = lia.derma.attribBar(charPanel, "Strength", 10)
strengthBar:setValue(8)

-- Dynamic attribute display
local function updateAttributeBar(bar, attributeName, currentValue, maxValue)
    bar:setText(attributeName .. ": " .. currentValue .. "/" .. maxValue)
    bar:setValue(currentValue)
    bar:setMax(maxValue)
end

-- Create multiple attribute bars
local attributes = {"Strength", "Dexterity", "Intelligence", "Wisdom"}
for _, attr in ipairs(attributes) do
    local bar = lia.derma.attribBar(parentPanel, attr, 20)
    updateAttributeBar(bar, attr, math.random(10, 18), 20)
end
```

---

### button

**Purpose**

Creates a customizable button with icon support, hover effects, and theme integration.

**Parameters**

* `parent` (*Panel*): The parent panel to add the button to.
* `icon` (*string*, optional): The material path for the button icon.
* `iconSize` (*number*, optional): The size of the icon (default: 16).
* `color` (*Color*, optional): The base color of the button.
* `radius` (*number*, optional): The corner radius of the button (default: 6).
* `noGradient` (*boolean*, optional): Whether to disable gradient effects.
* `hoverColor` (*Color*, optional): The hover color of the button.
* `noHover` (*boolean*, optional): Whether to disable hover effects.

**Returns**

* `button` (*liaButton*): The created button panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic button
local basicButton = lia.derma.button(parentPanel, "icon16/accept.png", 16, Color(100, 150, 255))

-- Create a button without gradient
local flatButton = lia.derma.button(parentPanel, nil, nil, nil, nil, true)

-- Create a custom colored button
local redButton = lia.derma.button(parentPanel, "icon16/cross.png", 16, Color(200, 100, 100))

-- Create a button with custom hover color
local greenButton = lia.derma.button(parentPanel, "icon16/tick.png", 16, Color(100, 200, 100), 8, false, Color(150, 255, 150))

-- Create a button without hover effects
local noHoverButton = lia.derma.button(parentPanel, nil, nil, nil, nil, nil, nil, true)

-- Use in a menu system
local menuButton = lia.derma.button(mainMenu, "icon16/folder.png", 16)
menuButton:SetText("Open Menu")
menuButton.DoClick = function()
    openSubMenu()
end

-- Create icon-only buttons
local playButton = lia.derma.button(toolbar, "icon16/control_play.png", 16)
local pauseButton = lia.derma.button(toolbar, "icon16/control_pause.png", 16)
local stopButton = lia.derma.button(toolbar, "icon16/control_stop.png", 16)
```

---

### category

**Purpose**

Creates a collapsible category panel for organizing UI elements.

**Parameters**

* `parent` (*Panel*): The parent panel to add the category to.
* `title` (*string*, optional): The title text for the category.
* `expanded` (*boolean*, optional): Whether the category should start expanded.

**Returns**

* `category` (*liaCategory*): The created category panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic category
local settingsCategory = lia.derma.category(parentPanel, "Settings")

-- Create an expanded category
local advancedCategory = lia.derma.category(parentPanel, "Advanced Options", true)

-- Create a collapsed category
local basicCategory = lia.derma.category(parentPanel, "Basic Settings", false)

-- Use categories to organize controls
local function createOptionsPanel()
    local generalCat = lia.derma.category(parentPanel, "General", true)

    local nameEntry = lia.derma.descEntry(generalCat, "Display Name", "Enter your name")
    local themeSelector = lia.derma.slideBox(generalCat, "Theme", 1, 3)

    local privacyCat = lia.derma.category(parentPanel, "Privacy", false)
    local showOnlineCheckbox = lia.derma.checkbox(privacyCat, "Show Online Status")
end

-- Dynamic category management
local categories = {}
local function addCategory(title, content)
    local cat = lia.derma.category(parentPanel, title)
    if content then
        content:SetParent(cat)
    end
    table.insert(categories, cat)
    return cat
end

-- Toggle category expansion
local toggleButton = lia.derma.button(parentPanel)
toggleButton.DoClick = function()
    for _, cat in ipairs(categories) do
        cat:Toggle()
    end
end
```

---

### characterAttribRow

**Purpose**

Creates a row component for displaying character attributes in a structured format.

**Parameters**

* `parent` (*Panel*): The parent panel to add the row to.
* `attributeKey` (*string*, optional): The attribute key/name.
* `attributeData` (*table*, optional): The attribute data containing display information.

**Returns**

* `row` (*liaCharacterAttribsRow*): The created attribute row panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic attribute row
local strengthRow = lia.derma.characterAttribRow(parentPanel, "strength", {
    name = "Strength",
    desc = "Physical power and carrying capacity",
    max = 20,
    value = 15
})

-- Create multiple attribute rows
local attributes = {
    strength = {name = "Strength", desc = "Physical power", max = 20, value = 16},
    dexterity = {name = "Dexterity", desc = "Agility and precision", max = 20, value = 14},
    intelligence = {name = "Intelligence", desc = "Mental capacity", max = 20, value = 18}
}

for key, data in pairs(attributes) do
    local row = lia.derma.characterAttribRow(parentPanel, key, data)
end

-- Use with character attribute system
local function createCharacterSheet(character)
    local attribsPanel = lia.derma.characterAttribs(parentPanel)

    for attributeKey, attributeData in pairs(lia.attributes.list) do
        local currentValue = character:getAttrib(attributeKey, 0)
        local row = lia.derma.characterAttribRow(attribsPanel, attributeKey, attributeData)
        row:setValue(currentValue)
    end
end

-- Dynamic attribute row updates
local function updateAttributeDisplay(row, newValue, maxValue)
    row:setValue(newValue)
    row:setMax(maxValue)
    row:setText(string.format("%s: %d/%d", row.attributeData.name, newValue, maxValue))
end
```

---

### characterAttribs

**Purpose**

Creates a container panel for displaying multiple character attribute rows.

**Parameters**

* `parent` (*Panel*): The parent panel to add the container to.

**Returns**

* `attribsPanel` (*liaCharacterAttribs*): The created attributes container panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a character attributes panel
local attribsPanel = lia.derma.characterAttribs(parentPanel)
attribsPanel:Dock(FILL)

-- Populate with character data
local character = LocalPlayer():getChar()
if character then
    for attributeKey, attributeData in pairs(lia.attributes.list) do
        local currentValue = character:getAttrib(attributeKey, 0)
        local row = lia.derma.characterAttribRow(attribsPanel, attributeKey, attributeData)
        row:setValue(currentValue)
    end
end

-- Create a reusable character sheet
local function createCharacterSheet(parent)
    local sheet = vgui.Create("DPanel", parent)
    sheet:Dock(FILL)

    local title = vgui.Create("DLabel", sheet)
    title:Dock(TOP)
    title:SetText("Character Attributes")
    title:SetFont("liaMediumFont")

    local attribsContainer = lia.derma.characterAttribs(sheet)

    -- Add attribute rows dynamically
    local character = LocalPlayer():getChar()
    if character then
        for key, data in pairs(lia.attributes.list) do
            local value = character:getAttrib(key, 0)
            local row = lia.derma.characterAttribRow(attribsContainer, key, data)
            row:setValue(value)
        end
    end

    return sheet
end

-- Use in character creation
local creationPanel = lia.derma.frame(nil, "Character Creation", 400, 600)
local attribsSection = lia.derma.characterAttribs(creationPanel)
-- Populate with default values for character creation...
```

---

### checkbox

**Purpose**

Creates a themed checkbox with label for boolean input.

**Parameters**

* `parent` (*Panel*): The parent panel to add the checkbox to.
* `text` (*string*): The label text for the checkbox.
* `convar` (*string*, optional): The console variable to bind the checkbox to.

**Returns**

* `panel` (*Panel*): The container panel.
* `checkbox` (*liaCheckBox*): The actual checkbox element.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic checkbox
local panel, checkbox = lia.derma.checkbox(parentPanel, "Enable Feature")
checkbox:SetChecked(true)

-- Create a checkbox bound to a convar
local _, soundCheckbox = lia.derma.checkbox(parentPanel, "Enable Sound", "lia_enable_sound")

-- Multiple related checkboxes
local options = {
    {"Show Health Bar", "lia_show_health"},
    {"Show Mana Bar", "lia_show_mana"},
    {"Show Minimap", "lia_show_minimap"},
    {"Enable Tooltips", "lia_enable_tooltips"}
}

for _, option in ipairs(options) do
    local _, checkbox = lia.derma.checkbox(parentPanel, option[1], option[2])
end

-- Group checkboxes in a category
local settingsCategory = lia.derma.category(parentPanel, "Display Settings", true)

local showFPS = lia.derma.checkbox(settingsCategory, "Show FPS Counter", "lia_show_fps")
local showPing = lia.derma.checkbox(settingsCategory, "Show Ping", "lia_show_ping")
local showCoords = lia.derma.checkbox(settingsCategory, "Show Coordinates", "lia_show_coords")

-- Use checkbox value in logic
local enableMusic = lia.derma.checkbox(parentPanel, "Enable Background Music")
enableMusic[2].OnChange = function(self, value)
    if value then
        startBackgroundMusic()
    else
        stopBackgroundMusic()
    end
end

-- Create checkbox with custom behavior
local _, debugCheckbox = lia.derma.checkbox(parentPanel, "Debug Mode", "lia_debug_mode")
debugCheckbox.OnChange = function(self, value)
    if value then
        print("Debug mode enabled")
        showDebugInfo()
    else
        print("Debug mode disabled")
        hideDebugInfo()
    end
end
```

---

### colorPicker

**Purpose**

Creates a color picker dialog for selecting colors with hue, saturation, and value controls.

**Parameters**

* `callback` (*function*): The function to call when a color is selected.
* `defaultColor` (*Color*, optional): The initial color to display.

**Returns**

* `frame` (*liaFrame*): The color picker frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic color picker
lia.derma.colorPicker(function(color)
    print("Selected color:", color)
    selectedColor = color
end)

-- Color picker with default color
local defaultColor = Color(255, 100, 100)
lia.derma.colorPicker(function(color)
    myPanel:SetBackgroundColor(color)
end, defaultColor)

-- Use in theme customization
lia.derma.colorPicker(function(color)
    local customTheme = table.Copy(lia.color.getTheme())
    customTheme.accent = color
    lia.color.registerTheme("custom", customTheme)
    lia.color.setTheme("custom")
end)

-- Color picker for item customization
local function createItemColorPicker(item, callback)
    lia.derma.colorPicker(function(color)
        item.customColor = color
        callback(color)
    end, item.customColor)
end

-- Multiple color pickers for different elements
local colorButtons = {}
local function createColorPalette()
    local colors = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"}

    for _, colorName in ipairs(colors) do
        local button = lia.derma.button(parentPanel, nil, nil, Color(100, 100, 100))
        button:SetText(colorName)
        button.DoClick = function()
            lia.derma.colorPicker(function(color)
                button:SetColor(color)
                print("Changed " .. colorName .. " to:", color)
            end)
        end
        table.insert(colorButtons, button)
    end
end
```

---

### dermaMenu

**Purpose**

Creates a context menu at the current mouse position with automatic positioning.

**Parameters**

*None*

**Returns**

* `menu` (*liaDermaMenu*): The created context menu.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic context menu
local menu = lia.derma.dermaMenu()
menu:AddOption("Option 1", function() print("Selected option 1") end)
menu:AddOption("Option 2", function() print("Selected option 2") end)
menu:AddOption("Option 3", function() print("Selected option 3") end)

-- Context menu with submenus
local menu = lia.derma.dermaMenu()
local submenu = menu:AddSubMenu("More Options")

submenu:AddOption("Sub Option 1", function() print("Sub option 1") end)
submenu:AddOption("Sub Option 2", function() print("Sub option 2") end)

menu:AddOption("Regular Option", function() print("Regular option") end)

-- Context menu for player interactions
local menu = lia.derma.dermaMenu()
local targetPlayer = LocalPlayer()

menu:AddOption("Send Message", function()
    lia.derma.textBox("Send Message", "Enter your message", function(text)
        targetPlayer:ChatPrint(text)
    end)
end)

menu:AddOption("Trade Items", function()
    openTradeWindow(targetPlayer)
end)

menu:AddOption("View Profile", function()
    showPlayerProfile(targetPlayer)
end)

-- Dynamic context menu based on object
local function createContextMenuForObject(object)
    local menu = lia.derma.dermaMenu()

    if object.isContainer then
        menu:AddOption("Open", function() object:Open() end)
        menu:AddOption("Lock", function() object:Lock() end)
    end

    if object.isNPC then
        menu:AddOption("Talk", function() object:Talk() end)
        menu:AddOption("Trade", function() object:Trade() end)
    end

    return menu
end

-- Context menu with icons
local menu = lia.derma.dermaMenu()
menu:AddOption("Copy", function() clipboard.Copy() end):SetIcon("icon16/page_copy.png")
menu:AddOption("Paste", function() clipboard.Paste() end):SetIcon("icon16/paste.png")
menu:AddOption("Cut", function() clipboard.Cut() end):SetIcon("icon16/cut.png")
```

---

### descEntry

**Purpose**

Creates a labeled text entry field with placeholder text and optional title.

**Parameters**

* `parent` (*Panel*): The parent panel to add the entry to.
* `title` (*string*, optional): The title label for the entry field.
* `placeholder` (*string*): The placeholder text to display when empty.
* `offTitle` (*boolean*, optional): Whether to disable the title label.

**Returns**

* `entry` (*liaEntry*): The text entry field.
* `entry_bg` (*liaBasePanel*): The background panel (only if title is provided).

**Realm**

Client.

**Example Usage**

```lua
-- Basic text entry with title
local entry = lia.derma.descEntry(parentPanel, "Username", "Enter your username")

-- Text entry without title
local passwordEntry = lia.derma.descEntry(parentPanel, nil, "Enter password", true)

-- Multiple form fields
local formFields = {}
local fields = {
    {"Name", "Enter your full name"},
    {"Email", "Enter your email address"},
    {"Age", "Enter your age"},
    {"Bio", "Tell us about yourself"}
}

for _, field in ipairs(fields) do
    local entry = lia.derma.descEntry(parentPanel, field[1], field[2])
    table.insert(formFields, entry)
end

-- Validate form input
local function validateForm()
    local isValid = true
    for i, entry in ipairs(formFields) do
        local value = entry:GetValue()
        if value == "" then
            entry:SetError("This field is required")
            isValid = false
        else
            entry:ClearError()
        end
    end
    return isValid
end

-- Use in settings panel
local settingsCategory = lia.derma.category(parentPanel, "Account Settings", true)

local usernameEntry = lia.derma.descEntry(settingsCategory, "Username", "Current username")
local emailEntry = lia.derma.descEntry(settingsCategory, "Email", "your@email.com")
local passwordEntry = lia.derma.descEntry(settingsCategory, "New Password", "Enter new password")

-- Auto-save functionality
local function setupAutoSave(entry, convar)
    entry.OnChange = function()
        LocalPlayer():ConCommand(convar .. " " .. entry:GetValue())
    end
end

setupAutoSave(usernameEntry, "lia_username")
setupAutoSave(emailEntry, "lia_email")
```

---

### frame

**Purpose**

Creates a themed frame window with optional close button and animation support.

**Parameters**

* `parent` (*Panel*): The parent panel to add the frame to.
* `title` (*string*, optional): The title text for the frame.
* `width` (*number*, optional): The width of the frame (default: 300).
* `height` (*number*, optional): The height of the frame (default: 200).
* `closeButton` (*boolean*, optional): Whether to show the close button.
* `animate` (*boolean*, optional): Whether to show entrance animation.

**Returns**

* `frame` (*liaFrame*): The created frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic frame
local frame = lia.derma.frame(nil, "My Window", 400, 300)

-- Frame with close button
local frameWithClose = lia.derma.frame(parentPanel, "Settings", 500, 400, true)

-- Frame without close button (modal)
local modalFrame = lia.derma.frame(nil, "Important Notice", 300, 150, false)

-- Animated frame
local animatedFrame = lia.derma.frame(nil, "Loading...", 200, 100, true, true)

-- Custom frame content
local infoFrame = lia.derma.frame(nil, "Player Information", 350, 250, true)
local content = vgui.Create("DPanel", infoFrame)
content:Dock(FILL)
content:DockMargin(10, 10, 10, 10)

local nameLabel = vgui.Create("DLabel", content)
nameLabel:Dock(TOP)
nameLabel:SetText("Player: " .. LocalPlayer():Name())

local steamLabel = vgui.Create("DLabel", content)
steamLabel:Dock(TOP)
steamLabel:DockMargin(0, 5, 0, 0)
steamLabel:SetText("Steam ID: " .. LocalPlayer():SteamID())

-- Frame with custom close behavior
local confirmFrame = lia.derma.frame(nil, "Confirm Action", 300, 120, true)
confirmFrame.OnClose = function()
    print("User cancelled the action")
end

-- Multiple frames management
local frames = {}
local function createTabFrame(title, content)
    local frame = lia.derma.frame(nil, title, 400, 300, true, true)
    local panel = vgui.Create("DPanel", frame)
    panel:Dock(FILL)
    if content then content(panel) end
    table.insert(frames, frame)
    return frame
end
```

---

### panelTabs

**Purpose**

Creates a tabbed panel interface for organizing content into multiple sections.

**Parameters**

* `parent` (*Panel*): The parent panel to add the tabs to.

**Returns**

* `tabs` (*liaTabs*): The created tabbed panel.

**Realm**

Client.

**Example Usage**

```lua
-- Basic tabbed panel
local tabs = lia.derma.panelTabs(parentPanel)

local tab1 = tabs:AddTab("General", createGeneralPanel())
local tab2 = tabs:AddTab("Advanced", createAdvancedPanel())
local tab3 = tabs:AddTab("About", createAboutPanel())

-- Programmatically switch tabs
tabs:ActiveTab("Advanced")

-- Tabs with icons
local tabs = lia.derma.panelTabs(parentPanel)
tabs:AddTab("Home", homePanel, "icon16/house.png")
tabs:AddTab("Settings", settingsPanel, "icon16/cog.png")
tabs:AddTab("Help", helpPanel, "icon16/help.png")

-- Dynamic tab creation
local function createTabbedInterface(data)
    local tabs = lia.derma.panelTabs(parentPanel)

    for title, contentFunc in pairs(data) do
        local panel = contentFunc()
        tabs:AddTab(title, panel)
    end

    return tabs
end

-- Settings tabs
local settingsTabs = lia.derma.panelTabs(settingsPanel)
settingsTabs:AddTab("Graphics", createGraphicsSettings())
settingsTabs:AddTab("Audio", createAudioSettings())
settingsTabs:AddTab("Controls", createControlSettings())
settingsTabs:AddTab("Network", createNetworkSettings())

-- Tab change callback
local tabs = lia.derma.panelTabs(parentPanel)
tabs.OnTabChanged = function(oldTab, newTab)
    print("Switched from", oldTab, "to", newTab)
end
```

---

### playerSelector

**Purpose**

Creates a player selection dialog with search and filtering capabilities.

**Parameters**

* `callback` (*function*): The function to call when a player is selected.
* `validationFunc` (*function*, optional): A function to validate player selection.

**Returns**

* `frame` (*liaFrame*): The player selector frame.

**Realm**

Client.

**Example Usage**

```lua
-- Basic player selector
lia.derma.playerSelector(function(player)
    print("Selected player:", player:Name())
end)

-- Player selector with validation
lia.derma.playerSelector(function(player)
    if IsValid(player) and player:Alive() then
        tradeWithPlayer(player)
    end
end, function(player)
    return player ~= LocalPlayer() and player:Alive()
end)

-- Use in admin functions
lia.derma.playerSelector(function(player)
    local menu = lia.derma.dermaMenu()
    menu:AddOption("Kick", function() kickPlayer(player) end)
    menu:AddOption("Ban", function() banPlayer(player) end)
    menu:AddOption("Teleport", function() teleportToPlayer(player) end)
end)

-- Player selector for team assignment
lia.derma.playerSelector(function(player)
    local teams = team.GetAllTeams()
    local menu = lia.derma.dermaMenu()

    for _, teamInfo in pairs(teams) do
        menu:AddOption("Move to " .. teamInfo.Name, function()
            player:SetTeam(teamInfo.ID)
        end)
    end
end, function(player)
    return player ~= LocalPlayer()
end)

-- Multiple player selection
local selectedPlayers = {}
lia.derma.playerSelector(function(player)
    if table.HasValue(selectedPlayers, player) then
        table.RemoveByValue(selectedPlayers, player)
        print("Deselected:", player:Name())
    else
        table.insert(selectedPlayers, player)
        print("Selected:", player:Name())
    end
    print("Selected players:", #selectedPlayers)
end)
```

---

### radialMenu

**Purpose**

Creates a radial/circular menu for quick action selection.

**Parameters**

* `options` (*table*): A table of options with name, icon, and callback properties.

**Returns**

* `menu` (*liaRadialPanel*): The created radial menu.

**Realm**

Client.

**Example Usage**

```lua
-- Basic radial menu
local options = {
    {name = "Attack", icon = "icon16/gun.png", callback = function() attack() end},
    {name = "Defend", icon = "icon16/shield.png", callback = function() defend() end},
    {name = "Heal", icon = "icon16/heart.png", callback = function() heal() end},
    {name = "Retreat", icon = "icon16/arrow_left.png", callback = function() retreat() end}
}

local menu = lia.derma.radialMenu(options)

-- Radial menu with more options
local spellOptions = {
    {name = "Fireball", icon = "icon16/fire.png", callback = function() castFireball() end},
    {name = "Ice Bolt", icon = "icon16/weather_snow.png", callback = function() castIceBolt() end},
    {name = "Lightning", icon = "icon16/lightning.png", callback = function() castLightning() end},
    {name = "Heal", icon = "icon16/heart.png", callback = function() castHeal() end},
    {name = "Shield", icon = "icon16/shield.png", callback = function() castShield() end},
    {name = "Teleport", icon = "icon16/arrow_right.png", callback = function() castTeleport() end}
}

local spellMenu = lia.derma.radialMenu(spellOptions)

-- Dynamic radial menu creation
local function createRadialMenuForItems(items)
    local options = {}

    for _, item in ipairs(items) do
        table.insert(options, {
            name = item.name,
            icon = item.icon,
            callback = function() useItem(item) end
        })
    end

    return lia.derma.radialMenu(options)
end

-- Radial menu for emotes
local emoteOptions = {
    {name = "Wave", icon = "icon16/user.png", callback = function() doEmote("wave") end},
    {name = "Dance", icon = "icon16/user_go.png", callback = function() doEmote("dance") end},
    {name = "Cry", icon = "icon16/user_delete.png", callback = function() doEmote("cry") end},
    {name = "Laugh", icon = "icon16/user_comment.png", callback = function() doEmote("laugh") end}
}

local emoteMenu = lia.derma.radialMenu(emoteOptions)
```

---

### scrollPanel

**Purpose**

Creates a scrollable panel with themed scrollbars.

**Parameters**

* `scrollPanel` (*Panel*): The scroll panel to apply theming to.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Theme an existing scroll panel
local scrollPanel = vgui.Create("DScrollPanel", parent)
lia.derma.scrollPanel(scrollPanel)

-- Create a new themed scroll panel
local scrollPanel = lia.derma.scrollpanel(parentPanel)

-- Use in content creation
local function createScrollableContent()
    local scroll = lia.derma.scrollpanel(parentPanel)
    scroll:Dock(FILL)

    -- Add many items to demonstrate scrolling
    for i = 1, 50 do
        local item = vgui.Create("DButton", scroll)
        item:Dock(TOP)
        item:SetTall(30)
        item:SetText("Item " .. i)
    end

    return scroll
end

-- Scroll panel with custom content
local contentScroll = lia.derma.scrollpanel(parentPanel)
contentScroll:Dock(FILL)

for i = 1, 20 do
    local panel = vgui.Create("DPanel", contentScroll)
    panel:Dock(TOP)
    panel:DockMargin(5, 5, 5, 0)
    panel:SetTall(60)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 150))
    end

    local label = vgui.Create("DLabel", panel)
    label:Dock(FILL)
    label:DockMargin(10, 0, 10, 0)
    label:SetText("Scrollable content item " .. i)
end

-- Nested scroll panels
local outerScroll = lia.derma.scrollpanel(parentPanel)
outerScroll:Dock(FILL)

local innerScroll = lia.derma.scrollpanel(outerScroll)
innerScroll:Dock(TOP)
innerScroll:SetTall(200)
```

---

### scrollpanel

**Purpose**

Creates a new themed scroll panel with automatic scrollbar theming.

**Parameters**

* `parent` (*Panel*): The parent panel to add the scroll panel to.

**Returns**

* `scrollpanel` (*liaScrollPanel*): The created themed scroll panel.

**Realm**

Client.

**Example Usage**

```lua
-- Create a themed scroll panel
local scrollPanel = lia.derma.scrollpanel(parentPanel)
scrollPanel:Dock(FILL)

-- Add content to the scroll panel
for i = 1, 100 do
    local button = vgui.Create("DButton", scrollPanel)
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 5)
    button:SetTall(40)
    button:SetText("Button " .. i)
end

-- Scroll panel in a frame
local frame = lia.derma.frame(nil, "Scrollable Content", 300, 400)
local scroll = lia.derma.scrollpanel(frame)

for i = 1, 30 do
    local item = vgui.Create("DPanel", scroll)
    item:Dock(TOP)
    item:DockMargin(5, 5, 5, 0)
    item:SetTall(50)
    item.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, lia.color.theme.panel_alpha[1])
    end
end

-- Dynamic content loading
local function loadMoreContent(scrollPanel, startIndex, count)
    for i = startIndex, startIndex + count - 1 do
        local item = vgui.Create("DLabel", scrollPanel)
        item:Dock(TOP)
        item:DockMargin(5, 5, 5, 0)
        item:SetTall(30)
        item:SetText("Item " .. i)
    end
end

local scrollPanel = lia.derma.scrollpanel(parentPanel)
loadMoreContent(scrollPanel, 1, 50)
```

---

### slideBox

**Purpose**

Creates a slider control with label and value display for numeric input.

**Parameters**

* `parent` (*Panel*): The parent panel to add the slider to.
* `label` (*string*): The label text for the slider.
* `minValue` (*number*): The minimum value of the slider.
* `maxValue` (*number*): The maximum value of the slider.
* `convar` (*string*, optional): The console variable to bind the slider to.
* `decimals` (*number*, optional): The number of decimal places to display.

**Returns**

* `slider` (*DButton*): The created slider control.

**Realm**

Client.

**Example Usage**

```lua
-- Basic slider
local volumeSlider = lia.derma.slideBox(parentPanel, "Volume", 0, 100, "lia_volume")

-- Slider with decimals
local opacitySlider = lia.derma.slideBox(parentPanel, "Opacity", 0, 1, "lia_opacity", 2)

-- Multiple sliders for settings
local sliders = {
    {label = "Master Volume", min = 0, max = 100, convar = "lia_master_volume"},
    {label = "Music Volume", min = 0, max = 100, convar = "lia_music_volume"},
    {label = "SFX Volume", min = 0, max = 100, convar = "lia_sfx_volume"},
    {label = "Mouse Sensitivity", min = 0.1, max = 5.0, convar = "lia_mouse_sensitivity", decimals = 1}
}

for _, sliderInfo in ipairs(sliders) do
    lia.derma.slideBox(parentPanel, sliderInfo.label, sliderInfo.min,
                       sliderInfo.max, sliderInfo.convar, sliderInfo.decimals)
end

-- Custom slider behavior
local customSlider = lia.derma.slideBox(parentPanel, "Custom Value", 0, 100)
customSlider.OnValueChanged = function(value)
    print("Slider value changed to:", value)
    updateBasedOnSlider(value)
end

-- Slider with live preview
local brightnessSlider = lia.derma.slideBox(parentPanel, "Brightness", 0, 2, nil, 1)
brightnessSlider.OnValueChanged = function(value)
    render.SetLightingMode(value)
end

-- Group sliders in categories
local graphicsCategory = lia.derma.category(parentPanel, "Graphics", true)
local resolutionSlider = lia.derma.slideBox(graphicsCategory, "Resolution Scale", 0.5, 2.0, "lia_resolution", 1)
local fpsSlider = lia.derma.slideBox(graphicsCategory, "Max FPS", 30, 300, "lia_max_fps")
```

---

### textBox

**Purpose**

Creates a text input dialog for getting user input with a title and description.

**Parameters**

* `title` (*string*): The title of the dialog.
* `description` (*string*): The placeholder/description text.
* `callback` (*function*): The function to call with the entered text.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Basic text input
lia.derma.textBox("Enter Name", "Type your name here", function(text)
    print("User entered:", text)
    playerName = text
end)

-- Text input for commands
lia.derma.textBox("Execute Command", "Enter console command", function(command)
    LocalPlayer():ConCommand(command)
end)

-- Text input with validation
lia.derma.textBox("Set Password", "Enter new password", function(password)
    if string.len(password) >= 8 then
        setPlayerPassword(password)
        print("Password updated successfully")
    else
        print("Password must be at least 8 characters")
        -- Show the dialog again
        timer.Simple(0.1, function()
            lia.derma.textBox("Set Password", "Enter new password (min 8 chars)", function(newPassword)
                if string.len(newPassword) >= 8 then
                    setPlayerPassword(newPassword)
                else
                    print("Password too short")
                end
            end)
        end)
    end
end)

-- Text input for item naming
lia.derma.textBox("Name Your Item", "Enter a name for this item", function(name)
    if name and name ~= "" then
        currentItem.name = name
        print("Item renamed to:", name)
    else
        print("Invalid name")
    end
end)

-- Multiple text inputs in sequence
local function promptForDetails()
    lia.derma.textBox("Enter Title", "What is the title?", function(title)
        lia.derma.textBox("Enter Description", "Describe it briefly", function(description)
            lia.derma.textBox("Enter Tags", "Comma-separated tags", function(tags)
                saveContent(title, description, tags)
            end)
        end)
    end)
end
```
