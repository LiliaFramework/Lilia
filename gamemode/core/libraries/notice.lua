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
        col = Color(255, 165, 0),
        icon = "icon16/error.png"
    },
    [4] = {
        col = Color(64, 185, 85),
        icon = "icon16/accept.png"
    },
    [5] = {
        col = Color(100, 185, 255),
        icon = "icon16/information.png"
    },
    [6] = {
        col = Color(255, 223, 0),
        icon = "icon16/lightbulb.png"
    }
}

function RemoveNotices(notice)
    if not IsValid(notice) then return end
    for k, v in ipairs(lia.notices) do
        if v == notice then
            if IsValid(notice) then notice:SizeTo(notice:GetWide(), 0, 0.2, 0, -1, function() if IsValid(notice) then notice:Remove() end end) end
            table.remove(lia.notices, k)
            timer.Simple(0.25, OrganizeNotices)
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
        local t = lia.notices.Types[5]
        local mat
        if self.notifType ~= nil and not isstring(self.notifType) and self.notifType > 0 then
            t = lia.notices.Types[self.notifType]
            mat = lia.util.getMaterial(t.icon)
        end

        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
        if self.start then
            local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
            local col = t and t.col or lia.config.get("Color")
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

local function DisplayNotice(message, notifType, manualDismiss)
    manualDismiss = manualDismiss or false
    notifType = notifType or 5
    local notice = CreateNoticePanel(10, manualDismiss)
    notice.notifType = notifType
    table.insert(lia.notices, notice)
    notice.text:SetText(message)
    notice:SetTall(36 * 1.8)
    notice:CalcWidth(120)
    if manualDismiss then notice.start = nil end
    notice.oh = notice:GetTall()
    notice:SetTall(0)
    local targetX = ScrW() / 2 - notice:GetWide() / 2
    local targetY = 4
    notice:SetPos(targetX, targetY)
    notice:SizeTo(notice:GetWide(), 36 * 1.8, 0.2, 0, -1, function() notice.text:SetPos(0, 0) end)
    if not manualDismiss then timer.Simple(5, function() if IsValid(notice) then RemoveNotices(notice) end end) end
    timer.Simple(0.05, OrganizeNotices)
end

function OrganizeNotices()
    local scrW = ScrW()
    local baseY = 10
    local validNotices = {}
    for _, notice in ipairs(lia.notices) do
        if IsValid(notice) then table.insert(validNotices, notice) end
    end

    while #validNotices > 6 do
        local old = table.remove(validNotices, 1)
        if IsValid(old) then old:Remove() end
    end

    local leftCount = #validNotices > 3 and #validNotices - 3 or 0
    for i, notice in ipairs(validNotices) do
        if i <= leftCount then
            local x = 10
            local y = baseY + (i - 1) * (notice.oh + 5)
            notice:MoveTo(x, y, 0.15)
        else
            local rightIndex = i - leftCount
            local x = scrW - notice:GetWide() - 10
            local y = baseY + (rightIndex - 1) * (notice.oh + 5)
            notice:MoveTo(x, y, 0.15)
        end
    end
end

--[[
    Function: lia.notices.notify

    Description:
       Sends a simple notification. On server this broadcasts (or sends to a specific player) via net;
       on client it displays via Garry’s Mod’s DisplayNotice + MsgN.

    Parameters:
       message (string) — text to show
       notifType? (number) — numeric type (defaults to 5) — only used client‑side
       recipient? (Player|nil) — target player (server only)

    Returns:
       nil

    Realm:
       Shared
 ]]
function lia.notices.notify(message, notifType, recipient)
    if SERVER then
        local args = {}
        if recipient ~= nil and not istable(recipient) and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotify")
        net.WriteString(message)
        net.WriteUInt(#args, 8)
        for _, v in ipairs(args) do
            net.WriteString(tostring(v))
        end

        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    else
        DisplayNotice(message, notifType or 5, false)
        MsgN(message)
    end
end

--[[
    Function: lia.notices.notifyLocalized

    Description:
       Same as lia.notices.notify but first localizes the message key with format arguments.

    Parameters:
       message (string) — localization key
       recipient? (Player|nil) — target player (server only)
       ... — format arguments

    Returns:
       nil

    Realm:
       Shared
 ]]
function lia.notices.notifyLocalized(message, recipient, ...)
    local args = {...}
    if SERVER then
        if recipient ~= nil and not istable(recipient) and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotifyL")
        net.WriteString(message)
        net.WriteUInt(#args, 8)
        for _, v in ipairs(args) do
            net.WriteString(tostring(v))
        end

        if recipient then
            net.Send(recipient)
        else
            net.Broadcast()
        end
    else
        lia.notices.notify(L(message, ...))
    end
end

if CLIENT then
    function notification.AddLegacy(text)
        lia.notices.notify(tostring(text))
    end
end
