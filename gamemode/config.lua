--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
--------------------------------------------------------------------------------------------------------
function GM:LoadConfigValues()
    if not lia.config.LoadedSchemaCoreConfig then
        print("CONFIG: Loaded Default Core Config")
    else
        print("CONFIG: Loaded Schema Core Config")
    end

    if not lia.config.LoadedSchemaTposeModelConfig then
        print("CONFIG: Loaded Default TPose Fixer!")
    else
        print("CONFIG: Loaded Schema Model Fixer Config")
    end
    self:LoadCoreConfig()
    self:LoadModelsConfig()
    hook.Run("InitializedConfig")
end
--------------------------------------------------------------------------------------------------------