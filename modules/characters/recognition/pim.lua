local MODULE = MODULE
PIM:AddLocalOption(L("recognizeInWhisperRange"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(2) end,
    runServer = false
})

PIM:AddLocalOption(L("recognizeInTalkRange"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(3) end,
    runServer = false
})

PIM:AddLocalOption(L("recognizeInYellRange"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(4) end,
    runServer = false
})

PIM:AddOption(L("recognizeOption"), {
    runServer = false,
    shouldShow = function(client, target)
        local ourChar = client:getChar()
        local tarCharID = target:getChar():getID()
        return not hook.Run("isCharRecognized", ourChar, tarCharID)
    end,
    onRun = function(_, target) if CLIENT then netstream.Start("rgnDirect", target) end end
})

PIM:AddOption(L("recognizeWithFakeNameOption"), {
    runServer = false,
    shouldShow = function(client, target)
        local ourChar = client:getChar()
        local tarCharID = target:getChar():getID()
        return not hook.Run("isCharRecognized", ourChar, tarCharID) and lia.config.get("FakeNamesEnabled", false)
    end,
    onRun = function(_, target)
        local tarChar = target:getChar()
        if CLIENT then Derma_StringRequest(L("recogMenuOptionFakeWhisper"), L("recogFakeNamePrompt"), tarChar:getName(), function(text) if text then netstream.Start("rgnDirect", target, text) end end) end
    end
})
