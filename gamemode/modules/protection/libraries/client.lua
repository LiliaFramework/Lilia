local TRIGGER_KEYS = {
    [KEY_HOME] = true,
    [KEY_INSERT] = true,
    [KEY_DELETE] = true,
}

local function getEntityDisplayName(ent)
    if not IsValid(ent) then return L("unknownEntity") end
    if ent:GetClass() == "lia_item" and ent.getItemTable then
        local item = ent:getItemTable()
        if item and item.getName then
            return item:getName()
        elseif item and item.name then
            return item.name
        end
    end

    if ent:GetClass() == "lia_vendor" then
        local vendorName = ent:getName()
        if vendorName and vendorName ~= "" then return vendorName end
    end

    if ent:GetClass() == "lia_storage" then
        local storageInfo = ent:getStorageInfo()
        if storageInfo and storageInfo.name then return storageInfo.name end
    end

    if ent:IsPlayer() and ent:getChar() then return ent:getChar():getName() end
    if ent:IsVehicle() then
        local vehicleName = ent:GetVehicleClass()
        if vehicleName and vehicleName ~= "" then return vehicleName end
    end

    if ent.PrintName and ent.PrintName ~= "" then return ent.PrintName end
    local className = ent:GetClass()
    if className:StartWith("lia_") then return className:sub(5):gsub("_", " "):gsub("^%l", string.upper) end
    return className
end

function MODULE:CanDeleteChar(client, character)
    if IsValid(character) and character:getMoney() < lia.config.get("DefaultMoney") then return false end
end

function MODULE:DrawPhysgunBeam(client)
    return client == LocalPlayer()
end

function MODULE:PlayerButtonDown(client, key)
    if TRIGGER_KEYS[key] then
        timer.Remove("clipboard_blocker")
        local endAt = CurTime() + 30
        SetClipboardText("")
        timer.Create("clipboard_blocker", 0.4, 0, function()
            if CurTime() >= endAt then
                timer.Remove("clipboard_blocker")
                return
            end

            SetClipboardText("")
        end)
    end

    if key == KEY_INSERT and IsFirstTimePredicted() then
        local ply = LocalPlayer()
        if IsValid(ply) and ply == client then
            net.Start("liaInsertKeyPressed")
            net.SendToServer()
        end
    end
end

function MODULE:InitPostEntity()
    local client = LocalPlayer()
    if not file.Exists("cache", "DATA") then file.CreateDir("cache") end
    local filename = "cache/icon32.png"
    if lia.config.get("AltsDisabled", false) and file.Exists(filename, "DATA") then
        net.Start("liaCheckSeed")
        net.WriteString(file.Read(filename, "DATA"))
        net.SendToServer()
    else
        file.Write(filename, client:SteamID())
    end
end

function MODULE:requestEntityTabData(force)
    if self.entityTabRequestPending and not force then return end
    if not force and self.entityTabLastRequest and self.entityTabLastRequest > CurTime() - 2 then return end
    self.entityTabRequestPending = true
    self.entityTabLastRequest = CurTime()
    lia.debug("[Entity Tab Debug]", "Requesting server entity tab payload")
    net.Start("liaRequestEntityTabData")
    net.SendToServer()
end

