lia.net = lia.net or {}
lia.net._sendq = lia.net._sendq or {}
lia.net.globals = lia.net.globals or {}
lia.net._buffers = lia.net._buffers or {}
function lia.net.readBigTable(netStr, callback)
    lia.net._buffers[netStr] = lia.net._buffers[netStr] or {}
    net.Receive(netStr, function(_, ply)
        local sid = net.ReadUInt(32)
        local total = net.ReadUInt(16)
        local idx = net.ReadUInt(16)
        local clen = net.ReadUInt(16)
        local chunk = net.ReadData(clen)
        local buffers = lia.net._buffers[netStr]
        local state = buffers[sid]
        if not state then
            state = {
                total = total,
                count = 0,
                parts = {}
            }

            buffers[sid] = state
        end

        if not state.parts[idx] then
            state.parts[idx] = chunk
            state.count = state.count + 1
        end

        if CLIENT then
            net.Start("LIA_BigTable_Ack")
            net.WriteUInt(sid, 32)
            net.WriteUInt(idx, 16)
            net.SendToServer()
        end

        if state.count == state.total then
            buffers[sid] = nil
            local full = table.concat(state.parts, "", 1, total)
            local decomp = util.Decompress(full)
            local tbl = decomp and util.JSONToTable(decomp) or nil
            if SERVER then
                if callback then callback(ply, tbl) end
            else
                if callback then callback(tbl) end
            end
        end
    end)
end

if SERVER then
    local chunkTime = 0.05
    local function sendChunk(ply, s, sid, idx)
        if not IsValid(ply) then
            if lia.net._sendq[ply] then lia.net._sendq[ply][sid] = nil end
            return
        end

        local part = s.chunks[idx]
        if not part then
            if lia.net._sendq[ply] then lia.net._sendq[ply][sid] = nil end
            return
        end

        s.idx = idx
        net.Start(s.netStr)
        net.WriteUInt(sid, 32)
        net.WriteUInt(s.total, 16)
        net.WriteUInt(idx, 16)
        net.WriteUInt(#part, 16)
        net.WriteData(part, #part)
        net.Send(ply)
        if idx == s.total and lia.net._sendq[ply] then lia.net._sendq[ply][sid] = nil end
    end

    net.Receive("LIA_BigTable_Ack", function(_, ply)
        if not IsValid(ply) then return end
        local sid = net.ReadUInt(32)
        local last = net.ReadUInt(16)
        local q = lia.net._sendq[ply]
        if not q then return end
        local s = q[sid]
        if not s then return end
        if last ~= s.idx then return end
        if s.idx >= s.total then
            q[sid] = nil
            return
        end

        timer.Simple(chunkTime, function()
            if not IsValid(ply) then return end
            local qq = lia.net._sendq[ply]
            if not qq then return end
            local ss = qq[sid]
            if not ss then return end
            sendChunk(ply, ss, sid, ss.idx + 1)
        end)
    end)

    local function beginStream(ply, netStr, chunks, sid)
        lia.net._sendq[ply] = lia.net._sendq[ply] or {}
        local s = {
            netStr = netStr,
            chunks = chunks,
            total = #chunks,
            idx = 0
        }

        lia.net._sendq[ply][sid] = s
        timer.Simple(chunkTime, function()
            if not IsValid(ply) then return end
            local q = lia.net._sendq[ply]
            if not q then return end
            local ss = q[sid]
            if not ss then return end
            sendChunk(ply, ss, sid, 1)
        end)
    end

    function lia.net.writeBigTable(targets, netStr, tbl, chunkSize)
        if not istable(tbl) then return end
        local json = util.TableToJSON(tbl)
        if not json then return end
        local data = util.Compress(json)
        if not data or #data == 0 then return end
        local size = math.max(256, math.min(4096, chunkSize or 2048))
        local chunks = {}
        local pos = 1
        while pos <= #data do
            local part = string.sub(data, pos, pos + size - 1)
            chunks[#chunks + 1] = part
            pos = pos + size
        end

        local sid = (tonumber(util.CRC(tostring(SysTime()) .. json)) or 0) % 4294967296
        local delay = 0
        local function schedule(ply)
            if not IsValid(ply) then return end
            timer.Simple(delay, function() if IsValid(ply) then beginStream(ply, netStr, chunks, sid) end end)
            delay = delay + chunkTime
        end

        if istable(targets) then
            for i = #targets, 1, -1 do
                schedule(targets[i])
            end
        elseif IsValid(targets) then
            schedule(targets)
        else
            for _, ply in ipairs(player.GetHumans()) do
                schedule(ply)
            end
        end
    end
end

if SERVER then
    function checkBadType(name, object)
        if isfunction(object) then
            lia.error(L("netVarBadType", name))
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if checkBadType(name, k) or checkBadType(name, v) then return true end
            end
        end
    end

    function setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        local oldValue = getNetVar(key)
        if oldValue == value then return end
        lia.net.globals[key] = value
        net.Start("gVar")
        net.WriteString(key)
        net.WriteType(value)
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end

        hook.Run("NetVarChanged", nil, key, oldValue, value)
    end

    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
    hook.Add("CharDeleted", "liaNetworkingCharDeleted", function(client, character)
        lia.char.names[character:getID()] = nil
        net.Start("liaCharFetchNames")
        net.WriteTable(lia.char.names)
        net.Send(client)
    end)

    hook.Add("OnCharCreated", "liaNetworkingCharCreated", function(client, character, data)
        lia.char.names[character:getID()] = data.name
        net.Start("liaCharFetchNames")
        net.WriteTable(lia.char.names)
        net.Send(client)
    end)
else
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    FindMetaTable("Player").getLocalVar = FindMetaTable("Entity").getNetVar
end