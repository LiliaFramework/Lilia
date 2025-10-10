local function utf8charbytes(s, i)
    i = i or 1
    if not isstring(s) then error(L("utf8CharbytesStringExpected", type(s))) end
    if not isnumber(i) then error(L("utf8CharbytesNumberExpected", type(i))) end
    local c = s:byte(i)
    if c > 0 and c <= 127 then
        return 1
    elseif c >= 194 and c <= 223 then
        local c2 = s:byte(i + 1)
        if not c2 then error(L("utf8StringTerminatedEarly")) end
        if c2 < 128 or c2 > 191 then error(L("utf8InvalidCharacter")) end
        return 2
    elseif c >= 224 and c <= 239 then
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        if not c2 or not c3 then error(L("utf8StringTerminatedEarly")) end
        if c == 224 and (c2 < 160 or c2 > 191) then
            error(L("utf8InvalidCharacter"))
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error(L("utf8InvalidCharacter"))
        elseif c2 < 128 or c2 > 191 then
            error(L("utf8InvalidCharacter"))
        end
        if c3 < 128 or c3 > 191 then error(L("utf8InvalidCharacter")) end
        return 3
    elseif c >= 240 and c <= 244 then
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)
        if not c2 or not c3 or not c4 then error(L("utf8StringTerminatedEarly")) end
        if c == 240 and (c2 < 144 or c2 > 191) then
            error(L("utf8InvalidCharacter"))
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error(L("utf8InvalidCharacter"))
        elseif c2 < 128 or c2 > 191 then
            error(L("utf8InvalidCharacter"))
        end
        if c3 < 128 or c3 > 191 then error(L("utf8InvalidCharacter")) end
        if c4 < 128 or c4 > 191 then error(L("utf8InvalidCharacter")) end
        return 4
    else
        error(L("utf8InvalidCharacter"))
    end
end
local function utf8len(s)
    if not isstring(s) then error(L("utf8LenStringExpected", type(s))) end
    local pos = 1
    local bytes = s:len()
    local len = 0
    while pos <= bytes do
        len = len + 1
        pos = pos + utf8charbytes(s, pos)
    end
    return len
end
if not string.utf8bytes then string.utf8bytes = utf8charbytes end
if not string.utf8len then string.utf8len = utf8len end
local function utf8sub(s, i, j)
    j = j or -1
    if not isstring(s) then error(L("utf8SubStringExpected", type(s))) end
    if not isnumber(i) then error(L("utf8SubNumber1Expected", type(i))) end
    if not isnumber(j) then error(L("utf8SubNumber2Expected", type(j))) end
    local pos = 1
    local bytes = s:len()
    local len = 0
    local l = i >= 0 and j >= 0 or s:utf8len()
    local startChar = i >= 0 and i or l + i + 1
    local endChar = j >= 0 and j or l + j + 1
    if startChar > endChar then return "" end
    local startByte, endByte = 1, bytes
    while pos <= bytes do
        len = len + 1
        if len == startChar then startByte = pos end
        pos = pos + utf8charbytes(s, pos)
        if len == endChar then
            endByte = pos - 1
            break
        end
    end
    return s:sub(startByte, endByte)
end
if not string.utf8sub then string.utf8sub = utf8sub end
local function utf8replace(s, mapping)
    if not isstring(s) then error(L("utf8ReplaceStringExpected", type(s))) end
    if not istable(mapping) then error(L("utf8ReplaceTableExpected", type(mapping))) end
    local pos = 1
    local bytes = s:len()
    local charbytes
    local newstr = ""
    while pos <= bytes do
        charbytes = utf8charbytes(s, pos)
        local c = s:sub(pos, pos + charbytes - 1)
        newstr = newstr .. (mapping[c] or c)
        pos = pos + charbytes
    end
    return newstr
end
local function utf8upper(s)
    return utf8replace(s, utf8_lc_uc)
end
if not string.utf8upper and utf8_lc_uc then string.utf8upper = utf8upper end
local function utf8lower(s)
    return utf8replace(s, utf8_uc_lc)
end
if not string.utf8lower and utf8_uc_lc then string.utf8lower = utf8lower end
local function utf8reverse(s)
    if not isstring(s) then error(L("utf8ReverseStringExpected", type(s))) end
    local bytes = s:len()
    local pos = bytes
    local charbytes
    local newstr = ""
    local c
    while pos > 0 do
        c = s:byte(pos)
        while c >= 128 and c <= 191 do
            pos = pos - 1
            c = s:byte(pos)
        end
        charbytes = utf8charbytes(s, pos)
        newstr = newstr .. s:sub(pos, pos + charbytes - 1)
        pos = pos - 1
    end
    return newstr
end
if not string.utf8reverse then string.utf8reverse = utf8reverse end