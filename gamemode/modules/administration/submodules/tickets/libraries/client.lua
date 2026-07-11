function MODULE:PopulateAdminTabs(pages)
    return
end

MODULE.TicketFrames = MODULE.TicketFrames or {}
local xpos = xpos or 20
local ypos = ypos or 20
local function getThemeAccent()
    local theme = lia.color.theme or {}
    return theme.accent or theme.header or theme.theme or Color(184, 132, 74)
end

local function getThemeText()
    local theme = lia.color.theme or {}
    return theme.text or Color(230, 238, 236)
end

local function drawRoundedPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

function MODULE:CreateTicketFrame(requester, message, claimed)
    self.TicketFrames = self.TicketFrames or {}
    local ticketFrames = self.TicketFrames
    if not IsValid(requester) or not requester:IsPlayer() then return end
    local requesterSteamID = requester:SteamID()
    for _, v in pairs(ticketFrames) do
        if v.requesterSteamID == requesterSteamID then
            local messageEntry = v.messageEntry
            if IsValid(messageEntry) then
                local existingText = messageEntry:GetValue() or ""
                messageEntry:SetText(existingText ~= "" and existingText .. "\n" .. message or message)
                messageEntry:GotoTextEnd()
                lia.websound.playButtonSound("ui/hint.wav")
            end
            return
        end
    end

    local frameWidth = 500
    local frameHeight = 260
    local headerHeight = 44
    local contentPadding = 12
    local actionWidth = 142
    local actionGap = 7
    local messageWidth = frameWidth - actionWidth - contentPadding * 3
    local claimedValid = IsValid(claimed) and claimed:IsPlayer()
    local claimedByLocal = claimedValid and claimed == LocalPlayer()
    local title = claimedValid and L("ticketTitleClaimed", requester:Nick(), claimed:Nick()) or requester:Nick()
    local frm = vgui.Create("liaFrame")
    frm:SetSize(frameWidth, frameHeight)
    frm:SetPos(xpos, ypos)
    frm.idiot = requester
    frm.requesterSteamID = requesterSteamID
    frm:SetTitle(title)
    frm:ShowCloseButton(false)
    frm:SetDraggable(true)
    frm:SetSizable(false)
    frm.Paint = function(panel, w, h)
        local accent = getThemeAccent()
        local textColor = getThemeText()
        local headerAccent = panel.headerColor or accent
        drawRoundedPanel(0, 0, w, h, 9, Color(2, 13, 18, 248), Color(headerAccent.r, headerAccent.g, headerAccent.b, 150))
        drawRoundedPanel(1, 1, w - 2, h - 2, 8, Color(5, 21, 27, 245))
        lia.derma.rect(1, 1, w - 2, headerHeight):Radii(8, 8, 0, 0):Color(Color(2, 14, 18, 252)):Draw()
        surface.SetDrawColor(headerAccent.r, headerAccent.g, headerAccent.b, 105)
        surface.DrawRect(contentPadding, headerHeight, w - contentPadding * 2, 1)
        surface.SetMaterial(Material("icon16/shield.png"))
        surface.SetDrawColor(headerAccent.r, headerAccent.g, headerAccent.b, 235)
        surface.DrawTexturedRect(14, 14, 16, 16)
        draw.SimpleText(panel.title or requester:Nick(), "LiliaFont.18", 38, 22, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if claimedValid and claimed ~= LocalPlayer() then frm.headerColor = Color(215, 85, 75) end
    local msg = vgui.Create("DTextEntry", frm)
    frm.messageEntry = msg
    msg:SetPos(contentPadding, headerHeight + 12)
    msg:SetSize(messageWidth, frameHeight - headerHeight - 24)
    msg:SetText(message)
    msg:SetFont("LiliaFont.18")
    msg:SetMultiline(true)
    msg:SetEditable(true)
    msg:SetMouseInputEnabled(true)
    msg:SetKeyboardInputEnabled(true)
    msg:SetPaintBackground(false)
    msg:SetDrawBackground(false)
    msg:SetDrawBorder(false)
    msg:SetVerticalScrollbarEnabled(true)
    msg.Paint = function(panel, w, h)
        local accent = getThemeAccent()
        local textColor = getThemeText()
        drawRoundedPanel(0, 0, w, h, 6, Color(3, 16, 21, 245), Color(accent.r, accent.g, accent.b, 80))
        panel:DrawTextEntryText(textColor, Color(accent.r, accent.g, accent.b, 70), Color(accent.r, accent.g, accent.b, 255))
    end

    local actionPanel = vgui.Create("DPanel", frm)
    actionPanel:SetPos(contentPadding * 2 + messageWidth, headerHeight + 12)
    actionPanel:SetSize(actionWidth, frameHeight - headerHeight - 24)
    actionPanel.Paint = nil
    local buttonIcons = {
        goTo = Material("icon16/arrow_right.png"),
        returnText = Material("icon16/arrow_redo.png"),
        freeze = Material("icon16/lock.png"),
        bring = Material("icon16/arrow_down.png"),
        claimCase = Material("icon16/shield.png")
    }

    local function createButton(textKey, clickFunc, disabled, primary)
        local btn = vgui.Create("DButton", actionPanel)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, actionGap)
        btn:SetTall(30)
        btn:SetText("")
        btn.Disabled = disabled
        btn.label = L(textKey)
        btn.icon = buttonIcons[textKey]
        btn.primary = primary
        btn.Paint = function(button, w, h)
            local accent = getThemeAccent()
            local textColor = getThemeText()
            local disabledColor = Color(120, 130, 132)
            local hovered = button:IsHovered() and not button.Disabled
            local pressed = button:IsDown() and not button.Disabled
            local fillAlpha = button.primary and 20 or 6
            if hovered then fillAlpha = button.primary and 44 or 24 end
            if pressed then fillAlpha = 58 end
            drawRoundedPanel(0, 0, w, h, 5, Color(accent.r, accent.g, accent.b, fillAlpha), Color(accent.r, accent.g, accent.b, button.Disabled and 35 or hovered and 170 or 95))
            local color = button.Disabled and disabledColor or textColor
            if button.icon and not button.icon:IsError() then
                surface.SetMaterial(button.icon)
                surface.SetDrawColor(color.r, color.g, color.b, button.Disabled and 110 or 220)
                surface.DrawTexturedRect(11, 7, 16, 16)
            end

            draw.SimpleText(button.label, "LiliaFont.16", 36, h * 0.5, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            if btn.Disabled then return end
            clickFunc()
            lia.websound.playButtonSound()
        end

        if disabled then btn:SetTooltip(L("ticketActionSelf")) end
        return btn
    end

    local isLocalPlayer = requester == LocalPlayer()
    createButton("goTo", function() lia.admin.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", function() lia.admin.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", function() lia.admin.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", function() lia.admin.execCommand("bring", requester) end, isLocalPlayer)
    local shouldClose = claimedByLocal
    local claimButton
    claimButton = createButton(claimedByLocal and "closeCase" or "claimCase", function()
        if not IsValid(frm) then return end
        if not shouldClose then
            if claimedValid and claimed ~= LocalPlayer() then
                chat.AddText(Color(255, 150, 0), "[" .. L("error") .. "] " .. L("caseAlreadyClaimed"))
                surface.PlaySound("common/wpn_denyselect.wav")
                return
            end

            net.Start("liaTicketSystemClaim")
            net.WriteEntity(requester)
            net.SendToServer()
            shouldClose = true
            claimButton.label = L("closeCase")
        else
            net.Start("liaTicketSystemClose")
            net.WriteEntity(requester)
            net.SendToServer()
        end
    end, isLocalPlayer, true)

    local closeButton = vgui.Create("DButton", frm)
    closeButton:SetText("")
    closeButton:SetTooltip(L("close"))
    closeButton:SetSize(30, 30)
    closeButton:SetPos(frameWidth - 36, 7)
    closeButton.Paint = function(button, w, h)
        local accent = getThemeAccent()
        local color = button:IsHovered() and Color(235, 105, 95) or Color(accent.r, accent.g, accent.b, 220)
        surface.SetDrawColor(color)
        surface.DrawLine(10, 10, w - 10, h - 10)
        surface.DrawLine(w - 10, 10, 10, h - 10)
    end

    closeButton.DoClick = function() if IsValid(frm) then frm:Remove() end end
    local stackSpacing = frameHeight + 12
    frm:SetPos(xpos, ypos + stackSpacing * #ticketFrames)
    frm:MoveTo(xpos, ypos + stackSpacing * #ticketFrames, 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        table.RemoveByValue(ticketFrames, frm)
        for k, v in ipairs(ticketFrames) do
            if IsValid(v) then v:MoveTo(xpos, ypos + stackSpacing * (k - 1), 0.1, 0, 1) end
        end
    end

    table.insert(ticketFrames, frm)
end
