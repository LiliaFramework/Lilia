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
end

lia.keybind.add(KEY_I, "Open Inventory", function(p)
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab("inv")
end)