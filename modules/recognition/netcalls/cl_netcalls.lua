--------------------------------------------------------------------------------------------------------
netstream.Hook("rgnMenu", function()
    local menu = DermaMenu()

    menu:AddOption(L"rgnLookingAt", function()
        netstream.Start("rgn", 1)
    end)

    menu:AddOption(L"rgnWhisper", function()
        netstream.Start("rgn", 2)
    end)

    menu:AddOption(L"rgnTalk", function()
        netstream.Start("rgn", 3)
    end)

    menu:AddOption(L"rgnYell", function()
        netstream.Start("rgn", 4)
    end)

    menu:Open()
    menu:MakePopup()
    menu:Center()
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("rgnDone", function()
    local client = LocalPlayer()
    hook.Run("OnCharRecognized", client, id)
end)
--------------------------------------------------------------------------------------------------------