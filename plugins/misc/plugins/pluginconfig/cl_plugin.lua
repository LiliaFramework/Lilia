local PLUGIN = PLUGIN

function PLUGIN:createPluginPanel(parent, plugins)
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L"Plugins")
    frame:SetSize(256, 512)
    frame:MakePopup()
    frame:Center()
    frame.plugins = {}
    local loading = frame:Add("DLabel")
    loading:Dock(FILL)
    loading:SetText(L"loading")
    loading:SetContentAlignment(5)
    lia.gui.pluginConfig = frame
    local info = frame:Add("DLabel")
    info:SetText("The map must be restarted after making changes!")
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 4)
    info:SetContentAlignment(5)
    local scroll = frame:Add("DScrollPanel")
    scroll:Dock(FILL)

    local function onChange(box, value)
        local plugin = box.plugin
        if not plugin then return end
        net.Start("liaPluginDisable")
        net.WriteString(plugin)
        net.WriteBit(value)
        net.SendToServer()
    end

    hook.Add("RetrievedPluginList", frame, function(_, plugins)
        for name, disabled in SortedPairs(plugins) do
            local box = scroll:Add("DCheckBoxLabel")
            box:Dock(TOP)
            box:DockMargin(0, 0, 0, 4)
            box:SetValue(disabled)
            box:SetText(name)
            box.plugin = name
            box.OnChange = onChange
            frame.plugins[name] = box
        end

        loading:Remove()
    end)

    hook.Add("PluginConfigDisabled", frame, function(_, plugin, disabled)
        local box = frame.plugins[plugin]

        if IsValid(box) then
            box:SetValue(disabled)
        end
    end)

    net.Start("liaPluginList")
    net.SendToServer()
end

function PLUGIN:CreateConfigPanel(parent)
    local button = parent:Add("DButton")
    button:SetText(L"Plugins")
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 8)
    button:SetSkin("Default")

    button.DoClick = function(button)
        self:createPluginPanel(parent)
    end
end

net.Receive("liaPluginList", function()
    local length = net.ReadUInt(32)
    local plugins = {}

    for i = 1, length do
        plugins[net.ReadString()] = net.ReadBit() == 1
    end

    hook.Run("RetrievedPluginList", plugins)
end)

net.Receive("liaPluginDisable", function()
    local name = net.ReadString()
    local disabled = net.ReadBit() == 1
    hook.Run("PluginConfigDisabled", name, disabled)
end)