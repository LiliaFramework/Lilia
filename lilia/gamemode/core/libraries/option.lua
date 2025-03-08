lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), "Expected option key to be a string, got " .. type(key))
    assert(isstring(name), "Expected option name to be a string, got " .. type(name))
    assert(istable(data), "Expected option data to be a table, got " .. type(data))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or (t == "table" and default.r and default.g and default.b and "Color") or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or (optionType == "Int" and math.floor(default / 2) or default / 2)
        data.max = data.max or (optionType == "Int" and math.floor(default * 2) or default * 2)
    end

    local oldOption = lia.option.stored[key]
    local savedValue = oldOption and oldOption.value or default
    lia.option.stored[key] = {
        name = name,
        desc = desc,
        data = data,
        value = savedValue,
        default = default,
        callback = callback,
        type = optionType,
    }
end

function lia.option.set(key, value)
    local option = lia.option.stored[key]
    if option then
        local oldValue = option.value
        option.value = value
        if option.callback then option.callback(oldValue, value) end
        lia.option.save()
    end
end

function lia.option.get(key, default)
    local option = lia.option.stored[key]
    if option then
        if option.value ~= nil then
            return option.value
        elseif option.default ~= nil then
            return option.default
        end
    end
    return default
end

function lia.option.save()
    local dirPath = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dirPath)
    local ipWithoutPort = string.Explode(":", game.GetIPAddress())[1]
    local formattedIP = ipWithoutPort:gsub("%.", "_")
    local saveLocation = dirPath .. "/" .. formattedIP .. ".txt"
    local data = {}
    for k, v in pairs(lia.option.stored) do
        if v and v.value ~= nil then data[k] = v.value end
    end

    local jsonData = util.TableToJSON(data, true)
    if jsonData then file.Write(saveLocation, jsonData) end
end

function lia.option.load()
    local dirPath = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dirPath)
    local ipWithoutPort = string.Explode(":", game.GetIPAddress())[1]
    local formattedIP = ipWithoutPort:gsub("%.", "_")
    local loadLocation = dirPath .. "/" .. formattedIP .. ".txt"
    local data = file.Read(loadLocation, "DATA")
    if data then
        local savedOptions = util.JSONToTable(data)
        for k, v in pairs(savedOptions) do
            if lia.option.stored[k] then lia.option.stored[k].value = v end
        end
    end

    hook.Run("InitializedOptions")
end

