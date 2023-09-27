
lia.notices = lia.notices or {}

lia.noticess = lia.noticess or {}

lia.config.Notify = {"garrysmod/content_downloaded.wav", 50, 250}

lia.config.NotifTypes = {
    [1] = {
        col = Color(200, 60, 60),
        icon = "icon16/exclamation.png"
    },
    -- ERROR
    [2] = {
        col = Color(255, 100, 100),
        icon = "icon16/cross.png"
    },
    -- COULD BE CANCELED
    [3] = {
        col = Color(255, 100, 100),
        icon = "icon16/cancel.png"
    },
    -- WILL BE CANCELED
    [4] = {
        col = Color(100, 185, 255),
        icon = "icon16/book.png"
    },
    -- TUTORIAL/GUIDE
    [5] = {
        col = Color(64, 185, 85),
        icon = "icon16/accept.png"
    },
    -- YES
    [7] = {
        col = Color(100, 185, 255),
        icon = "icon16/information.png"
    }
}

local function OrganizeNoticess()
    for k, v in ipairs(lia.noticess) do
        local topMargin = 0
        for k2, v2 in pairs(lia.noticess) do
            if k < k2 then
                topMargin = topMargin + v2:GetTall() + 5
            end
        end

        v:MoveTo(v:GetX(), topMargin + 5, 0.15, 0, 5)
    end
end

local function RemoveNoticess(notice)
    for k, v in ipairs(lia.noticess) do
        if v == notice then
            notice:SizeTo(
                notice:GetWide(),
                0,
                0.2,
                0,
                -1,
                function()
                    notice:Remove()
                end
            )

            table.remove(lia.noticess, k)
            OrganizeNoticess()
            break
        end
    end
end

function CreateNoticePanel(length, notimer)
    if not notimer then
        notimer = false
    end

    local notice = vgui.Create("noticePanel")
    notice.start = CurTime() + 0.25
    notice.endTime = CurTime() + length
    notice.oh = notice:GetTall()
    function notice:Paint(w, h)
        local t = lia.config.NotifTypes[7]
        local mat
        if self.notifType ~= nil and not isstring(self.notifType) and self.notifType > 0 then
            t = lia.config.NotifTypes[self.notifType]
            mat = lia.util.getMaterial(t.icon)
        end

        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
        if self.start then
            local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w
            local col = (t and t.col) or lia.config.get("color")
            draw.RoundedBox(4, w2, 0, w - w2, h, col)
        end

        if t and mat then
            local sw, sh = 24, 24
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(20, h / 2 - sh / 2, sw, sh)
        end
    end

    if not notimer then
        timer.Simple(
            length,
            function()
                RemoveNoticess(notice)
            end
        )
    end

    return notice
end

local function OrganizeNotices()
    local scrW = ScrW()
    for k, v in ipairs(lia.notices) do
        v:MoveTo(scrW - (v:GetWide() + 4), (k - 1) * (v:GetTall() + 4) + 4, 0.15, (k / #lia.notices) * 0.25)
    end
end

function lia.util.notify(message)
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
    timer.Simple(
        0.15,
        function()
            LocalPlayer():EmitSound(unpack(lia.config.Notify))
        end
    )

    timer.Simple(
        7.75,
        function()
            if IsValid(notice) then
                for k, v in ipairs(lia.notices) do
                    if v == notice then
                        notice:MoveTo(
                            scrW,
                            notice.y,
                            0.15,
                            0.1,
                            nil,
                            function()
                                notice:Remove()
                            end
                        )

                        table.remove(lia.notices, k)
                        OrganizeNotices()
                        break
                    end
                end
            end
        end
    )
end
