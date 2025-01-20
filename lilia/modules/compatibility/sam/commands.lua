lia.command.add("cleardecals", {
  adminOnly = true,
  privilege = "Clear Decals",
  onRun = function()
    for _, v in player.Iterator() do
      v:ConCommand("r_cleardecals")
    end
  end
})

lia.command.add("playtime", {
  adminOnly = false,
  privilege = "View Own Playtime",
  onRun = function(client)
    local steamID = client:SteamID()
    local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
    local result = sql.QueryRow(query)
    if result then
      local playTimeInSeconds = tonumber(result.play_time) or 0
      local hours = math.floor(playTimeInSeconds / 3600)
      local minutes = math.floor((playTimeInSeconds % 3600) / 60)
      local seconds = playTimeInSeconds % 60
      client:ChatPrint(string.format("Your playtime: %d hours, %d minutes, %d seconds", hours, minutes, seconds))
    else
      client:ChatPrint("Could not retrieve your playtime. Please try again or contact an admin if the issue persists.")
    end
  end
})

lia.command.add("plygetplaytime", {
  adminOnly = true,
  syntax = "[string charname]",
  privilege = "View Playtime",
  AdminStick = {
    Name = "Get Play Time",
    Category = "Moderation Tools",
    SubCategory = "Miscellaneous",
    Icon = "icon16/time.png"
  },
  onRun = function(client, arguments)
    local targetName = arguments[1]
    if not targetName then
      client:notify("You must specify a player name.")
      return
    end

    local target = lia.command.findPlayer(client, targetName)
    if not IsValid(target) then
      client:notify("Player not found.")
      return
    end

    local steamID = target:SteamID()
    local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
    local result = sql.QueryRow(query)
    if result then
      local playTimeInSeconds = tonumber(result.play_time) or 0
      local hours = math.floor(playTimeInSeconds / 3600)
      local minutes = math.floor((playTimeInSeconds % 3600) / 60)
      local seconds = playTimeInSeconds % 60
      local message = string.format("Playtime for %s: %d hours, %d minutes, %d seconds", target:Nick(), hours, minutes, seconds)
      client:ChatPrint(message)
    else
      client:notify("Could not retrieve playtime for the specified target.")
    end
  end
})