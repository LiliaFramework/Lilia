---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.attribs = lia.attribs or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.attribs.list = lia.attribs.list or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.util.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.char.registerVar("attribs", {
    field = "_attribs",
    default = {},
    isLocal = true,
    index = 4,
    onValidate = function(value, _, client)
        if value ~= nil then
            if istable(value) then
                local count = 0
                for k, v in pairs(value) do
                    local max = lia.attribs.list[k] and lia.attribs.list[k].startingMax or nil
                    if max and max < v then return false, lia.attribs.list[k].name .. " too high" end
                    count = count + v
                end

                local points = hook.Run("GetStartAttribPoints", client, count) or lia.config.MaxAttributes
                if count > points then return false, "unknownError" end
            else
                return false, "unknownError"
            end
        end
    end,
    shouldDisplay = function(_) return table.Count(lia.attribs.list) > 0 end
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
