function lia.currency.spawn(pos, amount, angle)
    if not pos then
        print("[Lilia] Can't create currency entity: Invalid Position")
    elseif not amount or amount < 0 then
        print("[Lilia] Can't create currency entity: Invalid Amount of money")
    else
        local money = ents.Create("lia_money")
        money:SetPos(pos)
        money:setAmount(math.Round(math.abs(amount)))
        money:SetAngles(angle or Angle(0, 0, 0))
        money:Spawn()
        money:Activate()
        return money
    end
end
