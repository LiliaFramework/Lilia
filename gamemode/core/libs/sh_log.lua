FLAG_NORMAL = 0
FLAG_SUCCESS = 1
FLAG_WARNING = 2
FLAG_DANGER = 3
FLAG_SERVER = 4
FLAG_DEV = 5

lia.log = lia.log or {}
lia.log.color = {
	[FLAG_NORMAL] = Color(200, 200, 200),
	[FLAG_SUCCESS] = Color(50, 200, 50),
	[FLAG_WARNING] = Color(255, 255, 0),
	[FLAG_DANGER] = Color(255, 50, 50),
	[FLAG_SERVER] = Color(200, 200, 220),
	[FLAG_DEV] = Color(200, 200, 220),
}
local consoleColor = Color(50, 200, 50)

if (SERVER) then
	if (not lia.db) then
		include("sv_database.lua")
	end

	function lia.log.loadTables()
		file.CreateDir("lilia/logs")
	end

	function lia.log.resetTables()
	end

	lia.log.types = lia.log.types or {}

	function lia.log.addType(logType, func)
		lia.log.types[logType] = func
	end

	function lia.log.getString(client, logType, ...)
		local text = lia.log.types[logType]
		if (isfunction(text)) then
			local success, result = pcall(text, client, ...)
			if (success) then
				return result
			end
		end
	end

	function lia.log.addRaw(logString, shouldNotify, flag)		
		if (shouldNotify) then
			lia.log.send(lia.util.getAdmins(), logString, flag)
		end

		Msg("[LOG] ", logString.."\n")
		if (!noSave) then
			file.Append("lilia/logs/"..os.date("%x"):gsub("/", "-")..".txt", "["..os.date("%X").."]\t"..logString.."\r\n")
		end
	end

	function lia.log.add(client, logType, ...)
		local logString = lia.log.getString(client, logType, ...)
		if (not isstring(logString)) then return end

		hook.Run("OnServerLog", client, logType, ...)
		Msg("[LOG] ", logString.."\n")

		if (noSave) then return end
		file.Append("lilia/logs/"..os.date("%x"):gsub("/", "-")..".txt", "["..os.date("%X").."]\t"..logString.."\r\n")
	end

	function lia.log.open(client)
		local logData = {}
		netstream.Hook(client, "liaLogView", logData)
	end

	function lia.log.send(client, logString, flag)
		netstream.Start(client, "liaLogStream", logString, flag)
	end
else
	netstream.Hook("liaLogStream", function(logString, flag)
		MsgC(consoleColor, "[SERVER] ", lia.log.color[flag] or color_white, tostring(logString).."\n")
	end)
end
