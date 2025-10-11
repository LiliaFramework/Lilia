lia.derma = lia.derma or {}
local color_disconnect = Color(210, 65, 65)
local color_bot = Color(70, 150, 220)
local color_online = Color(120, 180, 70)
local color_close = Color(210, 65, 65)
local color_accept = Color(44, 124, 62)
local color_target = Color(255, 255, 255, 200)
function lia.derma.dermaMenu()
    if IsValid(lia.derma.menuDermaMenu) then lia.derma.menuDermaMenu:CloseMenu() end
    local mouseX, mouseY = input.GetCursorPos()
    local m = vgui.Create("liaDermaMenu")
    m:SetPos(mouseX, mouseY)
    lia.util.clampMenuPosition(m)
    lia.derma.menuDermaMenu = m
    return m
end

function lia.derma.colorPicker(func, color_standart)
    if IsValid(lia.derma.menuColorPicker) then lia.derma.menuColorPicker:Remove() end
    local selected_color = color_standart or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    if color_standart then
        local r, g, b = color_standart.r / 255, color_standart.g / 255, color_standart.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        hue = h
        saturation = s
        value = v
    end

    lia.derma.menuColorPicker = vgui.Create("liaFrame")
    lia.derma.menuColorPicker:SetSize(300, 378)
    lia.derma.menuColorPicker:Center()
    lia.derma.menuColorPicker:MakePopup()
    lia.derma.menuColorPicker:SetTitle("")
    lia.derma.menuColorPicker:SetCenterTitle(L("colorPicker"))
    local container = vgui.Create("Panel", lia.derma.menuColorPicker)
    container:Dock(FILL)
    container:DockMargin(10, 10, 10, 10)
    container.Paint = nil
    local preview = vgui.Create("Panel", container)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h)
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        lia.derma.rect(2, 2, w - 4, h - 4):Rad(16):Color(selected_color):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local colorField = vgui.Create("Panel", container)
    colorField:Dock(TOP)
    colorField:SetTall(200)
    colorField:DockMargin(0, 0, 0, 10)
    local colorCursor = {
        x = 0,
        y = 0
    }

    local isDraggingColor = false
    colorField.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = true
            self:OnCursorMoved(self:CursorPos())
            surface.PlaySound("button_click.wav")
        end
    end

    colorField.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingColor = false end end
    colorField.OnCursorMoved = function(self, x, y)
        if isDraggingColor then
            local w, h = self:GetSize()
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)
            colorCursor.x = x
            colorCursor.y = y
            saturation = x / w
            value = 1 - (y / h)
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    colorField.Paint = function(_, w, h)
        local segments = 80
        local segmentSize = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        for x = 0, segments do
            for y = 0, segments do
                local s = x / segments
                local v = 1 - (y / segments)
                local segX = x * segmentSize
                local segY = y * segmentSize
                surface.SetDrawColor(HSVToColor(hue, s, v))
                surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
            end
        end

        lia.derma.circle(colorCursor.x, colorCursor.y, 12):Outline(2):Color(color_target):Draw()
    end

    local hueSlider = vgui.Create("Panel", container)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(20)
    hueSlider:DockMargin(0, 0, 0, 10)
    local huePos = 0
    local isDraggingHue = false
    hueSlider.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = true
            self:OnCursorMoved(self:CursorPos())
            surface.PlaySound("button_click.wav")
        end
    end

    hueSlider.OnMouseReleased = function(_, keyCode) if keyCode == MOUSE_LEFT then isDraggingHue = false end end
    hueSlider.OnCursorMoved = function(self, x)
        if isDraggingHue then
            local w = self:GetWide()
            x = math.Clamp(x, 0, w)
            huePos = x
            hue = (x / w) * 360
            selected_color = HSVToColor(hue, saturation, value)
        end
    end

    hueSlider.Paint = function(_, w, h)
        local segments = 100
        local segmentWidth = w / segments
        lia.derma.rect(0, 0, w, h):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(5, 20):Draw()
        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth
            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        lia.derma.rect(huePos - 2, 0, 4, h):Color(color_target):Draw()
    end

    local rgbContainer = vgui.Create("Panel", container)
    rgbContainer:Dock(TOP)
    rgbContainer:SetTall(60)
    rgbContainer:DockMargin(0, 0, 0, 10)
    rgbContainer.Paint = nil
    local btnContainer = vgui.Create("Panel", container)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)
    btnContainer.Paint = nil
    local btnClose = vgui.Create("liaButton", btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(90)
    btnClose:SetTxt(L("cancel"))
    btnClose:SetColorHover(color_close)
    btnClose.DoClick = function()
        lia.derma.menuColorPicker:Remove()
        surface.PlaySound("button_click.wav")
    end

    local btnSelect = vgui.Create("liaButton", btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetTxt(L("select"))
    btnSelect:SetColorHover(color_accept)
    btnSelect.DoClick = function()
        surface.PlaySound("button_click.wav")
        func(selected_color)
        lia.derma.menuColorPicker:Remove()
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)

    timer.Simple(0.1, function() lia.derma.menuColorPicker:SetAlpha(255) end)
end

function lia.derma.playerSelector(do_click)
    if IsValid(lia.derma.menuPlayerSelector) then lia.derma.menuPlayerSelector:Remove() end
    lia.derma.menuPlayerSelector = vgui.Create("liaFrame")
    lia.derma.menuPlayerSelector:SetSize(340, 398)
    lia.derma.menuPlayerSelector:Center()
    lia.derma.menuPlayerSelector:MakePopup()
    lia.derma.menuPlayerSelector:SetTitle("")
    lia.derma.menuPlayerSelector:SetCenterTitle(L("playerSelector"))
    lia.derma.menuPlayerSelector:ShowAnimation()
    local contentPanel = vgui.Create("Panel", lia.derma.menuPlayerSelector)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    lia.derma.menuPlayerSelector.sp = vgui.Create("liaScrollPanel", contentPanel)
    lia.derma.menuPlayerSelector.sp:Dock(FILL)
    local CARD_HEIGHT = 44
    local AVATAR_SIZE = 32
    local AVATAR_X = 14
    local function CreatePlayerCard(pl)
        local card = vgui.Create("DButton", lia.derma.menuPlayerSelector.sp)
        card:Dock(TOP)
        card:DockMargin(0, 5, 0, 0)
        card:SetTall(CARD_HEIGHT)
        card:SetText("")
        card.hover_status = 0
        card.OnCursorEntered = function(self) self:SetCursor("hand") end
        card.OnCursorExited = function(self) self:SetCursor("arrow") end
        card.Think = function(self)
            if self:IsHovered() then
                self.hover_status = math.Clamp(self.hover_status + 4 * FrameTime(), 0, 1)
            else
                self.hover_status = math.Clamp(self.hover_status - 8 * FrameTime(), 0, 1)
            end
        end

        card.DoClick = function()
            if IsValid(pl) then
                surface.PlaySound("button_click.wav")
                do_click(pl)
            end

            lia.derma.menuPlayerSelector:Remove()
        end

        card.Paint = function(self, w, h)
            lia.derma.rect(0, 0, w, h):Rad(10):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
            if self.hover_status > 0 then lia.derma.rect(0, 0, w, h):Rad(10):Color(Color(0, 0, 0, 40 * self.hover_status)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local infoX = AVATAR_X + AVATAR_SIZE + 10
            if not IsValid(pl) then
                draw.SimpleText(L("disconnected"), "LiliaFont.18", infoX, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(pl:Name(), "LiliaFont.18", infoX, 6, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = pl:GetUserGroup() or "user"
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, "LiliaFont.14", infoX, h - 6, lia.color.theme.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(pl:Ping() .. " " .. L("ping"), "LiliaFont.16", w - 20, h - 6, lia.color.theme.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            if pl:IsBot() then
                statusColor = color_bot
            else
                statusColor = color_online
            end

            lia.derma.circle(w - 24, 14, 24):Color(statusColor):Draw()
        end

        local avatarImg = vgui.Create("AvatarImage", card)
        avatarImg:SetSize(AVATAR_SIZE, AVATAR_SIZE)
        avatarImg:SetPos(AVATAR_X, (CARD_HEIGHT - AVATAR_SIZE) * 0.5)
        avatarImg:SetPlayer(pl, 64)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetKeyboardInputEnabled(false)
        avatarImg.PaintOver = function() end
        avatarImg:SetPos(AVATAR_X, (card:GetTall() - AVATAR_SIZE) * 0.5)
        return card
    end

    for _, pl in player.Iterator() do
        CreatePlayerCard(pl)
    end

    lia.derma.menuPlayerSelector.btn_close = vgui.Create("liaButton", lia.derma.menuPlayerSelector)
    lia.derma.menuPlayerSelector.btn_close:Dock(BOTTOM)
    lia.derma.menuPlayerSelector.btn_close:DockMargin(16, 8, 16, 12)
    lia.derma.menuPlayerSelector.btn_close:SetTall(36)
    lia.derma.menuPlayerSelector.btn_close:SetTxt(L("close"))
    lia.derma.menuPlayerSelector.btn_close:SetColorHover(color_disconnect)
    lia.derma.menuPlayerSelector.btn_close.DoClick = function() lia.derma.menuPlayerSelector:Remove() end
end

function lia.derma.textBox(title, desc, func)
    lia.derma.menuTextBox = vgui.Create("liaFrame")
    lia.derma.menuTextBox:SetSize(300, 132)
    lia.derma.menuTextBox:Center()
    lia.derma.menuTextBox:MakePopup()
    lia.derma.menuTextBox:SetTitle(title)
    lia.derma.menuTextBox:ShowAnimation()
    lia.derma.menuTextBox:DockPadding(12, 30, 12, 12)
    local entry = vgui.Create("liaEntry", lia.derma.menuTextBox)
    entry:Dock(TOP)
    entry:SetTitle(desc)
    local function apply_func()
        func(entry:GetValue())
        lia.derma.menuTextBox:Remove()
    end

    entry.OnEnter = function() apply_func() end
    local btn_accept = vgui.Create("liaButton", lia.derma.menuTextBox)
    btn_accept:Dock(BOTTOM)
    btn_accept:SetTall(30)
    btn_accept:SetTxt(L("apply"))
    btn_accept:SetColorHover(color_accept)
    btn_accept.DoClick = function()
        surface.PlaySound("button_click.wav")
        apply_func()
    end
end

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping
local SHADERS_VERSION = "1757877956"
local SHADERS_GMA = [========[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]========]
do
    local DECODED_SHADERS_GMA = util.Base64Decode(SHADERS_GMA)
    if not DECODED_SHADERS_GMA or #DECODED_SHADERS_GMA == 0 then return end
    file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", DECODED_SHADERS_GMA)
    game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function getShader(name)
    return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

local blurRt = GetRenderTargetEx("lia.derma" .. SHADERS_VERSION .. SysTime(), 1024, 1024, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2, 256, 4, 8), 0, IMAGE_FORMAT_BGRA8888)
local newFlag
do
    local flags_n = -1
    function newFlag()
        flags_n = flags_n + 1
        return 2 ^ flags_n
    end
end

local NO_TL, NO_TR, NO_BL, NO_BR = newFlag(), newFlag(), newFlag(), newFlag()
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = newFlag(), newFlag(), newFlag()
local BLUR = newFlag()
local shader_mat = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""
	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""
	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}
	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1
	$linearwrite               1
	$linearread_basetexture    1
	$linearread_texture1       1
	$linearread_texture2       1
	$linearread_texture3       1
}
]==]
local matrixes = {}
local function createShaderMat(name, opts)
    assert(name and isstring(name), "createShaderMat: tex must be a string")
    local key_values = util.KeyValuesToTable(shader_mat, false, true)
    if opts then
        for k, v in pairs(opts) do
            key_values[k] = v
        end
    end

    local mat = CreateMaterial("rndx_shaders1" .. name .. SysTime(), "screenspace_general", key_values)
    matrixes[mat] = Matrix()
    return mat
