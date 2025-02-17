local PANEL = {}
local WHITE = Color(255, 255, 255, 150)
local CharHover = {"buttons/button15.wav", 35, 250}
local CharClick = {"buttons/button14.wav", 35, 255}
local CharWarning = {"friends/friend_join.wav", 40, 255}
PANEL.ANIM_SPEED = 0.1
PANEL.FADE_SPEED = 0.5
local function animateButton(button, w, h, text)
    local animWidth = 0
    local animDuration = 0.3
    local startTime = nil
    button.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(1, 1, w - 2, h - 2)
        draw.SimpleText(text, "DermaLarge", w / 2, h / 2, WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if self:IsHovered() then
            if not startTime then startTime = CurTime() end
            local timeElapsed = CurTime() - startTime
            animWidth = math.min(w, (timeElapsed / animDuration) * w) / 2
            surface.SetDrawColor(76, 146, 172, 255)
            surface.DrawLine(w / 2 - animWidth, h - 1, w / 2 + animWidth, h - 1)
        else
            startTime = nil
            animWidth = 0
        end
    end
end

function PANEL:createStartButton()
    local screenWidth, screenHeight = ScrW(), ScrH()
    local btnWidth = screenWidth * 0.2
    local btnHeight = screenHeight * 0.04
    local buttonSpacing = screenHeight * 0.01
    local logoWidth = screenWidth * 0.13
    local logoHeight = screenWidth * 0.13
    local logoPath = lia.config.get("CenterLogo")
    local discordURL = lia.config.get("DiscordURL")
    local workshopURL = lia.config.get("Workshop")
    local buttonConfigs = {}
    table.insert(buttonConfigs, {
        id = "play",
        text = "PLAY",
        doClick = function()
            if self.buttons then
                for _, btn in pairs(self.buttons) do
                    if IsValid(btn) then btn:Remove() end
                end
            end

            if self.logo and IsValid(self.logo) then self.logo:Remove() end
            self:clickSound()
            self:showContent()
        end
    })

    if discordURL and discordURL ~= "" then
        table.insert(buttonConfigs, {
            id = "discord",
            text = "DISCORD",
            doClick = function()
                self:clickSound()
                gui.OpenURL(discordURL)
            end
        })
    end

    if workshopURL and workshopURL ~= "" then
        table.insert(buttonConfigs, {
            id = "workshop",
            text = "STEAM WORKSHOP",
            doClick = function()
                self:clickSound()
                gui.OpenURL(workshopURL)
            end
        })
    end

    table.insert(buttonConfigs, {
        id = "disconnect",
        text = "DISCONNECT",
        doClick = function()
            self:clickSound()
            RunConsoleCommand("disconnect")
        end
    })

    local numButtons = #buttonConfigs
    local totalHeight = numButtons * btnHeight + (numButtons - 1) * buttonSpacing
    local startY = screenHeight / 2 - totalHeight / 2
    self.buttons = {}
    for i, config in ipairs(buttonConfigs) do
        local btn = self:Add("DButton")
        btn:SetSize(btnWidth, btnHeight)
        local posY = startY + (i - 1) * (btnHeight + buttonSpacing)
        btn:SetPos(screenWidth / 2 - btnWidth / 2, posY)
        btn:SetText("")
        animateButton(btn, btnWidth, btnHeight, config.text)
        btn.DoClick = config.doClick
        btn.OnCursorEntered = function() surface.PlaySound("ui/hover.wav") end
        self.buttons[config.id] = btn
    end

    if logoPath and logoPath ~= "" then
        if string.sub(logoPath, 1, 8) == "https://" then
            http.Fetch(logoPath, function(body)
                local fileName = "temp_logo.png"
                file.Write(fileName, body)
                self.logo = self:Add("DImage")
                self.logo:SetImage("data/" .. fileName)
                self.logo:SetSize(logoWidth, logoHeight)
                self.logo:CenterHorizontal()
                self.logo:SetPos(screenWidth / 2 - logoWidth / 2, startY - logoHeight - buttonSpacing)
            end, function(err) print("Failed to fetch logo: ", err) end)
        else
            self.logo = self:Add("DImage")
            self.logo:SetImage(logoPath)
            self.logo:SetSize(logoWidth, logoHeight)
            self.logo:CenterHorizontal()
            self.logo:SetPos(screenWidth / 2 - logoWidth / 2, startY - logoHeight - buttonSpacing)
        end
    end
end

function PANEL:playSound(url)
    if lia.menuSound then
        lia.menuSound:Stop()
        lia.menuSound = nil
    end

    timer.Remove("liaSoundFader")
    local source = url
    if source:find("%S") then
        local function callback(sound, errorID, fault)
            if sound then
                sound:SetVolume(2)
                lia.menuSound = sound
                lia.menuSound:Play()
            else
                MsgC(Color(255, 50, 50), errorID .. " ")
                MsgC(color_white, fault .. "\n")
            end
        end

        if source:find("http") then
            sound.PlayURL(source, "noplay", callback)
        else
            sound.PlayFile("sound/" .. source, "noplay", callback)
        end
    end
end

function PANEL:fadeMusic()
    if lia.menuSound then
        local fraction = 1
        local start, finish = RealTime(), RealTime() + 10
        timer.Create("liaMusicFader", 0.1, 0, function()
            if lia.menuSound then
                fraction = 1 - math.TimeFraction(start, finish, RealTime())
                lia.menuSound:SetVolume(fraction * 0.5)
                if fraction <= 0 then
                    lia.menuSound:Stop()
                    lia.menuSound = nil
                    timer.Remove("liaMusicFader")
                end
            else
                timer.Remove("liaMusicFader")
            end
        end)
    end
end

function PANEL:createTitle()
    if self.tabs then
        local topMargin = 32
        self.tabs:DockMargin(64, topMargin, 64, 0)
    end
end

function PANEL:loadBackground()
    local mapScene = lia.module.list.mapscene
    if not mapScene or table.Count(mapScene.scenes) == 0 then self.blank = true end
    local url = lia.config.get("BackgroundURL")
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
        if lia.config.get("CharMenuBGInputDisabled") then
            self.background:SetMouseInputEnabled(false)
            self.background:SetKeyboardInputEnabled(false)
        end

        self.bgLoader = self:Add("DPanel")
        self.bgLoader:SetSize(ScrW(), ScrH())
        self.bgLoader:SetZPos(-998)
        self.bgLoader.Paint = function(loader, w, h)
            surface.SetDrawColor(5, 5, 5)
            surface.DrawRect(0, 0, w, h)
        end
    end
end

function PANEL:paintBackground(w, h)
    if IsValid(self.background) then return end
    if self.blank then
        surface.SetDrawColor(42, 42, 42, 179)
        surface.DrawRect(0, 0, w, h)
    end
end

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

function PANEL:createTabs()
    local load, create
    if lia.characters and #lia.characters > 0 then load = self:addTab("main menu", self.createCharacterSelection) end
    if hook.Run("CanPlayerCreateCharacter", LocalPlayer()) ~= false then create = self:addTab("new character", self.createCharacterCreation) end
    if IsValid(load) then
        load:setSelected()
    elseif IsValid(create) then
        create:setSelected()
    end

    if LocalPlayer():getChar() then
        self:addTab("return", function() if IsValid(self) and LocalPlayer():getChar() then self:fadeOut() end end, true)
    else
        self:addTab("leave", function() vgui.Create("liaCharacterConfirm"):setTitle(L("disconnect"):upper() .. "?"):setMessage(L("You will disconnect from the server."):upper()):onConfirm(function() LocalPlayer():ConCommand("disconnect") end) end, true)
    end

    local totalWidth = -32
    for _, v in ipairs(self.tabs:GetChildren()) do
        totalWidth = totalWidth + v:GetWide()
    end

    self.tabs:Dock(BOTTOM)
    self.tabs:DockMargin(0, 0, 0, 10)
    self.tabs:DockMargin(self.tabs:GetWide() * 0.5 - totalWidth * 0.5, 0, 0, 10)
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)
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
    self.color = ColorAlpha(color_white, 150)
    self.colorSelected = color_white
    self.colorHovered = ColorAlpha(color_white, 50)
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, self.ANIM_SPEED * 2)
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:DockMargin(64, 32, 64, 0)
    self.tabs:SetTall(48)
    self.tabs:SetPaintBackground(false)
    self:createTitle()
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(64, 0, 64, 64)
    self.content:SetPaintBackground(false)
    self.music = self:Add("liaCharBGMusic")
    self:loadBackground()
    self:InvalidateParent(true)
    self:InvalidateChildren(true)
    self:createStartButton()
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

function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    self:paintBackground(w, h)
end

function PANEL:hoverSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharHover))
end

function PANEL:clickSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharClick))
end

function PANEL:warningSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharWarning))
end

vgui.Register("liaCharacter", PANEL, "EditablePanel")