local PLUGIN = PLUGIN
PLUGIN.name = "Doors"
PLUGIN.author = "Leonheart#7476/Cheesenot & Leonheart#7476"
PLUGIN.desc = "A simple door system / Now has multifaction support!"
DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0
lia.util.include("sv_plugin.lua")
lia.util.include("cl_plugin.lua")
lia.util.include("sh_commands.lua")

do
    local entityMeta = FindMetaTable("Entity")

    function entityMeta:getDoorOwner()
        if not self:isDoor() then return nil end
        local parent = self.liaParent
        if IsValid(parent) then return parent:getDoorOwner() end
        if not self.liaAccess then return nil end

        for client, access in pairs(self.liaAccess) do
            if access == DOOR_OWNER then return client end
        end

        return nil
    end

    function entityMeta:checkDoorAccess(client, access)
        if not self:isDoor() then return false end
        access = access or DOOR_GUEST
        local parent = self.liaParent
        if IsValid(parent) then return parent:checkDoorAccess(client, access) end
        if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
        if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end

        return false
    end

    function entityMeta:CheckDoorAccess(client, access)
        if not self:IsDoor() then return false end
        access = access or DOOR_GUEST
        local parent = self.ixParent
        if IsValid(parent) then return parent:CheckDoorAccess(client, access) end
        if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
        if self.ixAccess and (self.ixAccess[client] or 0) >= access then return true end

        return false
    end

    if SERVER then
        function entityMeta:keysOwn(client)
            if not self:isDoor() then return end

            if self.liaParent then
                self.liaParent:keysOwn(client)

                return
            end

            self:SetDTEntity(0, client)
            self.liaAccess = self.liaAccess or {}
            self.liaAccess[client] = DOOR_OWNER

            PLUGIN:callOnDoorChildren(self, function(child)
                child:SetDTEntity(0, client)
            end)

            PLUGIN:UpdateClientDoorAccess(self, client, DOOR_OWNER)
        end

        function entityMeta:keysUnOwn(client)
            if not self:isDoor() then return end

            if self.liaParent then
                self.liaParent:keysUnOwn(client)

                return
            end

            self:SetDTEntity(0, nil)
            self.liaAccess = self.liaAccess or {}
            self.liaAccess[client] = DOOR_NONE

            PLUGIN:callOnDoorChildren(self, function(child)
                child:SetDTEntity(0, nil)
            end)

            PLUGIN:UpdateClientDoorAccess(self, client, DOOR_NONE)
        end

        function entityMeta:addKeysDoorOwner(client)
            if not self:isDoor() then return end

            if self.liaAccess then
                self.liaAccess:addKeysDoorOwner(client)

                return
            end

            self.liaAccess = self.liaAccess or {}
            self.liaAccess[client] = DOOR_TENANT
            PLUGIN:UpdateClientDoorAccess(self, client, DOOR_TENANT)
        end

        function entityMeta:removeKeysDoorOwner(client)
            if not self:isDoor() then return end

            if self.liaParent then
                self.liaParent:removeKeysDoorOwner(client)

                return
            end

            self.liaAccess = self.liaAccess or {}
            self.liaAccess[client] = DOOR_NONE
            PLUGIN:UpdateClientDoorAccess(self, client, DOOR_NONE)
        end

        function entityMeta:removeDoorAccessData()
            if IsValid(self) then
                for k, v in pairs(self.liaAccess or {}) do
                    netstream.Start(k, "doorMenu")
                end

                self.liaAccess = {}
                self:SetDTEntity(0, nil)
            end
        end

        function entityMeta:RemoveDoorAccessData()
            local receivers = {}

            for k, _ in pairs(self.ixAccess or {}) do
                receivers[#receivers + 1] = k
            end

            if #receivers > 0 then
                net.Start("ixDoorMenu")
                net.Send(receivers)
            end

            self.ixAccess = {}
            self:SetDTEntity(0, nil)

            -- Remove door information on child doors
            PLUGIN:CallOnDoorChildren(self, function(child)
                child:SetDTEntity(0, nil)
            end)
        end
    end
end
-- Configurations for door prices.
lia.config.add("doorCost", 10, "The price to purchase a door.", nil, {
    data = {
        min = 0,
        max = 500
    },
    category = "dConfigName"
})

lia.config.add("doorSellRatio", 0.5, "How much of the door price is returned when selling a door.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 1.0
    },
    category = "dConfigName"
})

lia.config.add("doorLockTime", 1, "How long it takes to (un)lock a door.", nil, {
    form = "Float",
    data = {
        min = 0,
        max = 10.0
    },
    category = "dConfigName"
})
