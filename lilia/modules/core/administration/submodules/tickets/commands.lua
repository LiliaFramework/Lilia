lia.command.add("plyviewclaims", {
  adminOnly = true,
  syntax = "[string charname]",
  privilege = "View Claims",
  AdminStick = {
    Name = "View Ticket Claims",
    Category = "Moderation Tools",
    SubCategory = "Miscellaneous",
    Icon = "icon16/page_white_text.png"
  },
  onRun = function(client, arguments)
    local targetName = arguments[1]
    if not targetName then
      client:ChatPrint("You must specify a player name.")
      return
    end

    local target = lia.command.findPlayer(client, targetName)
    if not IsValid(target) then
      client:ChatPrint("Player not found.")
      return
    end

    local steamID = target:SteamID()
    if not file.Exists("caseclaims.txt", "DATA") then
      client:ChatPrint("No claims have been recorded yet.")
      return
    end

    local caseclaimsContent = file.Read("caseclaims.txt", "DATA")
    local caseclaims = util.JSONToTable(caseclaimsContent) or {}
    local claim = caseclaims[steamID]
    if not claim then
      client:ChatPrint("No claims found for the specified player.")
      return
    end

    local message = string.format("=== Claims for %s ===\nSteamID: %s\nAdmin Name: %s\nTotal Claims: %d\nLast Claim Date: %s\nTime Since Last Claim: %s", target:Nick(), steamID, claim.name, claim.claims, os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim), lia.time.TimeSince(claim.lastclaim))
    client:ChatPrint(message)
  end
})

lia.command.add("viewallclaims", {
  privilege = "View Claims",
  description = "View the claims for all admins.",
  adminOnly = true,
  onRun = function(client)
    if not file.Exists("caseclaims.txt", "DATA") then
      client:ChatPrint("No claims have been recorded yet.")
      return
    end

    local caseclaims = util.JSONToTable(file.Read("caseclaims.txt", "DATA"))
    local claimsData = {}
    for steamID, claim in pairs(caseclaims) do
      table.insert(claimsData, {
        steamID = steamID,
        name = claim.name,
        claims = claim.claims,
        lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
        timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim)
      })
    end

    lia.util.CreateTableUI(client, "Admin Claims", {
      {
        name = "SteamID",
        field = "steamID",
      },
      {
        name = "Admin Name",
        field = "name",
      },
      {
        name = "Total Claims",
        field = "claims",
      },
      {
        name = "Last Claim Date",
        field = "lastclaim",
      },
      {
        name = "Time Since Last Claim",
        field = "timeSinceLastClaim",
      }
    }, claimsData)
  end
})

lia.command.add("viewclaims", {
  privilege = "View Claims",
  description = "View the claims for all admins.",
  adminOnly = true,
  onRun = function(client)
    if not file.Exists("caseclaims.txt", "DATA") then
      client:ChatPrint("No claims have been recorded yet.")
      return
    end

    local caseclaimsContent = file.Read("caseclaims.txt", "DATA")
    local caseclaims = util.JSONToTable(caseclaimsContent) or {}
    if next(caseclaims) == nil then
      client:ChatPrint("No claims data available.")
      return
    end

    client:ChatPrint("=== Admin Claims ===")
    for steamID, claim in pairs(caseclaims) do
      local message = string.format("SteamID: %s\nAdmin Name: %s\nTotal Claims: %d\nLast Claim Date: %s\nTime Since Last Claim: %s\n-------------------------", steamID, claim.name, claim.claims, os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim), lia.time.TimeSince(claim.lastclaim))
      client:ChatPrint(message)
    end
  end
})
