--------------------------------------------------------------------------------------------------------
local doLog = CreateConVar("net_logoutgoing", 0, FCVAR_NONE)
local maxLines = CreateConVar("net_maxlines", 30, FCVAR_ARCHIVE)
--------------------------------------------------------------------------------------------------------
net.StartTime = net.StartTime or CurTime()
net.NetworkData = net.NetworkData or {}
net.NetworkFilter = net.NetworkFilter or {}
net.MessageCount = net.MessageCount or 0
net.BytesCount = net.BytesCount or 0
net.OldStart = net.OldStart or net.Start
net.OldSend = net.OldSend or net.Send
net.OldSendOmit = net.OldSendOmit or net.SendOmit
net.OldSendPAS = net.OldSendPAS or net.SendPAS
net.OldSendPVS = net.OldSendPVS or net.SendPVS
net.OldBroadcast = net.OldBroadcast or net.Broadcast
--------------------------------------------------------------------------------------------------------
local function AccessCheck(ply)
	if game.SinglePlayer() or not IsValid(ply) then return true end

	return false
end

--------------------------------------------------------------------------------------------------------
local function printf(str, ...)
	print(string.format(str, ...))
end

--------------------------------------------------------------------------------------------------------
local function perc(val, max)
	return math.Round((val / max) * 100, 2)
end

