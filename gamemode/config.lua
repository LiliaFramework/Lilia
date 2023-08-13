--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
lia.config.list = lia.config.list or {}
--------------------------------------------------------------------------------------------------------
function lia.config.load()
    lia.config.load_protection()
    lia.config.load_core()
    lia.config.load_default()
    lia.config.load_miscellaneous()
    lia.config.load_tposingmodels()
    lia.config.load_perfomance()
    lia.config.load_permissions()
    lia.config.load_toolpermissions()
    hook.Run("InitializedConfig")
end