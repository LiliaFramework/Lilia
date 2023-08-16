--------------------------------------------------------------------------------------------------------
do
    lia.bar.add(function()
        return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
    end, Color(200, 50, 40), nil, "health")

    lia.bar.add(function()
        return math.min(LocalPlayer():Armor() / 100, 1)
    end, Color(30, 70, 180), nil, "armor")
end
--------------------------------------------------------------------------------------------------------