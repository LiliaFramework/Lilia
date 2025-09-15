local PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    local w, h = self:GetParent():GetSize()
    self:SetSize(w, h)
    self.sidebar = self:Add("DScrollPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(200)
    self.sidebar:DockMargin(20, 20, 0, 20)
    self.mainContent = self:Add("DScrollPanel")
    self.mainContent:Dock(FILL)
    self.mainContent:DockMargin(10, 10, 10, 10)
    self.tabList = {}
    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    local list = {}
    for _, cl in pairs(lia.class.list) do
        if cl.faction == client:Team() then list[#list + 1] = cl end
    end

    table.sort(list, function(a, b) return L(a.name or "") < L(b.name or "") end)
    self.sidebar:Clear()
    self.tabList = {}
    for _, cl in ipairs(list) do
        local canBe = lia.class.canBe(LocalPlayer(), cl.index)
        local btn = self.sidebar:Add("liaMediumButton")
        btn:SetText(cl.name and L(cl.name) or L("unnamed"))
        btn:SetTall(50)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 10, 20)
        btn.DoClick = function()
            for _, b in ipairs(self.tabList) do
                b:SetSelected(b == btn)
            end

            self:populateClassDetails(cl, canBe)
        end

        self.tabList[#self.tabList + 1] = btn
    end
end

function PANEL:populateClassDetails(cl, canBe)
    self.mainContent:Clear()
    local container = self.mainContent:Add("DPanel")
    container:Dock(TOP)
    container:DockMargin(10, 10, 10, 10)
    container:SetTall(800)
    if cl.logo then
        local img = container:Add("DImage")
        img:SetImage(cl.logo)
        img:SetScaledSize(128, 128)
        img.Think = function() img:SetPos(container:GetWide() - img:GetWide() - 10, 10) end
    end

    self:createModelPanel(container, cl)
    self:addClassDetails(container, cl)
    self:addJoinButton(container, cl, canBe)
end

function PANEL:createModelPanel(parent, cl)
    local sizeX, sizeY = 300, 600
    local panel = parent:Add("liaModelPanel")
    panel:SetScaledSize(sizeX, sizeY)
    panel:SetFOV(35)
    local function getModel(mdl)
        if isstring(mdl) then return mdl end
        if istable(mdl) then
            local models = {}
            local function gather(tbl)
                for _, v in pairs(tbl) do
                    if isstring(v) then
                        models[#models + 1] = v
                    elseif istable(v) then
                        gather(v)
                    end
                end
            end

            gather(mdl)
            if #models > 0 then return models[math.random(#models)] end
        end
    end

    local model = getModel(cl.model) or LocalPlayer():GetModel()
    panel:SetModel(model)
    panel.rotationAngle = 45
    local ent = panel.Entity
    ent:SetSkin(cl.skin or 0)
    for _, bg in ipairs(cl.bodyGroups or {}) do
        ent:SetBodygroup(bg.id, bg.value or 0)
    end

    for i, mat in ipairs(cl.subMaterials or {}) do
        ent:SetSubMaterial(i - 1, mat)
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

function PANEL:addClassDetails(parent, cl)
    local client = LocalPlayer()
    local maxH, maxA, maxJ = client:GetMaxHealth(), client:GetMaxArmor(), client:GetJumpPower()
    local run, walk = lia.config.get("RunSpeed"), lia.config.get("WalkSpeed")
    local function add(text)
        local lbl = parent:Add("DLabel")
        lbl:SetFont("liaMediumFont")
        lbl:SetText(text)
        lbl:SetTextColor(color_white)
        lbl:SetWrap(true)
        lbl:Dock(TOP)
        lbl:DockMargin(10, 5, 10, 0)
    end

    add(L("name") .. ": " .. (cl.name and L(cl.name) or L("unnamed")))
    add(L("description") .. ": " .. (cl.desc and L(cl.desc) or L("noDesc")))
    local facName = team.GetName(cl.faction)
    add(L("faction") .. ": " .. (facName and L(facName) or L("none")))
    add(L("isDefault") .. ": " .. (cl.isDefault and L("yes") or L("no")))
    add(L("baseHealth") .. ": " .. tostring(cl.health or maxH))
    add(L("baseArmor") .. ": " .. tostring(cl.armor or maxA))
    local weps = cl.weapons or {}
    add(L("weapons") .. ": " .. (#weps > 0 and table.concat(weps, ", ") or L("none")))
    add(L("modelScale") .. ": " .. tostring(cl.scale or 1))
    local rs = cl.runSpeedMultiplier and math.Round(run * cl.runSpeed) or cl.runSpeed or run
    add(L("runSpeed") .. ": " .. tostring(rs))
    local ws = cl.walkSpeedMultiplier and math.Round(walk * cl.walkSpeed) or cl.walkSpeed or walk
    add(L("walkSpeed") .. ": " .. tostring(ws))
    local jp = cl.jumpPowerMultiplier and math.Round(maxJ * cl.jumpPower) or cl.jumpPower or maxJ
    add(L("jumpPower") .. ": " .. tostring(jp))
    local bloodMap = {
        [-1] = L("bloodNo"),
        [0] = L("bloodRed"),
        [1] = L("bloodYellow"),
        [2] = L("bloodGreenRed"),
        [3] = L("bloodSparks"),
        [4] = L("bloodAntlion"),
        [5] = L("bloodZombie"),
        [6] = L("bloodAntlionBright")
    }

    add(L("bloodColor") .. ": " .. (bloodMap[cl.bloodcolor] or L("bloodRed")))
    if cl.requirements then
        local req
        if istable(cl.requirements) then
            local reqs = {}
            for _, v in ipairs(cl.requirements) do
                reqs[#reqs + 1] = L(v)
            end

            req = table.concat(reqs, ", ")
        else
            req = L(tostring(cl.requirements))
        end

        add(L("requirements") .. ": " .. req)
    end
end

function PANEL:addJoinButton(parent, cl, canBe)
    local isCurrent = LocalPlayer():getChar() and LocalPlayer():getChar():getClass() == cl.index
    local btn = parent:Add("liaMediumButton")
    btn:SetText(isCurrent and L("alreadyInClass") or canBe and L("joinClass") or L("classRequirementsNotMet"))
    btn:SetTall(40)
    local col = lia.color.ReturnMainAdjustedColors().text
    btn:SetTextColor(col)
    btn:SetFont("liaMediumFont")
    btn:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    btn:SetContentAlignment(5)
    btn:Dock(BOTTOM)
    btn:DockMargin(10, 10, 10, 10)
    btn:SetDisabled(isCurrent or not canBe)
    btn.DoClick = function()
        if canBe and not isCurrent then
            lia.command.send("beclass", cl.index)
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
