local meta = FindMetaTable("Player")

function PLUGIN:PlayerDeath(client)
    client:SetNWBool("customFlashlight", false)
end

function meta:FlashlightIsOn()
    return self:GetNWBool("customFlashlight", false)
end

function PLUGIN:PlayerSwitchFlashlight(client, bEnabled)
    local character = client:GetCharacter()

    if character and character:GetData("headlamp", false) == true then
        client:SetNWBool("customFlashlight", not client:GetNWBool("customFlashlight"))
        client:EmitSound("items/flashlight1.wav")

        return false
    end
end