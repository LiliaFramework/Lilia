mLogs.addCategory("Lilia", "lia", Color(121, 65, 203), function() return lia ~= nil end, nil, 105)
mLogs.addCategoryDefinitions("lia", {
    LiliaLog = function(data) return mLogs.doLogReplace({"[Lilia Logs]", "^log"}, data) end,
})

if SERVER then mLogs.addLogger("Lilia Logs", "LiliaLog", "lia") end
