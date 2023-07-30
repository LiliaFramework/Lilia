netstream.Hook("lia_bodygroupclosetapplychanges", function(client, data)
    for k, v in ipairs(ents.FindByClass("lia_bodygroupcloset")) do
        if v:GetPos():Distance(client:GetPos()) < 128 then
            client:SetSkin(data.skin or 0)
            client:getChar():setData("skin", data.skin or 0)
            local group = client:getChar():getData("groups") or {}

            for k, v in pairs(data.groups) do
                client:SetBodygroup(k, v)
                group[k] = v
            end

            client:getChar():setData("groups", group)

            return
        end
    end
end)

netstream.Hook("onlia_bodygroupclosetclose", function(client)
    for k, v in ipairs(ents.FindByClass("lia_bodygroupcloset")) do
        if v:GetPos():Distance(client:GetPos()) < 128 then
            v:EmitSound("items/ammocrate_close.wav")
        end
    end
end)