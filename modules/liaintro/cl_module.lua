function MODULE:CreateIntroduction()
    if lia.config.IntroEnabled then return vgui.Create("liaIntro") end
end