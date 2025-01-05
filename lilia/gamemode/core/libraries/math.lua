--- Various useful mathematical functions.
-- @library lia.math
lia.math = lia.math or {}
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

--- Applies a bias to a value based on an amount.
-- @int x The value to bias.
-- @int amount The bias amount.
-- @return The biased value.
-- @realm shared
function lia.math.Bias(x, amount)
    local exp = 0
    if amount ~= -1 then exp = math.log(amount) * -1.4427 end
    return math.pow(x, exp)
end

--- Applies a gain to a value based on an amount.
-- @int x The value to apply gain to.
-- @int amount The gain amount.
-- @return The value with applied gain.
-- @realm shared
function lia.math.Gain(x, amount)
    if x < 0.5 then
        return 0.5 * math.Bias(2 * x, 1 - amount)
    else
        return 1 - 0.5 * math.Bias(2 - 2 * x, 1 - amount)
    end
end

--- Approaches a value towards a target value at a specified speed.
-- @angle start The starting value.
-- @angle dest The target value.
-- @int speed The speed at which to approach the target.
-- @return The approached value.
-- @realm shared
function lia.math.ApproachSpeed(start, dest, speed)
    return math.Approach(start, dest, math.abs(start - dest) / speed)
end

--- Approaches a vector towards a target vector at a specified speed.
-- @angle start Vector The starting vector.
-- @angle dest Vector The target vector.
-- @int speed The speed at which to approach the target.
-- @return Vector The approached vector.
-- @realm shared
function lia.math.ApproachVectorSpeed(start, dest, speed)
    return Vector(math.ApproachSpeed(start.x, dest.x, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.z, dest.z, speed))
end

--- Approaches an angle towards a target angle at a specified speed.
-- @angle start The starting angle.
-- @angle dest The target angle.
-- @int speed The speed at which to approach the target.
-- @return Angle The approached angle.
-- @realm shared
function lia.math.ApproachAngleSpeed(start, dest, speed)
    return Angle(math.ApproachSpeed(start.p, dest.p, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.r, dest.r, speed))
end

--- Checks if a value is within a specified range.
-- @int val The value to check.
-- @int min The minimum value of the range.
-- @int max The maximum value of the range.
-- @return boolean True if the value is within the range, false otherwise.
-- @realm shared
function lia.math.InRange(val, min, max)
    return val >= min and val <= max
end

--- Clamps an angle to a specified range.
-- @int val The angle to clamp.
-- @int min The minimum angle of the range.
-- @int max The maximum angle of the range.
-- @return Angle The clamped angle.
-- @realm shared
function lia.math.ClampAngle(val, min, max)
    return Angle(math.Clamp(val.p, min.p, max.p), math.Clamp(val.y, min.y, max.y), math.Clamp(val.r, min.r, max.r))
end

--- Remaps a value from one range to another and clamps it.
-- @int val The value to remap.
-- @int frommin The minimum value of the original range.
-- @int frommax The maximum value of the original range.
-- @int tomin The minimum value of the target range.
-- @int tomax The maximum value of the target range.
-- @return The remapped and clamped value.
-- @realm shared
function lia.math.ClampedRemap(val, frommin, frommax, tomin, tomax)
    return math.Clamp(math.Remap(val, frommin, frommax, tomin, tomax), math.min(tomin, tomax), math.max(tomin, tomax))
end
