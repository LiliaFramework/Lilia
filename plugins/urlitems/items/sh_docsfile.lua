ITEM.name = "Special Documents"
ITEM.desc = "Special documents that can be shown"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.price = 10

ITEM.functions.show = {
    icon = "icon16/user.png",
    name = "Show",
    onRun = function(item)
        local client = item.player

        if client.NextDocumentCheck and client.NextDocumentCheck > SysTime() then
            client:notify("You can't show documents that quickly...")

            return false
        end

        client.NextDocumentCheck = SysTime() + 5
        local target = client:GetEyeTrace().Entity

        if not target or not IsValid(target) or target:GetPos():Distance(client:GetPos()) > 100 then
            client:notify("Invalid target")

            return false
        end

        if item.docLink then
            local findString = "https://docs.google.com/"
            if item.docLink:sub(1, #findString) ~= findString then return end
            net.Start("SpecialDocumentsSendURL")
            net.WriteString(item.docLink)
            net.WriteString(client:Name())
            net.WriteString(item:getName())
            net.Send(target)
        end

        return false
    end,
    onCanRun = function(item)
        local trEnt = item.player:GetEyeTrace().Entity

        return item.docLink and IsValid(trEnt) and trEnt:IsPlayer()
    end
}

ITEM.functions.set = {
    name = "Set Link",
    onRun = function(item)
        local client = item.player
        net.Start("SpecialDocumentsExchange")
        net.WriteDouble(item.id)
        net.Send(client)

        return false
    end
}

ITEM.getName = function(self)
    return self.overrideName or (CLIENT and L(self.name) or self.name)
end

ITEM.getDesc = function(self)
    if self.overrideDesc then return self.overrideDesc end
    if not self.desc then return "ERROR" end

    return L(self.desc or "noDesc")
end