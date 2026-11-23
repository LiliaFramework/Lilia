lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
local function localizeMenuLabel(value, ...)
    if not isstring(value) then return value end
    return lia.lang.resolve(value, ...)
end

lia.option.localizeValue = localizeMenuLabel
local function normalizeSelectableOption(optionEntry)
    if istable(optionEntry) then
        local rawLabel = optionEntry.rawLabel or optionEntry.label or optionEntry.name or optionEntry.text or optionEntry.value
        return {
            rawLabel = rawLabel,
            label = rawLabel,
            value = optionEntry.value ~= nil and optionEntry.value or rawLabel
        }
    elseif isstring(optionEntry) then
        return {
            rawLabel = optionEntry,
            label = optionEntry,
            value = optionEntry
        }
    end
end

local function localizeSelectableOption(optionEntry)
    if not istable(optionEntry) then return optionEntry end
    local rawLabel = optionEntry.rawLabel or optionEntry.label
    return {
        rawLabel = rawLabel,
        label = isstring(rawLabel) and localizeMenuLabel(rawLabel) or rawLabel,
        value = optionEntry.value
    }
end

local function getSelectableOptionLabel(options, selectedValue)
    for _, optionEntry in pairs(options or {}) do
        if istable(optionEntry) then
            if optionEntry.value == selectedValue then return optionEntry.label end
            if isstring(optionEntry.value) and isstring(selectedValue) and optionEntry.value:lower() == selectedValue:lower() then return optionEntry.label end
        end
    end
    return selectedValue
end

