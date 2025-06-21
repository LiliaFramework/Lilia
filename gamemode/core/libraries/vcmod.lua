--[[
    VC_canAfford(client, amount)

    Description:
        Determines if the client has enough money for a VCMod transaction
        using their character's money total.

    Parameters:
        client (Player) – Player attempting the purchase.
        amount (number) – Money required.

    Realm:
        Shared

    Returns:
        boolean – True when the character has sufficient funds.
]]
hook.Add("VC_canAfford", "VCMOD_VC_canAfford", function(client, amount)
    if client:getChar():hasMoney(amount) then return true end
    return false
end)

if SERVER then
    --[[
        VC_canAddMoney(client, amount)

        Description:
            Called by VCMod when it wants to give money to a player.
            The character's balance is increased instead of letting VCMod
            handle it.

        Parameters:
            client (Player) – Player receiving the money.
            amount (number) – Amount to add.

        Realm:
            Server

        Returns:
            boolean – Always false to prevent VCMod from modifying money.
    ]]
    hook.Add("VC_canAddMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():giveMoney(amount)
        return false
    end)

    --[[
        VC_canRemoveMoney(client, amount)

        Description:
            Invoked by VCMod when it tries to take money from a player. This
            deducts funds from the character and stops VCMod from performing
            its own deduction.

        Parameters:
            client (Player) – Player whose money is being taken.
            amount (number) – Amount to deduct.

        Realm:
            Server

        Returns:
            boolean – Always false to block VCMod from handling money.
    ]]
    hook.Add("VC_canRemoveMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():takeMoney(amount)
        return false
    end)
end
