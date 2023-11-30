----------------------------------------------------------------------------------------------
if not PIM then return end
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
        onRun = function(client, target) if CLIENT then netstream.Start("rgnDirect", target) end end
    }
)

----------------------------------------------------------------------------------------------
if lia.config.FakeNamesEnabled then
    PIM:AddOption(
        "Allow This Player To Recognize You With A Fake Name",
        {
            runServer = false,
            shouldShow = function(client, target)
                local ourChar = client:getChar()
                local tarCharID = target:getChar():getID()
                return not hook.Run("IsCharRecognized", ourChar, tarCharID) and lia.config.FakeNamesEnabled
            end,
            onRun = function(client, target) if CLIENT then Derma_StringRequest("Allow those in whispering range to recognize you by a fake name.", "Enter a fake name to display to other players in range.", default or "", function(text) if text then netstream.Start("rgnDirect", target, text) end end) end end
        }
    )
end
----------------------------------------------------------------------------------------------
