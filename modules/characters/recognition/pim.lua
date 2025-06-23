local MODULE = MODULE
function MODULE:CharRecognize(level, name)
    netstream.Start("rgn", level, name)
end

AddAction(L("recognizeInWhisperRange"), {
    shouldShow = function(client) return lia.config.get("RecognitionEnabled", true) and client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(2) end,
    runServer = false
})

AddAction(L("recognizeInTalkRange"), {
    shouldShow = function(client) return lia.config.get("RecognitionEnabled", true) and client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(3) end,
    runServer = false
})

AddAction(L("recognizeInYellRange"), {
    shouldShow = function(client) return lia.config.get("RecognitionEnabled", true) and client:getChar() and client:Alive() end,
    onRun = function() MODULE:CharRecognize(4) end,
    runServer = false
})

AddInteraction(L("recognizeOption"), {
    runServer = false,
    shouldShow = function(client, target)
        if not lia.config.get("RecognitionEnabled", true) then return false end
        local ourChar = client:getChar()
        local tarChar = target:getChar()
        return ourChar and tarChar and not hook.Run("isCharRecognized", ourChar, tarChar:getID())
    end,
    onRun = function(_, target) if CLIENT then netstream.Start("rgnDirect", target) end end
})

AddInteraction(L("recognizeWithFakeNameOption"), {
    runServer = false,
    shouldShow = function(client, target)
        if not lia.config.get("RecognitionEnabled", true) then return false end
        local ourChar = client:getChar()
        local tarChar = target:getChar()
        return ourChar and tarChar and not hook.Run("isCharRecognized", ourChar, tarChar:getID()) and lia.config.get("FakeNamesEnabled", false)
    end,
    onRun = function(_, target)
        local tarChar = target:getChar()
        if CLIENT then Derma_StringRequest(L("recogMenuOptionFakeWhisper"), L("recogFakeNamePrompt"), tarChar:getName(), function(text) if text then netstream.Start("rgnDirect", target, text) end end) end
    end
})