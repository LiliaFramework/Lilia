if SERVER then
    --[[
        lia.notices.notify(message, recipient)

        Description:
            Sends a notification message to a specific player or all players.

        Parameters:
            message (string) – Message text to send.
            recipient (Player|nil) – Target player, or nil to broadcast.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.notices.notify(message, recipient)
        net.Start("liaNotify")
        net.WriteString(message)
        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    end

    --[[
        lia.notices.notifyLocalized(key, recipient, ...)

        Description:
            Sends a localized notification to a player or all players.

        Parameters:
            key (string) – Localization key.
            recipient (Player|nil) – Target player or nil to broadcast.
            ... (any) – Formatting arguments for the localization string.

        Realm:
            Server

        Returns:
            None
    ]]
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
        local scrW = ScrW()
        for k, v in ipairs(lia.notices) do
            v:MoveTo(scrW - (v:GetWide() + 4), (k - 1) * (v:GetTall() + 4) + 4, 0.15, k / #lia.notices * 0.25)
        end
    end

    --[[
        lia.notices.notify(message)

        Description:
            Creates a visual notification panel on the client's screen.

        Parameters:
            message (string) – Message text to display.

        Realm:
            Client

        Returns:
            None
    ]]
    function lia.notices.notify(message)
        local notice = vgui.Create("liaNotice")
        local i = table.insert(lia.notices, notice)
        local scrW = ScrW()
        notice:SetText(message)
        notice:SetPos(scrW, (i - 1) * (notice:GetTall() + 4) + 4)
        notice:SizeToContentsX()
        notice:SetWide(notice:GetWide() + 16)
        notice.start = CurTime() + 0.25
        notice.endTime = CurTime() + 7.75
        OrganizeNotices()
        MsgC(Color(0, 255, 255), message .. "\n")
        timer.Simple(0.15, function() LocalPlayer():EmitSound(unpack({"garrysmod/content_downloaded.wav", 50, 250})) end)
        timer.Simple(7.75, function()
            if IsValid(notice) then
                for k, v in ipairs(lia.notices) do
                    if v == notice then
                        notice:MoveTo(scrW, notice.y, 0.15, 0.1, nil, function() notice:Remove() end)
                        table.remove(lia.notices, k)
                        OrganizeNotices()
                        break
                    end
                end
            end
        end)

        MsgN(message)
    end

    --[[
        lia.notices.notifyLocalized(key, ...)

        Description:
            Displays a localized notification on the client's screen.

        Parameters:
            key (string) – Localization key.
            ... (any) – Formatting arguments for the localization string.

        Realm:
            Client

        Returns:
            None
    ]]
    function lia.notices.notifyLocalized(key, ...)
        lia.notices.notify(L(key, ...))
    end

    --[[
        notification.AddLegacy(text)

        Description:
            Overrides Garry's Mod legacy notification to use lia.notices.

        Parameters:
            text (string) – Message text to display.

        Realm:
            Client

        Returns:
            None
    ]]
    function notification.AddLegacy(text)
        lia.notices.notify(tostring(text))
    end
end
