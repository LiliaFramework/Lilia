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
        local default = ""
        local menu = DermaMenu()
        menu:AddOption(
            "Allow those in a whispering range to recognize you.",
            function()
                CharRecognize(2)
            end
        )

        menu:AddOption(
            "Allow those in a talking range to recognize you.",
            function()
                CharRecognize(3)
            end
        )

        menu:AddOption(
            "Allow those in a yelling range to recognize you.",
            function()
                CharRecognize(4)
            end
        )

        menu:AddOption(
            "Allow those in whispering range to recognize you by a fake name.",
            function()
                Derma_StringRequest(
                    "Allow those in whispering range to recognize you by a fake name.",
                    "Enter a fake name to display to other players in range.",
                    default,
                    function(text)
                        if text then
                            CharRecognize(2, text)
                        end
                    end
                )
            end
        )

        menu:AddOption(
            "Allow those in talking range to recognize you by a fake name.",
            function()
                Derma_StringRequest(
                    "Allow those in talking range to recognize you by a fake name.",
                    "Enter a fake name to display to other players in range.",
                    default,
                    function(text)
                        if text then
                            CharRecognize(3, text)
                        end
                    end
                )
            end
        )

        menu:AddOption(
            "Allow those in yelling range to recognize you by a fake name.",
            function()
                Derma_StringRequest(
                    "Allow those in yelling range to recognize you by a fake name.",
                    "Enter a fake name to display to other players in range.",
                    default,
                    function(text)
                        if text then
                            CharRecognize(4, text)
                        end
                    end
                )
            end
        )

        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
)
--------------------------------------------------------------------------------------------------------