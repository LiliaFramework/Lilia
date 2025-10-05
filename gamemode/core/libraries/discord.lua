lia.discord = lia.discord or {}
lia.discord.webhook = lia.discord.webhook or ""
function lia.discord.relayMessage(embed)
    if not lia.discord.webhook or lia.discord.webhook == "" or not istable(embed) then return end
    local ForceHTTPMode = not util.IsBinaryModuleInstalled("chttp")
    embed.title = embed.title or L("discordRelayLilia")
    embed.color = tonumber(embed.color) or 7506394
    embed.timestamp = embed.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")
    embed.footer = embed.footer or {
        text = L("discordRelayLiliaDiscordRelay")
    }

    local payload = {
        embeds = {embed},
        username = L("discordRelayLiliaLogger")
    }

    hook.Run("DiscordRelaySend", embed)
    if util.IsBinaryModuleInstalled("chttp") and not ForceHTTPMode then
        require("chttp")
        CHTTP({
            url = lia.discord.webhook,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = util.TableToJSON(payload)
        })
    else
        if not ForceHTTPMode then hook.Run("DiscordRelayUnavailable") end
        http.Post(lia.discord.webhook, {
            payload_json = util.TableToJSON(payload)
        }, function() end, function(err) print(L("discordRelayHTTPFailed") .. " " .. tostring(err)) end)
    end

    hook.Run("DiscordRelayed", embed)
end