hook.Add("CreateMenuButtons", "OptionsMenuButtons", function(tabs)
    local OptionFormatting = {
        Int = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local slider = panel:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
            slider:SetDecimals(0)
            slider:SetValue(lia.option.get(key, config.value))
            slider.PerformLayout = function()
                slider.Label:SetWide(100)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, newValue) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.floor(newValue)) end) end
            return container
        end,
        Float = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local slider = panel:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
            slider:SetDecimals(2)
            slider:SetValue(lia.option.get(key, config.value))
            slider.PerformLayout = function()
                slider.Label:SetWide(100)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, newValue) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.Round(newValue, 2)) end) end
            return container
        end,
        Generic = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function() end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local entry = panel:Add("DTextEntry")
            entry:Dock(TOP)
            entry:SetTall(60)
            entry:DockMargin(300, 10, 300, 0)
            entry:SetText(tostring(lia.option.get(key, config.value)))
            entry:SetFont("ConfigFontLarge")
            entry:SetTextColor(Color(255, 255, 255))
            entry.OnEnter = function(btn)
                local newValue = btn:GetText()
                lia.option.set(key, newValue)
            end
            return container
        end,
        Boolean = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local button = panel:Add("DButton")
            button:Dock(TOP)
            button:SetTall(100)
            button:DockMargin(100, 10, 100, 0)
            button:SetText("")
            button.Paint = function(_, w, h)
                local check = getIcon("0xe880", true)
                local uncheck = getIcon("0xf096", true)
                local icon = lia.option.get(key, config.value) and check or uncheck
                lia.util.drawText(icon, w / 2, h / 2 - 10, color_white, 1, 1, "liaIconsHugeNew")
            end

            button.DoClick = function() lia.option.set(key, not lia.option.get(key, config.value)) end
            return container
        end,
        Color = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(220)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local button = panel:Add("DButton")
            button:Dock(FILL)
            button:DockMargin(10, 0, 10, 0)
            button:SetText("")
            button.Paint = function(_, w, h)
                surface.SetDrawColor(lia.option.get(key, config.value))
                surface.DrawRect(w - 925, h / 2 - 27, 500, 54)
            end

            button.DoClick = function(this)
                local pickerFrame = this:Add("DFrame")
                pickerFrame:SetSize(ScrW() * 0.15, ScrH() * 0.2)
                pickerFrame:SetPos(gui.MouseX(), gui.MouseY())
                pickerFrame:MakePopup()
                if IsValid(button.picker) then button.picker:Remove() end
                button.picker = pickerFrame
                local Mixer = pickerFrame:Add("DColorMixer")
                Mixer:Dock(FILL)
                Mixer:SetPalette(true)
                Mixer:SetAlphaBar(true)
                Mixer:SetWangs(true)
                Mixer:SetColor(lia.option.get(key, config.value))
                pickerFrame.curColor = lia.option.get(key, config.value)
                local confirm = pickerFrame:Add("DButton")
                confirm:Dock(BOTTOM)
                confirm:SetText("Apply")
                confirm:SetTextColor(color_white)
                confirm.DoClick = function()
                    timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, pickerFrame.curColor) end)
                    pickerFrame:Remove()
                end

                Mixer.ValueChanged = function(_, value) pickerFrame.curColor = value end
            end
            return container
        end,
        Table = function(key, name, config, parent)
            local container = vgui.Create("DPanel", parent)
            container:SetTall(300)
            container:Dock(TOP)
            container:DockMargin(0, 60, 0, 10)
            container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local panel = container:Add("DPanel")
            panel:Dock(FILL)
            panel.Paint = nil
            local label = panel:Add("DLabel")
            label:Dock(TOP)
            label:SetTall(45)
            label:SetText(name)
            label:SetFont("ConfigFontLarge")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))
            label:DockMargin(0, 20, 0, 0)
            local description = panel:Add("DLabel")
            description:Dock(TOP)
            description:SetTall(35)
            description:SetText(config.desc or "")
            description:SetFont("DescriptionFontLarge")
            description:SetContentAlignment(5)
            description:SetTextColor(Color(200, 200, 200))
            description:DockMargin(0, 10, 0, 0)
            local listView = panel:Add("DListView")
            listView:Dock(FILL)
            listView:SetMultiSelect(false)
            listView:AddColumn("Items")
            for _, item in ipairs(lia.option.get(key, config.value) or {}) do
                listView:AddLine(tostring(item))
            end

            local addButton = panel:Add("DButton")
            addButton:Dock(BOTTOM)
            addButton:SetTall(30)
            addButton:SetText("Add Item")
            addButton.DoClick = function()
                Derma_StringRequest("Add Item", "Enter new item:", "", function(text)
                    if text and text ~= "" then
                        local current = lia.option.get(key, config.value) or {}
                        table.insert(current, text)
                        lia.option.set(key, current)
                        listView:AddLine(text)
                    end
                end)
            end

            local removeButton = panel:Add("DButton")
            removeButton:Dock(BOTTOM)
            removeButton:SetTall(30)
            removeButton:SetText("Remove Selected")
            removeButton.DoClick = function()
                local selected = listView:GetSelected()
                if #selected > 0 then
                    local line = selected[1]
                    local index = listView:Line(line):GetID()
                    local current = lia.option.get(key, config.value) or {}
                    table.remove(current, index)
                    lia.option.set(key, current)
                    listView:RemoveLine(index)
                end
            end
            return container
        end
    }

    tabs["Settings"] = function(panel)
        panel.sidebar = panel:Add("DScrollPanel")
        panel.sidebar:Dock(LEFT)
        panel.sidebar:SetWide(250)
        panel.sidebar:DockMargin(20, 20, 10, 20)
        panel.scroll = panel:Add("DScrollPanel")
        panel.scroll:Dock(FILL)
        panel.scroll:DockMargin(10, 10, 10, 10)
        panel.scroll.Paint = function() end
        panel.categories = {}
        panel.activeTab = nil
        local function createCategoryButton(text)
            local categoryLabel = vgui.Create("DButton")
            categoryLabel:SetText(text)
            categoryLabel:SetTall(40)
            categoryLabel:SetFont("liaMediumFont")
            categoryLabel:SetTextColor(color_white)
            categoryLabel.Paint = function(btn, w, h)
                if btn:IsHovered() then
                    local underlineWidth = w * 0.4
                    local underlineX = (w - underlineWidth) * 0.5
                    local underlineY = h - 4
                    surface.SetDrawColor(255, 255, 255, 80)
                    surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
                end

                if panel.activeTab == btn then
                    surface.SetDrawColor(color_white)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
            end

            categoryLabel.DoClick = function(button)
                for _, cat in pairs(panel.categories) do
                    for _, btn in ipairs(cat.buttons) do
                        btn:SetVisible(false)
                    end
                end

                for _, btn in ipairs(panel.categories[text].buttons) do
                    btn:SetVisible(true)
                end

                panel.activeTab = button
            end
            return categoryLabel
        end

        local function addCategory(text)
            if panel.categories[text] then return panel.categories[text].label end
            local categoryLabel = createCategoryButton(text)
            panel.categories[text] = {
                label = categoryLabel,
                buttons = {}
            }
            return categoryLabel
        end

        local function addElement(elementType, key, name, option, category)
            category = category or "Miscellaneous"
            local cat = panel.categories[category]
            if not cat then
                cat = {
                    label = addCategory(category),
                    buttons = {}
                }

                panel.categories[category] = cat
            end

            local panelElement = OptionFormatting[elementType](key, name, option, panel.scroll)
            panelElement:SetParent(panel.scroll)
            panelElement:Dock(TOP)
            panelElement:DockMargin(20, 10, 20, 10)
            panelElement:SetVisible(false)
            panelElement.Paint = function(_, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                surface.SetDrawColor(255, 255, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            table.insert(cat.buttons, panelElement)
        end

        for key, option in pairs(lia.option.stored) do
            local elementType = option.type
            addElement(elementType, key, option.name, option, option.data and option.data.category)
        end

        local sortedCategories = {}
        for _, cat in pairs(panel.categories) do
            table.insert(sortedCategories, cat)
        end

        table.sort(sortedCategories, function(a, b) return a.label:GetText() < b.label:GetText() end)
        panel.sidebar:Clear()
        for _, cat in ipairs(sortedCategories) do
            cat.label:SetParent(panel.sidebar)
            cat.label:Dock(TOP)
            cat.label:DockMargin(0, 10, 0, 10)
            panel.sidebar:AddItem(cat.label)
        end

        if sortedCategories[1] then
            for _, btn in ipairs(sortedCategories[1].buttons) do
                btn:SetVisible(true)
            end
        end

        panel.scroll:InvalidateLayout(true)
    end
end)
