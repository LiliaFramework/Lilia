local MODULE = MODULE

properties.Add("persist", {
    MenuLabel = "#makepersistent",
    Order = 400,
    MenuIcon = "icon16/link.png",
    Filter = function(self, ent, ply)
        if ent:IsPlayer() then return false end
        if MODULE.blacklist[ent:GetClass()] then return false end
        if not gamemode.Call("CanProperty", ply, "persist", ent) then return false end

        return not ent:getNetVar("persistent", false)
    end,
    Action = function(self, ent)
        self:MsgStart()
        net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if not self:Filter(ent, ply) then return end
        ent:setNetVar("persistent", true)
        MODULE.entities[#MODULE.entities + 1] = ent
    end
})

properties.Add("persist_end", {
    MenuLabel = "#stoppersisting",
    Order = 400,
    MenuIcon = "icon16/link_break.png",
    Filter = function(self, ent, ply)
        if ent:IsPlayer() then return false end
        if not gamemode.Call("CanProperty", ply, "persist", ent) then return false end

        return ent:getNetVar("persistent", false)
    end,
    Action = function(self, ent)
        self:MsgStart()
        net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if not properties.CanBeTargeted(ent, ply) then return end
        if not self:Filter(ent, ply) then return end
        ent:setNetVar("persistent", false)

        -- Remove entity from registration
        for k, v in ipairs(MODULE.entities) do
            if v == entity then
                MODULE.entities[k] = nil
                break
            end
        end
    end
})