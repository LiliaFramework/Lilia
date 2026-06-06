function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canAlwaysSeeTickets = client:hasPrivilege("alwaysSeeTickets")
    local isStaffOnDuty = client:isStaffOnDuty()
    local canSeeTickets = canAlwaysSeeTickets or isStaffOnDuty
    if canSeeTickets then
        table.insert(pages, {
            name = "tickets",
            icon = "icon16/report.png",
            drawFunc = function(panel)
                ticketPanel = panel
                net.Start("liaRequestActiveTickets")
                net.SendToServer()
            end
        })
    end
end

MODULE.TicketFrames = MODULE.TicketFrames or {}
local xpos = xpos or 20
local ypos = ypos or 20
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

    local frameWidth, frameHeight = 400, 160
    local frm = vgui.Create("liaFrame")
    frm:SetSize(frameWidth, frameHeight)
    frm:SetPos(xpos, ypos)
    frm.idiot = requester
    frm.requesterSteamID = requesterSteamID
    frm:ShowCloseButton(false)
    if claimed and IsValid(claimed) and claimed:IsPlayer() then
        frm:SetTitle(L("ticketTitleClaimed", requester:Nick(), claimed:Nick()))
        if claimed ~= LocalPlayer() then frm.headerColor = Color(207, 0, 15) end
    else
        frm:SetTitle(requester:Nick())
    end

    local msg = vgui.Create("liaEntry", frm)
    frm.messageEntry = msg
    msg:SetPos(10, 30)
    msg:SetSize(280, frameHeight - 35)
    msg:SetText(message)
    msg:SetMultiline(true)
    msg:SetEditable(true)
    msg:AllowInput(function() return true end)
    msg:SetMouseInputEnabled(true)
    msg:SetKeyboardInputEnabled(true)
    msg:SetPaintBackground(false)
    if IsValid(msg.textEntry) then
        msg.textEntry:SetEditable(true)
        msg.textEntry:SetMouseInputEnabled(true)
        msg.textEntry:SetKeyboardInputEnabled(true)
        if msg.textEntry.SetVerticalScrollbarEnabled then msg.textEntry:SetVerticalScrollbarEnabled(true) end
    end
    msg.Paint = function(panel, w, h)
        lia.derma.rect(0, 0, w, h):Rad(4):Color((lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1]) or Color(34, 62, 62)):Shape(lia.derma.SHAPE_IOS):Draw()
        panel:DrawTextEntryText((lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235))
    end

    local function createButton(text, position, clickFunc, disabled)
        text = L(text)
        local btn = vgui.Create("liaButton", frm)
        btn:SetPos(300, position)
        btn:SetSize(83, 18)
        btn:SetText(text)
        btn.Disabled = disabled
        btn.DoClick = function() if not btn.Disabled then clickFunc() end end
        if disabled then btn:SetTooltip(L("ticketActionSelf")) end
        return btn
    end

    local isLocalPlayer = requester == LocalPlayer()
    createButton("goTo", 35, function() lia.admin.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", 60, function() lia.admin.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", 85, function() lia.admin.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", 110, function() lia.admin.execCommand("bring", requester) end, isLocalPlayer)
    local shouldClose = false
    local claimButton
    claimButton = createButton("claimCase", 135, function()
        if not IsValid(frm) then return end
        if not frm.title then return end
        if not shouldClose then
            local title = frm.title
            if title and title:lower():find(L("claimedBy"):lower()) then
                chat.AddText(Color(255, 150, 0), "[" .. L("error") .. "] " .. L("caseAlreadyClaimed"))
                surface.PlaySound("common/wpn_denyselect.wav")
            else
                net.Start("liaTicketSystemClaim")
                net.WriteEntity(requester)
                net.SendToServer()
                shouldClose = true
                claimButton:SetText(L("closeCase"))
            end
        else
            net.Start("liaTicketSystemClose")
            net.WriteEntity(requester)
            net.SendToServer()
        end
    end, isLocalPlayer)

    local closeButton = vgui.Create("liaButton", frm)
    closeButton:SetText("X")
    closeButton:SetTooltip(L("close"))
    closeButton:SetPos(frameWidth - 18, 2)
    closeButton:SetSize(16, 16)
    closeButton.DoClick = function() frm:Remove() end
    frm:SetPos(xpos, ypos + 180 * #ticketFrames)
    frm:MoveTo(xpos, ypos + 180 * #ticketFrames, 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if ticketFrames then
            table.RemoveByValue(ticketFrames, frm)
            for k, v in ipairs(ticketFrames) do
                v:MoveTo(xpos, ypos + 180 * (k - 1), 0.1, 0, 1)
            end
        end
    end

    table.insert(ticketFrames, frm)
end
