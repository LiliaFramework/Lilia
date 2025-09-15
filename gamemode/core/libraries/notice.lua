lia.notices = lia.notices or {}
if SERVER then
    function lia.notices.notify(client, message, notifType)
        net.Start("liaNotify")
        net.WriteString(message)
        net.WriteString(notifType or "default")
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    end
    function lia.notices.notifyLocalized(client, key, notifType, ...)
        local args = {...}
        if client and type(client) ~= "Player" then
            table.insert(args, 1, client)
            client = nil
        end
        net.Start("liaNotifyL")
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
    end
else
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
        MsgN(msg)
    end
    net.Receive("liaNotify", lia.notices.receiveNotify)
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
        MsgN(tostring(msg))
    end
    net.Receive("liaNotifyL", lia.notices.receiveNotifyL)
    function lia.notices.notify(_, message, notifType)
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
        MsgN(tostring(message))
    end
    function lia.notices.notifyLocalized(client, key, notifType, ...)
        lia.notices.notify(client, L(key, ...), notifType or "default")
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
function OrganizeNotices()
    local scale = ScrH() / 1080
    local baseY = ScrH() - 200 * scale
    local spacing = 4 * scale
    local y = baseY
    for _, v in ipairs(lia.notices) do
        if IsValid(v) then
            v.targetY = y
            y = y - (v:GetTall() + spacing)
        end
    end
end