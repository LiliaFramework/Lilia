--------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------------------------
PANEL.WHITE = Color(255, 255, 255, 150)
--------------------------------------------------------------------------------------------------------------------------
PANEL.SELECTED = Color(255, 255, 255, 230)
--------------------------------------------------------------------------------------------------------------------------
PANEL.HOVERED = Color(255, 255, 255, 50)
--------------------------------------------------------------------------------------------------------------------------
PANEL.ANIM_SPEED = 0.1
--------------------------------------------------------------------------------------------------------------------------
PANEL.FADE_SPEED = 0.5
--------------------------------------------------------------------------------------------------------------------------
function PANEL:createTabs()
    local load, create
    if lia.characters and #lia.characters > 0 then load = self:addTab("continue", self.createCharacterSelection) end
    if hook.Run("CanPlayerCreateCharacter", LocalPlayer()) ~= false then create = self:addTab("create", self.createCharacterCreation) end
    if IsValid(load) then
        load:setSelected()
    elseif IsValid(create) then
        create:setSelected()
    end

    if LocalPlayer():getChar() then
        self:addTab("return", function() if IsValid(self) and LocalPlayer():getChar() then self:fadeOut() end end, true)
        return
    end

    self:addTab("leave", function() vgui.Create("liaCharacterConfirm"):setTitle(L("disconnect"):upper() .. "?"):setMessage(L("You will disconnect from the server."):upper()):onConfirm(function() LocalPlayer():ConCommand("disconnect") end) end, true)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:createTitle()
    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
    self.title:DockMargin(64, 48, 0, 0)
    self.title:SetContentAlignment(1)
    self.title:SetTall(96)
    self.title:SetFont("liaCharTitleFont")
    self.title:SetText(L(SCHEMA and SCHEMA.name or "Unknown"):upper())
    self.title:SetTextColor(WHITE)
    self.desc = self:Add("DLabel")
    self.desc:Dock(TOP)
    self.desc:DockMargin(64, 0, 0, 0)
    self.desc:SetTall(32)
    self.desc:SetContentAlignment(7)
    self.desc:SetText(L(SCHEMA and SCHEMA.desc or ""):upper())
    self.desc:SetFont("liaCharDescFont")
    self.desc:SetTextColor(WHITE)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:loadBackground()
    if (not DynamicBackgrounds or table.Count(DynamicBackgrounds.scenes) == 0) or lia.config.CharCreationTransparentBackground then self.blank = true end
    local url = lia.config.BackgroundURL
    if url and url:find("%S") then
        self.background = self:Add("DHTML")
        self.background:SetSize(ScrW(), ScrH())
        if url:find("http") then
            self.background:OpenURL(url)
        else
            self.background:SetHTML(url)
        end

        self.background.OnDocumentReady = function(background) self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end
        self.background:MoveToBack()
        self.background:SetZPos(-999)
        if lia.config.CharMenuBGInputDisabled then
            self.background:SetMouseInputEnabled(false)
            self.background:SetKeyboardInputEnabled(false)
        end

        self.bgLoader = self:Add("DPanel")
        self.bgLoader:SetSize(ScrW(), ScrH())
        self.bgLoader:SetZPos(-998)
        self.bgLoader.Paint = function(loader, w, h)
            surface.SetDrawColor(20, 20, 20)
            surface.DrawRect(0, 0, w, h)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
local gradient = lia.util.getMaterial("vgui/gradient-u")
function PANEL:paintBackground(w, h)
    if IsValid(self.background) then return end
    if self.blank then
        surface.SetDrawColor(30, 30, 30)
        surface.DrawRect(0, 0, w, h)
    end

    surface.SetMaterial(gradient)
    surface.SetDrawColor(0, 0, 0, 250)
    surface.DrawTexturedRect(0, 0, w, h * 1.5)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:addTab(name, callback, justClick)
    local button = self.tabs:Add("liaCharacterTabButton")
    button:setText(L(name):upper())
    if justClick then
        if isfunction(callback) then button.DoClick = function(button) callback(self) end end
        return
    end

    button.DoClick = function(button) button:setSelected(true) end
    if isfunction(callback) then button:onSelected(function() callback(self) end) end
    return button
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:createCharacterSelection()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterSelection")
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:createCharacterCreation()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:fadeOut()
    self:AlphaTo(0, self.ANIM_SPEED, 0, function() self:Remove() end)
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, self.ANIM_SPEED * 2)
    self:createTitle()
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:DockMargin(64, 32, 64, 0)
    self.tabs:SetTall(48)
    self.tabs:SetPaintBackground(false)
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(64, 0, 64, 64)
    self.content:SetPaintBackground(false)
    self.music = self:Add("liaCharBGMusic")
    self:loadBackground()
    self:showContent()
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:showContent()
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
end

--------------------------------------------------------------------------------------------------------------------------
function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local fade = vgui.Create("DPanel")
        fade:SetSize(ScrW(), ScrH())
        fade:SetSkin("Default")
        fade:SetBackgroundColor(color_black)
        fade:SetAlpha(0)
        fade:AlphaTo(255, self.FADE_SPEED, 0, function() d:resolve() end)
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
function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    self:paintBackground(w, h)
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
vgui.Register("liaCharacter", PANEL, "EditablePanel")
--------------------------------------------------------------------------------------------------------------------------
