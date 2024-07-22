function MODULE:SaveData()
    local data = {}
    for _, v in ents.Iterator() do
        if v:IsLiliaPersistent() then
            data[#data + 1] = {
                pos = v:GetPos(),
                class = v:GetClass(),
                model = v:GetModel(),
                angles = v:GetAngles(),
            }
        end
    end

    self:setData(data)
end

function MODULE:LoadData()
    for _, v in pairs(self:getData() or {}) do
        local ent = ents.Create(v.class)
        if IsValid(ent) then
            if v.pos then ent:SetPos(v.pos) end
            if v.angles then ent:SetAngles(v.angles) end
            if v.model then ent:SetModel(v.model) end
            ent:Spawn()
            ent:Activate()
        end
    end
end