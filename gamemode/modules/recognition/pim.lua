local function canRecog(ply)
    return lia.config.get("RecognitionEnabled", true) and ply:getChar() and ply:Alive()
end

local function promptName(ply, cb)
    if lia.config.get("FakeNamesEnabled", false) then
        ply:requestString(L("recogFakeNamePrompt"), "", function(nm)
            nm = (nm or ""):Trim()
            local finalName = nm == "" and ply:getChar():getName() or nm
            cb(finalName)
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
    ply:notifySuccessLocalized("recognitionGiven", count)
    for _, v in ipairs(tgt) do
        lia.log.add(ply, "charRecognize", v:getChar():getID(), nm)
    end

    net.Start("liaRgnDone")
    net.Send(ply)
    hook.Run("OnCharRecognized", ply)
end

local function doRange(ply, lvl)
    promptName(ply, function(nm) CharRecognize(ply, lvl, nm) end)
end

lia.playerinteract.addAction("@recognizeInWhisperRange", {
    category = "categoryRecognition",
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply) doRange(ply, 1) end,
    serverOnly = true
})

lia.playerinteract.addAction("@recognizeInTalkRange", {
    category = "categoryRecognition",
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply) doRange(ply, 3) end,
    serverOnly = true
})

lia.playerinteract.addAction("@recognizeInYellRange", {
    category = "categoryRecognition",
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply) doRange(ply, 4) end,
    serverOnly = true
})

lia.playerinteract.addInteraction("@recognizeOption", {
    serverOnly = true,
    shouldShow = function(ply, tgt)
        if not canRecog(ply) then return false end
        local a, b = ply:getChar(), tgt:getChar()
        if not a or not b then return false end
        return not hook.Run("isCharRecognized", a, b:getID())
    end,
    onRun = function(ply, tgt)
        promptName(ply, function(nm)
            if tgt:getChar():recognize(ply:getChar(), nm) then
                ply:notifySuccessLocalized("recognitionGiven", 1)
                lia.log.add(ply, "charRecognize", tgt:getChar():getID(), nm)
                net.Start("liaRgnDone")
                net.Send(ply)
                hook.Run("OnCharRecognized", ply)
            end
        end)
    end
})
