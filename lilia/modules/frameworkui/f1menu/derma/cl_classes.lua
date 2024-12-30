local PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    self:SetSize(self:GetParent():GetSize())
    self.sidebar = self:Add("DScrollPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(200)
    self.sidebar:DockMargin(20, 20, 0, 20)
    self.sidebar.Paint = function() end
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
        local canBe = lia.class.canBe(client, classData.index)
        local button = self:createClassButton(classData, canBe)
        self.tabList[classData.name] = button
    end
end

function PANEL:createClassButton(classData, canBe)
    local MenuColors = lia.color.ReturnMainAdjustedColors()
    local button = self.sidebar:Add("DButton")
    button:SetText(classData.name)
    button:SetTextColor(MenuColors.text)
    button:SetFont("liaMediumFont")
    button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    button:SetContentAlignment(5)
    button:SetTall(50)
    button:Dock(TOP)
    button:DockMargin(0, 0, 10, 20)
    button.text_color = MenuColors.text
    button.Paint = function(btn, w, h)
        local hovered = btn:IsHovered()
        if hovered then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            local underlineY = h - 4
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end

        if self.activeTab == btn then
            surface.SetDrawColor(color_white)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    button.DoClick = function()
        self.activeTab = button
        self:populateClassDetails(classData, canBe)
    end
    return button
end

function PANEL:populateClassDetails(classData, canBe)
    self.mainContent:Clear()
    local detailsPanel = self.mainContent:Add("DPanel")
    detailsPanel:SetTall(800)
    detailsPanel:Dock(TOP)
    detailsPanel:DockMargin(10, 10, 10, 10)
    detailsPanel.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(120, 120, 120, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    if classData.logo then
        local logo = detailsPanel:Add("DImage")
        logo:SetImage(classData.logo)
        logo:SetSize(128, 128)
        logo:SetPos(detailsPanel:GetWide() - 138, 10)
        logo.Think = function() logo:SetPos(detailsPanel:GetWide() - logo:GetWide() - 10, 10) end
    end

    self:createModelPanel(detailsPanel, classData)
    self:addClassDetails(detailsPanel, classData)
    self:addJoinButton(detailsPanel, classData, canBe)
end

function PANEL:createModelPanel(parent, classData)
    local client = LocalPlayer()
    local modelPanel = parent:Add("liaModelPanel")
    modelPanel:SetSize(300, 600)
    modelPanel:SetFOV(35)
    modelPanel:SetModel(classData.model or client:GetModel())
    modelPanel:SetPos(150, 10)
    modelPanel.rotationAngle = 45
    modelPanel.Entity:SetSkin(classData.skin or 0)
    for _, bodyGroup in ipairs(classData.bodyGroups or {}) do
        modelPanel.Entity:SetBodygroup(bodyGroup.id, bodyGroup.value or 0)
    end

    local ent = modelPanel.Entity
    if IsValid(ent) then
        for k, v in pairs(classData.subMaterials or {}) do
            ent:SetSubMaterial(k - 1, v)
        end
    end

    modelPanel.Think = function()
        if IsValid(modelPanel.Entity) then
            modelPanel:SetPos(parent:GetWide() - modelPanel:GetWide() - 10, 100)
            if input.IsKeyDown(KEY_A) then
                modelPanel.rotationAngle = (modelPanel.rotationAngle or 0) - 0.5
            elseif input.IsKeyDown(KEY_D) then
                modelPanel.rotationAngle = (modelPanel.rotationAngle or 0) + 0.5
            end

            modelPanel.Entity:SetAngles(Angle(0, modelPanel.rotationAngle or 0, 0))
        end
    end
end

function PANEL:addClassDetails(detailsPanel, classData)
    local client = LocalPlayer()
    local function addDetail(text)
        local label = detailsPanel:Add("DLabel")
        label:SetText(text)
        label:SetFont("liaMediumFont")
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetTextColor(color_white)
        label:Dock(TOP)
        label:DockMargin(10, 5, 10, 0)
    end

    addDetail("Name: " .. (classData.name or "Unnamed"))
    addDetail("Description: " .. (classData.desc or "No description available."))
    addDetail("Faction: " .. (team.GetName(classData.faction) or "None"))
    addDetail("Is Default: " .. (classData.isDefault and "Yes" or "No"))
    addDetail("Base Health: " .. tostring(classData.health or client:GetMaxHealth()))
    addDetail("Base Armor: " .. tostring(classData.armor or client:GetMaxArmor()))
    local weapons = classData.weapons or {}
    local weaponsText = "Weapons: "
    if istable(weapons) and #weapons > 0 then
        weaponsText = weaponsText .. table.concat(weapons, ", ")
    else
        weaponsText = weaponsText .. "None"
    end

    addDetail(weaponsText)
    addDetail("Model Scale: " .. tostring(classData.scale or "1"))
    local runSpeed = lia.config.RunSpeed
    if classData.runSpeedMultiplier then
        runSpeed = math.Round(runSpeed * (classData.runSpeed or 1))
    elseif classData.runSpeed then
        runSpeed = classData.runSpeed
    end

    addDetail("Run Speed: " .. tostring(runSpeed))
    local walkSpeed = lia.config.WalkSpeed
    if classData.walkSpeedMultiplier then
        walkSpeed = math.Round(walkSpeed * (classData.walkSpeed or 1))
    elseif classData.walkSpeed then
        walkSpeed = classData.walkSpeed
    end

    addDetail("Walk Speed: " .. tostring(walkSpeed))
    local jumpPower = client:GetJumpPower()
    if classData.jumpPowerMultiplier then
        jumpPower = math.Round(jumpPower * (classData.jumpPower or 1))
    elseif classData.jumpPower then
        jumpPower = classData.jumpPower
    end

    addDetail("Jump Power: " .. tostring(jumpPower))
    local bloodColorMap = {
        [-1] = "No blood",
        [0] = "Red blood",
        [1] = "Yellow blood",
        [2] = "Green-red blood",
        [3] = "Sparks",
        [4] = "Antlion yellow blood",
        [5] = "Zombie green-red blood",
        [6] = "Antlion worker bright green blood"
    }

    local bloodColorText = bloodColorMap[classData.bloodcolor] or "Red blood"
    addDetail("Blood Color: " .. bloodColorText)
    if classData.requirements then
        addDetail("Requirements: " .. table.concat(classData.requirements, ", "))
    else
        addDetail("Requirements: Not specified")
    end
end

function PANEL:addJoinButton(detailsPanel, classData, canBe)
    local MenuColors = lia.color.ReturnMainAdjustedColors()
    local button = detailsPanel:Add("DButton")
    button:SetText(canBe and "Join Class" or "Requirements not met")
    button:SetTall(40)
    button:SetTextColor(MenuColors.text)
    button:SetFont("liaMediumFont")
    button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    button:SetContentAlignment(5)
    button:Dock(BOTTOM)
    button:DockMargin(10, 10, 10, 10)
    button.text_color = MenuColors.text
    button:SetDisabled(not canBe)
    button.Paint = function(btn, w, h)
        local hovered = btn:IsHovered()
        if hovered and canBe then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            local underlineY = h - 4
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end

        surface.SetDrawColor(MenuColors.border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    button.DoClick = function()
        if canBe then
            lia.command.send("beclass", classData.index)
            timer.Simple(0.1, function()
                if IsValid(self) then
                    self:loadClasses()
                    self.mainContent:Clear()
                end
            end)
        end
    end
end

vgui.Register("liaClasses", PANEL, "EditablePanel")