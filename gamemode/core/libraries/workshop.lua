lia = lia or {}
lia.workshop = lia.workshop or {}
if SERVER then
    lia.workshop.ids = lia.workshop.ids or {}
    lia.workshop.known = lia.workshop.known or {}
    lia.workshop.cache = lia.workshop.cache or {}
    lia.workshop.newAddonsCount = 0
    local function addKnown(id)
        id = tostring(id)
        if id ~= "" and not lia.workshop.known[id] then
            lia.workshop.known[id] = true
            lia.workshop.newAddonsCount = lia.workshop.newAddonsCount + 1
        end
    end

    function lia.workshop.Add(id)
        id = tostring(id)
        if id ~= "" and not lia.workshop.ids[id] then
            lia.workshop.ids[id] = true
            addKnown(id)
        end
    end

    function lia.workshop.Gather()
        local ids = table.Copy(lia.workshop.ids)
        for _, a in pairs(engine.GetAddons() or {}) do
            if a.mounted and a.wsid then ids[tostring(a.wsid)] = true end
        end

        for _, m in pairs(lia.module and lia.module.list or {}) do
            local wc = m.WorkshopContent
            if wc then
                if isstring(wc) then
                    ids[tostring(wc)] = true
                elseif istable(wc) then
                    for _, v in ipairs(wc) do
                        ids[tostring(v)] = true
                    end
                end
            end
        end

        for id in pairs(ids) do
            addKnown(id)
        end

        lia.workshop.cache = ids
        return ids
    end

    hook.Add("InitializedModules", "lia_ws_seed_cache", function() lia.workshop.Gather() end)
    function lia.workshop.Send(ply)
        net.Start("lia_ws_start")
        net.WriteTable(lia.workshop.cache or {})
        net.Send(ply)
    end

    hook.Add("PlayerInitialSpawn", "lia_ws_sync_on_join", function(ply)
        timer.Simple(1.5, function()
            if not IsValid(ply) then return end
            net.Start("lia_ws_ids")
            net.WriteTable(lia.workshop.cache or {})
            net.Send(ply)
        end)
    end)

    net.Receive("lia_ws_request", function(_, ply)
        if not IsValid(ply) then return end
        lia.workshop.Send(ply)
    end)

    resource.AddWorkshop = function(id) lia.workshop.Add(id) end
