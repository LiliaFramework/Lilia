local PREVIEW_WIDTH_RATIO = 0.32
local PREVIEW_MIN_WIDTH = 320
local PREVIEW_MAX_WIDTH = 440
local PREVIEW_GAP = 12
local function getPreviewWidth(width)
    return math.Clamp(math.floor(width * PREVIEW_WIDTH_RATIO), PREVIEW_MIN_WIDTH, PREVIEW_MAX_WIDTH)
end

local function getAccent()
    local theme = lia.color and lia.color.theme or {}
    return theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

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
    modelPanel:SetCamPos(Vector(center.x + distance, center.y, center.z))
end

local function configureModelPanel(modelPanel, character, client)
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
end

local function createInventoryPreview(parentPanel, mainPanel)
    if not IsValid(parentPanel) or not IsValid(mainPanel) then return end
    local client = LocalPlayer()
    local character = IsValid(client) and client:getChar() or nil
    if not character then return end
    local preview = parentPanel:Add("EditablePanel")
    local previewWidth = getPreviewWidth(parentPanel:GetWide())
    local previewHeight = math.max(parentPanel:GetTall(), mainPanel:GetTall())
    preview:SetSize(previewWidth, previewHeight)
    preview.Paint = function(_, w, h)
        local accent = getAccent()
        drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    local modelPanel = preview:Add("liaModelPanel")
    modelPanel:Dock(FILL)
    modelPanel:DockMargin(8, 8, 8, 8)
    configureModelPanel(modelPanel, character, client)
    preview.PerformLayout = function(_, w, h)
        local viewportW = math.max(w - 16, 1)
        local viewportH = math.max(h - 16, 1)
        if modelPanel._inventoryFitW == viewportW and modelPanel._inventoryFitH == viewportH then return end
        modelPanel._inventoryFitW = viewportW
        modelPanel._inventoryFitH = viewportH
        fitCharacterModel(modelPanel)
    end

    preview:SetPos(mainPanel.x + mainPanel:GetWide() + PREVIEW_GAP, 0)
    preview:MoveToFront()
    return preview
end

function MODULE:CreateInventoryPanel(inventory, parent)
    local panel = vgui.Create("liaGridInventory", parent)
    panel:setInventory(inventory)
    panel:Center()
    hook.Run("InventoryPanelCreated", panel, inventory, parent)
    return panel
end

function MODULE:InventoryItemRemoved(_, item)
    if not item.isBag then return end
    local bagInv = item:getInv()
    if not bagInv then return end
    local bagID = bagInv:getID()
    local panel = lia.gui["inv" .. bagID]
    if IsValid(panel) then
        panel:Remove()
        lia.gui["inv" .. bagID] = nil
    end
end

function MODULE:InventoryItemAdded(inventory, item)
    if not item.isBag then return end
    local bagInv = item:getInv()
    if not bagInv then return end
    local mainPanel = lia.gui["inv" .. inventory:getID()]
    if not IsValid(mainPanel) or mainPanel.isMenuInventory then return end
    if hook.Run("CanOpenBagPanel", item) == false then return end
    if IsValid(lia.gui["inv" .. bagInv:getID()]) then return end
    local bagPanel = bagInv:show(mainPanel)
    bagPanel:MoveRightOf(mainPanel, 4)
    lia.gui["inv" .. bagInv:getID()] = bagPanel
end

local activeMenuInventoryPanel
local function switchMenuToBag(panel, item)
    if not IsValid(panel) or not item or not isfunction(panel.openBagInventory) then return false end
    local ok, opened = pcall(panel.openBagInventory, panel, item)
    return ok and opened == true
end

local function registerMenuInventory(panel, inventory)
    activeMenuInventoryPanel = panel
    lia.gui = lia.gui or {}
    lia.gui.gridInventoryMenu = panel
    local globalName = "inv" .. inventory:getID()
    local previous = lia.gui[globalName]
    if IsValid(previous) and previous ~= panel and not previous.isMenuInventory then previous:Remove() end
    panel.isMenuInventory = true
    hook.Run("InventoryPanelCreated", panel, inventory, panel:GetParent())
    hook.Run("InventoryOpened", panel, inventory)
    local oldOnRemove = panel.OnRemove
    panel.OnRemove = function(self)
        if oldOnRemove then oldOnRemove(self) end
        if activeMenuInventoryPanel == self then activeMenuInventoryPanel = nil end
        if lia.gui and lia.gui.gridInventoryMenu == self then lia.gui.gridInventoryMenu = nil end
        if lia.gui[globalName] ~= self then return end
        lia.gui[globalName] = nil
        hook.Run("InventoryClosed", self, inventory)
    end

    lia.gui[globalName] = panel
