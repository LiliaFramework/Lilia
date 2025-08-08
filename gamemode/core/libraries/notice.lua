--[[
# Notice Library

This page documents the functions for working with notification systems and user feedback.

---

## Overview

The notice library provides a system for displaying notifications and messages to players within the Lilia framework. It handles both localized and non-localized notifications, supports different display styles, and provides utilities for sending notices to individual players or broadcasting to all players. The library manages notice positioning and timing on the client side.
]]
if SERVER then
    --[[
        lia.notices.notify

        Purpose:
            Sends a notification message to a specific player or broadcasts it to all players.
            The message will be displayed as a notice on the client(s).

        Parameters:
            message (string)   - The message to display.
            recipient (Player) - (Optional) The player to send the notice to. If nil, broadcasts to all players.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Send a notice to a specific player
            lia.notices.notify("You have received a new item!", ply)

            -- Broadcast a notice to all players
            lia.notices.notify("The server will restart in 5 minutes!")
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
        lia.notices.notifyLocalized

        Purpose:
            Sends a localized notification to a specific player or broadcasts it to all players.
            The message is looked up using a localization key and optional arguments.

        Parameters:
            key (string)         - The localization key for the message.
            recipient (Player)   - (Optional) The player to send the notice to. If not a Player, treated as an argument.
            ... (vararg)         - Additional arguments to format into the localized message.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Send a localized notice to a specific player
            lia.notices.notifyLocalized("itemReceived", ply, "Health Kit")

            -- Broadcast a localized notice to all players
            lia.notices.notifyLocalized("serverRestartWarning", "5 minutes")
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
        lia.notices.notify

        Purpose:
            Displays a notification message on the client's screen as a notice.
            The notice will animate in, play a sound, and disappear after a set time.

        Parameters:
            message (string) - The message to display.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            -- Show a notice to the local player
            lia.notices.notify("You have joined the server!")

            -- Show a notice with a dynamic message
            lia.notices.notify("Welcome, " .. LocalPlayer():Nick() .. "!")
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
        lia.notices.notifyLocalized

        Purpose:
            Displays a localized notification message on the client's screen as a notice.
            The message is looked up using a localization key and optional arguments.

        Parameters:
            key (string)   - The localization key for the message.
            ... (vararg)   - Additional arguments to format into the localized message.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            -- Show a localized notice to the local player
            lia.notices.notifyLocalized("welcomeMessage", LocalPlayer():Nick())

            -- Show a localized notice with multiple arguments
            lia.notices.notifyLocalized("itemPickup", "Health Kit", 3)
    ]]
    function lia.notices.notifyLocalized(key, ...)
        lia.notices.notify(L(key, ...))
    end

    --[[
        notification.AddLegacy

        Purpose:
            Overrides the default notification.AddLegacy to use lia.notices.notify for displaying legacy notifications.

        Parameters:
            text (string) - The message to display.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            -- Show a legacy notification
            notification.AddLegacy("This is a legacy notification!")
    ]]
    function notification.AddLegacy(text)
        lia.notices.notify(tostring(text))
    end
end