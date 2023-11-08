--------------------------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgnDone",
    function()
        local client = LocalPlayer()
        hook.Run("OnCharRecognized", client, id)
    end
)

--------------------------------------------------------------------------------------------------------------------------
netstream.Hook(
    "rgnMenu",
    function()
        local menu = DermaMenu()
        local character = LocalPlayer():getChar()
        local name = character:getName()
        menu:AddOption("Allow those in a whispering range to recognize you.", function() CharRecognize(2, name) end)
        menu:AddOption("Allow those in a talking range to recognize you.", function() CharRecognize(3, name) end)
        menu:AddOption("Allow those in a yelling range to recognize you.", function() CharRecognize(4, name) end)
        menu:AddOption("Allow those in whispering range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in whispering range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then CharRecognize(2, text) end end) end)
        menu:AddOption("Allow those in talking range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in talking range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then CharRecognize(3, text) end end) end)
        menu:AddOption("Allow those in yelling range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in yelling range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then CharRecognize(4, text) end end) end)
        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
)
--------------------------------------------------------------------------------------------------------------------------
