------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function VoiceCore:PlayerButtonDown(client, button)
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function VoiceCore:PostDrawOpaqueRenderables()
    local VoiceType = LocalPlayer():getNetVar("VoiceType", "Talking")
    local rangeSquared = self.TalkRanges[VoiceType] * self.TalkRanges[VoiceType]
    if self.VoiceDebugMode then
        for _, v in pairs(player.GetAll()) do
            if v == LocalPlayer() then continue end
            cam.Start3D2D(v:GetPos() + Vector(0, 0, 2), Angle(0, 0, 0), 1)
            draw.RoundedBox(rangeSquared / 2, -rangeSquared / 2, -rangeSquared / 2, rangeSquared, rangeSquared, Color(0, 255, 0, 5))
            draw.RoundedBox(0, 0, -1, rangeSquared / 2, 2, Color(0, 255, 0, 255))
            draw.SimpleText("Radius: " .. rangeSquared / 2, "3DVoiceDebug", 0, 8, Color(0, 255, 0, 220), 1)
            cam.End3D2D()
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function VoiceCore:LoadFonts(_)
    surface.CreateFont(
        "3DVoiceDebug",
        {
            font = "Arial",
            size = 14,
            antialias = true,
            weight = 700,
            underline = true,
        }
    )
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
