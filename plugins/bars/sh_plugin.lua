PLUGIN.name = "Bars"
PLUGIN.author = "Cheesenot"
PLUGIN.desc = "Adds bars to display information."

if (SERVER) then return end

function PLUGIN:HUDPaint()
	lia.bar.drawAll()
end
