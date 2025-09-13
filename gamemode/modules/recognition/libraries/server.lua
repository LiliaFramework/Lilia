local rangeMap = {
    whisper = "w",
    normal = "ic",
    talk = "ic",
    yell = "y"
}

function MODULE:ForceRecognizeRange(ply, range, fakeName)
    local char = ply:getChar()
    if not (char and ply:Alive()) then return end
    local key = rangeMap[range] or "ic"
    local cls = lia.chat.classes[key]
    if not cls then return end
    for _, v in player.Iterator() do
        if v ~= ply and v:getChar() and cls.onCanHear(ply, v) and v:getChar():recognize(char, fakeName) then lia.log.add(ply, "charRecognize", v:getChar():getID(), "FORCED") end
    end

    net.Start("rgnDone")
    net.Send(ply)
    hook.Run("OnCharRecognized", ply)
    hook.Run("CharacterForceRecognized", ply, range)
end