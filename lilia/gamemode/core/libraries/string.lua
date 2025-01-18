local oStringUpper = string.upper
local oStringLower = string.lower
local oStringReverse = string.reverse
lia.string = lia.string or {}
function lia.string.lower(str)
  for lowerVersion, upperVersion in pairs(SpecialCharacters) do
    str = str:gsub(upperVersion, lowerVersion)
  end
  return oStringLower(str)
end

function lia.string.upper(str)
  for lowerVersion, upperVersion in pairs(SpecialCharacters) do
    str = str:gsub(lowerVersion, upperVersion)
  end
  return oStringUpper(str)
end

function lia.string.generateRandom(length)
  length = length or 16
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  local randomString = {}
  for _ = 1, length do
    local rand = math.random(1, #chars)
    table.insert(randomString, chars:sub(rand, rand))
  end
  return table.concat(randomString)
end

function lia.string.quote(str)
  local escapedStr = string.gsub(str, "\\", "\\\\")
  escapedStr = string.gsub(escapedStr, '"', '\\"')
  return '"' .. escapedStr .. '"'
end

function lia.string.reverse(str)
  for lowerVersion, upperVersion in pairs(SpecialCharacters) do
    str = str:gsub(lowerVersion, upperVersion)
  end
  return oStringReverse(str)
end

function string.FirstToUpper(str)
  return str:gsub("^%l", oStringUpper)
end

function lia.string.FirstToUpper(str)
  return str:gsub("^%l", lia.string.upper)
end

function lia.string.CommaNumber(amount)
  local formatted = tostring(amount)
  while true do
    local k
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then break end
  end
  return formatted
end

function lia.string.DigitToString(digit)
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

function lia.string.Clean(str)
  return string.gsub(str, "[^\32-\127]", "")
end

function lia.string.Gibberish(str, prob)
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
