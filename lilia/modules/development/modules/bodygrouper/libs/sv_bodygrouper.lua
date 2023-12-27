--------------------------------------------------------------------------------------------------------------------------
function MODULE:BodygrouperClosetAddUser(closet, user)
    local opensound = lia.config.BodygrouperOpenSound
    if opensound then closet:EmitSound(opensound) end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:BodygrouperClosetRemoveUser(closet, user)
    local closesound = lia.config.BodygrouperCloseSound
    if closesound then closet:EmitSound(closesound) end
end
--------------------------------------------------------------------------------------------------------------------------
