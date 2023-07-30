function MODULE:ConfigureCharacterCreationSteps(panel)
    if lia.config.add("GamemodeInformation", false) then
        panel:addStep(vgui.Create("liaStartInfo"), 1)
    end
end