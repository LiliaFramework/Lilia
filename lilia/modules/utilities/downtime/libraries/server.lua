MODULE.isDownTime = false
function MODULE:PlayerLoadedChar()
    if not self.EnableDownTime then return end
    local players = player.GetAll()
    local playerCount = #players
    local playeramount = self.RPMinimumPlayerCount
    if playerCount < playeramount and not self.isDownTime then
        self.isDownTime = true
    elseif playerCount >= playeramount and self.isDownTime then
        lia.util.notify("Downtime is over.", players)
        self.isDownTime = false
    end
end