end

local roundedMat = createShaderMat("rounded", {
    ["$pixshader"] = getShader("rndx_rounded_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
})

local roundedTextureMat = createShaderMat("rounded_texture", {
    ["$pixshader"] = getShader("rndx_rounded_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = "vgui/white",
})

local blurVertical = "$c0_x"
local roundedBlurMat = createShaderMat("blur_horizontal", {
    ["$pixshader"] = getShader("rndx_rounded_blur_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = blurRt:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local shadowsMat = createShaderMat("rounded_shadows", {
    ["$pixshader"] = getShader("rndx_shadows_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
})

local shadowsBlurMat = createShaderMat("shadows_blur_horizontal", {
    ["$pixshader"] = getShader("rndx_shadows_blur_ps30"),
    ["$vertexshader"] = getShader("rndx_vertex_vs30"),
    ["$basetexture"] = blurRt:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local shapes = {
    [SHAPE_CIRCLE] = 2,
    [SHAPE_FIGMA] = 2.2,
    [SHAPE_IOS] = 4,
}

local defaultShape = SHAPE_FIGMA
local materialSetTexture = roundedMat.SetTexture
local materialSetMatrix = roundedMat.SetMatrix
local materialSetFloat = roundedMat.SetFloat
local matrixSetUnpacked = Matrix().SetUnpacked
local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY
local function resetParams()
    MAT = nil
    X, Y, W, H = 0, 0, 0, 0
    TL, TR, BL, BR = 0, 0, 0, 0
    TEXTURE = nil
    USING_BLUR, BLUR_INTENSITY = false, 1.0
    COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    SHAPE, OUTLINE_THICKNESS = shapes[defaultShape], -1
    START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
    CLIP_PANEL = nil
    SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = false, 0, 0
end

do
    local HUGE = math.huge
    local function nzr(x)
        if x ~= x or x < 0 then return 0 end
        local lim = math_min(W, H)
        if x == HUGE then return lim end
        return x
    end

    local function clamp0(x)
        return x < 0 and 0 or x
    end

    function normalizeCornerRadii()
        local tl, tr, bl, br = nzr(TL), nzr(TR), nzr(BL), nzr(BR)
        local k = math_max(1, (tl + tr) / W, (bl + br) / W, (tl + bl) / H, (tr + br) / H)
        if k > 1 then
            local inv = 1 / k
            tl, tr, bl, br = tl * inv, tr * inv, bl * inv, br * inv
        end
        return clamp0(tl), clamp0(tr), clamp0(bl), clamp0(br)
    end
end

local function setupDraw()
    local tl, tr, bl, br = normalizeCornerRadii()
    local matrix = matrixes[MAT]
    matrixSetUnpacked(matrix, bl, W, OUTLINE_THICKNESS or -1, END_ANGLE, br, H, SHADOW_INTENSITY, ROTATION, tr, SHAPE, BLUR_INTENSITY or 1.0, 0, tl, TEXTURE and 1 or 0, START_ANGLE, 0)
    materialSetMatrix(MAT, "$viewprojmat", matrix)
    if COL_R then surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A) end
    surface_SetMaterial(MAT)
end

local manualColor = newFlag()
local defaultDrawFlags = defaultShape
local function drawRounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
    if col and col.a == 0 then return end
    resetParams()
    if not flags then flags = defaultDrawFlags end
    local using_blur = bit_band(flags, BLUR) ~= 0
    if using_blur then return lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness) end
    MAT = roundedMat
    if texture then
        MAT = roundedTextureMat
        materialSetTexture(MAT, "$basetexture", texture)
        TEXTURE = texture
    end

    W, H = w, h
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    if bit_band(flags, manualColor) ~= 0 and not col then
        COL_R = nil
    elseif col then
        COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
    else
        COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    end

    setupDraw()
    return surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function lia.derma.draw(radius, x, y, w, h, col, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius)
end

function lia.derma.drawOutlined(radius, x, y, w, h, col, thickness, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, nil, thickness or 1)
end

function lia.derma.drawTexture(radius, x, y, w, h, col, texture, flags)
    return drawRounded(x, y, w, h, col, flags, radius, radius, radius, radius, texture)
end

function lia.derma.drawMaterial(radius, x, y, w, h, col, mat, flags)
    local tex = mat:GetTexture("$basetexture")
    if tex then return lia.derma.drawTexture(radius, x, y, w, h, col, tex, flags) end
end

function lia.derma.drawCircle(x, y, radius, col, flags)
    return lia.derma.draw(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, (flags or 0) + SHAPE_CIRCLE)
end

function lia.derma.drawCircleOutlined(x, y, radius, col, thickness, flags)
    return lia.derma.drawOutlined(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

function lia.derma.drawCircleTexture(x, y, radius, col, texture, flags)
    return lia.derma.drawTexture(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

function lia.derma.drawCircleMaterial(x, y, radius, col, mat, flags)
    return lia.derma.drawMaterial(radius / 2, x - radius / 2, y - radius / 2, radius, radius, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local useShadowsBlur = false
local function drawBlur()
    if useShadowsBlur then
        MAT = shadowsBlurMat
    else
        MAT = roundedBlurMat
    end

    COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    setupDraw()
    render_CopyRenderTargetToTexture(blurRt)
    materialSetFloat(MAT, blurVertical, 0)
    surface_DrawTexturedRect(X, Y, W, H)
    render_CopyRenderTargetToTexture(blurRt)
    materialSetFloat(MAT, blurVertical, 1)
    surface_DrawTexturedRect(X, Y, W, H)
end

function lia.derma.drawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
    resetParams()
    if not flags then flags = defaultDrawFlags end
    X, Y = x, y
    W, H = w, h
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    drawBlur()
end

local function setupShadows()
    X = X - SHADOW_SPREAD
    Y = Y - SHADOW_SPREAD
    W = W + (SHADOW_SPREAD * 2)
    H = H + (SHADOW_SPREAD * 2)
    TL = TL + (SHADOW_SPREAD * 2)
    TR = TR + (SHADOW_SPREAD * 2)
    BL = BL + (SHADOW_SPREAD * 2)
    BR = BR + (SHADOW_SPREAD * 2)
end

local function drawShadows(r, g, b, a)
    if USING_BLUR then
        useShadowsBlur = true
        drawBlur()
        useShadowsBlur = false
    end

    MAT = shadowsMat
    if r == false then
        COL_R = nil
    else
        COL_R, COL_G, COL_B, COL_A = r, g, b, a
    end

    setupDraw()
    surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

function lia.derma.drawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
    if col and col.a == 0 then return end
    local OLD_CLIPPING_STATE = DisableClipping(true)
    resetParams()
    if not flags then flags = defaultDrawFlags end
    X, Y = x, y
    W, H = w, h
    SHADOW_SPREAD = spread or 30
    SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2
    TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0, bit_band(flags, NO_TR) == 0 and tr or 0, bit_band(flags, NO_BL) == 0 and bl or 0, bit_band(flags, NO_BR) == 0 and br or 0
    SHAPE = shapes[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or shapes[defaultShape]
    OUTLINE_THICKNESS = thickness
    setupShadows()
    USING_BLUR = bit_band(flags, BLUR) ~= 0
    if bit_band(flags, manualColor) == 0 then drawShadows(col and col.r or 0, col and col.g or 0, col and col.b or 0, col and col.a or 255) end
    DisableClipping(OLD_CLIPPING_STATE)
end

function lia.derma.drawShadows(radius, x, y, w, h, col, spread, intensity, flags)
    return lia.derma.drawShadowsEx(x, y, w, h, col, flags, radius, radius, radius, radius, spread, intensity)
end

function lia.derma.drawShadowsOutlined(radius, x, y, w, h, col, thickness, spread, intensity, flags)
    return lia.derma.drawShadowsEx(x, y, w, h, col, flags, radius, radius, radius, radius, spread, intensity, thickness or 1)
end

lia.derma.baseFuncs = {
    Rad = function(self, rad)
        TL, TR, BL, BR = rad, rad, rad, rad
        return self
    end,
    Radii = function(self, tl, tr, bl, br)
        TL, TR, BL, BR = tl or 0, tr or 0, bl or 0, br or 0
        return self
    end,
    Texture = function(self, texture)
        TEXTURE = texture
        return self
    end,
    Material = function(self, mat)
        local tex = mat:GetTexture("$basetexture")
        if tex then TEXTURE = tex end
        return self
    end,
    Outline = function(self, thickness)
        OUTLINE_THICKNESS = thickness
        return self
    end,
    Shape = function(self, shape)
        SHAPE = shapes[shape] or 2.2
        return self
    end,
    Color = function(self, col_or_r, g, b, a)
        if isnumber(col_or_r) then
            COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
        else
            COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
        end
        return self
    end,
    Blur = function(self, intensity)
        if not intensity then intensity = 1.0 end
        intensity = math_max(intensity, 0)
        USING_BLUR, BLUR_INTENSITY = true, intensity
        return self
    end,
    Rotation = function(self, angle)
        ROTATION = math.rad(angle or 0)
        return self
    end,
    StartAngle = function(self, angle)
        START_ANGLE = angle or 0
        return self
    end,
    EndAngle = function(self, angle)
        END_ANGLE = angle or 360
        return self
    end,
    Shadow = function(self, spread, intensity)
        SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = true, spread or 30, intensity or (spread or 30) * 1.2
        return self
    end,
    Clip = function(self, pnl)
        CLIP_PANEL = pnl
        return self
    end,
    Flags = function(self, flags)
        flags = flags or 0
        if bit_band(flags, NO_TL) ~= 0 then TL = 0 end
        if bit_band(flags, NO_TR) ~= 0 then TR = 0 end
        if bit_band(flags, NO_BL) ~= 0 then BL = 0 end
        if bit_band(flags, NO_BR) ~= 0 then BR = 0 end
        local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
        if shape_flag ~= 0 then SHAPE = shapes[shape_flag] or shapes[defaultShape] end
        if bit_band(flags, BLUR) ~= 0 then USING_BLUR, BLUR_INTENSITY = true, 1.0 end
        if bit_band(flags, manualColor) ~= 0 then COL_R = nil end
        return self
    end,
}

lia.derma.Rect = {
    Rad = lia.derma.baseFuncs.Rad,
    Radii = lia.derma.baseFuncs.Radii,
    Texture = lia.derma.baseFuncs.Texture,
    Material = lia.derma.baseFuncs.Material,
    Outline = lia.derma.baseFuncs.Outline,
    Shape = lia.derma.baseFuncs.Shape,
    Color = lia.derma.baseFuncs.Color,
    Blur = lia.derma.baseFuncs.Blur,
    Rotation = lia.derma.baseFuncs.Rotation,
    StartAngle = lia.derma.baseFuncs.StartAngle,
    EndAngle = lia.derma.baseFuncs.EndAngle,
    Clip = lia.derma.baseFuncs.Clip,
    Shadow = lia.derma.baseFuncs.Shadow,
    Flags = lia.derma.baseFuncs.Flags,
    Draw = function()
        if START_ANGLE == END_ANGLE then return end
        local OLD_CLIPPING_STATE
        if SHADOW_ENABLED or CLIP_PANEL then OLD_CLIPPING_STATE = DisableClipping(true) end
        if CLIP_PANEL then
            local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
            local sw, sh = CLIP_PANEL:GetSize()
            render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
        end

        if SHADOW_ENABLED then
            setupShadows()
            drawShadows(COL_R, COL_G, COL_B, COL_A)
        elseif USING_BLUR then
            drawBlur()
        else
            if TEXTURE then
                MAT = roundedTextureMat
                materialSetTexture(MAT, "$basetexture", TEXTURE)
            end

            setupDraw()
            surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
        end

        if CLIP_PANEL then render.SetScissorRect(0, 0, 0, 0, false) end
        if SHADOW_ENABLED or CLIP_PANEL then DisableClipping(OLD_CLIPPING_STATE) end
    end,
    GetMaterial = function()
        if SHADOW_ENABLED or USING_BLUR then error(L("shadowedBlurredRectangleError")) end
        if TEXTURE then
            MAT = roundedTextureMat
            materialSetTexture(MAT, "$basetexture", TEXTURE)
        end

        setupDraw()
        return MAT
    end,
}

lia.derma.Circle = {
    Texture = lia.derma.baseFuncs.Texture,
    Material = lia.derma.baseFuncs.Material,
    Outline = lia.derma.baseFuncs.Outline,
    Color = lia.derma.baseFuncs.Color,
    Blur = lia.derma.baseFuncs.Blur,
    Rotation = lia.derma.baseFuncs.Rotation,
    StartAngle = lia.derma.baseFuncs.StartAngle,
    EndAngle = lia.derma.baseFuncs.EndAngle,
    Clip = lia.derma.baseFuncs.Clip,
    Shadow = lia.derma.baseFuncs.Shadow,
    Flags = lia.derma.baseFuncs.Flags,
    Draw = lia.derma.Rect.Draw,
    GetMaterial = lia.derma.Rect.GetMaterial,
}

lia.derma.Types = {
    Rect = function(x, y, w, h)
        resetParams()
        MAT = roundedMat
        X, Y, W, H = x, y, w, h
        return lia.derma.Rect
    end,
    Circle = function(x, y, r)
        resetParams()
        MAT = roundedMat
        SHAPE = shapes[SHAPE_CIRCLE]
        X, Y, W, H = x - r / 2, y - r / 2, r, r
        r = r / 2
        TL, TR, BL, BR = r, r, r, r
        return lia.derma.Circle
    end
}

function lia.derma.rect(x, y, w, h)
    return lia.derma.Types.Rect(x, y, w, h)
end

function lia.derma.circle(x, y, r)
    return lia.derma.Types.Circle(x, y, r)
end

lia.derma.NO_TL = NO_TL
lia.derma.NO_TR = NO_TR
lia.derma.NO_BL = NO_BL
lia.derma.NO_BR = NO_BR
lia.derma.SHAPE_CIRCLE = SHAPE_CIRCLE
lia.derma.SHAPE_FIGMA = SHAPE_FIGMA
lia.derma.SHAPE_IOS = SHAPE_IOS
lia.derma.BLUR = BLUR
lia.derma.MANUAL_COLOR = manualColor
function lia.derma.setFlag(flags, flag, bool)
    flag = lia.derma[flag] or flag
    if tobool(bool) then
        return bit.bor(flags, flag)
    else
        return bit.band(flags, bit.bnot(flag))
    end
end

function lia.derma.setDefaultShape(shape)
    defaultShape = shape or SHAPE_FIGMA
    defaultDrawFlags = defaultShape
end

function lia.derma.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    surface.SetFont(font)
    local _, h = surface.GetTextSize(text)
    if yalign == TEXT_ALIGN_CENTER then
        y = y - h / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then
        y = y - h
    end

    draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
    draw.DrawText(text, font, x, y, colortext, xalign)
end

function lia.derma.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
    local steps = (outlinewidth * 2) / 3
    if steps < 1 then steps = 1 end
    for ox = -outlinewidth, outlinewidth, steps do
        for oy = -outlinewidth, outlinewidth, steps do
            draw.DrawText(text, font, x + ox, y + oy, outlinecolour, xalign)
        end
    end
    return draw.DrawText(text, font, x, y, colour, xalign)
end

function lia.derma.DrawTip(x, y, w, h, text, font, textCol, outlineCol)
    draw.NoTexture()
    local rectH = 0.85
    local triW = 0.1
    local verts = {
        {
            x = x,
            y = y
        },
        {
            x = x + w,
            y = y
        },
        {
            x = x + w,
            y = y + h * rectH
        },
        {
            x = x + w / 2 + w * triW,
            y = y + h * rectH
        },
        {
            x = x + w / 2,
            y = y + h
        },
        {
            x = x + w / 2 - w * triW,
            y = y + h * rectH
        },
        {
            x = x,
            y = y + h * rectH
        }
    }

    surface.SetDrawColor(outlineCol)
    surface.DrawPoly(verts)
    draw.SimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function lia.derma.drawText(text, x, y, color, alignX, alignY, font, alpha)
    color = color or Color(255, 255, 255)
    return draw.TextShadow({
        text = text,
        font = font or "LiliaFont.16",
        pos = {x, y},
        color = color,
        xalign = alignX or 0,
        yalign = alignY or 0
    }, 1, alpha or color.a * 0.575)
end

function lia.derma.drawSurfaceTexture(material, color, x, y, w, h)
    surface.SetDrawColor(color or Color(255, 255, 255))
    if isstring(material) then
        surface.SetMaterial(lia.util.getMaterial(material))
    else
        surface.SetMaterial(material)
    end

    surface.DrawTexturedRect(x, y, w, h)
end

function lia.derma.skinFunc(name, panel, a, b, c, d, e, f, g)
    local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
    if not skin then return end
    local func = skin[name]
    if not func then return end
    return func(skin, panel, a, b, c, d, e, f, g)
end

function lia.derma.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

function lia.derma.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

function lia.derma.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

function lia.derma.animateAppearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
    local scaleFactor = 0.8
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration
    local targetX, targetY = panel:GetPos()
    local initialW = target_w * (scale_factor and scale_factor or scaleFactor)
    local initialH = target_h * (scale_factor and scale_factor or scaleFactor)
    local initialX = targetX + (target_w - initialW) / 2
    local initialY = targetY + (target_h - initialH) / 2
    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)
    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0
    local eps = 0.5
    local alpha_eps = 1
    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alpha_dur)
    panel.Think = function()
        if not IsValid(panel) then return end
        local dt = FrameTime()
        curW = lia.derma.approachExp(curW, target_w, speedSize, dt)
        curH = lia.derma.approachExp(curH, target_h, speedSize, dt)
        curX = lia.derma.approachExp(curX, targetX, speedSize, dt)
        curY = lia.derma.approachExp(curY, targetY, speedSize, dt)
        curA = lia.derma.approachExp(curA, 255, speedAlpha, dt)
        panel:SetSize(curW, curH)
        panel:SetPos(curX, curY)
        panel:SetAlpha(math.floor(curA + 0.5))
        local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps
        if doneSize and donePos and doneAlpha then
            panel:SetSize(target_w, target_h)
            panel:SetPos(targetX, targetY)
            panel:SetAlpha(255)
            panel.Think = nil
            if callback then callback(panel) end
        end
    end
end

function lia.derma.clampMenuPosition(panel)
    if not IsValid(panel) then return end
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = ScrW(), ScrH()
    if x < 5 then
        x = 5
    elseif x + w > sw - 5 then
        x = sw - 5 - w
    end

    if y < 5 then
        y = 5
    elseif y + h > sh - 5 then
        y = sh - 5 - h
    end

    panel:SetPos(x, y)
end

function lia.derma.drawGradient(_x, _y, _w, _h, direction, color_shadow, radius, flags)
    local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
    radius = radius and radius or 0
    lia.derma.drawMaterial(radius, _x, _y, _w, _h, color_shadow, listGradients[direction], flags)
end

function lia.derma.wrapText(text, width, font)
    font = font or "LiliaFont.16"
    surface.SetFont(font)
    local exploded = string.Explode("%s", text, true)
    local line = ""
    local lines = {}
    local w = surface.GetTextSize(text)
    local maxW = 0
    if w <= width then
        text, _ = text:gsub("%s", " ")
        return {text}, w
    end

    for i = 1, #exploded do
        local word = exploded[i]
        line = line .. " " .. word
        w = surface.GetTextSize(line)
        if w > width then
            lines[#lines + 1] = line
            line = ""
            if w > maxW then maxW = w end
        end
    end

    if line ~= "" then lines[#lines + 1] = line end
    return lines, maxW
end

function lia.derma.drawBlur(panel, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x, y = panel:LocalToScreen(0, 0)
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end

function lia.derma.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
    if not IsValid(panel) then return end
    amount = amount or 6
    passes = math.max(1, passes or 5)
    alpha = alpha or 255
    darkAlpha = darkAlpha or 220
    local mat = lia.util.getMaterial("pp/blurscreen")
    local x, y = panel:LocalToScreen(0, 0)
    x = math.floor(x)
    y = math.floor(y)
    local sw, sh = ScrW(), ScrH()
    local expand = 4
    render.UpdateScreenEffectTexture()
    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, alpha)
    for i = 1, passes do
        mat:SetFloat("$blur", i / passes * amount)
        mat:Recompute()
        surface.DrawTexturedRectUV(-x - expand, -y - expand, sw + expand * 2, sh + expand * 2, 0, 0, 1, 1)
    end

    surface.SetDrawColor(0, 0, 0, darkAlpha)
    surface.DrawRect(x, y, panel:GetWide(), panel:GetTall())
end

function lia.derma.drawBlurAt(x, y, w, h, amount, passes, alpha)
    amount = amount or 5
    alpha = alpha or 255
    surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
    surface.SetDrawColor(255, 255, 255, alpha)
    local x2, y2 = x / ScrW(), y / ScrH()
    local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
    for i = -(passes or 0.2), 1, 0.2 do
        lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
        lia.util.getMaterial("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
    end
end

function lia.derma.requestArguments(title, argTypes, onSubmit, defaults)
    defaults = defaults or {}
    local count = table.Count(argTypes)
    local frameW, frameH = 600, 450 + count * 120
    local frame = vgui.Create("liaFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("enterArguments"))
    local scroll = vgui.Create("liaScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 40, 10, 10)
    surface.SetFont("liaSmallFont")
    local controls, watchers = {}, {}
    local validate
    local ordered = {}
    local grouped = {
        strings = {},
        dropdowns = {},
        bools = {},
        rest = {}
    }

    for name, typeInfo in pairs(argTypes) do
        local fieldType, dataTbl, defaultVal = typeInfo, nil, nil
        if istable(typeInfo) then
            fieldType, dataTbl = typeInfo[1], typeInfo[2]
            if typeInfo[3] ~= nil then defaultVal = typeInfo[3] end
        end

        fieldType = string.lower(tostring(fieldType))
        if defaultVal == nil and defaults[name] ~= nil then defaultVal = defaults[name] end
        local info = {
            name = name,
            fieldType = fieldType,
            dataTbl = dataTbl,
            defaultVal = defaultVal
        }

        if fieldType == "string" then
            table.insert(grouped.strings, info)
        elseif fieldType == "table" then
            table.insert(grouped.dropdowns, info)
        elseif fieldType == "boolean" then
            table.insert(grouped.bools, info)
        else
            table.insert(grouped.rest, info)
        end
    end

    for _, group in ipairs({grouped.strings, grouped.dropdowns, grouped.bools, grouped.rest}) do
        for _, v in ipairs(group) do
            table.insert(ordered, v)
        end
    end

    for _, info in ipairs(ordered) do
        local name, fieldType, dataTbl, defaultVal = info.name, info.fieldType, info.dataTbl, info.defaultVal
        local panel = vgui.Create("DPanel", scroll)
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 5)
        panel:SetTall(100)
        panel.Paint = nil
        local label = vgui.Create("DLabel", panel)
        label:SetFont("liaSmallFont")
        label:SetText(name)
        label:SizeToContents()
        local textW = select(1, surface.GetTextSize(name))
        local ctrl
        local isBool = fieldType == "boolean"
        if isBool then
            ctrl = vgui.Create("liaCheckbox", panel)
            if defaultVal ~= nil then ctrl:SetChecked(tobool(defaultVal)) end
        elseif fieldType == "table" then
            ctrl = vgui.Create("liaComboBox", panel)
            local defaultChoiceIndex
            if istable(dataTbl) then
                for idx, v in ipairs(dataTbl) do
                    if istable(v) then
                        ctrl:AddChoice(v[1], v[2])
                        if defaultVal ~= nil and (v[2] == defaultVal or v[1] == defaultVal) then defaultChoiceIndex = idx end
                    else
                        ctrl:AddChoice(tostring(v))
                        if defaultVal ~= nil and v == defaultVal then defaultChoiceIndex = idx end
                    end
                end
            end

            if defaultChoiceIndex then ctrl:ChooseOptionID(defaultChoiceIndex) end
            ctrl:FinishAddingOptions()
            ctrl:PostInit()
        elseif fieldType == "int" or fieldType == "number" then
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("liaSmallFont")
            ctrl:SetTitle("")
            if ctrl.SetNumeric then ctrl:SetNumeric(true) end
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        else
            ctrl = vgui.Create("liaEntry", panel)
            ctrl:SetFont("liaSmallFont")
            ctrl:SetTitle("")
            if defaultVal ~= nil then ctrl:SetValue(tostring(defaultVal)) end
        end

        panel.PerformLayout = function(_, w, h)
            local ctrlH, ctrlW
            if isBool then
                ctrlH, ctrlW = 22, 22
            else
                ctrlH, ctrlW = 60, w * 0.85
            end

            local totalW = textW + 10 + ctrlW
            local xOff = (w - totalW) / 2
            label:SetPos(xOff, (h - label:GetTall()) / 2)
            ctrl:SetPos(xOff + textW + 10, (h - ctrlH) / 2 - 6)
            ctrl:SetSize(ctrlW, ctrlH)
        end

        controls[name] = {
            ctrl = ctrl,
            type = fieldType
        }

        watchers[#watchers + 1] = function()
            local function trigger()
                validate()
            end

            ctrl.OnValueChange, ctrl.OnTextChanged, ctrl.OnChange, ctrl.OnSelect = trigger, trigger, trigger, trigger
        end
    end

    local btnPanel = vgui.Create("DPanel", frame)
    btnPanel:Dock(BOTTOM)
    btnPanel:SetTall(90)
    btnPanel:DockPadding(15, 15, 15, 15)
    btnPanel.Paint = nil
    local submit = vgui.Create("liaButton", btnPanel)
    submit:Dock(LEFT)
    submit:DockMargin(0, 0, 15, 0)
    submit:SetWide(270)
    submit:SetTxt(L("submit"))
    submit:SetEnabled(false)
    local cancel = vgui.Create("liaButton", btnPanel)
    cancel:Dock(RIGHT)
    cancel:SetWide(270)
    cancel:SetTxt(L("cancel"))
    cancel.DoClick = function()
        if isfunction(onSubmit) then onSubmit(false) end
        frame:Remove()
    end

    validate = function()
        for _, data in pairs(controls) do
            local ctl, ftype, ok = data.ctrl, data.type, true
            if ftype == "boolean" then
                ok = true
            elseif ctl.GetSelected then
                local txt = select(1, ctl:GetSelected())
                ok = txt and txt ~= "" and txt ~= L("select") and txt ~= L("choose")
            elseif ctl.GetValue then
                local val = ctl:GetValue()
                ok = val ~= nil and val ~= "" and val ~= "0"
            end

            if not ok then
                submit:SetEnabled(false)
                return
            end
        end

        submit:SetEnabled(true)
    end

    for _, fn in ipairs(watchers) do
        fn()
    end

    validate()
    submit.DoClick = function()
        local result = {}
        for k, data in pairs(controls) do
            local ctl, ftype = data.ctrl, data.type
            if ftype == "boolean" then
                result[k] = ctl:GetChecked()
            elseif ctl.GetSelected then
                local txt, val = ctl:GetSelected()
                result[k] = val or txt
            else
                local val = ctl:GetValue()
                result[k] = (ftype == "int" or ftype == "number") and tonumber(val) or val
            end
        end

        if isfunction(onSubmit) then onSubmit(true, result) end
        frame:Remove()
    end

    frame.OnClose = function() if isfunction(onSubmit) then onSubmit(false) end end
end

function lia.derma.CreateTableUI(title, columns, data, options, charID)
    local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
    local frame = vgui.Create("liaDListView")
    frame:SetWindowTitle(title and L(title) or L("tableListTitle"))
    frame:SetSize(frameWidth, frameHeight)
    frame:Center()
    frame:MakePopup()
    if IsValid(frame.topBar) then frame.topBar:Remove() end
    if IsValid(frame.statusBar) then frame.statusBar:Remove() end
    local listView = frame.listView
    listView:Dock(FILL)
    listView:Clear()
    if listView.ClearColumns then listView:ClearColumns() end
    for _, colInfo in ipairs(columns or {}) do
        local localizedName = colInfo.name and L(colInfo.name) or L("na")
        local col = listView:AddColumn(localizedName)
        surface.SetFont(col.Header:GetFont())
        local textW = surface.GetTextSize(localizedName)
        local minWidth = textW + 16
        col:SetMinWidth(minWidth)
        col:SetWidth(colInfo.width or minWidth)
    end

    for _, row in ipairs(data) do
        local lineData = {}
        for _, colInfo in ipairs(columns) do
            table.insert(lineData, row[colInfo.field] or L("na"))
        end

        local line = listView:AddLine(unpack(lineData))
        line.rowData = row
    end

    listView.OnRowRightClick = function(_, _, line)
        if not IsValid(line) or not line.rowData then return end
        local rowData = line.rowData
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for key, value in pairs(rowData) do
                value = tostring(value or L("na"))
                rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
        end)

        for _, option in ipairs(istable(options) and options or {}) do
            menu:AddOption(option.name and L(option.name) or option.name, function()
                if not option.net then return end
                if option.ExtraFields then
                    local inputPanel = vgui.Create("DFrame")
                    inputPanel:SetTitle(L("optionsTitle", option.name))
                    inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                    inputPanel:Center()
                    inputPanel:MakePopup()
                    local form = vgui.Create("DForm", inputPanel)
                    form:Dock(FILL)
                    form:SetLabel("")
                    form.Paint = function() end
                    local inputs = {}
                    for fName, fType in pairs(option.ExtraFields) do
                        local label = vgui.Create("DLabel", form)
                        label:SetText(fName)
                        label:Dock(TOP)
                        label:DockMargin(5, 10, 5, 0)
                        form:AddItem(label)
                        if isstring(fType) and fType == "text" then
                            local entry = vgui.Create("DTextEntry", form)
                            entry:Dock(TOP)
                            entry:DockMargin(5, 5, 5, 0)
                            entry:SetPlaceholderText(L("typeFieldPrompt", fName))
                            form:AddItem(entry)
                            inputs[fName] = {
                                panel = entry,
                                ftype = "text"
                            }
                        elseif isstring(fType) and fType == "combo" then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        elseif istable(fType) then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            for _, choice in ipairs(fType) do
                                combo:AddChoice(choice)
                            end

                            combo:FinishAddingOptions()
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        end
                    end

                    local submitButton = vgui.Create("DButton", form)
                    submitButton:SetText(L("submit"))
                    submitButton:Dock(TOP)
                    submitButton:DockMargin(5, 10, 5, 0)
                    form:AddItem(submitButton)
                    submitButton.DoClick = function()
                        local values = {}
                        for fName, info in pairs(inputs) do
                            if not IsValid(info.panel) then continue end
                            if info.ftype == "text" then
                                values[fName] = info.panel:GetValue() or ""
                            elseif info.ftype == "combo" then
                                values[fName] = info.panel:GetSelected() or ""
                            end
                        end

                        net.Start(option.net)
                        net.WriteInt(charID, 32)
                        net.WriteTable(rowData)
                        for _, fVal in pairs(values) do
                            if isnumber(fVal) then
                                net.WriteInt(fVal, 32)
                            else
                                net.WriteString(fVal)
                            end
                        end

                        net.SendToServer()
                        inputPanel:Close()
                        frame:Remove()
                    end
                else
                    net.Start(option.net)
                    net.WriteInt(charID, 32)
                    net.WriteTable(rowData)
                    net.SendToServer()
                    frame:Remove()
                end
            end)
        end

        menu:Open()
    end
    return frame, listView
end

function lia.derma.openOptionsMenu(title, options)
    if not istable(options) then return end
    local entries = {}
    if options[1] then
        for _, opt in ipairs(options) do
            if isstring(opt.name) and isfunction(opt.callback) then entries[#entries + 1] = opt end
        end
    else
        for name, callback in pairs(options) do
            if isfunction(callback) then
                entries[#entries + 1] = {
                    name = name,
                    callback = callback
                }
            end
        end
    end

    if #entries == 0 then return end
    local frameW, entryH = 300, 30
    local frameH = entryH * #entries + 50
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame.Paint = function(self, w, h)
        lia.derma.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    local titleLabel = frame:Add("DLabel")
    titleLabel:SetPos(0, 8)
    titleLabel:SetSize(frameW, 20)
    titleLabel:SetText(L(title or "options"))
    titleLabel:SetFont("liaSmallFont")
    titleLabel:SetColor(Color(255, 255, 255))
    titleLabel:SetContentAlignment(5)
    local layout = frame:Add("DListLayout")
    layout:Dock(FILL)
    layout:DockMargin(10, 32, 10, 10)
    for _, opt in ipairs(entries) do
        local btn = layout:Add("DButton")
        btn:SetTall(entryH)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 5)
        btn:SetText(L(opt.name))
        btn:SetFont("liaSmallFont")
        btn:SetTextColor(Color(255, 255, 255))
        btn:SetContentAlignment(5)
        btn.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 160))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
            end
        end

        btn.DoClick = function()
            frame:Close()
            opt.callback()
        end
    end
    return frame
end

local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta and vectorMeta.ToScreen or function()
    return {
        x = 0,
        y = 0,
        visible = false
    }
end

local defaultTheme = {
    background_alpha = Color(34, 34, 34, 210),
    header = Color(34, 34, 34, 210),
    accent = Color(255, 255, 255, 180),
    text = Color(255, 255, 255)
}

local function scaleColorAlpha(col, scale)
    col = col or defaultTheme.background_alpha
    local a = col.a or 255
    return Color(col.r, col.g, col.b, math.Clamp(a * scale, 0, 255))
end

local function EntText(text, x, y, fade)
    surface.SetFont("LiliaFont.40")
    local tw, th = surface.GetTextSize(text)
    local bx, by = math.Round(x - tw * 0.5 - 18), math.Round(y - 12)
    local bw, bh = tw + 36, th + 24
    local theme = lia.color.theme or defaultTheme
    local fadeAlpha = math.Clamp(fade, 0, 1)
    local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
    local accentColor = scaleColorAlpha(theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
    local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
    lia.derma.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
    lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
    draw.SimpleText(text, "LiliaFont.40", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    return bh
end

lia.derma.entsScales = lia.derma.entsScales or {}
function lia.derma.drawEntText(ent, text, posY, alphaOverride)
    timer.Simple(0, function() if derma.RefreshSkins then derma.RefreshSkins() end end)
    if not (IsValid(ent) and text and text ~= "") then return end
    posY = posY or 0
    local distSqr = EyePos():DistToSqr(ent:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end
    local dist = math.sqrt(distSqr)
    local minDist = 20
    local idx = ent:EntIndex()
    local prev = lia.derma.entsScales[idx] or 0
    local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
    local appearThreshold = 0.8
    local disappearThreshold = 0.01
    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed
    local cur = lia.derma.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    if cur == 0 and target == 0 then
        lia.derma.entsScales[idx] = nil
        return
    end

    lia.derma.entsScales[idx] = cur
    local eased = lia.derma.easeInOutCubic(cur)
    if eased <= 0 then return end
    local fade = eased
    if alphaOverride then
        if alphaOverride > 1 then
            fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
        else
            fade = fade * math.Clamp(alphaOverride, 0, 1)
        end
    end

    if fade <= 0 then return end
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local _, rotatedMax = ent:GetRotatedAABB(mins, maxs)
    local bob = math.sin(CurTime() + idx) / 3 + 0.5
    local center = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, math.abs(rotatedMax.z / 2) + 12 + bob)
    local screenPos = toScreen(center)
    if screenPos.visible == false then return end
    EntText(text, screenPos.x, screenPos.y + posY, fade)
end

function lia.derma.requestDropdown(title, options, callback, defaultValue)
    if IsValid(lia.derma.menuRequestDropdown) then lia.derma.menuRequestDropdown:Remove() end
    local numOptions = istable(options) and #options or 0
    local itemHeight = 26
    local itemMargin = 2
    local dropdownHeight = math.min(numOptions * (itemHeight + itemMargin) + 12, 400)
    local frameHeight = 140 + dropdownHeight
    local frame = vgui.Create("liaFrame")
    frame:SetSize(300, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOption"))
    frame:ShowAnimation()
    local dropdown = vgui.Create("liaComboBox", frame)
    dropdown:Dock(TOP)
    dropdown:DockMargin(20, 20, 20, 20)
    dropdown:SetTall(30)
    dropdown:SetMouseInputEnabled(true)
    dropdown:SetKeyboardInputEnabled(true)
    if istable(options) then
        for _, option in ipairs(options) do
            if istable(option) then
                dropdown:AddChoice(option[1], option[2])
            else
                dropdown:AddChoice(tostring(option))
            end
        end
    end

    if defaultValue then
        if istable(defaultValue) then
            dropdown:ChooseOptionData(defaultValue[2])
        else
            dropdown:ChooseOption(tostring(defaultValue))
        end
    end

    dropdown:PostInit()
    if #options > 0 then
        local firstOption = options[1]
        if istable(firstOption) then
            dropdown:ChooseOption(firstOption[1])
            dropdown.selectedText = firstOption[1]
            dropdown.selectedData = firstOption[2]
        else
            dropdown:ChooseOption(tostring(firstOption))
            dropdown.selectedText = tostring(firstOption)
        end
    end

    dropdown.OnSelect = function(_, text, data)
        dropdown.selectedText = text
        dropdown.selectedData = data
        dropdown.selected = text
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(100)
    submitBtn:SetTxt(L("select"))
    submitBtn.DoClick = function()
        local selectedText = dropdown.selectedText or dropdown:GetValue()
        local selectedData = dropdown.selectedData or dropdown:GetSelectedData()
        if not selectedText and #options > 0 then
            local firstOption = options[1]
            if istable(firstOption) then
                selectedText = firstOption[1]
                selectedData = firstOption[2]
            else
                selectedText = tostring(firstOption)
            end
        end

        if callback then
            if selectedData ~= nil then
                callback(selectedText, selectedData)
            else
                callback(selectedText)
            end
        end

        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(100)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.derma.menuRequestDropdown = frame
    return frame
end

function lia.derma.requestString(title, description, callback, defaultValue, maxLength)
    if IsValid(lia.derma.menuRequestString) then lia.derma.menuRequestString:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(600, 300)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("enterText"))
    frame:ShowAnimation()
    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 10)
    descriptionLabel:SetText(description or L("enterValue"))
    descriptionLabel:SetFont("liaSmallFont")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local textEntry = vgui.Create("liaEntry", frame)
    textEntry:Dock(TOP)
    textEntry:DockMargin(20, 0, 20, 20)
    textEntry:SetTall(30)
    textEntry:SetTitle("")
    if defaultValue then textEntry:SetValue(tostring(defaultValue)) end
    if maxLength then textEntry:SetMaxLength(maxLength) end
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(120)
    submitBtn:SetTxt(L("submit"))
    submitBtn.DoClick = function()
        local value = textEntry:GetValue()
        if callback then callback(value) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(120)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.derma.menuRequestString = frame
    return frame
end

function lia.derma.requestOptions(title, options, callback, defaults)
    if IsValid(lia.derma.menuRequestOptions) then lia.derma.menuRequestOptions:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOptions"))
    frame:ShowAnimation()
    local scrollPanel = vgui.Create("liaScrollPanel", frame)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(20, 40, 20, 60)
    local checkboxes = {}
    if istable(options) then
        for _, option in ipairs(options) do
            local optionText
            local optionData
            if istable(option) then
                optionText = option[1] or tostring(option[2])
                optionData = option[2]
            else
                optionText = tostring(option)
                optionData = option
            end

            local optionPanel = vgui.Create("Panel", scrollPanel)
            optionPanel:Dock(TOP)
            optionPanel:DockMargin(0, 5, 0, 5)
            optionPanel:SetTall(30)
            local checkbox = vgui.Create("liaCheckbox", optionPanel)
            checkbox:Dock(LEFT)
            checkbox:SetWide(30)
            checkbox:SetChecked(defaults and table.HasValue(defaults, optionData))
            local label = vgui.Create("DLabel", optionPanel)
            label:Dock(FILL)
            label:DockMargin(40, 0, 0, 0)
            label:SetText(optionText)
            label:SetFont("liaSmallFont")
            label:SetTextColor(lia.color.theme.text or color_white)
            label:SetContentAlignment(4)
            checkboxes[optionData] = checkbox
        end
    end

    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local submitBtn = vgui.Create("liaButton", buttonPanel)
    submitBtn:Dock(RIGHT)
    submitBtn:SetWide(120)
    submitBtn:SetTxt(L("confirm"))
    submitBtn.DoClick = function()
        local selectedOptions = {}
        for optionData, checkbox in pairs(checkboxes) do
            if checkbox:GetChecked() then table.insert(selectedOptions, optionData) end
        end

        if callback then callback(selectedOptions) end
        frame:Remove()
    end

    local cancelBtn = vgui.Create("liaButton", buttonPanel)
    cancelBtn:Dock(LEFT)
    cancelBtn:SetWide(120)
    cancelBtn:SetTxt(L("cancel"))
    cancelBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.derma.menuRequestOptions = frame
    return frame
end

function lia.derma.requestBinaryQuestion(title, question, callback, yesText, noText)
    if IsValid(lia.derma.menuRequestBinary) then lia.derma.menuRequestBinary:Remove() end
    local frame = vgui.Create("liaFrame")
    frame:SetSize(350, 180)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("question"))
    frame:ShowAnimation()
    local questionLabel = vgui.Create("DLabel", frame)
    questionLabel:Dock(TOP)
    questionLabel:DockMargin(20, 40, 20, 20)
    questionLabel:SetText(question or L("areYouSure"))
    questionLabel:SetFont("liaMediumFont")
    questionLabel:SetTextColor(lia.color.theme.text or color_white)
    questionLabel:SetContentAlignment(5)
    questionLabel:SizeToContents()
    local buttonPanel = vgui.Create("Panel", frame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:DockMargin(20, 10, 20, 20)
    buttonPanel:SetTall(40)
    local yesBtn = vgui.Create("liaButton", buttonPanel)
    yesBtn:Dock(RIGHT)
    yesBtn:DockMargin(10, 0, 0, 0)
    yesBtn:SetWide(140)
    yesBtn:SetTxt(yesText or L("yes"))
    yesBtn.DoClick = function()
        if callback then callback(true) end
        frame:Remove()
    end

    local noBtn = vgui.Create("liaButton", buttonPanel)
    noBtn:Dock(LEFT)
    noBtn:DockMargin(0, 0, 10, 0)
    noBtn:SetWide(140)
    noBtn:SetTxt(noText or L("no"))
    noBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.derma.menuRequestBinary = frame
    return frame
end

function lia.derma.requestButtons(title, buttons, callback, description)
    if IsValid(lia.derma.menuRequestButtons) then lia.derma.menuRequestButtons:Remove() end
    local buttonCount = #buttons
    local frameHeight = 200 + (buttonCount * 45)
    local frame = vgui.Create("liaFrame")
    frame:SetSize(350, frameHeight)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(title or L("selectOption"))
    frame:ShowAnimation()
    local descriptionLabel = vgui.Create("DLabel", frame)
    descriptionLabel:Dock(TOP)
    descriptionLabel:DockMargin(20, 40, 20, 20)
    descriptionLabel:SetText(description or "")
    descriptionLabel:SetFont("liaSmallFont")
    descriptionLabel:SetTextColor(lia.color.theme.text or color_white)
    descriptionLabel:SetContentAlignment(5)
    descriptionLabel:SizeToContents()
    local buttonContainer = vgui.Create("Panel", frame)
    buttonContainer:Dock(FILL)
    buttonContainer:DockMargin(20, 0, 20, 60)
    local buttonPanels = {}
    for i, buttonInfo in ipairs(buttons) do
        local buttonText = ""
        local buttonCallback = nil
        local buttonIcon = nil
        if istable(buttonInfo) then
            buttonText = buttonInfo.text or buttonInfo[1] or tostring(buttonInfo)
            buttonCallback = buttonInfo.callback or buttonInfo[2]
            buttonIcon = buttonInfo.icon or buttonInfo[3]
        else
            buttonText = tostring(buttonInfo)
        end

        local buttonPanel = vgui.Create("Panel", buttonContainer)
        buttonPanel:Dock(TOP)
        buttonPanel:DockMargin(0, 5, 0, 5)
        buttonPanel:SetTall(40)
        local button = vgui.Create("liaButton", buttonPanel)
        button:Dock(FILL)
        button:DockMargin(0, 0, 0, 0)
        button:SetTxt(buttonText)
        if buttonIcon then button:SetIcon(buttonIcon) end
        button.DoClick = function()
            if buttonCallback then
                local result = buttonCallback()
                if result ~= false then frame:Remove() end
            else
                if callback then
                    local result = callback(i, buttonText)
                    if result ~= false then frame:Remove() end
                else
                    frame:Remove()
                end
            end
        end

        buttonPanels[i] = button
    end

    local closeBtn = vgui.Create("liaButton", frame)
    closeBtn:Dock(BOTTOM)
    closeBtn:DockMargin(20, 10, 20, 20)
    closeBtn:SetTall(40)
    closeBtn:SetTxt(L("close"))
    closeBtn.DoClick = function()
        if callback then callback(false) end
        frame:Remove()
    end

    lia.derma.menuRequestButtons = frame
    return frame, buttonPanels
end