﻿local oStringUpper = string.upper
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