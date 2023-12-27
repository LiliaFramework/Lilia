RecognitionCore = RecognitionCore or lia.module.list["recognition"]
----------------------------------------------------------------------------------------------
PIM:AddOption(
    "Allow This Player To Recognize You",
    {
        runServer = false,
        shouldShow = function(client, target)
            local ourChar = client:getChar()
            local tarCharID = target:getChar():getID()
            return not hook.Run("IsCharRecognized", ourChar, tarCharID)
        end,
        onRun = function(_, target) if CLIENT then netstream.Start("rgnDirect", target) end end
    }
)

----------------------------------------------------------------------------------------------
PIM:AddOption(
    "Allow This Player To Recognize You With A Fake Name",
    {
        runServer = false,
        shouldShow = function(client, target)
            local ourChar = client:getChar()
            local tarCharID = target:getChar():getID()
            return not hook.Run("IsCharRecognized", ourChar, tarCharID) and RecognitionCore.FakeNamesEnabled
        end,
        onRun = function(_, target) if CLIENT then Derma_StringRequest("Allow this person to recognize you by a fake name.", "Enter a fake name to display to this player.", default or "", function(text) if text then netstream.Start("rgnDirect", target, text) end end) end end
    }
)
----------------------------------------------------------------------------------------------
