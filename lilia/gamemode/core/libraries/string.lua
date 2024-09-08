local oStringUpper = string.upper
--- Various useful string-related functions.
-- @library lia.string
local SpecialCharacters = {
    ["ä"] = "Ä",
    ["ö"] = "Ö",
    ["ü"] = "Ü",
    ["ë"] = "Ë",
    ["ï"] = "Ï",
    ["â"] = "Â",
    ["ê"] = "Ê",
    ["î"] = "Î",
    ["ô"] = "Ô",
    ["û"] = "Û",
    ["à"] = "À",
    ["è"] = "È",
    ["ù"] = "Ù",
    ["ç"] = "Ç",
    ["é"] = "É",
    ["œ"] = "Œ",
    ["æ"] = "Æ"
}

--- Converts all lowercase letters in a string to uppercase, including special characters.
-- @realm shared
-- @string str The string to convert.
-- @return string The string with all letters converted to uppercase.
function lia.string.upper(str)
    for letter, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(letter, upperVersion)
    end
    return oStringUpper(str)
end

--- Capitalizes the first letter of a string.
-- @realm shared
-- @string str The string to capitalize.
-- @return string The string with the first letter capitalized.
function lia.string.FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

--- Formats a number with commas for thousands separation.
-- @realm shared
-- @number amount The number to format.
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