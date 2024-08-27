local lastcheck = CurTime()
function MODULE:CanDeleteChar(_, character)
    if IsValid(character) and character:getMoney() < lia.config.DefaultMoney then return false end
end

local function SendToServer()
    net.Start("IAmHackingOwO")
    net.SendToServer()
end

function MODULE:Think()
    if CurTime() - lastcheck > 2 then
        for _, command in ipairs(self.HackCommands) do
            if concommand.GetTable()[command] then SendToServer() end
        end

        for _, cvar in ipairs(self.BadCVars) do
            if ConVarExists(cvar) then SendToServer() end
        end

        for _, globalName in ipairs(self.HackGlobals) do
            if _G[globalName] ~= nil then SendToServer() end
        end

        lastcheck = CurTime()
    end
end

function MODULE:InitPostEntity()
    local client = LocalPlayer()
    if self.AltsDisabled and file.Exists("default_spawnicon.png", "DATA") then
        local text = file.Read("default_spawnicon.png", "DATA")
        net.Start("lia_alting_checkID")
        net.WriteString(text)
        net.SendToServer()
    else
        file.Write("default_spawnicon.png", client:SteamID())
    end
end