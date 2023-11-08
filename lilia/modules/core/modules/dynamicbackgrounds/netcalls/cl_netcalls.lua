--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
netstream.Hook(
    "mapScn",
    function(data, origin)
        if type(origin) == "Vector" then
            MODULE.scenes[origin] = data
            table.insert(MODULE.ordered, {origin, data})
        else
            MODULE.scenes[#MODULE.scenes + 1] = data
        end
    end
)

--------------------------------------------------------------------------------------------------------------------------
netstream.Hook(
    "mapScnDel",
    function(key)
        MODULE.scenes[key] = nil
        for k, v in ipairs(MODULE.ordered) do
            if v[1] == key then
                table.remove(MODULE.ordered, k)
                break
            end
        end
    end
)

--------------------------------------------------------------------------------------------------------------------------
netstream.Hook(
    "mapScnInit",
    function(scenes)
        MODULE.scenes = scenes
        for k, v in pairs(scenes) do
            if type(k) == "Vector" then table.insert(MODULE.ordered, {k, v}) end
        end
    end
)
--------------------------------------------------------------------------------------------------------------------------
