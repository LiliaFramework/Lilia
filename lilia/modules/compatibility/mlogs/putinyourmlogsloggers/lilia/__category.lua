mLogs.addCategory("lia", "lia", Color(38, 166, 91), function() return lia ~= nil end)
mLogs.addCategoryDefinitions("lia", {
    ScriptLog = function(data) return mLogs.doLogReplace({"[Script Log]", "^log"}, data) end,
})
