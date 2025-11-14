if registerNetCommands then return end
local active = false
local until_ts = 0
local threshold = 4096
local want_trace = false
local targets = {
    all = true
}

local tracked_players = {}
local events = {}
local stats = {}
local total = {}
local function now()
    return SysTime()
end

local function plyKey(p)
    return IsValid(p) and (p:SteamID() or p:Nick()) or "?"
end

local function addStat(ply, name, bytes)
    local sid = plyKey(ply)
    stats[sid] = stats[sid] or {}
    local s = stats[sid][name]
    if not s then
        s = {
            count = 0,
            total = 0,
            max = 0
        }

        stats[sid][name] = s
    end

    s.count = s.count + 1
    s.total = s.total + bytes
    if bytes > s.max then s.max = bytes end
    local tt = total[sid] or {
        count = 0,
        total = 0
    }

    tt.count = tt.count + 1
    tt.total = tt.total + bytes
    total[sid] = tt
end

local function shouldTrackPly(ply)
    if not IsValid(ply) then return false end
    if targets.all then return true end
    return tracked_players[ply] == true
end

local _Start, _Send, _Broadcast = net.Start, net.Send, net.Broadcast
local cur = nil
net.Start = function(name, unreliable)
    cur = {
        name = name,
        unreliable = unreliable == true,
        t = now()
    }
    return _Start(name, unreliable)
end

local function logSend(targets_arg)
    if not active or not cur then return end
    local bytes = net.BytesWritten() or 0
    local reliable = cur.unreliable ~= true
    if until_ts > 0 and now() >= until_ts then
        active = false
        print("[NetProf] stopped (time limit)")
    end

    if not active then return end
    if bytes < threshold then return end
    local tlist = {}
    if istable(targets_arg) then
        for _, p in ipairs(targets_arg) do
            if shouldTrackPly(p) then
                tlist[#tlist + 1] = plyKey(p)
                addStat(p, cur.name, bytes)
            end
        end
    elseif IsValid(targets_arg) then
        if shouldTrackPly(targets_arg) then
            tlist[1] = plyKey(targets_arg)
            addStat(targets_arg, cur.name, bytes)
        end
    else
        for _, p in ipairs(player.GetHumans()) do
            if shouldTrackPly(p) then
                tlist[#tlist + 1] = plyKey(p)
                addStat(p, cur.name, bytes)
            end
        end
    end

    if #tlist == 0 then return end
    local ev = {
        t = now(),
        name = cur.name,
        bytes = bytes,
        reliable = reliable,
        targets = table.concat(tlist, ","),
    }

    if want_trace then ev.stack = debug.traceback("", 3) end
    events[#events + 1] = ev
    if reliable and bytes >= 16000 then print(("[NetProf][BIG] %s %dB rel→ %s"):format(cur.name, bytes, ev.targets)) end
end

net.Send = function(target)
    logSend(target)
    return _Send(target)
end

net.Broadcast = function()
    logSend(nil)
    return _Broadcast()
end

local function resolveTarget(str)
    if not str or str == "" or str == "all" then return "all" end
    local uid = tonumber(str)
    if uid then
        for _, p in ipairs(player.GetHumans()) do
            if p:UserID() == uid then return p end
        end
    end

    for _, p in ipairs(player.GetHumans()) do
        if p:SteamID() == str then return p end
    end

    for _, p in ipairs(player.GetHumans()) do
        if string.find(string.lower(p:Nick()), string.lower(str), 1, true) then return p end
    end
    return nil
end

local function resetState()
    events, stats, total = {}, {}, {}
end

concommand.Add("netprof_start", function(ply, _, args)
    if IsValid(ply) then return end
    local who = resolveTarget(args[1])
    local seconds = tonumber(args[2] or "20") or 20
    local th = tonumber(args[3] or "4096") or 4096
    local wantTr = tonumber(args[4] or "0") == 1
    resetState()
    active = true
    until_ts = seconds > 0 and (now() + seconds) or 0
    threshold = math.max(0, th)
    want_trace = wantTr
    targets.all = who == "all" or who == nil
    tracked_players = {}
    if IsValid(who) then tracked_players[who] = true end
    print(("[NetProf] START: target=%s, dur=%ss, threshold=%dB, trace=%s"):format(who == "all" and "ALL" or (IsValid(who) and plyKey(who) or "ALL"), seconds, threshold, tostring(want_trace)))
end)

concommand.Add("netprof_stop", function(ply)
    if IsValid(ply) then return end
    active = false
    until_ts = 0
    print("[NetProf] STOP")
end)

local function sortPairsByTotal(t)
    local arr = {}
    for name, s in pairs(t) do
        arr[#arr + 1] = {
            name = name,
            s = s
        }
    end

    table.sort(arr, function(a, b) return a.s.total > b.s.total end)
    return arr
end

concommand.Add("netprof_report", function(ply)
    if IsValid(ply) then return end
    print("===== NetProf Report =====")
    for sid, st in pairs(stats) do
        local tot = total[sid] or {
            count = 0,
            total = 0
        }

        print(("\n-- Player %s: msgs=%d, bytes=%.1f KB"):format(sid, tot.count, tot.total / 1024))
        local arr = sortPairsByTotal(st)
        for i = 1, math.min(#arr, 15) do
            local it = arr[i]
            print(("[%2d] %-32s  cnt=%-4d total=%7.1fKB  max=%6dB"):format(i, it.name, it.s.count, it.s.total / 1024, it.s.max))
        end
    end

    print("\nTop events >= 16KB (reliable):")
    local n = 0
    for _, ev in ipairs(events) do
        if ev.reliable and ev.bytes >= 16000 then
            print(("- %s  %dB  → %s"):format(ev.name, ev.bytes, ev.targets))
            n = n + 1
            if n >= 20 then break end
        end
    end

    print("===== End =====")
end)

local function toJSON(v)
    if util and util.TableToJSON then return util.TableToJSON(v, true) end
    return "{}"
end

concommand.Add("netprof_dump", function(ply, _, args)
    if IsValid(ply) then return end
    local fn = args[1]
    if not fn or fn == "" then fn = ("netprof_%d.json"):format(os.time()) end
    local out = {
        meta = {
            started = os.time(),
            threshold = threshold,
            trace = want_trace,
        },
        events = events,
        stats = stats,
        total = total
    }

    file.CreateDir("netprof")
    file.Write("netprof/" .. fn, toJSON(out))
    print("[NetProf] Dumped to data/netprof/" .. fn)
end)

concommand.Add("netprof_join", function(ply, _, args)
    if IsValid(ply) then return end
    local who = resolveTarget(args[1])
    local sec = tonumber(args[2] or "25") or 25
    local th = tonumber(args[3] or "2048") or 2048
    if not who or who == "all" then
        print("usage: netprof_join <userid|steamid|nick> [seconds] [threshold]")
        return
    end

    RunConsoleCommand("netprof_start", who:UserID(), sec, th, 0)
end)

registerNetCommands = true
