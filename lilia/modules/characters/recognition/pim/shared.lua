local MODULE = MODULE
PIM:AddOption(L"recognize", {
    runServer = false,
    shouldShow = function(client, target)
        local ourChar = client:getChar()
        local tarCharID = target:getChar():getID()
        return not hook.Run("isCharRecognized", ourChar, tarCharID)
    end,
    onRun = function(_, target) if CLIENT then netstream.Start("rgnDirect", target) end end
})

PIM:AddOption(L"recognizeWithFakeName", {
    runServer = false,
    shouldShow = function(client, target)
        local ourChar = client:getChar()
        local tarCharID = target:getChar():getID()
        return not hook.Run("isCharRecognized", ourChar, tarCharID) and MODULE.FakeNamesEnabled
    end,
    onRun = function(_, target)
        local tarChar = target:getChar()
        if CLIENT then Derma_StringRequest(L"recogMenuOptionFakeWhisper", L"recogFakeNamePrompt", tarChar:getName(), function(text) if text then netstream.Start("rgnDirect", target, text) end end) end
    end
})