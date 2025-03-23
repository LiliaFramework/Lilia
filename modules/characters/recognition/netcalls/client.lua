local MODULE = MODULE
netstream.Hook("rgnDone", function()
    local client = LocalPlayer()
    hook.Run("OnCharRecognized", client, client:getChar():getID())
end)

netstream.Hook("rgnMenu", function()
    local menu = DermaMenu()
    menu:AddOption(L("recogMenuOptionWhisper"), function() MODULE:CharRecognize(2) end)
    menu:AddOption(L("recogMenuOptionTalk"), function() MODULE:CharRecognize(3) end)
    menu:AddOption(L("recogMenuOptionYell"), function() MODULE:CharRecognize(4) end)
    if lia.config.get("FakeNamesEnabled", false) then
        menu:AddOption(L("recogMenuOptionFakeWhisper"), function() Derma_StringRequest(L("recogMenuOptionFakeWhisper"), L("recogFakeNamePrompt"), "", function(text) if text then MODULE:CharRecognize(2, text) end end) end)
        menu:AddOption(L("recogMenuOptionFakeTalk"), function() Derma_StringRequest(L("recogMenuOptionFakeTalk"), L("recogFakeNamePrompt"), "", function(text) if text then MODULE:CharRecognize(3, text) end end) end)
        menu:AddOption(L("recogMenuOptionFakeYell"), function() Derma_StringRequest(L("recogMenuOptionFakeYell"), L("recogFakeNamePrompt"), "", function(text) if text then MODULE:CharRecognize(4, text) end end) end)
    end

    menu:Open()
    menu:MakePopup()
    menu:Center()
end)
