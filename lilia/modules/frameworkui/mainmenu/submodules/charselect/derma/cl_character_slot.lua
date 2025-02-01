local PANEL = {}
function PANEL:isCursorWithinBounds()
    local x, y = self:LocalCursorPos()
    return x >= 0 and x <= self:GetWide() and y >= 0 and y < self:GetTall()
end

function PANEL:confirmDelete()
    local id = self.character:getID()
    if hook.Run("CanDeleteChar", id) == false then
        LocalPlayer():notify("You cannot delete this character!")
        return
    end

    vgui.Create("liaCharacterConfirm"):setMessage(L("Deleting a character cannot be undone.")):onConfirm(function() MainMenu:deleteCharacter(id) end)
end

function PANEL:Init()
    self.originalWidth = 240
    self.originalHeight = 200
    self:SetSize(self.originalWidth, self.originalHeight)
    self:SetPaintBackground(false)
    self.isHovered = false
    self.faction = self:Add("DPanel")
    self.faction:Dock(TOP)
    self.faction:SetTall(4)
    self.faction:SetSkin("Default")
    self.faction:SetAlpha(100)
    self.faction.Paint = function(faction, w, h)
        surface.SetDrawColor(faction:GetBackgroundColor())
        surface.DrawRect(0, 0, w, h)
    end

    self.name = self:Add("DLabel")
    self.name:SetFont("liaCharMediumFont")
    self.name:SetTextColor(lia.gui.character.WHITE)
    self.name:SetWrap(true)
    self.name:SetAutoStretchVertical(true)
    self.name:Dock(TOP)
    self.factionLabel = self:Add("DLabel")
    self.factionLabel:Dock(TOP)
    self.factionLabel:DockMargin(0, 4, 0, 0)
    self.factionLabel:SetFont("liaCharSmallFont")
    self.factionLabel:SetTextColor(lia.gui.character.WHITE)
    self.factionLabel:SetWrap(true)
    self.factionLabel:SetAutoStretchVertical(true)
    self.factionLabel:SetVisible(false)
    self.factionLabel:SetContentAlignment(5)
    self.factionLabel:SizeToContentsY()
    self.classLabel = self:Add("DLabel")
    self.classLabel:Dock(TOP)
    self.classLabel:DockMargin(0, 4, 0, 0)
    self.classLabel:SetFont("liaCharSmallFont")
    self.classLabel:SetTextColor(lia.gui.character.WHITE)
    self.classLabel:SetWrap(true)
    self.classLabel:SetAutoStretchVertical(true)
    self.classLabel:SetVisible(false)
    self.classLabel:SetContentAlignment(5)
    self.classLabel:SizeToContentsY()
    self.model = self:Add("liaModelPanel")
    self.model:Dock(FILL)
    self.model:SetFOV(37)
    self.model.PaintOver = function(_, w, h)
        if self.banned then
            local centerX, centerY = w * 0.5, h * 0.5 - 24
            surface.SetDrawColor(250, 0, 0, 40)
            surface.DrawRect(0, centerY - 24, w, 48)
            draw.SimpleText(L("banned"):upper(), "liaCharSubTitleFont", centerX, centerY, color_white, 1, 1)
        end
    end

    self.button = self:Add("DButton")
    self.button:Dock(FILL)
    self.button:SetPaintBackground(false)
    self.button:SetText("")
    self.button.Paint = function() end
    self.button.OnCursorEntered = function() self:OnCursorEntered() end
    self.button.OnCursorExited = function() self:OnCursorExited() end
    self.button.DoClick = function()
        lia.gui.character:clickSound()
        if not self.banned then self:onSelected() end
    end

    self.delete = self:Add("DButton")
    self.delete:SetTall(30)
    self.delete:SetFont("liaCharSubTitleFont")
    self.delete:SetText("✕ " .. L("delete"):upper())
    self.delete:Dock(BOTTOM)
    self.delete:SetWide(self:GetWide())
    self.delete:DockMargin(0, 10, 0, 10)
    self.delete.Paint = function(_, w, h)
        surface.SetDrawColor(255, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end

    self.delete.DoClick = function()
        lia.gui.character:clickSound()
        self:confirmDelete()
    end

    self:CenterName()
end

function PANEL:onSelected()
end

function PANEL:setCharacter(character)
    if not character then return end
    self.character = character
    self.name:SetText(character:getName():gsub("#", "\226\128\139#"):upper())
    self.name:SizeToContentsY()
    self.model:SetModel(character:getModel())
    self.faction:SetBackgroundColor(team.GetColor(character:getFaction()))
    self:setBanned(character:getData("banned"))
    local entity = self.model.Entity
    if IsValid(entity) then
        entity:SetSkin(character:getData("skin", 0))
        for k, v in pairs(character:getData("groups", {})) do
            entity:SetBodygroup(k, v)
        end

        local mins, maxs = entity:GetRenderBounds()
        local height = math.abs(mins.z) + math.abs(maxs.z)
        local scale = math.max(960 / ScrH() * 0.5, 0.5)
        self.model:SetLookAt(entity:GetPos() + Vector(0, 0, height * scale))
    end

    if self.factionLabel then self.factionLabel:SetText("Faction: " .. (team.GetName(character:getFaction()) or "None")) end
    self.factionLabel:SizeToContentsY()
    if IsValid(self.factionLogo) then self.factionLogo:Remove() end
    local factionData = lia.faction.indices[character:getFaction()]
    if factionData and factionData.logo then
        self.factionLogo = self:Add("DImage")
        self.factionLogo:SetImage(factionData.logo)
        self.factionLogo:SetSize(256, 256)
        self.factionLogo:Dock(TOP)
        self.factionLogo:DockMargin(0, 16, 0, 16)
    end

    self:CenterName()
end

function PANEL:setBanned(banned)
    self.banned = banned
end

function PANEL:onHoverChanged(isHovered)
    if self.isHovered == isHovered then return end
    self.isHovered = isHovered
    if isHovered then
        lia.gui.character:hoverSound()
        if self.factionLabel and self.classLabel then
            self.factionLabel:SetVisible(true)
            self.classLabel:SetVisible(true)
        end
    else
        if self.factionLabel and self.classLabel then
            self.factionLabel:SetVisible(false)
            self.classLabel:SetVisible(false)
        end
    end

    self.faction:SetAlpha(isHovered and 250 or 100)
    self:CenterName()
end

function PANEL:OnCursorEntered()
    self:onHoverChanged(true)
end

function PANEL:OnCursorExited()
    self:onHoverChanged(false)
end

function PANEL:Paint(w, h)
    if not LocalPlayer():getChar() then lia.util.drawBlur(self) end
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 4, w, h)
    if not self:isCursorWithinBounds() and self.isHovered then self:onHoverChanged(false) end
