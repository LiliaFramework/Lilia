lia.db = lia.db or {}
lia.db.queryQueue = lia.db.queue or {}
lia.db.prepared = lia.db.prepared or {}
MYSQLOO_QUEUE = MYSQLOO_QUEUE or {}
PREPARE_CACHE = {}
MYSQLOO_INTEGER = 0
MYSQLOO_STRING = 1
MYSQLOO_BOOL = 2
local modules = {}
local function ThrowQueryFault(query, fault)
    if string.find(fault, "duplicate column name:") or string.find(fault, "UNIQUE constraint failed: lia_config") then return end
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " * " .. query .. "\n")
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. fault .. "\n")
end

local function ThrowConnectionFault(fault)
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. L("dbConnectionFail") .. "\n")
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. fault .. "\n")
    setNetVar("dbError", fault)
end

local function promisifyIfNoCallback(queryHandler)
    return function(query, callback)
        local d
        local function throw(err)
            if d then
                d:reject(err)
            else
                ThrowQueryFault(query, err)
            end
        end

        if not isfunction(callback) then
            d = deferred.new()
            callback = function(results, lastID)
                d:resolve({
                    results = results,
                    lastID = lastID
                })
            end
        end

        queryHandler(query, callback, throw)
        return d
    end
end

modules.sqlite = {
    query = promisifyIfNoCallback(function(query, callback, throw)
        local data = sql.Query(query)
        local err = sql.LastError()
        if data == false then throw(err) end
        if callback then
            local lastID = tonumber(sql.QueryValue("SELECT last_insert_rowid()"))
            callback(data, lastID)
        end
    end),
    escape = function(value) return sql.SQLStr(value, true) end,
    connect = function(callback)
        lia.db.query = modules.sqlite.query
        if callback then callback() end
    end
}

