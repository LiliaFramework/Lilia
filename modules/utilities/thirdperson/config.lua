lia.config.add( "ThirdPersonEnabled", "Enable Third-Person View", true, nil, {
	desc = "Allows players to toggle third-person view on or off.",
	category = "Third Person",
	type = "Boolean"
} )

lia.config.add( "MaxThirdPersonDistance", "Maximum Third-Person Distance", 100, nil, {
	desc = "The maximum allowable camera distance in third-person view.",
	category = "Third Person",
	type = "Int"
} )

lia.config.add( "WallPeek", "Wall Peek", true, nil, {
	desc = "Limits third‑person wall peeking by hiding players outside view or obstructed.",
	category = "Rendering",
	type = "Boolean"
} )

lia.config.add( "MaxThirdPersonHorizontal", "Maximum Third-Person Horizontal Offset", 30, nil, {
	desc = "The maximum allowable horizontal offset for third-person view.",
	category = "Third Person",
	type = "Int"
} )

lia.config.add( "MaxThirdPersonHeight", "Maximum Third-Person Height Offset", 30, nil, {
	desc = "The maximum allowable vertical offset for third-person view.",
	category = "Third Person",
	type = "Int"
} )

lia.config.add( "MaxViewDistance", "Maximum View Distance", 5000, nil, {
	desc = "The maximum distance (in units) at which players are visible.",
	category = "Quality of Life",
	type = "Int",
	min = 1000,
	max = 5000,
} )

if CLIENT then
	lia.option.add( "thirdPersonEnabled", "Third Person Enabled", "Toggle third-person view.", false, function( _, newValue ) hook.Run( "thirdPersonToggled", newValue ) end, {
		category = "Third Person",
	} )

	lia.option.add( "thirdPersonClassicMode", "Third Person Classic Mode", "Enable classic third-person view mode.", false, nil, {
		category = "Third Person",
	} )

	lia.option.add( "thirdPersonHeight", "Third Person Height", "Adjust the vertical height of the third-person camera.", 10, nil, {
		category = "Third Person",
		min = 0,
		max = lia.config.get( "MaxThirdPersonHeight", 30 ),
	} )

	lia.option.add( "thirdPersonHorizontal", "Third Person Horizontal", "Adjust the horizontal offset of the third-person camera.", 10, nil, {
		category = "Third Person",
		min = 0,
		max = lia.config.get( "MaxThirdPersonHorizontal", 30 ),
	} )

	lia.option.add( "thirdPersonDistance", "Third Person Distance", "Adjust the camera distance in third-person view.", 50, nil, {
		category = "Third Person",
		min = 0,
		max = lia.config.get( "MaxThirdPersonDistance", 100 ),
	} )
end
