--[[
    Folder: Developer - Libraries
    File: lia.workshop.md
]]
--[[
    Workshop

    Workshop downloader helpers for Lilia server content discovery, synchronization, download prompts, and clientside addon mounting.
]]
--[[
    Overview:
        The workshop library centralizes Workshop collection under `lia.workshop`. It registers server-required Workshop IDs, gathers IDs from mounted addons and module WorkshopContent entries, caches the resulting list for clients, sends workshop metadata to joining players, detects missing client content, requests missing downloads, and displays available server Workshop addons in the information menu.
]]
lia.workshop = lia.workshop or {}
lia.workshop.ids = lia.workshop.ids or {}
lia.workshop.known = lia.workshop.known or {}
if SERVER then
    --[[
    Purpose:
        Registers a Steam Workshop addon ID as required server content.

    Parameters:
        id (string|number)
            The Steam Workshop file ID to register.

    Example Usage:
        ```lua
        lia.workshop.addWorkshop("3527535922")
        lia.workshop.addWorkshop("3527535923")
        ```

    Realm:
        Server
]]
    function lia.workshop.addWorkshop(id)
        id = tostring(id)
        if not lia.workshop.ids[id] then
            lia.bootstrap(L("workshopDownloader"), L("workshopDownloading", id))
            lia.workshop.ids[id] = true
        end
    end

    local function addKnown(id)
        id = tostring(id)
        if not lia.workshop.known[id] then
            lia.workshop.known[id] = true
            lia.bootstrap(L("workshopDownloader"), L("workshopAdded", id))
        end
    end

    --[[
    Purpose:
        Collects all known server Workshop IDs from registered resources, mounted addons, and loaded module WorkshopContent definitions.

    Example Usage:
        ```lua
        local workshopIDs = lia.workshop.gather()
        for id in pairs(workshopIDs) do
            print("Server workshop content includes:", id)
        end
        ```

    Returns:
        table
            A table keyed by Workshop ID strings with true values for each required addon.

    Realm:
        Server
]]
    function lia.workshop.gather()
        local ids = table.Copy(lia.workshop.ids)
        for _, addon in pairs(engine.GetAddons() or {}) do
            if addon.mounted and addon.wsid then ids[tostring(addon.wsid)] = true end
        end

        for _, module in pairs(lia.module.list) do
            local wc = module.WorkshopContent
            if wc then
                if isstring(wc) then
                    ids[wc] = true
                else
                    for _, v in ipairs(wc) do
                        ids[tostring(v)] = true
                    end
                end
            end
        end

        for id in pairs(ids) do
            addKnown(id)
        end
        return ids
    end

    hook.Add("InitializedModules", "liaWorkshopInitializedModules", function() lia.workshop.cache = lia.workshop.gather() end)
    --[[
    Purpose:
        Sends the cached Workshop ID table to a player through the Workshop downloader start network message.

    Parameters:
        ply (Player)
            The player receiving the cached Workshop content list.

    Example Usage:
        ```lua
        local client = player.GetHumans()[1]
        if IsValid(client) then
            lia.workshop.cache = lia.workshop.cache or lia.workshop.gather()
            lia.workshop.send(client)
        end
        ```

    Realm:
        Server
]]
    function lia.workshop.send(ply)
        net.Start("liaWorkshopDownloaderStart")
        net.WriteTable(lia.workshop.cache)
        net.Send(ply)
    end

    hook.Add("PlayerInitialSpawn", "liaWorkshopInit", function(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                net.Start("liaWorkshopDownloaderInfo")
                net.WriteTable(lia.workshop.cache or {})
                net.Send(ply)
            end
        end)
    end)

    lia.workshop.addWorkshop("3527535922")
    resource.AddWorkshop = lia.workshop.addWorkshop
