---
function PerfectCasino.Config.AddMoney(client, amount)
    client:getChar():setMoney(client:getChar():getMoney() + amount)
end
---
