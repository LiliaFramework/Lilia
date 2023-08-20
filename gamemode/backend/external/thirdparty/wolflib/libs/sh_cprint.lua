CP_ERROR = 1
CP_WARN = 2
CP_LOAD = 3

function cprint(txt, msgType)
    mid = "->"
    local trace = debug.getinfo(2, "Sn")
    local dir = trace.short_src:Split("plugins")[2]:Split("/")
    local pluginTrace = ""

    for i = 2, #dir do
        if pluginTrace ~= "" then
            pluginTrace = pluginTrace .. mid
        end

        pluginTrace = pluginTrace .. dir[i]
    end

    local fname = trace.name or dir[#dir] or "main"

    if msgType == CP_ERROR then
        MsgC(Color(0, 0, 255), pluginTrace .. mid .. fname .. "()", Color(255, 0, 0), "[Error]", Color(255, 255, 255), ": " .. tostring(txt) .. "\n")
    elseif msgType == CP_WARN then
        MsgC(Color(0, 0, 255), pluginTrace .. mid .. fname .. "()", Color(255, 255, 0), "[Warn]", Color(255, 255, 255), ": " .. tostring(txt) .. "\n")
    elseif msgType == CP_LOAD then
        local parentPlugin = dir[2]
        local childFolder = dir[3] or ""
        if not parentPlugin then return end
        local ds = "[%s/%s/%s] "

        if childFolder == fname then
            fname = ""
            ds = "[%s/%s%s] "
        end

        ds = ds:format(parentPlugin, childFolder, fname)
        ds = string.upper(ds)
        MsgC(Color(255, 153, 0), ds, color_white, txt .. "\n")
    else
        MsgC(Color(0, 0, 255), pluginTrace .. mid .. fname .. "()", Color(255, 255, 255), ": " .. tostring(txt) .. "\n")
    end
end