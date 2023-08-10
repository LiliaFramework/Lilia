--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
lia.config.list = lia.config.list or {}
lia.config.load = lia.config.load or {}
--------------------------------------------------------------------------------------------------------
function lia.config.load()
    lia.config.load.protection()
    lia.config.load.core()
    lia.config.load.default()
    lia.config.load.gamepermissions()
    lia.config.load.miscellaneous()
    lia.config.load.tposingmodels()
    lia.config.load.perfomance()
    lia.config.load.permissions()
    lia.config.load.toolpermissions()
    hook.Run("InitializedConfig")
end