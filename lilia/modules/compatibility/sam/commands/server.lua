
lia.command.add(
    "cleardecals",
    {
        adminOnly = true,
        privilege = "Clear Decals",
        onRun = function()
            for _, v in pairs(player.GetAll()) do
                v:ConCommand("r_cleardecals")
            end
        end
    }
)

