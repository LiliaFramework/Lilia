local ScrW, ScrH = ScrW(), ScrH()
net.Receive("sam_blind", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "sam_blind", function() draw.RoundedBox(0, 0, 0, ScrW, ScrH, Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "sam_blind")
    end
end)