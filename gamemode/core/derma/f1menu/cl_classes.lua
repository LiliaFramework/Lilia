local PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    local parent = self:GetParent()
    local w, h = parent:GetSize()
    self:SetSize(w, h)
    local sidebar = self:Add("DScrollPanel")
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar:DockMargin(20, 20, 0, 20)
    self.sidebar = sidebar
    local mainContent = self:Add("DScrollPanel")
    mainContent:Dock(FILL)
    mainContent:DockMargin(10, 10, 10, 10)
    self.mainContent = mainContent
    self.tabList = {}
    self.activeTab = nil
    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    local classList = lia.class.list
    local canBeFunc = lia.class.canBe
    local sidebar = self.sidebar
    sidebar:Clear()
    self.tabList = {}
    local sorted = {}
    for _, classData in pairs(classList) do
        if classData.faction == client:Team() then sorted[#sorted + 1] = classData end
    end

    table.sort(sorted, function(a, b) return a.name < b.name end)
    for _, classData in ipairs(sorted) do
        local canBe = canBeFunc(client, classData.index)
        local btn = self:createClassButton(classData, canBe)
        self.tabList[classData.name] = btn
    end
end

function PANEL:createClassButton(classData, canBe)
    local sidebar = self.sidebar
    local menuColors = lia.color.ReturnMainAdjustedColors()
    local textColor = menuColors.text
    local fontName = "liaMediumFont"
    local shadowClr = Color(0, 0, 0, 100)
    local btn = sidebar:Add("DButton")
    btn:SetText(classData.name)
    btn:SetTextColor(textColor)
    btn:SetFont(fontName)
    btn:SetExpensiveShadow(1, shadowClr)
    btn:SetContentAlignment(5)
    btn:SetTall(50)
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 10, 20)
    btn.text_color = textColor
    btn.Paint = function(b, w, h)
        if b:IsHovered() then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, h - 4, underlineWidth, 2)
        end

        if self.activeTab == b then
            surface.SetDrawColor(255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    btn.DoClick = function()
        self.activeTab = btn
        self:populateClassDetails(classData, canBe)
    end
    return btn
end

function PANEL:populateClassDetails(classData, canBe)
    local mainContent = self.mainContent
    mainContent:Clear()
    local panel = mainContent:Add("DPanel")
    panel:Dock(TOP)
    panel:DockMargin(10, 10, 10, 10)
    panel:SetTall(800)
    if classData.logo then
        local logo = panel:Add("DImage")
        logo:SetImage(classData.logo)
        logo:SetSize(128, 128)
        logo:SetPos(panel:GetWide() - logo:GetWide() - 10, 10)
        logo.Think = function() logo:SetPos(panel:GetWide() - logo:GetWide() - 10, 10) end
    end

    self:createModelPanel(panel, classData)
    self:addClassDetails(panel, classData)
    self:addJoinButton(panel, classData, canBe)
end

function PANEL:createModelPanel(parent, classData)
    local client = LocalPlayer()
    local fov, sizeX, sizeY = 35, 300, 600
    local modelList = classData.model
    local panel = parent:Add("liaModelPanel")
    panel:SetSize(sizeX, sizeY)
    panel:SetFOV(fov)
    local model = modelList
    if istable(modelList) then model = modelList[math.random(#modelList)] end
    panel:SetModel(model or client:GetModel())
    panel:SetPos(150, 10)
    panel.rotationAngle = 45
    local ent = panel.Entity
    ent:SetSkin(classData.skin or 0)
    for _, bg in ipairs(classData.bodyGroups or {}) do
        ent:SetBodygroup(bg.id, bg.value or 0)
    end

    for idx, subM in ipairs(classData.subMaterials or {}) do
        ent:SetSubMaterial(idx - 1, subM)
    end

    panel.Think = function()
        if IsValid(ent) then
            panel:SetPos(parent:GetWide() - sizeX - 10, 100)
            if input.IsKeyDown(KEY_A) then
                panel.rotationAngle = panel.rotationAngle - 0.5
            elseif input.IsKeyDown(KEY_D) then
                panel.rotationAngle = panel.rotationAngle + 0.5
            end

            ent:SetAngles(Angle(0, panel.rotationAngle, 0))
        end
    end
end

function PANEL:addClassDetails(detailsPanel, classData)
    local client = LocalPlayer()
    local config = lia.config
    local maxHealth, maxArmor, jumpPower = client:GetMaxHealth(), client:GetMaxArmor(), client:GetJumpPower()
    local runSpeed, walkSpeed = config.get("RunSpeed"), config.get("WalkSpeed")
    local function addDetail(text)
        local label = detailsPanel:Add("DLabel")
        label:SetFont("liaMediumFont")
        label:SetText(text)
        label:SetTextColor(color_white)
        label:SetWrap(true)
        label:Dock(TOP)
        label:SetAutoStretchVertical(true)
        label:DockMargin(10, 5, 10, 0)
    end

    addDetail("Name: " .. (classData.name or "Unnamed"))
    addDetail("Description: " .. (classData.desc or "No description available."))
    addDetail("Faction: " .. (team.GetName(classData.faction) or "None"))
    addDetail("Is Default: " .. (classData.isDefault and "Yes" or "No"))
    addDetail("Base Health: " .. tostring(classData.health or maxHealth))
    addDetail("Base Armor: " .. tostring(classData.armor or maxArmor))
    local weapons = classData.weapons or {}
    local weaponsText = #weapons > 0 and table.concat(weapons, ", ") or "None"
    addDetail(L("weapons") .. ": " .. weaponsText)
    addDetail("Model Scale: " .. tostring(classData.scale or 1))
    local rs = classData.runSpeedMultiplier and math.Round(runSpeed * (classData.runSpeed or 1)) or classData.runSpeed or runSpeed
    addDetail("Run Speed: " .. tostring(rs))
    local ws = classData.walkSpeedMultiplier and math.Round(walkSpeed * (classData.walkSpeed or 1)) or classData.walkSpeed or walkSpeed
    addDetail("Walk Speed: " .. tostring(ws))
    local jp = classData.jumpPowerMultiplier and math.Round(jumpPower * (classData.jumpPower or 1)) or classData.jumpPower or jumpPower
    addDetail("Jump Power: " .. tostring(jp))
    local bloodMap = {
        [-1] = "No blood",
        [0] = "Red blood",
        [1] = "Yellow blood",
        [2] = "Green-red blood",
        [3] = "Sparks",
        [4] = "Antlion yellow blood",
        [5] = "Zombie green-red blood",
        [6] = "Antlion worker bright green blood"
    }

    addDetail("Blood Color: " .. (bloodMap[classData.bloodcolor] or "Red blood"))
    local req = classData.requirements
    if req then
        local reqText = istable(req) and table.concat(req, ", ") or tostring(req)
        addDetail("Requirements: " .. reqText)
    end
end

function PANEL:addJoinButton(detailsPanel, classData, canBe)
    local client = LocalPlayer()
    local isCurrent = client:getChar() and client:getChar():getClass() == classData.index
    local btn = detailsPanel:Add("DButton")
    local text = isCurrent and "You are already in this class" or canBe and "Join Class" or "You do not meet the class requirements or this class isn't default."
    btn:SetText(text)
    btn:SetTall(40)
    local menuColors = lia.color.ReturnMainAdjustedColors()
    btn:SetTextColor(menuColors.text)
    btn:SetFont("liaMediumFont")
    btn:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    btn:SetContentAlignment(5)
    btn:Dock(BOTTOM)
    btn:DockMargin(10, 10, 10, 10)
    btn.text_color = menuColors.text
    btn:SetDisabled(isCurrent or not canBe)
    btn.DoClick = function()
        if canBe and not isCurrent then
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