modules.mysqloo = {
    query = promisifyIfNoCallback(function(query, callback, throw)
        if lia.db.getObject and lia.db.getObject() then
            local object = lia.db.getObject():query(query)
            if callback then
                function object:onSuccess(data)
                    callback(data, self:lastInsert())
                end
            end

            function object:onError(fault)
                if lia.db.getObject():status() == mysqloo.DATABASE_NOT_CONNECTED then
                    lia.db.queryQueue[#lia.db.queryQueue + 1] = {query, callback}
                    lia.db.connect(nil, true)
                    return
                end

                throw(fault)
            end

            object:start()
        else
            lia.db.queryQueue[#lia.db.queryQueue + 1] = {query, callback}
        end
    end),
    escape = function(value)
        local object = lia.db.getObject and lia.db.getObject()
        if object then
            return object:escape(value)
        else
            return sql.SQLStr(value, true)
        end
    end,
    queue = function()
        local count = 0
        for _, v in pairs(lia.db.pool) do
            count = count + v:queueSize()
        end
        return count
    end,
    abort = function()
        for _, v in pairs(lia.db.pool) do
            v:abortAllQueries()
        end
    end,
    getObject = function()
        local lowest = nil
        local lowestCount = 0
        local lowestIndex = 0
        for k, db in pairs(lia.db.pool) do
            local queueSize = db:queueSize()
            if not lowest or queueSize < lowestCount then
                lowest = db
                lowestCount = queueSize
                lowestIndex = k
            end
        end

        if not lowest then error(L("dbPoolFail")) end
        return lowest, lowestIndex
    end,
    connect = function(callback)
        if not pcall(require, "mysqloo") then return setNetVar("dbError", system.IsWindows() and L("missingVcRedistributables") or L("missingMysqlooBinaries")) end
        if mysqloo.VERSION ~= "9" or not mysqloo.MINOR_VERSION or tonumber(mysqloo.MINOR_VERSION) < 1 then
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. L("mysqlooOutdated") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. L("mysqlooDownload") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), " " .. L("mysqlooDownloadURL") .. "\n")
            return
        end

        local hostname = lia.db.hostname
        local username = lia.db.username
        local password = lia.db.password
        local database = lia.db.database
        local port = lia.db.port
        mysqloo.connect(hostname, username, password, database, port)
        lia.db.pool = {}
        local poolNum = 6
        local connectedPools = 0
        for i = 1, poolNum do
            lia.db.pool[i] = mysqloo.connect(hostname, username, password, database, port)
            local pool = lia.db.pool[i]
            pool:setAutoReconnect(true)
            pool:connect()
            function pool:onConnectionFailed(fault)
                ThrowConnectionFault(fault)
            end

            function pool:onConnected()
                pool:setCharacterSet("utf8")
                connectedPools = connectedPools + 1
                if connectedPools == poolNum then
                    lia.db.escape = modules.mysqloo.escape
                    lia.db.query = modules.mysqloo.query
                    lia.db.prepare = modules.mysqloo.prepare
                    lia.db.abort = modules.mysqloo.abort
                    lia.db.queue = modules.mysqloo.queue
                    lia.db.getObject = modules.mysqloo.getObject
                    lia.db.preparedCall = modules.mysqloo.preparedCall
                    if callback then callback() end
                    hook.Run("OnMySQLOOConnected")
                end
            end

            timer.Create("liaMySQLWakeUp" .. i, 600 + i, 0, function() pool:query("SELECT 1 + 1") end)
        end

        lia.db.object = lia.db.pool
    end,
    prepare = function(key, str, values)
        lia.db.prepared[key] = {
            query = str,
            values = values,
        }
    end,
    preparedCall = function(key, callback, ...)
        local preparedStatement = lia.db.prepared[key]
        if preparedStatement then
            local _, freeIndex = lia.db.getObject()
            PREPARE_CACHE[key] = PREPARE_CACHE[key] or {}
            PREPARE_CACHE[key][freeIndex] = PREPARE_CACHE[key][freeIndex] or lia.db.getObject():prepare(preparedStatement.query)
            local prepObj = PREPARE_CACHE[key][freeIndex]
            function prepObj:onSuccess(data)
                if callback then callback(data, self:lastInsert()) end
            end

            function prepObj:onError(err)
                ServerLog(err)
            end

            local arguments = {...}
            if table.Count(arguments) == table.Count(preparedStatement.values) then
                local index = 1
                for _, type in pairs(preparedStatement.values) do
                    if type == MYSQLOO_INTEGER then
                        prepObj:setNumber(index, arguments[index])
                    elseif type == MYSQLOO_STRING then
                        prepObj:setString(index, lia.db.convertDataType(arguments[index], true))
                    elseif type == MYSQLOO_BOOL then
                        prepObj:setBoolean(index, arguments[index])
                    end

                    index = index + 1
                end
            end

            prepObj:start()
        else
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), L("invalidPreparedStatement", key) .. "\n")
        end
    end
}

lia.db.escape = lia.db.escape or modules.sqlite.escape
lia.db.query = lia.db.query or function(...) lia.db.queryQueue[#lia.db.queryQueue + 1] = {...} end
function lia.db.connect(callback, reconnect)
    local dbModule = modules[lia.db.module]
    if dbModule then
        if (reconnect or not lia.db.connected) and not lia.db.object then
            dbModule.connect(function()
                lia.db.connected = true
                if isfunction(callback) then callback() end
                for i = 1, #lia.db.queryQueue do
                    lia.db.query(unpack(lia.db.queryQueue[i]))
                end

                lia.db.queryQueue = {}
            end)
        end

        lia.db.escape = dbModule.escape
        lia.db.query = dbModule.query
    else
        lia.error(L("invalidStorageModule", lia.db.module or "Unavailable"))
    end
end

function lia.db.wipeTables(callback)
    local function realCallback()
        if lia.db.module == "mysqloo" then
            lia.db.query("SET FOREIGN_KEY_CHECKS = 1;", function()
                MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), L("dataWiped") .. "\n")
                if isfunction(callback) then callback() end
            end)
        else
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(0, 255, 0), "[" .. L("database") .. "]", Color(255, 255, 255), L("dataWiped") .. "\n")
            if isfunction(callback) then callback() end
        end
    end

    if lia.db.module == "mysqloo" then
        local function startDeleting()
            lia.db.query("SHOW TABLES LIKE 'lia\\_%';", function(data)
                data = data or {}
                local remaining = #data
                if remaining == 0 then
                    realCallback()
                    return
                end

                for _, row in ipairs(data) do
                    local tableName = row[1] or row[next(row)]
                    lia.db.query("DROP TABLE IF EXISTS `" .. tableName .. "`;", function()
                        remaining = remaining - 1
                        if remaining <= 0 then realCallback() end
                    end)
                end
            end)
        end

        lia.db.query("SET FOREIGN_KEY_CHECKS = 0;", startDeleting)
    else
        lia.db.query([[SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'lia_%';]], function(data)
            data = data or {}
            local remaining = #data
            if remaining == 0 then
                realCallback()
                return
            end

            for _, row in ipairs(data) do
                local tableName = row.name or row[1]
                lia.db.query("DROP TABLE IF EXISTS " .. tableName .. ";", function()
                    remaining = remaining - 1
                    if remaining <= 0 then realCallback() end
                end)
            end
        end)
    end
