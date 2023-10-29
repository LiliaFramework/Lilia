--------------------------------------------------------------------------------------------------------------------------
local data = {}
--------------------------------------------------------------------------------------------------------------------------
local owner, w, h, ceil, ft, clmp
--------------------------------------------------------------------------------------------------------------------------
ceil = math.ceil
--------------------------------------------------------------------------------------------------------------------------
clmp = math.Clamp
--------------------------------------------------------------------------------------------------------------------------
local flo = 0
--------------------------------------------------------------------------------------------------------------------------
local vec
--------------------------------------------------------------------------------------------------------------------------
local aprg, aprg2 = 0, 0
--------------------------------------------------------------------------------------------------------------------------
w, h = ScrW(), ScrH()
--------------------------------------------------------------------------------------------------------------------------
local offset1, offset2, offset3, alpha, y
--------------------------------------------------------------------------------------------------------------------------
function GM:InitializedExtrasClient()
    for _, timerName in pairs(lia.config.ClientTimersToRemove) do
        timer.Remove(timerName)
    end

    for k, v in pairs(lia.config.ClientStartupConsoleCommand) do
        RunConsoleCommand(k, v)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local entity = client:GetTracedEntity()
            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then
                hook.Run("ItemShowEntityMenu", entity)
            end
        end
    elseif bind:find("jump") then
        lia.command.send("chargetup")
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CharacterListLoaded()
    timer.Create(
        "liaWaitUntilPlayerValid",
        1,
        0,
        function()
            if not IsValid(LocalPlayer()) then return end
            timer.Remove("liaWaitUntilPlayerValid")
            hook.Run("LiliaLoaded")
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function GM:DrawLiliaModelView(panel, ent)
    if IsValid(ent.weapon) then
        ent.weapon:DrawModel()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then
        system.FlashWindow()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:HUDPaint()
    self:DeathHUDPaint()
    self:MiscHUDPaint()
    self:PointingHUDPaint()
    if hook.Run("ShouldDrawCrosshair") then
        self:HUDPaintCrosshair()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerButtonDown(client, button)
    if button == KEY_F2 and IsFirstTimePredicted() then
        local menu = DermaMenu()
        menu:AddOption(
            "Change voice mode to Whispering range.",
            function()
                netstream.Start("ChangeSpeakMode", "Whispering")
                client:ChatPrint("You have changed your voice mode to Whispering!")
            end
        )

        menu:AddOption(
            "Change voice mode to Talking range.",
            function()
                netstream.Start("ChangeSpeakMode", "Talking")
                client:ChatPrint("You have changed your voice mode to Talking!")
            end
        )

        menu:AddOption(
            "Change voice mode to Yelling range.",
            function()
                netstream.Start("ChangeSpeakMode", "Yelling")
                client:ChatPrint("You have changed your voice mode to Yelling!")
            end
        )

        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ClientInitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ClientPostInit()
    gmod.GetGamemode().PlayerStartVoice = function() end
    gmod.GetGamemode().PlayerEndVoice = function() end
    if IsValid(g_VoicePanelList) then
        g_VoicePanelList:Remove()
    end

    g_VoicePanelList = vgui.Create("DPanel")
    g_VoicePanelList:ParentToHUD()
    g_VoicePanelList:SetSize(270, ScrH() - 200)
    g_VoicePanelList:SetPos(ScrW() - 320, 100)
    g_VoicePanelList:SetPaintBackground(false)
    lia.joinTime = RealTime() - 0.9716
    lia.faction.formatModelData()
    if system.IsWindows() and not system.HasFocus() then
        system.FlashWindow()
    end

    timer.Create(
        "FixShadows",
        10,
        0,
        function()
            for _, player in ipairs(player.GetAll()) do
                player:DrawShadow(false)
            end

            for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
                if IsValid(v) and v:isDoor() then
                    v:DrawShadow(false)
                end
            end
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function GM:DeathHUDPaint()
    owner = LocalPlayer()
    ft = FrameTime()
    if owner:getChar() then
        if owner:Alive() then
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * 1.3, 0, 1)
                if aprg2 == 0 then
                    aprg = clmp(aprg - ft * .7, 0, 1)
                end
            end
        else
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * .5, 0, 1)
                if aprg == 1 then
                    aprg2 = clmp(aprg2 + ft * .4, 0, 1)
                end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not owner:getChar() then return end
    if aprg > 0.01 then
        surface.SetDrawColor(0, 0, 0, ceil((aprg ^ .5) * 255))
        surface.DrawRect(-1, -1, w + 2, h + 2)
        local tx, ty = lia.util.drawText(L"youreDead", w / 2, h / 2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "liaDynFontMedium", aprg2 * 255)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:MiscHUDPaint()
    local ply = LocalPlayer()
    local ourPos = ply:GetPos()
    local time = RealTime() * 5
    data.start = ply:EyePos()
    data.filter = ply
    lia.bar.drawAll()
    if lia.config.VersionEnabled and lia.config.version then
        local w, h = 45, 45
        surface.SetFont("liaSmallChatFont")
        surface.SetTextPos(5, ScrH() - 20, w, h)
        surface.DrawText("Server Current Version: " .. lia.config.version)
    end

    if lia.config.BranchWarning and BRANCH ~= "x86-64" then
        draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    for k, v in ipairs(player.GetAll()) do
        if v ~= ply and v:getNetVar("typing") and v:GetMoveType() == MOVETYPE_WALK then
            data.endpos = v:EyePos()
            if util.TraceLine(data).Entity ~= v then continue end
            local position = v:GetPos()
            alpha = (1 - (ourPos:DistToSqr(position) / 65536)) * 255
            if alpha <= 0 then continue end
            local screen = (position + (v:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
            offset1 = math.sin(time + 2) * alpha
            offset2 = math.sin(time + 1) * alpha
            offset3 = math.sin(time) * alpha
            y = screen.y - 20
            lia.util.drawText("•", screen.x - 8, y, ColorAlpha(Color(250, 250, 250), offset1), 1, 1, "liaChatFont", offset1)
            lia.util.drawText("•", screen.x, y, ColorAlpha(Color(250, 250, 250), offset2), 1, 1, "liaChatFont", offset2)
            lia.util.drawText("•", screen.x + 8, y, ColorAlpha(Color(250, 250, 250), offset3), 1, 1, "liaChatFont", offset3)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PointingHUDPaint()
    net.Receive(
        "Pointing",
        function(len)
            flo = net.ReadFloat()
            vec = net.ReadVector()
        end
    )

    if flo >= CurTime() then
        local toScream = vec:ToScreen()
        local distance = 40 / (LocalPlayer():GetPos():Distance(vec) / 300)
        surface.DrawCircle(toScream.x, toScream.y, distance, 0, 255, 0, 255)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:TooltipInitialize(var, panel)
    if panel.liaToolTip or panel.itemID then
        var.markupObject = lia.markup.parse(var:GetText(), ScrW() * .15)
        var:SetText("")
        var:SetWide(math.max(ScrW() * .15, 200) + 12)
        var:SetHeight(var.markupObject:getHeight() + 12)
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isItemTooltip = true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:TooltipPaint(var, w, h)
    if var.isItemTooltip then
        lia.util.drawBlur(var, 2, 2)
        surface.SetDrawColor(0, 0, 0, 230)
        surface.DrawRect(0, 0, w, h)
        if var.markupObject then
            var.markupObject:draw(12 * 0.5, 12 * 0.5 + 2)
        end

        return true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:TooltipLayout(var)
    if var.isItemTooltip then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:StartChat()
    net.Start("liaTypeStatus")
    net.WriteBool(false)
    net.SendToServer()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:FinishChat()
    net.Start("liaTypeStatus")
    net.WriteBool(true)
    net.SendToServer()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerStartVoice(client)
    if not IsValid(g_VoicePanelList) or not lia.config.AllowVoice then return end
    hook.Run("PlayerEndVoice", client)
    if IsValid(nsVoicePanels[client]) then
        if nsVoicePanels[client].fadeAnim then
            nsVoicePanels[client].fadeAnim:Stop()
            nsVoicePanels[client].fadeAnim = nil
        end

        nsVoicePanels[client]:SetAlpha(255)

        return
    end

    if not IsValid(client) then return end
    local pnl = g_VoicePanelList:Add("VoicePanel")
    pnl:Setup(client)
    nsVoicePanels[client] = pnl
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerEndVoice(client)
    if IsValid(nsVoicePanels[client]) then
        if nsVoicePanels[client].fadeAnim then return end
        nsVoicePanels[client].fadeAnim = Derma_Anim("FadeOut", nsVoicePanels[client], nsVoicePanels[client].FadeOut)
        nsVoicePanels[client].fadeAnim:Start(2)
    end
end

--------------------------------------------------------------------------------------------------------------------------
concommand.Add(
    "vgui_cleanup",
    function()
        for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then
                v:Remove()
            end
        end
    end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)"
)
--------------------------------------------------------------------------------------------------------------------------