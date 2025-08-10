local MODULE = MODULE
MODULE.CharacterInformation = {}
function MODULE:LoadCharInformation()
    hook.Run("AddSection", L("generalInfo"), Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", L("generalInfo"), "name", L("name"), function() return LocalPlayer():getChar():getName() end)
    hook.Run("AddTextField", L("generalInfo"), "desc", L("description"), function() return LocalPlayer():getChar():getDesc() end)
    hook.Run("AddTextField", L("generalInfo"), "money", L("money"), function() return LocalPlayer():getMoney() end)
end

function MODULE:AddSection(sectionName, color, priority, location)
    hook.Run("F1OnAddSection", sectionName, color, priority, location)
    if not self.CharacterInformation[sectionName] then
        self.CharacterInformation[sectionName] = {
            fields = {},
            color = color or Color(255, 255, 255),
            priority = priority or 999,
            location = location or 1
        }
    else
        local info = self.CharacterInformation[sectionName]
        info.color = color or info.color
        info.priority = priority or info.priority
        info.location = location or info.location
    end
end

function MODULE:AddTextField(sectionName, fieldName, labelText, valueFunc)
    hook.Run("F1OnAddTextField", sectionName, fieldName, labelText, valueFunc)
    local section = self.CharacterInformation[sectionName]
    if section then
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then return end
        end

        table.insert(section.fields, {
            type = "text",
            name = fieldName,
            label = labelText,
            value = valueFunc or function() return "" end
        })
    end
end

function MODULE:AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    hook.Run("F1OnAddBarField", sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    local section = self.CharacterInformation[sectionName]
    if section then
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then return end
        end

        table.insert(section.fields, {
            type = "bar",
            name = fieldName,
            label = labelText,
            min = minFunc or function() return 0 end,
            max = maxFunc or function() return 100 end,
            value = valueFunc or function() return 0 end
        })
    end
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end

function MODULE:CreateMenuButtons(tabs)
    tabs["you"] = function(statusPanel)
        statusPanel.info = vgui.Create("liaCharInfo", statusPanel)
        statusPanel.info:Dock(FILL)
        statusPanel.info:setup()
        statusPanel.info:SetAlpha(0)
        statusPanel.info:AlphaTo(255, 0.5)
    end

    tabs["information"] = function(infoTabPanel)
        local sheet = infoTabPanel:Add("DPropertySheet")
        sheet:Dock(FILL)
        sheet:DockMargin(10, 10, 10, 10)
        local pages = {}
        hook.Run("CreateInformationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
            return an < bn
        end)

        for _, page in ipairs(pages) do
            local panel = vgui.Create("DPanel")
            panel:Dock(FILL)
            panel.Paint = function() end
            panel:DockPadding(10, 10, 10, 10)
            page.drawFunc(panel)
            local sheetData = sheet:AddSheet(L(page.name), panel)
            if page.onSelect then
                sheetData.Tab.liaPagePanel = panel
                sheetData.Tab.liaOnSelect = page.onSelect
            end
        end

        function sheet:OnActiveTabChanged(_, newTab)
            if IsValid(newTab) and newTab.liaOnSelect then newTab.liaOnSelect(newTab.liaPagePanel) end
        end
    end

    tabs["settings"] = function(settingsPanel)
        local sheet = settingsPanel:Add("DPropertySheet")
        sheet:Dock(FILL)
        sheet:DockMargin(10, 10, 10, 10)
        local pages = {}
        hook.Run("PopulateConfigurationButtons", pages)
        if not pages then return end
        table.sort(pages, function(a, b)
            local an = tostring(a.name):lower()
            local bn = tostring(b.name):lower()
            return an < bn
        end)

                    for _, page in ipairs(pages) do
                local panel = sheet:Add("DPanel")
                panel:Dock(FILL)
                panel.Paint = function() end
                page.drawFunc(panel)
                sheet:AddSheet(L(page.name), panel)
        end
    end

    local adminPages = {}
    hook.Run("PopulateAdminTabs", adminPages)
    if not table.IsEmpty(adminPages) then
        tabs["admin"] = function(adminPanel)
            local sheet = adminPanel:Add("DPropertySheet")
            sheet:Dock(FILL)
            sheet:DockMargin(10, 10, 10, 10)
            local pages = {}
            hook.Run("PopulateAdminTabs", pages)
            if table.IsEmpty(pages) then return end
            table.sort(pages, function(a, b)
                local an = tostring(a.name):lower()
                local bn = tostring(b.name):lower()
                return an < bn
            end)

            for _, page in ipairs(pages) do
                local panel = sheet:Add("DPanel")
                panel:Dock(FILL)
                panel.Paint = function() end
                local sheetData = sheet:AddSheet(L(page.name), panel, page.icon)
                if page.drawFunc then
                    sheetData.Tab.liaPagePanel = panel
                    sheetData.Tab.liaOnSelect = page.drawFunc
                end
            end

            function sheet:OnActiveTabChanged(_, newTab)
                if IsValid(newTab) and newTab.liaOnSelect then newTab.liaOnSelect(newTab.liaPagePanel) end
            end

            local initial = sheet:GetActiveTab()
            if IsValid(initial) and initial.liaOnSelect then initial.liaOnSelect(initial.liaPagePanel) end
        end
    end
end

function MODULE:CanDisplayCharInfo(name)
    local client = LocalPlayer()
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end