local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    local clientChar = client.getChar and client:getChar()
    self.disableClientModel = false
    self.noBlur = not clientChar
    self.isLoadMode = false
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    hook.Run("CharacterMenuOpened", self)
    if not render.oldDrawBeam then
        render.oldDrawBeam = render.DrawBeam
        render.DrawBeam = function(startPos, endPos, width, textureStart, textureEnd, color)
            if IsValid(lia.gui.character) then return end
            return render.oldDrawBeam(startPos, endPos, width, textureStart, textureEnd, color)
        end
    end

    hook.Add("PreDrawPhysgunBeam", "liaMainMenuPreDrawPhysgunBeam", function() return IsValid(lia.gui.character) end)
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)
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
    self:createTitle()
    self:loadBackground()
    if clientChar and lia.characters and #lia.characters > 0 then
        for i, charID in ipairs(lia.characters) do
            local charObj = isnumber(charID) and lia.char.getCharacter(charID) or charID
            if charObj and charObj.getID and charObj:getID() == clientChar:getID() then
                self.currentIndex = i
                break
            end
        end

        self.currentIndex = self.currentIndex or 1
    end

    self:createStartButton()
end

function PANEL:createTitle()
    if self.tabs then self.tabs:DockMargin(64, 32, 64, 0) end
end

function PANEL:hideExternalEntities()
    self.hiddenEntities = {}
    for _, ent in ents.Iterator() do
        if ent ~= self.modelEntity and not ent:IsWorld() and not ent:CreatedByMap() then
            self.hiddenEntities[ent] = ent:GetNoDraw()
            ent:SetNoDraw(true)
        end
    end
end

function PANEL:restoreExternalEntities()
    if not self.hiddenEntities then return end
    for ent, wasHidden in pairs(self.hiddenEntities) do
        if IsValid(ent) then ent:SetNoDraw(wasHidden) end
    end

    self.hiddenEntities = nil
end

function PANEL:loadBackground()
    if self.isLoadMode then
        self:hideExternalEntities()
        hook.Add("PrePlayerDraw", "liaMainMenuPrePlayerDraw", function() return true end)
        self:updateSelectedCharacter()
        if not IsValid(self.leftArrow) and self.availableCharacters and #self.availableCharacters > 1 then self:createArrows() end
        hook.Add("CalcView", "liaMainMenuCalcView", function(_, _, _, fov)
            local ent = self.modelEntity
            if not IsValid(ent) then return end
            local center = ent:GetPos() + Vector(0, 0, 60)
            local desired = center + Vector(0, -70, 0)
            self.currentCamPos = self.currentCamPos and LerpVector(FrameTime() * 5, self.currentCamPos, desired) or desired
            return {
                origin = self.currentCamPos,
                angles = (center - self.currentCamPos):Angle(),
                fov = fov,
                drawviewer = true
            }
        end)
    else
        self:restoreExternalEntities()
        if IsValid(self.modelEntity) then self.modelEntity:Remove() end
        if IsValid(self.leftArrow) then
            self.leftArrow:Remove()
            self.leftArrow = nil
        end

        if IsValid(self.rightArrow) then
            self.rightArrow:Remove()
            self.rightArrow = nil
        end

        local url = lia.config.get("BackgroundURL")
        if url and url:find("%S") then
            self.background = self:Add("DHTML")
            self.background:SetSize(ScrW(), ScrH())
            if url:find("http") then
                self.background:OpenURL(url)
            else
                self.background:SetHTML(url)
            end

            self.background.OnDocumentReady = function() if IsValid(self.bgLoader) then self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end end
            self.background:MoveToBack()
            self.background:SetZPos(-999)
            if lia.config.get("CharMenuBGInputDisabled") then
                self.background:SetMouseInputEnabled(false)
                self.background:SetKeyboardInputEnabled(false)
            end

            self.bgLoader = self:Add("DPanel")
            self.bgLoader:SetSize(ScrW(), ScrH())
            self.bgLoader:SetZPos(-998)
            self.bgLoader.Paint = function(_, w, h)
                surface.SetDrawColor(5, 5, 5)
                surface.DrawRect(0, 0, w, h)
            end
        end
    end
end

