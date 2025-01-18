lia.math = lia.math or {}
function lia.math.UnitsToInches(units)
  return units * 0.75
end

function lia.math.UnitsToCentimeters(units)
  return math.UnitsToInches(units) * 2.54
end

function lia.math.UnitsToMeters(units)
  return math.UnitsToInches(units) * 0.0254
end

function lia.math.chance(chance)
  local rand = math.random(0, 100)
  if rand <= chance then return true end
  return false
end

function lia.math.Bias(x, amount)
  local exp = 0
  if amount ~= -1 then exp = math.log(amount) * -1.4427 end
  return math.pow(x, exp)
end

function lia.math.Gain(x, amount)
  if x < 0.5 then
    return 0.5 * math.Bias(2 * x, 1 - amount)
  else
    return 1 - 0.5 * math.Bias(2 - 2 * x, 1 - amount)
  end
end

function lia.math.ApproachSpeed(start, dest, speed)
  return math.Approach(start, dest, math.abs(start - dest) / speed)
end

function lia.math.ApproachVectorSpeed(start, dest, speed)
  return Vector(math.ApproachSpeed(start.x, dest.x, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.z, dest.z, speed))
end

function lia.math.ApproachAngleSpeed(start, dest, speed)
  return Angle(math.ApproachSpeed(start.p, dest.p, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.r, dest.r, speed))
end

function lia.math.InRange(val, min, max)
  return val >= min and val <= max
end

function lia.math.ClampAngle(val, min, max)
  return Angle(math.Clamp(val.p, min.p, max.p), math.Clamp(val.y, min.y, max.y), math.Clamp(val.r, min.r, max.r))
end

function lia.math.ClampedRemap(val, frommin, frommax, tomin, tomax)
  return math.Clamp(math.Remap(val, frommin, frommax, tomin, tomax), math.min(tomin, tomax), math.max(tomin, tomax))
end
