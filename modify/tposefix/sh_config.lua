local TposingModels = {
    "models/kerry/ag_player/male_03.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
}

for _, v in pairs(TposingModels) do
    lia.anim.setModelClass(v, "player")
end
