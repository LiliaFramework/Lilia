lia.notices = lia.notices or {}
lia.noticess = lia.noticess or {}
lia.config.NotifTypes = {
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

function OrganizeNoticess()
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

function RemoveNoticess(notice)
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

function OrganizeNotices(i)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100
    for k, v in ipairs(lia.notices) do
        local height = lastHeight - v:GetTall() - 10
        v:MoveTo(scrW - v:GetWide(), height, 0.15, (k / #lia.notices) * 0.25, nil)
        lastHeight = height
    end
end

function notification.AddLegacy(text, _, __)
    lia.util.notify(tostring(text))
end

function lia.util.notify(message)
    local notice = vgui.Create("liaNotify")
    local i = table.insert(lia.notices, notice)
    notice:SetMessage(message)
    notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4)
    notice:MoveToFront()
    OrganizeNotices(i)
    timer.Simple(
        10,
        function()
            if IsValid(notice) then
                notice:AlphaTo(
                    0,
                    1,
                    0,
                    function()
                        notice:Remove()
                        for v, k in pairs(lia.notices) do
                            if k == notice then
                                table.remove(lia.notices, v)
                            end
                        end

                        OrganizeNotices(i)
                    end
                )
            end
        end
    )

    MsgN(message)
end

function lia.util.notifQuery(question, option1, option2, manualDismiss, notifType, callback)
    if not callback or not isfunction(callback) then
        Error("A callback function must be specified")
    end

    if not question or not isstring(question) then
        Error("A question string must be specified")
    end

    if not option1 then
        option1 = "Yes"
    end

    if not option2 then
        option2 = "No"
    end

    if not manualDismiss then
        manualDismiss = false
    end

    local notice = CreateNoticePanel(10, manualDismiss)
    local i = table.insert(lia.noticess, notice)
    notice.isQuery = true
    notice.text:SetText(question)
    notice:SetPos(0, (i - 1) * (notice:GetTall() + 4) + 4)
    notice:SetTall(36 * 2.3)
    notice:CalcWidth(120)
    notice:CenterHorizontal()
    notice.notifType = notifType or 7
    if manualDismiss then
        notice.start = nil
    end

    notice.opt1 = notice:Add("DButton")
    notice.opt1:SetAlpha(0)
    notice.opt2 = notice:Add("DButton")
    notice.opt2:SetAlpha(0)
    notice.oh = notice:GetTall()
    OrganizeNotices()
    notice:SetTall(0)
    notice:SizeTo(
        notice:GetWide(),
        36 * 2.3,
        0.2,
        0,
        -1,
        function()
            notice.text:SetPos(0, 0)
            local function styleOpt(o)
                o.color = Color(0, 0, 0, 30)
                AccessorFunc(o, "color", "Color")
                function o:Paint(w, h)
                    if self.left then
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                    else
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                    end
                end
            end

            if notice.opt1 and IsValid(notice.opt1) then
                notice.opt1:SetAlpha(255)
                notice.opt1:SetSize(notice:GetWide() / 2, 25)
                notice.opt1:SetText(option1 .. " (F8)")
                notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
                notice.opt1:CenterHorizontal(0.25)
                notice.opt1:SetAlpha(0)
                notice.opt1:AlphaTo(255, 0.2)
                notice.opt1:SetTextColor(color_white)
                notice.opt1.left = true
                styleOpt(notice.opt1)
                function notice.opt1:keyThink()
                    if input.IsKeyDown(KEY_F8) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(1, notice)
                        timer.Simple(
                            1,
                            function()
                                if notice and IsValid(notice) then
                                    RemoveNotice(notice)
                                end
                            end
                        )

                        notice.lastKey = CurTime()
                    end
                end
            end

            if notice.opt2 and IsValid(notice.opt2) then
                notice.opt2:SetAlpha(255)
                notice.opt2:SetSize(notice:GetWide() / 2, 25)
                notice.opt2:SetText(option2 .. " (F9)")
                notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
                notice.opt2:CenterHorizontal(0.75)
                notice.opt2:SetAlpha(0)
                notice.opt2:AlphaTo(255, 0.2)
                notice.opt2:SetTextColor(color_white)
                styleOpt(notice.opt2)
                function notice.opt2:keyThink()
                    if input.IsKeyDown(KEY_F9) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(2, notice)
                        timer.Simple(
                            1,
                            function()
                                if notice and IsValid(notice) then
                                    RemoveNotice(notice)
                                end
                            end
                        )

                        notice.lastKey = CurTime()
                    end
                end
            end

            notice.lastKey = CurTime()
            notice.respondToKeys = true
            function notice:Think()
                if not self.respondToKeys then return end
                local queries = {}
                for _, v in pairs(lia.noticess) do
                    if v.isQuery then
                        queries[#queries + 1] = v
                    end
                end

                for _, v in pairs(queries) do
                    if v == self and k > 1 then return end
                end

                if self.opt1 and IsValid(self.opt1) then
                    self.opt1:keyThink()
                end

                if self.opt2 and IsValid(self.opt2) then
                    self.opt2:keyThink()
                end
            end
        end
    )

    return notice
end