function string.generateRandom(length)
    length = length or 16
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local randomString = {}
    for _ = 1, length do
        local rand = math.random(1, #chars)
        table.insert(randomString, chars:sub(rand, rand))
    end
    return table.concat(randomString)
end

function string.quote(str)
    local escapedStr = string.gsub(str, "\\", "\\\\")
    escapedStr = string.gsub(escapedStr, '"', '\\"')
    return '"' .. escapedStr .. '"'
end

function string.FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

function string.CommaNumber(amount)
    local formatted = tostring(amount)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

function string.Clean(str)
    return string.gsub(str, "[^\32-\127]", "")
end

function string.Gibberish(str, prob)
    local ret = ""
    for _, v in pairs(string.Explode("", str)) do
        if math.random(1, 100) < prob then
            v = ""
            for _ = 1, math.random(0, 2) do
                ret = ret .. table.Random({"#", "@", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*", "*"})
            end
        end

        ret = ret .. v
    end
    return ret
end

function string.DigitToString(digit)
    local digitToString = {
        ["0"] = "zero",
        ["1"] = "one",
        ["2"] = "two",
        ["3"] = "three",
        ["4"] = "four",
        ["5"] = "five",
        ["6"] = "six",
        ["7"] = "seven",
        ["8"] = "eight",
        ["9"] = "nine"
    }
    return digitToString[tostring(digit)] or "invalid"
end

function table.Sum(tbl)
    local sum = 0
    for _, v in pairs(tbl) do
        if isnumber(v) then
            sum = sum + v
        elseif istable(v) then
            sum = sum + table.Sum(v)
        end
    end
    return sum
end

function table.Lookupify(tbl)
    local lookup = {}
    for _, v in pairs(tbl) do
        lookup[v] = true
    end
    return lookup
end

function table.MakeAssociative(tab)
    local ret = {}
    for _, v in pairs(tab) do
        ret[v] = true
    end
    return ret
end

function table.Unique(tab)
    return table.GetKeys(table.MakeAssociative(tab))
end

function table.FullCopy(tab)
    local res = {}
    for k, v in pairs(tab) do
        if istable(v) then
            res[k] = table.FullCopy(v)
        elseif isvector(v) then
            res[k] = Vector(v.x, v.y, v.z)
        elseif isangle(v) then
            res[k] = Angle(v.p, v.y, v.r)
        else
            res[k] = v
        end
    end
    return res
end

function table.Filter(tab, func)
    local c = 1
    for i = 1, #tab do
        if func(tab[i]) then
            tab[c] = tab[i]
            c = c + 1
        end
    end

    for i = c, #tab do
        tab[i] = nil
    end
    return tab
end

function table.FilterCopy(tab, func)
    local ret = {}
    for i = 1, #tab do
        if func(tab[i]) then ret[#ret + 1] = tab[i] end
    end
    return ret
end

function math.UnitsToInches(units)
    return units * 0.75
end

function math.UnitsToCentimeters(units)
    return math.UnitsToInches(units) * 2.54
end

function math.UnitsToMeters(units)
    return math.UnitsToInches(units) * 0.0254
end

function math.chance(chance)
    local rand = math.random(0, 100)
    if rand <= chance then return true end
    return false
end

function math.Bias(x, amount)
    local exp = 0
    if amount ~= -1 then exp = math.log(amount) * -1.4427 end
    return math.pow(x, exp)
end

function math.Gain(x, amount)
    if x < 0.5 then
        return 0.5 * math.Bias(2 * x, 1 - amount)
    else
        return 1 - 0.5 * math.Bias(2 - 2 * x, 1 - amount)
    end
end

function math.ApproachSpeed(start, dest, speed)
    return math.Approach(start, dest, math.abs(start - dest) / speed)
end

function math.ApproachVectorSpeed(start, dest, speed)
    return Vector(math.ApproachSpeed(start.x, dest.x, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.z, dest.z, speed))
end

function math.ApproachAngleSpeed(start, dest, speed)
    return Angle(math.ApproachSpeed(start.p, dest.p, speed), math.ApproachSpeed(start.y, dest.y, speed), math.ApproachSpeed(start.r, dest.r, speed))
end

function math.InRange(val, min, max)
    return val >= min and val <= max
end

function math.ClampAngle(val, min, max)
    return Angle(math.Clamp(val.p, min.p, max.p), math.Clamp(val.y, min.y, max.y), math.Clamp(val.r, min.r, max.r))
end

function math.ClampedRemap(val, frommin, frommax, tomin, tomax)
    return math.Clamp(math.Remap(val, frommin, frommax, tomin, tomax), math.min(tomin, tomax), math.max(tomin, tomax))
end

if SERVER then
    function ClientAddText(client, ...)
        if not client or not IsValid(client) then
            print("Invalid client provided to chat.AddText")
            return
        end

        local args = {...}
        net.Start("ServerChatAddText")
        net.WriteTable(args)
        net.Send(client)
    end
end
