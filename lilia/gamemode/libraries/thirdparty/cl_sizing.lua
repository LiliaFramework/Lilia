function C(value, isWidth)
    local screenWidth, screenHeight = ScrW(), ScrH()
    local widthRatio = screenWidth / 1920
    local heightRatio = screenHeight / 1080
    return isWidth and (value * widthRatio) or (value * heightRatio)
end