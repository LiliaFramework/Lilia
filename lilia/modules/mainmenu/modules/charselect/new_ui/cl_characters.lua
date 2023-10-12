--------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------------------------
PANEL.WHITE = Color(255, 255, 255, 150)
PANEL.SELECTED = Color(255, 255, 255, 230)
PANEL.HOVERED = Color(255, 255, 255, 50)
PANEL.ANIM_SPEED = 0.1
PANEL.FADE_SPEED = 0.5
--------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    if IsValid(lia.gui.newCharsMenu) then
        lia.gui.newCharsMenu:Remove()
    end

    lia.gui.newCharsMenu = self
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, -ScrH())
    self:MakePopup()
    self:MoveTo(0, 0, .8)
    self.list = self:Add('liaHorizontalScroll')
    self.list:SetSize(ScrW() * .8, ScrH() * .6)
    self.list:SetPos((ScrW() * .5) - (ScrW() * .8) / 2, (ScrH() * .6) - (ScrH() * .6) / 2)
    local scrollBar = self.list:GetHBar()
    scrollBar:SetTall(8)
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(scroll, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end

    scrollBar.btnGrip.Paint = function(grip, w, h)
        local alpha = 50
        if scrollBar.Dragging then
            alpha = 150
        elseif grip:IsHovered() then
            alpha = 100
        end

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.DrawRect(0, 0, w, h)
    end

    self:createCharacterSlots()
    hook.Add(
        'CharacterListUpdated',
        self,
        function()
            self:createCharacterSlots()
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:createCharacterSlots()
    self.list:Clear()
    if #lia.characters == 0 then return end
    for _, id in ipairs(lia.characters) do
        local character = lia.char.loaded[id]
        if not character then continue end
        local panel = self.list:Add('liaNewCharacterSlot')
        panel:Dock(LEFT)
        panel:DockMargin(0, 0, 8, 8)
        panel:setCharacter(character)
        panel.onSelected = function(panel)
            self:onCharacterSelected(character)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:onCharacterSelected(character)
    if self.choosing then return end
    if IsValid(lia.gui.bgMusic) then
        lia.gui.bgMusic:Remove()
    end

    if character == LocalPlayer():getChar() then
        self:Remove()

        return
    end

    self.choosing = true
    self:setFadeToBlack(true):next(function() return MainMenu:chooseCharacter(character:getID()) end):next(
        function(err)
            self.choosing = false
            if IsValid(self) then
                timer.Simple(
                    0.25,
                    function()
                        if not IsValid(self) then return end
                        self:setFadeToBlack(false)
                        self:Remove()
                    end
                )
            end
        end,
        function(err)
            self.choosing = false
            self:setFadeToBlack(false)
            lia.util.notify(err)
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then
            self.fade:Remove()
        end

        local fade = vgui.Create('DPanel')
        fade:SetSize(ScrW(), ScrH())
        fade:SetSkin('Default')
        fade:SetBackgroundColor(color_black)
        fade:SetAlpha(0)
        fade:AlphaTo(
            255,
            self.FADE_SPEED,
            0,
            function()
                d:resolve()
            end
        )

        fade:SetZPos(999)
        fade:MakePopup()
        self.fade = fade
    elseif IsValid(self.fade) then
        local fadePanel = self.fade
        fadePanel:AlphaTo(
            0,
            self.FADE_SPEED,
            0,
            function()
                fadePanel:Remove()
                d:resolve()
            end
        )
    end

    return d
end

--------------------------------------------------------------------------------------------------------------------------
DEFINE_BASECLASS('EditablePanel')
function PANEL:Remove()
    self.bClosing = true
    self.list:Clear()
    self:AlphaTo(
        0,
        .3,
        0,
        function()
            BaseClass.Remove(self)
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
local gradient = lia.util.getMaterial('gui/gradient_up')
function PANEL:Paint(w, h)
    surface.DrawTexturedRect((w / 2) - ((h * 1.5) * .2) / 2, 10, (h * 1.5) * .2, h * .28)
    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, h - (h * .1), w, h * .1)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:OnKeyCodePressed(keyCode)
    if self.bClosing then return end
    if keyCode == KEY_SPACE then
        self:MoveTo(
            0,
            -ScrH(),
            .8,
            0,
            -1,
            function()
                self:Remove()
            end
        )

        local panel = vgui.Create('liaNewCharacterMenu')
        panel:SetPos(0, ScrH())
        panel:MoveTo(0, 0, .8)
        self.bClosing = true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:hoverSound()
    LocalPlayer():EmitSound(unpack(lia.config.CharHover))
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:clickSound()
    LocalPlayer():EmitSound(unpack(lia.config.CharClick))
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:warningSound()
    LocalPlayer():EmitSound(unpack(lia.config.CharWarning))
end

--------------------------------------------------------------------------------------------------------------------------
vgui.Register('liaNewCharactersMenu', PANEL, 'EditablePanel')
--------------------------------------------------------------------------------------------------------------------------