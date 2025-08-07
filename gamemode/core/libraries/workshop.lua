--[[
# Workshop Library

This page documents the functions for working with Steam Workshop content and addon management.

---

## Overview

The workshop library provides utilities for managing Steam Workshop content within the Lilia framework. It handles Workshop ID tracking, addon downloading, and provides functions for gathering and managing required Workshop content. The library supports automatic Workshop content detection and provides utilities for ensuring all required addons are available.
]]
lia.workshop = lia.workshop or {}
if SERVER then
    lia.workshop.ids = lia.workshop.ids or {}
    lia.workshop.known = lia.workshop.known or {}
    lia.workshop.cache = lia.workshop.cache or {}
    --[[
        lia.workshop.AddWorkshop

        Purpose:
            Adds a Workshop addon ID to the list of required Workshop content for the server.
            Notifies users via bootstrap messages when a new Workshop ID is added and when it begins downloading.

        Parameters:
            id (string or number) - The Workshop ID to add.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Add a Workshop addon to the server's required content
            lia.workshop.AddWorkshop("1234567890")
    ]]
    function lia.workshop.AddWorkshop(id)
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
        lia.workshop.gather

        Purpose:
            Gathers all Workshop IDs required by the server, including those added manually and those specified by modules.
            Also marks all found IDs as known.

        Parameters:
            None.

        Returns:
            (table) - A table of all required Workshop IDs as keys.

        Realm:
            Server.

        Example Usage:
            -- Gather all Workshop IDs and print them
            local ids = lia.workshop.gather()
            for id in pairs(ids) do
                print("Workshop ID required:", id)
            end
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
        lia.workshop.send

        Purpose:
            Sends the current Workshop cache (list of required Workshop IDs) to a specific player via a network message.

        Parameters:
            ply (Player) - The player to send the Workshop cache to.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Send the Workshop cache to a player when they join
            hook.Add("PlayerInitialSpawn", "SendWorkshopCache", function(ply)
                lia.workshop.send(ply)
            end)
    ]]
    function lia.workshop.send(ply)
        net.Start("WorkshopDownloader_Start")
        net.WriteTable(lia.workshop.cache)
        net.Send(ply)
    end

    hook.Add("PlayerInitialSpawn", "liaWorkshopInit", function(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                net.Start("WorkshopDownloader_Info")
                net.WriteTable(lia.workshop.cache or {})
                net.Send(ply)
            end
        end)
    end)

    net.Receive("WorkshopDownloader_Request", function(_, client) lia.workshop.send(client) end)
    lia.workshop.AddWorkshop("3527535922")
    resource.AddWorkshop = lia.workshop.AddWorkshop
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
        local ip = game.GetIPAddress() or "0.0.0.0"
        ip = string.gsub(ip, ":", "_")
        local dir = "lilia/" .. engine.ActiveGamemode() .. "_" .. ip
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
        lia.workshop.hasContentToDownload

        Purpose:
            Checks if there is any Workshop content required by the server that the client does not have mounted or downloaded locally.

        Parameters:
            None.

        Returns:
            (boolean) - True if there is content to download, false otherwise.

        Realm:
            Client.

        Example Usage:
            if lia.workshop.hasContentToDownload() then
                print("You need to download additional Workshop content!")
            end
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
        panel.bar = vgui.Create("DProgressBar", panel)
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

    net.Receive("WorkshopDownloader_Start", function()
        refresh(net.ReadTable())
        buildQueue(true)
        start()
    end)

    net.Receive("WorkshopDownloader_Info", function() refresh(net.ReadTable()) end)
    --[[
        lia.workshop.mountContent

        Purpose:
            Prompts the user to download and mount all missing Workshop content required by the server.
            Calculates the total size of missing content and shows a confirmation dialog before starting the download.

        Parameters:
            None.

        Returns:
            None.

        Realm:
            Client.

        Example Usage:
            -- Mount all missing Workshop content when a button is pressed
            concommand.Add("lia_mount_workshop", function()
                lia.workshop.mountContent()
            end)
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
                        net.Start("WorkshopDownloader_Request")
                        net.SendToServer()
                    end, L("no"))
                end
            end)
        end
    end

    concommand.Add("workshop_force_redownload", function()
        table.Empty(queue)
        buildQueue(true)
        start()
        lia.bootstrap(L("workshopDownloader"), L("workshopForcedRedownload"))
    end)

    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        table.insert(pages, {
            name = L("workshopAddons"),
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
