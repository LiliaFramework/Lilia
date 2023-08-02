local CONFIG = CONFIG

function MODULE:CharacterLoaded(character)
    timer.Simple(0, function()
        local timeRemaining = self:GetTimeToRestart()
        local timeRemainingInMinutes = timeRemaining / 60

        if timeRemainingInMinutes < lia.config.TimeRemainingTable[1] then
            self:NotifyServerRestart(character:GetPlayer(), self:GetTimeToRestart())
        end
    end)
end

function MODULE:GetTimeToRestart()
    local time = os.time()
    time = lia.config.NextRestart - time

    return time
end

function MODULE:NotifyServerRestart(client, timeRemaining)
    local timeRemainingMinutes = math.Round(timeRemaining / 60)
    client:notify("Server is restarting in " .. timeRemainingMinutes .. " minutes!")
end

function MODULE:GetInitialRestartTime()
    local temp = os.date("*t")
    local timeNowStruct

    if temp.hour >= lia.config.get("serverRestartHour") then
        timeNowStruct = os.date("*t", os.time() + (24 * 60 * 60)) -- we add a day this way, to account for date cancer
    else
        timeNowStruct = os.date("*t")
    end

    timeNowStruct.hour = lia.config.get("serverRestartHour") -- restart on the hour given in config
    timeNowStruct.min = 0 -- restart on the same minute
    timeNowStruct.sec = 0 -- restart on the same second
    local timestamp = os.time(timeNowStruct)

    return timestamp
end

function MODULE:GetInitialNotificationTime()
    local nextBreakpoint = self:GetNextNotificationTimeBreakpoint()

    return lia.config.NextRestart - nextBreakpoint
end

function MODULE:GetNextNotificationTimeBreakpoint()
    local timeMinutes = self:GetTimeToRestart() / 60

    for i = 1, #lia.config.TimeRemainingTable do
        if timeMinutes >= lia.config.TimeRemainingTable[i] then return lia.config.TimeRemainingTable[i] * 60 end -- convert back to seconds
    end
end

function MODULE:Think()
    if lia.config.IsRestarting == true then return end

    if lia.config.NextRestart == 0 then
        lia.config.NextRestart = self:GetInitialRestartTime()
        lia.config.NextNotificationTime = self:GetInitialNotificationTime()

        return
    end

    local time = os.time()

    if time > lia.config.NextNotificationTime or time > lia.config.NextRestart then
        local nextBreakpoint = self:GetNextNotificationTimeBreakpoint()

        if not nextBreakpoint then
            lia.config.IsRestarting = true
            RunConsoleCommand("changelevel", game.GetMap())
        else
            for _, v in pairs(player.GetAll()) do
                self:NotifyServerRestart(v, self:GetTimeToRestart())
            end

            lia.config.NextNotificationTime = lia.config.NextRestart - nextBreakpoint
        end
    end
end