--------------------------------------------------------------------------------------------------------
local function GetItemWithDataKeyValue(inv, class, key, value)
    local items = inv:getItemsOfType(class)
    local foundItem
    for _, item in pairs(items) do
        if item:getData(key) == value then
            foundItem = item
            break
        end
    end

    return foundItem
end
--------------------------------------------------------------------------------------------------------
function MODULE:PlayerButtonDown(client, key)
    if not client or not client:Alive() or not client:getChar() then return end
    if not IsFirstTimePredicted() then return end
    local inventory = client:getChar():getInv()
    local radioItem = GetItemWithDataKeyValue(inventory, "radio", "enabled", true)
    local voice_enabled = client:GetNW2Bool("radio_voice", false)
    if radioItem and key == lia.config.BindKey and not voice_enabled then
        client:EmitSound("ui/buttonclick.wav")
        net.Start("RadioTransmit")
        net.WriteBool(true)
        net.SendToServer()
        permissions.EnableVoiceChat(true)
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:PlayerButtonUp(client, key)
    if not client or not client:Alive() or not client:getChar() then return end
    if not IsFirstTimePredicted() then return end
    local inventory = client:getChar():getInv()
    local radioItem = GetItemWithDataKeyValue(inventory, "radio", "enabled", true)
    local voice_enabled = client:GetNW2Bool("radio_voice")
    if radioItem and key == lia.config.BindKey and voice_enabled then
        client:EmitSound("ui/buttonclick.wav")
        net.Start("RadioTransmit")
        net.WriteBool(false)
        net.SendToServer()
        permissions.EnableVoiceChat(false)
        RunConsoleCommand("-voicerecord")
    end
end
--------------------------------------------------------------------------------------------------------