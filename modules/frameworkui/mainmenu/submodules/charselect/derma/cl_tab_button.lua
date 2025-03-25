local PANEL = {}
local gradientR = lia.util.getMaterial("vgui/gradient-r")
local gradientL = lia.util.getMaterial("vgui/gradient-l")
function PANEL:Init()
    self:Dock(LEFT)
    self:DockMargin(0, 0, 32, 0)
    self:SetContentAlignment(4)
end

function PANEL:setText(name)
    self:SetText(L(name):upper())
    self:InvalidateLayout(true)
    self:SizeToContentsX()
end

function PANEL:onSelected(callback)
    self.callback = callback
end

function PANEL:setSelected(isSelected)
    if isSelected == nil then isSelected = true end
    if isSelected and self.isSelected then return end
    local menu = lia.gui.character
    if isSelected and IsValid(menu) then
        if IsValid(menu.lastTab) then
            menu.lastTab:SetTextColor(lia.gui.character.color)
            menu.lastTab.isSelected = false
        end

        menu.lastTab = self
    end

    self:SetTextColor(isSelected and lia.gui.character.colorSelected or lia.gui.character.color)
    self.isSelected = isSelected
    if isfunction(self.callback) then self:callback() end
end

function PANEL:Paint(w, h)
    if self.isSelected or self:IsHovered() then
        local r, g, b = lia.config.get("Color"):Unpack()
        if self.isSelected then
            surface.SetDrawColor(r, g, b, 200)
        else
            surface.SetDrawColor(r, g, b, 100)
        end

        surface.SetMaterial(gradientR)
        surface.DrawTexturedRect(0, h - 4, w / 2, 4)
        surface.SetMaterial(gradientL)
        surface.DrawTexturedRect(w / 2, h - 4, w / 2, 4)
    end
end

vgui.Register("liaCharacterTabButton", PANEL, "liaCharButton")
