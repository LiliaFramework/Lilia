ICON = {}
ICON.font = "wolficonfont"
ICON.characters = {
    trash = "-",
    male = "a",
    female = "b",
    bank = "d",
    tick = "e",
    phone = "CALL",
    hamburger = "g"
}

function ICON:GetIconChar(iconDesc)
    return self.characters[iconDesc] or "nil"
end