else
    local FORCE_ID = "3527535922"
    lia.workshop.serverIds = lia.workshop.serverIds or {}
    local function formatSize(bytes)
        if not bytes or bytes <= 0 then return "0 B" end
        local units = {"B", "KB", "MB", "GB", "TB"}
        local unit = 1
        while bytes >= 1024 and unit < #units do
            bytes = bytes / 1024
            unit = unit + 1
        end
        return string.format("%.2f %s", bytes, units[unit])
    end

    local function mounted(id)
        for _, addon in pairs(engine.GetAddons() or {}) do
            if tostring(addon.wsid or addon.workshopid) == tostring(id) and addon.mounted then return true end
        end
        return false
    end

    local function gmaDir()
        local dir = "lilia/workshop"
        if not file.IsDir(dir, "DATA") then file.CreateDir(dir) end
        return dir
    end

    local function gmaPath(id)
        return gmaDir() .. "/" .. id .. ".gma"
    end

    local function mountLocal(id)
        local rel = gmaPath(id)
        if file.Exists(rel, "DATA") then
            game.MountGMA("data/" .. rel)
            return true
        end
        return false
    end

    --[[
    Purpose:
        Checks whether the client is missing any server-required Workshop content that is not already mounted locally.

    Example Usage:
        ```lua
        if lia.workshop.hasContentToDownload() then
            chat.AddText(Color(255, 200, 0), "This server has workshop content ready to mount.")
        end
        ```

    Returns:
        boolean
            True when at least one required Workshop addon still needs to be downloaded or mounted, otherwise false.

    Realm:
        Client
]]
    function lia.workshop.hasContentToDownload()
        for id in pairs(lia.workshop.serverIds or {}) do
            if id ~= FORCE_ID and not mounted(id) and not mountLocal(id) then return true end
        end
        return false
    end

    --[[
    Purpose:
        Prompts the client to download and mount missing server-required Workshop content after calculating the total download size.

    Example Usage:
        ```lua
        if lia.workshop.hasContentToDownload() then
            lia.workshop.mountContent()
        end
        ```

    Realm:
        Client
]]
    function lia.workshop.mountContent()
        local ids = lia.workshop.serverIds or {}
        local needed = {}
        for id in pairs(ids) do
            if id ~= FORCE_ID and not mounted(id) and not mountLocal(id) then needed[#needed + 1] = id end
        end

        if #needed == 0 then
            lia.bootstrap(L("workshopDownloader"), L("workshopAllInstalled"))
            return
        end

        local pending, totalSize = #needed, 0
        for _, id in ipairs(needed) do
            steamworks.FileInfo(id, function(fi)
                if fi and fi.size then totalSize = totalSize + fi.size end
                pending = pending - 1
                if pending <= 0 then
                    lia.derma.requestPopupQuestion(L("workshopConfirmMount", formatSize(totalSize)), {
                        {
                            L("yes"),
                            function()
                                net.Start("liaWorkshopDownloaderRequest")
                                net.SendToServer()
                            end
                        },
                        {L("no")}
                    })
                end
            end)
        end
    end

    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        table.insert(pages, {
            name = "workshopAddons",
            shouldShow = function() return true end,
            drawFunc = function(parent)
                parent:Clear()
                local ids = lia.workshop.serverIds or {}
                local sheet = vgui.Create("liaSheet", parent)
                sheet:Dock(FILL)
                sheet:SetPlaceholderText(L("searchAddons"))
                local info, totalSize = {}, 0
                local pending = table.Count(ids)
                if pending <= 0 then
                    local noAddonsLabel = vgui.Create("DLabel", parent)
                    noAddonsLabel:SetText(L("noWorkshopAddonsFound"))
                    noAddonsLabel:SetContentAlignment(5)
                    noAddonsLabel:Dock(FILL)
                    noAddonsLabel:SetTextColor(Color(200, 200, 200))
                    return
                end

                local function populate()
                    for id, fi in pairs(info) do
                        if fi then
                            local percent = "0%"
                            if totalSize > 0 then percent = string.format("%.2f%%", (fi.size or 0) / totalSize * 100) end
                            local url = fi.previewurl or ""
                            if sheet.AddPreviewRow then
                                local rowData = sheet:AddPreviewRow({
                                    title = fi.title or L("idPrefix", id),
                                    desc = fi.size and L("addonSize", formatSize(fi.size), percent) or "",
                                    url = url,
                                    size = 64
                                })

                                if rowData and rowData.panel then
                                    local originalPerformLayout = rowData.panel.PerformLayout
                                    rowData.panel.PerformLayout = function(panel)
                                        if originalPerformLayout then originalPerformLayout(panel) end
                                        if not rowData.buttonContainer then
                                            local buttonContainer = vgui.Create("DPanel", panel)
                                            buttonContainer:SetWide(120)
                                            buttonContainer.Paint = function(self, w, h) draw.RoundedBox(0, 0, h - 1, w, 1, lia.config.Color and lia.config.Color.theme or Color(100, 100, 100)) end
                                            local mountButton = vgui.Create("liaSmallButton", buttonContainer)
                                            mountButton:SetText(L("mount"))
                                            mountButton:SetTall(40)
                                            mountButton:Dock(TOP)
                                            mountButton:DockMargin(0, 0, 0, 20)
                                            mountButton.DoClick = function()
                                                lia.websound.playButtonSound()
                                                steamworks.DownloadUGC(id, function(name, path)
                                                    if name and path then
                                                        LocalPlayer():notifyLocalized("workshopAddonDownloaded", fi.title or id)
                                                    else
                                                        LocalPlayer():notifyErrorLocalized("workshopAddonDownloadFailed", fi.title or id)
                                                    end
                                                end)
                                            end

                                            local linkButton = vgui.Create("liaSmallButton", buttonContainer)
                                            linkButton:SetText(L("workshop"))
                                            linkButton:SetTall(40)
                                            linkButton:Dock(TOP)
                                            linkButton.DoClick = function()
                                                lia.websound.playButtonSound()
                                                gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. id)
                                            end

                                            local panelHeight = panel:GetTall()
                                            local containerHeight = 100
                                            local centerY = (panelHeight - containerHeight) / 2
                                            buttonContainer:SetPos(panel:GetWide() - 130, math.max(5, centerY))
                                            buttonContainer:SetTall(containerHeight)
                                            rowData.buttonContainer = buttonContainer
                                        else
                                            local panelHeight = panel:GetTall()
                                            local containerHeight = 100
                                            local centerY = (panelHeight - containerHeight) / 2
                                            rowData.buttonContainer:SetPos(panel:GetWide() - 130, math.max(5, centerY))
                                        end

                                        panel:SetTall(math.max(panel:GetTall(), 112))
                                    end

                                    rowData.panel:InvalidateLayout(true)
                                end
                            elseif sheet.AddTextRow then
                                local rowData = sheet:AddTextRow({
                                    title = fi.title or L("idPrefix", id),
                                    desc = fi.size and L("addonSize", formatSize(fi.size), percent) or "",
                                    compact = true
                                })

                                if rowData and rowData.panel then
                                    local originalPerformLayout = rowData.panel.PerformLayout
                                    rowData.panel.PerformLayout = function(panel)
                                        if originalPerformLayout then originalPerformLayout(panel) end
                                        if not rowData.buttonContainer then
                                            local buttonContainer = vgui.Create("DPanel", panel)
                                            buttonContainer:SetWide(120)
                                            buttonContainer.Paint = function(self, w, h) draw.RoundedBox(0, 0, h - 1, w, 1, lia.config.Color and lia.config.Color.theme or Color(100, 100, 100)) end
                                            local mountButton = vgui.Create("liaSmallButton", buttonContainer)
                                            mountButton:SetText(L("mount"))
                                            mountButton:SetTall(40)
                                            mountButton:Dock(TOP)
                                            mountButton:DockMargin(0, 0, 0, 20)
                                            mountButton.DoClick = function()
                                                lia.websound.playButtonSound()
                                                steamworks.DownloadUGC(id, function(name, path)
                                                    if name and path then
                                                        LocalPlayer():notifyLocalized("workshopAddonDownloaded", fi.title or id)
                                                    else
                                                        LocalPlayer():notifyErrorLocalized("workshopAddonDownloadFailed", fi.title or id)
                                                    end
                                                end)
                                            end

                                            local linkButton = vgui.Create("liaSmallButton", buttonContainer)
                                            linkButton:SetText(L("workshop"))
                                            linkButton:SetTall(40)
                                            linkButton:Dock(TOP)
                                            linkButton.DoClick = function()
                                                lia.websound.playButtonSound()
                                                gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. id)
                                            end

                                            local panelHeight = panel:GetTall()
                                            local containerHeight = 100
                                            local centerY = (panelHeight - containerHeight) / 2
                                            buttonContainer:SetPos(panel:GetWide() - 130, math.max(5, centerY))
                                            buttonContainer:SetTall(containerHeight)
                                            rowData.buttonContainer = buttonContainer
                                        else
                                            local panelHeight = panel:GetTall()
                                            local containerHeight = 100
                                            local centerY = (panelHeight - containerHeight) / 2
                                            rowData.buttonContainer:SetPos(panel:GetWide() - 130, math.max(5, centerY))
                                        end

                                        panel:SetTall(math.max(panel:GetTall(), 102))
                                    end

                                    rowData.panel:InvalidateLayout(true)
                                end
                            end
                        end
                    end

                    if IsValid(sheet) and sheet.Refresh then sheet:Refresh() end
                end

                for id in pairs(ids) do
                    steamworks.FileInfo(id, function(fi)
                        info[id] = fi
                        if fi and fi.size then totalSize = totalSize + fi.size end
                        pending = pending - 1
                        if pending <= 0 then populate() end
                    end)
                end
            end
        })
    end)
end
