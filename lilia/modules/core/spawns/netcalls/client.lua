net.Receive("death_client", function()
    local date = lia.date.GetFormattedDate("", true, true, true, true, true)
    local nick = net.ReadString()
    local charid = net.ReadFloat()
    chat.AddText(Color(255, 0, 0), "[DEATH]: ", Color(255, 255, 255), date, "  You were killed by " .. nick .. " [" .. charid .. "]")
end)

net.Receive("RespawnButtonDeath", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetSize(800, 800)
    frame:Center()
    frame.Paint = function() end
    frame:MakePopup()
    frame.Think = function(s) if LocalPlayer():Alive() then s:Close() end end
    local bW, bH = 300, 100
    local btn = frame:Add("DButton")
    btn:SetText("Respawn")
    btn:SetPos((frame:GetWide() / 2) - (bW / 2), (frame:GetTall() / 2) - (bH / 2) + 250)
    btn:SetSize(bW, bH)
    btn.Paint = function(s, w, h)
        surface.SetDrawColor(lia.config.Color)
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 200))
        surface.DrawRect(1, 1, w - 2, h - 2)
        s:SetTextColor(Color(255, 255, 255))
        if s:IsHovered() then s:SetTextColor(Color(200, 200, 200)) end
    end

    btn.DoClick = function()
        net.Start("RespawnButtonPress")
        net.SendToServer()
        frame:Close()
    end
end)
