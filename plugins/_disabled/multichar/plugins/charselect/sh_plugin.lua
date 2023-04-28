PLUGIN.name = "Lilia Character Selection"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "The Lilia character selection screen."

lia.util.includeDir(PLUGIN.path.."/derma/steps", true)

lia.config.add(
	"music",
	"music/hl2_song2.mp3",
	"The default music played in the character menu.",
	nil,
	{category = PLUGIN.name}
)
lia.config.add(
	"musicvolume",
	"0.25",
	"The Volume for the music played in the character menu.",
	nil,
	{
		form = "Float",
		data = {min = 0, max = 1},
		category = PLUGIN.name
	}
)
lia.config.add(
	"backgroundURL",
	"",
	"The URL or HTML for the background of the character menu.",
	nil,
	{category = PLUGIN.name}
)

lia.config.add(
	"charMenuBGInputDisabled",
	true,
	"Whether or not KB/mouse input is disabled in the character background.",
	nil,
	{category = PLUGIN.name}
)

if (SERVER) then return end

local function ScreenScale(size)
	return size * (ScrH() / 900) + 10
end

function PLUGIN:LoadFonts(font)
	surface.CreateFont("liaCharTitleFont", {
		font = font,
		weight = 200,
		size = ScreenScale(70),
		additive = true
	})
	surface.CreateFont("liaCharDescFont", {
		font = font,
		weight = 200,
		size = ScreenScale(24),
		additive = true
	})
	surface.CreateFont("liaCharSubTitleFont", {
		font = font,
		weight = 200,
		size = ScreenScale(12),
		additive = true
	})
	surface.CreateFont("liaCharButtonFont", {
		font = font,
		weight = 200,
		size = ScreenScale(24),
		additive = true
	})
	surface.CreateFont("liaCharSmallButtonFont", {
		font = font,
		weight = 200,
		size = ScreenScale(22),
		additive = true
	})
end

function PLUGIN:LiliaLoaded()
	vgui.Create("liaCharacter")
end

function PLUGIN:KickedFromCharacter(id, isCurrentChar)
	if (isCurrentChar) then
		vgui.Create("liaCharacter")
	end
end

function PLUGIN:CreateMenuButtons(tabs)
	tabs["characters"] = function(panel)
		if (IsValid(lia.gui.menu)) then
			lia.gui.menu:Remove()
		end
		vgui.Create("liaCharacter")
	end
end
