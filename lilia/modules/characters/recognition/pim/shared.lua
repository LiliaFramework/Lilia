local MODULE = MODULE
PIM:AddOption("Recognize", {
    runServer = false,
    shouldShow = function(client, target)
        local ourChar = client:getChar()
        local tarCharID = target:getChar():getID()
        return not hook.Run("isCharRecognized", ourChar, tarCharID)
    end,
    onRun = function(_, target) if CLIENT then netstream.Start("rgnDirect", target) end end
})

PIM:AddOption("Recognize With Fake Name", {
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

MODULE:AddLocalOption("Allow Recognition by Recognize in Whisper Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) MODULE:CharRecognize(2) end,
    runServer = false
})

MODULE:AddLocalOption("Allow Recognition by Recognize in Talk Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) MODULE:CharRecognize(3) end,
    runServer = false
})

MODULE:AddLocalOption("Allow Recognition by Recognize in Yell Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) MODULE:CharRecognize(4) end,
    runServer = false
})

MODULE:AddLocalOption("Allow Recognition by Fake Name in Whisper Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) if CLIENT then Derma_StringRequest(recogMenuOptionFakeWhisper, recogFakeNamePrompt, default or "", function(text) if text then MODULE:CharRecognize(2, text) end end) end end,
    runServer = false
})

MODULE:AddLocalOption("Allow Recognition by Fake Name in Talk Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) if CLIENT then Derma_StringRequest(recogMenuOptionFakeTalk, recogFakeNamePrompt, default or "", function(text) if text then MODULE:CharRecognize(3, text) end end) end end,
    runServer = false
})

MODULE:AddLocalOption("Allow Recognition by Fake Name in Yell Range", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client) if CLIENT then Derma_StringRequest(recogMenuOptionFakeYell, recogFakeNamePrompt, default or "", function(text) if text then MODULE:CharRecognize(4, text) end end) end end,
    runServer = false
})