function PANEL:createStartButton()
    local client = LocalPlayer()
    if not IsValid(client) then
        timer.Simple(0.1, function() if IsValid(self) then self:createStartButton() end end)
        return
    end

    local clientChar = client.getChar and client:getChar()
    local w, h, s = ScrW() * 0.2, ScrH() * 0.04, ScrH() * 0.01
    local logoPath = lia.config.get("CenterLogo")
    local discordURL = lia.config.get("DiscordURL", "")
    local workshopURL = lia.config.get("Workshop", "")
    local buttonsData = {}
    local hasStaffChar, hasNonStaffChar = false, false
    if lia.characters and #lia.characters > 0 then
        for _, charID in pairs(lia.characters) do
            local character = lia.char.getCharacter(charID)
            if character then
                if character:getFaction() == FACTION_STAFF then
                    hasStaffChar = true
                else
                    hasNonStaffChar = true
                end
            end
        end
    end

    if hook.Run("CanPlayerCreateChar", client) ~= false then
        table.insert(buttonsData, {
            id = "create",
            text = "Create Character",
            doClick = function()
                for _, b in pairs(self.buttons) do
                    if IsValid(b) then b:Remove() end
                end

                self:clickSound()
                self.isLoadMode = false
                self:showContent(true)
                self:createCharacterCreation()
            end
        })
    end

    if hasNonStaffChar then
        table.insert(buttonsData, {
            id = "load",
            text = "Load Character",
            doClick = function()
                for _, b in pairs(self.buttons) do
                    if IsValid(b) then b:Remove() end
                end

                self:clickSound()
                self.availableCharacters = {}
                for _, charID in pairs(lia.characters or {}) do
                    local character = lia.char.getCharacter(charID)
                    if character and character:getFaction() ~= FACTION_STAFF then table.insert(self.availableCharacters, charID) end
                end

                self.currentIndex = 1
                self.isLoadMode = true
                self:showContent(true)
                self:createCharacterSelection()
            end
        })
    end

    if client:hasPrivilege("createStaffCharacter") and not client:isStaffOnDuty() then
        table.insert(buttonsData, {
            id = "staff",
            text = hasStaffChar and "Load Staff Character" or "Create Staff Character",
            doClick = function()
                for _, b in pairs(self.buttons) do
                    if IsValid(b) then b:Remove() end
                end

                self:clickSound()
                if hasStaffChar then
                    for _, charID in pairs(lia.characters) do
                        local character = lia.char.getCharacter(charID)
                        if character and character:getFaction() == FACTION_STAFF then
                            lia.module.list["mainmenu"]:chooseCharacter(character:getID()):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
                            break
                        end
                    end
                else
                    self:createStaffCharacter()
                end
            end
        })
    end

    if discordURL ~= "" then
        table.insert(buttonsData, {
            id = "discord",
            text = "Discord",
            doClick = function()
                self:clickSound()
                gui.OpenURL(discordURL)
            end
        })
    end

    if workshopURL ~= "" then
        table.insert(buttonsData, {
            id = "workshop",
            text = "Workshop",
            doClick = function()
                self:clickSound()
                gui.OpenURL(workshopURL)
            end
        })
    end

    if lia.workshop.hasContentToDownload and lia.workshop.hasContentToDownload() then
        table.insert(buttonsData, {
            id = "mount",
            text = "Mount Content",
            doClick = function()
                self:clickSound()
                if lia.workshop and lia.workshop.mountContent then
                    lia.workshop.mountContent()
                else
                    net.Start("liaWorkshopDownloaderRequest")
                    net.SendToServer()
                end
            end
        })
    end

    table.insert(buttonsData, {
        id = "disconnect",
        text = "Disconnect",
        doClick = function()
            self:clickSound()
            RunConsoleCommand("disconnect")
        end
    })

    if clientChar then
        table.insert(buttonsData, {
            id = "return",
            text = "Return",
            doClick = function() self:Remove() end
        })
    end

    self.buttons = {}
    for i, data in ipairs(buttonsData) do
        local x, y = ScrW() / 2 - w / 2, ScrH() * 0.3 + (i - 1) * (h + s)
        local btn = self:Add("liaMediumButton")
        btn:SetSize(w, h)
        btn:SetPos(x, y)
        btn:SetText(string.upper(data.text))
        btn.DoClick = data.doClick
        local oldSetPos = btn.SetPos
        btn.SetPos = function(b, nx, ny)
            oldSetPos(b, nx, ny)
            if IsValid(self) then self:UpdateLogoPosition() end
        end

        self.buttons[data.id] = btn
    end

    if logoPath ~= "" then
        local function setLogo(img)
            if not IsValid(self) then return end
            img:SetZPos(9999)
            self:UpdateLogoPosition()
            timer.Simple(0, function() if IsValid(img) then img:MoveToFront() end end)
        end

        if logoPath:sub(1, 8) == "https://" then
            http.Fetch(logoPath, function(body)
                if not IsValid(self) then return end
                file.Write("temp_logo.png", body)
                self.logo = self:Add("DImage")
                self.logo:SetImage("data/temp_logo.png")
                setLogo(self.logo)
            end)
        else
            self.logo = self:Add("DImage")
            self.logo:SetImage(logoPath)
            setLogo(self.logo)
        end
    end
