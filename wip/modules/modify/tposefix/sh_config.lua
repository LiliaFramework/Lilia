do
    for _, v in pairs(CONFIG.TposingModels) do
        lia.anim.setModelClass(v, "player")
    end
end