local MODULE = MODULE
MODULE.Actions = {}
MODULE.Interactions = {}
function AddInteraction(name, data)
    MODULE.Interactions[name] = data
end

function AddAction(name, data)
    MODULE.Actions[name] = data
end

AddInteraction(L("giveMoney"), {
    serverRun = false,
    shouldShow = function(client, target) return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0 end,
    onRun = function(client, target)
        local frame = vgui.Create("DFrame")
        frame:SetSize(600, 250)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle(L("enterAmount"))
        frame:ShowCloseButton(false)
        frame.te = frame:Add("DTextEntry")
        frame.te:SetSize(frame:GetWide() * 0.6, 30)
        frame.te:SetNumeric(true)
        frame.te:Center()
        frame.te:RequestFocus()
        function frame.te:OnEnter()
            local val = tonumber(frame.te:GetText())
            if not val or val <= 0 then
                client:notifyLocalized("moneyValueError")
                return
            end

            val = math.ceil(val)
            if not client:getChar():hasMoney(val) then
                client:notifyLocalized("notEnoughMoney")
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
        frame.ok:SetText(L("giveMoney"))
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
    print(L("debugCanRecog", ply:Nick(), tostring(ok)))
    return ok
end

local function promptName(ply, cb)
    print(L("debugPromptName", ply:Nick()))
    if lia.config.get("FakeNamesEnabled", false) then
        ply:requestString(L("recogFakeNamePrompt"), "", function(nm)
            nm = (nm or ""):Trim()
            local finalName = nm == "" and ply:getChar():getName() or nm
            print(L("debugEnteredFakeName", ply:Nick(), finalName))
            cb(finalName)
        end, ply:getChar():getName())
    else
        print(L("debugUsingRealName", ply:Nick()))
        cb()
    end
end

local function CharRecognize(ply, lvl, nm)
    print(L("debugCharRecognize", ply:Nick(), tostring(lvl), nm or "nil"))
    local tgt = {}
    if isnumber(lvl) then
        local clsKey = lvl == 3 and "ic" or lvl == 4 and "y" or "w"
        local cls = lia.chat.classes[clsKey]
        for _, v in player.Iterator() do
            if ply == v then continue end
            if v:getChar() and cls.onCanHear(ply, v) then tgt[#tgt + 1] = v end
        end
    end

    print(L("debugTargetsFound", ply:Nick(), #tgt))
    if #tgt == 0 then return end
    local count = 0
    for _, v in ipairs(tgt) do
        local success = v:getChar():recognize(ply:getChar(), nm)
        if success then
            count = count + 1
            print(L("debugRecognized", ply:Nick(), v:Nick()))
        else
            print(L("debugFailedRecognize", ply:Nick(), v:Nick()))
        end
    end

    if count == 0 then return end
    for _, v in ipairs(tgt) do
        lia.log.add(ply, "charRecognize", v:getChar():getID(), nm)
    end

    net.Start("rgnDone")
    net.Send(ply)
    print(L("debugRecognitionComplete", ply:Nick(), count))
    hook.Run("OnCharRecognized", ply)
end

local function doRange(ply, lvl)
    print(L("debugDoRange", ply:Nick(), tostring(lvl)))
    promptName(ply, function(nm)
        print(L("debugDoRangeCallback", ply:Nick(), nm or "nil"))
        CharRecognize(ply, lvl, nm)
    end)
end

AddAction(L("recognizeInWhisperRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(L("debugActionWhisper", ply:Nick()))
        doRange(ply, 1)
    end,
    runServer = true
})

AddAction(L("recognizeInTalkRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(L("debugActionTalk", ply:Nick()))
        doRange(ply, 3)
    end,
    runServer = true
})

AddAction(L("recognizeInYellRange"), {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        print(L("debugActionYell", ply:Nick()))
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
        print(L("debugInteractionTriggered", ply:Nick(), tgt:Nick()))
        promptName(ply, function(nm)
            print(L("debugInteractionCallback", ply:Nick(), nm or "nil"))
            if tgt:getChar():recognize(ply:getChar(), nm) then
                lia.log.add(ply, "charRecognize", tgt:getChar():getID(), nm)
                net.Start("rgnDone")
                net.Send(ply)
                hook.Run("OnCharRecognized", ply)
                print(L("debugInteractionSuccess", ply:Nick(), tgt:Nick()))
            else
                print(L("debugInteractionFail", ply:Nick(), tgt:Nick()))
            end
        end)
    end
})
