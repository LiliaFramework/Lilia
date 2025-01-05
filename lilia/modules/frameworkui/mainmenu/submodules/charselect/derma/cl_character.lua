local PANEL = {}
local CharHover = {"buttons/button15.wav", 35, 250}
local CharClick = {"buttons/button14.wav", 35, 255}
local CharWarning = {"friends/friend_join.wav", 40, 255}
local WHITE = Color(255, 255, 255, 200)
PANEL.WHITE = Color(255, 255, 255, 200)
PANEL.SELECTED = Color(255, 255, 255, 150)
PANEL.HOVERED = Color(255, 255, 255, 255)
PANEL.ANIM_SPEED = 0.2
PANEL.FADE_SPEED = 2
function PANEL:removeLogo()
    if IsValid(self.schemaLogo) then
        self.schemaLogo:Remove()
        self.schemaLogo = nil
    end
end

function PANEL:createTabs()
    if lia.characters and #lia.characters > 0 then self:CreateButton("continue", "Continue your character", function() self:createCharacterSelection() end) end
    if hook.Run("CanPlayerCreateChar", LocalPlayer()) ~= false then self:CreateButton("create", "Create a new character", function() self:createCharacterCreation() end) end
    if LocalPlayer():getChar() then
        if not MainMenu.KickOnEnteringMainMenu then self:CreateButton("return", "Return to character", function() if IsValid(self) and LocalPlayer():getChar() then self:fadeOut() end end) end
    else
        self:CreateButton("leave", "Disconnect from server", function() vgui.Create("liaCharacterConfirm"):setTitle(L("disconnect"):upper() .. "?"):setMessage(L("You will disconnect from the server."):upper()):onConfirm(function() LocalPlayer():ConCommand("disconnect") end) end)
    end
end

function PANEL:CreateIcon(parent, iconURL, iconIMG, posX, posY)
    if iconURL and iconURL:find("%S") and iconIMG and iconIMG:find("%S") then
        local icon = parent:Add("DHTML")
        icon:SetPos(posX, posY)
        icon:SetSize(86, 86)
        local imgTag
        if iconIMG:match("^https?://") then
            imgTag = '<img src="' .. iconIMG .. '" width="86" height="86" />'
        else
            imgTag = '<img src="asset/path/' .. iconIMG .. '" width="86" height="86" />'
        end

        icon:SetHTML([[
            <html>
                <body style="margin: 0; padding: 0; overflow: hidden;">
                    ]] .. imgTag .. [[
                </body>
            </html>
        ]])
        local button = icon:Add("DButton")
        button:Dock(FILL)
        button.DoClick = function() gui.OpenURL(iconURL) end
        button:SetAlpha(0)
        icon:SetAlpha(0)
        icon:AlphaTo(255, self.ANIM_SPEED, 0)
        return icon
    end
end

function PANEL:CreateButton(text, description, callback)
    local btn = self.tabs:Add("DButton")
    btn:SetText("")
    btn:Dock(TOP)
    btn:DockMargin(5, 5, 5, 10)
    btn.initialTall = ScrH() * 0.1 / 2
    btn.initialWidth = 2
    btn.tall = btn.initialTall
    btn.width = btn.initialWidth
    btn.text_color = color_white
    btn.text = text
    btn.description = description or "No description"
    btn.selected = false
    btn.fillProgress = 0
    btn:SetTall(btn.tall)
    btn.Paint = function(me, w, h)
        local hovered = me:IsHovered()
        me.text_color = lia.color.LerpColor(0.2, me.text_color, hovered and Color(200, 200, 200) or color_white)
        draw.SimpleText(me.text:upper(), "liaBigFont", w * 0.5, h * 0.5, me.text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if hovered then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            local underlineY = h - 4
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end
    end

    btn.DoClick = function(me)
        self:clickSound()
        if self.selectedButton and self.selectedButton ~= me and self.selectedButton.selected then self.selectedButton.selected = false end
        self.selectedButton = me
        if IsValid(self.selectedDescription) then self.selectedDescription:SetText(me.description) end
        if callback and isfunction(callback) then callback() end
    end
end

function PANEL:createTitle()
    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
    self.title:DockMargin(0, 20, 0, 20)
    self.title:SetContentAlignment(5)
    self.title:SetTall(96)
    self.title:SetFont("liaCharTitleFont")
    self.title:SetText(SCHEMA and SCHEMA.name)
    self.title:SetTextColor(WHITE)
    self.selectedDescription = self:Add("DLabel")
    self.selectedDescription:Dock(BOTTOM)
    self.selectedDescription:DockMargin(64, 0, 64, 16)
    self.selectedDescription:SetContentAlignment(5)
    self.selectedDescription:SetTall(24)
    self.selectedDescription:SetFont("liaMediumFont")
    self.selectedDescription:SetTextColor(WHITE)
    self.selectedDescription:SetText("")
    local centerlogo = MainMenu.CenterLogo and MainMenu.CenterLogo:find("%S")
    if centerlogo then
        local logoWidth, logoHeight = 512, 512
        self.schemaLogo = self:Add("DHTML")
        self.schemaLogo:SetSize(logoWidth, logoHeight)
        self.schemaLogo:SetPos((ScrW() - logoWidth) / 2, sH(150))
        self.schemaLogo:SetZPos(-197)
        local htmlContent = [[
            <html>
                <body style="margin: 0; background-color: transparent;">
                    <img src="]] .. MainMenu.CenterLogo .. [[" width="]] .. logoWidth .. [[" height="]] .. logoHeight .. [[" />
                </body>
            </html>
        ]]
        self.schemaLogo:SetHTML(htmlContent)
        self.schemaLogo:SetAlpha(255)
        self.schemaLogo.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 0)
            surface.DrawRect(0, 0, w, h)
        end
    end

    local iconWidth = 86
    self:CreateIcon(self, "https://github.com/LiliaFramework/Lilia", "https://raw.githubusercontent.com/LiliaFramework/Lilia/main/lilia/logo.png", ScrW() - iconWidth - 16, 8)
    if MainMenu.ButtonURL ~= "" and MainMenu.ButtonLogo ~= "" then self:CreateIcon(self, MainMenu.ButtonURL, MainMenu.ButtonLogo, 16, ScrH() - iconWidth - 16) end
