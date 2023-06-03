-- If we're close to restarting, let the client know
function PLUGIN:CharacterLoaded(character)
    timer.Simple(0, function()
        local timeRemaining = self:GetTimeToRestart()
        local timeRemainingInMinutes = timeRemaining / 60

        if timeRemainingInMinutes < self.TimeRemainingTable[1] then
            self:NotifyServerRestart(character:GetPlayer(), self:GetTimeToRestart())
        end
    end)
end

function PLUGIN:GetTimeToRestart()
    local time = os.time()
    time = self.NextRestart - time

    return time
end

function PLUGIN:NotifyServerRestart(client, timeRemaining)
    local timeRemainingMinutes = math.Round(timeRemaining / 60)
    client:notify("Server is restarting in " .. timeRemainingMinutes .. " minutes!")
end

function PLUGIN:GetInitialRestartTime()
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

function PLUGIN:GetInitialNotificationTime()
    local nextBreakpoint = self:GetNextNotificationTimeBreakpoint()

    return self.NextRestart - nextBreakpoint
end

function PLUGIN:GetNextNotificationTimeBreakpoint()
    local timeMinutes = self:GetTimeToRestart() / 60

    for i = 1, #self.TimeRemainingTable do
        if timeMinutes >= self.TimeRemainingTable[i] then return self.TimeRemainingTable[i] * 60 end -- convert back to seconds
    end
end

function PLUGIN:Think()
    if self.IsRestarting == true then return end

    if self.NextRestart == 0 then
        self.NextRestart = self:GetInitialRestartTime()
        self.NextNotificationTime = self:GetInitialNotificationTime()

        return
    end

    local time = os.time()

    if time > self.NextNotificationTime or time > self.NextRestart then
        local nextBreakpoint = self:GetNextNotificationTimeBreakpoint()

        if not nextBreakpoint then
            self.IsRestarting = true
            RunConsoleCommand("changelevel", game.GetMap())
        else
            for _, v in pairs(player.GetAll()) do
                self:NotifyServerRestart(v, self:GetTimeToRestart())
            end

            self.NextNotificationTime = self.NextRestart - nextBreakpoint
        end
    end
end