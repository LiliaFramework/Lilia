local MODULE = MODULE
MODULE.Actions = {}
MODULE.Interactions = {}
function AddInteraction(name, data)
    MODULE.Interactions[name] = data
end

function AddAction(name, data)
    MODULE.Actions[name] = data
end

AddInteraction("giveMoney", {
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

AddInteraction("inviteToClass", {
    runServer = true,
    shouldShow = function(client, target)
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return false end
        if cChar:hasFlags("X") then return true end
        local classData = lia.class.list[cChar:getClass()]
        if classData and classData.canInviteToClass then return true end
        if cChar:getFaction() ~= tChar:getFaction() then return false end
        return hook.Run("CanInviteToClass", client, target) ~= false
    end,
    onRun = function(client, target)
        if not SERVER then return end
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return end
        local class = lia.class.list[cChar:getClass()]
        if not class then
            client:notifyLocalized("invalidClass")
            return
        end

        target:binaryQuestion(L("joinClassPrompt"), L("yes"), L("no"), false, function(choice)
            if choice ~= 0 then
                client:notifyLocalized("inviteDeclined")
                return
            end

            if hook.Run("CanCharBeTransfered", tChar, class, tChar:getClass()) == false then return end
            local oldClass = tChar:getClass()
            tChar:setClass(class.index)
            hook.Run("OnPlayerJoinClass", target, class.index, oldClass)
            client:notifyLocalized("transferSuccess", target:Name(), class.name)
            if client ~= target then target:notifyLocalized("transferNotification", class.name, client:Name()) end
        end)
    end
})

AddAction("changeToWhisper", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", L("whispering"))
        client:notifyLocalized("voiceModeSet", L("whispering"))
    end,
    runServer = true
})

AddAction("changeToTalk", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", L("talking"))
        client:notifyLocalized("voiceModeSet", L("talking"))
    end,
    runServer = true
})

AddAction("changeToYell", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        if CLIENT then return end
        client:setNetVar("VoiceType", L("yelling"))
        client:notifyLocalized("voiceModeSet", L("yelling"))
    end,
    runServer = true
})

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
    ply:notifyLocalized("recognitionGiven", count)
    for _, v in ipairs(tgt) do
        lia.log.add(ply, "charRecognize", v:getChar():getID(), nm)
    end

    net.Start("rgnDone")
    net.Send(ply)
    hook.Run("OnCharRecognized", ply)
end

local function doRange(ply, lvl)
    promptName(ply, function(nm) CharRecognize(ply, lvl, nm) end)
end

AddAction("recognizeInWhisperRange", {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        doRange(ply, 1)
    end,
    runServer = true
})

AddAction("recognizeInTalkRange", {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        doRange(ply, 3)
    end,
    runServer = true
})

AddAction("recognizeInYellRange", {
    shouldShow = function(ply) return canRecog(ply) end,
    onRun = function(ply)
        if CLIENT then return end
        doRange(ply, 4)
    end,
    runServer = true
})

AddInteraction("recognizeOption", {
    runServer = true,
    shouldShow = function(ply, tgt)
        if not canRecog(ply) then return false end
        local a, b = ply:getChar(), tgt:getChar()
        if not a or not b then return false end
        return not hook.Run("isCharRecognized", a, b:getID())
    end,
    onRun = function(ply, tgt)
        if CLIENT then return end
        promptName(ply, function(nm)
            if tgt:getChar():recognize(ply:getChar(), nm) then
                ply:notifyLocalized("recognitionGiven", 1)
                lia.log.add(ply, "charRecognize", tgt:getChar():getID(), nm)
                net.Start("rgnDone")
                net.Send(ply)
                hook.Run("OnCharRecognized", ply)
            end
        end)
    end
})

AddInteraction("inviteToFaction", {
    runServer = true,
    shouldShow = function(client, target)
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return false end
        if cChar:hasFlags("Z") then return true end
        local classData = lia.class.list[cChar:getClass()]
        if classData and classData.canInviteToFaction then return true end
        return hook.Run("CanInviteToFaction", client, target) ~= false and cChar:getFaction() ~= tChar:getFaction()
    end,
    onRun = function(client, target)
        if not SERVER then return end
        local iChar = client:getChar()
        local tChar = target:getChar()
        if not iChar or not tChar then return end
        local faction
        for _, fac in pairs(lia.faction.teams) do
            if fac.index == client:Team() then faction = fac end
        end

        if not faction then
            client:notifyLocalized("invalidFaction")
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyLocalized("staffInviteBlocked")
            return
        end

        target:binaryQuestion(L("joinFactionPrompt"), L("yes"), L("no"), false, function(choice)
            if choice ~= 0 then
                client:notifyLocalized("inviteDeclined")
                return
            end

            if hook.Run("CanCharBeTransfered", tChar, faction, tChar:getFaction()) == false then return end
            local oldFaction = tChar:getFaction()
            tChar.vars.faction = faction.uniqueID
            tChar:setFaction(faction.index)
            tChar:kickClass()
            local defClass = lia.faction.getDefaultClass(faction.index)
            if defClass then tChar:joinClass(defClass.index) end
            hook.Run("OnTransferred", target)
            if faction.OnTransferred then faction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            client:notifyLocalized("transferSuccess", target:Name(), faction.name)
            if client ~= target then target:notifyLocalized("transferNotification", faction.name, client:Name()) end
            tChar:takeFlags("Z")
        end)
    end
})