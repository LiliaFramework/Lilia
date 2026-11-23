lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queryQueue or lia.db.queue or {}
lia.db.queue = lia.db.queryQueue
lia.db.prepared = lia.db.prepared or {}
lia.db.modules = lia.db.modules or {}
lia.db.connected = lia.db.connected or false
lia.db.tablesLoaded = lia.db.tablesLoaded or false
lia.db.tablesLoading = lia.db.tablesLoading or false
local conditionMarker = {}
local groupMarker = {}
local orderMarker = {}
local tableWaitID = 0
local allowedOperators = {
    ["="] = "=",
    ["!="] = "<>",
    ["<>"] = "<>",
    [">"] = ">",
    ["<"] = "<",
    [">="] = ">=",
    ["<="] = "<=",
    ["LIKE"] = "LIKE",
    ["NOT LIKE"] = "NOT LIKE",
    ["IN"] = "IN",
    ["NOT IN"] = "NOT IN",
    ["IS NULL"] = "IS NULL",
    ["IS NOT NULL"] = "IS NOT NULL"
}

local function devLog(...)
    if not lia.DevMode then return end
    local parts = {...}
    for i = 1, #parts do
        parts[i] = tostring(parts[i])
    end

    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 200, 0), "[DevMode] ", Color(255, 255, 255), table.concat(parts, " "), "\n")
end

local function databaseLogError(message)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), " " .. tostring(message) .. "\n")
end

local function safeCallback(context, callback, ...)
    if not isfunction(callback) then return true end
    local args = {...}
    local ok, err = xpcall(function() callback(unpack(args)) end, debug.traceback)
    if not ok then
        databaseLogError(context .. " callback failed: " .. tostring(err))
        return false
    end
    return true
end

local function statementType(query)
    if not isstring(query) then return "" end
    return string.upper(query:match("^%s*([%a]+)") or "")
end

local function isInsertStatement(query)
    local kind = statementType(query)
    return kind == "INSERT" or kind == "REPLACE"
end

local function normalizeQueryCallbacks(callback, errorCallback)
    if isfunction(callback) then return callback, errorCallback end
    local d = deferred.new()
    return function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end, d
end

local function dispatchQueryError(errorCallback, backend, query, err)
    local message = string.format("%s query failed: %s | Query: %s", backend, tostring(err), tostring(query))
    databaseLogError(message)
    if isfunction(errorCallback) then safeCallback(backend .. " error", errorCallback, err) end
end

local sqliteModule = lia.db.modules.sqlite or {}
function sqliteModule.escape(value)
    return sql.SQLStr(tostring(value), true)
end

function sqliteModule.connect(callback)
    lia.db.object = sql
    lia.db.connected = true
    lia.db.connectedModule = "sqlite"
    lia.db._hasConnectedOnce = true
    if isfunction(callback) then safeCallback("SQLite connection", callback) end
end

function sqliteModule.query(query, callback, errorCallback)
    local d
    callback, errorCallback, d = normalizeQueryCallbacks(callback, errorCallback)
    local started = SysTime()
    local data = sql.Query(query)
    local duration = SysTime() - started
    local err = sql.LastError()
    if lia.DevMode and duration >= 0.25 then devLog(string.format("SQLite query took %.3fs:", duration), query) end
    if data == false then
        local ignored = isstring(err) and (string.find(err, "duplicate column name:", 1, true) or string.find(err, "UNIQUE constraint failed: lia_config", 1, true))
        if ignored then
            safeCallback("SQLite success", callback, {}, 0)
            return d
        end

        if lia.DevMode then
            devLog("SQLite query failed:", query)
            devLog("SQLite error:", tostring(err))
        end

        dispatchQueryError(errorCallback, "SQLite", query, err)
        return d
    end

    local lastID
    if isInsertStatement(query) then
        local isIgnore = string.find(string.upper(query), "^%s*INSERT%s+OR%s+IGNORE") ~= nil
        if isIgnore then
            local changed = tonumber(sql.QueryValue("SELECT changes()")) or 0
            lastID = changed > 0 and tonumber(sql.QueryValue("SELECT last_insert_rowid()")) or 0
        else
            lastID = tonumber(sql.QueryValue("SELECT last_insert_rowid()")) or 0
        end
    end

    safeCallback("SQLite success", callback, data, lastID)
    return d
end

lia.db.modules.sqlite = sqliteModule
local mysqlooModule = lia.db.modules.mysqloo or {}
mysqlooModule.workQueue = mysqlooModule.workQueue or {}
mysqlooModule.workFirst = mysqlooModule.workFirst or 1
mysqlooModule.workLast = mysqlooModule.workLast or 0
mysqlooModule.connectCallbacks = mysqlooModule.connectCallbacks or {}
mysqlooModule.connecting = mysqlooModule.connecting or false
mysqlooModule.ready = mysqlooModule.ready or false
mysqlooModule.active = mysqlooModule.active or false
mysqlooModule.reconnectRequested = mysqlooModule.reconnectRequested or false
local function mysqlEscapeFallback(value)
    value = tostring(value)
    value = value:gsub("\\", "\\\\")
    value = value:gsub("%z", "\\0")
    value = value:gsub("\n", "\\n")
    value = value:gsub("\r", "\\r")
    value = value:gsub("\026", "\\Z")
    value = value:gsub("'", "\\'")
    value = value:gsub('"', '\\"')
    return value
end

function mysqlooModule.escape(value)
    local object = mysqlooModule.object
    if object and mysqlooModule.ready and isfunction(object.escape) then
        local ok, escaped = pcall(object.escape, object, tostring(value))
        if ok and escaped ~= nil then return escaped end
    end
    return mysqlEscapeFallback(value)
end

local function mysqlPushBack(job)
    mysqlooModule.workLast = mysqlooModule.workLast + 1
    mysqlooModule.workQueue[mysqlooModule.workLast] = job
end

local function mysqlPushFront(job)
    mysqlooModule.workFirst = mysqlooModule.workFirst - 1
    mysqlooModule.workQueue[mysqlooModule.workFirst] = job
end

local function mysqlPopFront()
    if mysqlooModule.workFirst > mysqlooModule.workLast then return nil end
    local job = mysqlooModule.workQueue[mysqlooModule.workFirst]
    mysqlooModule.workQueue[mysqlooModule.workFirst] = nil
    mysqlooModule.workFirst = mysqlooModule.workFirst + 1
    if mysqlooModule.workFirst > mysqlooModule.workLast then
        mysqlooModule.workQueue = {}
        mysqlooModule.workFirst = 1
        mysqlooModule.workLast = 0
    end
    return job
end

local function mysqlStatusConnected()
    local object = mysqlooModule.object
    local library = mysqlooModule.library
    if not object or not library or not mysqlooModule.ready then return false end
    local ok, status = pcall(object.status, object)
    return ok and status == library.DATABASE_CONNECTED
end

local function mysqlConnectionStatus()
    local object = mysqlooModule.object
    if not object then return "no object" end
    local ok, status = pcall(object.status, object)
    if not ok then return "status unavailable: " .. tostring(status) end
    local library = mysqlooModule.library
    if library then
        for name, value in pairs(library) do
            if isstring(name) and name:find("^DATABASE_") and value == status then return name end
        end
    end
    return tostring(status)
end

local function mysqlLoadLibrary()
    if mysqlooModule.library then return true end
    local ok, library = pcall(require, "mysqloo")
    if not ok then return false, "Failed to load mysqloo: " .. tostring(library) end
    if not istable(library) then library = _G.mysqloo end
    if not istable(library) or not isfunction(library.connect) then return false, "Failed to load mysqloo: invalid module" end
    mysqlooModule.library = library
    return true
end

local function mysqlFailJob(job, err)
    if job.kind == "transaction" then
        job.deferred:reject(err)
        return
    end

    dispatchQueryError(job.errorCallback, "MySQL", job.query, err)
end

local function mysqlFailPending(err)
    if mysqlooModule.currentJob then
        mysqlFailJob(mysqlooModule.currentJob, err)
        mysqlooModule.currentJob = nil
    end

    while true do
        local job = mysqlPopFront()
        if not job then break end
        mysqlFailJob(job, err)
    end

    mysqlooModule.active = false
end

local function mysqlFlushConnectCallbacks(success, err)
    local callbacks = mysqlooModule.connectCallbacks
    mysqlooModule.connectCallbacks = {}
    for _, entry in ipairs(callbacks) do
        if success then
            safeCallback("MySQL connection", entry.callback)
        elseif isfunction(entry.errorCallback) then
            safeCallback("MySQL connection error", entry.errorCallback, err)
        end
    end
end

local function mysqlDirectQuery(query, onSuccess, onError)
    local object = mysqlooModule.object
    if not object then
        onError("MySQL database object is unavailable", query)
        return
    end

    local ok, queryObject = pcall(object.query, object, query)
    if not ok or not queryObject then
        onError(ok and "Failed to create MySQL query" or queryObject, query)
        return
    end

    local started = SysTime()
    queryObject.onSuccess = function(q, data)
        local duration = SysTime() - started
        if lia.DevMode and duration >= 0.25 then devLog(string.format("MySQL query took %.3fs:", duration), query) end
        local lastID
        if isInsertStatement(query) then
            local success, value = pcall(q.lastInsert, q)
            if success then lastID = tonumber(value) or 0 end
        end

        onSuccess(data, lastID)
    end

    queryObject.onError = function(_, err, failedQuery) onError(err, failedQuery or query) end
    queryObject.onAborted = function() onError("Query aborted", query) end
    local startedOk, startErr = pcall(queryObject.start, queryObject)
    if not startedOk then onError(startErr, query) end
end

local mysqlPump
local function mysqlFinishJob()
    mysqlooModule.active = false
    mysqlooModule.currentJob = nil
    if mysqlooModule.reconnectRequested then
        mysqlooModule.reconnectRequested = false
        mysqlooModule.connect(nil, true)
        return
    end

    mysqlPump()
end

