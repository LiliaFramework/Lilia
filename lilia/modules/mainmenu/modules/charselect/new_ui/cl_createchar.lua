--------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------------------------
lia.config.CharClick = lia.config.CharClick
--------------------------------------------------------------------------------------------------------------------------
lia.config.CharWarning = lia.config.CharWarning
--------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    if IsValid(lia.gui.newCreateCharMenu) then
        lia.gui.newCreateCharMenu:Remove()
    end

    lia.gui.newCreateCharMenu = self
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, ScrH())
    self:MakePopup()
    self:MoveTo(0, 0, .8)
    self.context = {}
    AccessorFunc(self.context, 'faction', 'Faction')
    AccessorFunc(self.context, 'model', 'Model')
    AccessorFunc(self.context, 'name', 'Name')
    AccessorFunc(self.context, 'desc', 'Description')
    self.context:SetModel(1)
    self.slides = {}
    self.currentSlide = 1
    self.movingSlide = false
    self.right = self:Add('DImageButton')
    self.right:SetSize(20, 20)
    self.right:SetPos((ScrW() * .5) - 20 / 2 + 20, (ScrH() * .87) - 20 / 2)
    self.right:SetImage('mainmenu/arrow_right.png')
    self.right.Think = function()
        if self.currentSlide == #self.slides then
            self.right:SetDisabled(true)
            self.right:SetColor(Color(0, 0, 0, 0))
        else
            self.right:SetDisabled(false)
            self.right:SetColor(Color(255, 255, 255, 255))
        end
    end

    self.right.DoClick = function()
        if self.movingSlide then return end
        if self.currentSlide == #self.slides then return end
        self.movingSlide = true
        self.slides[self.currentSlide]:MoveTo(
            -ScrW(),
            (ScrH() * .5) - (ScrH() * .7) / 2,
            .3,
            0,
            -1,
            function(_, me)
                if me.Hidden then
                    me:Hidden()
                end
            end
        )

        if self.slides[self.currentSlide + 1].Setup then
            self.slides[self.currentSlide + 1]:Setup()
        end

        self.slides[self.currentSlide + 1]:MoveTo(
            (ScrW() * .5) - (ScrW() * .7) / 2,
            (ScrH() * .5) - (ScrH() * .7) / 2,
            .3,
            0,
            -1,
            function()
                self.movingSlide = false
                self.currentSlide = self.currentSlide + 1
            end
        )
    end

    self.left = self:Add('DImageButton')
    self.left:SetSize(20, 20)
    self.left:SetPos((ScrW() * .5) - 20 / 2 - 20, (ScrH() * .87) - 20 / 2)
    self.left:SetImage('mainmenu/arrow_left.png')
    self.left.Think = function()
        if self.currentSlide == 1 then
            self.left:SetDisabled(true)
            self.left:SetColor(Color(0, 0, 0, 0))
        else
            self.left:SetDisabled(false)
            self.left:SetColor(Color(255, 255, 255, 255))
        end
    end

    self.left.DoClick = function()
        if self.movingSlide then return end
        if self.currentSlide == 1 then return end
        self.movingSlide = true
        self.slides[self.currentSlide]:MoveTo(
            ScrW(),
            (ScrH() * .5) - (ScrH() * .7) / 2,
            .3,
            0,
            -1,
            function(_, me)
                if me.Hidden then
                    me:Hidden()
                end
            end
        )

        if self.slides[self.currentSlide - 1].Setup then
            self.slides[self.currentSlide - 1]:Setup()
        end

        self.slides[self.currentSlide - 1]:MoveTo(
            (ScrW() * .5) - (ScrW() * .7) / 2,
            (ScrH() * .5) - (ScrH() * .7) / 2,
            .3,
            0,
            -1,
            function()
                self.movingSlide = false
                self.currentSlide = self.currentSlide - 1
            end
        )
    end

    do
        local pnl = self:CreateSlide()
        pnl:SetX((ScrW() * .5) - (ScrW() * .7) / 2)
        pnl.Paint = function(_, w, h)
            draw.Text(
                {
                    text = 'Select a faction',
                    font = 'liaEgMainMenu',
                    pos = {w / 2, 0},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    color = color_white
                }
            )
        end

        pnl.Setup = function()
            pnl.faction = pnl:Add('DComboBox')
            pnl.faction:SetSize(pnl:GetWide() * .3, 35)
            pnl.faction:SetPos((pnl:GetWide() * .5) - (pnl:GetWide() * .3) / 2, (pnl:GetTall() * .5) - 35 / 2)
            pnl.faction:SetTextColor(color_white)
            pnl.faction:SetFont('liaCharButtonFont')
            pnl.faction.Paint = function(me, w, h)
                lia.util.drawBlur(me)
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawRect(0, 0, w, h)
            end

            pnl.faction.OnSelect = function(_, _, _, id)
                self.context:SetFaction(lia.faction.teams[id].index)
            end

            local first = true
            for id, _faction in SortedPairsByMemberValue(lia.faction.teams, 'name') do
                if not lia.faction.hasWhitelist(_faction.index) then continue end
                if self.context:GetFaction() then
                    first = false
                    pnl.faction:SetValue(L(lia.faction.get(self.context:GetFaction()).name))
                end

                pnl.faction:AddChoice(L(_faction.name), id, first)
                if first then
                    self.context:SetFaction(_faction.index)
                end

                first = false
            end
        end

        pnl.Hidden = function()
            if IsValid(pnl.faction) then
                pnl.faction:Remove()
            end
        end

        pnl:Setup()
    end

    do
        local realpanel = self
        local pnl = self:CreateSlide()
        pnl.Paint = function(_, w, h)
            draw.Text(
                {
                    text = 'Select a model',
                    font = 'liaEgMainMenu',
                    pos = {w / 2, 0},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    color = color_white
                }
            )
        end

        pnl.Setup = function()
            pnl.modelViewer = pnl:Add('liaModelPanel')
            pnl.modelViewer:SetWide(ScrW() * 0.25)
            pnl.modelViewer:Dock(LEFT)
            pnl.modelViewer:SetModel('models/error.mdl')
            pnl.modelViewer.oldSetModel = pnl.modelViewer.SetModel
            pnl.modelViewer.SetModel = function(model, ...)
                model:oldSetModel(...)
                model:fitFOV()
            end

            local sideMargin = 0
            if ScrW() > 1280 then
                sideMargin = ScrW() * 0.15
            elseif ScrW() > 720 then
                sideMargin = ScrW() * 0.075
            end

            function pnl.modelViewer:updateModel()
                local faction = lia.faction.indices[realpanel.context:GetFaction()]
                local modelInfo = faction.models[realpanel.context:GetModel() or 1]
                local model, skin, groups
                if istable(modelInfo) then
                    model, skin, groups = unpack(modelInfo)
                else
                    model, skin, groups = modelInfo, 0, {}
                end

                pnl.modelViewer:SetModel(model)
                local entity = pnl.modelViewer:GetEntity()
                if not IsValid(entity) then return end
                entity:SetSkin(skin)
                if istable(groups) then
                    for group, value in pairs(groups) do
                        entity:SetBodygroup(group, value)
                    end
                elseif isstring(groups) then
                    entity:SetBodyGroups(groups)
                end

                if faction.material then
                    entity:SetMaterial(faction.material)
                end
            end

            pnl.models = pnl:Add('DIconLayout')
            pnl.models:Dock(FILL)
            pnl.models:DockMargin(0, ScrH() * .1, 0, 0)
            pnl.models:SetSpaceX(4)
            pnl.models:SetSpaceY(4)
            pnl.models:SetPaintBackground(false)
            pnl.models:SetStretchWidth(true)
            pnl.models:SetStretchHeight(true)
            pnl.models:StretchToParent(0, 0, 0, 0)
            function pnl.models:onModelSelected(icon, noSound)
                realpanel.context:SetModel(icon.index or 1)
                pnl.modelViewer:updateModel()
            end

            function pnl.models:paintIcon(icon, w, h)
                if realpanel.context:GetModel() ~= icon.index then return end
                local color = lia.config.Color
                surface.SetDrawColor(color.r, color.g, color.b, 200)
                local i2
                for i = 1, 3 do
                    i2 = i * 2
                    surface.DrawOutlinedRect(i, i, w - i2, h - i2)
                end
            end

            function pnl.models:Setup()
                local oldChildren = pnl.models:GetChildren()
                pnl.models:InvalidateLayout(true)
                local faction = lia.faction.indices[realpanel.context:GetFaction()]
                if not faction then return end
                local function paintIcon(icon, w, h)
                    self:paintIcon(icon, w, h)
                end

                for k, v in SortedPairs(faction.models) do
                    local icon = pnl.models:Add('SpawnIcon')
                    icon:SetSize(64, 128)
                    icon:InvalidateLayout(true)
                    icon.DoClick = function(icon)
                        self:onModelSelected(icon)
                    end

                    icon.PaintOver = paintIcon
                    if isstring(v) then
                        icon:SetModel(v)
                        icon.model = v
                        icon.skin = 0
                        icon.bodyGroups = {}
                    else
                        icon:SetModel(v[1], v[2] or 0, v[3])
                        icon.model = v[1]
                        icon.skin = v[2] or 0
                        icon.bodyGroups = v[3]
                    end

                    icon.index = k
                    if realpanel.context:GetModel() == k then
                        self:onModelSelected(icon, true)
                    end
                end

                pnl.models:Layout()
                pnl.models:InvalidateLayout()
                for _, child in pairs(oldChildren) do
                    child:Remove()
                end
            end

            pnl.models:Setup()
        end

        pnl.Hidden = function()
            if IsValid(pnl.modelViewer) then
                pnl.modelViewer:Remove()
            end
        end
    end

    do
        local HIGHLIGHT = Color(255, 255, 255, 50)
        local realpanel = self
        local pnl = self:CreateSlide()
        pnl.Setup = function()
            pnl.secondPanel = pnl:Add('EditablePanel')
            pnl.secondPanel:SetSize(ScrW() * .5, ScrH() * .5)
            pnl.secondPanel:SetPos((pnl:GetWide() * .5) - (ScrW() * .5) / 2, (pnl:GetTall() * .5) - (ScrH() * .5) / 2)
            function pnl.secondPanel:paintTextEntry(w, h)
                lia.util.drawBlur(self)
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawRect(0, 0, w, h)
                self:DrawTextEntryText(color_white, HIGHLIGHT, HIGHLIGHT)
            end

            function pnl.secondPanel:addTextEntry(contextName)
                local entry = self:Add('DTextEntry')
                entry:Dock(TOP)
                entry:SetFont('liaCharButtonFont')
                entry.Paint = self.paintTextEntry
                entry:DockMargin(0, 4, 0, 16)
                entry.OnValueChange = function(_, value)
                    if contextName == 'Name' then
                        realpanel.context:SetName(value:Trim())
                    elseif contextName == 'Description' then
                        realpanel.context:SetDescription(value:Trim())
                    end
                end

                entry.contextName = contextName
                entry.OnKeyCodeTyped = function(name, keyCode)
                    if keyCode == KEY_TAB then
                        entry:onTabPressed()

                        return true
                    end
                end

                entry:SetUpdateOnType(true)

                return entry
            end

            function pnl.secondPanel:addLabel(text)
                local label = self:Add('DLabel')
                label:SetFont('liaCharButtonFont')
                label:SetText(L(text):upper())
                label:SetTextColor(color_white)
                label:SizeToContents()
                label:Dock(TOP)

                return label
            end

            pnl.nameLabel = pnl.secondPanel:addLabel('Name')
            pnl.nameLabel:SetZPos(0)
            pnl.name = pnl.secondPanel:addTextEntry('Name')
            pnl.name:SetTall(48)
            pnl.name.onTabPressed = function()
                pnl.desc:RequestFocus()
            end

            pnl.name:SetZPos(1)
            if realpanel.context:GetName() then
                pnl.name:SetValue(realpanel.context:GetName())
            end

            pnl.descLabel = pnl.secondPanel:addLabel('Description')
            pnl.descLabel:SetZPos(2)
            pnl.desc = pnl.secondPanel:addTextEntry('Description')
            pnl.desc:SetTall(pnl.name:GetTall() * 3)
            pnl.desc.onTabPressed = function()
                pnl.name:RequestFocus()
            end

            pnl.desc:SetMultiline(true)
            pnl.desc:SetZPos(3)
            if realpanel.context:GetDescription() then
                pnl.desc:SetValue(realpanel.context:GetDescription())
            end

            pnl.finish = pnl.secondPanel:Add('DButton')
            pnl.finish:SetSize(ScrW() * .2, ScrH() * .1)
            pnl.finish:SetPos((pnl.secondPanel:GetWide() * .5) - (ScrW() * .2) / 2, (pnl.secondPanel:GetTall() * .8) - (ScrH() * .1) / 2)
            pnl.finish:SetFont('liaCharButtonFont')
            pnl.finish:SetText('Finish')
            pnl.finish.Paint = nil
            pnl.finish.DoClick = function()
                if not realpanel.context:GetFaction() then return end
                if not realpanel.context:GetModel() then return end
                if not realpanel.context:GetName() then return end
                if not realpanel.context:GetDescription() then return end
                if self.bClosing then return end
                MainMenu:createCharacter(self.context):next(
                    function()
                        realpanel:Hide()
                        LocalPlayer():EmitSound(unpack(lia.config.CharClick))
                    end,
                    function()
                        LocalPlayer():EmitSound(unpack(lia.config.CharWarning))
                    end
                )
            end
        end

        pnl.Hidden = function()
            pnl.nameLabel:Remove()
            pnl.name:Remove()
            pnl.descLabel:Remove()
            pnl.desc:Remove()
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:CreateSlide()
    local pnl = self:Add('EditablePanel')
    pnl:SetSize(ScrW() * .7, ScrH() * .7)
    pnl:SetPos(ScrW(), (ScrH() * .5) - (ScrH() * .7) / 2)
    self.slides[#self.slides + 1] = pnl

    return pnl
end

--------------------------------------------------------------------------------------------------------------------------
local gradient = lia.util.getMaterial('gui/gradient_down')
function PANEL:Paint(w, h)
    surface.SetDrawColor(28, 28, 28)
    surface.DrawRect(0, 0, w, h)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:Hide()
    self:MoveTo(
        0,
        ScrH(),
        .8,
        0,
        -1,
        function()
            self:Remove()
        end
    )

    local panel = vgui.Create('liaNewCharacterMenu')
    panel:SetPos(0, -ScrH())
    panel:MoveTo(0, 0, .8)
    self.bClosing = true
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:OnKeyCodePressed(keyCode)
    if self.bClosing then return end
    if keyCode == KEY_SPACE then
        self:Hide()
    end
end

--------------------------------------------------------------------------------------------------------------------------
vgui.Register('liaNewCreateCharacterMenu', PANEL, 'EditablePanel')
--------------------------------------------------------------------------------------------------------------------------