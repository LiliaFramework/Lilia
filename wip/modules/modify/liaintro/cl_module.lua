function MODULE:CreateIntroduction()
    if CONFIG.IntroEnabled then return vgui.Create("liaIntro") end
end