function MODULE:populateEntityTabPanel(entPanel)
    if not IsValid(entPanel) then return end
    local client = LocalPlayer()
    local entityData = self.entityTabData or {
        owners = {},
        totalEntities = 0
    }

    local owners = istable(entityData.owners) and entityData.owners or {}
    entPanel:Clear()
    entPanel:DockPadding(6, 6, 6, 6)
    entPanel.Paint = nil
    if #owners == 0 then
        local message = self.entityTabRequestPending and L("loading") or "No tracked player-created entities found."
        local label = vgui.Create("DLabel", entPanel)
        label:Dock(TOP)
        label:SetTall(32)
        label:SetFont("LiliaFont.25")
        label:SetTextColor(color_white)
        label:SetText(message)
        local refresh = vgui.Create("liaButton", entPanel)
        refresh:Dock(TOP)
        refresh:SetTall(36)
        refresh:SetText("Refresh Entity Data")
        refresh.DoClick = function() self:requestEntityTabData(true) end
        return
    end

    lia.debug("[Entity Tab Debug]", "Drawing entity tab", "owners=", tostring(#owners), "totalEntities=", tostring(entityData.totalEntities or 0))
    local sheetContainer = vgui.Create("liaTabs", entPanel)
    sheetContainer:Dock(FILL)
    local function startSpectateView(ent, originalThirdPerson)
        local yaw = client:EyeAngles().yaw
        local camZOffset = 50
        client.IsInAdminEntityView = true
        hook.Add("CalcView", "EntityViewCalcView", function()
            return {
                origin = ent:GetPos() + Angle(0, yaw, 0):Forward() * 100 + Vector(0, 0, camZOffset),
                angles = Angle(0, yaw, 0),
                fov = 60
            }
        end)

        hook.Add("HUDPaint", "EntityViewHUD", function() draw.SimpleText(L("pressInstructions"), "LiliaFont.25", ScrW() / 2, ScrH() - 50, color_white, TEXT_ALIGN_CENTER) end)
        hook.Add("Think", "EntityViewRotate", function()
            if input.IsKeyDown(KEY_A) then yaw = yaw - FrameTime() * 100 end
            if input.IsKeyDown(KEY_D) then yaw = yaw + FrameTime() * 100 end
            if input.IsKeyDown(KEY_W) then camZOffset = camZOffset + FrameTime() * 100 end
            if input.IsKeyDown(KEY_S) then camZOffset = camZOffset - FrameTime() * 100 end
            if input.IsKeyDown(KEY_SPACE) then
                hook.Remove("CalcView", "EntityViewCalcView")
                hook.Remove("HUDPaint", "EntityViewHUD")
                hook.Remove("Think", "EntityViewRotate")
                hook.Remove("CreateMove", "EntitySpectateCreateMove")
                lia.option.set("thirdPersonEnabled", originalThirdPerson)
                client.IsInAdminEntityView = false
            end
        end)

        hook.Add("CreateMove", "EntitySpectateCreateMove", function(cmd)
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
            cmd:SetUpMove(0)
        end)
    end

    for _, ownerData in ipairs(owners) do
        local owner = tostring(ownerData.owner or "Unknown")
        local list = istable(ownerData.entities) and ownerData.entities or {}
        lia.debug("[Entity Tab Debug]", "Owner bucket", "owner=", tostring(owner), "entityCount=", tostring(#list))
        local ownerPanel = vgui.Create("DPanel")
        ownerPanel:Dock(FILL)
        ownerPanel.Paint = function() end
        local searchSheet = vgui.Create("liaSheet", ownerPanel)
        searchSheet:Dock(FILL)
        searchSheet:SetPlaceholderText(L("searchEntities"))
        for _, entry in ipairs(list) do
            local ent = Entity(entry.entIndex or -1)
            local entValid = IsValid(ent)
            local displayName = entValid and getEntityDisplayName(ent) or entry.displayName or entry.class or "Unknown Entity"
            local itemPanel = vgui.Create("DPanel")
            itemPanel:SetTall(100)
            itemPanel.Paint = function(pnl, w, h)
                derma.SkinHook("Paint", "Panel", pnl, w, h)
                draw.SimpleText(displayName, "LiliaFont.25", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local icon = vgui.Create("liaSpawnIcon", itemPanel)
            icon:Dock(LEFT)
            icon:SetWide(64)
            icon:SetTall(64)
            icon:DockMargin(5, 5, 0, 0)
            icon:SetModel(entry.model and entry.model ~= "" and entry.model or "models/error.mdl", entValid and ent:GetSkin() or 0)
            local btnContainer = vgui.Create("DPanel", itemPanel)
            btnContainer:Dock(RIGHT)
            btnContainer:SetWide(380)
            btnContainer:DockMargin(-250, 5, 5, 0)
            btnContainer.Paint = function() end
            local btnLayout = vgui.Create("DIconLayout", btnContainer)
            btnLayout:Dock(FILL)
            btnLayout:SetSpaceX(10)
            btnLayout:SetSpaceY(0)
            btnLayout:DockMargin(0, 5, 0, 0)
            local function makeBtn(key, func, enabled)
                local btn = btnLayout:Add("liaButton")
                btn:SetWide(120)
                btn:SetTall(60)
                btn:SetText(L(key))
                btn:SetEnabled(enabled ~= false)
                btn.DoClick = func
            end

            makeBtn("view", function()
                if not IsValid(ent) then return end
                if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
                local prevTP = lia.option.get("thirdPersonEnabled", false)
                lia.option.set("thirdPersonEnabled", false)
                startSpectateView(ent, prevTP)
            end, entValid)

            local canTeleportToEntity = client:hasPrivilege("teleportToEntity")
            if canTeleportToEntity then
                makeBtn("teleport", function()
                    if not IsValid(ent) then return end
                    if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
                    net.Start("liaTeleportToEntity")
                    net.WriteEntity(ent)
                    net.SendToServer()
                end, entValid)
            end

            if client.previousPosition then
                makeBtn("return", function()
                    if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
                    net.Start("liaReturnFromEntity")
                    net.SendToServer()
                end)
            end

            makeBtn("placeWaypoint", function()
                if IsValid(ent) then
                    client:setWaypoint(displayName, ent:GetPos())
                elseif isvector(entry.position) then
                    client:setWaypoint(displayName, entry.position)
                end
            end, entValid or isvector(entry.position))

            searchSheet:AddPanelRow(itemPanel, {
                height = 100,
                filterText = displayName:lower()
            })
        end

        searchSheet:Refresh()
        sheetContainer:AddSheet(owner .. " - " .. #list .. " " .. L("entities"), ownerPanel)
    end
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    local canViewEntityTab = client:hasPrivilege("viewEntityTab")
    local entityTabData = self.entityTabData or {
        owners = {},
        totalEntities = 0
    }

    lia.debug("[Entity Tab Debug]", "player=", tostring(IsValid(client) and client:Nick() or "unknown"), "usergroup=", tostring(IsValid(client) and client:GetUserGroup() or "unknown"), "hasPrivilege(viewEntityTab)=", tostring(canViewEntityTab), "cachedOwners=", tostring(istable(entityTabData.owners) and #entityTabData.owners or 0), "cachedEntities=", tostring(entityTabData.totalEntities or 0), "requestPending=", tostring(self.entityTabRequestPending or false), "shouldAddTab=", tostring(canViewEntityTab))
    if canViewEntityTab then
        self:requestEntityTabData()
        pages[#pages + 1] = {
            name = "@playerEntities",
            icon = "icon16/bricks.png",
            drawFunc = function(entPanel)
                self.entityTabPanel = entPanel
                self:populateEntityTabPanel(entPanel)
            end
        }
    end
end

local getImageDimensions
do
    local max_image_search = 1024
    local function getPNGDimensions(f)
        f:Skip(4)
        while not f:EndOfFile() and f:Tell() <= max_image_search do
            local chunkLength = f:ReadULong()
            local chunkType = f:Read(4)
            if chunkType == "IHDR" then
                local width = bit.bswap(f:ReadULong())
                local height = bit.bswap(f:ReadULong())
                return width, height
            end

            f:Skip(chunkLength)
            f:Skip(4)
        end
    end

    local function getJPEGDimensions(f)
        local byte1, byte2
        while not f:EndOfFile() and f:Tell() <= max_image_search do
            byte1 = f:ReadByte()
            if byte1 == 0xFF then
                byte2 = f:ReadByte()
                if byte2 >= 0xC0 and byte2 <= 0xCF and byte2 ~= 0xC4 and byte2 ~= 0xC8 then
                    f:Skip(3)
                    local height = bit.bswap(bit.lshift(f:ReadUShort(), 16))
                    local width = bit.bswap(bit.lshift(f:ReadUShort(), 16))
                    return width, height
                end
            end
        end
    end

    function getImageDimensions(path)
        local f = file.Open(path, "rb", "DATA")
        if not f then return end
        local succ, width, height
        local sig = f:Read(4)
        if sig == "\xff\xd8\xff\xe0" then
            succ, width, height = pcall(getJPEGDimensions, f)
        elseif sig == "\x89\x50\x4e\x47" then
            succ, width, height = pcall(getPNGDimensions, f)
        end

        f:Close()
        if not succ then return end
        return width, height
    end
end

__originalMaterial = __originalMaterial or Material
function Material(name, words)
    if name:find("../data") then
        local path = string.Replace(name, "../data/", "")
        local width, height = getImageDimensions(path)
        if not width or not height then return __originalMaterial("error") end
        if (width * height) > 33177600 then return __originalMaterial("error") end
    end
    return __originalMaterial(name, words)
end
