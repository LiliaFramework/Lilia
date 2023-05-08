net.Receive("death_client", function()
    local format = "%A, %d %B %Y %X"
    local date = os.date(format, nut.date.get())
    local nick = net.ReadString()
    local charid = net.ReadFloat()
    chat.AddText(Color(255, 0, 0), "[DEATH]: ", Color(255, 255, 255), date, Color(255, 255, 255), " - You were killed by " .. nick .. "[" .. charid .. "]")
end)