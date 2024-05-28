MODULE.NextRestart = 0
MODULE.NextNotificationTime = 0
MODULE.IsRestarting = false
MODULE.TimeRemainingTable = {30, 15, 5, 1, 0}
MODULE.ServerRestartHour = 5
function MODULE:InitializedModules()
    self.NextRestart = self:GetInitialRestartTime()
    self.NextNotificationTime = self:GetNextNotificationTimeBreakpoint()
end

function MODULE:GetTimeToRestart()
    local time = os.time()
    time = self.NextRestart - time
    return time
end

function MODULE:NotifyServerRestart(client, timeRemaining)
    local timeRemainingMinutes = math.Round(timeRemaining / 60)
    client:notify("Server is restarting in " .. timeRemainingMinutes .. " minutes!")
end

function MODULE:CharLoaded(id)
    local character = lia.char.loaded[id]
    timer.Simple(0, function()
        local timeRemaining = self:GetTimeToRestart()
        local timeRemainingInMinutes = timeRemaining / 60
        if timeRemainingInMinutes < self.TimeRemainingTable[1] then self:NotifyServerRestart(character:getPlayer(), self:GetTimeToRestart()) end
    end)
end

function MODULE:GetInitialRestartTime()
    local temp = os.date("*t")
    local timeNowStruct
    if temp.hour >= self.ServerRestartHour then
        timeNowStruct = os.date("*t", os.time() + (24 * 60 * 60))
    else
        timeNowStruct = os.date("*t")
    end

    timeNowStruct.hour = self.ServerRestartHour
    timeNowStruct.min = 0
    timeNowStruct.sec = 0
    local timestamp = os.time(timeNowStruct)
    return timestamp
end

function MODULE:GetInitialNotificationTime()
    local nextBreakpoint = self:GetNextNotificationTimeBreakpoint()
    return self.NextRestart - nextBreakpoint
end

function MODULE:GetNextNotificationTimeBreakpoint()
    local timeMinutes = self:GetTimeToRestart() / 60
    for i = 1, #self.TimeRemainingTable do
        if timeMinutes >= self.TimeRemainingTable[i] then return self.TimeRemainingTable[i] * 60 end
    end
end

function MODULE:Think()
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

function MODULE:ServerSidePlayerInitialSpawn()
    local music = ents.FindByName("music")
    if #music > 0 then
        music[1]:SetKeyValue("RefireTime", 99999999)
        music[1]:Fire("Disable")
        music[1]:Fire("Kill")
    end

    if player.GetCount() >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        for _, car in pairs(ents.GetAll()) do
            if car:IsVehicle() then car:Remove() end
        end

        print("Cars deleted. Player count reached the limit. Please disable MODULE.PlayerCountCarLimitEnabled if you don't want this. ")
    end
end

function MODULE:PlayerSpawnVehicle(client)
    if player.GetCount() >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        client:notify("You can't spawn this as the playerlimit to spawn car has been hit!")
        return false
    end
end

function MODULE:PropBreak(_, entity)
    if entity:IsValid() and entity:GetPhysicsObject():IsValid() then constraint.RemoveAll(entity) end
end

function MODULE:PreGamemodeLoaded()
    function widgets.PlayerTick()
    end

    hook.Remove("PlayerTick", "TickWidgets")
end

function MODULE:EntityRemoved(entity)
    if entity:IsRagdoll() and not entity:getNetVar("player", nil) and self.RagdollCleaningTimer > 0 then
        timer.Simple(self.RagdollCleaningTimer, function()
            if not IsValid(entity) then return end
            entity:SetSaveValue("m_bFadingOut", true)
            timer.Simple(3, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end)
    end
end

function MODULE:Initialize()
    hook.Remove("OnEntityCreated", "WidgetInit")
    hook.Remove("Think", "DOFThink")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
    hook.Remove("PlayerDisconnected", "DarkRP_ChatIndicator")
    hook.Remove("LoadGModSave", "LoadGModSave")
    timer.Remove("CheckHookTimes")
    timer.Remove("HostnameThink")
end