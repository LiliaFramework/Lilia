--------------------------------------------------------------------------------------------------------
lia.config.BanRequest = "I WANT TO GET BANNED SO BADDDLLLLYYYY"
lia.config.BanGiven = " had their wish granted!"
lia.config.BlacklistEnabled = true
--------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawn(client)
    local IPAddress = client:IPAddress()
    local SteamID = client:SteamID()
    if not client:getChar() or not lia.config.BlacklistEnabled then return end

    if table.HasValue(self.BlacklistedIPAddress, IPAddress) then
        self:SpecialFunction(client)
    end

    if table.HasValue(self.BlacklistedSteamID, SteamID) then
        self:SpecialFunction(client)
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:SpecialFunction(client)
    client:Say("// ".. lia.config.BanRequest)

    timer.Simple(5, function()
        local steamIDToBan = client:SteamID()
        local banDuration = 0
        local command = string.format("banid %d %s", banDuration, steamIDToBan)
        game.ConsoleCommand(command .. "\n")

        timer.Simple(1, function()
            for _, ply in pairs(player.GetAll()) do
                ply:ChatPrint(client:GetName() .. lia.config.BanGiven)
            end
        end)
    end)
end
--------------------------------------------------------------------------------------------------------