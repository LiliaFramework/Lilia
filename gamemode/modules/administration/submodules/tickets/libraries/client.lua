local xpos = xpos or 20
local ypos = ypos or 20
function MODULE:TicketFrame(requester, message, claimed)
    if not IsValid(requester) or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            local txt = v:GetChildren()[5]
            txt:AppendText("\n" .. message)
            txt:GotoTextEnd()
            timer.Remove("ticketsystem-" .. requester:SteamID())
            timer.Create("ticketsystem-" .. requester:SteamID(), 60, 1, function() if IsValid(v) then v:Remove() end end)
            surface.PlaySound("ui/hint.wav")
            return
        end
    end

    local frameWidth, frameHeight = 300, 120
    local frm = vgui.Create("liaFrame")
    frm:SetSize(frameWidth, frameHeight)
    frm:SetPos(xpos, ypos)
    frm.idiot = requester
    frm:ShowCloseButton(false)
    if claimed and IsValid(claimed) and claimed:IsPlayer() then
        frm:SetTitle(L("ticketTitleClaimed", requester:Nick(), claimed:Nick()))
        if claimed == LocalPlayer() then
            frm.headerColor = Color(38, 166, 91)
        else
            frm.headerColor = Color(207, 0, 15)
        end
    else
        frm:SetTitle(requester:Nick())
    end

    local msg = vgui.Create("SemiTransparentDPanel", frm)
    msg:SetPos(10, 30)
    msg:SetSize(190, frameHeight - 35)
    msg.message = message
    msg.Paint = function(panel, w, h)
        lia.derma.rect(0, 0, w, h):Rad(4):Color(lia.derma.getNextPanelColor()):Shape(lia.derma.SHAPE_IOS):Draw()
        draw.SimpleText(panel.message, "DermaDefault", w * 0.5, h * 0.5, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function createButton(text, position, clickFunc, disabled)
        text = L(text)
        local btn = vgui.Create("liaButton", frm)
        btn:SetPos(215, position)
        btn:SetSize(83, 18)
        btn:SetText(text)
        btn.Disabled = disabled
        btn.DoClick = function() if not btn.Disabled then clickFunc() end end
        if disabled then btn:SetTooltip(L("ticketActionSelf")) end
        return btn
    end

    local isLocalPlayer = requester == LocalPlayer()
    createButton("goTo", 20, function() lia.administrator.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", 40, function() lia.administrator.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", 60, function() lia.administrator.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", 80, function() lia.administrator.execCommand("bring", requester) end, isLocalPlayer)
    local shouldClose = false
    local claimButton
    claimButton = createButton("claimCase", 100, function()
        if not IsValid(frm) then return end
        if not shouldClose then
            if frm:GetTitle():lower():find(L("claimedBy"):lower()) then
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
    frm:SetPos(xpos, ypos + 130 * #TicketFrames)
    frm:MoveTo(xpos, ypos + 130 * #TicketFrames, 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if TicketFrames then
            table.RemoveByValue(TicketFrames, frm)
            for k, v in ipairs(TicketFrames) do
                v:MoveTo(xpos, ypos + 130 * (k - 1), 0.1, 0, 1)
            end
        end

        if IsValid(requester) and timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
    end

    table.insert(TicketFrames, frm)
    timer.Create("ticketsystem-" .. requester:SteamID(), 60, 1, function() if IsValid(frm) then frm:Remove() end end)
end
