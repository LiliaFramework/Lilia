netstream.Hook("cfgSet", function(client, key, name, value)
    if type(lia.config.stored[key].default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
        print(client, key, name, value)
        local oldValue = lia.config.stored[key].value
        lia.config.set(key, value)
        if istable(value) then
            local value2 = "["
            local count = table.Count(value)
            local i = 1
            for _, v in SortedPairs(value) do
                value2 = value2 .. v .. (i == count and "]" or ", ")
                i = i + 1
            end

            value = value2
        end

        lia.util.notifyLocalized("cfgSet", nil, client:Name(), name, tostring(value))
        lia.log.add(client, "configChange", name, tostring(oldValue), tostring(value))
    end
end)

lia.log.addType("configChange", {
    func = function(name, oldValue, value) return string.format("Changed config '%s' from '%s' to '%s'.", name, tostring(oldValue), tostring(value)) end,
    category = "Admin Actions",
    color = Color(0, 128, 255)
})
