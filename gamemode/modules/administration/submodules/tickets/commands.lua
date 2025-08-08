local MODULE = MODULE
lia.command.add("viewtickets", {
    adminOnly = true,
    privilege = "viewClaims",
    desc = "viewTicketsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyLocalized("mustSpecifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        local steamID, displayName
        if IsValid(target) then
            steamID = target:SteamID()
            displayName = target:Nick()
        else
            steamID = targetName
            displayName = targetName
        end

        MODULE:GetTicketsByRequester(steamID):next(function(tickets)
            if #tickets == 0 then
                client:notifyLocalized("noTicketsFound")
                return
            end

            local ticketsData = {}
            for _, ticket in ipairs(tickets) do
                ticketsData[#ticketsData + 1] = {
                    timestamp = os.date("%Y-%m-%d %H:%M:%S", ticket.timestamp),
                    admin = string.format("%s (%s)", ticket.admin or L("na"), ticket.adminSteamID or L("na")),
                    message = ticket.message or ""
                }
            end

            lia.util.CreateTableUI(client, L("ticketsForTitle", displayName), {
                {
                    name = L("timestamp"),
                    field = "timestamp"
                },
                {
                    name = L("admin"),
                    field = "admin"
                },
                {
                    name = L("message"),
                    field = "message"
                }
            }, ticketsData)

            lia.log.add(client, "viewPlayerTickets", displayName)
        end)
    end
})

lia.command.add("plyviewclaims", {
    adminOnly = true,
    privilege = "viewClaims",
    desc = "plyViewClaimsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "viewTicketClaims",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/page_white_text.png"
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyLocalized("mustSpecifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local steamID = target:SteamID()
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            local claim = caseclaims[steamID]
            if not claim then
                client:notifyLocalized("noClaimsFound")
                return
            end

            local claimsData = {
                {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                }
            }

            lia.util.CreateTableUI(client, L("claimsForTitle", target:Nick()), {
                {
                    name = L("steamID"),
                    field = "steamID"
                },
                {
                    name = L("adminName"),
                    field = "name"
                },
                {
                    name = L("totalClaims"),
                    field = "claims"
                },
                {
                    name = L("lastClaimDate"),
                    field = "lastclaim"
                },
                {
                    name = L("timeSinceLastClaim"),
                    field = "timeSinceLastClaim"
                },
                {
                    name = L("claimedFor"),
                    field = "claimedFor"
                }
            }, claimsData)

            lia.log.add(client, "viewPlayerClaims", target:Name())
        end)
    end
})

lia.command.add("viewallclaims", {
    adminOnly = true,
    privilege = "viewClaims",
    desc = "viewAllClaimsDesc",
    onRun = function(client)
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyLocalized("noClaimsRecorded")
                return
            end

            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), ", ")
                })
            end

            lia.util.CreateTableUI(client, L("adminClaimsTitle"), {
                {
                    name = L("steamID"),
                    field = "steamID"
                },
                {
                    name = L("adminName"),
                    field = "name"
                },
                {
                    name = L("totalClaims"),
                    field = "claims"
                },
                {
                    name = L("lastClaimDate"),
                    field = "lastclaim"
                },
                {
                    name = L("timeSinceLastClaim"),
                    field = "timeSinceLastClaim"
                },
                {
                    name = L("claimedFor"),
                    field = "claimedFor"
                }
            }, claimsData)

            lia.log.add(client, "viewAllClaims")
        end)
    end
})

lia.command.add("viewclaims", {
    adminOnly = true,
    privilege = "viewClaims",
    desc = "viewClaimsDesc",
    onRun = function(client)
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyLocalized("noClaimsData")
                return
            end

            lia.log.add(client, "viewAllClaims")
            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                })
            end

            lia.util.CreateTableUI(client, L("adminClaimsTitle"), {
                {
                    name = L("steamID"),
                    field = "steamID"
                },
                {
                    name = L("adminName"),
                    field = "name"
                },
                {
                    name = L("totalClaims"),
                    field = "claims"
                },
                {
                    name = L("lastClaimDate"),
                    field = "lastclaim"
                },
                {
                    name = L("timeSinceLastClaim"),
                    field = "timeSinceLastClaim"
                },
                {
                    name = L("claimedFor"),
                    field = "claimedFor"
                }
            }, claimsData)
        end)
    end
})