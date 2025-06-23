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
    if BRANCH ~= "x86-64" then
        timer.Simple(0, function()
            local pnl = Derma_Query(L("upgradeNotice"), L("upgradeTitle"), L("ok"), function()
                local f = vgui.Create("DFrame")
                f:SetSize(ScrW() * 0.8, ScrH() * 0.55)
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
