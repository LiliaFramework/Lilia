ITEM.name = "Flashlight"
ITEM.model = "models/Items/battery.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A standard flashlight that can be toggled."
ITEM:hook("drop", function(item) item.player:Flashlight(false) end)
