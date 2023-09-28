--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
AccessorFunc(PANEL, "m_eTarget", "Target")
--------------------------------------------------------------------------------------------------------
local leftrotate, rightrotate = input.LookupBinding("+moveleft"), input.LookupBinding("+moveright")
--------------------------------------------------------------------------------------------------------
local leftinput, rightinput = input.GetKeyCode(leftrotate), input.GetKeyCode(rightrotate)
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetSize(ScrW() / 1.5, ScrH() / 1.5)
    self:Center()
    self:MakePopup()
    self:SetBackgroundBlur(true)
    self:SetTitle("Bodygroup Menu")
    local frameWidth = self:GetSize()
    self.model = self:Add("liaModelPanel")
    self.model:Dock(LEFT)
    self.model:SetWide(frameWidth / 2)
    self.model.PaintOver = function(this, w, h)
        local str = "[%s] Rotate Left | [%s] Rotate Right"
        str = str:format(leftrotate:upper(), rightrotate:upper())
        lia.util.drawText(str, w / 2, h - 16, color_white, 1, 1)
    end

    self.side = self:Add("Panel")
    self.side:Dock(RIGHT)
    self.side:DockPadding(5, 5, 5, 5)
    self.side:SetWide(frameWidth / 2)
    self.skinSelector = self.side:Add("DNumSlider")
    self.skinSelector:Dock(TOP)
    self.skinSelector:DockMargin(0, 0, 0, 5)
    self.skinSelector:SetText("Skin")
    self.skinSelector:SetMin(0)
    self.skinSelector:SetDecimals(0)
    self.skinSelector:SetVisible(false)
    self.skinSelector.OnValueChanged = function(this, value)
        local model = self.model.Entity
        if IsValid(model) then
            model:SetSkin(math.Round(value))
        end
    end

    local defaultColor = lia.config.Color
    local hue, saturation, value = ColorToHSV(defaultColor)
    saturation = saturation * 0.25
    local finalOutlineColor = HSVToColor(hue, saturation, value)
    self.finish = self.side:Add("DButton")
    self.finish:Dock(BOTTOM)
    self.finish:DockMargin(0, 5, 0, 0)
    self.finish:SetTall(24)
    self.finish:SetText("Finish")
    self.finish:SetFont("liaMediumFont")
    self.finish.Paint = function(panel, w, h)
        surface.SetDrawColor(defaultColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(finalOutlineColor)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    self.finish.DoClick = function(this)
        local model = self.model.Entity
        if IsValid(model) then
            local skin = model:GetSkin()
            local groups = {}
            for i = 0, model:GetNumBodyGroups() - 1 do
                groups[i] = model:GetBodygroup(i)
            end

            local makeChange = true
            if self.originalSkin == skin then
                makeChange = false
            end

            if not makeChange then
                for i = 0, model:GetNumBodyGroups() - 1 do
                    if self.originalBodygroups[i] ~= groups[i] then
                        makeChange = true
                        break
                    end
                end
            end

            if makeChange then
                net.Start("BodygrouperMenu")
                net.WriteEntity(self:GetTarget())
                net.WriteUInt(skin, 10)
                net.WriteTable(groups)
                net.SendToServer()
            end
        end
    end

    self.scroll = self.side:Add("DScrollPanel")
    self.scroll:Dock(FILL)
end
--------------------------------------------------------------------------------------------------------
function PANEL:OnClose()
    net.Start("BodygrouperMenuClose")
    net.SendToServer()
end
--------------------------------------------------------------------------------------------------------
function PANEL:PopulateOptions()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    self.scroll:Clear()
    if target:SkinCount() > 1 then
        self.skinSelector:SetMax(target:SkinCount() - 1)
        self.skinSelector:SetValue(target:GetSkin())
        self.skinSelector:SetVisible(true)
    end

    if target:GetNumBodyGroups() > 1 then
        self.category = self.scroll:Add("DCollapsibleCategory")
        self.category:Dock(TOP)
        self.category:SetLabel("Bodygroups")
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) <= 1 then continue end
            local group = target:GetBodygroup(i)
            local model = self.model.Entity
            local panel = vgui.Create("DNumSlider", self.category)
            panel:Dock(TOP)
            panel:DockMargin(5, 0, 5, 5)
            panel:SetText(target:GetBodygroupName(i):sub(1, 1):upper() .. target:GetBodygroupName(i):sub(2))
            panel:SetMin(0)
            panel:SetMax(target:GetBodygroupCount(i) - 1)
            panel:SetDecimals(0)
            panel:SetValue(group)
            panel.OnValueChanged = function(this, value)
                model:SetBodygroup(i, math.Round(value))
            end
        end
    else
        if not self.skinSelector:IsVisible() then
            self.finish:Remove()
            local info = self.side:Add("DLabel")
            info:Dock(TOP)
            info:SetText("This model has no manipulatable bodygroups or skins!")
            info:SetFont("liaMediumFont")
            info:SetTextColor(color_white)
            info:SetContentAlignment(5)
            info:SizeToContents()
        end
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:SetTarget(target)
    self.m_eTarget = target
    self.model:SetModel(target:GetModel())
    self.model:fitFOV()
    local ent = self.model.Entity
    if IsValid(ent) then
        self.originalSkin = target:GetSkin()
        ent:SetSkin(target:GetSkin())
        self.originalBodygroups = {}
        for i = 0, ent:GetNumBodyGroups() - 1 do
            self.originalBodygroups[i] = target:GetBodygroup(i)
            ent:SetBodygroup(i, target:GetBodygroup(i))
        end
    end

    self:PopulateOptions()
end
--------------------------------------------------------------------------------------------------------
local function RotatePointAroundPivot(point, pivot, angles)
    local newpoint = point - pivot
    newpoint:Rotate(angles)
    newpoint = newpoint + pivot

    return newpoint
end
--------------------------------------------------------------------------------------------------------
function PANEL:Think()
    local model = self.model
    if input.IsKeyDown(leftinput) then
        model:SetCamPos(RotatePointAroundPivot(model:GetCamPos(), model:GetLookAt(), Angle(0, FrameTime() * 180, 0)))
    elseif input.IsKeyDown(rightinput) then
        model:SetCamPos(RotatePointAroundPivot(model:GetCamPos(), model:GetLookAt(), Angle(0, FrameTime() * -180, 0)))
    end
end
--------------------------------------------------------------------------------------------------------
vgui.Register("BodygrouperMenu", PANEL, "DFrame")
--------------------------------------------------------------------------------------------------------