else
    lia.workshop.serverIds = lia.workshop.serverIds or {}
    lia.workshop.mounted = lia.workshop.mounted or {}
    lia.workshop.mountCounts = lia.workshop.mountCounts or {}
    lia.workshop.queue = lia.workshop.queue or {}
    lia.workshop.active = lia.workshop.active or false
    local function mountedByEngine(id)
        id = tostring(id)
        for _, a in pairs(engine.GetAddons() or {}) do
            local ws = tostring(a.wsid or a.workshopid or "")
            if ws == id and a.mounted then return true end
        end
        return false
    end

    function lia.workshop.IsMounted(id)
        id = tostring(id)
        if lia.workshop.mounted[id] then return true end
        if mountedByEngine(id) then return true end
        return false
    end

    local function mountFromPath(id, path)
        local res = game.MountGMA(path)
        local ok = res and true or false
        local c = istable(res) and #res or 0
        if ok then
            lia.workshop.mounted[id] = true
            lia.workshop.mountCounts[id] = c
            print("[lia.workshop] Mounted " .. c .. " files from addon " .. id)
            return true, c
        end

        print("[lia.workshop] Mount failed for addon " .. id .. " - trying alternative methods")
        print("[lia.workshop]   Path: " .. tostring(path))
        if string.find(path, "gmpublisher%.gma$") then
            local altPath = string.gsub(path, "/gmpublisher%.gma$", ".gma")
            if altPath ~= path then
                local res2 = game.MountGMA(altPath)
                local ok2 = res2 and true or false
                local c2 = istable(res2) and #res2 or 0
                if ok2 then
                    lia.workshop.mounted[id] = true
                    lia.workshop.mountCounts[id] = c2
                    print("[lia.workshop] Mounted " .. c2 .. " files from addon " .. id .. " via alternative path")
                    return true, c2
                end
            end
        end
        return false, 0
    end

    function lia.workshop.Enqueue(id)
        id = tostring(id)
        if id == "" then return end
        if lia.workshop.IsMounted(id) then return end
        lia.workshop.serverIds[id] = true
        lia.workshop.queue[#lia.workshop.queue + 1] = id
        print("[lia.workshop] Queued addon " .. id .. " for mounting")
        if not lia.workshop.active then lia.workshop.ProcessQueue() end
    end

    function lia.workshop.ProcessQueue()
        if lia.workshop.active then return end
        if #lia.workshop.queue == 0 then return end
        if not steamworks then return end
        lia.workshop.active = true
        local id = table.remove(lia.workshop.queue, 1)
        print("[lia.workshop] Starting mount process for addon " .. id)
        print("[lia.workshop] Downloading addon " .. id .. " from Steam Workshop")
        steamworks.DownloadUGC(id, function(path)
            if not path or path == "" then
                print("[lia.workshop] Failed to download addon " .. id .. " - no path returned")
                lia.workshop.active = false
                timer.Simple(0, lia.workshop.ProcessQueue)
                return
            end

            print("[lia.workshop] Download completed for addon " .. id .. ", path: " .. path)
            local ok = select(1, mountFromPath(id, path))
            if not ok and string.find(path, "gmpublisher%.gma$") then
                print("[lia.workshop] Attempting direct alternative path for GMPublisher addon")
                local altPath = string.gsub(path, "/gmpublisher%.gma$", ".gma")
                if altPath ~= path then ok = select(1, mountFromPath(id, altPath)) end
            end

            if ok then
                print("[lia.workshop] Successfully mounted addon " .. id)
            else
                print("[lia.workshop] Failed to mount addon " .. id)
            end

            lia.workshop.active = false
            timer.Simple(0, lia.workshop.ProcessQueue)
        end)
    end

    net.Receive("lia_ws_start", function()
        local ids = net.ReadTable() or {}
        lia.workshop.serverIds = {}
        for id in pairs(ids) do
            lia.workshop.serverIds[id] = true
        end
    end)

    net.Receive("lia_ws_ids", function()
        local ids = net.ReadTable() or {}
        for id in pairs(ids) do
            lia.workshop.serverIds[id] = true
        end
    end)

    hook.Add("Initialize", "lia_ws_seed_engine", function()
        for _, a in pairs(engine.GetAddons() or {}) do
            local id = tostring(a.wsid or a.workshopid or "")
            if id ~= "" and a.mounted then
                lia.workshop.mounted[id] = true
                lia.workshop.mountCounts[id] = lia.workshop.mountCounts[id] or 0
            end
        end
    end)

    hook.Add("Think", "lia_ws_request_once", function()
        hook.Remove("Think", "lia_ws_request_once")
        net.Start("lia_ws_request")
        net.SendToServer()
    end)

    concommand.Add("lia_workshop_status", function()
        local t = {}
        for id in pairs(lia.workshop.serverIds or {}) do
            local s = lia.workshop.IsMounted(id)
            local c = lia.workshop.mountCounts[id] or 0
            t[#t + 1] = string.format("%s: %s (%d files)", id, s and "mounted" or "not mounted", c)
        end

        if #t == 0 then
            print("[lia.workshop] no ids")
            return
        end

        print("[lia.workshop] status")
        for _, line in ipairs(t) do
            print("  " .. line)
        end
    end)

    function lia.workshop.hasContentToDownload()
        if not lia.workshop.serverIds then return false end
        for id in pairs(lia.workshop.serverIds) do
            if not lia.workshop.IsMounted(id) then return true end
        end
        return false
    end

    function lia.workshop.mountContent()
        if not lia.workshop.hasContentToDownload() then
            LocalPlayer():notifyLocalized("workshopAllInstalled")
            return
        end

        local missingAddons = {}
        for id in pairs(lia.workshop.serverIds or {}) do
            if not lia.workshop.IsMounted(id) then table.insert(missingAddons, id) end
        end

        if #missingAddons == 0 then
            LocalPlayer():notifyLocalized("workshopAllInstalled")
            return
        end

        local function confirmMount()
            local progressFrame = vgui.Create("DFrame")
            progressFrame:SetSize(500, 300)
            progressFrame:Center()
            progressFrame:SetTitle(L("workshopDownloader"))
            progressFrame:SetDraggable(false)
            progressFrame:SetDeleteOnClose(true)
            progressFrame:MakePopup()
            local statusLabel = vgui.Create("DLabel", progressFrame)
            statusLabel:SetPos(20, 40)
            statusLabel:SetSize(460, 30)
            statusLabel:SetText(L("workshopMounting"))
            statusLabel:SetFont("DermaDefault")
            local progressBar = vgui.Create("DProgressBar", progressFrame)
            progressBar:SetPos(20, 80)
            progressBar:SetSize(460, 20)
            progressBar:SetFraction(0)
            local addonList = vgui.Create("DListView", progressFrame)
            addonList:SetPos(20, 120)
            addonList:SetSize(460, 150)
            addonList:AddColumn("Addon ID")
            addonList:AddColumn("Status")
            for _, id in ipairs(missingAddons) do
                addonList:AddLine(id, "Pending")
            end

            local mountedCount = 0
            local totalCount = #missingAddons
            local function updateProgress()
                mountedCount = mountedCount + 1
                local progress = mountedCount / totalCount
                if IsValid(progressBar) and progressBar.SetFraction then progressBar:SetFraction(progress) end
                if mountedCount < totalCount then
                    if IsValid(statusLabel) and statusLabel.SetText then statusLabel:SetText(L("workshopMountingAddon", missingAddons[mountedCount + 1], mountedCount + 1, totalCount)) end
                    return
                end

                if IsValid(statusLabel) and statusLabel.SetText then statusLabel:SetText(L("workshopMountComplete")) end
                timer.Simple(3, function() if IsValid(progressFrame) then progressFrame:Close() end end)
            end

            local function updateAddonStatus(id, status)
                if not IsValid(addonList) then return end
                if not addonList.GetLineCount then return end
                for i = 1, addonList:GetLineCount() do
                    local line = addonList:GetLine(i)
                    if line and line.GetValue and line:GetValue(1) == id then
                        line:SetColumnText(2, status)
                        break
                    end
                end
            end

            local originalEnqueue = lia.workshop.Enqueue
            lia.workshop.Enqueue = function(id)
                updateAddonStatus(id, "Mounting...")
                local result = originalEnqueue(id)
                local checkCount = 0
                local maxChecks = 30
                local checkInterval = 1
                local function checkMountStatus()
                    checkCount = checkCount + 1
                    if lia.workshop.IsMounted(id) then
                        updateAddonStatus(id, "Mounted")
                        updateProgress()
                        return
                    end

                    if checkCount >= maxChecks then
                        updateAddonStatus(id, "Failed")
                        LocalPlayer():notifyLocalized("workshopMountFailed", id)
                        updateProgress()
                        return
                    end

                    local nextInterval = checkInterval
                    if checkCount > 5 then nextInterval = checkInterval * 1.5 end
                    timer.Simple(nextInterval, checkMountStatus)
                end

                timer.Simple(1, checkMountStatus)
                return result
            end

            for i, id in ipairs(missingAddons) do
                timer.Simple(i * 3, function() lia.workshop.Enqueue(id) end)
            end

            timer.Simple(totalCount * 3 + 5, function() lia.workshop.Enqueue = originalEnqueue end)
        end

        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 200)
        frame:Center()
        frame:SetTitle(L("workshopDownloader"))
        frame:SetDraggable(false)
        frame:SetDeleteOnClose(true)
        frame:MakePopup()
        local label = vgui.Create("DLabel", frame)
        label:SetPos(20, 40)
        label:SetSize(360, 60)
        label:SetText(L("workshopMountConfirm", #missingAddons))
        label:SetWrap(true)
        local yesBtn = vgui.Create("DButton", frame)
        yesBtn:SetPos(50, 120)
        yesBtn:SetSize(100, 30)
        yesBtn:SetText("Yes")
        yesBtn.DoClick = function()
            frame:Close()
            confirmMount()
        end

        local noBtn = vgui.Create("DButton", frame)
        noBtn:SetPos(250, 120)
        noBtn:SetSize(100, 30)
        noBtn:SetText("No")
        noBtn.DoClick = function() frame:Close() end
    end

    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        table.insert(pages, {
            name = "workshopAddons",
            drawFunc = function(parent)
                local ids = lia.workshop.serverIds or {}
                local sheet = vgui.Create("liaSheet", parent)
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
