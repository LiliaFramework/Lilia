local MODULE = MODULE
util.AddNetworkString("SyncLogs")
util.AddNetworkString("SyncCategories")
util.AddNetworkString("OpenLogger")
function MODULE:addCategory(name, color)
    if not isstring(name) or not IsColor(color) then return false end
    local t = {
        name = name,
        color = color
    }

    self.categories[name] = t
    return function(log) return self:addLog(name, log) end
end

function MODULE:addLog(category, log)
    if not isstring(category) or not isstring(log) then return false end
    if not self.categories[category] then return false end
    local query = ("INSERT INTO lilia_logs ( log, category, time ) VALUES ( %s, %s, %d )"):format(SQLStr(log), SQLStr(category), os.time())
    return sql.Query(query) == nil and true or false
end

function MODULE:networkCategories(client)
    net.Start("SyncCategories")
    net.WriteUInt(table.Count(self.categories), self.maxCategoriesInBits)
    for _, v in pairs(self.categories) do
        net.WriteString(v.name)
        net.WriteColor(v.color)
    end

    net.Send(client)
end

net.Receive("SyncCategories", function(_, client)
    if not CAMI.PlayerHasAccess(client, "Commands - View Logs", nil) then return end
    MODULE:networkCategories(client)
end)

net.Receive("SyncLogs", function(_, client)
    if not CAMI.PlayerHasAccess(client, "Commands - View Logs", nil) then return end
    local page = net.ReadUInt(MODULE.maxPagesInBits)
    local category_name = net.ReadString()
    local escaped_category_name = SQLStr(category_name)
    local logs = sql.Query(("SELECT * FROM lilia_logs WHERE category = %s ORDER BY time DESC LIMIT %d OFFSET %d"):format(escaped_category_name, MODULE.logsPerPage, (page - 1) * MODULE.logsPerPage))
    if not logs then
        net.Start("SyncLogs")
        net.WriteUInt(0, MODULE.maxPagesInBits)
        net.Send(client)
        return
    end

    local count = select(2, next(sql.Query(("SELECT COUNT( * ) FROM lilia_logs WHERE category = %s"):format(escaped_category_name))[1]))
    for _, v in ipairs(logs) do
        v.category = nil
        v.id = nil
    end

    local data = util.Compress(util.TableToJSON(logs))
    net.Start("SyncLogs")
    net.WriteUInt(math.ceil(count / MODULE.logsPerPage), MODULE.maxPagesInBits)
    net.WriteData(data, #data)
    net.Send(client)
end)

concommand.Add("logger_delete_logs", function(client)
    if not IsValid(client) then
        lia.db.query("DELETE FROM `lilia_logs` WHERE time > 0", function(result)
            if result then
                print("Logger - All logs with time greater than 0 have been erased")
            else
                print("Logger - Failed : " .. sql.LastError())
            end
        end)
    else
        client:ChatPrint("Nuh-uh")
    end
end)

hook.Add("PostGamemodeLoaded", "hooks", function() sql.Query("CREATE TABLE IF NOT EXISTS lilia_logs ( id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, log TEXT NOT NULL, time INTEGER NOT NULL )") end)
