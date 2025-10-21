DeriveGamemode("sandbox")
include("shared.lua")
local hudImages = {
    armor = Material("armor.png"),
    drug = Material("drug.png"),
    cuffed = Material("cuffed.png"),
    emptyframe = Material("emptyframe.png"),
    backgroundsquare = Material("backgroundsquare.png")
}

-- HUD Configuration
local hudConfig = {
    imageSize = 82, -- 15% smaller than 96
    spacing = 10, -- Hardcoded spacing to match reference image
    position = {
        x = 20, -- Will be calculated dynamically
        y = 0
    },
    alpha = 255
}

-- HUD State tracking
local hudState = {
    showArmor = true,
    showDrug = true,
    showCuffed = true,
    showEmptyFrame = true
}

-- Function to draw HUD images
local function drawHUDImages()
    local x = hudConfig.position.x + 30 -- Moved a bit to the right
    local y = ScrH() - 480 -- Raised icons a bit more
    local size = hudConfig.imageSize
    local spacing = hudConfig.spacing
    -- Draw armor icon (top)
    surface.SetDrawColor(255, 255, 255, hudConfig.alpha)
    surface.SetMaterial(hudImages.armor)
    surface.DrawTexturedRect(x, y, size, size)
    -- Draw armor text
    draw.SimpleText("ARMOUR", "DermaDefault", x + size + 10, y + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("+100 Armour Active", "DermaDefault", x + size + 10, y + 45, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    -- Draw drug icon (middle) - directly below armor
    surface.SetDrawColor(255, 255, 255, hudConfig.alpha)
    surface.SetMaterial(hudImages.drug)
    surface.DrawTexturedRect(x, y + size + 10, size, size) -- Hardcoded spacing of 10
    -- Draw drug text
    draw.SimpleText("DRUGGED", "DermaDefault", x + size + 10, y + size + 10 + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("Speed Boost Active", "DermaDefault", x + size + 10, y + size + 10 + 45, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    -- Draw cuffed icon (bottom) - directly below drug
    surface.SetDrawColor(255, 255, 255, hudConfig.alpha)
    surface.SetMaterial(hudImages.cuffed)
    surface.DrawTexturedRect(x, y + (size + 10) * 2, size, size) -- Hardcoded spacing of 10
    -- Draw cuffed text
    draw.SimpleText("HANDCUFFED", "DermaDefault", x + size + 10, y + (size + 10) * 2 + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText("Restricted Movement Active", "DermaDefault", x + size + 10, y + (size + 10) * 2 + 45, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    -- Draw background square below handcuffed (3x size and moved way up)
    surface.SetDrawColor(255, 255, 255, hudConfig.alpha)
    surface.SetMaterial(hudImages.backgroundsquare)
    surface.DrawTexturedRect(x, y + (size + 10) * 3 - 90, size * 3, size * 3)
    -- Draw empty frame (all the way to the right)
    surface.SetDrawColor(255, 255, 255, hudConfig.alpha)
    surface.SetMaterial(hudImages.emptyframe)
    surface.DrawTexturedRect(ScrW() - size - 20, y, size, size) -- Right side positioning
end

hook.Add("HUDPaint", "CustomHUDImages", function()
    local client = LocalPlayer()
    if not IsValid(client) or not client:getChar() then return end
    -- Update HUD state based on player conditions
    hudState.showArmor = client:Armor() > 0
    hudState.showDrug = true
    hudState.showCuffed = true
    hudState.showEmptyFrame = true -- Always show empty frame
    -- Draw the HUD images
    drawHUDImages()
end)

hook.Add("ShouldHideBars", "YourHookName", function()
    return true -- Hides all bars
end)

hook.Add("ShouldDrawAmmo", "YourHookName", function(bar) end)