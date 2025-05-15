function MODULE:ShowSpare1(client)
    if client:getChar() then
        net.Start("rgnMenu")
        net.Send(client)
    end
end
