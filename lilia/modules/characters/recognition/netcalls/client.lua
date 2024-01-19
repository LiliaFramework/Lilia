netstream.Hook("rgnDone", function()
    local client = LocalPlayer()
    hook.Run("OnCharRecognized", client, id)
end)

netstream.Hook("rgnMenu", function()
    local menu = DermaMenu()
    menu:AddOption("Allow those in a whispering range to recognize you.", function() RecognitionCore:CharRecognize(2) end)
    menu:AddOption("Allow those in a talking range to recognize you.", function() RecognitionCore:CharRecognize(3) end)
    menu:AddOption("Allow those in a yelling range to recognize you.", function() RecognitionCore:CharRecognize(4) end)
    if RecognitionCore.FakeNamesEnabled then
        menu:AddOption("Allow those in whispering range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in whispering range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then RecognitionCore:CharRecognize(2, text) end end) end)
        menu:AddOption("Allow those in talking range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in talking range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then RecognitionCore:CharRecognize(3, text) end end) end)
        menu:AddOption("Allow those in yelling range to recognize you by a fake name.", function() Derma_StringRequest("Allow those in yelling range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then RecognitionCore:CharRecognize(4, text) end end) end)
    end

    menu:Open()
    menu:MakePopup()
    menu:Center()
end)
