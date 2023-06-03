netstream.Hook("VoiceMenu", function(client)
    local menu = DermaMenu()

    menu:AddOption("Change voice mode to Whispering range.", function()
        netstream.Start("ChangeMode", 1)
        LocalPlayer():notify("You have changed your voice mode to Whispering!")
    end)

    menu:AddOption("Change voice mode to Talking range.", function()
        netstream.Start("ChangeMode", 2)
        LocalPlayer():notify("You have changed your voice mode to Talking!")
    end)

    menu:AddOption("Change voice mode to Yelling range.", function()
        netstream.Start("ChangeMode", 3)
        LocalPlayer():notify("You have changed your voice mode to Yelling!")
    end)

    menu:Open()
    menu:MakePopup()
    menu:Center()
end)

function PLUGIN:PlayerButtonDown(client, button)
    if button == KEY_F2 and IsFirstTimePredicted() then
        netstream.Start(client, "VoiceMenu")
    end
end