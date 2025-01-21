MODULE.name = "Weapon Selector"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds a Weapon Selector UI"
if CLIENT then
    lia.option.add("invertWeaponScroll", "Invert Weapon Scroll", "Invert the weapon selection scroll direction", false, nil, {
        category = "Miscellaneous",
        IsQuick = true
    })
end
