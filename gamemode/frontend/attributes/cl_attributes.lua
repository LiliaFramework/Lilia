--------------------------------------------------------------------------------------------------------
hook.Add("ConfigureCharacterCreationSteps", "AttribOnCharInfoSetup", function(panel)
    panel:addStep(vgui.Create("liaCharacterAttribs"), 99)
end)
--------------------------------------------------------------------------------------------------------