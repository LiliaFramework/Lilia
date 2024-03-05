function OpenPlayerModelUI(target)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Change Playermodel")
    frame:SetSize(450, 300)
    frame:Center()
    function frame:OnClose()
        frame:Remove()
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local wrapper = vgui.Create("DIconLayout", scroll)
    wrapper:Dock(FILL)
    local edit = vgui.Create("DTextEntry", frame)
    edit:Dock(BOTTOM)
    edit:SetText(target:GetModel())
    local button = vgui.Create("DButton", frame)
    button:SetText("Change")
    button:Dock(TOP)
    function button:DoClick()
        local txt = edit:GetValue()
        RunConsoleCommand("say", "/charsetmodel " .. target:SteamID() .. " " .. txt)
        frame:Remove()
    end

    for name, model in SortedPairs(player_manager.AllValidModels()) do
        local icon = wrapper:Add("SpawnIcon")
        icon:SetModel(model)
        icon:SetSize(64, 64)
        icon:SetTooltip(name)
        icon.playermodel = name
        icon.model_path = model
        icon.DoClick = function(self) edit:SetValue(self.model_path) end
    end

    frame:MakePopup()
end
