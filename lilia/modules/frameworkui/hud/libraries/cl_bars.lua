lia.bar.add(function() local client = LocalPlayer() return client:Health() / client:GetMaxHealth() end, Color(200, 50, 40), nil, "health")
lia.bar.add(function()local client = LocalPlayer() return math.min(client:Armor() / 100, 1) end, Color(30, 70, 180), nil, "armor")
