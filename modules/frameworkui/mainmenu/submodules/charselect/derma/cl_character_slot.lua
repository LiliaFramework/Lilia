local PANEL = {}
function PANEL:confirmDelete()
    local id = self.character:getID()
    if hook.Run("CanDeleteChar", id) == false then
        LocalPlayer():notifyWarning("You cannot delete this character!")
        return
    end

    vgui.Create("liaCharacterConfirm"):setMessage(L("charDeletionCannotUndone")):onConfirm(function() MainMenu:deleteCharacter(id) end)
end

function PANEL:Init()
    self.originalWidth = 240
    self.originalHeight = 200
    self:SetSize(self.originalWidth, self.originalHeight)
    self:SetPaintBackground(false)
    self.isHovered = false
    self.factionLabel = self:Add("DLabel")
    self.factionLabel:SetFont("liaCharSmallFont")
    self.factionLabel:SetTextColor(lia.gui.character.WHITE)
    self.factionLabel:SetWrap(true)
    self.factionLabel:SetAutoStretchVertical(true)
    self.factionLabel:SetVisible(false)
    self.factionLabel:SetContentAlignment(5)
    self.classLabel = self:Add("DLabel")
    self.classLabel:SetFont("liaCharSmallFont")
    self.classLabel:SetTextColor(lia.gui.character.WHITE)
    self.classLabel:SetWrap(true)
    self.classLabel:SetAutoStretchVertical(true)
    self.classLabel:SetVisible(false)
    self.classLabel:SetContentAlignment(5)
    self.name = self:Add("DLabel")
    self.name:SetFont("liaCharMediumFont")
    self.name:SetTextColor(lia.gui.character.WHITE)
    self.name:SetWrap(false)
    self.model = self:Add("liaModelPanel")
    self.model:SetFOV(37)
    self.model.PaintOver = function(_, w, h)
        if self.banned then
            local centerX, centerY = w * 0.5, h * 0.5 - 24
            surface.SetDrawColor(250, 0, 0, 40)
            surface.DrawRect(0, centerY - 24, w, 48)
            draw.SimpleText(L("banned"):upper(), "liaCharSubTitleFont", centerX, centerY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self.model.OnMousePressed = function(_, mc) self:OnMousePressed(mc) end
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
end

function PANEL:onSelected()
end

function PANEL:setCharacter(character)
    if not character then return end
    self.character = character
    local nameText = character:getName():gsub("#", "\226\128\139#"):upper()
    self.name:SetText(nameText)
    self.model:SetModel(character:getModel())
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

    if self.factionLabel then
        self.factionLabel:SetText("Faction: " .. (team.GetName(character:getFaction()) or "None"))
        self.factionLabel:SizeToContentsY()
    end

    if IsValid(self.factionLogo) then self.factionLogo:Remove() end
    if IsValid(self.classLogo) then self.classLogo:Remove() end
    local factionData = lia.faction.indices[character:getFaction()]
    local classData
    local classIndex = character:getClass()
    if classIndex then classData = lia.class.list[classIndex] end
    if factionData and factionData.logo then
        self.factionLogo = self:Add("DImage")
        self.factionLogo:SetImage(factionData.logo)
        self.factionLogo:SetSize(128, 128)
    end

    if classData and classData.logo then
        self.classLogo = self:Add("DImage")
        self.classLogo:SetImage(classData.logo)
        self.classLogo:SetSize(128, 128)
    end
end

function PANEL:setBanned(banned)
    self.banned = banned
end

function PANEL:OnMousePressed(mc)
    if mc == MOUSE_LEFT then
        lia.gui.character:clickSound()
        if not self.banned then self:onSelected() end
    end
end

function PANEL:Paint()
    lia.util.drawBlur(self)
end

function PANEL:PerformLayout()
    DPanel.PerformLayout(self)
    self.name:SetWrap(false)
    self.name:SizeToContents()
    local maxWidth = self:GetWide() - 16
    if self.name:GetWide() > maxWidth then
        self.name:SetWrap(true)
        self.name:SetWide(maxWidth)
        self.name:SizeToContentsY()
    else
        self.name:SizeToContents()
    end

    self.name:CenterHorizontal()
    self.name:SetY(16)
    local fW, fH = self.factionLabel:GetSize()
    local cW, cH = self.classLabel:GetSize()
    self.factionLabel:SetPos((self:GetWide() - fW) * 0.5, -(fH + cH))
    self.classLabel:SetPos((self:GetWide() - cW) * 0.5, -cH)
    local _, nameY = self.name:GetPos()
    local nameHeight = self.name:GetTall()
    local logoX = math.max((self:GetWide() - 128) / 2, 0)
    local nextY = nameY + nameHeight + 8
    if IsValid(self.factionLogo) then self.factionLogo:SetPos(logoX, nextY) end
    if IsValid(self.classLogo) then
        local offset = IsValid(self.factionLogo) and (self.factionLogo:GetTall() + 8) or 0
        self.classLogo:SetPos(logoX, nextY + offset)
    end

    local modelHeight = self:GetTall() - 324 - self.delete:GetTall()
    self.model:SetPos(0, 324)
    self.model:SetSize(self:GetWide(), modelHeight)
end

vgui.Register("liaCharacterSlot", PANEL, "DPanel")