local function mysqlHandleConnectionLoss(job, err)
    mysqlooModule.ready = false
    lia.db.connected = false
    mysqlooModule.active = false
    mysqlooModule.currentJob = nil
    if job.kind == "query" and (job.retries or 0) < 1 then
        job.retries = (job.retries or 0) + 1
        mysqlPushFront(job)
    else
        mysqlFailJob(job, err)
    end

    mysqlooModule.connect(nil, true)
end

local function mysqlRunQueryJob(job)
    mysqlDirectQuery(job.query, function(data, lastID)
        safeCallback("MySQL success", job.callback, data, lastID)
        mysqlFinishJob()
    end, function(err, failedQuery)
        if not mysqlStatusConnected() then
            mysqlHandleConnectionLoss(job, err)
            return
        end

        if lia.DevMode then
            devLog("MySQL query failed:", failedQuery or job.query)
            devLog("MySQL error:", tostring(err))
        end

        mysqlFailJob(job, err)
        mysqlFinishJob()
    end)
end

local function mysqlRunTransactionJob(job)
    local queries = job.queries
    local index = 1
    local originalError
    local function fail(err)
        originalError = originalError or err
        if not mysqlStatusConnected() then
            job.deferred:reject(originalError)
            mysqlFinishJob()
            mysqlooModule.connect(nil, true)
            return
        end

        mysqlDirectQuery("ROLLBACK", function()
            job.deferred:reject(originalError)
            mysqlFinishJob()
        end, function()
            job.deferred:reject(originalError)
            mysqlFinishJob()
            if not mysqlStatusConnected() then mysqlooModule.connect(nil, true) end
        end)
    end

    local function commit()
        mysqlDirectQuery("COMMIT", function()
            job.deferred:resolve()
            mysqlFinishJob()
        end, function(err) fail(err) end)
    end

    local function nextQuery()
        if index > #queries then
            commit()
            return
        end

        local query = queries[index]
        index = index + 1
        mysqlDirectQuery(query, function() nextQuery() end, function(err) fail(err) end)
    end

    mysqlDirectQuery("START TRANSACTION", function() nextQuery() end, function(err)
        if not mysqlStatusConnected() and (job.retries or 0) < 1 then
            job.retries = (job.retries or 0) + 1
            mysqlooModule.active = false
            mysqlooModule.currentJob = nil
            mysqlPushFront(job)
            mysqlooModule.connect(nil, true)
            return
        end

        job.deferred:reject(err)
        mysqlFinishJob()
    end)
end

mysqlPump = function()
    if mysqlooModule.active or not mysqlStatusConnected() then return end
    local job = mysqlPopFront()
    if not job then return end
    mysqlooModule.active = true
    mysqlooModule.currentJob = job
    if job.kind == "transaction" then
        mysqlRunTransactionJob(job)
    else
        mysqlRunQueryJob(job)
    end
end

local function mysqlConnectionTimeout(database)
    timer.Simple(60, function()
        if mysqlooModule.object ~= database or not mysqlooModule.connecting then return end
        local phase = tostring(mysqlooModule.connectionPhase or "connecting")
        local status = mysqlConnectionStatus()
        local err = "MySQL connection timed out after 60 seconds (phase=" .. phase .. ", status=" .. status .. ")"
        mysqlooModule.object = nil
        mysqlooModule.connecting = false
        mysqlooModule.ready = false
        mysqlooModule.connectionPhase = "failed"
        mysqlooModule.lastConnectionError = err
        lia.db.connected = false
        lia.db.object = nil
        if lia.db.connectedModule == "mysqloo" then lia.db.connectedModule = nil end
        if isfunction(database.disconnect) then pcall(database.disconnect, database, false) end
        mysqlFlushConnectCallbacks(false, err)
        mysqlFailPending(err)
        databaseLogError(err)
    end)
end

local function mysqlConfigureCharset(database, done)
    local function runCharset(charset, fallback)
        local ok, queryObject = pcall(database.query, database, "SET NAMES " .. charset)
        if not ok or not queryObject then
            if fallback then
                fallback()
            else
                done()
            end
            return
        end

        queryObject.onSuccess = function() done() end
        queryObject.onError = function()
            if fallback then
                fallback()
            else
                done()
            end
        end

        queryObject.onAborted = function()
            if fallback then
                fallback()
            else
                done()
            end
        end

        local startedOk = pcall(queryObject.start, queryObject)
        if not startedOk then
            if fallback then
                fallback()
            else
                done()
            end
        end
    end

    runCharset("utf8mb4", function() runCharset("utf8", nil) end)
end

function mysqlooModule.connect(callback, reconnect, errorCallback)
    if isfunction(callback) or isfunction(errorCallback) then
        mysqlooModule.connectCallbacks[#mysqlooModule.connectCallbacks + 1] = {
            callback = callback,
            errorCallback = errorCallback
        }
    end

    if mysqlStatusConnected() and not reconnect then
        mysqlFlushConnectCallbacks(true)
        mysqlPump()
        return
    end

    if mysqlooModule.connecting then return end
    if reconnect and mysqlooModule.active and mysqlStatusConnected() then
        mysqlooModule.reconnectRequested = true
        return
    end

    local loaded, loadError = mysqlLoadLibrary()
    if not loaded then
        mysqlooModule.ready = false
        mysqlooModule.connectionPhase = "failed"
        mysqlooModule.lastConnectionError = tostring(loadError)
        lia.db.connected = false
        if lia.db.connectedModule == "mysqloo" then lia.db.connectedModule = nil end
        lia.db.object = nil
        mysqlFlushConnectCallbacks(false, loadError)
        mysqlFailPending(loadError)
        databaseLogError(loadError)
        return
    end

    mysqlooModule.connecting = true
    mysqlooModule.ready = false
    mysqlooModule.connectionPhase = "connecting"
    mysqlooModule.connectionStartedAt = SysTime()
    mysqlooModule.lastConnectionError = nil
    lia.db.connected = false
    databaseLogError(string.format("Starting MySQL connection to %s:%s (database=%s)", tostring(lia.db.hostname or "127.0.0.1"), tostring(lia.db.port or 3306), tostring(lia.db.database or "")))
    local previous = mysqlooModule.object
    if reconnect and previous and isfunction(previous.disconnect) then pcall(previous.disconnect, previous, false) end
    local library = mysqlooModule.library
    local ok, database = pcall(library.connect, lia.db.hostname or "127.0.0.1", lia.db.username or "", lia.db.password or "", lia.db.database or "", tonumber(lia.db.port) or 3306)
    if not ok or not database then
        local err = ok and "mysqloo.connect returned no database object" or database
        mysqlooModule.connecting = false
        mysqlooModule.connectionPhase = "failed"
        mysqlooModule.lastConnectionError = tostring(err)
        lia.db.object = nil
        mysqlooModule.object = nil
        mysqlFlushConnectCallbacks(false, err)
        mysqlFailPending(err)
        databaseLogError("MySQL connection failed: " .. tostring(err))
        return
    end

    mysqlooModule.object = database
    lia.db.object = database
    if isfunction(database.setAutoReconnect) then pcall(database.setAutoReconnect, database, true) end
    if isfunction(database.setMultiStatements) then pcall(database.setMultiStatements, database, true) end
    database.onConnected = function(db)
        if mysqlooModule.object ~= db then return end
        databaseLogError("MySQL socket connected; configuring connection character set")
        mysqlooModule.connectionPhase = "charset"
        mysqlConfigureCharset(db, function()
            if mysqlooModule.object ~= db then return end
            mysqlooModule.connecting = false
            mysqlooModule.ready = true
            mysqlooModule.connectionPhase = "ready"
            mysqlooModule.lastConnectionError = nil
            lia.db.connected = true
            lia.db.connectedModule = "mysqloo"
            lia.db.object = db
            lia.db._hasConnectedOnce = true
            if isfunction(db.serverInfo) then
                local infoOk, info = pcall(db.serverInfo, db)
                if infoOk then mysqlooModule.serverInfo = info end
            end

            databaseLogError("MySQL connection ready (" .. mysqlConnectionStatus() .. ")")
            mysqlFlushConnectCallbacks(true)
            mysqlPump()
        end)
    end

    database.onConnectionFailed = function(db, err)
        if mysqlooModule.object ~= db then return end
        mysqlooModule.connecting = false
        mysqlooModule.ready = false
        mysqlooModule.connectionPhase = "failed"
        mysqlooModule.lastConnectionError = tostring(err)
        lia.db.connected = false
        mysqlFlushConnectCallbacks(false, err)
        mysqlFailPending(err)
        databaseLogError("MySQL connection failed: " .. tostring(err))
    end

    database.onDisconnected = function(db)
        if mysqlooModule.object ~= db then return end
        mysqlooModule.ready = false
        mysqlooModule.connectionPhase = "disconnected"
        lia.db.connected = false
        databaseLogError("MySQL connection lost; attempting reconnect")
        if not mysqlooModule.connecting then mysqlooModule.connect(nil, true) end
    end

    mysqlConnectionTimeout(database)
    local connected, connectError = pcall(database.connect, database)
    if not connected then
        mysqlooModule.object = nil
        mysqlooModule.connecting = false
        mysqlooModule.ready = false
        mysqlooModule.connectionPhase = "failed"
        mysqlooModule.lastConnectionError = tostring(connectError)
        lia.db.connected = false
        lia.db.object = nil
        mysqlFlushConnectCallbacks(false, connectError)
        mysqlFailPending(connectError)
        databaseLogError("MySQL connection failed: " .. tostring(connectError))
    end
end

