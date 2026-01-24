--[[
    Folder: Libraries
    File: notices.md
]]
--[[
    Notice Library

    Player notification and messaging system for the Lilia framework.
]]
--[[
    Overview:
        The notice library provides comprehensive functionality for displaying notifications and messages to players in the Lilia framework. It handles both server-side and client-side notification systems, supporting both direct text messages and localized messages with parameter substitution. The library operates across server and client realms, with the server sending notification data to clients via network messages, while the client handles the visual display of notifications using VGUI panels. It includes automatic organization of multiple notifications, sound effects, and console output for debugging purposes. The library also provides compatibility with Garry's Mod's legacy notification system.
]]
lia.notices = lia.notices or {}
if CLIENT then
    --[[
    Purpose:
        Receives notification data from the server via network message and displays it to the client.

    When Called:
        Automatically called when the client receives a "liaNotificationData" network message from the server.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
        -- This function is called automatically when receiving server notifications
        -- No manual calling needed
        ```
]]
    function lia.notices.receiveNotify()
        local msg = net.ReadString() or ""
        local ntype = net.ReadString() or "default"
        local notice = vgui.Create("liaNotice")
        notice:SetText(msg)
        notice:SetType(ntype)
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), msg .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end

    --[[
    Purpose:
        Receives localized notification data from the server and displays the localized message to the client.

    When Called:
        Automatically called when the client receives a "liaNotifyLocal" network message from the server containing localized notification data.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
        -- This function is called automatically when receiving localized server notifications
        -- No manual calling needed
        ```
]]
    function lia.notices.receiveNotifyL()
        local key = net.ReadString() or ""
        local argc = net.ReadUInt(8) or 0
        local args = {}
        for i = 1, argc do
            args[i] = net.ReadString()
        end

        local ntype = net.ReadString() or "default"
        local msg = L(key, unpack(args))
        local notice = vgui.Create("liaNotice")
        notice:SetText(tostring(msg))
        notice:SetType(ntype)
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), tostring(msg) .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end

    --[[
    Purpose:
        Sends an informational notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send an info-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized info notification to a specific player
        lia.notices.notifyInfoLocalized(player, "item.purchased", itemName, price)

        -- Send to all players
        lia.notices.notifyInfoLocalized(nil, "server.restart", "5")
        ```
]]
    function lia.notices.notifyInfoLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "info")
    end

    --[[
    Purpose:
        Sends a warning notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send a warning-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized warning notification to a specific player
        lia.notices.notifyWarningLocalized(player, "inventory.full")

        -- Send to all players
        lia.notices.notifyWarningLocalized(nil, "server.maintenance", "30")
        ```
]]
    function lia.notices.notifyWarningLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "warning")
    end

    --[[
    Purpose:
        Sends an error notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send an error-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized error notification to a specific player
        lia.notices.notifyErrorLocalized(player, "command.noPermission")

        -- Send to all players
        lia.notices.notifyErrorLocalized(nil, "server.error", errorCode)
        ```
]]
    function lia.notices.notifyErrorLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "error")
    end

    --[[
    Purpose:
        Sends a success notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send a success-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized success notification to a specific player
        lia.notices.notifySuccessLocalized(player, "quest.completed", questName)

        -- Send to all players
        lia.notices.notifySuccessLocalized(nil, "server.update.complete")
        ```
]]
    function lia.notices.notifySuccessLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "success")
    end

    --[[
    Purpose:
        Sends a money-related notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send a money-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized money notification to a specific player
        lia.notices.notifyMoneyLocalized(player, "money.earned", amount, reason)

        -- Send to all players
        lia.notices.notifyMoneyLocalized(nil, "lottery.winner", winnerName, prize)
        ```
]]
    function lia.notices.notifyMoneyLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "money")
    end

    --[[
    Purpose:
        Sends an admin-related notification to a client using a localized message key with optional parameters.

    When Called:
        Called when you want to send an admin-type notification with localized text to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        key (string)
            The localization key for the message.
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Client

    Example Usage:
        ```lua
        -- Send localized admin notification to a specific player
        lia.notices.notifyAdminLocalized(player, "admin.kicked", reason)

        -- Send to all players
        lia.notices.notifyAdminLocalized(nil, "admin.announcement", message)
        ```
]]
    function lia.notices.notifyAdminLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "admin")
    end

    --[[
    Purpose:
        Provides compatibility with Garry's Mod's legacy notification system by mapping legacy notification types to Lilia's notification system.

    When Called:
        Called automatically when Garry's Mod's legacy notification.AddLegacy function is invoked, or can be called directly for compatibility.

    Parameters:
        text (string)
            The notification text to display.
        typeId (number)
            The legacy notification type ID (0 = info, 1 = error, 2 = success).
    Realm:
        Client

    Example Usage:
        ```lua
        -- This function provides backwards compatibility
        notification.AddLegacy("Player connected!", 2) -- Shows as success notification
        ```
]]
    function notification.AddLegacy(text, typeId)
        local map = {
            [0] = "info",
            [1] = "error",
            [2] = "success"
        }

        lia.notices.notify(nil, tostring(text), map[tonumber(typeId) or -1] or "default")
    end
end

if CLIENT then
    local cachedScrH = ScrH()
    local cachedScale = cachedScrH / 1080
    local lastScrHCheck = 0
    --[[
    Purpose:
        Organizes and positions notification panels on the screen, ensuring they are properly spaced and positioned relative to screen resolution.

    When Called:
        Called whenever a new notification is added or when the screen resolution changes to reposition existing notifications.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
        -- This function is called automatically when notifications are added
        -- No manual calling needed
        OrganizeNotices()
        ```
]]
    function OrganizeNotices()
        local now = CurTime()
        if now - lastScrHCheck > 1 then
            lastScrHCheck = now
            local newScrH = ScrH()
            if newScrH ~= cachedScrH then
                cachedScrH = newScrH
                cachedScale = cachedScrH / 1080
            end
        end

        local baseY = cachedScrH - 200 * cachedScale
        local spacing = 4 * cachedScale
        local y = baseY
        for _, v in ipairs(lia.notices) do
            if IsValid(v) then
                v.targetY = y
                y = y - (v:GetTall() + spacing)
            end
        end
    end
