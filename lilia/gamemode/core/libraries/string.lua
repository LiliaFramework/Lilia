local oStringUpper = string.upper
local oStringLower = string.lower
local oStringReverse = string.reverse
--- Various useful string-related functions.
-- @library lia.string
lia.string = lia.string or {}
--- Converts all uppercase letters in a string to lowercase, including special characters.
-- @realm shared
-- @string str The string to convert.
-- @return string The string with all letters converted to lowercase.
-- @note This function handles UTF-8 text characters.
function lia.string.lower(str)
    for lowerVersion, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(upperVersion, lowerVersion)
    end
    return oStringLower(str)
end

--- Converts all lowercase letters in a string to uppercase, including special characters.
-- @realm shared
-- @string str The string to convert.
-- @return string The string with all letters converted to uppercase.
-- @note This function handles UTF-8 text characters.
function lia.string.upper(str)
    for lowerVersion, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(lowerVersion, upperVersion)
    end
    return oStringUpper(str)
end

--- Safely quotes a string by escaping backslashes and double quotes, then wrapping the entire string in double quotes.
-- @realm shared
-- @param str string The string to quote.
-- @return string The quoted and escaped string.
-- @note This function handles UTF-8 text characters.
function lia.string.quote(str)
    local escapedStr = string.gsub(str, "\\", "\\\\")
    escapedStr = string.gsub(escapedStr, '"', '\\"')
    return '"' .. escapedStr .. '"'
end

--- Reverses the characters in a string, including special characters.
-- @realm shared
-- @string str The string to reverse.
-- @return string The reversed string.
-- @note This function handles UTF-8 text characters.
function lia.string.reverse(str)
    for lowerVersion, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(lowerVersion, upperVersion)
    end
    return oStringReverse(str)
end

--- Capitalizes the first letter of a string using the default string.upper.
-- @realm shared
-- @string str The string to capitalize.
-- @return string The string with the first letter capitalized.
-- @note This function handles UTF-8 text characters.
function string.FirstToUpper(str)
    return str:gsub("^%l", oStringUpper)
end

--- Capitalizes the first letter of a string using lia.string.upper.
-- @realm shared
-- @string str The string to capitalize.
-- @return string The string with the first letter capitalized.
-- @note This function handles UTF-8 text characters.
function lia.string.FirstToUpper(str)
    return str:gsub("^%l", lia.string.upper)
end

--- Formats a number with commas for thousands separation.
-- @realm shared
-- @int amount The number to format.
-- @return string The formatted number with commas.
function lia.string.CommaNumber(amount)
    local formatted = tostring(amount)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

--- Converts a digit to its English word representation.
-- @int digit The digit to convert.
-- @return string The word representation of the digit, or "invalid" if not a digit.
-- @realm shared
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

--- Removes non-printable ASCII characters from a string.
-- @string str The string to clean.
-- @return string The cleaned string.
-- @realm shared
function lia.string.Clean(str)
    return string.gsub(str, "[^\32-\127]", "")
end

--- Randomly introduces gibberish characters into a string based on probability.
-- @string str The string to modify.
-- @int prob The probability (1-100) of introducing gibberish.
-- @return string The modified string with possible gibberish.
-- @realm shared
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