end

function lia.db.loadTables()
    local function done()
        lia.db.addDatabaseFields()
        lia.db.tablesLoaded = true
        hook.Run("LiliaTablesLoaded")
        hook.Run("OnDatabaseLoaded")
    end

    if lia.db.module == "sqlite" then
        lia.db.query([[
CREATE TABLE IF NOT EXISTS lia_players (
    steamID varchar,
    steamName varchar,
    firstJoin datetime,
    lastJoin datetime,
    userGroup varchar,
    data varchar,
    lastIP varchar,
    lastOnline integer,
    totalOnlineTime float
);
CREATE TABLE IF NOT EXISTS lia_chardata (
    charID integer not null,
    key varchar(255) not null,
    value text(1024),
    PRIMARY KEY (charID, key)
);
CREATE TABLE IF NOT EXISTS lia_characters (
    id integer primary key autoincrement,
    steamID varchar,
    name varchar,
    desc varchar,
    model varchar,
    attribs varchar,
    schema varchar,
    createTime datetime,
    lastJoinTime datetime,
    money varchar,
    faction varchar,
    recognition text not null default '',
    fakenames text not null default ''
);
CREATE TABLE IF NOT EXISTS lia_inventories (
    invID integer primary key autoincrement,
    charID integer,
    _invType varchar
);
CREATE TABLE IF NOT EXISTS lia_items (
    _itemID integer primary key autoincrement,
    invID integer,
    uniqueID varchar,
    data varchar,
    quantity integer,
    x integer,
    y integer
);
CREATE TABLE IF NOT EXISTS lia_invdata (
    invID integer,
    key text,
    value text,
    FOREIGN KEY(invID) REFERENCES lia_inventories(invID),
    PRIMARY KEY (invID, key)
);
CREATE TABLE IF NOT EXISTS lia_config (
    schema text,
    key text,
    value text,
    PRIMARY KEY (schema, key)
);
CREATE TABLE IF NOT EXISTS lia_logs (
    id integer primary key autoincrement,
    timestamp datetime,
    gamemode varchar,
    category varchar,
    message text,
    charID integer,
    steamID varchar
);
CREATE TABLE IF NOT EXISTS lia_ticketclaims (
    timestamp datetime,
    requester text,
    requesterSteamID text,
    admin text,
    adminSteamID text,
    message text
);
CREATE TABLE IF NOT EXISTS lia_warnings (
    id integer primary key autoincrement,
    charID integer,
    warned text,
    warnedSteamID text,
    timestamp datetime,
    message text,
    warner text,
    warnerSteamID text
);
CREATE TABLE IF NOT EXISTS lia_permakills (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    reason varchar(255),
    steamID varchar(255),
    charID integer,
    submitterName varchar(255),
    submitterSteamID varchar(255),
    timestamp integer,
    evidence varchar(255)
);
CREATE TABLE IF NOT EXISTS lia_bans (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    playerSteamID varchar(255),
    reason varchar(255),
    bannerName varchar(255),
    bannerSteamID varchar(255),
    timestamp integer,
    evidence varchar(255)
);
CREATE TABLE IF NOT EXISTS lia_staffactions (
    id integer primary key autoincrement,
    player varchar(255) NOT NULL,
    playerSteamID varchar(255),
    steamID varchar(255),
    action varchar(255),
    staffName varchar(255),
    staffSteamID varchar(255),
    timestamp integer
);
CREATE TABLE IF NOT EXISTS lia_doors (
    gamemode text,
    map text,
    id integer,
    factions text,
    classes text,
    disabled integer,
    hidden integer,
    ownable integer,
    name text,
    price integer,
    locked integer,
    children text,
    PRIMARY KEY (gamemode, map, id)
);
CREATE TABLE IF NOT EXISTS lia_persistence (
    id integer primary key autoincrement,
    gamemode text,
    map text,
    class text,
    pos text,
    angles text,
    model text
);
CREATE TABLE IF NOT EXISTS lia_saveditems (
    id integer primary key autoincrement,
    schema text,
    map text,
    _itemID integer,
    _pos text,
    _angles text
);
CREATE TABLE IF NOT EXISTS lia_admin (
    usergroup text PRIMARY KEY,
    privileges text,
    inheritance text,
    types text
);
CREATE TABLE IF NOT EXISTS lia_data (
    gamemode text,
    map text,
    data text,
    PRIMARY KEY (gamemode, map)
);
]], done)
    else
        local queries = string.Explode(";", [[
CREATE TABLE IF NOT EXISTS `lia_players` (
    `steamID` varchar(20) not null collate 'utf8mb4_general_ci',
    `steamName` varchar(32) not null collate 'utf8mb4_general_ci',
    `firstJoin` datetime,
    `lastJoin` datetime,
    `userGroup` varchar(32) default null collate 'utf8mb4_general_ci',
    `data` varchar(255) not null collate 'utf8mb4_general_ci',
    `lastIP` varchar(64) default null collate 'utf8mb4_general_ci',
    `lastOnline` int(32) default 0,
    `totalOnlineTime` float default 0,
    primary key (`steamID`)
);
CREATE TABLE IF NOT EXISTS `lia_chardata` (
    `charID` int not null,
    `key` varchar(255) not null collate 'utf8mb4_general_ci',
    `value` text collate 'utf8mb4_general_ci',
    primary key (`charID`,`key`)
);
CREATE TABLE IF NOT EXISTS `lia_characters` (
    `id` int not null auto_increment,
    `steamID` varchar(20) not null collate 'utf8mb4_general_ci',
    `name` varchar(70) not null collate 'utf8mb4_general_ci',
    `desc` varchar(512) not null collate 'utf8mb4_general_ci',
    `model` varchar(255) not null collate 'utf8mb4_general_ci',
    `attribs` varchar(512) default null collate 'utf8mb4_general_ci',
    `schema` varchar(24) not null collate 'utf8mb4_general_ci',
    `createTime` datetime not null,
    `lastJoinTime` datetime not null,
    `money` int(10) unsigned default 0,
    `faction` varchar(255) default null collate 'utf8mb4_general_ci',
    `recognition` text collate 'utf8mb4_general_ci',
    `fakenames` text collate 'utf8mb4_general_ci',
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_inventories` (
    `invID` int not null auto_increment,
    `charID` int default null,
    `_invType` varchar(24) default null collate 'utf8mb4_general_ci',
    primary key (`invID`)
);
CREATE TABLE IF NOT EXISTS `lia_items` (
    `_itemID` int not null auto_increment,
    `invID` int default null,
    `uniqueID` varchar(60) not null collate 'utf8mb4_general_ci',
    `data` varchar(512) default null collate 'utf8mb4_general_ci',
    `quantity` int,
    `x` int,
    `y` int,
    primary key (`_itemID`)
);
CREATE TABLE IF NOT EXISTS `lia_invdata` (
    `invID` int not null,
    `key` varchar(32) not null collate 'utf8mb4_general_ci',
    `value` varchar(255) not null collate 'utf8mb4_general_ci',
    foreign key (`invID`) references lia_inventories(invID) on delete cascade,
    primary key (`invID`,`key`)
);
CREATE TABLE IF NOT EXISTS `lia_config` (
    `schema` varchar(24) not null collate 'utf8mb4_general_ci',
    `key` varchar(64) not null collate 'utf8mb4_general_ci',
    `value` text not null collate 'utf8mb4_general_ci',
    primary key (`schema`,`key`)
);
CREATE TABLE IF NOT EXISTS `lia_logs` (
    `id` int not null auto_increment,
    `timestamp` datetime not null,
    `gamemode` varchar(50) not null collate 'utf8mb4_general_ci',
    `category` varchar(255) not null collate 'utf8mb4_general_ci',
    `message` text not null collate 'utf8mb4_general_ci',
    `charID` int default null,
    `steamID` varchar(20) collate 'utf8mb4_general_ci',
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_ticketclaims` (
    `timestamp` datetime not null,
    `requester` varchar(64) not null collate 'utf8mb4_general_ci',
    `requesterSteamID` varchar(64) not null collate 'utf8mb4_general_ci',
    `admin` varchar(64) not null collate 'utf8mb4_general_ci',
    `adminSteamID` varchar(64) not null collate 'utf8mb4_general_ci',
    `message` text collate 'utf8mb4_general_ci'
);
CREATE TABLE IF NOT EXISTS `lia_warnings` (
    `id` int not null auto_increment,
    `charID` int default null,
    `warned` text collate 'utf8mb4_general_ci',
    `warnedSteamID` varchar(64) default null collate 'utf8mb4_general_ci',
    `timestamp` datetime not null,
    `message` text collate 'utf8mb4_general_ci',
    `warner` text collate 'utf8mb4_general_ci',
    `warnerSteamID` varchar(64) default null collate 'utf8mb4_general_ci',
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_permakills` (
    `id` int not null auto_increment,
    `player` varchar(255) not null collate 'utf8mb4_general_ci',
    `reason` varchar(255) default null collate 'utf8mb4_general_ci',
    `steamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `charID` int default null,
    `submitterName` varchar(255) default null collate 'utf8mb4_general_ci',
    `submitterSteamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `timestamp` int default null,
    `evidence` varchar(255) default null collate 'utf8mb4_general_ci',
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_bans` (
    `id` int not null auto_increment,
    `player` varchar(255) not null collate 'utf8mb4_general_ci',
    `playerSteamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `reason` varchar(255) default null collate 'utf8mb4_general_ci',
    `bannerName` varchar(255) default null collate 'utf8mb4_general_ci',
    `bannerSteamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `timestamp` int default null,
    `evidence` varchar(255) default null collate 'utf8mb4_general_ci',
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_staffactions` (
    `id` int not null auto_increment,
    `player` varchar(255) not null collate 'utf8mb4_general_ci',
    `playerSteamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `steamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `action` varchar(255) default null collate 'utf8mb4_general_ci',
    `staffName` varchar(255) default null collate 'utf8mb4_general_ci',
    `staffSteamID` varchar(255) default null collate 'utf8mb4_general_ci',
    `timestamp` int default null,
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_doors` (
    `gamemode` text default null,
    `map` text default null,
    `id` int not null,
    `factions` text default null,
    `classes` text default null,
    `disabled` tinyint(1) default null,
    `hidden` tinyint(1) default null,
    `ownable` tinyint(1) default null,
    `name` text default null,
    `price` int default null,
    `locked` tinyint(1) default null,
    `children` text default null,
    primary key (`gamemode`,`map`,`id`)
);
CREATE TABLE IF NOT EXISTS `lia_data` (
    `gamemode` text default null,
    `map` text default null,
    `data` text default null,
    primary key (`gamemode`,`map`)
);
CREATE TABLE IF NOT EXISTS `lia_persistence` (
    `id` int not null auto_increment,
    `gamemode` text default null,
    `map` text default null,
    `class` text default null,
    `pos` text default null,
    `angles` text default null,
    `model` text default null,
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_saveditems` (
    `id` int not null auto_increment,
    `schema` text default null,
    `map` text default null,
    `_itemID` int not null,
    `_pos` text default null,
    `_angles` text default null,
    primary key (`id`)
);
CREATE TABLE IF NOT EXISTS `lia_admin` (
    `usergroup` text not null,
    `privileges` text default null,
    `inheritance` text default null,
    `types` text default null,
    PRIMARY KEY (`usergroup`)
);
]])
        local index = 1
        local function nextQuery()
            if index > #queries then
                done()
                return
            end

            local q = string.Trim(queries[index])
            if q == "" then
                index = index + 1
                nextQuery()
            else
                lia.db.query(q, function()
                    index = index + 1
                    nextQuery()
                end)
            end
        end

        nextQuery()
    end

    hook.Run("OnLoadTables")
end

function lia.db.waitForTablesToLoad()
    TABLE_WAIT_ID = TABLE_WAIT_ID or 0
    local d = deferred.new()
    if lia.db.tablesLoaded then
        d:resolve()
    else
        hook.Add("LiliaTablesLoaded", tostring(TABLE_WAIT_ID), function() d:resolve() end)
    end

    TABLE_WAIT_ID = TABLE_WAIT_ID + 1
    return d
end

local function genInsertValues(value, dbTable)
    local query = "lia_" .. (dbTable or "characters") .. " ("
    local keys = {}
    local values = {}
    for k, v in pairs(value) do
        keys[#keys + 1] = k
        values[#keys] = lia.db.convertDataType(v)
    end
    return query .. table.concat(keys, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
end

local function genUpdateList(value)
    local changes = {}
    for k, v in pairs(value) do
        changes[#changes + 1] = k .. " = " .. lia.db.convertDataType(v)
    end
    return table.concat(changes, ", ")
end

function lia.db.convertDataType(value, noEscape)
    if value == nil then
        return "NULL"
    elseif isstring(value) then
        if noEscape then
            return value
        else
            return "'" .. lia.db.escape(value) .. "'"
        end
    elseif istable(value) then
        if noEscape then
            return util.TableToJSON(value)
        else
            return "'" .. lia.db.escape(util.TableToJSON(value)) .. "'"
        end
    elseif isbool(value) then
        return value and 1 or 0
    elseif value == NULL then
        return "NULL"
    end
    return value
end

function lia.db.insertTable(value, callback, dbTable)
    local query = "INSERT INTO " .. genInsertValues(value, dbTable)
    lia.db.query(query, callback)
end

function lia.db.updateTable(value, callback, dbTable, condition)
    local query = "UPDATE " .. "lia_" .. (dbTable or "characters") .. " SET " .. genUpdateList(value) .. (condition and " WHERE " .. condition or "")
    lia.db.query(query, callback)
end

function lia.db.select(fields, dbTable, condition, limit)
    local d = deferred.new()
    local from = istable(fields) and table.concat(fields, ", ") or tostring(fields)
    local tableName = "lia_" .. (dbTable or "characters")
    local query = "SELECT " .. from .. " FROM " .. tableName
    if condition then query = query .. " WHERE " .. tostring(condition) end
    if limit then query = query .. " LIMIT " .. tostring(limit) end
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.count(dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local q = "SELECT COUNT(*) AS cnt FROM " .. tbl .. (condition and " WHERE " .. condition or "")
    lia.db.query(q, function(results)
        if istable(results) then
            c:resolve(tonumber(results[1].cnt))
        else
            c:resolve(0)
        end
    end)
    return c
end

function lia.db.addDatabaseFields()
    local typeMap = {
        string = function(d) return ("%s VARCHAR(%d)"):format(d.field, d.length or 255) end,
        integer = function(d) return ("%s INT"):format(d.field) end,
        float = function(d) return ("%s FLOAT"):format(d.field) end,
        boolean = function(d) return ("%s TINYINT(1)"):format(d.field) end,
        datetime = function(d) return ("%s DATETIME"):format(d.field) end,
        text = function(d) return ("%s TEXT"):format(d.field) end
    }

    local ignore = function() end
    if not istable(lia.char.vars) then return end
    for _, v in pairs(lia.char.vars) do
        if v.field and typeMap[v.fieldType] then
            lia.db.fieldExists("lia_characters", v.field):next(function(exists)
                if not exists then
                    local colDef = typeMap[v.fieldType](v)
                    if v.default ~= nil then colDef = colDef .. " DEFAULT '" .. tostring(v.default) .. "'" end
                    lia.db.query("ALTER TABLE lia_characters ADD COLUMN " .. colDef):catch(ignore)
                end
            end)
        end
    end
end

function lia.db.exists(dbTable, condition)
    return lia.db.count(dbTable, condition):next(function(n) return n > 0 end)
end

function lia.db.selectOne(fields, dbTable, condition)
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local f = istable(fields) and table.concat(fields, ", ") or fields
    local q = "SELECT " .. f .. " FROM " .. tbl
    if condition then q = q .. " WHERE " .. condition end
    q = q .. " LIMIT 1"
    lia.db.query(q, function(results)
        if istable(results) then
            c:resolve(results[1])
        else
            c:resolve(nil)
        end
    end)
    return c
end

function lia.db.bulkInsert(dbTable, rows)
    if #rows == 0 then return deferred.new():resolve() end
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local keys = {}
    for k in pairs(rows[1]) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
    end

    local vals = {}
    for _, row in ipairs(rows) do
        local items = {}
        for _, k in ipairs(keys) do
            local key = k:sub(2, -2)
            items[#items + 1] = lia.db.convertDataType(row[key])
        end

        vals[#vals + 1] = "(" .. table.concat(items, ",") .. ")"
    end

    local q = "INSERT INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",")
    lia.db.query(q, function() c:resolve() end, function(err) c:reject(err) end)
    return c
end

function lia.db.bulkUpsert(dbTable, rows)
    if #rows == 0 then return deferred.new():resolve() end
    local c = deferred.new()
    local tbl = "`lia_" .. dbTable .. "`"
    local keys = {}
    for k in pairs(rows[1]) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
    end

    local vals = {}
    for _, row in ipairs(rows) do
        local items = {}
        for _, k in ipairs(keys) do
            local key = k:sub(2, -2)
            items[#items + 1] = lia.db.convertDataType(row[key])
        end

        vals[#vals + 1] = "(" .. table.concat(items, ",") .. ")"
    end

    local q
    if lia.db.object then
        local updates = {}
        for _, k in ipairs(keys) do
            updates[#updates + 1] = k .. "=VALUES(" .. k .. ")"
        end

        q = "INSERT INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",") .. " ON DUPLICATE KEY UPDATE " .. table.concat(updates, ",")
    else
        q = "INSERT OR REPLACE INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES " .. table.concat(vals, ",")
    end

    lia.db.query(q, function() c:resolve() end, function(err) c:reject(err) end)
    return c
end

function lia.db.insertOrIgnore(value, dbTable)
    local c = deferred.new()
    local tbl = "`lia_" .. (dbTable or "characters") .. "`"
    local keys, vals = {}, {}
    for k, v in pairs(value) do
        keys[#keys + 1] = lia.db.escapeIdentifier(k)
        vals[#vals + 1] = lia.db.convertDataType(v)
    end

    local cmd = lia.db.module == "sqlite" and "INSERT OR IGNORE" or "INSERT IGNORE"
    local q = cmd .. " INTO " .. tbl .. " (" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(vals, ",") .. ")"
    lia.db.query(q, function(results, lastID)
        c:resolve({
            results = results,
            lastID = lastID
        })
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.tableExists(tbl)
    local d = deferred.new()
    local qt = "'" .. tbl:gsub("'", "''") .. "'"
    if lia.db.module == "sqlite" then
        lia.db.query("SELECT name FROM sqlite_master WHERE type='table' AND name=" .. qt, function(res) d:resolve(res and #res > 0) end, function(err) d:reject(err) end)
    else
        lia.db.query("SHOW TABLES LIKE " .. qt, function(res) d:resolve(res and #res > 0) end, function(err) d:reject(err) end)
    end
    return d
end

function lia.db.fieldExists(tbl, field)
    local d = deferred.new()
    if lia.db.module == "sqlite" then
        lia.db.query("PRAGMA table_info(" .. tbl .. ")", function(res)
            for _, r in ipairs(res) do
                if r.name == field then return d:resolve(true) end
            end

            d:resolve(false)
        end, function(err) d:reject(err) end)
    else
        lia.db.query("DESCRIBE " .. lia.db.escapeIdentifier(tbl), function(res)
            for _, r in ipairs(res) do
                if r.Field == field then return d:resolve(true) end
            end

            d:resolve(false)
        end, function(err) d:reject(err) end)
    end
    return d
end

function lia.db.getTables()
    local d = deferred.new()
    if lia.db.module == "sqlite" then
        lia.db.query("SELECT name FROM sqlite_master WHERE type='table'", function(res)
            local tables = {}
            for _, row in ipairs(res or {}) do
                if row.name and row.name:StartWith("lia_") then tables[#tables + 1] = row.name end
            end

            d:resolve(tables)
        end, function(err) d:reject(err) end)
    else
        local key = "Tables_in_" .. lia.db.database
        lia.db.query("SHOW TABLES", function(res)
            local tables = {}
            for _, row in ipairs(res or {}) do
                local name = row[key]
                if name and string.sub(name, 1, 4) == "lia_" then tables[#tables + 1] = name end
            end

            d:resolve(tables)
        end, function(err) d:reject(err) end)
    end
    return d
end

function lia.db.transaction(queries)
    local c = deferred.new()
    lia.db.query("BEGIN TRANSACTION", function()
        local i = 1
        local function nextQuery()
            if i > #queries then
                lia.db.query("COMMIT", function() c:resolve() end)
            else
                lia.db.query(queries[i], function()
                    i = i + 1
                    nextQuery()
                end, function(err) lia.db.query("ROLLBACK", function() c:reject(err) end) end)
            end
        end

        nextQuery()
    end, function(err) c:reject(err) end)
    return c
end

function lia.db.escapeIdentifier(id)
    return "`" .. tostring(id):gsub("`", "``") .. "`"
end

function lia.db.upsert(value, dbTable)
    local query
    if lia.db.object then
        query = "INSERT INTO " .. genInsertValues(value, dbTable) .. " ON DUPLICATE KEY UPDATE " .. genUpdateList(value)
    else
        query = "INSERT OR REPLACE INTO " .. genInsertValues(value, dbTable)
    end

    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.delete(dbTable, condition)
    local query
    dbTable = "lia_" .. (dbTable or "character")
    if condition then
        query = "DELETE FROM " .. dbTable .. " WHERE " .. condition
    else
        query = "DELETE * FROM " .. dbTable
    end

    local d = deferred.new()
    lia.db.query(query, function(results, lastID)
        d:resolve({
            results = results,
            lastID = lastID
        })
    end)
    return d
end

function lia.db.GetCharacterTable(callback)
    local query = lia.db.module == "sqlite" and "PRAGMA table_info(lia_characters)" or "DESCRIBE lia_characters"
    lia.db.query(query, function(results)
        if not results or #results == 0 then return callback({}) end
        local columns = {}
        if lia.db.module == "sqlite" then
            for _, row in ipairs(results) do
                table.insert(columns, row.name)
            end
        else
            for _, row in ipairs(results) do
                table.insert(columns, row.Field)
            end
        end

        callback(columns)
    end)
end

concommand.Add("database_list", function(ply)
    if IsValid(ply) then return end
    lia.db.GetCharacterTable(function(columns)
        if #columns == 0 then
            lia.error(L("dbColumnsNone"))
        else
            lia.information(L("dbColumnsList", table.concat(columns, ", ")))
        end
    end)
end)

function GM:RegisterPreparedStatements()
    lia.bootstrap(L("database"), L("preparedStatementsAdded"))
    lia.db.prepare("itemData", "UPDATE lia_items SET data = ? WHERE _itemID = ?", {MYSQLOO_STRING, MYSQLOO_INTEGER})
    lia.db.prepare("itemx", "UPDATE lia_items SET x = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemy", "UPDATE lia_items SET y = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemq", "UPDATE lia_items SET quantity = ? WHERE _itemID = ?", {MYSQLOO_INTEGER, MYSQLOO_INTEGER})
    lia.db.prepare("itemInstance", "INSERT INTO lia_items (invID, uniqueID, data, x, y, quantity) VALUES (?, ?, ?, ?, ?, ?)", {MYSQLOO_INTEGER, MYSQLOO_STRING, MYSQLOO_STRING, MYSQLOO_INTEGER, MYSQLOO_INTEGER, MYSQLOO_INTEGER,})
end

function GM:SetupDatabase()
    local databasePath = engine.ActiveGamemode() .. "/schema/database.lua"
    local databaseOverrideExists = file.Exists(databasePath, "LUA")
    if databaseOverrideExists then
        local databaseConfig = include(databasePath)
        if databaseConfig then
            lia.db.config = databaseConfig
            for k, v in pairs(databaseConfig) do
                lia.db[k] = v
            end
        end
    end

    if not lia.db.config then
        for k, v in pairs({
            module = "sqlite",
            hostname = "127.0.0.1",
            username = "",
            password = "",
            database = "",
            port = 3306,
        }) do
            lia.db[k] = v
        end
    end
end

function GM:DatabaseConnected()
    lia.bootstrap(L("database"), L("databaseConnected", lia.db.module), Color(0, 255, 0))
end

function GM:OnMySQLOOConnected()
    hook.Run("RegisterPreparedStatements")
    MYSQLOO_PREPARED = true
end
