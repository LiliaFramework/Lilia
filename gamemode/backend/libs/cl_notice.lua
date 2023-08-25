--------------------------------------------------------------------------------------------------------
lia.notices = lia.notices or {}
--------------------------------------------------------------------------------------------------------
lia.config.Notify = {"garrysmod/content_downloaded.wav", 50, 250}
--------------------------------------------------------------------------------------------------------
local function OrganizeNotices()
    local scrW = ScrW()
    for k, v in ipairs(lia.notices) do
        v:MoveTo(scrW - (v:GetWide() + 4), (k - 1) * (v:GetTall() + 4) + 4, 0.15, (k / #lia.notices) * 0.25)
    end
end
--------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------