end

function PANEL:CenterName()
    self.name:SizeToContents()
    if self.name:GetWide() > self:GetWide() then
        self.name:SetWide(self:GetWide() - 16)
        self.name:SetWrap(true)
    else
        self.name:SetWrap(false)
    end

    local nameMargin = math.max((self:GetWide() - self.name:GetWide()) / 2, 0)
    self.name:DockMargin(nameMargin, 16, nameMargin, 0)
    self.factionLabel:SizeToContents()
    if self.factionLabel:GetWide() > self:GetWide() then
        self.factionLabel:SetWide(self:GetWide() - 16)
        self.factionLabel:SetWrap(true)
    else
        self.factionLabel:SetWrap(false)
    end

    local factionMargin = math.max((self:GetWide() - self.factionLabel:GetWide()) / 2, 0)
    self.factionLabel:DockMargin(factionMargin, 8, factionMargin, 0)
    self.classLabel:SizeToContents()
    if self.classLabel:GetWide() > self:GetWide() then
        self.classLabel:SetWide(self:GetWide() - 16)
        self.classLabel:SetWrap(true)
    else
        self.classLabel:SetWrap(false)
    end

    local classMargin = math.max((self:GetWide() - self.classLabel:GetWide()) / 2, 0)
    self.classLabel:DockMargin(classMargin, 8, classMargin, 0)
end

function PANEL:PerformLayout()
    DPanel.PerformLayout(self)
    self:CenterName()
end

vgui.Register("liaCharacterSlot", PANEL, "DPanel")
hook.Add("ResetCharacterPanel", "liaResetCharacterPanel", function() if IsValid(lia.gui.character) then lia.gui.character:showContent() end end)
