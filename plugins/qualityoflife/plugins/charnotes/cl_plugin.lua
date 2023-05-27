local PLUGIN = PLUGIN

netstream.Hook("lia_charNoteOpen", function(charID, notes, edit)
    for k, v in pairs(notes) do
        local noteFrame = vgui.Create("DFrame")
        noteFrame:SetTitle(v.name)
        noteFrame:SetSize(v.size[1] or 400, v.size[2] or 400)
        noteFrame:SetPos(ScrW() * (v.pos[1] or 0.5), ScrH() * (v.pos[2] or 0.5))
        noteFrame:MakePopup()
        noteFrame:ShowCloseButton(true)
        local scroll = vgui.Create("DScrollPanel", noteFrame)
        scroll:Dock(FILL)
        local notesGUI = vgui.Create("DTextEntry", scroll)
        notesGUI:DockMargin(0, 8, 0, 0)
        notesGUI:SetSize(160, ScrH() * 0.2)
        notesGUI:Dock(FILL)
        notesGUI:SetFont("liaCharSubTitleFont")
        notesGUI:SetTextColor(Color(255, 255, 255))
        notesGUI:SetVerticalScrollbarEnabled(true)
        notesGUI:SetText(v.data or "")
        notesGUI:SetPaintBackground(false)
        notesGUI:SetWrap(true)
        notesGUI:SetMultiline(true)
        notesGUI:SetEditable(true)

        if edit then
            local notesGUIB = vgui.Create("DButton", noteFrame)
            notesGUIB:SetText("Save")
            notesGUIB:SetSize(20, 100)
            notesGUIB:Dock(BOTTOM)

            notesGUIB.DoClick = function()
                netstream.Start(v.saveFunc, charID, notesGUI:GetText())
                noteFrame:Remove()
            end

            notesGUIB.Paint = function(self, w, h)
                surface.SetDrawColor(Color(20, 20, 20, 255))
                surface.DrawRect(0, 0, w, h)
            end
        else
            --notesGUI:SetEditable(false)
            notesGUI:SetEnabled(false)
        end
    end
end)
