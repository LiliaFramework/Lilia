--------------------------------------------------------------------------------------------------------------------------
net.Receive(
    "liaModuleList",
    function()
        local length = net.ReadUInt(32)
        local modules = {}
        for i = 1, length do
            modules[net.ReadString()] = net.ReadBit() == 1
        end

        hook.Run("RetrievedModuleList", modules)
    end
)

--------------------------------------------------------------------------------------------------------------------------
net.Receive(
    "liaModuleDisable",
    function()
        local name = net.ReadString()
        local disabled = net.ReadBit() == 1
        hook.Run("ModuleConfigDisabled", name, disabled)
    end
)
--------------------------------------------------------------------------------------------------------------------------