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

    vgui.Create("liaCharacterConfirm")
        :setMessage(L("Deleting a character cannot be undone."))
        :onConfirm(function() MainMenu:deleteCharacter(id) end)
end

function PANEL:Init()
    self.originalWidth = 240
    self.originalHeight = 200
    self:SetSize(self.originalWidth, self.originalHeight)
    self:SetPaintBackground(false)
    self.hoverCooldown = false

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
    self.name:SetFont("liaCharLargeFont")
    self.name:SetTextColor(lia.gui.character.WHITE)
    self.name:SetWrap(true)
    self.name:SetAutoStretchVertical(true)
    self.name:Dock(TOP)

    self.factionLabel = self:Add("DLabel")
    self.factionLabel:Dock(TOP)
    self.factionLabel:DockMargin(150, 4, 0, 0)
    self.factionLabel:SetFont("liaCharSmallFont")
    self.factionLabel:SetTextColor(lia.gui.character.WHITE)
    self.factionLabel:SetWrap(true)
    self.factionLabel:SetAutoStretchVertical(true)
    self.factionLabel:SetVisible(false)
    self.factionLabel:SizeToContentsY()

    self.classLabel = self:Add("DLabel")
    self.classLabel:Dock(TOP)
    self.classLabel:DockMargin(150, 4, 0, 0)
    self.classLabel:SetFont("liaCharSmallFont")
    self.classLabel:SetTextColor(lia.gui.character.WHITE)
    self.classLabel:SetWrap(true)
    self.classLabel:SetAutoStretchVertical(true)
    self.classLabel:SetVisible(false)
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
        local scale = math.max((960 / ScrH()) * 0.5, 0.5)
        self.model:SetLookAt(entity:GetPos() + Vector(0, 0, height * scale))
    end

    if self.factionLabel then
        self.factionLabel:SetText("Faction: " .. (team.GetName(character:getFaction()) or "None"))
    end
    self.factionLabel:SizeToContentsY()

    if self.classLabel then
        if character:getClass() and lia.class.list[character:getClass()] then
            local className = lia.class.list[character:getClass()].name
            self.classLabel:SetText("Class: " .. className)
        else
            self.classLabel:SetText("")
        end

        self.classLabel:SizeToContentsY()
    end

    self:CenterName()
end

function PANEL:setBanned(banned)
    self.banned = banned
end

function PANEL:onHoverChanged(isHovered)
    local ANIM_SPEED = lia.gui.character.ANIM_SPEED
    if self.isHovered == isHovered then return end
    self.isHovered = isHovered
    if isHovered then
        self:SizeTo(self.originalWidth * 2, self.originalHeight * 2, ANIM_SPEED)
        lia.gui.character:hoverSound()
        if self.factionLabel and self.classLabel then
            self.factionLabel:SetVisible(true)
            self.classLabel:SetVisible(true)
        end
    else
        self:SizeTo(self.originalWidth, self.originalHeight, ANIM_SPEED)
        if self.factionLabel and self.classLabel then
            self.factionLabel:SetVisible(false)
            self.classLabel:SetVisible(false)
        end
    end

    self.faction:AlphaTo(isHovered and 250 or 100, ANIM_SPEED)
    self:CenterName()
end

function PANEL:Paint(w, h)
    if not LocalPlayer():getChar() then lia.util.drawBlur(self) end
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 4, w, h)
    if not self:isCursorWithinBounds() and self.isHovered then
        self:onHoverChanged(false)
    end
end

function PANEL:OnCursorEntered()
    if not self.hoverCooldown then
        self.hoverCooldown = true
        self:onHoverChanged(true)
        timer.Simple(1, function()
            if IsValid(self) then
                self.hoverCooldown = false
            end
        end)
    end
end

function PANEL:OnCursorExited()
    if not self.hoverCooldown then
        self.hoverCooldown = true
        self:onHoverChanged(false)
        timer.Simple(1, function()
            if IsValid(self) then
                self.hoverCooldown = false
            end
        end)
    end
end

function PANEL:CenterName()
    self.name:SizeToContents()
    local panelWidth, _ = self:GetSize()
    local labelWidth, _ = self.name:GetSize()
    local marginLeft = math.max((panelWidth - labelWidth) / 2, 0)
    local marginRight = math.max((panelWidth - labelWidth) / 2, 0)
    self.name:DockMargin(marginLeft, 16, marginRight, 0)
end

function PANEL:PerformLayout()
    DPanel.PerformLayout(self)
    self:CenterName()
end

vgui.Register("liaCharacterSlot", PANEL, "DPanel")
