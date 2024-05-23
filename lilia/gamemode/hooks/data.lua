﻿local GM = GM or GAMEMODE
function GM:PreCleanupMap()
    lia.shuttingDown = true
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end

function GM:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    for _, v in player.Iterator() do
        v:saveLiliaData()
        if v:getChar() then v:getChar():save() end
    end
end
