﻿util.AddNetworkString("F1AlterDescription")
net.Receive(
    "F1AlterDescription",
    function(_, client)
        local char = client:getChar()
        local newDesc = net.ReadString()
        char:setDesc(newDesc)
    end
)
