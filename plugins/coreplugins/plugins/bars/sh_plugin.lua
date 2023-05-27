PLUGIN.name = "Bars"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Adds bars to display information."

if (SERVER) then return end

function PLUGIN:HUDPaint()
	lia.bar.drawAll()
end
