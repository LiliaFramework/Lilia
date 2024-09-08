--- Various useful mathematical functions.
-- @library lia.math

--- Converts units to inches.
-- @realm shared
-- @number units The units to convert
-- @return number The equivalent measurement in inches
function lia.math.UnitsToInches(units)
    return units * 0.75
end

--- Converts units to centimeters.
-- @realm shared
-- @number units The units to convert
-- @return number The equivalent measurement in centimeters
function lia.math.UnitsToCentimeters(units)
    return math.UnitsToInches(units) * 2.54
end

--- Converts units to meters.
-- @realm shared
-- @number units The units to convert
-- @return number The equivalent measurement in meters
function lia.math.UnitsToMeters(units)
    return math.UnitsToInches(units) * 0.0254
end

--- Rolls a chance based on a given probability.
-- @int chance The probability of success in percentage
-- @treturn bool True if the chance is successful, false otherwise
-- @realm shared
function lia.math.chance(chance)
    local rand = math.random(0, 100)
    if rand <= chance then return true end
    return false
end