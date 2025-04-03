local GM = GM or GAMEMODE
function GM:DrawLiliaModelView(_, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:CreateMove(cmd)
    local client = LocalPlayer()
    if IsValid(client) and client:getLocalVar("bIsHoldingObject", false) and cmd:KeyDown(IN_ATTACK2) then
        cmd:ClearMovement()
        local angle = RenderAngles()
        angle.z = 0
        cmd:SetViewAngles(angle)
    end
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and client:hasRagdoll() then
        lia.command.send("chargetup")
    elseif (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
        if bind:find("use") then
            local entity = client:getTracedEntity()
            if IsValid(entity) and entity:isItem() or entity.hasMenu then hook.Run("ItemShowEntityMenu", entity) end
        end
    end
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local ragdoll = client:GetRagdollEntity()
    local ent = nil
    if not client:hasValidVehicle() and client:GetViewEntity() == client and not client:ShouldDrawLocalPlayer() then
        if IsValid(entity) and entity:IsRagdoll() then
            ent = entity
        elseif not LocalPlayer():Alive() and IsValid(ragdoll) then
            ent = ragdoll
        end
    end

    if ent and ent:IsValid() then
        local index = ent:LookupAttachment("eyes")
        if index then
            local data = ent:GetAttachment(index)
            if data then
                view = view or {}
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
            end
        end
    end
    return view
end

function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local options = {}
    local itemTable = entity:getItemTable()
    if not itemTable then return end
    local function callback(index)
        if IsValid(entity) then netstream.Start("invAct", index, entity) end
    end

    itemTable.player = LocalPlayer()
    itemTable.entity = entity
    if input.IsShiftDown() then callback("take") end
    for k, v in SortedPairs(itemTable.functions) do
        if k == "combine" then continue end
        if (hook.Run("CanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and not v.onCanRun(itemTable) then continue end
        options[L(v.name or k)] = function()
            local send = true
            if v.onClick then send = v.onClick(itemTable) end
            if v.sound then surface.PlaySound(v.sound) end
            if send ~= false then callback(k) end
        end
    end

    if table.Count(options) > 0 then entity.liaMenuIndex = lia.menu.add(options, entity) end
    itemTable.player = nil
    itemTable.entity = nil
end

function GM:HUDPaintBackground()
    lia.menu.drawAll()
    self.BaseClass.PaintWorldTips(self.BaseClass)
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("LiliaLoaded")
    end)
end

function GM:ForceDermaSkin()
    return "lilia"
end

function GM:HUDShouldDraw(element)
    local HiddenHUDElements = {
        CHUDAutoAim = true,
        CHudHealth = true,
        CHudCrosshair = true,
        CHudBattery = true,
        CHudAmmo = true,
        CHudSecondaryAmmo = true,
        CHudHistoryResource = true,
        CHudChat = true,
        CHudDamageIndicator = true,
        CHudVoiceStatus = true,
    }
    return not HiddenHUDElements[element]
end

function GM:PlayerStartVoice(client)
    if not IsValid(g_VoicePanelList) then return end
    if lia and lia.config and not lia.config.get("IsVoiceEnabled", true) then return end
    if client:getNetVar("IsDeadRestricted", false) then return false end
    hook.Run("PlayerEndVoice", client)
    if IsValid(VoicePanels[client]) then
        if VoicePanels[client].fadeAnim then
            VoicePanels[client].fadeAnim:Stop()
            VoicePanels[client].fadeAnim = nil
        end

        VoicePanels[client]:SetAlpha(255)
        return
    end

    if not IsValid(client) then return end
    local pnl = g_VoicePanelList:Add("VoicePanel")
    pnl:Setup(client)
    VoicePanels[client] = pnl
end

function GM:PlayerEndVoice(client)
    if IsValid(VoicePanels[client]) then
        if VoicePanels[client].fadeAnim then return end
        VoicePanels[client].fadeAnim = Derma_Anim("FadeOut", VoicePanels[client], VoicePanels[client].FadeOut)
        VoicePanels[client].fadeAnim:Start(2)
    end
end

function GM:SpawnMenuOpen()
    local client = LocalPlayer()
    if lia.config.get("SpawnMenuLimit", false) and not (client:getChar():hasFlags("pet") or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Props")) then return end
    return true
end