end

local function getBagItemByInventory(inventory)
    if not inventory then return end
    local inventoryID = inventory.getID and inventory:getID() or nil
    local itemID = inventory.getData and inventory:getData("item") or nil
    if itemID and lia.item and lia.item.instances then
        local item = lia.item.instances[itemID]
        if item then return item end
    end

    for _, item in pairs(lia.item.instances or {}) do
        if isfunction(item.getInv) then
            local ok, itemInventory = pcall(item.getInv, item)
            if ok and itemInventory then
                if itemInventory == inventory then return item end
                if inventoryID and itemInventory.getID and itemInventory:getID() == inventoryID then return item end
            end
        end
    end
end

local function getActiveMenuInventoryPanel()
    if IsValid(activeMenuInventoryPanel) then return activeMenuInventoryPanel end
    for _, panel in pairs(lia.gui or {}) do
        if IsValid(panel) and panel.isMenuInventory then return panel end
    end
end

lia.inventory = lia.inventory or {}
local menuBagRedirectWrapper
local function installMenuBagRedirect()
    if not lia.inventory or not isfunction(lia.inventory.showDual) then return end
    if lia.inventory.showDual == menuBagRedirectWrapper then return end
    local showDual = lia.inventory.showDual
    menuBagRedirectWrapper = function(inventory1, inventory2, parent)
        local bagItem = getBagItemByInventory(inventory2)
        local menuPanel = getActiveMenuInventoryPanel()
        if bagItem and IsValid(menuPanel) then
            local opened = switchMenuToBag(menuPanel, bagItem)
            if opened then return {menuPanel, IsValid(menuPanel.bagContent) and menuPanel.bagContent or menuPanel} end
        end
        return showDual(inventory1, inventory2, parent)
    end

    lia.inventory.showDual = menuBagRedirectWrapper
end

installMenuBagRedirect()
hook.Add("InitPostEntity", "liaInventoryMenuBagRedirect", installMenuBagRedirect)
hook.Add("Think", "liaInventoryMenuBagRedirectKeepAlive", function()
    if not IsValid(activeMenuInventoryPanel) then return end
    if (MODULE.nextMenuBagRedirectCheck or 0) > RealTime() then return end
    MODULE.nextMenuBagRedirectCheck = RealTime() + 0.5
    installMenuBagRedirect()
end)

hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    installMenuBagRedirect()
    tabs["inv"] = {
        name = "inv",
        icon = "icon16/box.png",
        shouldShow = function() return hook.Run("CanPlayerViewInventory") ~= false end,
        func = function(parentPanel)
            installMenuBagRedirect()
            local client = LocalPlayer()
            local character = IsValid(client) and client:getChar() or nil
            local inventory = character and character:getInv() or nil
            if not inventory then return end
            local root = parentPanel:Add("EditablePanel")
            root:Dock(FILL)
            root:SetMouseInputEnabled(true)
            root:SetKeyboardInputEnabled(true)
            root.Paint = function() end
            local inventoryPanel = root:Add("liaGridInventoryMenu")
            inventoryPanel:setInventory(inventory)
            registerMenuInventory(inventoryPanel, inventory)
            installMenuBagRedirect()
            local preview = createInventoryPreview(root, inventoryPanel)
            if not IsValid(preview) then
                root:Remove()
                return
            end

            root.PerformLayout = function(_, w, h)
                if not IsValid(inventoryPanel) or not IsValid(preview) then return end
                local previewWidth = getPreviewWidth(w)
                local inventoryWidth = math.max(w - previewWidth - PREVIEW_GAP, 1)
                inventoryPanel:SetPos(0, 0)
                inventoryPanel:SetSize(inventoryWidth, h)
                preview:SetPos(inventoryWidth + PREVIEW_GAP, 0)
                preview:SetSize(previewWidth, math.max(h, inventoryPanel:GetTall()))
                inventoryPanel:InvalidateLayout(true)
                preview:InvalidateLayout(true)
            end

            root:InvalidateLayout(true)
            hook.Add("PostRenderVGUI", inventoryPanel, function()
                if not IsValid(inventoryPanel) or not IsValid(parentPanel) then return end
                hook.Run("PostDrawInventory", inventoryPanel, parentPanel)
            end)
        end
    }
end)