end

function PANEL:addTab(name, callback, justClick, height)
    local btn = self.tabs:Add("liaMediumButton")
    surface.SetFont(btn:GetFont())
    local textW, textH = surface.GetTextSize(L(name):upper())
    btn:SetWide(textW + 40)
    btn:SetText(L(name):upper())
    btn:SetTall(height or textH + 20)
    if justClick then
        if isfunction(callback) then btn.DoClick = function() callback(self) end end
        return btn
    end

    btn.DoClick = function(b) b:setSelected(true) end
    if isfunction(callback) then btn:onSelected(function() callback(self) end) end
    return btn
end

function PANEL:createTabs()
    self.tabs:Clear()
    if not self.isKickedFromChar then self:addTab(L("returnText"), function() self:backToMainMenu() end, true) end
end

function PANEL:backToMainMenu()
    self:clickSound()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    if IsValid(self.selectBtn) then self.selectBtn:Remove() end
    if IsValid(self.deleteBtn) then self.deleteBtn:Remove() end
    for _, btn in pairs(self.buttons) do
        if IsValid(btn) then btn:Remove() end
    end

    self.buttons = {}
    self.isLoadMode = false
    self.disableClientModel = false
    self.content:Clear()
    self.tabs:Clear()
    self:createStartButton()
    self:loadBackground()
end

function PANEL:createCharacterSelection()
    self.isLoadMode = true
    for _, name in ipairs{"background", "logo"} do
        if IsValid(self[name]) then
            self[name]:Remove()
            self[name] = nil
        end
    end

    for _, b in pairs(self.buttons) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    self.content:Clear()
    self.content:InvalidateLayout(true)
    self:updateSelectedCharacter()
    if self.availableCharacters and #self.availableCharacters > 1 then self:createArrows() end
end

function PANEL:createCharacterCreation()
    for _, name in ipairs{"background", "logo"} do
        if IsValid(self[name]) then
            self[name]:Remove()
            self[name] = nil
        end
    end

    for _, b in pairs(self.buttons) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

function PANEL:createStaffCharacter()
    local client = LocalPlayer()
    local steamName = client:Nick()
    local staffData = {
        name = steamName,
        faction = FACTION_STAFF,
        model = 1,
        desc = "",
        skin = 0,
        groups = {}
    }

    lia.module.list["mainmenu"]:createCharacter(staffData):next(function(charID) lia.module.list["mainmenu"]:chooseCharacter(charID):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end) end):catch(function(err) LocalPlayer():notifyErrorLocalized(err or "Failed to create staff character") end)
end

function PANEL:updateSelectedCharacter()
    if not self.isLoadMode then return end
    local chars = self.availableCharacters or {}
    if #chars == 0 then return end
    self.currentIndex = self.currentIndex or 1
    local sel = chars[self.currentIndex] or chars[1]
    local character = lia.char.getCharacter(sel)
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.selectBtn) then self.selectBtn:Remove() end
    if IsValid(self.deleteBtn) then self.deleteBtn:Remove() end
    self:createSelectedCharacterInfoPanel(character)
    self:updateModelEntity(character)
end

