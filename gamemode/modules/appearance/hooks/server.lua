function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    lia.util.applyBodygroups(client, character:getBodygroups())
    client:SetSkin(character:getSkin())
end

function MODULE:PlayerDisconnected(client)
    lia.appearance.removeUser(client)
end

function MODULE:ShouldEntityLoad(data)
    if istable(data) and data.class == "lia_bodygrouper" then data.class = "lia_wardrobe" end
end
