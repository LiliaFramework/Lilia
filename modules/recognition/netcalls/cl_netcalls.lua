--------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgnDone",
    function()
        local client = LocalPlayer()
        hook.Run("OnCharRecognized", client, id)
    end
)
--------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgnMenu",
    function()
        local menu = DermaMenu()
        menu:AddOption(
            "Allow those in a whispering range to recognize you.",
            function()
                netstream.Start("rgn", 2)
            end
        )

        menu:AddOption(
            "Allow those in a talking range to recognize you.",
            function()
                netstream.Start("rgn", 3)
            end
        )

        menu:AddOption(
            "Allow those in a yelling range to recognize you.",
            function()
                netstream.Start("rgn", 4)
            end
        )

        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
)
--------------------------------------------------------------------------------------------------------