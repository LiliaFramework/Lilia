local MODULE = MODULE
local PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    self:SetSize(self:GetParent():GetSize())
    self.sidebar = self:Add("DPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(200)
    self.sidebar.Paint = function() end
    self.sidebar:DockMargin(20, 20, 0, 20)
    self.mainContent = self:Add("DScrollPanel")
    self.mainContent:Dock(FILL)
    self.mainContent:DockMargin(10, 10, 10, 10)
    self.mainContent.Paint = function() end
    self.tabList = {}
    self.activeTab = nil
    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    self.sidebar:Clear()
    self.tabList = {}
    local sortedClasses = {}
    for _, classData in pairs(lia.class.list) do
        if classData.faction == client:Team() then table.insert(sortedClasses, classData) end
    end

    table.sort(sortedClasses, function(a, b) return a.name < b.name end)
    for _, classData in ipairs(sortedClasses) do
        local canBe, _ = lia.class.canBe(client, classData.index)
        local tabName = classData.name
        local button = self.sidebar:Add("DButton")
        button:SetText(tabName)
        button:SetTextColor(color_white)
        button:SetFont("liaMediumFont")
        button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
        button:SetContentAlignment(5)
        button:SetTall(50)
        button:Dock(TOP)
        button:DockMargin(0, 0, 10, 20)
        button.isAvailable = canBe
        button.Paint = function(btn, w, h)
            if self.activeTab == btn then
                surface.SetDrawColor(MODULE.MenuColors.accent)
            elseif btn:IsHovered() then
                surface.SetDrawColor(btn.isAvailable and MODULE.MenuColors.hover or Color(100, 100, 100))
            else
                surface.SetDrawColor(btn.isAvailable and MODULE.MenuColors.sidebar or Color(80, 80, 80))
            end

            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(MODULE.MenuColors.border)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        button.DoClick = function()
            self.activeTab = button
            for _, btn in pairs(self.tabList) do
                btn.active = false
            end

            button.active = true
            self:populateClassDetails(classData, canBe)
        end

        self.tabList[tabName] = button
    end
end

function PANEL:populateClassDetails(classData, canBe)
    self.mainContent:Clear()
    local detailsPanel = self.mainContent:Add("DPanel")
    detailsPanel:SetTall(800)
    detailsPanel:Dock(TOP)
    detailsPanel:DockMargin(10, 10, 10, 10)
    detailsPanel.Paint = function(_, w, h)
        surface.SetDrawColor(30, 30, 30, 200)
        surface.DrawRect(0, 0, w, h)
    end

    if classData.logo then
        local logo = detailsPanel:Add("DImage")
        logo:SetImage(classData.logo)
        logo:SetSize(128, 128)
        logo:SetPos(detailsPanel:GetWide() - 138, 10)
        logo.Think = function() logo:SetPos(detailsPanel:GetWide() - logo:GetWide() - 10, 10) end
    end

    if classData.model then
        local modelPanel = detailsPanel:Add("liaModelPanel")
        modelPanel:SetSize(300, 600)
        modelPanel:SetFOV(35)
        modelPanel:SetModel(classData.model)
        modelPanel:SetPos(150, 10)
        modelPanel.rotationAngle = 45
        modelPanel.rotationSpeed = 0.5
        modelPanel.Entity:SetSkin(classData.skin or 0)
        for _, v in ipairs(classData.bodyGroups or {}) do
            modelPanel.Entity:SetBodygroup(v.id, v.value or 0)
        end

        local ent = modelPanel.Entity
        if ent and IsValid(ent) then
            local mats = classData.subMaterials or {}
            for k, v in pairs(mats) do
                ent:SetSubMaterial(k - 1, v)
            end
        end

        modelPanel.Think = function()
            if IsValid(modelPanel) and IsValid(modelPanel.Entity) then
                modelPanel:SetPos(detailsPanel:GetWide() - modelPanel:GetWide() - 10, 100)
                local rotateLeft = input.IsKeyDown(KEY_A)
                local rotateRight = input.IsKeyDown(KEY_D)
                if rotateLeft then
                    modelPanel.rotationAngle = (modelPanel.rotationAngle or 0) - 0.5
                elseif rotateRight then
                    modelPanel.rotationAngle = (modelPanel.rotationAngle or 0) + 0.5
                end

                modelPanel.Entity:SetAngles(Angle(0, modelPanel.rotationAngle or 0, 0))
            end
        end
    end

    local function addDetail(labelText)
        local label = detailsPanel:Add("DLabel")
        label:SetText(labelText)
        label:SetFont("liaMediumFont")
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetTextColor(color_white)
        label:Dock(TOP)
        label:DockMargin(10, 5, 10, 0)
        return label
    end

    addDetail("Name: " .. (classData.name or "N/A"))
    addDetail("Description: " .. (classData.desc or "No description available."))
    addDetail("Faction: " .. (team.GetName(classData.faction) or "None"))
    addDetail("Is Default: " .. (classData.isDefault and "Yes" or "No"))
    addDetail("Base Health: " .. tostring(classData.health or "N/A"))
    addDetail("Base Armor: " .. tostring(classData.armor or "N/A"))
    local weapons = classData.weapons or {}
    local weaponsText = "Weapons: "
    if istable(weapons) and #weapons > 0 then
        weaponsText = weaponsText .. table.concat(weapons, ", ")
    else
        weaponsText = weaponsText .. "N/A"
    end

    addDetail(weaponsText)
    addDetail("Model Scale: " .. tostring(classData.scale or "N/A"))
    local runSpeedText = "Run Speed: "
    if classData.runSpeedMultiplier then
        runSpeedText = runSpeedText .. tostring(math.Round(lia.config.RunSpeed * classData.runSpeedMultiplier))
    elseif classData.runSpeed then
        runSpeedText = runSpeedText .. tostring(classData.runSpeed)
    else
        runSpeedText = runSpeedText .. tostring(lia.config.RunSpeed)
    end

    addDetail(runSpeedText)
    local walkSpeedText = "Walk Speed: "
    if classData.walkSpeedMultiplier then
        walkSpeedText = walkSpeedText .. tostring(math.Round(lia.config.WalkSpeed * classData.walkSpeedMultiplier))
    elseif classData.walkSpeed then
        walkSpeedText = walkSpeedText .. tostring(classData.walkSpeed)
    else
        walkSpeedText = walkSpeedText .. tostring(lia.config.WalkSpeed)
    end

    addDetail(walkSpeedText)
    local jumpPowerText = "Jump Power: "
    if classData.jumpPowerMultiplier then
        jumpPowerText = jumpPowerText .. tostring(math.Round(lia.config.JumpPower * classData.jumpPowerMultiplier))
    elseif classData.jumpPower then
        jumpPowerText = jumpPowerText .. tostring(classData.jumpPower)
    else
        jumpPowerText = jumpPowerText .. tostring(lia.config.JumpPower)
    end

    addDetail(jumpPowerText)
    local bloodColorMap = {
        [-1] = "No blood",
        [0] = "Normal red blood",
        [1] = "Yellow blood",
        [2] = "Green-red blood",
        [3] = "Sparks",
        [4] = "Antlion yellow blood",
        [5] = "Zombie green-red blood",
        [6] = "Antlion worker bright green blood"
    }

    local bloodColorText = bloodColorMap[classData.bloodcolor] or "N/A"
    addDetail("Blood Color: " .. bloodColorText)
    if canBe then
        local joinButton = detailsPanel:Add("DButton")
        joinButton:SetText("Join Class")
        joinButton:SetTall(40)
        joinButton:SetTextColor(color_white)
        joinButton:SetFont("liaMediumFont")
        joinButton:Dock(BOTTOM) -- Ensures the button is at the bottom of the panel
        joinButton:DockMargin(10, 10, 10, 10)
        -- Paint the button like the tabs
        joinButton.Paint = function(btn, w, h)
            if btn:IsHovered() then
                surface.SetDrawColor(MODULE.MenuColors.hover)
            else
                surface.SetDrawColor(MODULE.MenuColors.sidebar)
            end

            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(MODULE.MenuColors.border)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        joinButton.DoClick = function() lia.command.send("beclass", classData.index) end
    end
end

vgui.Register("liaClasses", PANEL, "EditablePanel")