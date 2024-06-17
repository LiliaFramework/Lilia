--- Hook Documentation for HUD Module.
-- @hooks HUD
--- Whether or not the ammo HUD should be drawn.
-- @realm client
-- @entity weapon Weapon the player currently is holding
-- @treturn bool Whether or not to draw the ammo hud
function ShouldDrawAmmoHUD(weapon)
end

--- Determines whether a bar should be drawn.
-- @realm client
-- @tab bar The bar object.
-- @treturn boolean True if the bar should be drawn, false otherwise.
function ShouldBarDraw(bar)
end

--- Determines whether the crosshair should be drawn for a specific client and weapon.
-- @realm client
-- @client client The player entity.
-- @string weapon The weapon entity.
-- @treturn boolean True if the crosshair should be drawn, false otherwise.
function ShouldDrawCrosshair(client, weapon)
end

--- Displays the context menu for interacting with an item entity.
-- @realm client
-- @entity entity The item entity for which the context menu is displayed.
function ItemShowEntityMenu(entity)
end

--- Determines whether bars should be hidden.
-- @realm client
-- @treturn boolean True if bars should be hidden, false otherwise.
function ShouldHideBars()
end

--- Determines whether the ammo display should be drawn for the given weapon.
-- @realm client
-- @entity weapon The weapon for which the ammo display is being considered.
-- @treturn boolean True if the ammo display should be drawn, false otherwise.
function ShouldDrawAmmo(weapon)
end

--- Draws the ammo display for the given weapon.
-- @realm client
-- @entity weapon The weapon for which the ammo display is being drawn.
function DrawAmmo(weapon)
end

--- Determines whet character information should be drawn for the given entity and character.
-- @realm client
-- @entity entity The entity associated with the character.
-- @character character The character for which information is being considered.
-- @tab charInfo Additional information about the character.
-- @treturn boolean True if character information should be drawn, false otherwise.
function ShouldDrawCharInfo(entity, character, charInfo)
end

--- Determines whether entity information should be drawn for the given entity.
-- @realm client
-- @entity entity The entity for which information is being considered.
-- @treturn boolean True if entity information should be drawn, false otherwise.
function ShouldDrawEntityInfo(entity)
end

--- Draws information about the given entity.
-- @realm client
-- @param entity The entity for which information is being drawn.
-- @param alpha The alpha value to use for drawing the entity information.
function DrawEntityInfo(entity, alpha)
end

--- Determines whether the crosshair should be drawn.
-- @realm client
-- @treturn boolean True if the crosshair should be drawn, false otherwise.
function ShouldDrawCrosshair()
end

--- Draws the crosshair.
-- @realm client
function DrawCrosshair()
end

--- Determines whether the vignette effect should be drawn.
-- @realm client
-- @treturn boolean True if the vignette effect should be drawn, false otherwise.
function ShouldDrawVignette()
end

--- Draws the vignette effect.
-- @realm client
function DrawVignette()
end

--- Determines whether a warning about a branching path should be drawn.
-- @realm client
-- @treturn boolean True if the branching path warning should be drawn, false otherwise.
function ShouldDrawBranchWarning()
end

--- Draws a warning about a branching path.
-- @realm client
function DrawBranchWarning()
end

--- Determines whether the blur effect should be drawn.
-- @realm client
-- @treturn boolean True if the blur effect should be drawn, false otherwise.
function ShouldDrawBlur()
end

--- Draws the blur effect.
-- @realm client
function DrawBlur()
end

--- Determines whether bars should be hidden.
-- @realm client
-- @treturn boolean True if bars should be hidden, false otherwise.
function ShouldHideBars()
end

--- Determines whether player information should be drawn.
-- @realm client
-- @treturn boolean True if player information should be drawn, false otherwise.
function ShouldDrawPlayerInfo()
end

--- Initializes the tooltip before it is displayed.
-- @realm client
-- @panel panel The tooltip panel.
-- @panel targetPanel The panel for which the tooltip is being displayed.
function TooltipInitialize(panel, targetPanel)
end

--- Handles the painting of the tooltip.
-- @realm client
-- @panel panel The tooltip panel.
-- @int w The width of the tooltip.
-- @int h The height of the tooltip.
function TooltipPaint(panel, w, h)
end

--- Handles the layout of the tooltip.
-- @realm client
-- @panel panel The tooltip panel.
function TooltipLayout(panel)
end

--- Adjusts the amount of blur applied to the screen.
-- @realm client
-- This function allows you to modify the blur amount before it's applied.
-- @int blurGoal The current target blur amount.
-- @treturn number The adjusted blur amount to be applied.
function AdjustBlurAmount(blurGoal)
end

--- Sets up the quick menu by adding buttons, sliders, spacers, etc.
-- This function is called during the initialization of the quick menu panel.
-- @realm client
-- @panel panel The panel representing the quick menu.
-- @realm client
function SetupQuickMenu(panel)
end

--- Called to draw additional content within the model view panel.
--- @panel panel The panel containing the model view
--- @entity entity The entity being drawn.
--- @realm client
function DrawLiliaModelView(panel, entity)
end
