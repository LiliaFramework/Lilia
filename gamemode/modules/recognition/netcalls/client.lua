
net.Receive("liaRgnDone", function()
    local client = LocalPlayer()
    hook.Run("OnCharRecognized", client, client:getChar():getID())
end)
