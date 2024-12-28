local BodygrouperOpenSound = "doors/door_metal_thin_open1.wav"
local BodygrouperCloseSound = "doors/door_metal_thin_close2.wav"

function MODULE:BodygrouperClosetAddUser(closet)
    local opensound = BodygrouperOpenSound
    if opensound then closet:EmitSound(opensound) end
end

function MODULE:BodygrouperClosetRemoveUser(closet)
    local closesound = BodygrouperCloseSound
    if closesound then closet:EmitSound(closesound) end
end