function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), string.format("Option key must be a string, got %s", type(key)))
    assert(isstring(name), string.format("Option name must be a string, got %s", type(name)))
    assert(istable(data), string.format("Expected option data to be a table, got %s", type(data)))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or t == "table" and default.r and default.g and default.b and "Color" or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or optionType == "Int" and math.floor(default / 2) or default / 2
        data.max = data.max or optionType == "Int" and math.floor(default * 2) or default * 2
    end

    if data.type then optionType = data.type end
    local old = lia.option.stored[key]
    local value = (old and old.value ~= nil) and old.value or default
    if istable(data.options) then
        for k, v in pairs(data.options) do
            local normalized = normalizeSelectableOption(v)
            if normalized then data.options[k] = normalized end
        end
    elseif isfunction(data.options) then
        data.optionsFunc = data.options
        data.options = nil
    end

    data.rawCategory = data.rawCategory or data.category
    data.category = isstring(data.category) and localizeMenuLabel(data.category) or data.category
    lia.option.stored[key] = {
        rawName = name,
        name = isstring(name) and localizeMenuLabel(name) or name,
        rawDesc = desc,
        desc = isstring(desc) and localizeMenuLabel(desc) or desc,
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

function lia.option.getDisplayName(key)
    local option = lia.option.stored[key]
    if not option then return key end
    local value = option.rawName or option.name or key
    return isstring(value) and localizeMenuLabel(value) or value
end

function lia.option.getDisplayDesc(key)
    local option = lia.option.stored[key]
    if not option then return "" end
    local value = option.rawDesc or option.desc or ""
    return isstring(value) and localizeMenuLabel(value) or value
end

function lia.option.getDisplayCategory(key)
    local option = lia.option.stored[key]
    if not option then return localizeMenuLabel("misc") end
    local data = option.data or {}
    local value = data.rawCategory or data.category or "misc"
    return isstring(value) and localizeMenuLabel(value) or value
end

function lia.option.getOptions(key)
    local option = lia.option.stored[key]
    if not option then return {} end
    if option.data.optionsFunc then
        local success, result = pcall(option.data.optionsFunc)
        if success and istable(result) then
            local normalizedOptions = {}
            for k, v in pairs(result) do
                local normalized = normalizeSelectableOption(v)
                if normalized then normalizedOptions[k] = localizeSelectableOption(normalized) end
            end
            return normalizedOptions
        else
            return {}
        end
    elseif istable(option.data.options) then
        local normalizedOptions = {}
        for k, v in pairs(option.data.options) do
            local normalized = normalizeSelectableOption(v)
            if normalized then normalizedOptions[k] = localizeSelectableOption(normalized) end
        end
        return normalizedOptions
    end
    return {}
end

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

function lia.option.get(key, default)
    local opt = lia.option.stored[key]
    if opt then
        if opt.value ~= nil then return opt.value end
        if opt.default ~= nil then return opt.default end
    end
    return default
end

function lia.option.save()
    local path = "lilia/options.json"
    local out = {}
    for k, v in pairs(lia.option.stored) do
        if v.value ~= nil then out[k] = v.value end
    end

    local json = util.TableToJSON(out, true)
    if json then file.Write(path, json) end
end

function lia.option.load()
    local path = "lilia/options.json"
    local data = file.Read(path, "DATA")
    local saved = data and util.JSONToTable(data) or nil
    for _, option in pairs(lia.option.stored) do
        option.value = option.default
    end

    if istable(saved) then
        for k, v in pairs(saved) do
            if lia.option.stored[k] then lia.option.stored[k].value = v end
        end
    else
        lia.option.save()
    end

    for _, option in pairs(lia.option.stored) do
        if option.callback then option.callback(option.value, option.value) end
    end

    hook.Run("InitializedOptions")
end

hook.Add("PopulateConfigurationButtons", "liaOptionsPopulate", function(pages)
    local uiColors = {
        bg = Color(5, 18, 23, 220),
        bgSoft = Color(7, 20, 25, 237),
        row = Color(10, 25, 30, 232),
        rowAlt = Color(9, 24, 29, 238),
        rowHover = Color(16, 34, 40, 235),
        selected = Color(13, 30, 35, 225),
        border = Color(45, 190, 170, 78),
        text = Color(242, 247, 247),
        muted = Color(155, 178, 179),
        dim = Color(100, 120, 122),
        accent = Color(45, 190, 170),
        accentSoft = Color(45, 190, 170, 28),
        success = Color(93, 203, 140)
    }

    local preferredCategories = {"Core", "HUD", "ESP", "Third Person", "Camera", "Performance", "Interface", "Gameplay", "Misc"}
    local function getAccent(alpha)
        local theme = lia.color and lia.color.theme or {}
        local color = theme.accent or theme.theme or lia.config.get("Color") or uiColors.accent
        if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
        return Color(uiColors.accent.r, uiColors.accent.g, uiColors.accent.b, alpha or uiColors.accent.a or 255)
    end

    local function getTextColor(alpha)
        local theme = lia.color and lia.color.theme or {}
        local color = theme.text or uiColors.text
        if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
        return Color(uiColors.text.r, uiColors.text.g, uiColors.text.b, alpha or uiColors.text.a or 255)
    end

    local function rounded(x, y, w, h, r, color)
        if lia.derma.SHAPE_IOS then
            lia.derma.rect(x, y, w, h):Rad(r or 0):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
            return
        end

        draw.RoundedBox(r or 0, x, y, w, h, color)
    end

    local function outline(x, y, w, h, color)
        if lia.derma.SHAPE_IOS then
            lia.derma.rect(x, y, w, h):Rad(6):Color(color):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
            return
        end

        surface.SetDrawColor(color)
        surface.DrawOutlinedRect(x, y, w, h)
    end

    local function normalizeValue(value)
        if IsColor(value) then
            return {
                r = value.r,
                g = value.g,
                b = value.b,
                a = value.a
            }
        end
        return value
    end

    local function valuesEqual(a, b)
        a = normalizeValue(a)
        b = normalizeValue(b)
        if istable(a) and istable(b) then return util.TableToJSON(a) == util.TableToJSON(b) end
        return a == b
    end

    local function formatValue(value)
        if IsColor(value) then return string.format("%d, %d, %d", value.r, value.g, value.b) end
        if istable(value) and value.r and value.g and value.b then return string.format("%d, %d, %d", value.r, value.g, value.b) end
        return tostring(value or "")
    end

    local function SetStyledTooltip(panel, text)
        if not text or text == "" then return end
        panel:SetTooltip(text)
        local oldSetTooltip = panel.SetTooltip
        function panel:SetTooltip(tooltipText)
            oldSetTooltip(self, tooltipText)
            timer.Simple(0, function()
                if not IsValid(self) then return end
                local tooltip = vgui.GetTooltipPanel()
                if IsValid(tooltip) and not tooltip.LiliaStyled then
                    tooltip.LiliaStyled = true
                    tooltip:SetTextColor(uiColors.text)
                    function tooltip:Paint(w, h)
                        rounded(0, 0, w, h, 8, Color(7, 18, 24, 245))
                        outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 135))
                    end
                end
            end)
        end
    end

    local function isOptionVisible(option)
        if not option then return false end
        if option.visible == nil then return true end
        if isfunction(option.visible) then
            local success, result = pcall(option.visible)
            return success and result ~= false
        end
        return option.visible ~= false
    end

    local function getRawCategory(option)
        local data = option.data or {}
        return data.rawCategory or data.category or "misc"
    end

    local function getVisualCategory(key, option)
        local raw = tostring(getRawCategory(option) or "misc")
        local localized = tostring(localizeMenuLabel(raw) or raw)
        local lowerRaw = raw:lower()
        local lowerCategory = localized:lower()
        local lowerKey = tostring(key or ""):lower()
        if lowerRaw:find("categoryesp", 1, true) or lowerCategory:find("esp", 1, true) or lowerKey:find("esp", 1, true) then return "ESP" end
        if lowerRaw:find("third", 1, true) or lowerCategory:find("third", 1, true) or lowerKey:find("thirdperson", 1, true) then return "Third Person" end
        if lowerRaw:find("camera", 1, true) or lowerCategory:find("camera", 1, true) or lowerKey:find("freelook", 1, true) or lowerKey:find("realisticview", 1, true) then return "Camera" end
        if lowerRaw:find("performance", 1, true) or lowerCategory:find("performance", 1, true) or lowerKey:find("shadow", 1, true) or lowerKey:find("lighting", 1, true) or lowerKey:find("blur", 1, true) or lowerKey:find("decal", 1, true) or lowerKey:find("smoothing", 1, true) or lowerKey:find("water", 1, true) or lowerKey:find("gib", 1, true) then return "Performance" end
        if lowerRaw:find("hud", 1, true) or lowerCategory:find("hud", 1, true) or lowerKey:find("hud", 1, true) or lowerKey:find("hover", 1, true) or lowerKey:find("bars", 1, true) or lowerKey:find("chat", 1, true) or lowerKey:find("weaponselector", 1, true) then return "HUD" end
        if lowerKey:find("view", 1, true) or lowerKey:find("camera", 1, true) or lowerKey:find("scroll", 1, true) or lowerKey:find("voice", 1, true) then return "Interface" end
        if lowerRaw == "Core" or lowerCategory == "core" then return "Core" end
        if lowerCategory == "misc" or lowerRaw == "misc" then return "Misc" end
        return localized ~= "" and localized or "Misc"
    end

    local function sortCategories(categories)
        local sorted = {}
        local exists = {}
        for _, category in ipairs(preferredCategories) do
            if categories[category] then
                sorted[#sorted + 1] = category
                exists[category] = true
            end
        end

        local remaining = {}
        for category in pairs(categories) do
            if not exists[category] then remaining[#remaining + 1] = category end
        end

        table.sort(remaining, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
        for _, category in ipairs(remaining) do
            sorted[#sorted + 1] = category
        end
        return sorted
    end

    local function styleScroll(scroll)
        local bar = scroll:GetVBar()
        if not IsValid(bar) then return end
        bar:SetWide(6)
        bar.Paint = function(_, w, h) rounded(2, 0, w - 2, h, 4, Color(0, 0, 0, 70)) end
        bar.btnGrip.Paint = function(_, w, h) rounded(1, 0, w - 1, h, 4, Color(getAccent().r, getAccent().g, getAccent().b, 185)) end
        bar.btnUp.Paint = function() end
        bar.btnDown.Paint = function() end
    end

    local function makeButton(parent, text, width, primary)
        local button = parent:Add("DButton")
        button:SetText(text)
        button:SetWide(width)
        button:SetFont("LiliaFont.18")
        button:SetTextColor(primary and color_white or uiColors.muted)
        button.Paint = function(me, w, h)
            local accent = getAccent(primary and 210 or 95)
            local bg = primary and Color(accent.r, accent.g, accent.b, me:IsHovered() and 225 or 185) or Color(9, 21, 29, me:IsHovered() and 235 or 205)
            rounded(0, 0, w, h, 4, bg)
            outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, primary and 150 or 100))
        end
        return button
    end

    local function makeToggle(parent, enabled, onChanged)
        local toggle = parent:Add("DButton")
        toggle:SetText("")
        toggle:SetSize(48, 24)
        toggle.value = enabled == true
        toggle.Paint = function(me, w, h)
            local active = me.value == true
            local accent = getAccent(active and 235 or 0)
            local bg = active and Color(accent.r, accent.g, accent.b, me:IsHovered() and 245 or 205) or Color(65, 83, 86, me:IsHovered() and 230 or 195)
            rounded(0, 0, w, h, 12, bg)
            rounded(active and w - 21 or 3, 3, 18, 18, 9, Color(238, 244, 244, 245))
        end

        toggle.DoClick = function(me)
            me.value = not me.value
            if onChanged then onChanged(me.value) end
        end
        return toggle
    end

    local function normalizeOptionValue(value, optionType, option)
        if optionType == "Int" or optionType == "Float" or optionType == "Number" then
            local numeric = tonumber(value)
            if numeric == nil then return nil end
            local data = option.data or {}
            if optionType == "Int" then numeric = math.Round(numeric) end
            if isnumber(data.min) then numeric = math.max(data.min, numeric) end
            if isnumber(data.max) then numeric = math.min(data.max, numeric) end
            if isnumber(data.decimals) and data.decimals >= 0 then
                local mult = 10 ^ data.decimals
                numeric = math.Round(numeric * mult) / mult
            end
            return numeric
        end

        if optionType == "Generic" then return tostring(value or "") end
        return value
    end

    local function collectOptions()
        local categories = {}
        local total = 0
        for key, option in pairs(lia.option.stored) do
            if isOptionVisible(option) then
                total = total + 1
                local category = getVisualCategory(key, option)
                categories[category] = categories[category] or {}
                categories[category][#categories[category] + 1] = {
                    key = key,
                    name = tostring(lia.option.getDisplayName(key) or key),
                    desc = tostring(lia.option.getDisplayDesc(key) or ""),
                    option = option,
                    category = category
                }
            end
        end

        for _, items in pairs(categories) do
            table.sort(items, function(a, b) return tostring(a.name or ""):lower() < tostring(b.name or ""):lower() end)
        end
        return categories, sortCategories(categories), total
    end

    local function getModifiedCount()
        local count = 0
        for _, option in pairs(lia.option.stored) do
            if isOptionVisible(option) and not valuesEqual(option.value, option.default) then count = count + 1 end
        end
        return count
    end

    local function drawSectionHeader(scroll, category, count)
        local header = scroll:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(34)
        header:DockMargin(0, 8, 0, 0)
        header.Paint = function(_, w, h)
            local accent = getAccent(210)
            surface.SetDrawColor(accent)
            surface.DrawRect(0, h - 2, w, 2)
            draw.SimpleText(string.upper(tostring(category)), "LiliaFont.18", 8, h * 0.5, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(count or 0), "LiliaFont.18", w - 10, h * 0.5, uiColors.dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    local function addOptionField(scroll, item, refreshFooter, repopulate)
        local key = item.key
        local option = item.option
        local optionType = option.type or "Generic"
        local description = item.desc or ""
        local currentValue = lia.option.get(key, option.value)
        local modified = not valuesEqual(currentValue, option.default)
        local row = scroll:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(58)
        row:DockMargin(0, 0, 0, 4)
        row.Paint = function(me, w, h)
            local accent = getAccent(modified and 215 or 70)
            rounded(0, 0, w, h, 3, me:IsHovered() and uiColors.rowHover or uiColors.row)
            outline(0, 0, w, h, modified and Color(accent.r, accent.g, accent.b, 135) or Color(getAccent().r, getAccent().g, getAccent().b, 78))
            if modified then
                surface.SetDrawColor(accent)
                surface.DrawRect(0, 0, 2, h)
            end
        end

        SetStyledTooltip(row, description)
        local controlDock = row:Add("DPanel")
        controlDock:Dock(RIGHT)
        controlDock:SetWide(230)
        controlDock:DockMargin(8, 9, 14, 9)
        controlDock.Paint = function() end
        local textDock = row:Add("DPanel")
        textDock:Dock(FILL)
        textDock:DockMargin(14, 7, 8, 7)
        textDock.Paint = function() end
        local title = textDock:Add("DLabel")
        title:Dock(TOP)
        title:SetTall(21)
        title:SetFont("LiliaFont.18")
        title:SetText(item.name)
        title:SetTextColor(getTextColor())
        title:SetContentAlignment(4)
        SetStyledTooltip(title, description)
        local desc = textDock:Add("DLabel")
        desc:Dock(FILL)
        desc:SetFont("LiliaFont.18")
        desc:SetText(description ~= "" and description or key)
        desc:SetTextColor(uiColors.muted)
        desc:SetWrap(true)
        desc:SetContentAlignment(7)
        SetStyledTooltip(desc, description)
        local function commit(value)
            local normalized = normalizeOptionValue(value, optionType, option)
            if normalized == nil then return end
            lia.option.set(key, normalized)
            if refreshFooter then refreshFooter() end
            if repopulate then timer.Simple(0, repopulate) end
        end

        if optionType == "Boolean" then
            controlDock:SetWide(72)
            local toggle = makeToggle(controlDock, currentValue == true, commit)
            toggle:SetPos(12, 8)
        elseif optionType == "Int" or optionType == "Float" or optionType == "Number" or optionType == "Generic" then
            local entry = controlDock:Add("liaEntry")
            entry:Dock(FILL)
            entry:SetValue(formatValue(currentValue))
            entry:SetFont("LiliaFont.18")
            SetStyledTooltip(entry, description)
            local function submitEntry()
                local value = entry:GetValue()
                local normalized = normalizeOptionValue(value, optionType, option)
                if normalized == nil then
                    entry:SetValue(formatValue(lia.option.get(key, option.value)))
                    return
                end

                lia.option.set(key, normalized)
                entry:SetValue(formatValue(normalized))
                if refreshFooter then refreshFooter() end
                if repopulate then timer.Simple(0, repopulate) end
            end

            if IsValid(entry.textEntry) then
                entry.textEntry.OnEnter = submitEntry
                entry.textEntry.OnLoseFocus = submitEntry
            else
                entry.OnEnter = submitEntry
                entry.OnLoseFocus = submitEntry
            end
        elseif optionType == "Color" then
            local button = controlDock:Add("DButton")
            button:Dock(FILL)
            button:SetText("")
            SetStyledTooltip(button, description)
            button.Paint = function(_, w, h)
                local c = lia.option.get(key, option.value)
                if istable(c) and c.r and c.g and c.b then
                    c = Color(c.r, c.g, c.b, c.a or 255)
                elseif not IsColor(c) then
                    c = color_white
                end

                rounded(0, 0, w, h, 4, Color(6, 18, 23, 225))
                outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 95))
                rounded(8, 7, w - 16, h - 14, 3, c)
            end

            button.DoClick = function()
                local c = lia.option.get(key, option.value)
                if not IsColor(c) and istable(c) then c = Color(c.r, c.g, c.b, c.a or 255) end
                lia.derma.requestColorPicker(function(color) commit(color) end, c)
            end
        elseif optionType == "Table" then
            local combo = controlDock:Add("liaComboBox")
            combo:Dock(FILL)
            combo:SetFont("LiliaFont.18")
            SetStyledTooltip(combo, description)
            local options = lia.option.getOptions(key)
            local selectedValue = lia.option.get(key, option.value)
            combo:SetValue(tostring(getSelectableOptionLabel(options, selectedValue)))
            for _, optionEntry in pairs(options) do
                combo:AddChoice(optionEntry.label, optionEntry.value)
            end

            combo.OnSelect = function(_, _, _, value) commit(value) end
        else
            local label = controlDock:Add("DLabel")
            label:Dock(FILL)
            label:SetFont("LiliaFont.18")
            label:SetText(formatValue(currentValue))
            label:SetTextColor(uiColors.muted)
            label:SetContentAlignment(6)
        end
    end

    local function drawOptionsPage(parent)
        parent:Clear()
        parent:DockPadding(0, 0, 0, 0)
        local categories, sortedCategories, totalOptions = collectOptions()
        local selectedCategory = categories.Core and "Core" or sortedCategories[1]
        local filterText = ""
        local categoryRail
        local optionScroll
        local categoryCombo
        local footerStatus
        local populate
        local rebuildRail
        local refreshFooter
        local root = parent:Add("DPanel")
        root:Dock(FILL)
        root:DockMargin(0, 0, 0, 0)
        root.Paint = function(_, w, h)
            rounded(0, 0, w, h, 8, uiColors.bg)
            outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 55))
        end

        local header = root:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(72)
        header:DockMargin(14, 12, 14, 0)
        header.Paint = function() end
        local title = header:Add("DLabel")
        title:Dock(TOP)
        title:SetTall(32)
        title:SetText("Options")
        title:SetFont("LiliaFont.22")
        title:SetTextColor(getTextColor())
        title:SetContentAlignment(4)
        local subtitle = header:Add("DLabel")
        subtitle:Dock(TOP)
        subtitle:SetTall(24)
        subtitle:SetText("Manage local client preferences, visual settings, quick toggles, and performance options.")
        subtitle:SetFont("LiliaFont.18")
        subtitle:SetTextColor(uiColors.muted)
        subtitle:SetContentAlignment(4)
        local toolbar = root:Add("DPanel")
        toolbar:Dock(TOP)
        toolbar:SetTall(42)
        toolbar:DockMargin(14, 0, 14, 10)
        toolbar.Paint = function() end
        local status = toolbar:Add("DPanel")
        status:Dock(RIGHT)
        status:SetWide(160)
        status:DockMargin(10, 3, 0, 3)
        status.Paint = function(_, w, h)
            local accent = getAccent()
            rounded(0, 0, w, h, 6, Color(13, 30, 35, 225))
            outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, 95))
            draw.SimpleText("Instant Save", "LiliaFont.18", w * 0.5, h * 0.5, getTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        categoryCombo = toolbar:Add("liaComboBox")
        categoryCombo:Dock(RIGHT)
        categoryCombo:SetWide(190)
        categoryCombo:DockMargin(0, 3, 0, 3)
        categoryCombo:SetFont("LiliaFont.18")
        categoryCombo:AddChoice("All Categories", "__all")
        for _, category in ipairs(sortedCategories) do
            categoryCombo:AddChoice(category, category)
        end

        categoryCombo:SetValue(selectedCategory or "All Categories")
        local searchEntry = toolbar:Add("liaEntry")
        searchEntry:Dock(FILL)
        searchEntry:DockMargin(0, 3, 10, 3)
        searchEntry:SetPlaceholderText("Search Options..." or "Search options...")
        searchEntry:SetFont("LiliaFont.18")
        local body = root:Add("DPanel")
        body:Dock(FILL)
        body:DockMargin(14, 0, 14, 0)
        body.Paint = function() end
        local railPanel = body:Add("DPanel")
        railPanel:Dock(LEFT)
        railPanel:SetWide(255)
        railPanel:DockMargin(0, 0, 12, 0)
        railPanel.Paint = function(_, w, h)
            rounded(0, 0, w, h, 6, uiColors.bgSoft)
            outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
        end

        categoryRail = railPanel:Add("liaScrollPanel")
        categoryRail:Dock(FILL)
        categoryRail:DockMargin(8, 8, 8, 8)
        categoryRail:GetCanvas():DockPadding(0, 0, 0, 0)
        styleScroll(categoryRail)
        optionScroll = body:Add("liaScrollPanel")
        optionScroll:Dock(FILL)
        optionScroll:GetCanvas():DockPadding(0, 0, 0, 0)
        styleScroll(optionScroll)
        local footer = root:Add("DPanel")
        footer:Dock(BOTTOM)
        footer:SetTall(54)
        footer:DockMargin(14, 8, 14, 14)
        footer.Paint = function(_, w, h)
            surface.SetDrawColor(Color(getAccent().r, getAccent().g, getAccent().b, 78))
            surface.DrawRect(0, 0, w, 1)
        end

        footerStatus = footer:Add("DLabel")
        footerStatus:Dock(LEFT)
        footerStatus:SetWide(560)
        footerStatus:SetFont("LiliaFont.18")
        footerStatus:SetTextColor(uiColors.muted)
        footerStatus:SetContentAlignment(4)
        local resetButton = makeButton(footer, "Reset", 135, false)
        resetButton:Dock(RIGHT)
        resetButton:DockMargin(8, 9, 0, 8)
        refreshFooter = function()
            if not IsValid(footerStatus) then return end
            footerStatus:SetText(totalOptions .. " options    |    " .. getModifiedCount() .. " modified    |    Saved to data/lilia/options.json")
            if IsValid(status) then status:InvalidateLayout(true) end
            if IsValid(resetButton) then resetButton:InvalidateLayout(true) end
        end

        local function addRailButton(label, value)
            local button = categoryRail:Add("DButton")
            button:Dock(TOP)
            button:SetTall(48)
            button:DockMargin(0, 0, 0, 6)
            button:SetText("")
            button:SetCursor("hand")
            button.Paint = function(s, w, h)
                local active = selectedCategory == value or (not selectedCategory and value == nil)
                local accent = getAccent()
                rounded(0, 0, w, h, 5, active and Color(accent.r, accent.g, accent.b, 35) or s:IsHovered() and Color(16, 34, 40, 235) or Color(10, 25, 30, 210))
                outline(0, 0, w, h, active and Color(accent.r, accent.g, accent.b, 160) or Color(getAccent().r, getAccent().g, getAccent().b, 62))
                if active then
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                    surface.DrawRect(0, 0, 3, h)
                end

                local count = value and categories[value] and #categories[value] or totalOptions
                draw.SimpleText(label, "LiliaFont.18", 16, h * 0.38, active and getTextColor() or Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(count .. " options", "LiliaFont.16", 16, h * 0.68, uiColors.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function()
                selectedCategory = value
                if IsValid(categoryCombo) then categoryCombo:SetValue(value or "All Categories") end
                rebuildRail()
                populate(filterText)
            end
        end

        rebuildRail = function()
            if not IsValid(categoryRail) then return end
            categories, sortedCategories, totalOptions = collectOptions()
            categoryRail:Clear()
            addRailButton("All Options", nil)
            for _, category in ipairs(sortedCategories) do
                addRailButton(category, category)
            end
        end

        populate = function(filter)
            if not IsValid(optionScroll) then return end
            filterText = filter or ""
            categories, sortedCategories, totalOptions = collectOptions()
            optionScroll:Clear()
            local hasAny = false
            local categoriesToDraw = selectedCategory and {selectedCategory} or sortedCategories
            for _, category in ipairs(categoriesToDraw) do
                local visibleItems = {}
                for _, item in ipairs(categories[category] or {}) do
                    local name = tostring(item.name or ""):lower()
                    local desc = tostring(item.desc or ""):lower()
                    local cat = tostring(category or ""):lower()
                    local loweredFilter = filterText ~= "" and filterText:lower() or nil
                    if not loweredFilter or name:find(loweredFilter, 1, true) or desc:find(loweredFilter, 1, true) or cat:find(loweredFilter, 1, true) then visibleItems[#visibleItems + 1] = item end
                end

                if #visibleItems > 0 then
                    hasAny = true
                    drawSectionHeader(optionScroll, category, #visibleItems)
                    for _, item in ipairs(visibleItems) do
                        addOptionField(optionScroll, item, refreshFooter, function()
                            rebuildRail()
                            populate(filterText)
                            refreshFooter()
                        end)
                    end
                end
            end

            if not hasAny then
                local empty = optionScroll:Add("DPanel")
                empty:Dock(TOP)
                empty:SetTall(90)
                empty.Paint = function(_, w, h)
                    rounded(0, 0, w, h, 6, Color(8, 22, 28, 185))
                    outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
                    draw.SimpleText("No options match your search.", "LiliaFont.18", w * 0.5, h * 0.5, uiColors.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            refreshFooter()
        end

        categoryCombo.OnSelect = function(_, _, _, value)
            selectedCategory = value == "__all" and nil or value
            rebuildRail()
            populate(filterText)
        end

        searchEntry:SetUpdateOnType(true)
        searchEntry.OnTextChanged = function(me, text) populate(text or me:GetValue()) end
        resetButton.DoClick = function()
            for key, option in pairs(lia.option.stored) do
                if isOptionVisible(option) and not valuesEqual(option.value, option.default) then lia.option.set(key, option.default) end
            end

            rebuildRail()
            populate(filterText)
            refreshFooter()
        end

        rebuildRail()
        populate(nil)
        refreshFooter()
    end

    pages[#pages + 1] = {
        name = "Options",
        shouldShow = function() return true end,
        drawFunc = function(parent) drawOptionsPage(parent) end
    }
end)

lia.option.add("descriptionWidth", "Description Width", "Adjust the description width on the HUD", 0.5, nil, {
    category = "Core",
    min = 0.1,
    max = 1,
    decimals = 2
})

lia.option.add("drawPlayerHoverInfo", "Player Hover Info", "Show or hide hover information for players.", true, nil, {
    category = "Core",
    isQuick = true,
})

lia.option.add("drawItemHoverInfo", "Item Hover Info", "Show or hide hover information for dropped items and money.", true, nil, {
    category = "Core",
    isQuick = true,
})

lia.option.add("drawEntityHoverInfo", "Entity Hover Info", "Show or hide hover information for general entities.", true, nil, {
    category = "Core",
    isQuick = true,
})

lia.option.add("invertWeaponScroll", "Invert Weapon Scroll", "Invert the weapon selection scroll direction.", false, nil, {
    category = "Core",
    isQuick = true,
})

lia.option.add("espEnabled", "ESP Enabled", "Toggle ESP features.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espPlayers", "ESP Players", "Enable ESP for players.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espItems", "ESP Items", "Enable ESP for items.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espEntities", "ESP Entities", "Enable ESP for entities.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espUnconfiguredDoors", "ESP Unconfigured Doors", "Enable ESP for doors without configuration.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espItemsColor", "ESP Items Color", "Sets the ESP color for items.", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espEntitiesColor", "ESP Entities Color", "Sets the ESP color for entities.", {
    r = 255,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espUnconfiguredDoorsColor", "ESP Unconfigured Doors Color", "Sets the ESP color for unconfigured doors.", {
    r = 255,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espConfiguredDoors", "ESP Configured Doors", "Enable ESP for doors with configuration.", false, nil, {
    category = "ESP",
    isQuick = true,
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espConfiguredDoorsColor", "ESP Configured Doors Color", "Sets the ESP color for configured doors.", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("espPlayersColor", "ESP Players Color", "Sets the ESP color for players.", {
    r = 0,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        local isStaffOnDuty = ply:isStaffOnDuty()
        local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
        local permission = isStaffOnDuty or hasNoClipOutsideStaff
        return permission
    end
})

lia.option.add("BarsAlwaysVisible", "Bars Always Visible", "Make all bars always visible", false, nil, {
    category = "Core",
    isQuick = true,
})

lia.option.add("thirdPersonEnabled", "Enable Third-Person View", "Allows players to toggle third-person view on or off.", false, function(_, newValue) hook.Run("ThirdPersonToggled", newValue) end, {
    category = "Third Person",
    isQuick = true,
})

lia.option.add("thirdPersonClassicMode", "Classic Mode", "Makes third-person aiming follow your camera direction even while standing still.", false, nil, {
    category = "Third Person",
    isQuick = true,
})

lia.option.add("thirdPersonHeight", "Third Person Height", "Makes the third-person camera sit higher or lower.", 10, nil, {
    category = "Third Person",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHeight", 30),
})

lia.option.add("thirdPersonHorizontal", "Horizontal", "Makes the third-person camera sit farther left or right.", 0, nil, {
    category = "Third Person",
    min = -lia.config.get("MaxThirdPersonHorizontal", 30),
    isQuick = true,
    max = lia.config.get("MaxThirdPersonHorizontal", 30),
})

lia.option.add("thirdPersonDistance", "Distance", "Makes the third-person camera sit closer to or farther from your character.", 50, nil, {
    category = "Third Person",
    min = 0,
    isQuick = true,
    max = lia.config.get("MaxThirdPersonDistance", 100),
})

lia.option.add("realisticViewEnabled", "Enable Realistic View", "Makes realistic view work with non-whitelisted weapons instead of only the default keys behavior.", false, nil, {
    category = "Camera",
    type = "Boolean",
    isQuick = true
})

lia.option.add("freelookEnabled", "Enable Freelook", "Makes freelook available so you can look around without turning your character.", true, nil, {
    category = "Camera",
    type = "Boolean",
    isQuick = true
})

lia.option.add("freelookLimitVertical", "Freelook Vertical Limit", "Makes freelook stop once you reach this up-or-down angle.", 65, nil, {
    category = "Camera",
    type = "Int",
    min = 30,
    max = 90
})

lia.option.add("freelookLimitHorizontal", "Freelook Horizontal Limit", "Makes freelook stop once you reach this left-or-right angle.", 90, nil, {
    category = "Camera",
    type = "Int",
    min = 60,
    max = 120
})

lia.option.add("freelookSmoothness", "Freelook Smoothness", "Makes the freelook camera catch up faster at higher values and lag more at lower values.", 1, nil, {
    category = "Camera",
    type = "Float",
    min = 0.1,
    max = 2,
    decimals = 2
})

lia.option.add("freelookBlockADS", "Freelook Block ADS", "Makes freelook turn off while aiming and blocks normal firing while freelook is being held.", true, nil, {
    category = "Camera",
    type = "Boolean"
})

lia.option.add("ChatShowTime", "Show Chat Timestamp", "Should chat show timestamp", false, nil, {
    category = "Core",
    type = "Boolean"
})

lia.option.add("shadows", "Shadows", "Enable/disable shadow rendering for better performance.", false, function(_, value) RunConsoleCommand("r_shadows", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("dynamicLighting", "Dynamic Lighting", "Enable/disable dynamic lighting from lights and flashlights.", false, function(_, value) RunConsoleCommand("r_dynamic", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("eyeMovement", "Eye Movement", "Enable/disable eye movement on player models.", false, function(_, value) RunConsoleCommand("r_eyemove", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("facialExpressions", "Facial Expressions", "Enable/disable facial flex animations and expressions.", false, function(_, value) RunConsoleCommand("r_flex", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("motionBlur", "Motion Blur", "Enable/disable motion blur effects.", false, function(_, value) RunConsoleCommand("mat_motion_blur_enabled", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("waterReflections", "Water Reflections", "Enable/disable water reflections.", false, function(_, value) RunConsoleCommand("r_waterdrawreflection", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("gameMonitors", "Game Monitors", "Enable/disable rendering of in-game monitors and screens.", false, function(_, value) RunConsoleCommand("cl_drawmonitors", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("alienGibs", "Alien Gibs", "Show/hide alien gibs (body parts).", false, function(_, value) RunConsoleCommand("violence_agibs", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("humanGibs", "Human Gibs", "Show/hide human gibs (body parts).", false, function(_, value) RunConsoleCommand("violence_hgibs", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("waterSplashes", "Water Splashes", "Enable/disable water splash effects.", false, function(_, value) RunConsoleCommand("cl_show_splashes", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("shellEjection", "Shell Ejection", "Enable/disable shell casing ejection from weapons.", false, function(_, value) RunConsoleCommand("cl_ejectbrass", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("sprayLifetime", "Spray Lifetime", "How long spray paints last (in seconds).", 1, function(_, value) RunConsoleCommand("r_spray_lifetime", tostring(value)) end, {
    min = 0,
    max = 300,
    category = "Performance",
    type = "Int"
})

lia.option.add("modelDecals", "Model Decals", "Enable/disable decals on models (bullet holes, blood splatters).", true, function(_, value) RunConsoleCommand("r_drawmodeldecals", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("detailFadeDistance", "Detail Fade Distance", "Distance at which details begin fading.", 800, function(_, value) RunConsoleCommand("cl_detailfade", tostring(value)) end, {
    min = 400,
    max = 2000,
    category = "Performance",
    type = "Int"
})

lia.option.add("detailDistance", "Detail Distance", "Distance at which detail props are visible.", 0, function(_, value) RunConsoleCommand("cl_detaildist", tostring(value)) end, {
    min = 0,
    max = 1200,
    category = "Performance",
    type = "Int"
})

lia.option.add("networkSmoothing", "Network Smoothing", "Enable/disable entity smoothing for network interpolation.", false, function(_, value) RunConsoleCommand("cl_smooth", value and "1" or "0") end, {
    category = "Performance",
    type = "Boolean"
})

lia.option.add("smoothingTime", "Smoothing Time", "Network smoothing interpolation time.", 0.05, function(_, value) RunConsoleCommand("cl_smoothtime", tostring(value)) end, {
    min = 0.01,
    max = 0.2,
    decimals = 2,
    category = "Performance",
    type = "Float"
})

lia.option.add("voiceRange", "Voice Range", "Display a circle showing your current voice range", false, nil, {
    category = "Core",
    isQuick = true,
    type = "Boolean"
})

lia.option.add("weaponSelectorPosition", "Weapon Selector Position", "Controls where the weapon selector appears on screen (Left, Right, or Center).", "right", nil, {
    category = "Core",
    type = "Table",
    options = {
        {
            label = "Left",
            value = "left"
        },
        {
            label = "Right",
            value = "right"
        },
        {
            label = "Center",
            value = "center"
        }
    }
})
