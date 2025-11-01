--[[
    Option Library

    User-configurable settings management system for the Lilia framework.
]]
--[[
    Overview:
        The option library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.
]]
lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
--[[
    Purpose:
        Registers a new configurable option in the Lilia framework with automatic type detection and UI generation

    When Called:
        During module initialization or when adding new user-configurable settings

    Parameters:
        - key (string): Unique identifier for the option
        - name (string): Display name for the option (can be localized)
        - desc (string): Description text for the option (can be localized)
        - default (any): Default value for the option
        - callback (function, optional): Function called when option value changes (oldValue, newValue)
        - data (table): Configuration data containing type, category, min/max values, etc.

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a boolean toggle option
        lia.option.add("showHUD", "Show HUD", "Toggle HUD visibility", true, nil, {
            category = "categoryGeneral",
            isQuick  = true
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Add a numeric slider with callback
        lia.option.add("volume", "Volume", "Master volume level", 0.8, function(oldVal, newVal)
            RunConsoleCommand("volume", tostring(newVal))
        end, {
            category = "categoryAudio",
            min      = 0,
            max      = 1,
            decimals = 2
        })
        ```

    High Complexity:
        ```lua
        -- High: Add a color picker with visibility condition and networking
        lia.option.add("espColor", "ESP Color", "Color for ESP display", Color(255, 0, 0), nil, {
            category      = "categoryESP",
            visible       = function()
                return LocalPlayer():isStaffOnDuty()
            end,
            shouldNetwork = true,
            type          = "Color"
        })
        ```
]]
function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), L("optionKeyString", type(key)))
    assert(isstring(name), L("optionNameString", type(name)))
    assert(istable(data), L("optionDataTable", type(data)))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or t == "table" and default.r and default.g and default.b and "Color" or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or optionType == "Int" and math.floor(default / 2) or default / 2
        data.max = data.max or optionType == "Int" and math.floor(default * 2) or default * 2
    end

    if data.type then optionType = data.type end
    local old = lia.option.stored[key]
    local value = old and old.value or default
    if istable(data.options) then
        for k, v in pairs(data.options) do
            if isstring(v) then data.options[k] = L(v) end
        end
    elseif isfunction(data.options) then
        data.optionsFunc = data.options
        data.options = nil
    end

    data.category = isstring(data.category) and L(data.category) or data.category
    lia.option.stored[key] = {
        name = isstring(name) and L(name) or name,
        desc = isstring(desc) and L(desc) or desc,
        data = data,
        value = value,
        default = default,
        callback = callback,
        type = optionType,
        visible = data.visible,
        shouldNetwork = data.shouldNetwork,
        isQuick = data.isQuick
    }

    hook.Run("OptionAdded", key, lia.option.stored[key])
end

--[[
    Purpose:
        Retrieves the available options for a dropdown/selection type option, handling both static and dynamic option lists

    When Called:
        When rendering dropdown options in the UI or when modules need to access option choices

    Parameters:
        - key (string): The option key to get choices for

    Returns:
        table - Array of available option choices (localized strings)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get static options for a dropdown
        local options = lia.option.getOptions("weaponSelectorPosition")

        -- Returns: {"Left", "Right", "Center"}
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use options in UI creation
        local combo = vgui.Create("liaComboBox")
        local options = lia.option.getOptions("language")
        for _, option in pairs(options) do
            combo:AddChoice(option, option)
        end
        ```

        High Complexity:
        ```lua
        -- High: Dynamic options with validation
        local options = lia.option.getOptions("teamSelection")
        if #options > 0 then
            for i, option in ipairs(options) do
                if option and option ~= "" then
                    teamCombo:AddChoice(option, option)
                end
            end
            else
                teamCombo:AddChoice("No teams available", "")
            end
        ```
]]
function lia.option.getOptions(key)
    local option = lia.option.stored[key]
    if not option then return {} end
    if option.data.optionsFunc then
        local success, result = pcall(option.data.optionsFunc)
        if success and istable(result) then
            for k, v in pairs(result) do
                if isstring(v) then result[k] = L(v) end
            end
            return result
        else
            return {}
        end
    elseif istable(option.data.options) then
        return option.data.options
    end
    return {}
end

--[[
    Purpose:
        Sets the value of an option, triggers callbacks, saves to file, and optionally networks to clients

    When Called:
        When user changes an option value through UI or when programmatically updating option values

    Parameters:
        - key (string): The option key to set
        - value (any): The new value to set for the option

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set a boolean option
        lia.option.set("showHUD", true)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set option with callback execution
        lia.option.set("volume", 0.5)
        -- This will trigger the callback function if one was defined
        ```

    High Complexity:
        ```lua
        -- High: Set multiple options with validation
        local optionsToSet = {
            {"showHUD", true},
            {"volume",  0.8},
            {"espColor", Color(255, 0, 0)}
        }

        for _, optionData in ipairs(optionsToSet) do
            local key, value = optionData[1], optionData[2]
            if lia.option.stored[key] then
                lia.option.set(key, value)
            end
        end
        ```
]]
function lia.option.set(key, value)
    local opt = lia.option.stored[key]
    if not opt then return end
    local old = opt.value
    opt.value = value
    if opt.callback then opt.callback(old, value) end
    hook.Run("OptionChanged", key, old, value)
    lia.option.save()
    if opt.shouldNetwork and SERVER then hook.Run("OptionReceived", nil, key, value) end
end

--[[
    Purpose:
        Retrieves the current value of an option, falling back to default value or provided fallback if not set

    When Called:
        When modules need to read option values for configuration or when UI needs to display current values

    Parameters:
        - key (string): The option key to retrieve
        - default (any, optional): Fallback value if option doesn't exist or has no value

    Returns:
        any - The current option value, default value, or provided fallback

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a boolean option
        local showHUD = lia.option.get("showHUD")
        if showHUD then
            -- HUD is enabled
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get option with fallback
        local volume = lia.option.get("volume", 0.5)
        RunConsoleCommand("volume", tostring(volume))
        ```

    High Complexity:
        ```lua
        -- High: Get multiple options with validation and type checking
        local config = {
            showHUD  = lia.option.get("showHUD", true),
            volume   = lia.option.get("volume", 0.8),
            espColor = lia.option.get("espColor", Color(255, 0, 0))
        }

        -- Validate and apply configuration
        if type(config.showHUD) == "boolean" then
            hook.Run("HUDVisibilityChanged", config.showHUD)
        end

        if type(config.volume) == "number" and config.volume >= 0 and config.volume <= 1 then
            RunConsoleCommand("volume", tostring(config.volume))
        end
        ```
]]
function lia.option.get(key, default)
    local opt = lia.option.stored[key]
    if opt then
        if opt.value ~= nil then return opt.value end
        if opt.default ~= nil then return opt.default end
    end
    return default
end

--[[
    Purpose:
        Saves all current option values to a JSON file for persistence across sessions

    When Called:
        Automatically called when options are changed, or manually when saving configuration

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Save options after changes
        lia.option.set("showHUD", true)
        lia.option.save() -- Automatically called, but can be called manually
        ```

    Medium Complexity:
        ```lua
        -- Medium: Save options with error handling
        local function saveOptionsSafely()
            local success, err = pcall(lia.option.save)
            if not success then
                print("Failed to save options: " .. tostring(err))
            end
        end
        saveOptionsSafely()
        ```

    High Complexity:
        ```lua
        -- High: Batch save with validation and backup
        local function batchSaveOptions()
            -- Create backup of current options
            local backupPath = "lilia/options_backup_" .. os.time() .. ".json"
            local currentData = file.Read("lilia/options.json", "DATA")
            if currentData then
                file.Write(backupPath, currentData)
            end

            -- Save current options
            lia.option.save()

            -- Verify save was successful
            local savedData = file.Read("lilia/options.json", "DATA")
            if savedData then
                print("Options saved successfully")
            else
                print("Failed to save options")
            end
        end
        batchSaveOptions()
        ```
]]
function lia.option.save()
    local path = "lilia/options.json"
    local out = {}
    for k, v in pairs(lia.option.stored) do
        if v.value ~= nil then out[k] = v.value end
    end

    local json = util.TableToJSON(out, true)
    if json then file.Write(path, json) end
end

--[[
    Purpose:
        Loads saved option values from JSON file and initializes options with defaults if no saved data exists

    When Called:
        During client initialization or when manually reloading option configuration

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load options at startup
        lia.option.load()
        -- This is typically called automatically during initialization
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load options with error handling
        local function loadOptionsSafely()
            local success, err = pcall(lia.option.load)
            if not success then
                print("Failed to load options: " .. tostring(err))
                -- Reset to defaults
                for key, option in pairs(lia.option.stored) do
                    option.value = option.default
                end
            end
        end
        loadOptionsSafely()
        ```

    High Complexity:
        ```lua
        -- High: Load options with validation and migration
        local function loadOptionsWithMigration()
            -- Check if options file exists
            if file.Exists("lilia/options.json", "DATA") then
                local data = file.Read("lilia/options.json", "DATA")
                if data then
                    local saved = util.JSONToTable(data)
                    if saved then
                        -- Validate and migrate old option formats
                        for key, value in pairs(saved) do
                            if lia.option.stored[key] then
                                local option = lia.option.stored[key]
                                -- Type validation
                                if option.type == "Boolean" and type(value) ~= "boolean" then
                                    value = tobool(value)
                                elseif option.type == "Int" and type(value) ~= "number" then
                                    value = tonumber(value) or option.default
                                end
                                option.value = value
                            end
                        end
                    end
                else
                    -- No saved options, use defaults
                    lia.option.load()
                end

                -- Trigger initialization hook
                hook.Run("InitializedOptions")
            end
            loadOptionsWithMigration()
        ```
]]
function lia.option.load()
    local path = "lilia/options.json"
    local data = file.Read(path, "DATA")
    if data then
        local saved = util.JSONToTable(data)
        if saved then
            for k, v in pairs(saved) do
                if lia.option.stored[k] then lia.option.stored[k].value = v end
            end
        end
    else
        for _, option in pairs(lia.option.stored) do
            if option.default ~= nil then option.value = option.default end
        end

        local out = {}
        for k, v in pairs(lia.option.stored) do
            if v.value ~= nil then out[k] = v.value end
        end

        local json = util.TableToJSON(out, true)
        if json then file.Write(path, json) end
    end

    hook.Run("InitializedOptions")
end

hook.Add("PopulateConfigurationButtons", "liaOptionsPopulate", function(pages)
    local OptionFormatting = {
        Int = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local slider = panel:Add("liaSlideBox")
            slider:Dock(TOP)
            slider:DockMargin(20, 10, 50, 0)
            slider:SetTall(60)
            slider:SetRange(lia.config.get(key .. "_min", cfg.data and cfg.data.min or 0), lia.config.get(key .. "_max", cfg.data and cfg.data.max or 1), 0)
            slider:SetValue(lia.option.get(key, cfg.value))
            slider:SetText("")
            slider.Paint = function(s, w)
                local padX = 16
                local padTop = 2
                local barY = 32
                local barH = 6
                local barR = barH / 2
                local handleW, handleH = 14, 14
                local handleR = handleH / 2
                local textFont = "LiliaFont.18"
                local valueFont = "LiliaFont.16"
                if s.text and s.text ~= "" then draw.SimpleText(s.text, textFont, padX, padTop, lia.color.theme.text) end
                local barStart = padX + handleW / 2
                local barEnd = w - padX - handleW / 2
                local barW = barEnd - barStart
                local progress = (s.value - s.min_value) / (s.max_value - s.min_value)
                local activeW = math.Clamp(barW * progress, 0, barW)
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.window_shadow):Shadow(5, 20):Draw()
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.focus_panel):Draw()
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.button_shadow):Draw()
                lia.derma.rect(barStart, barY, s.smoothPos, barH):Rad(barR):Color(lia.color.theme.theme):Draw()
                s.smoothPos = Lerp(FrameTime() * 12, s.smoothPos or 0, activeW)
                local handleX = barStart + s.smoothPos
                local handleY = barY + barH / 2
                lia.derma.drawShadows(handleR, handleX - handleW / 2, handleY - handleH / 2, handleW, handleH, lia.color.theme.window_shadow, 3, 10)
                local targetAlpha = s.dragging and 100 or 255
                s._dragAlpha = Lerp(FrameTime() * 10, s._dragAlpha, targetAlpha)
                local colorText = Color(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, s._dragAlpha)
                lia.derma.rect(handleX - handleW / 2, handleY - handleH / 2, handleW, handleH):Rad(handleR):Color(colorText):Draw()
                draw.SimpleText(s.value, valueFont, w / 2, barY - 20, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            slider.OnValueChanged = function(_, v) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.floor(v)) end) end
            return container
        end,
        Float = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local slider = panel:Add("liaSlideBox")
            slider:Dock(TOP)
            slider:DockMargin(20, 10, 50, 0)
            slider:SetTall(60)
            slider:SetRange(lia.config.get(key .. "_min", cfg.data and cfg.data.min or 0), lia.config.get(key .. "_max", cfg.data and cfg.data.max or 1), cfg.data and cfg.data.decimals or 2)
            slider:SetValue(lia.option.get(key, cfg.value))
            slider:SetText("")
            slider.Paint = function(s, w)
                local padX = 16
                local padTop = 2
                local barY = 32
                local barH = 6
                local barR = barH / 2
                local handleW, handleH = 14, 14
                local handleR = handleH / 2
                local textFont = "LiliaFont.18"
                local valueFont = "LiliaFont.16"
                if s.text and s.text ~= "" then draw.SimpleText(s.text, textFont, padX, padTop, lia.color.theme.text) end
                local barStart = padX + handleW / 2
                local barEnd = w - padX - handleW / 2
                local barW = barEnd - barStart
                local progress = (s.value - s.min_value) / (s.max_value - s.min_value)
                local activeW = math.Clamp(barW * progress, 0, barW)
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.window_shadow):Shadow(5, 20):Draw()
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.focus_panel):Draw()
                lia.derma.rect(barStart, barY, barW, barH):Rad(barR):Color(lia.color.theme.button_shadow):Draw()
                lia.derma.rect(barStart, barY, s.smoothPos, barH):Rad(barR):Color(lia.color.theme.theme):Draw()
                s.smoothPos = Lerp(FrameTime() * 12, s.smoothPos or 0, activeW)
                local handleX = barStart + s.smoothPos
                local handleY = barY + barH / 2
                lia.derma.drawShadows(handleR, handleX - handleW / 2, handleY - handleH / 2, handleW, handleH, lia.color.theme.window_shadow, 3, 10)
                local targetAlpha = s.dragging and 100 or 255
                s._dragAlpha = Lerp(FrameTime() * 10, s._dragAlpha, targetAlpha)
                local colorText = Color(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, s._dragAlpha)
                lia.derma.rect(handleX - handleW / 2, handleY - handleH / 2, handleW, handleH):Rad(handleR):Color(colorText):Draw()
                draw.SimpleText(s.value, valueFont, w / 2, barY - 20, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            slider.OnValueChanged = function(_, v) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.Round(v, 2)) end) end
            return container
        end,
        Generic = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local entry = vgui.Create("liaEntry", panel)
            if IsValid(entry) then
                entry:Dock(TOP)
                entry:SetTall(60)
                entry:DockMargin(300, 10, 300, 0)
                entry:SetValue(tostring(lia.option.get(key, cfg.value)))
                entry:SetFont("LiliaFont.36")
                entry.textEntry.OnEnter = function()
                    local value = entry:GetValue()
                    if value ~= "" then lia.option.set(key, value) end
                end
            end
            return container
        end,
        Boolean = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local checkbox = vgui.Create("liaCheckbox", panel)
            if IsValid(checkbox) then
                checkbox:Dock(TOP)
                checkbox:SetTall(160)
                checkbox:DockMargin(10, 25, 10, 15)
                checkbox:SetChecked(lia.option.get(key, cfg.value))
                checkbox.OnChange = function(_, state) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, state) end) end
            end
            return container
        end,
        Color = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local button = vgui.Create("liaButton", panel)
            if IsValid(button) then
                button:Dock(TOP)
                button:DockMargin(300, 10, 300, 0)
                button:SetTall(60)
                button:SetTxt("")
                button.Paint = function(_, w, h)
                    local c = lia.option.get(key, cfg.value)
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
                    lia.derma.rect(0, 0, w, h):Rad(16):Color(c):Shape(lia.derma.SHAPE_IOS):Draw()
                    draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 50))
                end

                button.DoClick = function() lia.derma.colorPicker(function(color) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, color) end) end, lia.option.get(key, cfg.value)) end
            end
            return container
        end,
        Table = function(key, name, cfg, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel:DockMargin(300, 5, 300, 5)
            panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local label = vgui.Create("DLabel", panel)
            label:Dock(TOP)
            label:SetTall(45)
            label:DockMargin(0, 20, 0, 0)
            label:SetText("")
            label.Paint = function(_, w, h) draw.SimpleText(name, "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local description = vgui.Create("DLabel", panel)
            description:Dock(TOP)
            description:SetTall(35)
            description:DockMargin(0, 10, 0, 0)
            description:SetText("")
            description.Paint = function(_, w, h) draw.SimpleText(cfg.desc or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            local combo = vgui.Create("liaComboBox", panel)
            if IsValid(combo) then
                combo:Dock(TOP)
                combo:SetTall(60)
                combo:DockMargin(300, 20, 300, 0)
                combo:SetValue(tostring(lia.option.get(key, cfg.value)))
                combo:SetFont("LiliaFont.18")
                local options = lia.option.getOptions(key)
                for _, text in pairs(options) do
                    combo:AddChoice(text, text)
                end

                combo:FinishAddingOptions()
                combo:PostInit()
                combo.OnSelect = function(_, _, v) lia.option.set(key, v) end
            end
            return container
        end
    }

    local function buildOptions(parent, filter)
        local categories = {}
        local keys = {}
        for k in pairs(lia.option.stored) do
            keys[#keys + 1] = k
        end

        table.sort(keys, function(a, b) return lia.option.stored[a].name < lia.option.stored[b].name end)
        for _, key in ipairs(keys) do
            local opt = lia.option.stored[key]
            if not opt.visible or isfunction(opt.visible) and opt.visible() then
                local name = opt.name
                local desc = opt.desc or ""
                local catName = opt.data and opt.data.category or L("misc")
                local ln, ld = name:lower(), desc:lower()
                local lk, lc = key:lower(), catName:lower()
                if filter == "" or ln:find(filter, 1, true) or ld:find(filter, 1, true) or lk:find(filter, 1, true) or lc:find(filter, 1, true) then
                    categories[catName] = categories[catName] or {}
                    categories[catName][#categories[catName] + 1] = {
                        key = key,
                        name = name,
                        config = opt,
                        elemType = opt.type or "Generic"
                    }
                end
            end
        end

        local catNames = {}
        for name in pairs(categories) do
            catNames[#catNames + 1] = name
        end

        table.sort(catNames)
        for _, catName in ipairs(catNames) do
            local items = categories[catName]
            local cat = vgui.Create("DCollapsibleCategory", parent)
            cat:Dock(TOP)
            cat:SetLabel(catName)
            cat:SetExpanded(true)
            cat:DockMargin(0, 0, 0, 10)
            if IsValid(cat.Header) then
                cat.Header:SetContentAlignment(5)
                cat.Header:SetTall(30)
                cat.Header:SetFont("liaMediumFont")
                cat.Header:SetTextColor(lia.color.theme.text)
                cat.Header.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(50, 50, 60, 120)):Shape(lia.derma.SHAPE_IOS):Draw() end
            end

            cat.Paint = function() end
            local body = vgui.Create("DPanel", cat)
            body:SetTall(#items * 240)
            body:DockMargin(5, 5, 5, 5)
            body.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(45, 45, 55, 60)):Shape(lia.derma.SHAPE_IOS):Draw() end
            cat:SetContents(body)
            for _, v in ipairs(items) do
                local panel = OptionFormatting[v.elemType](v.key, v.name, v.config, body)
                panel:Dock(TOP)
                panel:DockMargin(10, 10, 10, 0)
                panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(50, 50, 60, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            end
        end
    end

    pages[#pages + 1] = {
        name = "options",
        drawFunc = function(parent)
            parent:Clear()
            local sheet = parent:Add("liaSheet")
            sheet:Dock(FILL)
            sheet:SetPlaceholderText(L("searchOptions"))
            local function refresh()
                sheet:Clear()
                buildOptions(sheet.canvas, sheet.search:GetValue():lower())
                sheet:Refresh()
            end

            sheet.search.OnTextChanged = refresh
            refresh()
        end
    }
end)

lia.option.add("descriptionWidth", "descriptionWidth", "descriptionWidthDesc", 0.5, nil, {
    category = "categoryHUD",
    min = 0.1,
    max = 1,
    decimals = 2
})

lia.option.add("invertWeaponScroll", "invertWeaponScroll", "invertWeaponScrollDesc", false, nil, {
    category = "categoryWeaponSelector",
    isQuick = true,
})

lia.option.add("espEnabled", "espEnabled", "espEnabledDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espPlayers", "espPlayers", "espPlayersDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espItems", "espItems", "espItemsDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espEntities", "espEntities", "espEntitiesDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espUnconfiguredDoors", "espUnconfiguredDoors", "espUnconfiguredDoorsDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espItemsColor", "espItemsColor", "espItemsColorDesc", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espEntitiesColor", "espEntitiesColor", "espEntitiesColorDesc", {
    r = 255,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espUnconfiguredDoorsColor", "espUnconfiguredDoorsColor", "espUnconfiguredDoorsColorDesc", {
    r = 255,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espConfiguredDoors", "espConfiguredDoors", "espConfiguredDoorsDesc", false, nil, {
    category = "categoryESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espConfiguredDoorsColor", "espConfiguredDoorsColor", "espConfiguredDoorsColorDesc", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("espPlayersColor", "espPlayersColor", "espPlayersColorDesc", {
    r = 0,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "categoryESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")
    end
})

lia.option.add("BarsAlwaysVisible", "barsAlwaysVisible", "barsAlwaysVisibleDesc", false, nil, {
    category = "categoryGeneral",
    isQuick = true,
})

lia.option.add("descriptionWidth", "descriptionWidth", "descriptionWidthDesc", 0.5, nil, {
    category = "categoryHUD",
    min = 0.1,
    max = 1,
    decimals = 2
})

lia.option.add("thirdPersonEnabled", "thirdPersonEnabled", "thirdPersonEnabledDesc", false, function(_, newValue) hook.Run("ThirdPersonToggled", newValue) end, {
    category = "categoryThirdPerson",
    isQuick = true,
})

lia.option.add("thirdPersonClassicMode", "thirdPersonClassicMode", "thirdPersonClassicModeDesc", false, nil, {
    category = "categoryThirdPerson",
    isQuick = true,
})

lia.option.add("thirdPersonHeight", "thirdPersonHeight", "thirdPersonHeightDesc", 10, nil, {
    category = "categoryThirdPerson",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHeight", 30),
})

lia.option.add("thirdPersonHorizontal", "thirdPersonHorizontal", "thirdPersonHorizontalDesc", 10, nil, {
    category = "categoryThirdPerson",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHorizontal", 30),
})

lia.option.add("thirdPersonDistance", "thirdPersonDistance", "thirdPersonDistanceDesc", 50, nil, {
    category = "categoryThirdPerson",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonDistance", 100),
})

lia.option.add("ChatShowTime", "chatShowTime", "chatShowTimeDesc", false, nil, {
    category = "categoryChat",
    type = "Boolean"
})

lia.option.add("voiceRange", "voiceRange", "voiceRangeDesc", false, nil, {
    category = "categoryHUD",
    isQuick = true,
    type = "Boolean"
})

lia.option.add("weaponSelectorPosition", "weaponSelectorPosition", "weaponSelectorPositionDesc", "Left", nil, {
    category = "categoryWeaponSelector",
    type = "Table",
    options = {"Left", "Right", "Center"}
})
