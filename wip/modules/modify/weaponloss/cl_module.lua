-------------------------------------------------------------------------------------------------------------------------
net.Receive("death_client", function()
    local format = "%A, " .. CONFIG.Day .. " " .. CONFIG.Month .. tostring(CONFIG.SchemaYear)
    local date = lia.date.GetFormattedDate(true, true, true, true, true)
    local nick = net.ReadString()
    local charid = net.ReadFloat()
    chat.AddText(Color(255, 0, 0), "[DEATH]: ", Color(255, 255, 255), date, Color(255, 255, 255), " - You were killed by " .. nick .. "[" .. charid .. "]")
end)

-------------------------------------------------------------------------------------------------------------------------
netstream.Hook("removeF1", function()
    if IsValid(lia.gui.menu) then
        lia.gui.menu:remove()
    end
end)