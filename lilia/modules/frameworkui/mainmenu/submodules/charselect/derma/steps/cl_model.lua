local PANEL = {}
function PANEL:Init()
    self.models = self:Add("DIconLayout")
    self.models:Dock(FILL)
    self.models:SetSpaceX(4)
    self.models:SetSpaceY(4)
    self.models:SetPaintBackground(false)
    self.models:SetStretchWidth(true)
    self.models:SetStretchHeight(true)
    self.models:StretchToParent(0, 0, 0, 0)
    self.slidePanel = {}
end

function PANEL:onDisplay()
    local oldChildren = self.models:GetChildren()
    self.models:InvalidateLayout(true)
    local faction = lia.faction.indices[self:getContext("faction")]
    if not faction then return end
    local function paintIcon(icon, w, h)
        self:paintIcon(icon, w, h)
    end

    for k, v in SortedPairs(faction.models) do
        local icon = self.models:Add("SpawnIcon")
        icon:SetSize(64, 128)
        icon:InvalidateLayout(true)
        icon.DoClick = function(icon) self:onModelSelected(icon) end
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
        if self:getContext("model") == k then self:onModelSelected(icon, true) end
    end

    self.models:Layout()
    self.models:InvalidateLayout()
    for _, child in pairs(oldChildren) do
        child:Remove()
    end
end

function PANEL:paintIcon(icon, w, h)
    if self:getContext("model") ~= icon.index then return end
    local color = lia.config.Color
    surface.SetDrawColor(color.r, color.g, color.b, 200)
    local i2
    for i = 1, 3 do
        i2 = i * 2
        surface.DrawOutlinedRect(i, i, w - i2, h - i2)
    end
end

function PANEL:onModelSelected(icon, noSound)
    self:setContext("model", icon.index or 1)
    if not noSound then lia.gui.character:clickSound() end
    self:updateModelPanel()
    self:updateSliders()
end

function PANEL:shouldSkip()
    local faction = lia.faction.indices[self:getContext("faction")]
    return faction and #faction.models == 1 or false
end

local function createSlider(parent, text, min, max, value, onValueChanged)
    local slider = vgui.Create("DNumSlider", parent)
    slider:Dock(TOP)
    slider:DockMargin(5, 0, 5, 5)
    slider:SetText(text)
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetValue(value)
    slider:SetDecimals(0)
    slider.Label:SetTextColor(color_white)
    function slider:OnValueChanged(newValue)
        onValueChanged(math.Round(newValue))
    end
    return slider
end

function PANEL:updateSliders()
    if lia.gui.charCreate.model then
        if self.slidePanel.used then
            self.slidePanel.used = nil
            self.slidePanel:Remove()
        end

        local entity = lia.gui.charCreate.model:GetEntity()
        if entity then
            local slidePanel = lia.gui.charCreate:Add("DPanel")
            slidePanel:SetPos(ScrW() - ScrW() * 0.45 - 20, ScrH() * 0.05)
            slidePanel:SetSize(ScrW() * 0.2, ScrH() * 0.3)
            slidePanel:SetPaintBackground(true)
            slidePanel:SetBackgroundColor(Color(0, 0, 0, 200))
            if MainMenu.CanSelectBodygroups then
                local groups = {}
                for _, v in pairs(entity:GetBodyGroups()) do
                    if v.id == 0 then continue end
                    createSlider(slidePanel, "  " .. string.gsub(v.name, "^.", string.upper), 0, v.num, groups[v.id] or 0, function(value)
                        groups[v.id] = value
                        PANEL:setContext("groups", groups)
                        PANEL:onGroups()
                    end)
                end
            end

            if MainMenu.CanSelectSkins and entity:SkinCount() > 1 then
                createSlider(slidePanel, "  Skin", 0, entity:SkinCount() - 1, 0, function(value)
                    PANEL:setContext("skin", value)
                    PANEL:onGroups()
                end)
            end

            slidePanel:InvalidateLayout(true)
            slidePanel:SizeToChildren(false, true)
            self.slidePanel = slidePanel
            self.slidePanel.used = true
        end
    end
end

function PANEL:onGroups()
    self:updateModelPanel()
end

function PANEL:onSkip()
    self:setContext("model", 1)
end

function PANEL:Think()
    if self.slidePanel and self.slidePanel.GetAlpha then
        if self:GetAlpha() < 100 then
            self.slidePanel:SetAlpha(0)
        else
            self.slidePanel:SetAlpha(255)
        end
    end
end

vgui.Register("liaCharacterModel", PANEL, "liaCharacterCreateStep")