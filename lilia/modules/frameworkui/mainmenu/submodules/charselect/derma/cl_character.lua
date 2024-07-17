local PANEL = {}
PANEL.WHITE = Color(255, 255, 255, 150)
PANEL.SELECTED = Color(255, 255, 255, 230)
PANEL.HOVERED = Color(255, 255, 255, 50)
PANEL.ANIM_SPEED = 0.1
PANEL.FADE_SPEED = 0.5
function PANEL:createTabs()
    local client = LocalPlayer()
    local load, create
    if lia.characters and #lia.characters > 0 then load = self:addTab("continue", self.createCharacterSelection) end
    if hook.Run("CanPlayerCreateChar", client) ~= false then create = self:addTab("create", self.createCharacterCreation) end
    if IsValid(load) then
        load:setSelected()
    elseif IsValid(create) then
        create:setSelected()
    end

    if client:getChar() then
        self:addTab("return", function() if IsValid(self) and client:getChar() then self:fadeOut() end end, true)
    else
        self:addTab("leave", function() vgui.Create("liaCharacterConfirm"):setTitle(L("disconnect"):upper() .. "?"):setMessage(L("You will disconnect from the server."):upper()):onConfirm(function() client:ConCommand("disconnect") end) end, true)
    end

    local totalWidth = 0
    for _, v in ipairs(self.tabs:GetChildren()) do
        totalWidth = totalWidth + v:GetWide()
    end

    self.tabs:DockMargin(self.tabs:GetWide() + totalWidth * 1.5, 25, 0, 0)
end

function PANEL:createTitle()
    self.pnl = self:Add("DPanel")
    self.pnl:Dock(TOP)
    self.title = self.pnl:Add("DLabel")
    self.title:Dock(LEFT)
    self.title:InvalidateParent(true)
    self.title.Paint = function() end
    self.title:SetTextColor(lia.gui.character.WHITE)
    self.title:SetFont("liaCharTitleFont")
    self.title:SetMultiline(false)
    self.title:SetWrap(false)
    self.title:SetText(SCHEMA.name)
    self.title:SizeToContents()
    self.pnl:SizeToChildren(false, true)
end

function PANEL:CreateBG()
    self.background = self:Add("DHTML")
    self.background:SetSize(ScrW(), ScrH())
    self.background:SetHTML([[
        <html>
        <head>
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    pointer-events: none; /* Disable mouse events */
                }
            </style>
        </head>
        <body>
            <iframe src="]] .. "https://www.youtube.com/embed/" .. MainMenu.BackgroundURL .. "?autoplay=1&controls=0&loop=1&mute=0" .. [[" frameborder="0" allowfullscreen style="width: 100%; height: 100%; pointer-events: none;"></iframe>
        </body>
        </html>
    ]])
    self.background:SetAllowLua(true) -- Enable running Lua scripts in the DHTML panel
    if MainMenu.CharMenuBGInputDisabled then
        self.background:SetMouseInputEnabled(false) -- Disable mouse input
        self.background:SetKeyboardInputEnabled(false) -- Disable keyboard input
    end
end

function PANEL:loadBackground()
    local url = MainMenu.BackgroundURL
    local logo = MainMenu.LogoURL
    if url ~= "" then
        if MainMenu.BackgroundIsYoutubeVideo then
            self:CreateBG()
        elseif url:find("%S") then
            self.background = self:Add("DHTML")
            self.background:SetSize(ScrW(), ScrH())
            if url:find("http") then
                self.background:OpenURL(url)
            else
                self.background:SetHTML(url)
            end

            self.background.OnDocumentReady = function() self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end
            self.bgLoader = self:Add("DPanel")
            self.bgLoader:SetSize(ScrW(), ScrH())
            self.bgLoader:SetZPos(-998)
            self.bgLoader.Paint = function(_, w, h)
                surface.SetDrawColor(20, 20, 20)
                surface.DrawRect(0, 0, w, h)
            end
        end

        self.background:MoveToBack()
        self.background:SetZPos(-999)
        if MainMenu.CharMenuBGInputDisabled then
            self.background:SetMouseInputEnabled(false)
            self.background:SetKeyboardInputEnabled(false)
        end
    end

    if logo ~= "" then
        self.logoPanel = self:Add("DHTML")
        self.logoPanel:SetSize(128, 128)
        self.logoPanel:SetPos(ScrW() - 128, 0)
        self.logoPanel:SetHTML(string.format("<img src='%s' width='100%%' height='100%%'>", logo))
    end
end

function PANEL:paintBackground(w, h)
    if IsValid(self.background) then return end
    if self.blank then
        surface.SetDrawColor(30, 30, 30)
        surface.DrawRect(0, 0, w, h)
    end

    if not self.startTime then self.startTime = CurTime() end
    local r, g, b = lia.config.Color:Unpack()
    local curTime = (self.startTime - CurTime()) / 4
    local alpha = 200 * ((math.sin(curTime - 1.8719) + math.sin(curTime - 1.8719 / 2)) / 4 + 0.44)
    surface.SetDrawColor(r, g, b, alpha)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
    surface.DrawTexturedRect(0, 0, w, h)
end

function PANEL:addTab(name, callback, justClick)
    local button = self.tabs:Add("liaCharacterTabButton")
    button:setText(L(name):upper())
    if justClick then
        if isfunction(callback) then button.DoClick = function() callback(self) end end
        return
    end

    button.DoClick = function(button) button:setSelected(true) end
    if isfunction(callback) then button:onSelected(function() callback(self) end) end
    return button
end

function PANEL:createCharacterSelection()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterSelection")
end

function PANEL:createCharacterCreation()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

function PANEL:fadeOut()
    self:AlphaTo(0, self.ANIM_SPEED, 0, function() self:Remove() end)
end

function PANEL:Init()
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, self.ANIM_SPEED * 2)
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

function PANEL:showContent()
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
end

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
        fadePanel:AlphaTo(0, self.FADE_SPEED, 0, function()
            fadePanel:Remove()
            d:resolve()
        end)
    end
    return d
end

function PANEL:Paint()
    local client = LocalPlayer()
    if not client:getChar() then lia.util.drawBlur(self) end
end

function PANEL:hoverSound()local client = LocalPlayer()
    client:EmitSound(unpack(MainMenu.CharHover))
end

function PANEL:clickSound()local client = LocalPlayer()
    client:EmitSound(unpack(MainMenu.CharClick))
end

function PANEL:warningSound()local client = LocalPlayer()
    client:EmitSound(unpack(MainMenu.CharWarning))
end

vgui.Register("liaCharacter", PANEL, "EditablePanel")