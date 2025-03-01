function MODULE:LoadCharInformation()
    hook.Run("AddSection", "General Info", Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", "General Info", "name", "Name", function() return LocalPlayer():getChar():getName() end)
    hook.Run("AddTextField", "General Info", "desc", "Description", function() return LocalPlayer():getChar():getDesc() end)
    hook.Run("AddTextField", "General Info", "money", "Money", function() return LocalPlayer():getMoney() end)
end

function MODULE:AddSection(sectionName, color, priority, location)
    hook.Run("F1OnAddSection", sectionName, color, priority, location)
    self.CharacterInformations[sectionName] = {
        fields = {},
        color = color or Color(255, 255, 255),
        priority = priority or 999,
        location = location or 1
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
    tabs["Status"] = function(panel)
        panel.info = vgui.Create("liaCharInfo", panel)
        panel.info:setup()
        panel.info:SetAlpha(0)
        panel.info:AlphaTo(255, 0.5)
    end
end

lia.keybind.add(KEY_I, "Open Inventory", function()
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab("inv")
end)