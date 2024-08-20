--- Helper library for generating bars.
-- @class string

local oStringUpper = string.upper
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

--- Checks if a given value is a SteamID.
-- @string value The value to check
-- @treturn bool True if the value is a SteamID, false otherwise
-- @realm shared
function string.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end
    return false
end

--- Converts special characters in a string to their uppercase equivalents.
-- This function iterates through a table of special characters, converting each one to its uppercase form.
-- @realm shared
-- @string str The string to convert to uppercase.
-- @treturn string The string with special characters converted to uppercase.
function string.upper(str)
    for letter, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(letter, upperVersion)
    end
    return oStringUpper(str)
end

--- Capitalizes the first letter of a string.
-- Converts the first letter of a string to its uppercase equivalent, leaving the rest of the string unchanged.
-- @realm shared
-- @string str The string to capitalize.
-- @treturn string The string with the first letter capitalized.
-- @usage print(string.FirstToUpper("hello world"))
-- > Hello world
function string.FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

--- Removes the realm prefix from a file name.
-- This function strips the "sh_", "sv_", or "cl_" prefix from the beginning of a string.
-- If the string doesn't have one of these prefixes, it returns the string unchanged.
-- @realm shared
-- @string name The file name to strip the prefix from.
-- @treturn string The file name with the realm prefix removed, if it was present.
-- @usage print(string.stripRealmPrefix("sv_init.lua"))
-- > init.lua
function string.stripRealmPrefix(name)
    local prefix = name:sub(1, 3)
    return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
end

--- Formats a number with commas for thousands separation.
-- This function adds commas to a number string for easier readability, separating every three digits from the right.
-- @realm client
-- @number amount The number to format with commas.
-- @treturn string The number formatted with commas as thousands separators.
-- @usage print(string.CommaNumber(123456789))
-- > 123,456,789
function string.CommaNumber(amount)
    local formatted = amount
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

-- Returns a string that has the named arguments in the format string replaced with the given arguments.
-- @realm shared
-- @string format Format string
-- @tparam tab|... Arguments to pass to the formatted string. If passed a table, it will use that table as the lookup table for
-- the named arguments. If passed multiple arguments, it will replace the arguments in the string in order.
-- @usage print(lia.util.formatStringNamed("Hi, my name is {name}.", {name = "Bobby"}))
-- > Hi, my name is Bobby.
-- @usage print(lia.util.formatStringNamed("Hi, my name is {name}.", "Bobby"))
-- > Hi, my name is Bobby.
function string.formatStringNamed(format, ...)
    local arguments = {...}
    local bArray = false
    local input
    if istable(arguments[1]) then
        input = arguments[1]
    else
        input = arguments
        bArray = true
    end

    local i = 0
    local result = format:gsub("{(%w-)}", function(word)
        i = i + 1
        return tostring((bArray and input[i] or input[word]) or word)
    end)
    return result
end
