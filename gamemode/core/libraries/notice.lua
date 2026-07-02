--[[
    Folder: Developer - Libraries
    File: lia.notices.md
]]
--[[
    Notices

    Notice helpers for sending, receiving, localizing, displaying, and routing Lilia notification messages.
]]
--[[
    Overview:
        The notices library centralizes notification delivery under `lia.notices`. Serverside calls send networked notices to one client or broadcast them to all players, while clientside calls build `liaNotice` panels, organize their screen positions, emit the notice sound, and print the message to the console. Localized helpers resolve language keys through `L` before using the normal notice pipeline.
]]
--[[
    Hooks:
        LiliaNoticeOverride(string message, string noticeType)

    Purpose:
        Allows plugins or modules to intercept incoming networked notices before a clientside notice panel is created.

    Category:
        Notices

    Parameters:
        message (string)
            The notice text that would be displayed.

        noticeType (string)
            The notice type used to style the notice.

    Returns:
        boolean|table|nil
            Return true to block the notice. Return a table with `message` or `msg` and/or `type` to replace the notice data. Return nil or any other value to continue with the original notice.

    Realm:
        Client
]]
lia.notices = lia.notices or {}
if CLIENT then
    --[[
    Purpose:
        Reads a networked notification payload and creates a clientside notice panel after running the notice override hook.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        net.Receive("liaNotificationData", lia.notices.receiveNotify)
        ```

    Realm:
        Client
]]
    function lia.notices.receiveNotify()
        local msg = net.ReadString() or ""
        local ntype = net.ReadString() or "default"
        local override = hook.Run("LiliaNoticeOverride", msg, ntype)
        if override == true then return end
        if istable(override) then
            msg = tostring(override.message or override.msg or msg)
            ntype = tostring(override.type or ntype)
        end

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
        Reads a networked localized notification payload, resolves the language key, and creates a clientside notice panel after running the notice override hook.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        net.Receive("liaNotifyLocal", lia.notices.receiveNotifyL)
        ```

    Realm:
        Client
]]
    function lia.notices.receiveNotifyL()
        local key = net.ReadString() or ""
        local argc = net.ReadUInt(8) or 0
        local args = {}
        for i = 1, argc do
            args[i] = net.ReadString()
        end

        local ntype = net.ReadString() or "default"
        local msg = tostring(L(key, unpack(args)))
        local override = hook.Run("LiliaNoticeOverride", msg, ntype)
        if override == true then return end
        if istable(override) then
            msg = tostring(override.message or override.msg or msg)
            ntype = tostring(override.type or ntype)
        end

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
        Displays a localized info notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyInfoLocalized(nil, "noticeSaved")
        ```

    Realm:
        Client
]]
    function lia.notices.notifyInfoLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "info")
    end

    --[[
    Purpose:
        Displays a localized warning notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyWarningLocalized(nil, "noticeWarning")
        ```

    Realm:
        Client
]]
    function lia.notices.notifyWarningLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "warning")
    end

    --[[
    Purpose:
        Displays a localized error notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyErrorLocalized(nil, "noticeError")
        ```

    Realm:
        Client
]]
    function lia.notices.notifyErrorLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "error")
    end

    --[[
    Purpose:
        Displays a localized success notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifySuccessLocalized(nil, "noticeSuccess")
        ```

    Realm:
        Client
]]
    function lia.notices.notifySuccessLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "success")
    end

    --[[
    Purpose:
        Displays a localized money notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyMoneyLocalized(nil, "noticeMoney")
        ```

    Realm:
        Client
]]
    function lia.notices.notifyMoneyLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "money")
    end

    --[[
    Purpose:
        Displays a localized admin notice for the local client.

    Parameters:
        client (Player|nil)
            Retained for API compatibility and passed through to the shared notice function.

        key (string)
            The localization key to resolve with `L`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyAdminLocalized(nil, "noticeAdmin")
        ```

    Realm:
        Client
]]
    function lia.notices.notifyAdminLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "admin")
    end

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
        Sends or displays a localized notice using the provided notice type.

    Parameters:
        client (Player|any|nil)
            On the server, the target player to receive the notice. If nil, the notice is broadcast. If this value is not a Player, it is treated as the first localization argument and the notice is broadcast. On the client, this is retained for API compatibility.

        key (string)
            The localization key to resolve with `L`.

        notifType (string|nil)
            The notice type to send or display. Defaults to `default`.

        ... (any)
            Values passed to the localization function.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notifyLocalized(client, "noticeSaved", "success")
        lia.notices.notifyLocalized(nil, "noticeWarning", "warning", "Door")
        ```

    Realm:
        Shared
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
        Sends a plain notice from the server or displays one immediately on the client.

    Parameters:
        client (Player|nil)
            On the server, the target player to receive the notice. If nil, the notice is broadcast. On the client, this is retained for API compatibility.

        message (string)
            The notice text to send or display.

        notifType (string|nil)
            The notice type to send or display. Defaults to `default`.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.notices.notify(client, "Settings saved.", "success")
        lia.notices.notify(nil, "Server restart soon.", "warning")
        ```

    Realm:
        Shared
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
