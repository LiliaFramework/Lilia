function MODULE:PlayerGetFistDamage(client, damage, context)
    local character = client:getChar()

    -- Add to the total fist damage.
    if character and character.getAttrib then
        local multiplier = CONFIG.StrMultiplier
        local bonus = character:getAttrib("str", 0) * multiplier
        context.damage = context.damage + bonus
    end
end

function MODULE:PlayerThrowPunch(client, hit)
    if client:getChar() then
        client:getChar():updateAttrib("str", 0.001)
    end
end