--[[
    Workshop Library
    Steam Workshop addon downloading, mounting, and management system for the Lilia framework.
]]
--[[
    Overview:
    The workshop library provides comprehensive functionality for managing Steam Workshop addons in the Lilia framework. It handles automatic downloading, mounting, and management of workshop content required by the gamemode and its modules. The library operates on both server and client sides, with the server gathering workshop IDs from modules and mounted addons, while the client handles downloading and mounting of required content. It includes user interface elements for download progress tracking and addon information display. The library ensures that all required workshop content is available before gameplay begins.
]]
lia.workshop = lia.workshop or {}
if SERVER then
    lia.workshop.ids = lia.workshop.ids or {}
    lia.workshop.known = lia.workshop.known or {}
    lia.workshop.cache = lia.workshop.cache or {}
    --[[
        Purpose: Adds a workshop addon ID to the server's required workshop content list
        When Called: Called when modules or addons need specific workshop content
        Parameters: id (string/number) - The Steam Workshop ID of the addon to add
        Returns: None
        Realm: Server
        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Add a single workshop addon
            lia.workshop.addWorkshop("1234567890")
            ```
        Medium Complexity:
            ```lua
            -- Medium: Add workshop addon from module configuration
            local workshopId = module.WorkshopContent
            if workshopId then
                lia.workshop.addWorkshop(workshopId)
            end
            ```
        High Complexity:
            ```lua
            -- High: Add multiple workshop addons with validation
            local workshopIds = {"1234567890", "0987654321", "1122334455"}
            for _, id in ipairs(workshopIds) do
                if id and id ~= "" then
                    lia.workshop.addWorkshop(id)
                end
            end
            ```
    ]]
    function lia.workshop.addWorkshop(id)
        id = tostring(id)
        if not lia.workshop.ids[id] then lia.bootstrap(L("workshopDownloader"), L("workshopAdded", id)) end
        lia.bootstrap(L("workshopDownloader"), L("workshopDownloading", id))
        lia.workshop.ids[id] = true
    end

    local function addKnown(id)
        id = tostring(id)
        if not lia.workshop.known[id] then
            lia.workshop.known[id] = true
            lia.bootstrap(L("workshopDownloader"), L("workshopAdded", id))
        end
    end

    --[[
        Purpose: Gathers all workshop IDs from mounted addons and module configurations
        When Called: Called during module initialization to collect all required workshop content
        Parameters: None
        Returns: table - Table containing all workshop IDs that need to be downloaded
        Realm: Server
        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Gather workshop IDs
            local workshopIds = lia.workshop.gather()
            ```
        Medium Complexity:
            ```lua
            -- Medium: Gather and validate workshop IDs
            local workshopIds = lia.workshop.gather()
            local count = table.Count(workshopIds)
            print("Found " .. count .. " workshop addons")
            ```
        High Complexity:
            ```lua
            -- High: Gather workshop IDs and send to specific players
            local workshopIds = lia.workshop.gather()
            for _, ply in pairs(player.GetAll()) do
                if ply:IsAdmin() then
                    net.Start("liaWorkshopDownloaderStart")
                    net.WriteTable(workshopIds)
                    net.Send(ply)
                end
            end
            ```
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
        Purpose: Sends the cached workshop IDs to a specific player to initiate download
        When Called: Called when a player requests workshop content or during initial spawn
        Parameters: ply (Player) - The player to send workshop IDs to
        Returns: None
        Realm: Server
        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Send workshop IDs to a player
            lia.workshop.send(player.GetByID(1))
            ```
        Medium Complexity:
            ```lua
            -- Medium: Send workshop IDs to admin players only
            for _, ply in pairs(player.GetAll()) do
                if ply:IsAdmin() then
                    lia.workshop.send(ply)
                end
            end
            ```
        High Complexity:
            ```lua
            -- High: Send workshop IDs with validation and logging
            local function sendToPlayer(ply)
                if IsValid(ply) and ply:IsConnected() then
                    lia.workshop.send(ply)
                    print("Sent workshop IDs to " .. ply:Name())
                end
            end
            hook.Add("PlayerInitialSpawn", "CustomWorkshopSend", function(ply)
                timer.Simple(5, function()
                    sendToPlayer(ply)
                end)
            end)
            ```
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

    net.Receive("liaWorkshopDownloaderRequest", function(_, client) lia.workshop.send(client) end)
    lia.workshop.addWorkshop("3527535922")
    resource.AddWorkshop = lia.workshop.addWorkshop
else
    local FORCE_ID = "3527535922"
    local MOUNT_DELAY = 3
    local queue, panel, totalDownloads, remainingDownloads = {}, nil, 0, 0
    lia.workshop.serverIds = lia.workshop.serverIds or {}
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
        Purpose: Checks if there are any workshop addons that need to be downloaded
        When Called: Called to determine if the client needs to download workshop content
        Parameters: None
        Returns: boolean - True if content needs to be downloaded, false otherwise
        Realm: Client
        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Check if downloads are needed
            if lia.workshop.hasContentToDownload() then
                print("Workshop content needs to be downloaded")
            end
            ```
        Medium Complexity:
            ```lua
            -- Medium: Check and show notification
            if lia.workshop.hasContentToDownload() then
                notification.AddLegacy("Workshop content available for download", NOTIFY_GENERIC, 5)
            end
            ```
        High Complexity:
            ```lua
            -- High: Check downloads and create custom UI
            local function checkDownloads()
                if lia.workshop.hasContentToDownload() then
                    local frame = vgui.Create("DFrame")
                    frame:SetTitle("Workshop Downloads Available")
                    frame:SetSize(400, 200)
                    frame:Center()
                    frame:MakePopup()
                    local btn = vgui.Create("DButton", frame)
                    btn:SetText("Download Now")
                    btn:Dock(BOTTOM)
                    btn.DoClick = function()
                        lia.workshop.mountContent()
                        frame:Close()
                    end
                end
            end
            hook.Add("OnEntityCreated", "CheckWorkshopDownloads", function(ent)
                if ent == LocalPlayer() then
                    timer.Simple(1, checkDownloads)
                end
            end)
            ```
    ]]
    function lia.workshop.hasContentToDownload()
        for id in pairs(lia.workshop.serverIds or {}) do
            if id ~= FORCE_ID and not mounted(id) and not mountLocal(id) then return true end
        end
        return false
    end

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

    local function uiCreate()
        if panel and panel:IsValid() then return end
        surface.SetFont("DermaLarge")
        local tw, th = surface.GetTextSize(L("downloadingWorkshopAddonsTitle"))
        local pad, bh = 10, 20
        local w, h = math.max(tw, 200) + pad * 2, th + bh + pad * 3
        panel = vgui.Create("DPanel")
        panel:SetSize(w, h)
        panel:SetPos((ScrW() - w) / 2, ScrH() * 0.1)
        panel:SetZPos(10000)
        panel:MoveToFront()
        derma.SkinHook("Paint", "Panel", panel, w, h)
        local lbl = vgui.Create("DLabel", panel)
        lbl:SetFont("DermaLarge")
        lbl:SetText(L("downloadingWorkshopAddonsTitle"))
        lbl:SizeToContents()
        lbl:SetPos(pad, pad)
        panel.bar = vgui.Create("liaDProgressBar", panel)
        panel.bar:SetPos(pad, pad + th + pad)
        panel.bar:SetSize(w - pad * 2, bh)
        panel.bar:SetFraction(0)
    end

    local function uiUpdate()
        if not (panel and panel:IsValid()) then return end
        panel.bar:SetFraction(totalDownloads > 0 and (totalDownloads - remainingDownloads) / totalDownloads or 0)
        panel.bar:SetText(totalDownloads - remainingDownloads .. "/" .. totalDownloads)
    end

    local function start()
        for id in pairs(queue) do
            if mounted(id) or mountLocal(id) then queue[id] = nil end
        end

        local seq, idx = {}, 1
        for id in pairs(queue) do
            seq[#seq + 1] = id
        end

        totalDownloads = #seq
        remainingDownloads = totalDownloads
        if totalDownloads == 0 then
            lia.bootstrap(L("workshopDownloader"), L("workshopAllInstalled"))
            return
        end

        uiCreate()
        uiUpdate()
        local function nextItem()
            if idx > #seq then
                if panel and panel:IsValid() then
                    panel:Remove()
                    panel = nil
                end
                return
            end

            local id = seq[idx]
            lia.bootstrap(L("workshopDownloader"), L("workshopDownloading", id))
            steamworks.DownloadUGC(id, function(path)
                remainingDownloads = remainingDownloads - 1
                lia.bootstrap(L("workshopDownloader"), L("workshopDownloadComplete", id))
                if path then
                    local rel = gmaPath(id)
                    local data = file.Read(path, "GAME")
                    if data then
                        file.Write(rel, data)
                        path = "data/" .. rel
                    end

                    game.MountGMA(path)
                end

                uiUpdate()
                idx = idx + 1
                timer.Simple(MOUNT_DELAY, nextItem)
            end)
        end

        nextItem()
    end

    local function buildQueue(all)
        table.Empty(queue)
        for id in pairs(lia.workshop.serverIds or {}) do
            if id == FORCE_ID or all then queue[id] = true end
        end
    end

    local function refresh(tbl)
        if tbl then lia.workshop.serverIds = tbl end
        for id in pairs(lia.workshop.serverIds or {}) do
            if id ~= FORCE_ID then mountLocal(id) end
        end
    end

    net.Receive("liaWorkshopDownloaderStart", function()
        refresh(net.ReadTable())
        buildQueue(true)
        start()
    end)

    net.Receive("liaWorkshopDownloaderInfo", function() refresh(net.ReadTable()) end)
    --[[
        Purpose: Initiates the mounting process for required workshop content with user confirmation
        When Called: Called when the client needs to download and mount workshop addons
        Parameters: None
        Returns: None
        Realm: Client
        Example Usage:
        Low Complexity:
            ```lua
            -- Simple: Mount workshop content
            lia.workshop.mountContent()
            ```
        Medium Complexity:
            ```lua
            -- Medium: Mount content with custom callback
            lia.workshop.mountContent()
            hook.Add("Think", "CheckMountComplete", function()
                if not lia.workshop.hasContentToDownload() then
                    print("All workshop content mounted successfully")
                    hook.Remove("Think", "CheckMountComplete")
                end
            end)
            ```
        High Complexity:
            ```lua
            -- High: Mount content with progress tracking and custom UI
            local function mountWithProgress()
                local needed = {}
                local ids = lia.workshop.serverIds or {}
                for id in pairs(ids) do
                    if id ~= "3527535922" and not mounted(id) and not mountLocal(id) then
                        needed[#needed + 1] = id
                    end
                end
                if #needed > 0 then
                    local frame = vgui.Create("DFrame")
                    frame:SetTitle("Workshop Content Download")
                    frame:SetSize(500, 300)
                    frame:Center()
                    frame:MakePopup()
                    local progress = vgui.Create("DProgress", frame)
                    progress:Dock(TOP)
                    progress:SetHeight(30)
                    local function updateProgress(current, total)
                        progress:SetFraction(current / total)
                        progress:SetText(current .. "/" .. total)
                    end
                    lia.workshop.mountContent()
                end
            end
            hook.Add("PlayerInitialSpawn", "MountWorkshopContent", function(ply)
                if ply == LocalPlayer() then
                    timer.Simple(3, mountWithProgress)
                end
            end)
            ```
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
                    Derma_Query(L("workshopConfirmMount", formatSize(totalSize)), L("workshopDownloader"), L("yes"), function()
                        net.Start("liaWorkshopDownloaderRequest")
                        net.SendToServer()
                    end, L("no"))
                end
            end)
        end
    end

    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        table.insert(pages, {
            name = "workshopAddons",
            drawFunc = function(parent)
                parent:Clear()
                local ids = lia.workshop.serverIds or {}
                local sheet = vgui.Create("liaSheet", parent)
                sheet:Dock(FILL)
                sheet:SetPlaceholderText(L("searchAddons"))
                local info, totalSize = {}, 0
                local pending = table.Count(ids)
                if pending <= 0 then return end
                local function populate()
                    for id, fi in pairs(info) do
                        if fi then
                            local percent = "0%"
                            if totalSize > 0 then percent = string.format("%.2f%%", (fi.size or 0) / totalSize * 100) end
                            local url = fi.previewurl or ""
                            if sheet.AddPreviewRow then
                                sheet:AddPreviewRow({
                                    title = fi.title or L("idPrefix", id),
                                    desc = fi.size and L("addonSize", formatSize(fi.size), percent) or "",
                                    url = url,
                                    size = 64
                                })
                            elseif sheet.AddTextRow then
                                sheet:AddTextRow({
                                    title = fi.title or L("idPrefix", id),
                                    desc = fi.size and L("addonSize", formatSize(fi.size), percent) or "",
                                    compact = true
                                })
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
