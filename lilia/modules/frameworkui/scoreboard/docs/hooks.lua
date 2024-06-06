--- Hook Documentation for Scoreboard Module.
-- @ahooks Scoreboard

--- Determines whether a player should be shown on the scoreboard.
--- @realm client
--- @client client The player entity to be evaluated.
--- @treturn bool True if the player should be shown on the scoreboard, false otherwise.
function ShouldShowPlayerOnScoreboard(client)
end

--- Provides options for the player context menu on the scoreboard.
-- @realm client
-- @client client The player entity for whom the options are being provided.
-- @tab options A table to which new options can be added. Each option should be a table with the format {icon, callback}.
function ShowPlayerOptions(client, options)
end

--- Determines whether a scoreboard value should be overridden.
-- @realm client
-- @client client The player entity being checked.
-- @string var The variable being checked for override (e.g., "name" or "desc").
-- @treturn boolean True if the variable should be overridden, false otherwise.
function ShouldAllowScoreboardOverride(client, var)
end
