﻿function MODULE:LoadCharInformation()
    hook.Run("AddSection", "General Info", Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", "General Info", "name", "Name", function() return LocalPlayer():getChar():getName() end)
    hook.Run("AddTextField", "General Info", "desc", "Description", function() return LocalPlayer():getChar():getDesc() end)
    hook.Run("AddTextField", "General Info", "money", "Money", function() return LocalPlayer():getMoney() end)
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
        self.CharacterInformation[sectionName].color = color or self.CharacterInformation[sectionName].color
        self.CharacterInformation[sectionName].priority = priority or self.CharacterInformation[sectionName].priority
        self.CharacterInformation[sectionName].location = location or self.CharacterInformation[sectionName].location
    end
end

function MODULE:AddTextField(sectionName, fieldName, labelText, valueFunc)
    hook.Run("F1OnAddTextField", sectionName, fieldName, labelText, valueFunc)
    local section = self.CharacterInformation[sectionName]
    if section then
        local exists = false
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(section.fields, {
                type = "text",
                name = fieldName,
                label = labelText,
                value = valueFunc or function() return "" end
            })
        end
    end
end

function MODULE:AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    hook.Run("F1OnAddBarField", sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    local section = self.CharacterInformation[sectionName]
    if section then
        local exists = false
        for _, field in ipairs(section.fields) do
            if field.name == fieldName then
                exists = true
                break
            end
        end

        if not exists then
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

function MODULE:BuildInformationMenu(pages)
    local client = LocalPlayer()
    local entitiesByCreator = {}
    for _, ent in ents.Iterator() do
        if IsValid(ent) and ent.GetCreator and IsValid(ent:GetCreator()) then
            local owner = ent:GetCreator():Nick()
            entitiesByCreator[owner] = entitiesByCreator[owner] or {}
            table.insert(entitiesByCreator[owner], ent)
        end
    end

    local function startSpectateView(ent, originalThirdPerson)
        local yaw = client:EyeAngles().yaw
        local camZOffset = 50
        hook.Add("CalcView", "EntityViewCalcView", function()
            return {
                origin = ent:GetPos() + Angle(0, yaw, 0):Forward() * 100 + Vector(0, 0, camZOffset),
                angles = Angle(0, yaw, 0),
                fov = 60
            }
        end)

        hook.Add("HUDPaint", "EntityViewHUD", function() draw.SimpleText("Press A/D to rotate | W/S to move camera vertically | Press SPACE to exit", "liaMediumFont", ScrW() / 2, ScrH() - 50, color_white, TEXT_ALIGN_CENTER) end)
        hook.Add("Think", "EntityViewRotate", function()
            if input.IsKeyDown(KEY_A) then yaw = yaw - FrameTime() * 100 end
            if input.IsKeyDown(KEY_D) then yaw = yaw + FrameTime() * 100 end
            if input.IsKeyDown(KEY_W) then camZOffset = camZOffset + FrameTime() * 100 end
            if input.IsKeyDown(KEY_S) then camZOffset = camZOffset - FrameTime() * 100 end
            if input.IsKeyDown(KEY_SPACE) then
                hook.Remove("CalcView", "EntityViewCalcView")
                hook.Remove("HUDPaint", "EntityViewHUD")
                hook.Remove("Think", "EntityViewRotate")
                hook.Remove("CreateMove", "EntitySpectateCreateMove")
                lia.option.set("thirdPersonEnabled", originalThirdPerson)
            end
        end)

        hook.Add("CreateMove", "EntitySpectateCreateMove", function(cmd)
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
            cmd:SetUpMove(0)
        end)
    end

    table.insert(pages, {
        name = "Entities",
        drawFunc = function(panel)
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            for owner, entsList in SortedPairs(entitiesByCreator) do
                local header = vgui.Create("DCollapsibleCategory", scroll)
                header:Dock(TOP)
                header:SetLabel(owner)
                header:SetExpanded(true)
                header:DockMargin(0, 0, 0, 0)
                header.Paint = function() end
                header.Header:SetFont("liaMediumFont")
                header.Header:SetTextColor(Color(255, 255, 255))
                header.Header:SetContentAlignment(5)
                header.Header:SetTall(30)
                header.Header.Paint = function(_, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                local body = vgui.Create("DPanel", header)
                body.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
                header:SetContents(body)
                for _, ent in ipairs(entsList) do
                    local class = ent:GetClass()
                    local entPanel = vgui.Create("DPanel", body)
                    entPanel:Dock(TOP)
                    entPanel:DockMargin(10, 15, 10, 10)
                    entPanel:SetTall(100)
                    entPanel.Paint = function(_, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
                        draw.SimpleText(class, "liaMediumFont", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local icon = vgui.Create("liaSpawnIcon", entPanel)
                    icon:Dock(LEFT)
                    icon:SetWide(64)
                    icon:SetModel(ent:GetModel() or "models/error.mdl", ent:GetSkin() or 0)
                    icon.DoClick = function()
                        if IsValid(lastModelFrame) then lastModelFrame:Close() end
                        lastModelFrame = vgui.Create("DFrame")
                        lastModelFrame:SetTitle(class)
                        lastModelFrame:SetSize(800, 800)
                        lastModelFrame:Center()
                        lastModelFrame:MakePopup()
                        local info = vgui.Create("DLabel", lastModelFrame)
                        info:SetText("Press A/D to rotate | W/S to move camera vertically | Press SPACE to exit")
                        info:SetFont("liaMediumFont")
                        info:SizeToContents()
                        info:Dock(TOP)
                        info:DockMargin(0, 10, 0, 0)
                        info:SetContentAlignment(5)
                        local modelPanel = vgui.Create("DModelPanel", lastModelFrame)
                        modelPanel:Dock(FILL)
                        modelPanel:SetModel(ent:GetModel() or "models/error.mdl", ent:GetSkin() or 0)
                        modelPanel:SetFOV(45)
                        local mn, mx = modelPanel.Entity:GetRenderBounds()
                        local size = math.max(math.abs(mn.x) + math.abs(mx.x), math.abs(mn.y) + math.abs(mx.y), math.abs(mn.z) + math.abs(mx.z))
                        modelPanel:SetCamPos(Vector(size, size, size))
                        modelPanel:SetLookAt((mn + mx) * 0.5)
                        local originalThirdPerson = lia.option.get("thirdPersonEnabled", false)
                        lia.option.set("thirdPersonEnabled", false)
                        startSpectateView(ent,  originalThirdPerson)
                    end

                    local btnContainer = vgui.Create("DPanel", entPanel)
                    btnContainer:Dock(RIGHT)
                    btnContainer:SetWide(180)
                    if client:hasPrivilege("Staff Permission — View Entity (Entity Tab)") then
                        local btnView = vgui.Create("DButton", btnContainer)
                        btnView:Dock(LEFT)
                        btnView:SetWide(60)
                        btnView:SetText("View")
                        btnView.DoClick = function()
                            if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
                            local originalThirdPerson = lia.option.get("thirdPersonEnabled", false)
                            lia.option.set("thirdPersonEnabled", false)
                            startSpectateView(ent,  originalThirdPerson)
                        end
                    end

                    if client:hasPrivilege("Staff Permission — Teleport to Entity (Entity Tab)") then
                        local btnTeleport = vgui.Create("DButton", btnContainer)
                        btnTeleport:Dock(LEFT)
                        btnTeleport:SetWide(60)
                        btnTeleport:SetText("Teleport")
                        btnTeleport.DoClick = function()
                            net.Start("liaTeleportToEntity")
                            net.WriteEntity(ent)
                            net.SendToServer()
                        end
                    end

                    local btnWaypoint = vgui.Create("DButton", btnContainer)
                    btnWaypoint:Dock(RIGHT)
                    btnWaypoint:SetWide(60)
                    btnWaypoint:SetText("Waypoint")
                    btnWaypoint.DoClick = function() client:setWaypoint(class, ent:GetPos()) end
                end
            end
        end
    })

    if client:hasPrivilege("Staff Permission — Access Faction List") then
        table.insert(pages, {
            name = "Factions & Classes",
            drawFunc = function(panel)
                local scroll = vgui.Create("DScrollPanel", panel)
                scroll:Dock(FILL)
                for _, faction in SortedPairs(lia.faction.indices) do
                    local cat = vgui.Create("DCollapsibleCategory", scroll)
                    cat:Dock(TOP)
                    cat:SetLabel(faction.name)
                    cat:SetExpanded(false)
                    cat:DockMargin(0, 0, 0, 10)
                    cat.Paint = function() end
                    cat.Header:SetContentAlignment(5)
                    cat.Header:SetTall(30)
                    cat.Header:SetFont("liaMediumFont")
                    cat.Header:SetTextColor(Color(255, 255, 255))
                    cat.Header.Paint = function(_, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawOutlinedRect(0, 0, w, h)
                    end

                    local body = vgui.Create("DPanel", cat)
                    body.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
                    cat:SetContents(body)
                    for _, classData in SortedPairs(lia.class.list) do
                        if classData.faction == faction.index then
                            local details = {}
                            table.insert(details, "Description: " .. (classData.desc or "No description."))
                            table.insert(details, "Faction: " .. team.GetName(classData.faction))
                            table.insert(details, "Is Default: " .. (classData.isDefault and "Yes" or "No"))
                            table.insert(details, "Base Health: " .. tostring(classData.health or LocalPlayer():GetMaxHealth()))
                            table.insert(details, "Base Armor: " .. tostring(classData.armor or LocalPlayer():GetMaxArmor()))
                            table.insert(details, "Weapons: " .. (istable(classData.weapons) and #classData.weapons > 0 and table.concat(classData.weapons, ", ") or "None"))
                            table.insert(details, "Model Scale: " .. tostring(classData.scale or 1))
                            table.insert(details, "Run Speed: " .. tostring(classData.runSpeed or lia.config.get("RunSpeed")))
                            table.insert(details, "Walk Speed: " .. tostring(classData.walkSpeed or lia.config.get("WalkSpeed")))
                            table.insert(details, "Jump Power: " .. tostring(classData.jumpPower or LocalPlayer():GetJumpPower()))
                            local blood = ({
                                [-1] = "No blood",
                                [0] = "Red blood",
                                [1] = "Yellow blood",
                                [2] = "Green-red blood",
                                [3] = "Sparks",
                                [4] = "Antlion yellow blood",
                                [5] = "Zombie green-red blood",
                                [6] = "Antlion worker bright green blood"
                            })[classData.bloodcolor] or "Red blood"

                            table.insert(details, "Blood Color: " .. blood)
                            if classData.requirements then table.insert(details, "Requirements: " .. table.concat(classData.requirements, ", ")) end
                            local itemPanel = vgui.Create("DPanel", body)
                            itemPanel:Dock(TOP)
                            itemPanel:DockMargin(10, 5, 10, 5)
                            itemPanel:SetTall(40 + #details * 24 + 8)
                            itemPanel.Paint = function(_, w, h)
                                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
                                draw.SimpleText("Class: " .. (classData.name or "Unnamed"), "liaMediumFont", 10, 12, color_white)
                                for i, line in ipairs(details) do
                                    draw.SimpleText(line, "liaSmallFont", 10, 40 + (i - 1) * 24, color_white)
                                end
                            end
                        end
                    end
                end
            end
        })
    end

    if client:hasPrivilege("Staff Permission — Access Module List") then
        table.insert(pages, {
            name = "Modules",
            drawFunc = function(panel)
                local char = client:getChar()
                if not char then
                    panel:Add("DLabel"):SetText("No character found!"):Dock(TOP)
                    return
                end

                local scroll = vgui.Create("DScrollPanel", panel)
                scroll:Dock(FILL)
                for _, moduleData in SortedPairs(lia.module.list) do
                    local hasDesc = moduleData.desc and moduleData.desc ~= ""
                    local height = hasDesc and 80 or 40
                    local modulePanel = vgui.Create("DPanel", scroll)
                    modulePanel:Dock(TOP)
                    modulePanel:DockMargin(10, 5, 10, 0)
                    modulePanel:SetTall(height)
                    modulePanel.Paint = function(_, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
                        draw.SimpleText(moduleData.name, "liaMediumFont", 20, 10, color_white)
                        draw.SimpleText(moduleData.version and tostring(moduleData.version) or "1.0", "liaSmallFont", w - 20, 45, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                        if hasDesc then draw.SimpleText(moduleData.desc, "liaSmallFont", 20, 45, color_white) end
                    end
                end
            end
        })
    end
end

function MODULE:CreateMenuButtons(tabs)
    tabs["Status"] = function(panel)
        panel.info = vgui.Create("liaCharInfo", panel)
        panel.info:setup()
        panel.info:SetAlpha(0)
        panel.info:AlphaTo(255, 0.5)
    end

    tabs["Information"] = function(panel)
        panel.sidebar = panel:Add("DScrollPanel")
        panel.sidebar:Dock(LEFT)
        panel.sidebar:SetWide(200)
        panel.sidebar:DockMargin(20, 20, 0, 20)
        panel.mainContent = panel:Add("DPanel")
        panel.mainContent:Dock(FILL)
        panel.mainContent:DockMargin(10, 10, 10, 10)
        local pages = {}
        hook.Run("BuildInformationMenu", pages)
        if not pages then return end
        local currentSelected = nil
        for _, pageInfo in ipairs(pages) do
            local btn = panel.sidebar:Add("liaMediumButton")
            btn:SetText(pageInfo.name)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 10)
            btn:SetTall(40)
            btn.DoClick = function()
                if IsValid(currentSelected) then currentSelected:SetSelected(false) end
                btn:SetSelected(true)
                currentSelected = btn
                panel.mainContent:Clear()
                pageInfo.drawFunc(panel.mainContent)
            end
        end
    end

    tabs["Settings"] = function(panel)
        panel.sidebar = panel:Add("DScrollPanel")
        panel.sidebar:Dock(LEFT)
        panel.sidebar:SetWide(200)
        panel.sidebar:DockMargin(20, 20, 0, 20)
        panel.mainContent = panel:Add("DPanel")
        panel.mainContent:Dock(FILL)
        panel.mainContent:DockMargin(10, 10, 10, 10)
        local pages = {}
        hook.Run("PopulateConfigurationTabs", pages)
        if not pages then return end
        local currentSelected = nil
        for _, pageInfo in ipairs(pages) do
            local btn = panel.sidebar:Add("liaMediumButton")
            btn:SetText(pageInfo.name)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 10)
            btn:SetTall(40)
            btn.DoClick = function()
                if IsValid(currentSelected) then currentSelected:SetSelected(false) end
                btn:SetSelected(true)
                currentSelected = btn
                panel.mainContent:Clear()
                pageInfo.drawFunc(panel.mainContent)
            end
        end

        if #pages > 0 then
            panel.mainContent:Clear()
            pages[1].drawFunc(panel.mainContent)
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

lia.keybind.add(KEY_I, "Open Inventory", function()
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab("inv")
end)