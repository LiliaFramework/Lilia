local xpos = xpos or 20
local ypos = ypos or 20
function MODULE:TicketFrame(requester, message, claimed)
    local mat_lightning = Material("icon16/lightning_go.png")
    local mat_arrow = Material("icon16/arrow_left.png")
    local mat_link = Material("icon16/link.png")
    local mat_case = Material("icon16/briefcase.png")
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
    function frm:Paint(paintWidth, paintHeight)
        draw.RoundedBox(0, 0, 0, paintWidth, paintHeight, Color(10, 10, 10, 230))
    end

    frm.lblTitle:SetColor(Color(255, 255, 255))
    frm.lblTitle:SetFont("ticketsystem")
    frm.lblTitle:SetContentAlignment(7)
    if claimed and IsValid(claimed) and claimed:IsPlayer() then
        frm:SetTitle(L("ticketTitleClaimed", requester:Nick(), claimed:Nick()))
        if claimed == LocalPlayer() then
            function frm:Paint(paintWidth, paintHeight)
                draw.RoundedBox(0, 0, 0, paintWidth, paintHeight, Color(10, 10, 10, 230))
                draw.RoundedBox(0, 2, 2, paintWidth - 4, 16, Color(38, 166, 91))
            end
        else
            function frm:Paint(paintWidth, paintHeight)
                draw.RoundedBox(0, 0, 0, paintWidth, paintHeight, Color(10, 10, 10, 230))
                draw.RoundedBox(0, 2, 2, paintWidth - 4, 16, Color(207, 0, 15))
            end
        end
    else
        frm:SetTitle(requester:Nick())
    end

    local msg = vgui.Create("RichText", frm)
    msg:SetPos(10, 30)
    msg:SetSize(190, frameHeight - 35)
    msg:SetContentAlignment(7)
    msg:SetVerticalScrollbarEnabled(false)
    function msg:PerformLayout()
        self:SetFontInternal("DermaDefault")
    end

    msg:AppendText(message)
    local function createButton(text, material, position, clickFunc, disabled)
        text = L(text)
        local btn = vgui.Create("liaButton", frm)
        btn:SetPos(215, position)
        btn:SetSize(83, 18)
        btn:SetText("          " .. text)
        btn:SetColor(Color(255, 255, 255))
        btn:SetContentAlignment(4)
        btn.Disabled = disabled
        btn.DoClick = function() if not btn.Disabled then clickFunc() end end
        btn.Paint = function(panel, paintWidth, paintHeight)
            if panel.Depressed or panel.m_bSelected then
                draw.RoundedBox(1, 0, 0, paintWidth, paintHeight, Color(255, 50, 50, 255))
            elseif panel.Hovered and not panel.Disabled then
                draw.RoundedBox(1, 0, 0, paintWidth, paintHeight, Color(205, 30, 30, 255))
            else
                draw.RoundedBox(1, 0, 0, paintWidth, paintHeight, panel.Disabled and Color(100, 100, 100, 255) or Color(80, 80, 80, 255))
            end

            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(material)
            surface.DrawTexturedRect(5, 1, 16, 16)
        end

        if disabled then btn:SetTooltip(L("ticketActionSelf")) end
        return btn
    end

    local isLocalPlayer = requester == LocalPlayer()
    createButton("goTo", mat_lightning, 20, function() lia.administrator.execCommand("goto", requester) end, isLocalPlayer)
    createButton("returnText", mat_arrow, 40, function() lia.administrator.execCommand("return", requester) end, isLocalPlayer)
    createButton("freeze", mat_link, 60, function() lia.administrator.execCommand("freeze", requester) end, isLocalPlayer)
    createButton("bring", mat_arrow, 80, function() lia.administrator.execCommand("bring", requester) end, isLocalPlayer)
    local shouldClose = false
    local claimButton
    claimButton = createButton("claimCase", mat_case, 100, function()
        if not shouldClose then
            if frm.lblTitle:GetText():lower():find(L("claimedBy"):lower()) then
                chat.AddText(Color(255, 150, 0), "[" .. L("error") .. "] " .. L("caseAlreadyClaimed"))
                surface.PlaySound("common/wpn_denyselect.wav")
            else
                net.Start("liaTicketSystemClaim")
                net.WriteEntity(requester)
                net.SendToServer()
                shouldClose = true
                claimButton:SetText("          " .. L("closeCase"))
            end
        else
            net.Start("liaTicketSystemClose")
            net.WriteEntity(requester)
            net.SendToServer()
        end
    end, isLocalPlayer)

    local closeButton = vgui.Create("liaButton", frm)
    closeButton:SetText("")
    closeButton:SetTooltip(L("close"))
    closeButton:SetColor(Color(255, 255, 255))
    closeButton:SetPos(frameWidth - 18, 2)
    closeButton:SetSize(16, 16)
    function closeButton:Paint()
    end

    closeButton.DoClick = function() frm:Close() end
    frm:ShowCloseButton(false)
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
