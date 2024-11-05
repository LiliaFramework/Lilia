--- Various useful table related functions.
-- @library lia.table
lia.table = lia.table or {}
--- Sums all numerical values in a table.
-- @realm shared
-- @tab tbl The table containing numerical values to sum
-- @return number The sum of all numerical values
function lia.table.Sum(tbl)
    local sum = 0
    for _, v in pairs(tbl) do
        if isnumber(v) then
            sum = sum + v
        elseif istable(v) then
            sum = sum + lia.table.Sum(v)
        end
    end
    return sum
end

--- Creates a lookup table from a list of values.
-- @realm shared
-- @tab tbl The list of values to create a lookup table from
-- @return table A lookup table where the keys are the values from the input list
function lia.table.Lookupify(tbl)
    local lookup = {}
    for _, v in pairs(tbl) do
        lookup[v] = true
    end
    return lookup
end

--- Converts a table into an associative table where the original values are keys.
-- @tab tab The table to convert.
-- @return table The associative table.
-- @realm shared
function lia.table.MakeAssociative(tab)
    local ret = {}
    for _, v in pairs(tab) do
        ret[v] = true
    end
    return ret
end

--- Returns a table of unique values from the input table.
-- @tab tab The table to process.
-- @return table The table of unique values.
-- @realm shared
function lia.table.Unique(tab)
    return table.GetKeys(table.MakeAssociative(tab))
end

--- Creates a deep copy of a table.
-- @tab tab table The table to copy.
-- @return table A deep copy of the table.
-- @realm shared
function lia.table.FullCopy(tab)
    local res = {}
    for k, v in pairs(tab) do
        if istable(v) then
            res[k] = lia.table.FullCopy(v)
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

--- Filters a table in-place based on a callback function.
-- Modifies the original table by removing elements for which the callback returns false.
-- @tab tab The table to filter in-place.
-- @func func The function to call for each element; if it returns true, the element is kept.
-- @return table The modified (filtered) table.
-- @realm shared
function lia.table.Filter(tab, func)
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

--- Creates a copy of the table with elements that pass the callback function.
-- Does not modify the original table; returns a new table containing only elements for which the callback returns true.
-- @tab tab The table to filter.
-- @func func The function to call for each element; if it returns true, the element is added to the result.
-- @return table A new table containing the filtered elements.
-- @realm shared
function lia.table.FilterCopy(tab, func)
    local ret = {}
    for i = 1, #tab do
        if func(tab[i]) then ret[#ret + 1] = tab[i] end
    end
    return ret
end

table.Sum = lia.table.Sum
table.Unique = lia.table.Unique
table.Filter = lia.table.Filter
table.FullCopy = lia.table.FullCopy
table.Lookupify = lia.table.Lookupify
table.FilterCopy = lia.table.FilterCopy
table.MakeAssociative = lia.table.MakeAssociative