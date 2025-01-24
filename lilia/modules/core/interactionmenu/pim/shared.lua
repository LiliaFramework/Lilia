local MODULE = MODULE
MODULE:AddOption("Give Money", {
    serverRun = false,
    shouldShow = function(client, target) return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0 end,
    onRun = function(client, target)
        local frame = vgui.Create("WolfFrame")
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

        frame.ok = frame:Add("DButton")
        frame.ok:SetSize(150, 30)
        frame.ok:CenterHorizontal()
        frame.ok:CenterVertical(0.7)
        frame.ok:SetText("Give Money")
        frame.ok:SetTextColor(color_white)
        frame.ok:SetFont("WB_Small")
        frame.ok.DoClick = frame.te.OnEnter
        function frame.ok:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, BC_NEUTRAL)
        end
    end
})

MODULE:AddLocalOption("Check Injury Status", {
    shouldShow = function(client) return client:getChar() and client:Alive() end,
    onRun = function(client)
        local injText, _ = hook.Run("GetInjuredText", client, true)
        if injText then client:ChatPrint("I feel like I am in " .. injText) end
    end,
    runServer = false
})
