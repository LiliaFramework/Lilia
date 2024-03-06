
function MODULE:ShowSpare1(client)
    if client:getChar() then netstream.Start(client, "rgnMenu") end
end

