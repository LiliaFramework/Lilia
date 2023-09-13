--------------------------------------------------------------------------------------------------------
netstream.Hook(
    "radioAdjust",
    function(client, freq, id)
        local inv = client:getChar() and client:getChar():getInv() or nil
        if inv then
            local item
            if id then
                item = lia.item.instances[id]
            else
                item = inv:hasItem("radio")
            end

            local ent = item:getEntity()
            if item and (IsValid(ent) or item:getOwner() == client) then
                (ent or client):EmitSound("buttons/combine_button1.wav", 50, 170)
                item:setData("freq", freq, player.GetAll(), false, true)
            else
                client:notifyLocalized("radioNoRadio")
            end
        end
    end
)

--------------------------------------------------------------------------------------------------------
net.Receive(
    "RadioTransmit",
    function(len, ply)
        local value = net.ReadBool()
        ply:SetNW2Bool("radio_voice", value)
    end
)
--------------------------------------------------------------------------------------------------------