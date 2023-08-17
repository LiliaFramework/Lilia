lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--------------------------------------------------------------------------------------------------------
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(4, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}

        if MODULE then
            ATTRIBUTE.module = MODULE.uniqueID
        end

        lia.util.include(directory .. "/" .. v)
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end
--------------------------------------------------------------------------------------------------------
function lia.attribs.setup(client)
    local character = client:getChar()

    if character then
        for k, v in pairs(lia.attribs.list) do
            if v.onSetup then
                v:onSetup(client, character:getAttrib(k, 0))
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------
lia.char.registerVar("attribs", {
    field = "_attribs",
    default = {},
    isLocal = true,
    index = 4,
    onValidate = function(value, data, client)
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
    shouldDisplay = function(panel)
        return table.Count(lia.attribs.list) > 0
    end
})
--------------------------------------------------------------------------------------------------------