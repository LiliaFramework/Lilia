local function canRecog(ply)
    return lia.config.get("RecognitionEnabled", true) and ply:getChar() and ply:Alive()
end

local function hasPlayersInRange(ply, lvl)
    if not canRecog(ply) then return false end
    local clsKey = lvl == 3 and "ic" or lvl == 4 and "y" or "w"
    local cls = lia.chat.classes[clsKey]
    if not cls then return false end
    for _, v in player.Iterator() do
        if ply ~= v and v:getChar() and cls.onCanHear(ply, v) then return true end
    end
    return false
end

local function promptName(ply, cb)
    if lia.config.get("FakeNamesEnabled", false) then
        ply:requestString("Enter fake name", "", function(nm)
            nm = (nm or ""):Trim()
            cb(nm == "" and ply:getChar():getName() or nm)
        end, ply:getChar():getName())
    else
        cb()
    end
end

local function CharRecognize(ply, lvl, nm)
    local tgt = {}
    if isnumber(lvl) then
        local clsKey = lvl == 3 and "ic" or lvl == 4 and "y" or "w"
        local cls = lia.chat.classes[clsKey]
        for _, v in player.Iterator() do
            if ply ~= v and v:getChar() and cls.onCanHear(ply, v) then tgt[#tgt + 1] = v end
        end
    end

    if #tgt == 0 then return end
    local count = 0
    for _, v in ipairs(tgt) do
        if v:getChar():recognize(ply:getChar(), nm) then count = count + 1 end
    end

    if count == 0 then return end
    ply:notifySuccess(string.format("Gave Recognition to %s people.", count))
    for _, v in ipairs(tgt) do
    end

    net.Start("liaRgnDone")
    net.Send(ply)
    hook.Run("OnCharRecognized", ply)
end

local function doRange(ply, lvl)
    promptName(ply, function(nm) CharRecognize(ply, lvl, nm) end)
end

lia.playerinteract.addAction("Recognize in Whisper Range", {
    category = "Recognition",
    shouldShow = function(ply) return hasPlayersInRange(ply, 1) end,
    onRun = function(ply) doRange(ply, 1) end,
    serverOnly = true
})

lia.playerinteract.addAction("Recognize in Talk Range", {
    category = "Recognition",
    shouldShow = function(ply) return hasPlayersInRange(ply, 3) end,
    onRun = function(ply) doRange(ply, 3) end,
    serverOnly = true
})

lia.playerinteract.addAction("Recognize in Yell Range", {
    category = "Recognition",
    shouldShow = function(ply) return hasPlayersInRange(ply, 4) end,
    onRun = function(ply) doRange(ply, 4) end,
    serverOnly = true
})

lia.playerinteract.addInteraction("Give recognition to this person", {
    category = "Recognition",
    serverOnly = true,
    shouldShow = function(ply, tgt)
        if not canRecog(ply) then return false end
        local a, b = ply:getChar(), tgt:getChar()
        if not a or not b then return false end
        return not hook.Run("IsCharRecognized", a, b:getID())
    end,
    onRun = function(ply, tgt)
        promptName(ply, function(nm)
            if tgt:getChar():recognize(ply:getChar(), nm) then
                ply:notifySuccess(string.format("Gave Recognition to %s people.", 1))
                net.Start("liaRgnDone")
                net.Send(ply)
                hook.Run("OnCharRecognized", ply)
            end
        end)
    end
})