end

--[[
    Purpose:
        Sends a localized notification to a client or all clients, handling both server-side networking and client-side display.

    When Called:
        Called when you want to send a notification using a localization key with variable arguments to a specific client or all clients.

    Parameters:
        client (Player|string|nil)
            The player to send the notification to, or the first argument if not a player. If nil, sends to all players.
        key (string)
            The localization key for the message.
        notifType (string)
            The type of notification (e.g., "info", "warning", "error", "success").
        ... (varargs)
            Additional parameters to substitute into the localized message.
    Realm:
        Shared

    Example Usage:
        ```lua
        -- Server-side: Send to specific player
        lia.notices.notifyLocalized(player, "item.purchased", "success", itemName, price)

        -- Server-side: Send to all players
        lia.notices.notifyLocalized(nil, "server.restart", "warning", "5")

        -- Client-side: Display localized notification
        lia.notices.notifyLocalized(nil, "ui.button.clicked", "info")
        ```
]]
function lia.notices.notifyLocalized(client, key, notifType, ...)
    if SERVER then
        local args = {...}
        if client and type(client) ~= "Player" then
            table.insert(args, 1, client)
            client = nil
        end

        net.Start("liaNotifyLocal")
        net.WriteString(key)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        net.WriteString(tostring(notifType or "default"))
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    else
        lia.notices.notify(client, L(key, ...), notifType or "default")
    end
end

--[[
    Purpose:
        Sends a text notification to a client or all clients, handling both server-side networking and client-side display with sound and visual effects.

    When Called:
        Called when you want to send a notification with plain text (not localized) to a specific client or all clients.

    Parameters:
        client (Player|nil)
            The player to send the notification to. If nil, sends to all players.
        message (string)
            The notification message text to display.
        notifType (string)
            The type of notification (e.g., "default", "info", "warning", "error", "success", "money", "admin").
    Realm:
        Shared

    Example Usage:
        ```lua
        -- Server-side: Send to specific player
        lia.notices.notify(player, "You have received 100 credits!", "money")

        -- Server-side: Send to all players
        lia.notices.notify(nil, "Server restarting in 5 minutes", "warning")

        -- Client-side: Display notification
        lia.notices.notify(nil, "Welcome to the server!", "info")
        ```
]]
function lia.notices.notify(client, message, notifType)
    if SERVER then
        net.Start("liaNotificationData")
        net.WriteString(message)
        net.WriteString(notifType or "default")
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    else
        local notice = vgui.Create("liaNotice")
        notice:SetText(tostring(message))
        notice:SetType(tostring(notifType or "default"))
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), tostring(message) .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end
end
