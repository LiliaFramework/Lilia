--[[
    Hooks:
        StorageOpen(storage)

    Purpose:
        Runs when a weight-inventory storage container should open its clientside storage panel.

    Category:
        Inventory

    Parameters:
        storage (Inventory)
            The storage inventory being opened.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("StorageOpen", "liaExampleStorageOpenWeightInv", function(storage)
            print("Opened storage", storage:getID())
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        CanPlayerViewInventory()

    Purpose:
        Determines whether the inventory menu button should be available for the local player.

    Category:
        Inventory

    Parameters:
        None

    Returns:
        boolean|nil
            Return false to hide the inventory menu button. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerViewInventory", "liaExampleCanPlayerViewInventory", function()
            if IsValid(lia.gui.character) then
                return false
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        CanOpenBagPanel(item)

    Purpose:
        Determines whether a bag inventory panel should be opened alongside the main weight inventory.

    Category:
        Inventory

    Parameters:
        item (Item)
            The bag item whose inventory panel is being considered.

    Returns:
        boolean|nil
            Return false to suppress opening the bag panel. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanOpenBagPanel", "liaExampleCanOpenBagPanel", function(item)
            if item.uniqueID == "hiddenbag" then
                return false
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        PostDrawInventory(mainPanel, parentPanel)

    Purpose:
        Runs after the weight inventory panels have been laid out and VGUI finished rendering for the frame.

    Category:
        Inventory

    Parameters:
        mainPanel (Panel)
            The primary inventory panel created for the player's inventory.

        parentPanel (Panel)
            The parent panel that hosted the inventory layout.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostDrawInventory", "liaExamplePostDrawInventory", function(mainPanel, parentPanel)
            surface.SetDrawColor(255, 255, 255, 10)
        end)
        ```

    Realm:
        Client
]]
local PREVIEW_WIDTH = 260
local PREVIEW_GAP = 12
local PREVIEW_TOP_PADDING = 24
local PREVIEW_BOTTOM_PADDING = 24
local function setIdleSequence(entity)
    if not IsValid(entity) then return end
    local sequences = {"idle_all_01", "idle_subtle", "idle_unarmed", "idle01", "pose_standing_01"}
    for _, sequenceName in ipairs(sequences) do
        local sequence = entity:LookupSequence(sequenceName)
        if sequence and sequence > 0 then
            entity:ResetSequence(sequence)
            entity:SetCycle(0)
            return
        end
    end
end

local function fitCharacterModel(modelPanel)
    if not IsValid(modelPanel) then return end
    local entity = modelPanel:GetEntity()
    if not IsValid(entity) then return end
    entity:SetupBones()
    local mins, maxs = entity:GetRenderBounds()
    local size = maxs - mins
    local width = math.max(size.x, size.y, 1)
    local height = math.max(size.z, 1)
    entity:SetPos(Vector(0, 0, -mins.z))
    mins, maxs = entity:GetRenderBounds()
    local center = Vector((mins.x + maxs.x) * 0.5, (mins.y + maxs.y) * 0.5, -mins.z + height * 0.5)
    local fov = 24
    local aspect = math.max(modelPanel:GetWide(), 1) / math.max(modelPanel:GetTall(), 1)
    local verticalFov = math.deg(2 * math.atan(math.tan(math.rad(fov * 0.5)) / math.max(aspect, 0.1)))
    local verticalDistance = height * 0.55 / math.tan(math.rad(verticalFov * 0.5))
    local horizontalDistance = width * 0.6 / math.tan(math.rad(fov * 0.5))
    local distance = math.max(verticalDistance, horizontalDistance)
    modelPanel:SetFOV(fov)
    modelPanel:SetLookAt(center)
    modelPanel:SetCamPos(center + Vector(distance, 0, 0))
end

local function createInventoryPreview(parentPanel, mainPanel)
    if not IsValid(parentPanel) or not IsValid(mainPanel) then return end
    local client = LocalPlayer()
    local character = IsValid(client) and client:getChar() or nil
    if not character then return end
    local preview = parentPanel:Add("EditablePanel")
    local previewHeight = math.max(parentPanel:GetTall() - PREVIEW_TOP_PADDING - PREVIEW_BOTTOM_PADDING, mainPanel:GetTall())
    preview:SetSize(PREVIEW_WIDTH, previewHeight)
    preview.Paint = function(_, w, h)
        local theme = lia.color and lia.color.theme or {}
        local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
        draw.RoundedBox(6, 0, 0, w, h, Color(2, 14, 18, 175))
        surface.SetDrawColor(accent.r, accent.g, accent.b, 92)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local modelPanel = preview:Add("liaModelPanel")
    modelPanel:Dock(FILL)
    modelPanel:DockMargin(8, 8, 8, 8)
    modelPanel:SetAnimated(true)
    modelPanel:SetAmbientLight(Color(120, 138, 148))
    modelPanel:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    modelPanel:SetDirectionalLight(BOX_FRONT, Color(220, 232, 232))
    modelPanel:SetDirectionalLight(BOX_RIGHT, Color(90, 110, 118))
    modelPanel:SetDirectionalLight(BOX_LEFT, Color(90, 110, 118))
    modelPanel.rotationAngle = 0
    modelPanel.LayoutEntity = function(panel, entity)
        if not IsValid(entity) then return end
        entity:SetAngles(Angle(0, panel.rotationAngle, 0))
        entity:SetPoseParameter("head_yaw", 0)
        entity:SetPoseParameter("head_pitch", 0)
        entity:SetPoseParameter("body_yaw", 0)
        entity:SetPoseParameter("aim_yaw", 0)
        entity:SetPoseParameter("aim_pitch", 0)
        entity:SetEyeTarget(panel:GetCamPos())
        entity:SetIK(false)
        entity:FrameAdvance(FrameTime())
    end

    local model = character.getModel and character:getModel() or client:GetModel()
    modelPanel:SetModel(model)
    local function applyEntitySettings()
        local entity = modelPanel:GetEntity()
        if not IsValid(entity) then return end
        entity:SetSkin(character:getSkin())
        lia.util.applyBodygroups(entity, character:getBodygroups())
        hook.Run("SetupPlayerModel", entity, character)
        setIdleSequence(entity)
        fitCharacterModel(modelPanel)
    end

    applyEntitySettings()
    timer.Simple(0, function() if IsValid(modelPanel) then applyEntitySettings() end end)
    timer.Simple(0.05, function() if IsValid(modelPanel) then applyEntitySettings() end end)
    timer.Simple(0.15, function() if IsValid(modelPanel) then applyEntitySettings() end end)
    modelPanel.OnSizeChanged = function(panel, width, height)
        if panel._inventoryFitW == width and panel._inventoryFitH == height then return end
        panel._inventoryFitW = width
        panel._inventoryFitH = height
        fitCharacterModel(panel)
    end

    preview:SetPos(mainPanel.x + mainPanel:GetWide() + PREVIEW_GAP, PREVIEW_TOP_PADDING)
    preview:MoveToFront()
    return preview
end

function MODULE:CreateInventoryPanel(inventory, parent)
    if inventory.typeID ~= "WeightInv" then return end
    local panel = parent:Add("liaListInventory")
    panel:setInventory(inventory)
    panel:Center()
    return panel
end

function MODULE:StorageOpen(storage)
    if IsValid(storage) and storage:getStorageInfo().invType == INV_TYPE_ID then vgui.Create("liaListStorage"):setStorage(storage) end
end

hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    local margin = 10
    tabs["inv"] = {
        name = "inv",
        icon = "icon16/box.png",
        shouldShow = function() return hook.Run("CanPlayerViewInventory") ~= false end,
        func = function(parentPanel)
            local inventory = LocalPlayer():getChar():getInv()
            if not inventory then return end
            local mainPanel = inventory:show(parentPanel)
            local panels = {}
            local totalWidth = 0
            local maxHeight = 0
            table.insert(panels, mainPanel)
            totalWidth = totalWidth + mainPanel:GetWide() + margin + PREVIEW_WIDTH + PREVIEW_GAP
            maxHeight = math.max(maxHeight, mainPanel:GetTall())
            for _, item in pairs(inventory:getItems()) do
                if item.isBag and hook.Run("CanOpenBagPanel", item) ~= false then
                    local bagInv = item:getInv()
                    if bagInv then
                        local bagPanel = bagInv:show(mainPanel)
                        lia.gui["inv" .. bagInv:getID()] = bagPanel
                        table.insert(panels, bagPanel)
                        totalWidth = totalWidth + bagPanel:GetWide() + margin
                        maxHeight = math.max(maxHeight, bagPanel:GetTall())
                    end
                end
            end

            local px, py, pw, ph = mainPanel:GetBounds()
            local xPos = px + pw / 2 - totalWidth / 2
            local yPos = py + ph / 2
            for _, panel in pairs(panels) do
                panel:ShowCloseButton(false)
                panel:SetPos(xPos, yPos - panel:GetTall() / 2)
                xPos = xPos + panel:GetWide() + margin
            end

            createInventoryPreview(parentPanel, mainPanel)
            hook.Add("PostRenderVGUI", mainPanel, function() hook.Run("PostDrawInventory", mainPanel, parentPanel) end)
        end
    }
end)
