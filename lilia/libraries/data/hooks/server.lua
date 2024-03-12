
function GAMEMODE:PreCleanupMap()
    lia.shuttingDown = true
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end

function GAMEMODE:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

function GAMEMODE:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    for _, v in ipairs(player.GetAll()) do
        v:saveLiliaData()
        if v:getChar() then v:getChar():save() end
    end
end
