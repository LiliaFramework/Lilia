local ScrW, ScrH = ScrW(), ScrH()
function MODULE:InitializedModules()
    scripted_ents.GetStored("base_gmodentity").t.Think = nil
end

function MODULE:GrabEarAnimation()
    return nil
end

function MODULE:MouthMoveAnimation()
    return nil
end

function MODULE:InitPostEntity()
    if not lia.util.is64Bits() then
        timer.Simple(0, function()
            local pnl = Derma_Query("Hey there, we noticed that you're running an older version of Garry's Mod. We highly recommend switch to the updated, more stable x64 branch of the game.\nSwitching comes with a ton of benefits, including less risk of crashing, increased performance, and more!", "Garry's Mod 32-bit Client detected!", "Okay", function()
                local f = vgui.Create("DFrame")
                f:SetSize(ScrW * 0.8, ScrH * 0.55)
                f:Center()
                f:MakePopup()
                local h = vgui.Create("DHTML", f)
                h:Dock(FILL)
                h:OpenURL("https://i.imgur.com/sbCmM2T.png")
            end)

            pnl:MakePopup()
        end)
    end
end