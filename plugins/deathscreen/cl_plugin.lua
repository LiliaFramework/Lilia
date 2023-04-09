local owner, w, h, ceil, ft, clmp
ceil = math.ceil
clmp = math.Clamp
local aprg, aprg2 = 0, 0
w, h = ScrW(), ScrH()

-------------------------------------------------------------------------------------------------------------------------
function PLUGIN:HUDPaint()
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

-------------------------------------------------------------------------------------------------------------------------
net.Receive("death_client", function()
    local format = "%A, %d %B %Y %X"
    local date = os.date(format, lia.date.get())
    local nick = net.ReadString()
    local charid = net.ReadFloat()
    chat.AddText(Color(255, 0, 0), "[DEATH]: ", Color(255, 255, 255), date, Color(255, 255, 255), " - You were killed by " .. nick .. "[" .. charid .. "]")
end)

-------------------------------------------------------------------------------------------------------------------------
netstream.Hook("removeF1", function()
    if IsValid(lia.gui.menu) then
        lia.gui.menu:remove()
    end
end)

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("returnitems", {
    syntax = "<string name>",
    onRun = function(client, arguments) end
})