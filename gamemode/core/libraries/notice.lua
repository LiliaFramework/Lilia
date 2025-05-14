if SERVER then
    function lia.notices.notify(message, recipient)
        net.Start("liaNotify")
        net.WriteString(message)
        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end

    function lia.notices.notifyLocalized(key, recipient, ...)
        local args = {...}
        if recipient and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotifyL")
        net.WriteString(key)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end
else
    local function OrganizeNotices()
        local baseY = 10
        local validNotices = {}
        for _, notice in ipairs(lia.notices) do
            if IsValid(notice) then validNotices[#validNotices + 1] = notice end
        end

        while #validNotices > 6 do
            local old = table.remove(validNotices, 1)
            if IsValid(old) then old:Remove() end
        end

        local leftCount = #validNotices > 3 and #validNotices - 3 or 0
        for i, notice in ipairs(validNotices) do
            local x, y
            if i <= leftCount then
                x = 10
                y = baseY + (i - 1) * (notice.oh + 5)
            else
                local idx = i - leftCount
                x = ScrW() - notice:GetWide() - 10
                y = baseY + (idx - 1) * (notice.oh + 5)
            end

            notice:MoveTo(x, y, 0.15)
        end
    end

    function CreateNoticePanel(length, notimer)
        if not notimer then notimer = false end
        local notice = vgui.Create("noticePanel")
        notice.start = CurTime() + 0.25
        notice.endTime = CurTime() + length
        notice.oh = notice:GetTall()
        function notice:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
            if self.start then
                local progress = math.TimeFraction(self.start, self.endTime, CurTime()) * w
                draw.RoundedBox(4, 0, 0, progress, h, lia.config.get("Color"))
            end
        end

        if not notimer then timer.Simple(length, function() RemoveNotices(notice) end) end
        return notice
    end

    local function DisplayNotice(message, manualDismiss)
        manualDismiss = manualDismiss or false
        local notice = CreateNoticePanel(10, manualDismiss)
        table.insert(lia.notices, notice)
        notice.text:SetText(message)
        notice:SetTall(36 * 1.8)
        notice:CalcWidth(120)
        if manualDismiss then notice.start = nil end
        notice.oh = notice:GetTall()
        notice:SetTall(0)
        local x = ScrW() / 2 - notice:GetWide() / 2
        notice:SetPos(x, 4)
        notice:SizeTo(notice:GetWide(), 36 * 1.8, 0.2, 0, -1, function() notice.text:SetPos(0, 0) end)
        if not manualDismiss then timer.Simple(5, function() if IsValid(notice) then RemoveNotices(notice) end end) end
        timer.Simple(0.05, OrganizeNotices)
    end

    function RemoveNotices(notice)
        if not IsValid(notice) then return end
        for i, v in ipairs(lia.notices) do
            if v == notice then
                notice:SizeTo(notice:GetWide(), 0, 0.2, 0, -1, function() if IsValid(notice) then notice:Remove() end end)
                table.remove(lia.notices, i)
                timer.Simple(0.25, OrganizeNotices)
                break
            end
        end
    end

    function lia.notices.notify(message)
        DisplayNotice(message, false)
        MsgN(message)
    end

    function lia.notices.notifyLocalized(key, ...)
        lia.notices.notify(L(key, ...))
    end

    function notification.AddLegacy(text)
        lia.notices.notify(tostring(text))
    end
end