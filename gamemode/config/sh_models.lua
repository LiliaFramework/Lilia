--------------------------------------------------------------------------------------------------------
function lia.config.LoadModels()
    lia.config.PlayerModelTposingFixer = {
        ["path/to/model.mdl"] = "player",
        ["path/to/model.mdl"] = "player",
        ["path/to/model.mdl"] = "player",
        ["path/to/model.mdl"] = "player",
    }

    for model, animtype in pairs(lia.config.PlayerModelTposingFixer) do
        lia.anim.setModelClass(model, animtype)
    end
end
--------------------------------------------------------------------------------------------------------