local MODULE = MODULE
MODULE.Actions = {}
MODULE.Interactions = {}
function AddInteraction(name, data)
    MODULE.Interactions[name] = data
end

function AddAction(name, data)
    MODULE.Actions[name] = data
end

AddInteraction("Give Money", {
    serverRun = false,
    shouldShow = function(client, target) return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0 end,
    onRun = function(client, target)
        local frame = vgui.Create("DFrame")
        frame:SetSize(600, 250)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("Enter amount")
        frame:ShowCloseButton(false)
        frame.te = frame:Add("DTextEntry")
        frame.te:SetSize(frame:GetWide() * 0.6, 30)
        frame.te:SetNumeric(true)
        frame.te:Center()
        frame.te:RequestFocus()
        function frame.te:OnEnter()
            local val = tonumber(frame.te:GetText())
            if not val or val <= 0 then
                client:notify("You need to insert a value bigger than 0.", NOT_ERROR)
                return
            end

            val = math.ceil(val)
            if not client:getChar():hasMoney(val) then
                client:notify("You don't have enough money", NOT_ERROR)
                return
            end

            net.Start("TransferMoneyFromP2P")
            net.WriteUInt(val, 32)
            net.WriteEntity(target)
            net.SendToServer()
            frame:Close()
        end

        frame.ok = frame:Add("liaMediumButton")
        frame.ok:SetSize(150, 30)
        frame.ok:CenterHorizontal()
        frame.ok:CenterVertical(0.7)
        frame.ok:SetText("Give Money")
        frame.ok:SetTextColor(color_white)
        frame.ok:SetFont("liaSmallFont")
        frame.ok.DoClick = frame.te.OnEnter
    end
})

AddAction(L("changeToWhisper"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", "Whispering")
    end,
    runServer = true
})

AddAction(L("changeToTalk"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", "Talking")
    end,
    runServer = true
})

AddAction(L("changeToYell"), {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", "Yelling")
    end,
    runServer = true
})

local function canRecog(ply)
    local ok = lia.config.get("RecognitionEnabled", true) and ply:getChar() and ply:Alive()
    print(ply:Nick(), "canRecog:", ok)
    return ok
end

local function promptName(ply, cb)
    print(ply:Nick(), "promptName called")
    if lia.config.get("FakeNamesEnabled", false) then
        ply:requestString(L("recogFakeNamePrompt"), "", function(nm)
            nm = (nm or ""):Trim()
            local finalName = nm == "" and ply:getChar():getName() or nm
            print(ply:Nick(), "entered fake name:", finalName)
            cb(finalName)
        end, ply:getChar():getName())
    else
        print(ply:Nick(), "using real name")
        cb()
    end
end

local function CharRecognize(ply, lvl, nm)
    print(ply:Nick(), "CharRecognize called with level", lvl, "and name", nm or "nil")
    local tgt = {}
    if isnumber(lvl) then
        local clsKey = lvl == 3 and "ic" or lvl == 4 and "y" or "w"
        local cls = lia.chat.classes[clsKey]
        for _, v in player.Iterator() do
            if ply == v then continue end
            if v:getChar() and cls.onCanHear(ply, v) then tgt[#tgt + 1] = v end
        end
    end

    print(ply:Nick(), "found", #tgt, "targets to recognize")
    if #tgt == 0 then return end
    local count = 0
    for _, v in ipairs(tgt) do
        local success = v:getChar():recognize(ply:getChar(), nm)
        if success then
            count = count + 1
            print(ply:Nick(), "recognized", v:Nick())
        else
            print(ply:Nick(), "failed to recognize", v:Nick())
        end
    end

    if count == 0 then return end
    for _, v in ipairs(tgt) do
        lia.log.add(ply, "charRecognize", v:getChar():getID(), nm)
    end

    net.Start("rgnDone")
    net.Send(ply)
    print(ply:Nick(), "recognition complete, total successes:", count)
    hook.Run("OnCharRecognized", ply)
end

local function doRange(ply, lvl)
    print(ply:Nick(), "doRange called with level", lvl)
    promptName(ply, function(nm)
        print(ply:Nick(), "doRange callback with name", nm or "nil")
        CharRecognize(ply, lvl, nm)
    end)
end

AddAction(L("recognizeInWhisperRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(ply:Nick(), "action recognizeInWhisperRange triggered")
        doRange(ply, 1)
    end,
    runServer = true
})

AddAction(L("recognizeInTalkRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(ply:Nick(), "action recognizeInTalkRange triggered")
        doRange(ply, 3)
    end,
    runServer = true
})

AddAction(L("recognizeInYellRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(ply:Nick(), "action recognizeInYellRange triggered")
        doRange(ply, 4)
    end,
    runServer = true
})

AddInteraction(L("recognizeOption"), {
    runServer = true,
    shouldShow = function(ply, tgt)
        if not canRecog(ply) then return false end
        local a, b = ply:getChar(), tgt:getChar()
        local show = a and b and not hook.Run("isCharRecognized", a, b:getID())
        return show
    end,
    onRun = function(ply, tgt)
        if CLIENT then return end
        print(ply:Nick(), "interaction recognizeOption triggered on", tgt:Nick())
        promptName(ply, function(nm)
            print(ply:Nick(), "interaction callback with name", nm or "nil")
            if tgt:getChar():recognize(ply:getChar(), nm) then
                lia.log.add(ply, "charRecognize", tgt:getChar():getID(), nm)
                net.Start("rgnDone")
                net.Send(ply)
                hook.Run("OnCharRecognized", ply)
                print(ply:Nick(), "interaction recognition succeeded on", tgt:Nick())
            else
                print(ply:Nick(), "interaction recognition failed on", tgt:Nick())
            end
        end)
    end
})