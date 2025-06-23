do
    local getmetatable = getmetatable
    do
        local meta = debug.getmetatable("")
        function isstring(val)
            return val and getmetatable(val) == meta
        end
    end

    do
        local _type = 0
        local meta = debug.getmetatable(_type)
        if not meta then
            meta = {
                MetaName = "number",
                MetaID = TypeID(_type)
            }

            debug.setmetatable(_type, meta)
        end

        function isnumber(val)
            return val and getmetatable(val) == meta
        end
    end

    do
        local _type = function() end
        local meta = debug.getmetatable(_type)
        if not meta then
            meta = {
                MetaName = "function",
                MetaID = TypeID(_type)
            }

            debug.setmetatable(_type, meta)
        end

        function isfunction(val)
            return val and getmetatable(val) == meta
        end
    end

    do
        local _type = true
        local meta = debug.getmetatable(_type)
        if not meta then
            meta = {
                MetaName = "boolean",
                MetaID = TypeID(_type)
            }

            debug.setmetatable(_type, meta)
        end

        function isbool(val)
            return val and getmetatable(val) == meta
        end
    end

    do
        local _type = coroutine.create(function() end)
        local meta = debug.getmetatable(_type)
        if not meta then
            meta = {
                MetaName = "thread",
                MetaID = TypeID(_type)
            }

            debug.setmetatable(_type, meta)
        end

        function iscoroutine(val)
            return val and getmetatable(val) == meta
        end
    end

    for k, v in pairs({
        ["Vector"] = "vector",
        ["Angle"] = "angle",
        ["VMatrix"] = "matrix",
        ["Panel"] = "panel"
    }) do
        local meta = FindMetaTable(k)
        _G["is" .. v] = function(val) return val and getmetatable(val) == meta end
    end
end

do
    setmetatable(FindMetaTable("Weapon"), {
        __index = FindMetaTable("Entity")
    })

    setmetatable(FindMetaTable("NPC"), {
        __index = FindMetaTable("Entity")
    })

    setmetatable(FindMetaTable("Vehicle"), {
        __index = FindMetaTable("Entity")
    })

    if isfunction(Entity) then
        local EntityFunction = Entity
        Entity = FindMetaTable("Entity")
        setmetatable(Entity, {
            __call = function(_, x) return EntityFunction(x) end
        })
    end

    if isfunction(Player) then
        local PlayerFunction = Player
        Player = FindMetaTable("Player")
        setmetatable(Player, {
            __call = function(_, x) return PlayerFunction(x) end
        })
    end

    local ENT = Entity
    do
        CEntityGetTable = CEntityGetTable or ENT.GetTable
        local cgettable, rawset = CEntityGetTable, rawset
        EntityTable = setmetatable({}, {
            __mode = "k",
            __index = function(self, ent)
                local tab = cgettable(ent)
                rawset(self, ent, tab)
                return tab
            end
        })
    end

    local GetTable, simple = EntityTable, timer.Simple
    hook.Add("EntityRemoved", "CleanupEntityTableCache", function(ent) simple(0, function() GetTable[ent] = nil end) end)
    function ENT:GetTable()
        return GetTable[self]
    end

    do
        local rawequal = rawequal
        function ENT.__eq(a, b)
            return rawequal(a, b)
        end
    end

    local dt = {}
    do
        local PLY = Player
        function PLY:__index(key)
            local val = PLY[key]
            if val ~= nil then return val end
            val = ENT[key]
            if val ~= nil then return val end
            return (GetTable[self] or dt)[key]
        end
    end

    local GetOwner = ENT.GetOwner
    local ownerkey = "Owner"
    function ENT:__index(key)
        if key == ownerkey then return GetOwner(self) end
        local val = ENT[key]
        if val ~= nil then return val end
        return (GetTable[self] or dt)[key]
    end

    do
        local WEP = FindMetaTable("Weapon")
        function WEP:__index(key)
            if key == ownerkey then return GetOwner(self) end
            local val = WEP[key]
            if val ~= nil then return val end
            val = ENT[key]
            if val ~= nil then return val end
            return (GetTable[self] or dt)[key]
        end
    end

    do
        local VEH = FindMetaTable("Vehicle")
        function VEH:__index(key)
            if key == ownerkey then return GetOwner(self) end
            local val = VEH[key]
            if val ~= nil then return val end
            val = ENT[key]
            if val ~= nil then return val end
            return (GetTable[self] or dt)[key]
        end
    end
end