--------------------------------------------------------------------------------------------------------
function net.LogOutgoing(filter)
	local recipients
	local typeID = TypeID(filter or nil)
	local playerCount = 0
	local broadcast = false
	if typeID == TYPE_ENTITY then
		recipients = string.format("client: %s (%s)", filter:Nick(), filter:SteamID())
		playerCount = 1
	elseif typeID == TYPE_TABLE then
		recipients = string.format("%s clients", #filter)
		playerCount = #filter
	elseif typeID == TYPE_RECIPIENTFILTER then
		recipients = string.format("%s clients", filter:GetCount())
		playerCount = filter:GetCount()
	else
		recipients = "everyone"
		playerCount = player.GetCount()
		broadcast = true
	end

	local name = net.CurrentMessageName
	local bytes = net.BytesWritten() * playerCount
	net.MessageCount = net.MessageCount + 1
	net.BytesCount = net.BytesCount + bytes
	net.NetworkData[name] = net.NetworkData[name] or {
		Count = 0,
		Bytes = 0,
		PlayerCount = 0,
		Broadcast = 0
	}

	net.NetworkData[name].Count = net.NetworkData[name].Count + 1
	net.NetworkData[name].Bytes = net.NetworkData[name].Bytes + bytes
	net.NetworkData[name].PlayerCount = net.NetworkData[name].PlayerCount + playerCount
	if broadcast then
		net.NetworkData[name].Broadcast = net.NetworkData[name].Broadcast + 1
	end

	if doLog:GetBool() and not net.NetworkFilter[name] then
		printf("Outgoing %s message %s (%s) to %s", net.IsUnreliable and "unreliable" or "reliable", name, string.NiceSize(bytes), recipients)
	end
end

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_addfilter",
	function(ply, cmd, args)
		if not AccessCheck(ply) or not args[1] then return end
		net.NetworkFilter[args[1]] = true
	end
)

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_removefilter",
	function(ply, cmd, args)
		if not AccessCheck(ply) or not args[1] then return end
		net.NetworkFilter[args[1]] = nil
	end
)

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_checkfilter",
	function(ply)
		if not AccessCheck(ply) then return end
		if table.Count(net.NetworkFilter) == 0 then
			print("-------")
			print("No network messages are being filtered")
			print("-------")

			return
		end

		print("-------")
		print("Filtered network messages:")
		print("-------")
		for k in SortedPairs(net.NetworkFilter) do
			print(k)
		end

		print("-------")
	end
)

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_clearfilter",
	function(ply)
		if not AccessCheck(ply) then return end
		net.NetworkFilter = {}
	end
)

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_getinfo",
	function(ply, cmd, args)
		if not AccessCheck(ply) then return end
		print("-------")
		local time = CurTime() - net.StartTime
		local messageName = args[1]
		if messageName then
			if net.NetworkData[messageName] then
				print("Network data for message: " .. messageName)
				print("Interval: " .. string.NiceTime(time))
				print("-------")
				local data = net.NetworkData[messageName]
				printf("Times sent: %s (%s messages/sec, %s%%)", data.Count, math.Round(data.Count / time, 2), perc(data.Count, net.MessageCount))
				printf("Sent to %s players on average per message", math.Round(data.PlayerCount / data.Count))
				printf("Broadcast to everyone %s%% of the time (%s/%s messages)", perc(data.Broadcast, data.Count), data.Broadcast, data.Count)
				printf("Data sent: %s (%s/sec, %s%%)", string.NiceSize(data.Bytes), string.NiceSize(math.Round(data.Bytes / time)), perc(data.Bytes, net.BytesCount))
			else
				print("No network data found for this message")
			end
		else
			print("Biggest contributors to net library usage:")
			printf("Interval: %s", string.NiceTime(time))
			printf("Messages sent: %s", net.MessageCount)
			printf("Data sent: %s", string.NiceSize(net.BytesCount))
			print("-------")
			local keys = {}
			for k in pairs(net.NetworkData) do
				if net.NetworkFilter[k] then continue end
				keys[#keys + 1] = k
			end

			local function output()
				local max = {
					name = 0,
					count = 0,
					data = 0
				}

				local lines = {}
				for i = 1, math.min(#keys, maxLines:GetInt()) do
					local name = keys[i]
					local data = net.NetworkData[name]
					lines[name] = {string.format("Count: %s (%s messages/sec, %s%%)", data.Count, math.Round(data.Count / time, 2), perc(data.Count, net.MessageCount)), string.format("Data: %s (%s/sec, %s%%)", string.NiceSize(data.Bytes), string.NiceSize(math.Round(data.Bytes / time)), perc(data.Bytes, net.BytesCount))}
					max.name = math.max(max.name, #name + 2)
					max.count = math.max(max.count, #lines[name][1] + 1)
					max.data = math.max(max.data, #lines[name][2])
				end

				for i = 1, math.min(#keys, maxLines:GetInt()) do
					local name = keys[i]
					local line = lines[name]
					printf("%-" .. max.name .. "s %-" .. max.count .. "s %-" .. max.data .. "s", name .. ": ", line[1], line[2])
				end
			end

			print("Sorted by message size")
			print("-------")
			table.sort(keys, function(a, b) return net.NetworkData[a].Bytes > net.NetworkData[b].Bytes end)
			output()
			print("-------")
			print("Sorted by message count")
			print("-------")
			table.sort(keys, function(a, b) return net.NetworkData[a].Count > net.NetworkData[b].Count end)
			output()
		end

		print("-------")
	end
)

--------------------------------------------------------------------------------------------------------
concommand.Add(
	"net_reset",
	function(ply)
		if not AccessCheck(ply) then return end
		net.StartTime = CurTime()
		net.NetworkData = {}
		net.MessageCount = 0
		net.BytesCount = 0
	end
)

--------------------------------------------------------------------------------------------------------
function net.Start(messageName, unreliable)
	net.CurrentMessageName = messageName
	net.IsUnreliable = unreliable or false
	net.OldStart(messageName, unreliable)
end

--------------------------------------------------------------------------------------------------------
function net.Send(ply)
	net.LogOutgoing(ply)
	net.OldSend(ply)
end

--------------------------------------------------------------------------------------------------------
function net.SendOmit(ply)
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	if istable(ply) then
		for _, v in pairs(ply) do
			if v:IsPlayer() then
				filter:RemovePlayer(v)
			end
		end
	else
		filter:RemovePlayer(ply)
	end

	net.LogOutgoing(filter)
	net.OldSendOmit(ply)
end

--------------------------------------------------------------------------------------------------------
function net.SendPAS(vec)
	local filter = RecipientFilter()
	filter:AddPAS(vec)
	net.LogOutgoing(filter)
	net.OldSendPAS(vec)
end

--------------------------------------------------------------------------------------------------------
function net.SendPVS(vec)
	local filter = RecipientFilter()
	filter:AddPVS(vec)
	net.LogOutgoing(filter)
	net.OldSendPVS(vec)
end

--------------------------------------------------------------------------------------------------------
function net.Broadcast()
	net.LogOutgoing()
	net.OldBroadcast()
end
--------------------------------------------------------------------------------------------------------