local function normalizeMySQLLegacyQuery(query)
    if not isstring(query) then return query end
    local tableName = query:match("^%s*[Pp][Rr][Aa][Gg][Mm][Aa]%s+[Tt][Aa][Bb][Ll][Ee]_[Ii][Nn][Ff][Oo]%s*%(%s*`?([%w_]+)`?%s*%)%s*;?%s*$")
    if tableName and tableName:match("^[%a_][%w_]*$") then return "SELECT ordinal_position - 1 AS cid, column_name AS name, column_type AS type, column_default AS dflt_value, CASE WHEN column_key = 'PRI' THEN 1 ELSE 0 END AS pk FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = '" .. tableName .. "' ORDER BY ordinal_position" end
    if query:match("^%s*[Cc][Rr][Ee][Aa][Tt][Ee]%s+[Tt][Aa][Bb][Ll][Ee]") then return query:gsub("[Ii][Nn][Tt][Ee][Gg][Ee][Rr]%s+[Pp][Rr][Ii][Mm][Aa][Rr][Yy]%s+[Kk][Ee][Yy]%s+[Aa][Uu][Tt][Oo][Ii][Nn][Cc][Rr][Ee][Mm][Ee][Nn][Tt]", "INT NOT NULL AUTO_INCREMENT PRIMARY KEY") end
    return query
end

function mysqlooModule.query(query, callback, errorCallback)
    local d
    callback, errorCallback, d = normalizeQueryCallbacks(callback, errorCallback)
    query = normalizeMySQLLegacyQuery(query)
    mysqlPushBack({
        kind = "query",
        query = query,
        callback = callback,
        errorCallback = errorCallback,
        retries = 0
    })

    if mysqlStatusConnected() then
        mysqlPump()
    elseif lia.db._hasConnectedOnce and not mysqlooModule.connecting then
        mysqlooModule.connect(nil, true)
    end
    return d
end

function mysqlooModule.transaction(queries)
    local d = deferred.new()
    mysqlPushBack({
        kind = "transaction",
        queries = queries,
        deferred = d,
        retries = 0
    })

    if mysqlStatusConnected() then
        mysqlPump()
    elseif lia.db._hasConnectedOnce and not mysqlooModule.connecting then
        mysqlooModule.connect(nil, true)
    end
    return d
end

lia.db.modules.mysqloo = mysqlooModule
local function activeModule()
    return lia.db.modules[lia.db.module]
end

function lia.db.escape(value)
    local module = activeModule() or lia.db.modules.sqlite
    return module.escape(value)
end

local function queueBeforeConnection(query, callback, errorCallback)
    local d
    callback, errorCallback, d = normalizeQueryCallbacks(callback, errorCallback)
    lia.db.queryQueue[#lia.db.queryQueue + 1] = {
        query = query,
        callback = callback,
        errorCallback = errorCallback
    }
    return d
end

local function failInitialQueue(err)
    local queue = lia.db.queryQueue
    lia.db.queryQueue = {}
    lia.db.queue = lia.db.queryQueue
    for _, item in ipairs(queue) do
        dispatchQueryError(item.errorCallback, "Database", item.query, err)
    end
end

local function flushInitialQueue(module)
    local queue = lia.db.queryQueue
    lia.db.queryQueue = {}
    lia.db.queue = lia.db.queryQueue
    for _, item in ipairs(queue) do
        module.query(item.query, item.callback, item.errorCallback)
    end
end

function lia.db.query(query, callback, errorCallback)
    local module = activeModule()
    if not module then return queueBeforeConnection(query, callback, errorCallback) end
    if lia.db.connected then return module.query(query, callback, errorCallback) end
    if lia.db.module == "mysqloo" and lia.db._hasConnectedOnce then return module.query(query, callback, errorCallback) end
    return queueBeforeConnection(query, callback, errorCallback)
end

function lia.db.connect(callback, reconnect)
    local module = activeModule()
    if not module then
        local err = string.format("'%s' is not a valid data storage method!", lia.db.module or "Unavailable")
        failInitialQueue(err)
        lia.error(err)
        return
    end

    if lia.db.connected and lia.db.connectedModule and lia.db.connectedModule ~= lia.db.module then
        lia.db.connected = false
        lia.db.object = nil
    end

    if lia.db.connected and not reconnect then
        flushInitialQueue(module)
        if isfunction(callback) then safeCallback("Database connection", callback) end
        return
    end

    module.connect(function()
        lia.db.connected = true
        lia.db.connectedModule = lia.db.module
        lia.db._hasConnectedOnce = true
        flushInitialQueue(module)
        if isfunction(callback) then safeCallback("Database connection", callback) end
    end, reconnect, function(err) failInitialQueue(err) end)
end

