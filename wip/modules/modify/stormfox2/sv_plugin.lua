function MODULE:OnLoaded()
    if StormFox2 and lia.config.get("StormFox2Compatibility", true) then
        timer.Simple(2, function()
            local dt = string.Explode(":", os.date("%H:%M:%S", lia.date.get()))
            StormFox2.Time.Set(dt[1] * 60 + dt[2] + (dt[3] / 60))
            StormFox2.Setting.Set("time_speed", 1)
        end)
    end
end

function MODULE:PlayerConnect(ply)
    if StormFox2 and lia.config.get("StormFox2Compatibility", true) then
        if #player.GetAll() == 0 then
            local dt = string.Explode(":", os.date("%H:%M:%S", lia.date.get()))
            StormFox2.Time.Set(dt[1] * 60 + dt[2] + (dt[3] / 60))
        end
    end
end
