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

    function lia.notices.notifyInfoLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "info")
    end

    function lia.notices.notifyWarningLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "warning")
    end

    function lia.notices.notifyErrorLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "error")
    end

    function lia.notices.notifySuccessLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "success")
    end

    function lia.notices.notifyMoneyLocalized(client, key, ...)
        lia.notices.notify(client, L(key, ...), "money")
    end

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
