lia.command.add("plyviewclaims", {
    adminOnly = true,
    privilege = "View Claims",
    desc = "plyViewClaimsDesc",
    syntax = "[player Name]",
    AdminStick = {
        Name = "viewTicketClaims",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/page_white_text.png"
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:ChatPrint(L("mustSpecifyPlayer"))
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local steamID = target:SteamID64()
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            local claim = caseclaims[steamID]
            if not claim then
                client:ChatPrint(L("noClaimsFound"))
                return
            end

            local claimedFor = L("none")
            if not table.IsEmpty(claim.claimedFor) then
                claimedFor = table.concat((function()
                    local t = {}
                    for sid, name in pairs(claim.claimedFor) do
                        table.insert(t, string.format("%s (%s)", name, sid))
                    end
                    return t
                end)(), "\n")
            end

            local claimsData = {
                {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = claimedFor
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
    privilege = "View Claims",
    desc = "viewAllClaimsDesc",
    onRun = function(client)
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:ChatPrint(L("noClaimsRecorded"))
                return
            end

            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                local claimedFor = L("none")
                if not table.IsEmpty(claim.claimedFor) then
                    claimedFor = table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), ", ")
                end

                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = claimedFor
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
    privilege = "View Claims",
    desc = "viewClaimsDesc",
    onRun = function(client)
        MODULE:GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:ChatPrint(L("noClaimsData"))
                return
            end

            lia.log.add(client, "viewAllClaims")
            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                local claimedFor = L("none")
                if not table.IsEmpty(claim.claimedFor) then
                    claimedFor = table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                end

                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.TimeSince(claim.lastclaim),
                    claimedFor = claimedFor
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
