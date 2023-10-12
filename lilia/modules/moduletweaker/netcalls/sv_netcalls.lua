--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaModuleDisable")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaModuleList")
--------------------------------------------------------------------------------------------------------------------------
net.Receive(
    "liaModuleDisable",
    function(_, client)
        if not client:IsSuperAdmin() then return end
        local name = net.ReadString()
        local disabled = net.ReadBit() == 1
        MODULE:setModuleDisabled(name, disabled)
    end
)

--------------------------------------------------------------------------------------------------------------------------
net.Receive(
    "liaModuleList",
    function(_, client)
        if not client:IsSuperAdmin() then return end
        local modules = MODULE:getModuleList()
        local disabled
        net.Start("liaModuleList")
        net.WriteUInt(#modules, 32)
        for k, module in ipairs(modules) do
            if MODULE.overwrite[module] ~= nil then
                disabled = MODULE.overwrite[module]
            else
                disabled = lia.module.isDisabled(module)
            end

            net.WriteString(module)
            net.WriteBit(disabled)
        end

        net.Send(client)
    end
)
--------------------------------------------------------------------------------------------------------------------------