function PANEL:createSelectedCharacterInfoPanel(character)
    if not character then return end
    local chars = self.availableCharacters or {}
    local total = #chars
    local index = 1
    for i, cID in ipairs(chars) do
        local cObj = isnumber(cID) and lia.char.getCharacter(cID) or cID
        if cObj and cObj.getID and cObj:getID() == character:getID() then
            index = i
            break
        end
    end

    local info = {L("name") .. ": " .. (character:getName() or ""), L("description") .. ":", character:getDesc() or "", L("faction") .. ": " .. (team.GetName(character:getFaction()) or "")}
    if character:getClass() then
        local cls = lia.class.list[character:getClass()]
        if cls and cls.name then table.insert(info, L("class") .. ": " .. cls.name) end
    end

    table.insert(info, L("money") .. ": " .. lia.currency.get(character:getMoney()))
    hook.Run("LoadMainMenuInformation", info, character)
    self.infoFrame = self:Add("SemiTransparentDFrame")
    self.infoFrame:SetSize(ScrW() * 0.25, ScrH() * 0.45)
    self.infoFrame:SetPos(ScrW() * 0.75 - 50, ScrH() * 0.25)
    self.infoFrame:SetTitle("")
    self.infoFrame:SetDraggable(false)
    self.infoFrame:ShowCloseButton(false)
    local scroll = vgui.Create("DScrollPanel", self.infoFrame)
    scroll:Dock(FILL)
    for i, text in ipairs(info) do
        if i == 1 then
            local line = scroll:Add("DPanel")
            line:Dock(TOP)
            line:DockMargin(10, 3, 10, 0)
            line:SetHeight(20)
            line.Paint = function() end
            local nameLabel = line:Add("DLabel")
            nameLabel:Dock(LEFT)
            nameLabel:SetFont("liaSmallFont")
            nameLabel:SetTextColor(Color(255, 255, 255))
            nameLabel:SetText(text)
            nameLabel:SizeToContents()
            nameLabel.Paint = function() end
            local countLabel = line:Add("DLabel")
            countLabel:Dock(RIGHT)
            countLabel:SetFont("liaSmallFont")
            countLabel:SetTextColor(Color(255, 255, 255))
            countLabel:SetText(index .. "/" .. total)
            countLabel:SizeToContents()
            countLabel.Paint = function() end
        else
            local lbl = scroll:Add("DLabel")
            lbl:Dock(TOP)
            lbl:DockMargin(10, 5, 10, 10)
            lbl:SetFont("liaSmallFont")
            lbl:SetWrap(true)
            lbl:SetAutoStretchVertical(true)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:SetText(text)
            lbl:SizeToContentsY()
        end
    end

    local spacer = scroll:Add("DPanel")
    spacer:Dock(TOP)
    spacer:SetTall(5)
    spacer.Paint = function() end
    local attrs = {}
    for id, attr in pairs(lia.attribs.list) do
        attrs[#attrs + 1] = {
            id = id,
            attr = attr
        }
    end

    table.sort(attrs, function(a, b) return a.attr.name < b.attr.name end)
    for _, entry in ipairs(attrs) do
        local minValue = entry.attr.min or 0
        local maxValue = entry.attr.max or 100
        local currentValue = character:getAttrib(entry.id) or minValue
        local label = scroll:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(10, 3, 10, 5)
        label:SetFont("liaSmallFont")
        label:SetTextColor(Color(255, 255, 255))
        label:SetText(entry.attr.name)
        label:SetContentAlignment(5)
        label:SizeToContentsY()
        local progressBar = scroll:Add("DProgressBar")
        progressBar:Dock(TOP)
        progressBar:DockMargin(10, 0, 10, 10)
        progressBar:SetBarColor(entry.attr.color or lia.config.get("Color"))
        progressBar:SetFraction(math.Clamp(currentValue / maxValue, 0, 1))
        progressBar:SetText(currentValue .. "/" .. maxValue)
        progressBar.Font = "liaSmallFont"
        progressBar:SetTall(20)
    end

    local fx, fy = self.infoFrame:GetPos()
    local fw, fh = self.infoFrame:GetWide(), self.infoFrame:GetTall()
    local bw, bh = fw * 0.85, 40
    local pad = 10
    local cx = fx + (fw - bw) * 0.5
    local clientChar = LocalPlayer().getChar and LocalPlayer():getChar()
    local selectText = L("select") .. " " .. L("character")
    if clientChar and character:getID() == clientChar:getID() then
        selectText = L("alreadyUsingCharacter")
    elseif character:isBanned() then
        selectText = L("permaKilledCharacter")
    end

    self.selectBtn = self:Add("liaSmallButton")
    self.selectBtn:SetSize(bw, bh)
    self.selectBtn:SetPos(cx, fy + fh + pad)
    self.selectBtn:SetText(selectText)
    if clientChar and character:getID() == clientChar:getID() then
        self.selectBtn:SetEnabled(false)
        self.selectBtn:SetTextColor(Color(255, 255, 255))
    end

    self.selectBtn.DoClick = function()
        if character:isBanned() then
            local characterName = character:getName()
            Derma_Query(L("pkDialogMessage", characterName), L("permaKillTitle"), L("iAcknowledge"), function() end)
            return
        end

        lia.module.list["mainmenu"]:chooseCharacter(character:getID()):next(function() if IsValid(self) then self:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
    end

    self.deleteBtn = self:Add("liaSmallButton")
    self.deleteBtn:SetSize(bw, bh)
    self.deleteBtn:SetPos(cx, fy + fh + pad + bh + pad)
    self.deleteBtn:SetText(L("delete") .. " " .. L("character"))
    self.deleteBtn.DoClick = function()
        if hook.Run("CanDeleteChar", character:getID()) == false then
            LocalPlayer():notifyErrorLocalized("cannotDeleteChar")
            return
        end

        vgui.Create("liaCharacterConfirm", self):setMessage(L("charDeletionAreYouSure") .. "\n" .. L("charDeletionCannotUndone")):onConfirm(function() lia.module.list["mainmenu"]:deleteCharacter(character:getID()) end)
    end
end

function PANEL:updateModelEntity(character)
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    if not character then return end
    local model = character.getModel and character:getModel() or LocalPlayer():GetModel()
    self.modelEntity = ClientsideModel(model, RENDERGROUP_OPAQUE)
    if not IsValid(self.modelEntity) then return end
    self.modelEntity:SetSkin(character:getSkin())
    local groups = character:getBodygroups()
    for i = 0, self.modelEntity:GetNumBodyGroups() - 1 do
        local value = groups[i]
        if value == nil then value = groups[tostring(i)] end
        if value ~= nil then self.modelEntity:SetBodygroup(i, tonumber(value) or 0) end
    end

    hook.Run("SetupPlayerModel", self.modelEntity, character)
    local pos, ang = hook.Run("GetMainMenuPosition", character)
    if not pos or not ang then
        local spawns = ents.FindByClass("info_player_start")
        pos = #spawns > 0 and spawns[1]:GetPos() or Vector()
        ang = #spawns > 0 and spawns[1]:GetAngles() or Angle()
    end

    ang.pitch, ang.roll = 0, 0
    ang.yaw = 265
    self.modelEntity:SetPos(pos)
    self.modelEntity:SetAngles(ang)
    for _, seq in ipairs(self.modelEntity:GetSequenceList()) do
        if seq:lower():find("idle") and seq ~= "idlenoise" then
            self.modelEntity:ResetSequence(seq)
            self.modelEntity:SetCycle(0)
            break
        end
    end

    hook.Run("ModifyCharacterModel", self.modelEntity, character)
    hook.Add("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables", function()
        if IsValid(self.modelEntity) then
            self.modelEntity:FrameAdvance()
            self.modelEntity:DrawModel()
        end
    end)
end

function PANEL:createArrows()
    local size, space = 100, 240
    local function newArrow(sign, xOffset)
        local btn = self:Add("liaBigButton")
        btn:SetSize(size, size)
        btn:SetPos(ScrW() * 0.5 + xOffset, ScrH() * 0.5 - size * 0.5)
        btn:SetFont("liaHugeFont")
        btn:SetText(sign)
        btn.DoClick = function()
            local chars = self.availableCharacters or {}
            if not self.isLoadMode or #chars == 0 then return end
            self.currentIndex = self.currentIndex + (sign == "<" and -1 or 1)
            if self.currentIndex < 1 then self.currentIndex = #chars end
            if self.currentIndex > #chars then self.currentIndex = 1 end
            self:clickSound()
            self:updateSelectedCharacter()
        end
        return btn
    end

    self.leftArrow = newArrow("<", -size - space)
    self.rightArrow = newArrow(">", space)
end

function PANEL:UpdateLogoPosition()
    if not IsValid(self.logo) then return end
    local pad = ScrH() * 0.01
    local logoW, logoH = ScrW() * 0.13 * 0.95, ScrW() * 0.13 * 0.95
    local left, right, top = math.huge, -math.huge, math.huge
    for _, v in pairs(self.buttons) do
        if IsValid(v) then
            local x, y = v:GetPos()
            left = math.min(left, x)
            right = math.max(right, x + v:GetWide())
            top = math.min(top, y)
        end
    end

    top = top == math.huge and ScrH() * 0.5 or top
    local center = (left + right) * 0.5
    self.logo:SetPos(center - logoW * 0.5, top - logoH - pad)
    self.logo:SetSize(logoW, logoH)
end

function PANEL:showContent(disableBg)
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    if IsValid(self.logo) then
        self.logo:Remove()
        self.logo = nil
    end

    for _, b in pairs(self.buttons) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    self.disableClientModel = true
    self:removeClientModelModifications()
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
    self.noBlur = self.isLoadMode or false
    if self.isLoadMode or not disableBg then self:loadBackground() end
end

function PANEL:removeClientModelModifications()
    hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
    if not self.isLoadMode then hook.Remove("CalcView", "liaMainMenuCalcView") end
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
end

function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local p = vgui.Create("DPanel")
        p:SetSize(ScrW(), ScrH())
        p:SetSkin("Default")
        p:SetBackgroundColor(color_black)
        p:SetAlpha(0)
        p:AlphaTo(255, 0.5, 0, function() d:resolve() end)
        p:SetZPos(999)
        p:MakePopup()
        self.fade = p
    else
        if IsValid(self.fade) then
            local p = self.fade
            p:AlphaTo(0, 0.5, 0, function()
                p:Remove()
                d:resolve()
            end)
        end
    end
    return d
end

function PANEL:fadeOut()
    self:AlphaTo(0, 0.1, 0, function() self:Remove() end)
end

function PANEL:Paint(w, h)
    if not self.noBlur then lia.util.drawBlur(self) end
    self:paintBackground(w, h)
end

function PANEL:paintBackground(w, h)
    if not IsValid(self.background) and self.blank then
        surface.SetDrawColor(42, 42, 42, 179)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:hoverSound()
    LocalPlayer():EmitSound("buttons/button15.wav", 35, 250)
end

function PANEL:clickSound()
    LocalPlayer():EmitSound("buttons/button14.wav", 35, 255)
end

function PANEL:warningSound()
    LocalPlayer():EmitSound("friends/friend_join.wav", 40, 255)
end

function PANEL:OnRemove()
    if lia.gui.character == self then lia.gui.character = nil end
    hook.Run("CharacterMenuClosed")
    self:restoreExternalEntities()
    hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
    hook.Remove("CalcView", "liaMainMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
    hook.Remove("PreDrawPhysgunBeam", "liaMainMenuPreDrawPhysgunBeam")
    if render.oldDrawBeam then
        render.DrawBeam = render.oldDrawBeam
        render.oldDrawBeam = nil
    end

    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
end

function PANEL:Think()
    if IsValid(self.logo) then
        self.logo:SetZPos(9999)
        self.logo:MoveToFront()
        self:UpdateLogoPosition()
    end

    if self.isLoadMode and IsValid(self.modelEntity) then
        local ang = self.modelEntity:GetAngles()
        local rotate = 0
        if input.IsKeyDown(KEY_A) then rotate = rotate + FrameTime() * 120 end
        if input.IsKeyDown(KEY_D) then rotate = rotate - FrameTime() * 120 end
        if rotate ~= 0 then
            ang.y = ang.y + rotate
            self.modelEntity:SetAngles(ang)
        end
    end
end

vgui.Register("liaCharacter", PANEL, "EditablePanel")
