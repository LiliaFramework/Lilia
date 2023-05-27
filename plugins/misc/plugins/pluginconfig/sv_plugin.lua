local PLUGIN = PLUGIN
util.AddNetworkString("liaPluginDisable")
util.AddNetworkString("liaPluginList")

function PLUGIN:getPluginList()
    if self.computedPlugins then return self.computedPlugins end
    local plugins = {}
    local found = {}

    local function findPlugins(path)
        local files, folders = file.Find(path .. "/*", "LUA")

        for _, folder in ipairs(folders) do
            if not file.Exists(path .. "/" .. folder .. "/sh_plugin.lua", "LUA") or found[folder] then continue end
            plugins[#plugins + 1] = folder
            found[folder] = true
            findPlugins(path .. "/" .. folder .. "/plugins")
        end

        for _, fileName in ipairs(files) do
            local pluginID = string.StripExtension(fileName)

            if string.GetExtensionFromFilename(fileName) == "lua" and not found[pluginID] then
                plugins[#plugins + 1] = pluginID
                found[pluginID] = true
            end
        end
    end

    findPlugins("lilia/plugins")
    findPlugins(SCHEMA.folder .. "/plugins")
    self.computedPlugins = plugins

    return plugins
end

function PLUGIN:setPluginDisabled(name, disabled)
    lia.plugin.setDisabled(name, disabled)
    self.overwrite[name] = disabled
    net.Start("liaPluginDisable")
    net.WriteString(name)
    net.WriteBit(disabled)
    net.Send(lia.util.getAdmins(true))
end

concommand.Add("lia_disableplugin", function(client, _, arguments)
    if IsValid(client) and not client:IsSuperAdmin() then return end
    local name = arguments[1]
    local disabled = tobool(arguments[2])
    PLUGIN:setPluginDisabled(name, disabled)
    local message = name .. " is now " .. (disabled and "disabled" or "enabled")

    if IsValid(client) then
        client:ChatPrint(message)
    end

    print(message)
end)

net.Receive("liaPluginDisable", function(_, client)
    if not client:IsSuperAdmin() then return end
    local name = net.ReadString()
    local disabled = net.ReadBit() == 1
    PLUGIN:setPluginDisabled(name, disabled)
end)

net.Receive("liaPluginList", function(_, client)
    if not client:IsSuperAdmin() then return end
    local plugins = PLUGIN:getPluginList()
    local disabled, plugin
    net.Start("liaPluginList")
    net.WriteUInt(#plugins, 32)

    for k, plugin in ipairs(plugins) do
        if PLUGIN.overwrite[plugin] ~= nil then
            disabled = PLUGIN.overwrite[plugin]
        else
            disabled = lia.plugin.isDisabled(plugin)
        end

        net.WriteString(plugin)
        net.WriteBit(disabled)
    end

    net.Send(client)
end)