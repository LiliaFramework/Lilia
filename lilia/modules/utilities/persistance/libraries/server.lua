function MODULE:SaveData()
    local data = {}
    for _, v in ents.Iterator() do
        if v.IsLeonNPC or v.IsPersistent then
            data[#data + 1] = {
                class = v:GetClass(),
                pos = v:GetPos(),
                angles = v:GetAngles(),
                model = v:GetModel(),
                skin = v:GetSkin(),
                color = v:GetColor(),
                material = v:GetMaterial(),
                bodygroups = v:GetBodyGroups(),
            }
        end
    end

    self:setData(data)
end

function MODULE:LoadData()
    for _, v in pairs(self:getData() or {}) do
        local ent = ents.Create(v.class)
        if v.pos then ent:SetPos(v.pos) end
        if v.angles then ent:SetAngles(v.angles) end
        if v.model then ent:SetModel(v.model) end
        if v.skin then ent:SetSkin(v.skin) end
        if v.color then ent:SetColor(v.color) end
        if v.material then ent:SetMaterial(v.material) end
        ent:Spawn()
        ent:Activate()

        if v.bodygroups then
            for id, num in pairs(v.bodygroups) do
                ent:SetBodygroup(id, num)
            end
        end
    end
end