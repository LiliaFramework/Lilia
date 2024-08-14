function MODULE:BodygrouperClosetAddUser(closet)
    local opensound = self.BodygrouperOpenSound
    if opensound then closet:EmitSound(opensound) end
end

function MODULE:BodygrouperClosetRemoveUser(closet)
    local closesound = self.BodygrouperCloseSound
    if closesound then closet:EmitSound(closesound) end
end
