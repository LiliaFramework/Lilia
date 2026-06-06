
net.Receive("liaSetMainCharacter", function(_, client)
    local charID = net.ReadUInt(32)
    if not charID or charID == 0 then return end
    local success, errorMsg = client:setMainCharacter(charID)
    if success then
        net.Start("liaMainCharacterSet")
        net.WriteUInt(charID, 32)
        net.Send(client)
    else
        if errorMsg then client:notifyErrorLocalized(errorMsg) end
    end
end)
