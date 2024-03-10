---
-- Whether or not a player can switch to this class.
--
-- @param client Client that wants to switch to this class
-- @treturn bool True if the player is allowed to switch to this class
--
function CLASS:onCanBe(client)
    return client:IsAdmin() or client:getChar():hasFlags("Z") -- Only admins or people with the Z flag are allowed in this class!
end

---
-- Called when a character has left this class and has joined a different one. You can get the class the character has
-- joined by calling `character:GetClass()`.
--
-- @param client Player who left this class
--
function CLASS:onLeave(client)
end

---
-- Called when a character has joined this class.
--
-- @param client Player who has joined this class
--
function CLASS:onSet(client)
    client:SetModel("models/police.mdl")
end

---
-- Called when a character in this class has spawned in the world.
--
-- @param client Player that has just spawned
--
function CLASS:onSpawn(client)
    client:SetMaxHealth(500) -- Sets your Max Health to 500
    client:SetHealth(500) -- Subsequently sets your Health to 500
end