if SERVER then
    concommand.Add("lia_db_status", function(client)
        if IsValid(client) then return end
        local module = tostring(lia.db.module or "unset")
        print(string.format("[Lilia DB] backend=%s connected=%s tablesLoaded=%s tablesLoading=%s connectedModule=%s", module, tostring(lia.db.connected), tostring(lia.db.tablesLoaded), tostring(lia.db.tablesLoading), tostring(lia.db.connectedModule or "none")))
        if module ~= "mysqloo" then return end
        local queued = math.max(0, mysqlooModule.workLast - mysqlooModule.workFirst + 1)
        local elapsed = mysqlooModule.connecting and mysqlooModule.connectionStartedAt and math.max(0, SysTime() - mysqlooModule.connectionStartedAt) or 0
        print(string.format("[Lilia DB] phase=%s connecting=%s ready=%s status=%s elapsed=%.1fs", tostring(mysqlooModule.connectionPhase or "idle"), tostring(mysqlooModule.connecting), tostring(mysqlooModule.ready), mysqlConnectionStatus(), elapsed))
        print(string.format("[Lilia DB] initialQueued=%d mysqlQueued=%d active=%s callbacks=%d", #lia.db.queryQueue, queued, tostring(mysqlooModule.active), #mysqlooModule.connectCallbacks))
        if mysqlooModule.lastConnectionError then print("[Lilia DB] lastError=" .. tostring(mysqlooModule.lastConnectionError)) end
    end)

    concommand.Add("lia_db_retry", function(client)
        if IsValid(client) then return end
        if lia.db.module ~= "mysqloo" then
            print("[Lilia DB] Retry is only available for mysqloo.")
            return
        end

        if mysqlooModule.connecting then
            print("[Lilia DB] A connection is already in progress. Run lia_db_status to inspect it.")
            return
        end

        if mysqlStatusConnected() then
            print("[Lilia DB] MySQL is already connected.")
            return
        end

        print("[Lilia DB] Retrying MySQL connection...")
        lia.db.connect(function()
            if lia.db.tablesLoaded then return end
            lia.db.loadTables()
            hook.Run("DatabaseConnected")
        end, true)
    end)
end

local function prefixTable(dbTable, defaultName)
    return "lia_" .. tostring(dbTable or defaultName)
end

function lia.db.escapeIdentifier(id)
    local value = tostring(id)
    if value == "*" then return "*" end
    if value:find("[%z\1-\31]") then error("Invalid SQL identifier", 2) end
    if value:sub(1, 1) == "." or value:sub(-1) == "." or value:find("%.%.") then error("Invalid SQL identifier", 2) end
    local parts = {}
    for part in value:gmatch("[^%.]+") do
        if part == "*" then
            parts[#parts + 1] = "*"
        else
            parts[#parts + 1] = "`" .. part:gsub("`", "``") .. "`"
        end
    end

    if #parts == 0 then error("Invalid SQL identifier", 2) end
    return table.concat(parts, ".")
end

local function escapeStructuredIdentifier(id)
    local value = tostring(id)
    for part in value:gmatch("[^%.]+") do
        if not part:match("^[%a_][%w_]*$") then error("Invalid structured SQL identifier: " .. value, 3) end
    end
    return lia.db.escapeIdentifier(value)
end

function lia.db.convertDataType(value, noEscape)
    if value == nil then
        return "NULL"
    elseif isstring(value) then
        if noEscape then return value end
        return "'" .. lia.db.escape(value) .. "'"
    elseif istable(value) then
        local encoded = util.TableToJSON(value)
        if noEscape then return encoded end
        return "'" .. lia.db.escape(encoded) .. "'"
    elseif isbool(value) then
        return value and "1" or "0"
    elseif NULL ~= nil and value == NULL then
        return "NULL"
    elseif isnumber(value) then
        if value ~= value or value == math.huge or value == -math.huge then error("Invalid numeric database value", 2) end
        return tostring(value)
    end
    return tostring(value)
end

local function makeCondition(operator, value)
    return {
        [conditionMarker] = true,
        operator = operator,
        value = value
    }
end

function lia.db.eq(value)
    return makeCondition("=", value)
end

function lia.db.neq(value)
    return makeCondition("<>", value)
end

function lia.db.gt(value)
    return makeCondition(">", value)
end

function lia.db.gte(value)
    return makeCondition(">=", value)
end

function lia.db.lt(value)
    return makeCondition("<", value)
end

function lia.db.lte(value)
    return makeCondition("<=", value)
end

function lia.db.like(value)
    return makeCondition("LIKE", value)
end

function lia.db.notLike(value)
    return makeCondition("NOT LIKE", value)
end

function lia.db.inList(values)
    return makeCondition("IN", values)
end

function lia.db.notInList(values)
    return makeCondition("NOT IN", values)
end

function lia.db.isNull()
    return makeCondition("IS NULL")
end

function lia.db.isNotNull()
    return makeCondition("IS NOT NULL")
end

local function logicalGroup(logic, ...)
    local items = {...}
    if #items == 1 and istable(items[1]) and items[1][groupMarker] ~= true and #items[1] > 0 then
        local arrayOnly = true
        for key in pairs(items[1]) do
            if not isnumber(key) then
                arrayOnly = false
                break
            end
        end

        if arrayOnly then items = items[1] end
    end
    return {
        [groupMarker] = true,
        logic = logic,
        items = items
    }
end

function lia.db.andGroup(...)
    return logicalGroup("AND", ...)
end

function lia.db.orGroup(...)
    return logicalGroup("OR", ...)
end

local function normalizeOperator(operator)
    operator = string.upper(tostring(operator or "=")):gsub("%s+", " ")
    local normalized = allowedOperators[operator]
    if not normalized then error("Unsupported database condition operator: " .. tostring(operator), 4) end
    return normalized
end

local function isConditionDescriptor(value)
    if not istable(value) then return false end
    if value[conditionMarker] then return true end
    if value.operator == nil then return false end
    local operator = string.upper(tostring(value.operator)):gsub("%s+", " ")
    return value.value ~= nil or operator == "IS NULL" or operator == "IS NOT NULL"
end

local compileConditionTable
local function compileFieldCondition(field, value)
    local escapedField = lia.db.escapeIdentifier(field)
    local operator = "="
    local conditionValue = value
    if isConditionDescriptor(value) then
        operator = normalizeOperator(value.operator)
        conditionValue = value.value
    end

    if operator == "IS NULL" or operator == "IS NOT NULL" then return escapedField .. " " .. operator end
    if (operator == "=" or operator == "<>") and (conditionValue == nil or NULL ~= nil and conditionValue == NULL) then return escapedField .. (operator == "=" and " IS NULL" or " IS NOT NULL") end
    if operator == "IN" or operator == "NOT IN" then
        if not istable(conditionValue) then error(operator .. " requires a table of values", 4) end
        if #conditionValue == 0 then return operator == "IN" and "1 = 0" or "1 = 1" end
        local values = {}
        for _, item in ipairs(conditionValue) do
            values[#values + 1] = lia.db.convertDataType(item)
        end
        return escapedField .. " " .. operator .. " (" .. table.concat(values, ", ") .. ")"
    end

    if conditionValue == nil then return nil end
    return escapedField .. " " .. operator .. " " .. lia.db.convertDataType(conditionValue)
end

local function compileGroup(group)
    local parts = {}
    for _, item in ipairs(group.items or {}) do
        local compiled
        if istable(item) and item[groupMarker] then
            compiled = compileGroup(item)
        elseif istable(item) then
            compiled = compileConditionTable(item, "AND")
        else
            error("Logical database groups require condition tables", 4)
        end

        if compiled and compiled ~= "" then parts[#parts + 1] = compiled end
    end

    if #parts == 0 then return group.logic == "OR" and "1 = 0" or "1 = 1" end
    return "(" .. table.concat(parts, " " .. group.logic .. " ") .. ")"
end

compileConditionTable = function(conditions, logic)
    local parts = {}
    for field, value in pairs(conditions) do
        local compiled
        if isnumber(field) then
            if istable(value) and value[groupMarker] then compiled = compileGroup(value) end
        elseif value ~= nil or isConditionDescriptor(value) then
            compiled = compileFieldCondition(field, value)
        end

        if compiled and compiled ~= "" then parts[#parts + 1] = compiled end
    end

    if #parts == 0 then return "" end
    return table.concat(parts, " " .. (logic or "AND") .. " ")
end

local function buildWhereClause(conditions)
    if conditions == nil then return "" end
    if isstring(conditions) then return conditions == "" and "" or " WHERE " .. conditions end
    if istable(conditions) then
        local compiled
        if conditions[groupMarker] then
            compiled = compileGroup(conditions)
        else
            compiled = compileConditionTable(conditions, "AND")
        end

        if compiled ~= "" then return " WHERE " .. compiled end
    end
    return ""
end

local function makeOrder(field, direction)
    return {
        [orderMarker] = true,
        field = field,
        direction = direction
    }
end

function lia.db.orderAsc(field)
    return makeOrder(field, "ASC")
end

function lia.db.orderDesc(field)
    return makeOrder(field, "DESC")
end

local function buildOrderClause(order)
    if order == nil then return "" end
    if isstring(order) then return order == "" and "" or " ORDER BY " .. order end
    local entries = {}
    if istable(order) and order[orderMarker] then
        entries[1] = order
    elseif istable(order) then
        for _, entry in ipairs(order) do
            if not istable(entry) or not entry[orderMarker] then error("Structured order entries must use lia.db.orderAsc/orderDesc", 3) end
            entries[#entries + 1] = entry
        end
    else
        error("Invalid database ordering", 3)
    end

    if #entries == 0 then return "" end
    local parts = {}
    for _, entry in ipairs(entries) do
        parts[#parts + 1] = escapeStructuredIdentifier(entry.field) .. " " .. entry.direction
    end
    return " ORDER BY " .. table.concat(parts, ", ")
end

local function normalizeLimitOffset(limit, offset)
    local normalizedLimit
    local normalizedOffset
    if limit ~= nil then
        normalizedLimit = tonumber(limit)
        if not normalizedLimit or normalizedLimit < 0 or normalizedLimit ~= math.floor(normalizedLimit) then error("Database limit must be a non-negative integer", 3) end
    end

    if offset ~= nil then
        normalizedOffset = tonumber(offset)
        if not normalizedOffset or normalizedOffset < 0 or normalizedOffset ~= math.floor(normalizedOffset) then error("Database offset must be a non-negative integer", 3) end
    end
    return normalizedLimit, normalizedOffset
end

local function buildLimitOffsetClause(limit, offset)
    limit, offset = normalizeLimitOffset(limit, offset)
    if limit ~= nil then
        local clause = " LIMIT " .. tostring(limit)
        if offset ~= nil then clause = clause .. " OFFSET " .. tostring(offset) end
        return clause
    end

    if offset ~= nil then
        if lia.db.module == "mysqloo" then return " LIMIT 18446744073709551615 OFFSET " .. tostring(offset) end
        return " LIMIT -1 OFFSET " .. tostring(offset)
    end
    return ""
end

local function resolveSelectOptions(limit, orderBy, options)
    local order = orderBy
    local offset
    if istable(orderBy) and not orderBy[orderMarker] and (orderBy.order ~= nil or orderBy.offset ~= nil or orderBy.limit ~= nil) then
        options = orderBy
        order = options.order
    elseif istable(options) then
        order = options.order ~= nil and options.order or order
    end

    if istable(options) then
        if options.limit ~= nil then limit = options.limit end
        offset = options.offset
    end
    return limit, order, offset
end

local function genInsertParts(value, dbTable)
    local keys = {}
    local rawKeys = {}
    local values = {}
    for key, item in pairs(value) do
        rawKeys[#rawKeys + 1] = key
        keys[#keys + 1] = lia.db.escapeIdentifier(key)
        values[#values + 1] = lia.db.convertDataType(item)
    end

    if #keys == 0 then error("Database insert requires at least one field", 3) end
    local tableName = lia.db.escapeIdentifier(prefixTable(dbTable, "characters"))
    return tableName, keys, rawKeys, values
end

local function genInsertValues(value, dbTable)
    local tableName, keys, _, values = genInsertParts(value, dbTable)
    return tableName .. " (" .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
end

local function genUpdateList(value)
    local changes = {}
    for key, item in pairs(value) do
        changes[#changes + 1] = lia.db.escapeIdentifier(key) .. " = " .. lia.db.convertDataType(item)
    end

    if #changes == 0 then error("Database update requires at least one field", 3) end
    return table.concat(changes, ", ")
end

function lia.db.insertTable(value, callback, dbTable)
    local d = deferred.new()
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    lia.db.query(query, function(results, lastID)
        if callback then safeCallback("insertTable", callback, results, lastID) end
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.updateTable(value, callback, dbTable, condition)
    local d = deferred.new()
    local query = "UPDATE " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters")) .. " SET " .. genUpdateList(value) .. buildWhereClause(condition)
    lia.db.query(query, function(results, lastID)
        if callback then safeCallback("updateTable", callback, results, lastID) end
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

local function buildSelectFields(fields)
    local selected = istable(fields) and fields or string.Explode(",", tostring(fields))
    local compiled = {}
    for _, field in ipairs(selected) do
        local value = string.Trim(tostring(field))
        if value:match("^[%a_][%w_]*$") or value:match("^[%a_][%w_]*%.[%a_][%w_]*$") then
            compiled[#compiled + 1] = lia.db.escapeIdentifier(value)
        else
            compiled[#compiled + 1] = value
        end
    end
    return table.concat(compiled, ", ")
end

function lia.db.select(fields, dbTable, condition, limit, options)
    local d = deferred.new()
    if fields == nil then
        lia.error("lia.db.select called with nil fields parameter - using default '*'")
        fields = "*"
    end

    local from = buildSelectFields(fields)
    local query = "SELECT " .. from .. " FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters"))
    query = query .. buildWhereClause(condition)
    local order
    local offset
    if istable(options) then
        order = options.order
        offset = options.offset
        if options.limit ~= nil then limit = options.limit end
    end

    query = query .. buildOrderClause(order) .. buildLimitOffsetClause(limit, offset)
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.selectWithCondition(fields, dbTable, conditions, limit, orderBy, options)
    local d = deferred.new()
    if fields == nil then
        lia.error("lia.db.selectWithCondition called with nil fields parameter - using default '*'")
        fields = "*"
    end

    local from = buildSelectFields(fields)
    local query = "SELECT " .. from .. " FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters"))
    query = query .. buildWhereClause(conditions)
    local resolvedLimit, resolvedOrder, offset = resolveSelectOptions(limit, orderBy, options)
    query = query .. buildOrderClause(resolvedOrder) .. buildLimitOffsetClause(resolvedLimit, offset)
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.count(dbTable, condition)
    local d = deferred.new()
    local query = "SELECT COUNT(*) AS cnt FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters")) .. buildWhereClause(condition)
    lia.db.query(query, function(results)
        if istable(results) and results[1] then
            d:resolve(tonumber(results[1].cnt) or 0)
        else
            d:resolve(0)
        end
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(count) return count > 0 end)
end

function lia.db.selectOne(fields, dbTable, condition, options)
    local d = deferred.new()
    if fields == nil then
        lia.error("lia.db.selectOne called with nil fields parameter - using default '*'")
        fields = "*"
    end

    local from = buildSelectFields(fields)
    local query = "SELECT " .. from .. " FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters")) .. buildWhereClause(condition)
    local order = istable(options) and options.order or nil
    local offset = istable(options) and options.offset or nil
    query = query .. buildOrderClause(order) .. buildLimitOffsetClause(1, offset)
    lia.db.query(query, function(results)
        if istable(results) then
            d:resolve(results[1])
        else
            d:resolve(nil)
        end
    end, function(err) d:reject(err) end)
    return d
end

local function bulkParts(dbTable, rows)
    if not istable(rows) or #rows == 0 then return nil end
    local rawKeys = {}
    local keys = {}
    for key in pairs(rows[1]) do
        rawKeys[#rawKeys + 1] = key
        keys[#keys + 1] = lia.db.escapeIdentifier(key)
    end

    if #keys == 0 then error("Bulk database operation requires at least one field", 3) end
    local values = {}
    for _, row in ipairs(rows) do
        local items = {}
        for _, key in ipairs(rawKeys) do
            items[#items + 1] = lia.db.convertDataType(row[key])
        end

        values[#values + 1] = "(" .. table.concat(items, ", ") .. ")"
    end
    return lia.db.escapeIdentifier(prefixTable(dbTable, "characters")), rawKeys, keys, values
end

function lia.db.bulkInsert(dbTable, rows)
    if not istable(rows) or #rows == 0 then return deferred.resolve() end
    local d = deferred.new()
    local tableName, _, keys, values = bulkParts(dbTable, rows)
    local query = "INSERT INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(values, ",")
    lia.db.query(query, function() d:resolve() end, function(err) d:reject(err) end)
    return d
end

local function mysqlSupportsInsertAlias()
    local info = tostring(mysqlooModule.serverInfo or "")
    if info == "" or string.find(string.lower(info), "mariadb", 1, true) then return false end
    local major, minor, patch = info:match("(%d+)%.(%d+)%.(%d+)")
    major = tonumber(major)
    minor = tonumber(minor)
    patch = tonumber(patch)
    if not major or not minor or not patch then return false end
    if major > 8 then return true end
    return major == 8 and minor == 0 and patch >= 19
end

local function mysqlUpsertAlias(dbTable)
    local tableName = prefixTable(dbTable, "characters")
    local alias = tableName == "lia_upsert_values" and "lia_upsert_values_2" or "lia_upsert_values"
    return lia.db.escapeIdentifier(alias)
end

local function mysqlDuplicateUpdate(rawKeys, alias)
    local updates = {}
    for _, key in ipairs(rawKeys) do
        local escaped = lia.db.escapeIdentifier(key)
        if alias then
            updates[#updates + 1] = escaped .. " = " .. alias .. "." .. escaped
        else
            updates[#updates + 1] = escaped .. " = VALUES(" .. escaped .. ")"
        end
    end
    return table.concat(updates, ", ")
end

function lia.db.bulkUpsert(dbTable, rows)
    if not istable(rows) or #rows == 0 then return deferred.resolve() end
    local d = deferred.new()
    local tableName, rawKeys, keys, values = bulkParts(dbTable, rows)
    local query
    if lia.db.module == "mysqloo" then
        if mysqlSupportsInsertAlias() then
            local alias = mysqlUpsertAlias(dbTable)
            query = "INSERT INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(values, ",") .. " AS " .. alias .. " ON DUPLICATE KEY UPDATE " .. mysqlDuplicateUpdate(rawKeys, alias)
        else
            query = "INSERT INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(values, ",") .. " ON DUPLICATE KEY UPDATE " .. mysqlDuplicateUpdate(rawKeys)
        end
    else
        query = "INSERT OR REPLACE INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(values, ",")
    end

    lia.db.query(query, function() d:resolve() end, function(err) d:reject(err) end)
    return d
end

function lia.db.insertOrIgnore(value, dbTable)
    local d = deferred.new()
    local tableName, keys, _, values = genInsertParts(value, dbTable)
    local command = lia.db.module == "mysqloo" and "INSERT IGNORE" or "INSERT OR IGNORE"
    local query = command .. " INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(values, ",") .. ")"
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.upsert(value, dbTable)
    local d = deferred.new()
    local tableName, keys, rawKeys, values = genInsertParts(value, dbTable)
    local query
    if lia.db.module == "mysqloo" then
        if mysqlSupportsInsertAlias() then
            local alias = mysqlUpsertAlias(dbTable)
            query = "INSERT INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(values, ",") .. ") AS " .. alias .. " ON DUPLICATE KEY UPDATE " .. mysqlDuplicateUpdate(rawKeys, alias)
        else
            query = "INSERT INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(values, ",") .. ") ON DUPLICATE KEY UPDATE " .. mysqlDuplicateUpdate(rawKeys)
        end
    else
        query = "INSERT OR REPLACE INTO " .. tableName .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(values, ",") .. ")"
    end

    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.delete(dbTable, condition)
    local d = deferred.new()
    local query = "DELETE FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "character")) .. buildWhereClause(condition)
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) d:reject(err) end)
    return d
end

local function compileTransactionQuery(operation)
    if isstring(operation) then return operation end
    if not istable(operation) then error("Database transactions require query strings or operation tables", 3) end
    local dbTable = operation.table or operation.dbTable
    if not isstring(dbTable) or dbTable == "" then error("Database transaction operation requires a table", 3) end
    if operation.type == "update" then
        return "UPDATE " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters")) .. " SET " .. genUpdateList(operation.values or operation.value or {}) .. buildWhereClause(operation.condition)
    elseif operation.type == "delete" then
        return "DELETE FROM " .. lia.db.escapeIdentifier(prefixTable(dbTable, "characters")) .. buildWhereClause(operation.condition)
    elseif operation.type == "insert" then
        return "INSERT INTO " .. genInsertValues(operation.values or operation.value or {}, dbTable)
    end
    error("Unsupported database transaction operation: " .. tostring(operation.type), 3)
end

function lia.db.transaction(queries)
    if not istable(queries) then return deferred.reject("Database transaction requires a table of queries") end
    local compiled = {}
    local ok, compileError = pcall(function()
        for index, operation in ipairs(queries) do
            compiled[index] = compileTransactionQuery(operation)
        end
    end)
    if not ok then return deferred.reject(compileError) end
    queries = compiled
    if lia.db.module == "mysqloo" then return lia.db.modules.mysqloo.transaction(queries) end
    local d = deferred.new()
    lia.db.query("BEGIN TRANSACTION", function()
        local index = 1
        local originalError
        local function fail(err)
            originalError = originalError or err
            lia.db.query("ROLLBACK", function() d:reject(originalError) end, function() d:reject(originalError) end)
        end

        local function nextQuery()
            if index > #queries then
                lia.db.query("COMMIT", function() d:resolve() end, function(err) fail(err) end)
                return
            end

            local query = queries[index]
            index = index + 1
            lia.db.query(query, function() nextQuery() end, function(err) fail(err) end)
        end

        nextQuery()
    end, function(err) d:reject(err) end)
    return d
end

local function schemaDatabaseValue()
    return lia.db.convertDataType(lia.db.database or "")
end

function lia.db.tableExists(tbl)
    local d = deferred.new()
    if lia.db.module == "mysqloo" then
        local query = "SELECT 1 AS found FROM information_schema.tables WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_name = " .. lia.db.convertDataType(tbl) .. " LIMIT 1"
        lia.db.query(query, function(results) d:resolve(istable(results) and #results > 0) end, function(err) d:reject(err) end)
    else
        local query = "SELECT name FROM sqlite_master WHERE type = 'table' AND name = " .. lia.db.convertDataType(tbl) .. " LIMIT 1"
        lia.db.query(query, function(results) d:resolve(istable(results) and #results > 0) end, function(err) d:reject(err) end)
    end
    return d
end

function lia.db.fieldExists(tbl, field)
    local d = deferred.new()
    if lia.db.module == "mysqloo" then
        local query = "SELECT 1 AS found FROM information_schema.columns WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_name = " .. lia.db.convertDataType(tbl) .. " AND column_name = " .. lia.db.convertDataType(field) .. " LIMIT 1"
        lia.db.query(query, function(results) d:resolve(istable(results) and #results > 0) end, function(err) d:reject(err) end)
    else
        lia.db.query("PRAGMA table_info(" .. lia.db.escapeIdentifier(tbl) .. ")", function(results)
            for _, row in ipairs(results or {}) do
                if row.name == field then
                    d:resolve(true)
                    return
                end
            end

            d:resolve(false)
        end, function(err) d:reject(err) end)
    end
    return d
end

function lia.db.getTables()
    local d = deferred.new()
    local query
    if lia.db.module == "mysqloo" then
        query = "SELECT table_name AS name FROM information_schema.tables WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_type = 'BASE TABLE'"
    else
        query = "SELECT name FROM sqlite_master WHERE type = 'table'"
    end

    lia.db.query(query, function(results)
        local tables = {}
        for _, row in ipairs(results or {}) do
            local name = row.name or row.table_name
            if isstring(name) and name:sub(1, 4) == "lia_" then tables[#tables + 1] = name end
        end

        d:resolve(tables)
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.createIndex(dbTable, indexName, columns)
    local d = deferred.new()
    if not isstring(dbTable) or dbTable == "" then
        d:reject("Database index requires a table name")
        return d
    end

    if not isstring(indexName) or indexName == "" then
        d:reject("Database index requires an index name")
        return d
    end

    if not istable(columns) or #columns == 0 then
        d:reject("Database index requires at least one column")
        return d
    end

    local tableName = prefixTable(dbTable, "characters")
    local escapedColumns = {}
    local ok, err = pcall(function()
        for _, column in ipairs(columns) do
            escapedColumns[#escapedColumns + 1] = escapeStructuredIdentifier(column)
        end
    end)
    if not ok then
        d:reject(err)
        return d
    end

    local function create()
        local query = "CREATE INDEX " .. lia.db.escapeIdentifier(indexName) .. " ON " .. lia.db.escapeIdentifier(tableName) .. "(" .. table.concat(escapedColumns, ", ") .. ")"
        lia.db.query(query, function() d:resolve(true) end, function(createErr) d:reject(createErr) end)
    end

    if lia.db.module == "mysqloo" then
        local query = "SELECT 1 AS found FROM information_schema.statistics WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_name = " .. lia.db.convertDataType(tableName) .. " AND index_name = " .. lia.db.convertDataType(indexName) .. " LIMIT 1"
        lia.db.query(query, function(results)
            if istable(results) and #results > 0 then d:resolve(false) else create() end
        end, function(queryErr) d:reject(queryErr) end)
    else
        local query = "SELECT 1 AS found FROM sqlite_master WHERE type = 'index' AND tbl_name = " .. lia.db.convertDataType(tableName) .. " AND name = " .. lia.db.convertDataType(indexName) .. " LIMIT 1"
        lia.db.query(query, function(results)
            if istable(results) and #results > 0 then d:resolve(false) else create() end
        end, function(queryErr) d:reject(queryErr) end)
    end
    return d
end

local function normalizeColumnType(columnType, length)
    local value = string.lower(tostring(columnType or "")):gsub("^%s+", ""):gsub("%s+$", "")
    local typeMap
    if lia.db.module == "mysqloo" then
        typeMap = {
            string = "VARCHAR(" .. tostring(tonumber(length) or 255) .. ")",
            integer = "INT",
            int = "INT",
            float = "FLOAT",
            boolean = "TINYINT(1)",
            datetime = "DATETIME",
            text = "TEXT"
        }
    else
        typeMap = {
            string = "VARCHAR(" .. tostring(tonumber(length) or 255) .. ")",
            integer = "INTEGER",
            int = "INTEGER",
            float = "REAL",
            boolean = "INTEGER",
            datetime = "DATETIME",
            text = "TEXT"
        }
    end

    if typeMap[value] then return typeMap[value] end
    if value:match("^integer%s+primary%s+key%s+autoincrement$") then return lia.db.module == "mysqloo" and "INT NOT NULL AUTO_INCREMENT PRIMARY KEY" or "INTEGER PRIMARY KEY AUTOINCREMENT" end
    if value:match("^varchar%(%d+%)$") or value:match("^char%(%d+%)$") or value:match("^decimal%(%d+,%s*%d+%)$") or value == "bigint" or value == "double" or value == "blob" or value == "timestamp" or value == "date" or value == "json" then return string.upper(value) end
    local textLength = value:match("^text%(%d+%)$")
    if textLength then return "TEXT" end
    error("Unsupported database column type: " .. tostring(columnType), 3)
end

function lia.db.createTable(dbName, primaryKey, schema)
    local d = deferred.new()
    local columns = {}
    local inlinePrimaryKey
    for _, column in ipairs(schema) do
        local normalizedType = normalizeColumnType(column.type, column.length)
        local hasInlinePrimaryKey = normalizedType:find("PRIMARY KEY", 1, true) ~= nil
        if hasInlinePrimaryKey then inlinePrimaryKey = column.name end
        local colDef = lia.db.escapeIdentifier(column.name) .. " " .. normalizedType
        if column.not_null and not hasInlinePrimaryKey then colDef = colDef .. " NOT NULL" end
        if column.default ~= nil and not hasInlinePrimaryKey then colDef = colDef .. " DEFAULT " .. lia.db.convertDataType(column.default) end
        if column.auto_increment and not hasInlinePrimaryKey then
            if lia.db.module == "mysqloo" then
                colDef = colDef .. " AUTO_INCREMENT"
            elseif string.upper(normalizedType) == "INTEGER" then
                colDef = colDef .. " PRIMARY KEY AUTOINCREMENT"
                inlinePrimaryKey = column.name
            end
        end

        columns[#columns + 1] = colDef
    end

    if primaryKey and inlinePrimaryKey and primaryKey ~= inlinePrimaryKey then error("Conflicting database primary key definitions", 2) end
    if primaryKey and primaryKey ~= inlinePrimaryKey then columns[#columns + 1] = "PRIMARY KEY (" .. lia.db.escapeIdentifier(primaryKey) .. ")" end
    local query = "CREATE TABLE IF NOT EXISTS " .. lia.db.escapeIdentifier(prefixTable(dbName, "characters")) .. " (" .. table.concat(columns, ", ") .. ")"
    if lia.db.module == "mysqloo" then query = query .. " ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci" end
    lia.db.query(query, function() d:resolve(true) end, function(err) d:reject(err) end)
    return d
end

lia.db.pendingColumns = lia.db.pendingColumns or {}
function lia.db.createColumn(tableName, columnName, columnType, defaultValue)
    local fullTableName = prefixTable(tableName, "characters")
    local pendingKey = fullTableName .. ":" .. columnName
    if lia.db.pendingColumns[pendingKey] then return lia.db.pendingColumns[pendingKey] end
    local d = deferred.new()
    lia.db.pendingColumns[pendingKey] = d
    local function complete(success, result)
        lia.db.pendingColumns[pendingKey] = nil
        if success then
            d:resolve(result)
        else
            d:reject(result)
        end
    end

    lia.db.fieldExists(fullTableName, columnName):next(function(exists)
        if exists then
            complete(true, false)
            return
        end

        local ok, colDef = pcall(function()
            local definition = lia.db.escapeIdentifier(columnName) .. " " .. normalizeColumnType(columnType)
            if defaultValue ~= nil then definition = definition .. " DEFAULT " .. lia.db.convertDataType(defaultValue) end
            return definition
        end)

        if not ok then
            complete(false, colDef)
            return
        end

        local query = "ALTER TABLE " .. lia.db.escapeIdentifier(fullTableName) .. " ADD COLUMN " .. colDef
        lia.db.query(query, function() complete(true, true) end, function(err)
            if lia.db.module == "mysqloo" and tostring(err):find("Duplicate column name", 1, true) then
                lia.db.fieldExists(fullTableName, columnName):next(function(present) complete(present, present and false or err) end, function(checkErr) complete(false, checkErr) end)
                return
            end

            complete(false, err)
        end)
    end, function(err) complete(false, err) end)
    return d
end

function lia.db.removeTable(tableName)
    local d = deferred.new()
    local fullTableName = prefixTable(tableName, "characters")
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:resolve(false)
            return
        end

        lia.db.query("DROP TABLE " .. lia.db.escapeIdentifier(fullTableName), function() d:resolve(true) end, function(err) d:reject(err) end)
    end, function(err) d:reject(err) end)
    return d
end

function lia.db.removeColumn(tableName, columnName)
    local d = deferred.new()
    local fullTableName = prefixTable(tableName, "characters")
    lia.db.tableExists(fullTableName):next(function(tableExists)
        if not tableExists then
            d:resolve(false)
            return
        end

        lia.db.fieldExists(fullTableName, columnName):next(function(columnExists)
            if not columnExists then
                d:resolve(false)
                return
            end

            local query = "ALTER TABLE " .. lia.db.escapeIdentifier(fullTableName) .. " DROP COLUMN " .. lia.db.escapeIdentifier(columnName)
            lia.db.query(query, function() d:resolve(true) end, function(err) d:reject(err) end)
        end, function(err) d:reject(err) end)
    end, function(err) d:reject(err) end)
    return d
end

local function getTableColumns(tableName, callback, errorCallback)
    if lia.db.module == "mysqloo" then
        local query = "SELECT column_name AS name, column_type AS type FROM information_schema.columns WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_name = " .. lia.db.convertDataType(tableName) .. " ORDER BY ordinal_position"
        lia.db.query(query, callback, errorCallback)
    else
        lia.db.query("PRAGMA table_info(" .. lia.db.escapeIdentifier(tableName) .. ")", callback, errorCallback)
    end
end

function lia.db.getTableColumnInfo(tableName)
    local d = deferred.new()
    getTableColumns(tableName, function(results) d:resolve(results or {}) end, function(err) d:reject(err) end)
    return d
end

function lia.db.getCharacterTable(callback)
    getTableColumns("lia_characters", function(results)
        if not results or #results == 0 then
            safeCallback("getCharacterTable", callback, {})
            return
        end

        local columns = {}
        for _, row in ipairs(results) do
            columns[#columns + 1] = row.name
        end

        safeCallback("getCharacterTable", callback, columns)
    end, function(err)
        databaseLogError("Failed to get character table: " .. tostring(err))
        safeCallback("getCharacterTable", callback, {})
    end)
end

function lia.db.truncate(dbTable)
    local d = deferred.new()
    local tableName = prefixTable(dbTable, "characters")
    local escapedTable = lia.db.escapeIdentifier(tableName)
    if lia.db.module == "mysqloo" then
        lia.db.query("TRUNCATE TABLE " .. escapedTable, function(results, lastID)
            d:resolve({
                results = results,
                lastID = lastID
            })
        end, function(err) d:reject(err) end)
        return d
    end

    lia.db.query("DELETE FROM " .. escapedTable, function(results, lastID)
        lia.db.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'sqlite_sequence'", function(sequenceTable)
            if not sequenceTable or #sequenceTable == 0 then
                d:resolve({
                    results = results,
                    lastID = lastID
                })
                return
            end

            lia.db.query("DELETE FROM sqlite_sequence WHERE name = " .. lia.db.convertDataType(tableName), function()
                d:resolve({
                    results = results,
                    lastID = lastID
                })
            end, function(err) d:reject(err) end)
        end, function(err) d:reject(err) end)
    end, function(err) d:reject(err) end)
    return d
end

local function runQuerySeries(queries, onSuccess, onError)
    local index = 1
    local function nextQuery()
        if index > #queries then
            if onSuccess then onSuccess() end
            return
        end

        local query = queries[index]
        index = index + 1
        lia.db.query(query, function() nextQuery() end, function(err) if onError then onError(err, query) end end)
    end

    nextQuery()
end

local function autoPrimaryKey(name)
    if lia.db.module == "mysqloo" then return lia.db.escapeIdentifier(name) .. " INT NOT NULL AUTO_INCREMENT PRIMARY KEY" end
    return lia.db.escapeIdentifier(name) .. " INTEGER PRIMARY KEY AUTOINCREMENT"
end

local function schemaQueries()
    local q = lia.db.escapeIdentifier
    local textDefault = lia.db.module == "mysqloo" and "TEXT NOT NULL" or "TEXT NOT NULL DEFAULT ''"
    local queries = {"CREATE TABLE IF NOT EXISTS " .. q("lia_players") .. " (" .. q("steamID") .. " VARCHAR(255), " .. q("steamName") .. " VARCHAR(255), " .. q("firstJoin") .. " DATETIME, " .. q("lastJoin") .. " DATETIME, " .. q("userGroup") .. " VARCHAR(255), " .. q("data") .. " TEXT, " .. q("lastIP") .. " VARCHAR(255), " .. q("lastOnline") .. " INTEGER, " .. q("totalOnlineTime") .. " FLOAT)", "CREATE TABLE IF NOT EXISTS " .. q("lia_chardata") .. " (" .. q("charID") .. " INTEGER NOT NULL, " .. q("key") .. " VARCHAR(255) NOT NULL, " .. q("value") .. " TEXT, PRIMARY KEY (" .. q("charID") .. ", " .. q("key") .. "))", "CREATE TABLE IF NOT EXISTS " .. q("lia_characters") .. " (" .. autoPrimaryKey("id") .. ", " .. q("steamID") .. " VARCHAR(255), " .. q("name") .. " VARCHAR(255), " .. q("desc") .. " TEXT, " .. q("model") .. " VARCHAR(255), " .. q("attribs") .. " TEXT, " .. q("schema") .. " VARCHAR(255), " .. q("createTime") .. " DATETIME, " .. q("lastJoinTime") .. " DATETIME, " .. q("money") .. " VARCHAR(255), " .. q("faction") .. " VARCHAR(255), " .. q("recognition") .. " " .. textDefault .. ", " .. q("fakenames") .. " " .. textDefault .. ")", "CREATE TABLE IF NOT EXISTS " .. q("lia_inventories") .. " (" .. autoPrimaryKey("invID") .. ", " .. q("charID") .. " INTEGER, " .. q("invType") .. " VARCHAR(255))", "CREATE TABLE IF NOT EXISTS " .. q("lia_items") .. " (" .. autoPrimaryKey("itemID") .. ", " .. q("invID") .. " INTEGER, " .. q("uniqueID") .. " VARCHAR(255), " .. q("data") .. " TEXT, " .. q("quantity") .. " INTEGER, " .. q("x") .. " INTEGER, " .. q("y") .. " INTEGER)", "CREATE TABLE IF NOT EXISTS " .. q("lia_invdata") .. " (" .. q("invID") .. " INTEGER, " .. q("key") .. " VARCHAR(255), " .. q("value") .. " TEXT, FOREIGN KEY(" .. q("invID") .. ") REFERENCES " .. q("lia_inventories") .. "(" .. q("invID") .. "), PRIMARY KEY (" .. q("invID") .. ", " .. q("key") .. "))", "CREATE TABLE IF NOT EXISTS " .. q("lia_logs") .. " (" .. autoPrimaryKey("id") .. ", " .. q("timestamp") .. " DATETIME, " .. q("gamemode") .. " VARCHAR(255), " .. q("category") .. " VARCHAR(255), " .. q("message") .. " TEXT, " .. q("charID") .. " INTEGER, " .. q("steamID") .. " VARCHAR(255))", "CREATE TABLE IF NOT EXISTS " .. q("lia_ticketclaims") .. " (" .. q("timestamp") .. " DATETIME, " .. q("requester") .. " TEXT, " .. q("requesterSteamID") .. " TEXT, " .. q("admin") .. " TEXT, " .. q("adminSteamID") .. " TEXT, " .. q("message") .. " TEXT)", "CREATE TABLE IF NOT EXISTS " .. q("lia_warnings") .. " (" .. autoPrimaryKey("id") .. ", " .. q("charID") .. " INTEGER, " .. q("warned") .. " TEXT, " .. q("warnedSteamID") .. " TEXT, " .. q("timestamp") .. " DATETIME, " .. q("message") .. " TEXT, " .. q("warner") .. " TEXT, " .. q("warnerSteamID") .. " TEXT, " .. q("severity") .. " VARCHAR(255) DEFAULT 'Medium')", "CREATE TABLE IF NOT EXISTS " .. q("lia_permakills") .. " (" .. autoPrimaryKey("id") .. ", " .. q("player") .. " VARCHAR(255) NOT NULL, " .. q("reason") .. " VARCHAR(255), " .. q("steamID") .. " VARCHAR(255), " .. q("charID") .. " INTEGER, " .. q("submitterName") .. " VARCHAR(255), " .. q("submitterSteamID") .. " VARCHAR(255), " .. q("timestamp") .. " INTEGER, " .. q("evidence") .. " VARCHAR(255))", "CREATE TABLE IF NOT EXISTS " .. q("lia_bans") .. " (" .. autoPrimaryKey("id") .. ", " .. q("player") .. " VARCHAR(255) NOT NULL, " .. q("playerSteamID") .. " VARCHAR(255), " .. q("reason") .. " VARCHAR(255), " .. q("bannerName") .. " VARCHAR(255), " .. q("bannerSteamID") .. " VARCHAR(255), " .. q("timestamp") .. " INTEGER, " .. q("evidence") .. " VARCHAR(255))", "CREATE TABLE IF NOT EXISTS " .. q("lia_staffactions") .. " (" .. autoPrimaryKey("id") .. ", " .. q("player") .. " VARCHAR(255) NOT NULL, " .. q("playerSteamID") .. " VARCHAR(255), " .. q("steamID") .. " VARCHAR(255), " .. q("action") .. " VARCHAR(255), " .. q("staffName") .. " VARCHAR(255), " .. q("staffSteamID") .. " VARCHAR(255), " .. q("timestamp") .. " INTEGER)", "CREATE TABLE IF NOT EXISTS " .. q("lia_doors") .. " (" .. q("gamemode") .. " VARCHAR(255), " .. q("map") .. " VARCHAR(255), " .. q("id") .. " INTEGER, " .. q("factions") .. " TEXT, " .. q("classes") .. " TEXT, " .. q("disabled") .. " INTEGER, " .. q("hidden") .. " INTEGER, " .. q("ownable") .. " INTEGER, " .. q("name") .. " TEXT, " .. q("price") .. " INTEGER, " .. q("locked") .. " INTEGER, PRIMARY KEY (" .. q("gamemode") .. ", " .. q("map") .. ", " .. q("id") .. "))", "CREATE TABLE IF NOT EXISTS " .. q("lia_persistence") .. " (" .. autoPrimaryKey("id") .. ", " .. q("gamemode") .. " TEXT, " .. q("map") .. " TEXT, " .. q("class") .. " TEXT, " .. q("pos") .. " TEXT, " .. q("angles") .. " TEXT, " .. q("model") .. " TEXT, " .. q("data") .. " TEXT)", "CREATE TABLE IF NOT EXISTS " .. q("lia_saveditems") .. " (" .. autoPrimaryKey("id") .. ", " .. q("schema") .. " TEXT, " .. q("map") .. " TEXT, " .. q("itemID") .. " INTEGER, " .. q("pos") .. " TEXT, " .. q("angles") .. " TEXT)", "CREATE TABLE IF NOT EXISTS " .. q("lia_admin") .. " (" .. q("usergroup") .. " VARCHAR(255) PRIMARY KEY, " .. q("privileges") .. " TEXT, " .. q("inheritance") .. " TEXT, " .. q("types") .. " TEXT)"}
    if lia.db.module == "mysqloo" then
        for i = 1, #queries do
            queries[i] = queries[i] .. " ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
        end
    end
    return queries
end

function lia.db.wipeTables(callback)
    local wipedTables = {}
    lia.db.getTables():next(function(tables)
        if #tables == 0 then
            if isfunction(callback) then safeCallback("wipeTables", callback) end
            return
        end

        local drops = {}
        for _, tableName in ipairs(tables) do
            wipedTables[#wipedTables + 1] = tableName
            drops[#drops + 1] = "DROP TABLE IF EXISTS " .. lia.db.escapeIdentifier(tableName)
        end

        local function finish()
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[Database]", Color(255, 255, 255), "ALL LILIA DATA HAS BEEN WIPED\n")
            if #wipedTables > 0 then MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Wiped tables: %s", table.concat(wipedTables, ", ")) .. "\n") end
            if isfunction(callback) then safeCallback("wipeTables", callback) end
        end

        if lia.db.module == "mysqloo" then
            lia.db.query("SET FOREIGN_KEY_CHECKS = 0", function()
                runQuerySeries(drops, function()
                    lia.db.query("SET FOREIGN_KEY_CHECKS = 1", finish, function(err)
                        databaseLogError(err)
                        finish()
                    end)
                end, function(err) lia.db.query("SET FOREIGN_KEY_CHECKS = 1", function() databaseLogError(err) end, function() databaseLogError(err) end) end)
            end, function(err) databaseLogError(err) end)
        else
            runQuerySeries(drops, finish, function(err) databaseLogError(err) end)
        end
    end, function(err) databaseLogError(err) end)
end

function lia.db.loadTables()
    if lia.db.tablesLoading then return end
    lia.db.tablesLoading = true
    lia.db.tablesLoaded = false
    runQuerySeries(schemaQueries(), function()
        lia.db.addDatabaseFields():next(function()
            local function ready()
                lia.db.tablesLoading = false
                lia.db.tablesLoaded = true
                hook.Run("OnDatabaseLoaded")
                timer.Simple(0, function() lia.config.load() end)
                timer.Simple(0.1, function()
                    lia.config.send()
                    lia.playerinteract.sync()
                    lia.item.loadWeaponOverrides()
                    lia.item.loadWeaponRuntimeOverrides()
                end)
            end

            lia.db.ensureIndexes():next(ready, function(err)
                databaseLogError("Failed to ensure database indexes: " .. tostring(err))
                ready()
            end)
        end, function(err)
            lia.db.tablesLoading = false
            databaseLogError("Failed to initialize database columns: " .. tostring(err))
        end)
    end, function(err, query)
        lia.db.tablesLoading = false
        databaseLogError("Failed to load database tables: " .. tostring(err) .. " | Query: " .. tostring(query))
    end)

    hook.Run("OnLoadTables")
end

function lia.db.waitForTablesToLoad()
    local d = deferred.new()
    if lia.db.tablesLoaded then
        d:resolve()
    else
        local id = tostring(tableWaitID)
        hook.Add("OnDatabaseLoaded", id, function()
            hook.Remove("OnDatabaseLoaded", id)
            d:resolve()
        end)
    end

    tableWaitID = tableWaitID + 1
    return d
end

function lia.db.addDatabaseFields()
    local d = deferred.new()
    local columns = {}
    local supportedTypes = {
        string = true,
        integer = true,
        int = true,
        float = true,
        boolean = true,
        datetime = true,
        text = true
    }

    for _, data in pairs(lia.char.vars or {}) do
        if data.field and supportedTypes[data.fieldType] then
            columns[#columns + 1] = {
                tableName = "characters",
                name = data.field,
                columnType = data.fieldType == "string" and "VARCHAR(" .. tostring(tonumber(data.length) or 255) .. ")" or data.fieldType,
                default = data.default
            }
        end
    end

    columns[#columns + 1] = {
        tableName = "warnings",
        name = "severity",
        columnType = "string",
        default = "Medium"
    }

    local index = 1
    local function nextColumn()
        local column = columns[index]
        if not column then
            d:resolve(true)
            return
        end

        index = index + 1
        lia.db.createColumn(column.tableName, column.name, column.columnType, column.default):next(nextColumn, function(err) d:reject("Failed to add " .. column.tableName .. "." .. column.name .. ": " .. tostring(err)) end)
    end

    nextColumn()
    return d
end

local function mysqlIndexExists(tableName, indexName, callback, errorCallback)
    local query = "SELECT 1 AS found FROM information_schema.statistics WHERE table_schema = " .. schemaDatabaseValue() .. " AND table_name = " .. lia.db.convertDataType(tableName) .. " AND index_name = " .. lia.db.convertDataType(indexName) .. " LIMIT 1"
    lia.db.query(query, function(results) callback(istable(results) and #results > 0) end, errorCallback)
end

function lia.db.ensureIndexes()
    local d = deferred.new()
    local indexes = {
        {
            name = "idx_lia_players_steamID",
            tableName = "lia_players",
            columns = {"steamID"}
        },
        {
            name = "idx_lia_characters_steamID_schema",
            tableName = "lia_characters",
            columns = {"steamID", "schema"}
        },
        {
            name = "idx_lia_inventories_charID",
            tableName = "lia_inventories",
            columns = {"charID"}
        },
        {
            name = "idx_lia_items_invID",
            tableName = "lia_items",
            columns = {"invID"}
        }
    }

    local index = 1
    local function nextIndex()
        if index > #indexes then
            d:resolve(true)
            return
        end

        local definition = indexes[index]
        index = index + 1
        local columns = {}
        for _, column in ipairs(definition.columns) do
            columns[#columns + 1] = lia.db.escapeIdentifier(column)
        end

        local createQuery = "CREATE INDEX " .. lia.db.escapeIdentifier(definition.name) .. " ON " .. lia.db.escapeIdentifier(definition.tableName) .. "(" .. table.concat(columns, ", ") .. ")"
        if lia.db.module == "mysqloo" then
            mysqlIndexExists(definition.tableName, definition.name, function(exists)
                if exists then
                    nextIndex()
                else
                    lia.db.query(createQuery, function() nextIndex() end, function(err) d:reject(err) end)
                end
            end, function(err) d:reject(err) end)
        else
            lia.db.query("CREATE INDEX IF NOT EXISTS " .. lia.db.escapeIdentifier(definition.name) .. " ON " .. lia.db.escapeIdentifier(definition.tableName) .. "(" .. table.concat(columns, ", ") .. ")", function() nextIndex() end, function(err) d:reject(err) end)
        end
    end

    nextIndex()
    return d
end

function lia.db.createSnapshot(tableName)
    local d = deferred.new()
    local fullTableName = prefixTable(tableName, "characters")
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:reject("Table " .. fullTableName .. " does not exist")
            return
        end

        lia.db.query("SELECT * FROM " .. lia.db.escapeIdentifier(fullTableName), function(results)
            if results == nil then results = {} end
            if not istable(results) then
                d:reject("Failed to query table " .. fullTableName)
                return
            end

            local snapshot = {
                table = tableName,
                timestamp = os.time(),
                data = results
            }

            local jsonData = util.TableToJSON(snapshot, true)
            local fileName = "snapshot_" .. tableName .. "_" .. os.time() .. ".json"
            local filePath = "lilia/snapshots/" .. fileName
            file.CreateDir("lilia/snapshots")
            file.Write(filePath, jsonData)
            d:resolve({
                file = fileName,
                path = filePath,
                records = #results
            })
        end, function(err) d:reject("Database Error " .. tostring(err)) end)
    end, function(err) d:reject("Table check error: " .. tostring(err)) end)
    return d
end

function lia.db.loadSnapshot(fileName)
    local d = deferred.new()
    local filePath = "lilia/snapshots/" .. fileName
    if not file.Exists(filePath, "DATA") then
        d:reject("Snapshot file " .. fileName .. " not found")
        return d
    end

    local jsonData = file.Read(filePath, "DATA")
    if not jsonData then
        d:reject("Failed to read snapshot file")
        return d
    end

    local success, snapshot = pcall(util.JSONToTable, jsonData)
    if not success then
        d:reject(string.format("Failed to parse JSON data: %s", tostring(snapshot)))
        return d
    end

    if not snapshot.table or not snapshot.data then
        d:reject("Invalid snapshot format")
        return d
    end

    local fullTableName = prefixTable(snapshot.table, "characters")
    lia.db.tableExists(fullTableName):next(function(exists)
        if not exists then
            d:reject("Target table " .. fullTableName .. " does not exist")
            return
        end

        lia.db.query("DELETE FROM " .. lia.db.escapeIdentifier(fullTableName), function()
            if #snapshot.data == 0 then
                d:resolve({
                    table = snapshot.table,
                    records = 0
                })
                return
            end

            local batchSize = 100
            local index = 1
            local function insertNextBatch()
                if index > #snapshot.data then
                    d:resolve({
                        table = snapshot.table,
                        records = #snapshot.data,
                        timestamp = snapshot.timestamp
                    })
                    return
                end

                local batch = {}
                local last = math.min(index + batchSize - 1, #snapshot.data)
                for rowIndex = index, last do
                    batch[#batch + 1] = snapshot.data[rowIndex]
                end

                index = last + 1
                lia.db.bulkInsert(snapshot.table, batch):next(function() insertNextBatch() end, function(err) d:reject("Failed to insert snapshot batch: " .. tostring(err)) end)
            end

            insertNextBatch()
        end, function(err) d:reject("Failed To Clear Table " .. tostring(err)) end)
    end, function(err) d:reject("Table check error: " .. tostring(err)) end)
    return d
end

function GM:SetupDatabase()
    local defaults = {
        module = "sqlite",
        hostname = "127.0.0.1",
        username = "",
        password = "",
        database = "",
        port = 3306
    }

    for key, value in pairs(defaults) do
        lia.db[key] = value
    end

    local databasePath = engine.ActiveGamemode() .. "/schema/database.lua"
    if file.Exists(databasePath, "LUA") then
        local databaseConfig = include(databasePath)
        if databaseConfig then
            lia.db.config = databaseConfig
            for key, value in pairs(databaseConfig) do
                lia.db[key] = value
            end
        end
    end
end

function GM:DatabaseConnected()
    lia.bootstrap("Database", string.format("Lilia has connected to the database. We are using %s!", lia.db.module))
end

concommand.Add("lia_snapshot", function(client, _, args)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    if not args[1] then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_snapshot <table_name>\n")
        return
    end

    local tableName = args[1]
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Creating snapshot for table: %s", tableName) .. "\n")
    lia.db.createSnapshot(tableName):next(function(snapshot)
        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Snapshot created successfully!\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Records: %s", snapshot.records) .. "\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Path: %s", snapshot.path) .. "\n")
    end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Snapshot failed: %s", tostring(err)) .. "\n") end)
end)

concommand.Add("lia_snapshot_load", function(client, _, args)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    if not args[1] then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_snapshot_load <filename>\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "Available snapshots:\n")
        local files = file.Find("lilia/snapshots/*", "DATA")
        if #files == 0 then
            MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), "No snapshots found\n")
        else
            for _, name in ipairs(files) do
                MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "  - " .. name .. "\n")
            end
        end
        return
    end

    local fileName = args[1]
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Loading snapshot: %s", fileName) .. "\n")
    lia.db.loadSnapshot(fileName):next(function(result)
        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Snapshot loaded successfully!\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Table: %s", result.table) .. "\n")
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Records: %s", result.records) .. "\n")
    end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Snapshot load failed: %s", tostring(err)) .. "\n") end)
end)

concommand.Add("lia_wipetable", function(client, _, args)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    if not args[1] then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_wipetable <table_name>\n")
        return
    end

    local tableName = args[1]
    local fullTableName = prefixTable(tableName, "characters")
    MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), string.format("Creating backup before wiping table: %s", tableName) .. "\n")
    lia.db.createSnapshot(tableName):next(function(snapshot)
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Backup created: %s", snapshot.file) .. "\n")
        MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), string.format("Wiping table: %s", fullTableName) .. "\n")
        lia.db.truncate(tableName):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Table %s has been wiped successfully!", fullTableName) .. "\n") end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Failed to wipe table: %s", tostring(err)) .. "\n") end)
    end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Backup failed, aborting wipe: %s", tostring(err)) .. "\n") end)
end)

concommand.Add("lia_wipedb", function(client)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    lia.db.wipeTables(function()
        lia.information("Database Wiped")
        lia.db.loadTables()
        hook.Add("PostLoadData", "lia_wipedb_changemap", function()
            hook.Remove("PostLoadData", "lia_wipedb_changemap")
            timer.Simple(2.5, function()
                lia.information("Database wipe complete. Changing map...")
                RunConsoleCommand("changelevel", game.GetMap())
            end)
        end)
    end)
end)
