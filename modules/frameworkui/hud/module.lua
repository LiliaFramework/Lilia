MODULE.name = "HUD"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Implements Lilia HUD Elements."
if CLIENT then
    lia.option.add("descriptionWidth", "Description Width", "Adjust the description width on the HUD", 0.5, nil, {
        category = "HUD",
        min = 0.1,
        max = 1,
        decimals = 2
    })
end
