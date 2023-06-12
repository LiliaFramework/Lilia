function PLUGIN:PlayerGetFistDamage(client, damage, context)
    local character = client:getChar()

    -- Add to the total fist damage.
    if character and character.getAttrib then
        local multiplier = lia.config.get("strMultiplier", 0.1)
        local bonus = character:getAttrib("str", 0) * multiplier
        context.damage = context.damage + bonus
    end
end

function PLUGIN:PlayerThrowPunch(client, hit)
    if client:getChar() then
        client:getChar():updateAttrib("str", 0.001)
    end
end