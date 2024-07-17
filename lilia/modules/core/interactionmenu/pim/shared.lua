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
            if val <= 0 then
                client:notify("You need to insert a value bigger than 0.", NOT_ERROR)
                return
            end

            if math.modf(val) > 0 then val = math.ceil(val) end
            if not client:getChar():hasMoney(val) then
                client:notify("You don't have enough money", NOT_ERROR)
                return
            end

            netstream.Start("transferMoneyFromP2P", val, target, hook.Run("GetDisplayedName", target) or target:getChar():getName(), hook.Run("GetDisplayedName", client) or client:getChar():getName())
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
