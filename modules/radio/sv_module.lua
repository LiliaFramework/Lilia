--------------------------------------------------------------------------------------------------------
util.AddNetworkString("RadioTransmit")
--------------------------------------------------------------------------------------------------------
function MODULE:PlayerCanHearPlayersVoice(listener, speaker)
    local speakerChar = speaker:getChar()
    local listenerChar = listener:getChar()
    if not speakerChar or not listenerChar then return false end
    local talitem = speakerChar:getInv():getFirstItemOfType("radio")
    local lisitem = listenerChar:getInv():getFirstItemOfType("radio")
    if not talitem or not lisitem then return false end
    local speakerFreq = tonumber(talitem:getData("freq"))
    local listenerFreq = tonumber(lisitem:getData("freq"))
    if not speakerFreq or not listenerFreq then return false end
    if speakerFreq == listenerFreq and speaker:GetNW2Bool("radio_voice") then return true end

    return false
end
--------------------------------------------------------------------------------------------------------