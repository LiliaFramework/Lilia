lia.notices.Types = {
    [1] = {
        col = Color(200, 60, 60),
        icon = "icon16/exclamation.png"
    },
    [2] = {
        col = Color(255, 100, 100),
        icon = "icon16/cross.png"
    },
    [3] = {
        col = Color(255, 100, 100),
        icon = "icon16/cancel.png"
    },
    [4] = {
        col = Color(100, 185, 255),
        icon = "icon16/book.png"
    },
    [5] = {
        col = Color(64, 185, 85),
        icon = "icon16/accept.png"
    },
    [7] = {
        col = Color(100, 185, 255),
        icon = "icon16/information.png"
    }
}

function RemoveNotices(notice)
    for k, v in ipairs(lia.notices) do
        if v == notice then
            notice:SizeTo(notice:GetWide(), 0, 0.2, 0, -1, function() notice:Remove() end)
            table.remove(lia.notices, k)
            OrganizeNotices(true)
            break
        end
    end
end

function CreateNoticePanel(length, notimer)
    if not notimer then notimer = false end
    local notice = vgui.Create("noticePanel")
    notice.start = CurTime() + 0.25
    notice.endTime = CurTime() + length
    notice.oh = notice:GetTall()
    function notice:Paint(w, h)
        local t = lia.notices.Types[7]
        local mat
        if self.notifType ~= nil and not isstring(self.notifType) and self.notifType > 0 then
            t = lia.notices.Types[self.notifType]
            mat = lia.util.getMaterial(t.icon)
        end

        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
        if self.start then
            local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
            local col = (t and t.col) or lia.config.Color
            draw.RoundedBox(4, w2, 0, w - w2, h, col)
        end

        if t and mat then
            local sw, sh = 24, 24
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(20, h / 2 - sh / 2, sw, sh)
        end
    end

    if not notimer then timer.Simple(length, function() RemoveNotices(notice) end) end
    return notice
end

function OrganizeNotices(alternate)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100
    if alternate then
        for k, v in ipairs(lia.notices) do
            if IsValid(v) then
                local topMargin = 0
                for k2, v2 in ipairs(lia.notices) do
                    if IsValid(v2) then if k < k2 then topMargin = topMargin + v2:GetTall() + 5 end end
                end

                v:MoveTo(v:GetX(), topMargin + 5, 0.15, 0, 5)
            end
        end
    else
        for k, v in ipairs(lia.notices) do
            if IsValid(v) then
                local height = lastHeight - v:GetTall() - 10
                v:MoveTo(scrW - v:GetWide(), height, 0.15, (k / #lia.notices) * 0.25, nil)
                lastHeight = height
            end
        end
    end
end

if SERVER then
    --- Notifies all players with a given message.
    -- @realm server
    -- @string msg The message to send to all players
    function lia.notices.notifyAll(msg)
        for _, v in pairs(player.GetAll()) do
            v:notify(msg)
        end
    end

    --- Notifies a player or all players with a message.
    -- @realm server
    -- @string message The message to be notified
    -- @client recipient The player to receive the notification
    function lia.notices.notify(message, recipient)
        net.Start("liaNotify")
        net.WriteString(message)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end

    --- Notifies a player or all players with a localized message.
    -- @realm server
    -- @string message The localized message to be notified
    -- @client recipient The player to receive the notification
    -- @param ... Additional parameters for message formatting
    function lia.notices.notifyLocalized(message, recipient, ...)
        local args = {...}
        if recipient ~= nil and not istable(recipient) and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotifyL")
        net.WriteString(message)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end

    lia.util.notifyAll = lia.notices.notifyAll
    lia.util.notify = lia.notices.notify
    lia.util.notifyLocalized = lia.notices.notifyLocalized
else
    function lia.notices.notify(message, shouldChatPrint)
        local notice = vgui.Create("liaNotify")
        local i = table.insert(lia.notices, notice)
        notice:SetMessage(message)
        notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4)
        notice:MoveToFront()
        OrganizeNotices(false)
        timer.Simple(10, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function()
                    notice:Remove()
                    for v, k in pairs(lia.notices) do
                        if k == notice then table.remove(lia.notices, v) end
                    end

                    OrganizeNotices(false)
                end)
            end
        end)

        if shouldChatPrint then chat.AddText(message) end
        MsgN(message)
    end

    --- Displays a localized notification message in the chat.
    -- @realm client
    -- @string message The message to display (localized)
    -- @param ... Additional parameters for string formatting
    function lia.notices.notifyLocalized(message, ...)
        lia.notices.notify(L(message, ...))
    end

    function notification.AddLegacy(text)
        lia.notices.notify(tostring(text))
    end

    lia.util.notify = lia.notices.notify
    lia.util.notifyLocalized = lia.notices.notifyLocalized
end