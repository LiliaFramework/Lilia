--- Hook Documentation for Salary Module.
-- @hooksmodule Salary

--- Retrieves the salary limit for a player.
--- @client client The player for whom to retrieve the salary limit.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn The salary limit for the player.
--- @realm shared
function GetSalaryLimit(client, faction, class)
end

--- Retrieves the amount of salary a player should receive.
--- @client client The player receiving the salary.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn The amount of salary the player should receive.
--- @realm shared
function GetSalaryAmount(client, faction, class)
end

--- Determines if a player is allowed to earn salary.
--- @client client The player whose eligibility for salary is being checked.
--- @tab faction The faction the player belongs to.
--- @tab class The class of the player's character.
--- @treturn True if the player is allowed to earn salary, false otherwise.
--- @realm shared
function CanPlayerEarnSalary(client, faction, class)
end

--- Creates a timer to manage player salary.
--- @client client The player for whom the salary timer is created.
--- @realm shared
function CreateSalaryTimer(client)
end