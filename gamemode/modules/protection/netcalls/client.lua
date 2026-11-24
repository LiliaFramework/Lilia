local MODULE = MODULE
net.Receive("liaVerifyCheats", function()
    MODULE:VerifyCheats()
    net.Start("liaVerifyCheatsResponse")
    net.SendToServer()
end)
