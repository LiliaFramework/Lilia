local MODULE = MODULE
MODULE.Options = MODULE.Options or {}
MODULE.SelfOptions = MODULE.SelfOptions or {}
local MaxInteractionDistance = 250 * 250
function AddInteraction(name, data)
    MODULE.Options[name] = data
    LiliaBootstrap("Player Interaction Menu", "Added P2P Action: " .. name)
end

function AddAction(name, data)
    MODULE.SelfOptions[name] = data
    LiliaBootstrap("Action Menu", "Added Personal Action: " .. name)
end

function MODULE:CheckPossibilities()
    local client = LocalPlayer()
    for _, v in pairs(self.Options) do
        if not client:getTracedEntity():IsPlayer() then return end
        if v.shouldShow(client, client:getTracedEntity()) then return true end
    end
    return false
end

function MODULE:InitializedModules()
    hook.Run("AddPIMOption", self.Options)
    hook.Run("AddLocalPIMOption", self.SelfOptions)
end

function MODULE:CheckDistance(client, entity)
    return entity:GetPos():DistToSqr(client:GetPos()) < MaxInteractionDistance
end

AddAction("Give Money", {
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