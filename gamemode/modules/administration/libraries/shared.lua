function MODULE:CanPlayerModifyConfig(client)
    return client:hasPrivilege("Staff Permissions - Access Edit Configuration Menu")
end

properties.Add("TogglePropBlacklist", {
    MenuLabel = L("TogglePropBlacklist"),
    Order = 900,
    MenuIcon = "icon16/link.png",
    Filter = function(_, ent, ply) return IsValid(ent) and ent:GetClass() == "prop_physics" and ply:hasPrivilege("Staff Permissions - Manage Prop Blacklist") end,
    Action = function(self, ent)
        self:MsgStart()
        net.WriteString(ent:GetModel())
        self:MsgEnd()
    end,
    Receive = function(_, _, ply)
        if not ply:hasPrivilege("Staff Permissions - Manage Prop Blacklist") then return end
        local model = net.ReadString()
        local list = lia.data.get("blacklist", {})
        if table.HasValue(list, model) then
            table.RemoveByValue(list, model)
            lia.data.set("blacklist", list, true, true)
            ply:notifyLocalized("removedFromBlacklist", model)
        else
            table.insert(list, model)
            lia.data.set("blacklist", list, true, true)
            ply:notifyLocalized("addedToBlacklist", model)
        end
    end
})

properties.Add("copytoclipboard", {
    MenuLabel = "Copy Model to Clipboard",
    Order = 999,
    MenuIcon = "icon16/cup.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return true
    end,
    Action = function(self, ent)
        self:MsgStart()
        local s = ent:GetModel()
        SetClipboardText(s)
        print(s)
        self:MsgEnd()
    end,
    Receive = function() end
})
