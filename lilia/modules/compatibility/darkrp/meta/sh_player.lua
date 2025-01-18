local playerMeta = FindMetaTable("Player")
function playerMeta:getDarkRPVar(var)
  local char = self:getChar()
  if var ~= "money" then
    self:ChatPrint("Invalid variable requested! Only 'money' can be fetched. Please refer to our Discord for help.")
    return nil
  end

  if char and char.getMoney then return char:getMoney() end
end

function playerMeta:getMoney()
  local character = self:getChar()
  return character and character:getMoney() or 0
end

function playerMeta:canAfford(amount)
  local character = self:getChar()
  return character and character:hasMoney(amount)
end

if SERVER then
  function playerMeta:addMoney(amount)
    local character = self:getChar()
    if not character then return false end
    local client = self
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    local totalMoney = currentMoney + amount
    if maxMoneyLimit > 0 and isnumber(maxMoneyLimit) and totalMoney > maxMoneyLimit then
      local excessMoney = totalMoney - maxMoneyLimit
      character:setMoney(maxMoneyLimit)
      client:notifyLocalized("moneyLimit", lia.currency.get(maxMoneyLimit), lia.currency.plural, lia.currency.get(excessMoney), lia.currency.plural)
      local money = lia.currency.spawn(client:getItemDropPos(), excessMoney)
      if IsValid(money) then
        money.client = client
        money.charID = character:getID()
      end

      lia.log.add(client, "money", maxMoneyLimit - currentMoney)
    else
      character:setMoney(totalMoney)
      lia.log.add(client, "money", amount)
    end
    return true
  end

  function playerMeta:takeMoney(amount)
    local character = self:getChar()
    if character then character:giveMoney(-amount) end
  end
end
