local MODULE = MODULE
MODULE.Actions = {}
MODULE.Interactions = {}
function AddInteraction(name, data)
    MODULE.Interactions[name] = data
    lia.bootstrap("Player Interaction Menu", "Added P2P Action: " .. name)
end

function AddAction(name, data)
    MODULE.Actions[name] = data
    lia.bootstrap("Action Menu", "Added Personal Action: " .. name)
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