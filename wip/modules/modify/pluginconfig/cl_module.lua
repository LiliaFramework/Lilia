local MODULE = MODULE

function MODULE:createModulePanel(parent, modules)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Tick to Disable The Checkmarked Modules")
    frame:SetSize(256, 512)
    frame:MakePopup()
    frame:Center()
    frame.modules = {}
    local loading = frame:Add("DLabel")
    loading:Dock(FILL)
    loading:SetText(L"loading")
    loading:SetContentAlignment(5)
    lia.gui.moduleConfig = frame
    local info = frame:Add("DLabel")
    info:SetText("The map must be restarted after making changes!")
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 4)
    info:SetContentAlignment(5)
    local scroll = frame:Add("DScrollPanel")
    scroll:Dock(FILL)

    local function onChange(box, value)
        local module = box.module
        if not module then return end
        net.Start("liaModuleDisable")
        net.WriteString(module)
        net.WriteBit(value)
        net.SendToServer()
    end

    hook.Add("RetrievedModuleList", frame, function(_, modules)
        for name, disabled in SortedPairs(modules) do
            local box = scroll:Add("DCheckBoxLabel")
            box:Dock(TOP)
            box:DockMargin(0, 0, 0, 4)
            box:SetValue(disabled)
            box:SetText(name)
            box.module = name
            box.OnChange = onChange
            frame.modules[name] = box
        end

        loading:Remove()
    end)

    hook.Add("ModuleConfigDisabled", frame, function(_, module, disabled)
        local box = frame.modules[module]

        if IsValid(box) then
            box:SetValue(disabled)
        end
    end)

    net.Start("liaModuleList")
    net.SendToServer()
end

function MODULE:CreateConfigPanel(parent)
    local button = parent:Add("DButton")
    button:SetText(L"Modules")
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 8)
    button:SetSkin("Default")

    button.DoClick = function(button)
        self:createModulePanel(parent)
    end
end

net.Receive("liaModuleList", function()
    local length = net.ReadUInt(32)
    local modules = {}

    for i = 1, length do
        modules[net.ReadString()] = net.ReadBit() == 1
    end

    hook.Run("RetrievedModuleList", modules)
end)

net.Receive("liaModuleDisable", function()
    local name = net.ReadString()
    local disabled = net.ReadBit() == 1
    hook.Run("ModuleConfigDisabled", name, disabled)
end)