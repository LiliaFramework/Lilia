-------------------------------------------------------------------------------------------------------------------------
net.Receive("cleanup_inbound", function()
    chat.AddText(Color(255, 0, 0), "[ WARNING ]  Map Cleanup Inbound! Brace for Impact!")
end)

-------------------------------------------------------------------------------------------------------------------------
net.Receive("worlditem_cleanup_inbound", function()
    chat.AddText(Color(255, 0, 0), "[ WARNING ]  World items will be cleared in 10 Miliaes!")
end)

-------------------------------------------------------------------------------------------------------------------------
net.Receive("worlditem_cleanup_inbound_final", function()
    chat.AddText(Color(255, 0, 0), "[ WARNING ]  World items will be cleared in 60 Seconds!")
end)

-------------------------------------------------------------------------------------------------------------------------
net.Receive("map_cleanup_inbound", function()
    chat.AddText(Color(255, 0, 0), "[ WARNING ]  Automatic Map Cleanup in 10 Miliaes!")
end)

-------------------------------------------------------------------------------------------------------------------------
net.Receive("map_cleanup_inbound_final", function()
    chat.AddText(Color(255, 0, 0), "[ WARNING ]  Automatic Map Cleanup in 60 Seconds!")
end)