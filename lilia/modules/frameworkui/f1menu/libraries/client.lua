function MODULE:LoadCharInformation()
    hook.Run("AddSection", "General Info", Color(0, 0, 0), 1)
    hook.Run("AddTextField", "General Info", "name", "Name", function() return LocalPlayer():getChar():getName() end)
    hook.Run("AddTextField", "General Info", "desc", "Description", function() return LocalPlayer():getChar():getDesc() end)
    hook.Run("AddTextField", "General Info", "money", "Money", function() return LocalPlayer():getMoney() end)
end

function MODULE:AddSection(sectionName, color, priority)
    hook.Run("F1OnAddSection", sectionName, color, priority)
    self.CharacterInformations[sectionName] = {
        fields = {},
        color = color or Color(255, 255, 255),
        priority = priority or 999
    }
end

function MODULE:AddTextField(sectionName, fieldName, labelText, valueFunc)
    hook.Run("F1OnAddTextField", sectionName, fieldName, labelText, valueFunc)
    local section = self.CharacterInformations[sectionName]
    if section then
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
    local section = self.CharacterInformations[sectionName]
    if section then
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

function MODULE:CanDisplayCharInfo(name)
    local client = LocalPlayer()
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end

function MODULE:CreateMenuButtons(tabs)
    local client = LocalPlayer()
    tabs["Status"] = function(panel)
        panel.rotationAngle = 45
        panel.rotationSpeed = 0.5
        panel.info = vgui.Create("liaCharInfo", panel)
        panel.info:setup()
        panel.info:SetAlpha(0)
        panel.info:AlphaTo(255, 0.5)
        panel.model = panel:Add("liaModelPanel")
        panel.model:SetWide(ScrW() * 0.25)
        panel.model:SetFOV(50)
        panel.model:SetTall(ScrH() - 50)
        panel.model:SetPos(ScrW() - panel.model:GetWide() - 150, 150)
        panel.model:SetModel(client:GetModel())
        panel.model.Entity:SetSkin(client:GetSkin())
        for _, v in ipairs(client:GetBodyGroups()) do
            panel.model.Entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
        end

        local ent = panel.model.Entity
        if ent and IsValid(ent) then
            local mats = client:GetMaterials()
            for k, _ in pairs(mats) do
                ent:SetSubMaterial(k - 1, client:GetSubMaterial(k - 1))
            end
        end

        panel.model.Think = function()
            local rotateLeft = input.IsKeyDown(KEY_A)
            local rotateRight = input.IsKeyDown(KEY_D)
            if rotateLeft then
                panel.rotationAngle = panel.rotationAngle - panel.rotationSpeed
            elseif rotateRight then
                panel.rotationAngle = panel.rotationAngle + panel.rotationSpeed
            end

            if IsValid(panel.model) and IsValid(panel.model.Entity) then
                local Angles = Angle(0, panel.rotationAngle, 0)
                panel.model.Entity:SetAngles(Angles)
            end
        end
    end

    if hook.Run("CanPlayerViewInventory") ~= false then
        tabs["inv"] = function(panel)
            local inventory = client:getChar():getInv()
            if not inventory then return end
            local mainPanel = inventory:show(panel)
            local sortPanels = {}
            local totalSize = {
                x = 0,
                y = 0,
                p = 0
            }

            table.insert(sortPanels, mainPanel)
            totalSize.x = totalSize.x + mainPanel:GetWide() + 10
            totalSize.y = math.max(totalSize.y, mainPanel:GetTall())
            local px, py, pw, ph = mainPanel:GetBounds()
            local x, y = px + pw / 2 - totalSize.x / 2, py + ph / 2
            for _, panel in pairs(sortPanels) do
                panel:ShowCloseButton(true)
                panel:SetPos(x, y - panel:GetTall() / 2)
                x = x + panel:GetWide() + 10
            end

            hook.Add("PostRenderVGUI", mainPanel, function() hook.Run("PostDrawInventory", mainPanel) end)
        end
    end

    if table.Count(lia.class.list) > 1 then
        local hasClass = false
        for k, _ in ipairs(lia.class.list) do
            if lia.class.canBe(client, k) then hasClass = true end
        end

        if hasClass then tabs["classes"] = function(panel) panel:Add("liaClasses") end end
    end

    tabs["help"] = function(panel)
        local sidebar = panel:Add("DPanel")
        sidebar:Dock(LEFT)
        sidebar:SetWide(200)
        sidebar:DockMargin(20, 20, 0, 20)
        sidebar.Paint = function() end
        local mainContent = panel:Add("DPanel")
        mainContent:Dock(FILL)
        mainContent.Paint = function() end
        local html = mainContent:Add("DHTML")
        html:Dock(FILL)
        local helpTabs = {}
        hook.Run("BuildHelpMenu", helpTabs)
        panel.activeTab = nil
        panel.tabList = {}
        for k, v in SortedPairs(helpTabs) do
            local tabName = L(k)
            local callback = v
            local button = sidebar:Add("DButton")
            button:SetText(tabName)
            button:SetTextColor(self.MenuColors.text)
            button:SetFont("liaMediumFont")
            button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
            button:SetContentAlignment(5)
            button:SetTall(50)
            button:Dock(TOP)
            button:DockMargin(0, 0, 10, 10)
            button.Paint = function(btn, w, h)
                if panel.activeTab == btn then
                    surface.SetDrawColor(self.MenuColors.accent)
                    surface.DrawRect(0, 0, w, h)
                elseif btn:IsHovered() then
                    surface.SetDrawColor(self.MenuColors.hover)
                    surface.DrawRect(0, 0, w, h)
                else
                    surface.SetDrawColor(self.MenuColors.sidebar)
                    surface.DrawRect(0, 0, w, h)
                end

                surface.SetDrawColor(self.MenuColors.border)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            button.DoClick = function()
                panel.activeTab = btn
                for _, btn in pairs(panel.tabList) do
                    btn.active = false
                end

                panel.tabList[tabName].active = true
                mainContent:Clear()
                local tabPanel = mainContent:Add("DPanel")
                tabPanel:Dock(FILL)
                tabPanel.Paint = function() end
                callback(tabPanel, sidebar)
                surface.PlaySound(self.TabClickingSound or "buttons/button14.wav")
            end

            panel.tabList[tabName] = button
        end
    end
