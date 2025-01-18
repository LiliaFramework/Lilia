lia.command.add("adminmode", {
  onRun = function(client)
    if not IsValid(client) then return end
    local steamID = client:SteamID64()
    if client:Team() == FACTION_STAFF then
      local oldCharID = client:GetNW2Int("OldCharID", 0)
      if oldCharID > 0 then
        net.Start("AdminModeSwapCharacter")
        net.WriteInt(oldCharID, 32)
        net.Send(client)
        client:SetNW2Int("OldCharID", nil)
        lia.log.add(client, "adminMode", oldCharID, "Switched back to their IC character")
      else
        client:ChatPrint("No previous character to swap to.")
      end
    else
      lia.db.query(string.format("SELECT * FROM lia_characters WHERE _steamID = \"%s\"", lia.db.escape(steamID)), function(data)
        for _, row in ipairs(data) do
          local id = tonumber(row._id)
          local faction = row._faction
          if faction == "staff" then
            client:SetNW2Int("OldCharID", client:getChar():getID())
            net.Start("AdminModeSwapCharacter")
            net.WriteInt(id, 32)
            net.Send(client)
            lia.log.add(client, "adminMode", id, "Switched to their staff character")
            return
          end
        end

        client:ChatPrint("No staff character found.")
      end)
    end
  end
})

lia.command.add("setsitroom", {
  superAdminOnly = true,
  privilege = "Manage SitRooms",
  onRun = function(client)
    local pos = client:GetPos()
    local dir = string.format("data/lilia/%s/%s", engine.ActiveGamemode(), game.GetMap())
    local filePath = string.format("%s/sitroom.txt", dir)
    if not file.Exists(dir, "DATA") then file.CreateDir(dir) end
    file.Write(filePath, tostring(pos))
    client:notify("Sitroom location has been set.")
    lia.log.add(client, "sitRoomSet", tostring(pos), "Set the sitroom location")
  end
})

lia.command.add("sendtositroom", {
  adminOnly = true,
  syntax = "[string charname]",
  privilege = "Manage SitRooms",
  AdminStick = {
    Name = "Send To Sit Room",
    Category = "Moderation Tools",
    SubCategory = "Miscellaneous",
    Icon = "icon16/arrow_down.png"
  },
  onRun = function(client, arguments)
    local target = lia.command.findPlayer(client, arguments[1])
    if not IsValid(target) then
      client:notify("Player not found.")
      return
    end

    local filePath = string.format("data/lilia/%s/%s/sitroom.txt", engine.ActiveGamemode(), game.GetMap())
    if not file.Exists(filePath, "DATA") then
      client:notify("Sitroom location has not been set.")
      return
    end

    local data = file.Read(filePath, "DATA")
    if not data then
      client:notify("Failed to read sitroom location.")
      return
    end

    local pos = util.StringToType(data, "Vector")
    if pos then
      target:SetPos(pos)
      client:notify(string.format("%s has been teleported to the sitroom.", target:Nick()))
      lia.log.add(client, "sendToSitRoom", target:Nick(), "Teleported to the sitroom")
    else
      client:notify("Invalid sitroom data.")
    end
  end
})

lia.command.add("warn", {
  adminOnly = true,
  privilege = "Issue Warnings",
  syntax = "<string target> <string reason>",
  AdminStick = {
    Name = "Warn Player",
    Category = "Moderation Tools",
    SubCategory = "Warnings",
    Icon = "icon16/error.png"
  },
  onRun = function(client, arguments)
    local targetName = arguments[1]
    local reason = table.concat(arguments, " ", 2)
    if not targetName or not reason then return "Usage: warn <player> <reason>" end
    local target = lia.command.findPlayer(client, arguments[1])
    if not IsValid(target) then return "Player not found." end
    local warning = {
      timestamp = os.date("%Y-%m-%d %H:%M:%S"),
      reason = reason,
      admin = client:Nick() .. " (" .. client:SteamID() .. ")"
    }

    local warns = target:getLiliaData("warns") or {}
    table.insert(warns, warning)
    target:setLiliaData("warns", warns)
    target:notify("You have been warned by " .. warning.admin .. " for: " .. reason)
    client:notify("Warning issued to " .. target:Nick())
    lia.log.add(client, "warningIssued", target, reason)
  end
})

lia.command.add("viewwarns", {
  adminOnly = true,
  privilege = "View Player Warnings",
  syntax = "<string target>",
  AdminStick = {
    Name = "View Player Warnings",
    Category = "Moderation Tools",
    SubCategory = "Warnings",
    Icon = "icon16/eye.png"
  },
  onRun = function(client, arguments)
    local target = lia.command.findPlayer(client, arguments[1])
    local warns = target:getLiliaData("warns") or {}
    if table.Count(warns) == 0 then
      client:notify(target:Nick() .. " has no warnings.")
      return
    end

    local warningList = {}
    for index, warn in ipairs(warns) do
      table.insert(warningList, {
        index = index,
        timestamp = warn.timestamp or "N/A",
        reason = warn.reason or "N/A",
        admin = warn.admin or "N/A",
      })
    end

    lia.util.CreateTableUI(client, target:Nick() .. "'s Warnings", {
      {
        name = "ID",
        field = "index"
      },
      {
        name = "Timestamp",
        field = "timestamp"
      },
      {
        name = "Reason",
        field = "reason"
      },
      {
        name = "Admin",
        field = "admin"
      },
    }, warningList, {
      {
        name = "Remove Warning",
        net = "RequestRemoveWarning"
      }
    }, target:getChar():getID())
  end
})
