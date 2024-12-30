local playerMeta = FindMetaTable("Player")
function MODULE:PlayerSpawnProp(client)
    if not playerMeta.GetLimit then return end
    local limit = client:GetLimit("props")
    if limit < 0 then return end
    local props = client:GetCount("props") + 1
    if client:getLiliaData("extraProps") then
        if props > (limit + 50) then
            client:LimitHit("props")
            return false
        end
    else
        if props > limit then
            client:LimitHit("props")
            return false
        end
    end
end

function MODULE:PlayerCheckLimit(client, name)
    if not playerMeta.GetLimit then return end
    if name == "props" then
        if client:isStaffOnDuty() then return true end
        if client:GetLimit("props") < 0 then return end
        if client:getLiliaData("extraProps") then
            local limit = client:GetLimit("props") + 50
            local props = client:GetCount("props")
            if props <= limit + 50 then return true end
        end
    end
end

function MODULE:PlayerSpawnRagdoll(client)
    if not playerMeta.GetLimit then return end
    local limit = client:GetLimit("ragdolls")
    if limit < 0 then return end
    local ragdolls = client:GetCount("ragdolls") + 1
    if ragdolls > limit then
        client:LimitHit("ragdolls")
        return false
    end
end

sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(true)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()

sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Unblinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(false)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Un-Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()

local function TimeSince(lastClaimTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - lastClaimTime
    if elapsedTime < 60 then
        return elapsedTime .. " seconds"
    elseif elapsedTime < 3600 then
        return math.floor(elapsedTime / 60) .. " minutes"
    elseif elapsedTime < 86400 then
        return math.floor(elapsedTime / 3600) .. " hours"
    else
        return math.floor(elapsedTime / 86400) .. " days"
    end
end

lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    onRun = function()
        for _, v in pairs(player.GetAll()) do
            v:ConCommand("r_cleardecals")
        end
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

        local caseclaims = util.JSONToTable(file.Read("caseclaims.txt", "DATA"))
        local claimsData = {}
        for steamID, claim in pairs(caseclaims) do
            table.insert(claimsData, {
                steamID = steamID,
                name = claim.name,
                claims = claim.claims,
                lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                timeSinceLastClaim = TimeSince(claim.lastclaim)
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

lia.command.add("playtime", {
    adminOnly = false,
    onRun = function(client)
        local steamID = client:SteamID()
        local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
        local result = sql.QueryRow(query)
        if result then
            local playTimeInSeconds = tonumber(result.play_time) or 0
            local hours = math.floor(playTimeInSeconds / 3600)
            local minutes = math.floor((playTimeInSeconds % 3600) / 60)
            local seconds = playTimeInSeconds % 60
            client:chatNotify(string.format("Your playtime: %d hours, %d minutes, %d seconds", hours, minutes, seconds))
        else
            client:notify("Could not retrieve your playtime. Please try again or contact an admin if the issue persists.")
        end
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
            local message = string.format("SteamID: %s\nAdmin Name: %s\nTotal Claims: %d\nLast Claim Date: %s\nTime Since Last Claim: %s\n-------------------------", steamID, claim.name, claim.claims, os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim), TimeSince(claim.lastclaim))
            client:ChatPrint(message)
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
        local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
        local result = sql.QueryRow(query)
        if result then
            local playTimeInSeconds = tonumber(result.play_time) or 0
            local hours = math.floor(playTimeInSeconds / 3600)
            local minutes = math.floor((playTimeInSeconds % 3600) / 60)
            local seconds = playTimeInSeconds % 60
            client:ChatPrint(string.format("Playtime for %s: %d hours, %d minutes, %d seconds", target:Nick(), hours, minutes, seconds))
        else
            client:ChatPrint("Could not retrieve playtime for the specified target.")
        end
    end
})

lia.command.add("plyviewclaims", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "View Claims",
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

        local message = string.format("=== Claims for %s ===\nSteamID: %s\nAdmin Name: %s\nTotal Claims: %d\nLast Claim Date: %s\nTime Since Last Claim: %s", target:Nick(), steamID, claim.name, claim.claims, os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim), TimeSince(claim.lastclaim))
        client:ChatPrint(message)
    end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "View Playtime",
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notify("You must specify a player name.")
            return
        end

        local target = lia.command.findPlayer(client, targetName)
        local steamID = target:SteamID()
        local query = "SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";"
        local result = sql.QueryRow(query)
        if result then
            local playTimeInSeconds = tonumber(result.play_time) or 0
            local hours = math.floor(playTimeInSeconds / 3600)
            local minutes = math.floor((playTimeInSeconds % 3600) / 60)
            local seconds = playTimeInSeconds % 60
            local message = string.format("Playtime for %s: %d hours, %d minutes, %d seconds", steamID, hours, minutes, seconds)
            client:chatNotify(message)
        else
            client:notify("Could not retrieve playtime for the specified target.")
        end
    end
})

util.AddNetworkString("sam_blind")