end

function MODULE:BuildHelpMenu(tabs)
    local client = LocalPlayer()
    if hook.Run("CanPlayerViewCommands") ~= false then
        tabs["Commands"] = function(parent)
            local listView = vgui.Create("DListView", parent)
            listView:SetMultiSelect(false)
            listView:AddColumn("Command")
            listView:AddColumn("Syntax")
            listView:AddColumn("Privilege")
            listView:SetSize(sW(1360), sH(768))
            listView:SetPos(sW(50), sH(150))
            for cmdName, cmdData in SortedPairs(lia.command.list) do
                local hasAccess, privilege = lia.command.hasAccess(LocalPlayer(), cmdName, cmdData)
                if hasAccess then listView:AddLine("/" .. cmdName, cmdData.syntax, privilege) end
            end
        end
    end

    tabs["flags"] = function(parent)
        local listView = vgui.Create("DListView", parent)
        listView:SetMultiSelect(false)
        listView:AddColumn("Status")
        listView:AddColumn("Flag")
        listView:AddColumn("Description")
        listView:SetSize(sW(1360), sH(768))
        listView:SetPos(sW(50), sH(150))
        for flagName, flagData in SortedPairs(lia.flag.list) do
            local status = client:getChar():hasFlags(flagName) and "✓" or "✗"
            listView:AddLine(status, flagName, flagData.desc)
        end
        return listView
    end

    tabs["modules"] = function(parent)
        local listView = vgui.Create("DListView", parent)
        listView:SetMultiSelect(false)
        listView:AddColumn("Module")
        listView:AddColumn("Description")
        listView:AddColumn("Discord")
        listView:AddColumn("Author")
        listView:AddColumn("Version")
        listView:SetSize(sW(1360), sH(768))
        listView:SetPos(sW(50), sH(150))
        for _, module in SortedPairsByMemberValue(lia.module.list, "name") do
            if module.MenuNoShow then continue end
            local version = module.version or "1.0"
            local author = (not isstring(module.author) and lia.module.namecache[module.author]) or module.author or "Unknown"
            listView:AddLine(module.name or "Unknown", module.desc or "No Description", module.discord or "Unknown", author, version)
        end
        return listView
    end
end