end

function PANEL:loadBackground()
    local url = MainMenu.BackgroundURL
    if url and url:find("%S") then
        self.background = self:Add("DHTML")
        self.background:SetSize(ScrW(), ScrH())
        if url:find("http") then
            self.background:OpenURL(url)
        else
            self.background:SetHTML(url)
        end

        self.background.OnDocumentReady = function() self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end
        self.background:MoveToBack()
        self.background:SetZPos(-999)
        if MainMenu.CharMenuBGInputDisabled then
            self.background:SetMouseInputEnabled(false)
            self.background:SetKeyboardInputEnabled(false)
        end

        self.background:SetAlpha(200)
        self.bgLoader = self:Add("DPanel")
        self.bgLoader:SetSize(ScrW(), ScrH())
        self.bgLoader:SetZPos(-998)
        self.bgLoader.Paint = function(_, w, h)
            surface.SetDrawColor(20, 20, 20)
            surface.DrawRect(0, 0, w, h)
        end
    end
end

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

function PANEL:fadeOut()
    self:AlphaTo(0, self.ANIM_SPEED, 0, function() self:Remove() end)
end

function PANEL:Init()
    self.mainMenu = true
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 2)
    self:createTitle()
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(LEFT)
    self.tabs:SetWide(ScrW() * 0.2)
    self.tabs:DockMargin(10, 10, 10, 10)
    self.tabs:SetPaintBackground(false)
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(10, 10, 10, 10)
    self.content:SetPaintBackground(false)
    self.content:SetZPos(-100)
    self.music = self:Add("liaCharBGMusic")
    self:loadBackground()
    self:showContent()
end

function PANEL:showContent()
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
end

function PANEL:moveTabs()
end

function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local fadePanel = vgui.Create("DPanel")
        fadePanel:SetSize(ScrW(), ScrH())
        fadePanel:SetSkin("Default")
        fadePanel:SetBackgroundColor(color_black)
        fadePanel:SetAlpha(0)
        fadePanel:AlphaTo(255, self.FADE_SPEED, 0, function() d:resolve() end)
        fadePanel:SetZPos(999)
        fadePanel:MakePopup()
        self.fade = fadePanel
    elseif IsValid(self.fade) then
        local fadePanel = self.fade
        fadePanel:AlphaTo(0, self.FADE_SPEED, 0, function()
            fadePanel:Remove()
            d:resolve()
        end)
    end
    return d
end

function PANEL:createCharacterSelection()
    self:removeLogo()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    local charSelect = self.content:Add("liaCharacterSelection")
    charSelect:Dock(FILL)
end

function PANEL:createCharacterCreation()
    if MainMenu.BackgroundURL then
        if IsValid(self.background) then self.background:Remove() end
        if IsValid(self.schemaLogo) then self.schemaLogo:Remove() end
    end

    self:removeLogo()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
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
